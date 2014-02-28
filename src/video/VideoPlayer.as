package video
{
	import com.greensock.motionPaths.RectanglePath2D;
	import data.Data;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	import skin.events.RateEvent;
	import video.events.BufferingEvent;
	import video.events.LoadingEvent;
	import video.events.NetConnectionEvent;
	import video.events.NetStreamEvent;
	import video.events.OnMetaDataEvent;
	import video.events.PlayingEvent;
	import video.events.PlayStatusEvent;
	import video.events.StreamNotFountEvent;
	import zhen.guo.yao.components.yaotrace.YaoTrace;

	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class VideoPlayer extends Sprite  
	{
		public static const RE_CONNECT_COUNT:uint = 3;
		
		private var _video:Video;
		
		private var _netStream:NetStream;
		private var _tempStream:NetStream;
		private var _netConnetction:NetConnection;
		
		private var _totalTime:Number = -1;//视频总时间
		private var _staticTotalTime:Number = -1;//视频总时间
		private var _currentTime:Number = 0;//当前时间
		
		private var _beforChangeRateTime:Number = 0;
		private var _videoCanAttachNetStream:Boolean = true;
		private var _connectSuccess:Boolean = false;//连接是否成功了
		private var _metaData:Object
		
		private var _playStatus:String = "";
		private var _useFms:Boolean = false;//是否使用fms
		
		private var _playingTimer:Timer;
		private var _loadingTimer:Timer;
		private var _bufferingTimer:Timer;
		private var _reConnectTimer:Timer;
		private var _checkBufferLengthTimer:Timer;
        private var _seekAfterPlayTimer:Timer;
		
		
		private var _fms:String;
		private var _stream:Object;
		private var _bufferTime:Number;
		
		private var _stop:Boolean = false;
		private var _flush:Boolean = false;
		private var _bufferEmpty:Boolean=true
		private var _firstOnStart:Boolean = true;
		private var _live:Boolean = false;
		private var _currentReconnectCount:uint = 0;
		private var _currentRate:String;
		private var _startTime:Number;
		private var _lastPlayRate:String;
		private var _buffering:Boolean;
		private var _playCount:uint = 0;
		private var _videoRatio:Number;
		private var _lastByteLoaded:uint = 0
		private var _loadPer:Number = 0;
		private var _timeOnDrag:Number=0//只用于mp4
		
		public var bufferFullCount:uint = 0;//缓冲区满的次数
		public var byteLoaded:uint = 0;
		
		public function VideoPlayer():void
		{
			initVideo(400, 300);
			
			_reConnectTimer = new Timer(100,1);
			_reConnectTimer.addEventListener(TimerEvent.TIMER, reConnectTimerHandler);
			
			_seekAfterPlayTimer = new Timer(100,1);
			_seekAfterPlayTimer.addEventListener(TimerEvent.TIMER, seekAfterPlayTimerHandler);
		}
		//初始化视频元件
		private function initVideo(videoWidth:Number,videoHeight:Number):void
		{
			_video = new Video();
			_video.width = videoWidth;
			_video.height = videoHeight;
			_video.smoothing = true;
			addChild(_video);
		}
		//初始化连接
		private function initNetConnecttion():void
		{
			 _netConnetction = new NetConnection();
			 _netConnetction.addEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
			 _netConnetction.client = this;
		}
        //初始化流
		private function initStream(nc:NetConnection,videoComonent:Video,bufferTime:Number):void
		{
			_tempStream = new NetStream(nc);
			_tempStream.client = this;
			_tempStream.bufferTime = bufferTime / 1000;
			_tempStream.addEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
		}
		private function onConnectSuccess():void
		{
			_playCount++;
			_connectSuccess = true;
			initTimer();
			initStream(_netConnetction, _video, _bufferTime);
			if (_live)
			{
				_tempStream.play(String(_stream),-1);
			}
			else
			{
				var stream:String = getStream();
				//dispacheVideoRatio(streamArray[2]);
				_tempStream.play(stream, 0);
				//_tempStream.seek(_startTime);
			}	
		}
		private function ncStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			trace(msg)
			switch (msg) 
			{ 
				case "NetConnection.Connect.Success":
					onConnectSuccess();
					break;
				case "NetConnection.Connect.Failed":
					_reConnectTimer.start();
					break
				case "NetConnection.Connect.Rejected":
				    break;
				case "NetConnection.Connect.Closed":
					clear()
					break;
			}
			var event:NetConnectionEvent = new NetConnectionEvent(NetConnectionEvent.CHANGE);
			event.status = msg;
			dispatchEvent(event);
		}
		private function reConnectTimerHandler(evn:TimerEvent):void
		{
			reConnect();
		}
		private function seekAfterPlayTimerHandler(evn:TimerEvent):void
		{
			if (_tempStream)
			{
				advSeek(_tempStream, _beforChangeRateTime);
			}
			if (_netStream)
			{
				advSeek(_netStream, _beforChangeRateTime);
			}
		}
		private function reConnect():void
		{
			if (_currentReconnectCount < RE_CONNECT_COUNT)
			{
				_currentReconnectCount++;
				trace("再次尝试连接服务器")
				if (_fms == "")
				{
					_netConnetction.connect(null);
				}
				else
				{
					_netConnetction.connect(_fms);
				}
			}
			else
			{
				_connectSuccess = false;
				
				var event:NetConnectionEvent = new NetConnectionEvent(NetConnectionEvent.CHANGE);
				event.status = "NetConnection.ReConnect.Failed";
				dispatchEvent(event);
			}
		}
		private function onStreamNotFound():void
		{
			var event:StreamNotFountEvent = new StreamNotFountEvent(StreamNotFountEvent.STREAM_NOT_FOUNT);
			event.rate = _currentRate;
			dispatchEvent(event);
			
			switch (_currentRate)
			{
				case "2":	
					if (_lastPlayRate)
					{
						changeStreamRate(_lastPlayRate);
					}
					else
					{
						changeStreamRate("1");
					}
					break;
				case "1":
					if (_lastPlayRate)
					{
						changeStreamRate(_lastPlayRate);
					}
					else
					{
						changeStreamRate("3");
					}
					break;
				case "3":
					if (_lastPlayRate)
					{
						changeStreamRate(_lastPlayRate);
					}
					else
					{
						if (_loadingTimer)
						{
							_loadingTimer.stop();
						}
						_playingTimer.stop();
						dispatchEvent(new Event("streamNotFound"));
					}
					break;
			}
		}
		private function nsStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			trace(msg)
			switch (msg) 
			{ 
				case "NetStream.Play.Start":
					onPlayStart();
					break;
				case "NetStream.Buffer.Full":
					bufferFullCount++;
				    _flush = false;
					_buffering = false;
					_bufferEmpty = false;
					_bufferingTimer.reset();
					
					if (_tempStream)
					{
						_netStream = _tempStream;
						_tempStream = null;
					}
					if (_videoCanAttachNetStream)
					{
						_video.attachNetStream(_netStream);
					}
					if (_startTime != 0)
					{
						advSeek(_netStream,_startTime)
						_startTime = 0;
					}
				    break;
				case "NetStream.Buffer.Empty":
					onBufferEmpty();
				    break;
				case "NetStream.Seek.Notify":
					_flush = false;
					_bufferEmpty = false;
					_playingTimer.start();
				    break;
				case "NetStream.Seek.Complete":
					_videoCanAttachNetStream = true;
					break;
				case "NetStream.Seek.InvalidTime":	
					advSeek(_netStream,evn.info.details)
				    break;
				case "NetStream.Buffer.Flush":
				    _flush = true;
					onBufferFlush()
				    break;	
				case "NetStream.Unpause.Notify":
				    break;	
				case "NetStream.Play.Stop":
				    _stop = true;
					onPlayStop()
				    break;	
				case "NetStream.Play.StreamNotFound":
				case "NetStream.Failed":
					onStreamNotFound();
					break;
				case "NetStream.Play.UnpublishNotify":
					_checkBufferLengthTimer.start();
					break;
				case "NetStream.Play.PublishNotify":
					if (_playStatus == "" || _playStatus == Data.UN_PUBLISH)
					{
						_bufferingTimer.reset();
						_buffering = true;
						_bufferingTimer.start();
					}
					_checkBufferLengthTimer.reset();
					break;
			}
			var event:NetStreamEvent = new NetStreamEvent(NetStreamEvent.CHANGE);
			event.status = msg;
			dispatchEvent(event);
		}
        private function onPlayStart():void
		{
			if (!_useFms)
			{
				_loadingTimer.reset()
				_loadingTimer.start();
			}
			if (_videoCanAttachNetStream == false)
			{
				_seekAfterPlayTimer.reset();
				_seekAfterPlayTimer.start();
				_videoCanAttachNetStream = true;
			}
			
			_playingTimer.reset();
			_playingTimer.start();
			
			_bufferingTimer.reset();
			_bufferingTimer.start();
			_buffering = true;
			
			_lastPlayRate = _currentRate;
			if (_firstOnStart)
			{	
				_firstOnStart = false;
				
				_playStatus = Data.PLAY;	
				
				var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
				event.status = Data.PLAY;
				dispatchEvent(event);
			}
		}
		private function playComplete():void
		{
			_firstOnStart = true;
			_playStatus = Data.COMPLETE;
			
			_bufferingTimer.stop();
			_playingTimer.stop();
			_buffering = false;

			bufferFullCount = 0;
			_lastByteLoaded = 0;
			
			var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
			if (_live)
			{
				event.status = Data.UN_PUBLISH;
			}
			else
			{
				event.status = Data.COMPLETE;
			}
			dispatchEvent(event);
			
			_netConnetction.close();
		}
		private function onBufferEmpty():void
		{			
			_bufferEmpty = true;
			if (!_useFms)
			{
				if (_flush && _stop)
				{
					playComplete();
				}
			}
			
			if (_playStatus != Data.COMPLETE)
			{
				_buffering = true;
				if (_bufferingTimer)
				{
					_bufferingTimer.start();
				}
			}
		}
		private function onBufferFlush():void
		{
			checkFinishOnNotUseFms();
		}
		private function onPlayStop():void
		{
			checkFinishOnNotUseFms();
		}
		private function checkFinishOnNotUseFms():void
		{
			if (!_useFms)
			{
				if (_flush && _stop && _bufferEmpty)
				{
					playComplete();
				}
			}
		}
		private function initTimer():void
		{
			_playingTimer = new Timer(200);
			_checkBufferLengthTimer = new Timer(200);
			
			if (_live)
			{
				_checkBufferLengthTimer.addEventListener(TimerEvent.TIMER, checkBufferLengthTimerHandler);
			}
			else
			{
				_playingTimer.addEventListener(TimerEvent.TIMER, playingTimerHandler);
			}
			//_playingTimer.addEventListener(TimerEvent.TIMER, playingTimerHandler);	
			if (!_useFms)
			{
				_loadingTimer = new Timer(100);
				_loadingTimer.addEventListener(TimerEvent.TIMER, loadingHandler);
			}

			_bufferingTimer = new Timer(200);
			_bufferingTimer.addEventListener(TimerEvent.TIMER, bufferingTimerHandler);
		}
		 //加载中
		private function loadingHandler(evn:Event):void
		{
			if (_netStream)
			{
				byteLoaded += _netStream.bytesLoaded - _lastByteLoaded;
				_lastByteLoaded = _netStream.bytesLoaded;
				_loadPer = _netStream.bytesLoaded / _netStream.bytesTotal
				var event:LoadingEvent = new LoadingEvent(LoadingEvent.LOADING);
				if (_netStream.bytesLoaded < _netStream.bytesTotal)
				{
					event.percent = _loadPer;
				}
				else
				{
					event.percent = 1;
					_loadingTimer.reset();
					dispatchEvent(new Event("loadingComplete"))
				}
				dispatchEvent(event);
			}
		}
		private function playingTimerHandler(evn:TimerEvent):void
		{
			if (_netStream)
			{
				if (currentTime > 1)
				{
					if (currentTime * 1000 <= totalTime)
					{
						var event:PlayingEvent = new PlayingEvent(PlayingEvent.PLAYING);
						event.currentTime = currentTime * 1000;
						dispatchEvent(event);
					}
				}
			}
			
		}
		private function bufferingTimerHandler(evn:TimerEvent):void
		{
			var event:BufferingEvent = new BufferingEvent(BufferingEvent.BUFFERING);
			if (_netStream)
			{
				event.percent = _netStream.bufferLength / _netStream.bufferTime;
			}
			else
			{
				if (_tempStream)
				{
					event.percent = _tempStream.bufferLength / _tempStream.bufferTime;
				}
			}
			dispatchEvent(event);
		}
		//只有直播，才会触发
		private function checkBufferLengthTimerHandler(evn:TimerEvent):void
		{
			var xxx:NetStream;
			if (_netStream)
			{
				xxx = _netStream;
			}
			else
			{
				xxx = _tempStream;
			}
			
			playComplete();
			xxx.close();
			xxx.play(String(_stream), -1);
			_checkBufferLengthTimer.reset();
		}
		private function _pause():void
		{
			if (_connectSuccess)
			{
				if (_playStatus == Data.PLAY)
				{
					_netStream.pause();
					_playStatus = Data.PAUSE;
					//_playingTimer.stop();

					var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
					event.status = Data.PAUSE;
					dispatchEvent(event);
				}
			}
		}
		private function _seek(time:Number,forceConnect:Boolean):void
		{
			if (_connectSuccess)
			{
				_playingTimer.stop();
				advSeek(_netStream,time)
			}
			else
			{
				if (forceConnect)
				{
					play(_stream,_fms,_currentRate,time,_bufferTime,_live);
				}
			}
		}
		private function _resume():void
		{
			if (_connectSuccess)
			{
				switch(_playStatus)
				{
					case Data.PAUSE:
						_netStream.resume();
						_playStatus = Data.PLAY;
						//_playingTimer.start();
						break;
					case Data.COMPLETE:
						var stream:String = getStream();
						//dispacheVideoRatio(streamArray[2]);
						_netStream.play(stream,0);
						_playStatus = Data.PLAY;
						_playingTimer.start();
						break;
				}
				var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
				event.status = Data.PLAY;
				dispatchEvent(event);
			}
		}
		private function clearNetStream():void
		{
			if (_netStream)
			{
				_netStream.close();
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
				_netStream = null;
			}
			
			_netStream = null;
		}
		private function clearNetConnection():void
		{
			if (_netConnetction)
			{
				_netConnetction.removeEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
				_netConnetction.close();
				_netConnetction = null;
			}
		}
		private function dispacheVideoRatio(ratio:String):void
		{
			_videoRatio = Number(ratio);
			dispatchEvent(new Event("videoRatioChanged"));
		}
		public function clear():void
		{			
			clearNetConnection();
			clearNetStream();
			
			_totalTime = -1;
			_timeOnDrag = 0;
			bufferFullCount = 0;
			_firstOnStart = true;
			_connectSuccess = false;
			_playStatus= "";
		    _useFms = false;
			_stop = false;
			_flush = false;
			_buffering = false;
			//_lastByteLoaded = 0;
			
			_video.smoothing = false;
			_video.clear();
			
			if (_playingTimer)
			{
				_playingTimer.stop();
				_playingTimer.removeEventListener(TimerEvent.TIMER, playingTimerHandler);
				_playingTimer = null;
			}
			
			if (!_useFms)
			{
				if (_loadingTimer != null)
				{
					_loadingTimer.stop();
					_loadingTimer.removeEventListener(TimerEvent.TIMER, loadingHandler);
					_loadingTimer = null;
				}
			}
			if (_bufferingTimer)
			{
				_bufferingTimer.stop();
				_bufferingTimer.removeEventListener(TimerEvent.TIMER, bufferingTimerHandler);
				_bufferingTimer = null;
			}
			if (_checkBufferLengthTimer)
			{
				_checkBufferLengthTimer.reset();
				_checkBufferLengthTimer.removeEventListener(TimerEvent.TIMER, checkBufferLengthTimerHandler);
				_checkBufferLengthTimer = null;
			}
			dispatchEvent(new Event("loadingComplete"))
		}
		private function _play(stream:Object,fms:String,startRate:String,startTime:Number,bufferTime:Number,live:Boolean):void
		{
			_video.smoothing = true;
			
			if (_netConnetction != null)
			{
				clear();
			}
			_bufferTime = bufferTime;
			_startTime = startTime;
			_stream = stream;
			_live = live;
			_fms = fms;
			_currentRate = startRate;

			initNetConnecttion();

			if (fms == "")
			{
				_useFms = false;
				_netConnetction.connect(null);
			}
			else
			{
				_useFms = true;
				try
				{
					_netConnetction.connect(fms);
				}
				catch (err:Error)
				{
					YaoTrace.add(YaoTrace.ERROR, "netconnection.connect方法参数无效，请检查json数据中fms的值是否合法");
					
					var event:NetConnectionEvent = new NetConnectionEvent(NetConnectionEvent.CHANGE);
					event.status = "NetConnection.ReConnect.Failed";
					dispatchEvent(event);
				}
			}
		}
		private function advSeek(stream:NetStream,time:Number):void
		{
			if (_useFms)
			{
				if (stream)
				{
					stream.seek(time);
				}
			}
			else
			{
			    if(keyframes.data == undefined)
				{
					if (stream)
					{
						stream.seek(time);
					}
				}
				else
				{
					_lastByteLoaded = 0;
					var currentStream:String = getStream();
					var theKeyFrame:Number
					if(keyframes.type=="flv")
					{
						theKeyFrame = getFlvPosFromTime(keyframes.data.times, keyframes.data.filepositions, time);
					}
					else if(keyframes.type=="mp4")
					{
						theKeyFrame = getMp4PosFromTime(time, keyframes.data);
						_timeOnDrag = Number(theKeyFrame);
					}
                	var bool:Boolean = currentStream.indexOf("?") != -1
                	if(bool)
                	{
				    	stream.play(currentStream + "&start="+theKeyFrame )
               	 	}
                	else
                	{
						stream.play(currentStream + "?start=" + theKeyFrame)
                	}
				}
				if ( status == Data.PAUSE)
				{
					_resume()
				}
			}
		}
		private function getFlvPosFromTime(param1:Array, param2:Array, param3:Number) : Number
        {
            var repos = param2[param2.length - 1];
            if (param3 <= param1[0])
            {
                return 0;
            }
            var _loc_4 = 0;
            while (_loc_4 <= param1.length - 2)
            {
                
                var prePos = param1[_loc_4];
                var nextPos = param1[(_loc_4 + 1)];
                if (param3 >= prePos && param3 < nextPos)
                {
                    repos = param2[_loc_4];
                    break;
                }
                _loc_4 = _loc_4 + 1;
            }
            return repos;
        }// end function
        private function getMp4PosFromTime(second:Number, seekpoints:Object):Number
  		{
    		var index1 = 0;
    		var index2 = 0;
    		// Iterate through array to find keyframes before and after scrubber second
    		for(var i = 0; i != seekpoints.length; i++)
    		{
      			if(seekpoints[i]["time"] < second)
      			{
        			index1 = i;
      			}
      			else
      			{
        			index2 = i;
        			break;
      			}
			}

    		// Calculate nearest keyframe
    		if(second - seekpoints[index1]["time"] < seekpoints[index2]["time"] - second)
    		{
        		return seekpoints[index1]["time"];
    		}
    		else
    		{
        		return seekpoints[index2]["time"];
    		}
			return 0
  		}
		///////////////////////////////////////////////////////////////////////////////////////////////
		public function onMetaData(obj:Object):void
		{
			trace("时长："+obj.duration)
			if (_totalTime == -1)
			{
				_metaData = obj;
				_totalTime = _metaData.duration * 1000;
				_staticTotalTime = _totalTime;
				var event:OnMetaDataEvent = new OnMetaDataEvent(OnMetaDataEvent.ON_METADATA);
				event.metaData = _metaData;
				dispatchEvent(event);
				//trace("a:"+_metaData.hasKeyframes)
				/*for (var item in _metaData)
				{
					//trace(item+":"+_metaData[item])
					if(item=='keyframes')
					{
						trace(_metaData[item].times)
					}
					if(item=='seekpoints')
					{
						for(var xx in _metaData[item])
						{
							trace(xx+":"+_metaData[item][xx]["time"])
							trace(xx+":"+_metaData[item][xx]["offset"])
						}
					}
				}*/
				//trace(_metaData.keyframes.times)
				//trace(_metaData.keyframes.filepositions)
				//trace(getPosFromTime(_metaData.keyframes.times, _metaData.keyframes.filepositions,15))
			}
		}
		public function onPlayStatus(obj:Object):void
		{
			switch (obj.code)
			{
				case "NetStream.Play.Complete":
					if (_useFms)
					{
						playComplete();
					}
				    break;
				case "NetStream.Play.TransitionComplete":
				    trace("流切换成功")
					break;
			}
		}
		public function onBWDone():void
		{
			
		}
		public function onXMPData(obj:Object):void
		{
			
		}
		public function onFI(obj:Object):void
		{
			
		}
		public function get close()
		{
			
		}
		public function get onTimeCoordInfo()
		{
			
		}
		/****************************************************************************** 方法 **********************/
		public function play(stream:Object,fms:String="",startRate:String="1",startTime:Number=0,bufferTime:Number=5000,live:Boolean=false):void
		{
			_play(stream,fms,startRate,startTime,bufferTime,live);
		}
		public function changeStreamRate(rate:String):void
		{
			if (_netStream)
			{
			    _beforChangeRateTime = currentTime;
				_videoCanAttachNetStream = false;
			}
			
			clearNetStream();
			_currentRate = rate;
			initStream(_netConnetction, _video, _bufferTime);
			
			
			if (status == Data.PAUSE)
			{
				_playStatus = Data.PLAY;
				
				var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
				event.status = Data.PLAY;
				dispatchEvent(event);
			}
			
			var rateEvent:RateEvent = new RateEvent(RateEvent.RATE_CHANGE);
			rateEvent.rate = _currentRate;
			dispatchEvent(rateEvent);
			
			var stream:String = getStream();
			//dispacheVideoRatio(streamArray[2]);
			_tempStream.play(stream, 0);
			//_tempStream.seek(tempTime);
		}
		private function getStream():String
		{
			var n:uint = _stream.length;
			for (var i:uint = 0; i < n; i++)
			{
				if (_stream[i].type == _currentRate)
				{
					return String(_stream[i].stream);
				}
			}
			return null;
		}
		public function play2():void
		{
			if (_live)
			{
				_netStream.play(String(_stream),-1);
			}
			else
			{
				var stream:String = getStream();
				//dispacheVideoRatio(streamArray[2]);
				_netStream.play(stream,0);
			}
		}
		public function pause():void
		{
			_pause();
		}
		public function resume():void
		{
			_resume();
		}
		public function seek(time:Number,forceConnect:Boolean=false):void
		{
			_seek(time,forceConnect);
		}
		//设置音量
		public function setVol(n:Number):void
		{
			SoundMixer.soundTransform = new SoundTransform( n );
		}
		public function stop():void
		{
			//_netStream.close();
		}
		public function closeNetconnection():void
		{
			if (_netConnetction)
			{
				_netConnetction.close();
			}
		}
		/****************************************************************************** 属性 ********************/
		//连接是否成功
		public function get connectSuccess():Boolean
		{
			return _connectSuccess;
		}
		//视频持续时间
		public function get totalTime():Number
		{
			return _staticTotalTime;
		}
		//视频当前时间
		public function get currentTime():Number
		{
			if (_connectSuccess)
			{
				if (_netStream)
				{
				    if (keyframes.type == "flv")
					{
						return _netStream.time;
					}
					else if (keyframes.type == "mp4")
					{
						return _timeOnDrag + _netStream.time;
					}
				}
				else 
				{
					return -1;
				}
			}
			return -1;
		}
		public function get buffering():Boolean
		{
			return _buffering;
		}
		public function get status():String
		{
			return _playStatus;
		}
		public function get playCount():uint
		{
			return _playCount;
		}
		public function get videoRatio():Number
		{
			return _videoRatio;
		}
		public function get currentVideoURL():String
		{
			var currentStream:String = getStream();
			if (_useFms)
			{
				return _fms + currentStream;
			}
			return currentStream;
		}
		public function get currentFMS():String
		{
			return _fms;
		}
		public function get currentStream():Object
		{
			return _stream
		}
		public function get keyframes():Object
		{
			var videoKeyFrames:Object=new Object()
			
			if(_metaData.keyframes != undefined)
			{
				videoKeyFrames.type='flv'
				videoKeyFrames.data=_metaData.keyframes
			}
			else if(_metaData.seekpoints != undefined)
			{
				videoKeyFrames.type='mp4'
				videoKeyFrames.data=_metaData.seekpoints
			}
			return videoKeyFrames
		}
		public function get loadPer():Number
		{
			return _loadPer
		}
	}
	
}