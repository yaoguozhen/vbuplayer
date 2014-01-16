package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class VideoPreview 
	{
		private var _container:MovieClip
		private var _video:Video;
		private var _netConnetction:NetConnection
		private var _netStream:NetStream
		private var _fms:String;
		private var _stream:String
		private var _gotoTime:Number = 0
		private var _closeConnectionTimer:Timer
		private var _showVideoTimer:Timer
		private var _path:MovieClip
		private var _totalTime:Number = -1;
		private var _connecting:Boolean = false
		private var _metaData:Object
		private var _useFms:Boolean = true;
		
		public function VideoPreview():void 
		{
			initTimer()
			initNetConnecttion()
		}
		private function initTimer():void
		{
			_closeConnectionTimer = new Timer(2000)
			_closeConnectionTimer.addEventListener(TimerEvent.TIMER, closeConnTimerHandler);
			
			_showVideoTimer = new Timer(500)
			_showVideoTimer.addEventListener(TimerEvent.TIMER, showVideoTimerHandler);
		}
		private function closeConnTimerHandler(evn:TimerEvent):void
		{
			_clear()
		}
		private function _clear():void
		{
			_closeConnectionTimer.reset();
			if (_netConnetction)
			{
				//_netConnetction.close();
			}
			if (_netStream)
			{
				_netStream.close()
			}
			_gotoTime = 0;
			//_netStream = null;
			if (_video)
			{
				_video.clear()
			}
			clear();
		}
		private function showVideoTimerHandler(evn:TimerEvent):void
		{
			_showVideoTimer.stop()
			_container.visible = true
			setContainerPosition()
			gotoPlay(_totalTime*_path.mouseX/_path.width)
		}
		private function setContainerPosition():void
		{
			_container.x = _path.parent.x + _path.mouseX - _container.width / 2;
			_container.y = _path.parent.parent.y - _container.height;
		}
		private function initVideo(videoWidth:Number,videoHeight:Number):void
		{
			_video = new Video();
			_video.width = videoWidth;
			_video.height = videoHeight;
			_video.smoothing = true;
			_container.addChild(_video);
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
			_netStream = new NetStream(nc);
			_netStream.client = this;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
			//_netStream.bufferTime = bufferTime;
			_netStream.soundTransform=new SoundTransform(0)
			_video.attachNetStream(_netStream);
		}
		private function nsStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			trace("预览："+msg)
			switch (msg) 
			{ 
				case "NetStream.Seek.InvalidTime":	
					advSeek(_netStream,evn.info.details)
				    break;
			}
		}
		private function onConnectSuccess():void
		{
			initStream(_netConnetction, _video, 1);
			_netStream.play(_stream,_gotoTime);
		}
		private function ncStatusHandler(evn:NetStatusEvent):void
		{
			_connecting = false;
			var msg:String = evn.info.code;
			trace("预览："+msg)
			switch (msg) 
			{ 
				case "NetConnection.Connect.Success":
					onConnectSuccess();
					break;
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Closed":
					clear()
					break;
			}
		}
		private function scale(rect:Rectangle,b:Number=0):void
		{			
			var areaPer:Number = rect.width / rect.height;
			var videoPer:Number
			if (b==0)
			{
				videoPer = _video.width / _video.height;
			}
			else
			{
				videoPer = b;
			}

			if (videoPer >= areaPer)
			{
				_video.width = rect.width;
				_video.height = _video.width / videoPer;
			   
				_video.y = (rect.height - _video.height) / 2;
				_video.x = 0;
				
			}
			else
			{
				_video.height = rect.height;
				_video.width = _video.height * videoPer;
				_video.x = (rect.width - _video.width) / 2;
				_video.y = 0;
			}
		}
		private function pathRollOverHandler(evn:MouseEvent):void
		{
			_showVideoTimer.start()
			_path.addEventListener(MouseEvent.ROLL_OUT, pathRollOutHandler);
			_path.addEventListener(MouseEvent.MOUSE_MOVE, pathMoveHandler);
		}
		private function pathRollOutHandler(evn:MouseEvent):void
		{
			_path.removeEventListener(MouseEvent.ROLL_OUT, pathRollOutHandler);
			_path.removeEventListener(MouseEvent.MOUSE_MOVE, pathMoveHandler);
			_clear()
		}
		private function pathMoveHandler(evn:MouseEvent):void
		{
			setContainerPosition()
			gotoPlay(_totalTime*_path.mouseX/_path.width)
		}
		private function advSeek(stream:NetStream,time:Number):void
		{
			if (_useFms)
			{
				stream.seek(time);
			}
			else
			{
				if (_metaData)
				{
					var theKeyFrame:String = String(getPosFromTime(_metaData.keyframes.times, _metaData.keyframes.filepositions, time));
					_netStream.play(_stream + "?start=" + theKeyFrame)
				}
			}
		}
		private function getPosFromTime(param1:Array, param2:Array, param3:Number) : Number
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
		public function onMetaData(obj:Object):void
		{
			if (_totalTime == -1)
			{
				_metaData = obj;
				_totalTime = _metaData.duration;
				scale(new Rectangle(0, 0, _container.width, _container.height), _metaData.width / _metaData.height)
			}
		}
		public function onPlayStatus(obj:Object):void{}
		public function onBWDone():void{}
		public function onXMPData(obj:Object):void{}
		public function onFI(obj:Object):void{}
		public function get close(){}
		public function get onTimeCoordInfo() { }
		
		public function init(container:MovieClip,path:MovieClip):void
		{
			_container = container;
			_path = path;
			initVideo(10, 10)
			scale(new Rectangle(0, 0, _container.width, _container.height), 4 / 3)
		}
		private function gotoPlay(second:Number):void
		{	
			_closeConnectionTimer.reset()
			_gotoTime = second;
			if (_netConnetction.connected)
			{
				advSeek(_netStream,_gotoTime)
			}
			else
			{
				if (_connecting == false)
				{
					_connecting = true;
					_netConnetction.connect(_fms);
				}
			}
		}
		public function clear():void
		{
			_container.visible=false
			_closeConnectionTimer.start()
			_showVideoTimer.stop()
		}
		public function setVideo(fms:String, stream:String):void
		{
			_fms = fms;
			if (_fms == "")
			{
				_fms = null;
                _useFms = false;			
			}
			_stream = stream;
		}
		public function set active(b:Boolean):void
		{
			if (b)
			{
				if (_stream && _stream != "" && _stream != "null" && _stream != "undefined")
				{
					_path.addEventListener(MouseEvent.ROLL_OVER, pathRollOverHandler);
				}
			}
			else
			{
				_clear();
				_path.removeEventListener(MouseEvent.ROLL_OVER, pathRollOverHandler);
				_path.removeEventListener(MouseEvent.MOUSE_MOVE, pathMoveHandler);
			}
		}
	}

}