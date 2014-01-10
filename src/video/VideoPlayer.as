package video
{
	import adobe.utils.ProductManager;
	import com.greensock.plugins.VolumePlugin;
	import data.Data;
	import flash.display.Sprite;
	import flash.events.Event;
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
		
		private var _totalTime:Number = 0;//视频总时间
		private var _currentTime:Number = 0;//当前时间
		
		private var _beforChangeRateTime:Number = 0;
		private var _videoCanAttachNetStream:Boolean = true;
		private var _connectSuccess:Boolean = false;//连接是否成功了
		
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
		private var _firstOnStart:Boolean = true;
		private var _live:Boolean = false;
		private var _currentReconnectCount:uint = 0;
		private var _currentRate:String;
		private var _startTime:Number;
		private var _lastPlayRate:String;
		private var _buffering:Boolean;
		private var _playCount:uint = 0;
		private var _videoRatio:Number;
		
		public var bufferFullCount:uint = 0;//缓冲区满的次数
		
		
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
				var streamArray:Array = getStream();
				dispacheVideoRatio(streamArray[2]);
				_tempStream.play(streamArray[0], 0);
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
				_tempStream.seek(_beforChangeRateTime);
			}
			if (_netStream)
			{
				_netStream.seek(_beforChangeRateTime);
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
				case "biaozhun":	
					if (_lastPlayRate)
					{
						changeStreamRate(_lastPlayRate);
					}
					else
					{
						changeStreamRate("liuchang");
					}
					break;
				case "liuchang":
					if (_lastPlayRate)
					{
						changeStreamRate(_lastPlayRate);
					}
					else
					{
						changeStreamRate("gaoqing");
					}
					break;
				case "gaoqing":
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
						_netStream.seek(_startTime);
						_startTime = 0;
					}
				    break;
				case "NetStream.Buffer.Empty":
					onBufferEmpty();
				    break;
				case "NetStream.Seek.Notify":
					_flush = false;
					_playingTimer.start();
				    break;
				case "NetStream.Seek.Complete":
					_videoCanAttachNetStream = true;
					break;
				case "NetStream.Seek.InvalidTime":	
					_netStream.seek(evn.info.details);
				    break;
				case "NetStream.Buffer.Flush":
				    _flush = true;
				    break;	
				case "NetStream.Unpause.Notify":
				    break;	
				case "NetStream.Play.Stop":
				    _stop = true;
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
			//_netStream.seek(0);
			//_netStream.pause();
					
			bufferFullCount = 0;
			
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
		}
		private function onBufferEmpty():void
		{			
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
				_bufferingTimer.start();
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
			var per:Number = _netStream.bytesLoaded / _netStream.bytesTotal;
			
			var event:LoadingEvent = new LoadingEvent(LoadingEvent.LOADING);
			event.percent = per;
			dispatchEvent(event);
		}
		private function playingTimerHandler(evn:TimerEvent):void
		{
			//trace(_netStream.info.currentBytesPerSecond/1024)
			
			if (_netStream)
			{
				var event:PlayingEvent = new PlayingEvent(PlayingEvent.PLAYING);
				event.currentTime = _netStream.time*1000;
				dispatchEvent(event);
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
		private function _seek(time:Number):void
		{
			if (_connectSuccess)
			{
				_playingTimer.stop();
				_netStream.seek(time);
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
						var streamArray:Array = getStream();
						dispacheVideoRatio(streamArray[2]);
						_netStream.play(streamArray[0],0);
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
			
			_totalTime = 0;
			bufferFullCount = 0;
			_firstOnStart = true;
			_connectSuccess = false;
			_playStatus= "";
		    _useFms = false;
			_stop = false;
			_flush = false;
			_buffering = false;
			
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
		///////////////////////////////////////////////////////////////////////////////////////////////
		public function onMetaData(obj:Object):void
		{
			_totalTime = obj.duration*1000;
			
			if (_live)
			{
				var event:OnMetaDataEvent = new OnMetaDataEvent(OnMetaDataEvent.ON_METADATA);
				event.videoWidth = obj.width;
				event.videoHeight = obj.height;
				dispatchEvent(event);
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
		public function play(stream:Object,fms:String="",startRate:String="biaozhun",startTime:Number=0,bufferTime:Number=5000,live:Boolean=false):void
		{
			_play(stream,fms,startRate,startTime,bufferTime,live);
		}
		public function changeStreamRate(rate:String):void
		{
			if (_netStream)
			{
			    _beforChangeRateTime = _netStream.time;
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
			
			var streamArray:Array = getStream();
			dispacheVideoRatio(streamArray[2]);
			_tempStream.play(streamArray[0], 0);
			//_tempStream.seek(tempTime);
		}
		private function getStream():Array
		{
			var n:uint = _stream.length;
			for (var i:uint = 0; i < n; i++)
			{
				if (_stream[i][1] == _currentRate)
				{
					return _stream[i];
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
				var streamArray:Array = getStream();
				dispacheVideoRatio(streamArray[2]);
				_netStream.play(streamArray[0],0);
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
		public function seek(time:Number):void
		{
			_seek(time);
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
			if (_connectSuccess)
			{
				return _totalTime;
			}
			return 0;
		}
		//视频当前时间
		public function get currentTime():Number
		{
			if (_connectSuccess)
			{
				if (_netStream)
				{
					return int(_netStream.time);
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
	}
	
}