﻿package  
{
	import data.Data;
	import data.DispatchEvents;
	import data.Submit;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import skin.ControlBarManager;
	import skin.events.ChangeLightEvent;
	import skin.events.ProgressChangeEvent;
	import skin.events.RateEvent;
	import skin.events.VideoAreaRateEvent;
	import skin.events.VolChangeEvent;
	import skin.MyDate;
	import video.AdvVideoPlayer;
	import skin.Skin;
	import video.events.BufferingEvent;
	import video.events.LoadingEvent;
	import video.events.NetConnectionEvent;
	import video.events.NetStreamEvent;
	import video.events.OnMetaDataEvent;
	import video.events.PlayingEvent;
	import video.events.PlayStatusEvent;
	import video.events.StreamNotFountEvent;
	import video.VideoPlayer;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	import fl.motion.ColorMatrix;
	import flash.filters.ColorMatrixFilter;
	import flash.net.navigateToURL
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author t
	 */
	public class ABC extends EventDispatcher 
	{
	    private var _skin:Skin;
		private var _videoPlayer:AdvVideoPlayer;
		private var _controlBarManager:ControlBarManager
		private var _stage:Stage;
		private var _waitOnLive:Boolean = true;//缓冲时，当缓冲0%时，是否显示“当前没有直播”
        private var _callJSPerSecondTimer:Timer;//每秒钟调用js定时器
		private var _hideLastPlayTimeAlertTimer:Timer;//上次播放时间消失定时器
		private var _lastTime:Number = 0;//上次播放时间
		private var _ld_Filter:ColorMatrixFilter = new ColorMatrixFilter();
		private var _db_Filter:ColorMatrixFilter = new ColorMatrixFilter();
		
		private var _dragStartTime:Number = -1;//拖拽起始时间点
		private var _bufferEmptyStartTime:Number = -1;//缓冲器空了起始时间点
		private var _connectStartTime:Number = -1;//开始连接起始时间点
		private var _connectSuccessTime:Number = -1;//连接成功起始时间点
		private var _connectUsedTime:Number = 0;//连接耗时
		private var _firstBufferUsedTime:Number = 0;//第一次缓冲用时
		private var _hasDraged:Boolean = false;
		private var _meteData:Object;
		private var _loadingStartTime:uint = -1;
		private var _loadingUsedTime:uint = 0;
		private var _isNewStartPlay:Boolean = true;
		
		public function ABC() :void
		{
			_callJSPerSecondTimer = new Timer(1000);
			_callJSPerSecondTimer.addEventListener(TimerEvent.TIMER, callJsTimerHandler);
			
			_hideLastPlayTimeAlertTimer = new Timer(5000,1);
			_hideLastPlayTimeAlertTimer.addEventListener(TimerEvent.TIMER, hideLastPlayTimeAlertTimerHandler);
		}
		private function callJsTimerHandler(evn:TimerEvent):void
		{
			if (_videoPlayer.currentTime != -1)
			{
				if (_videoPlayer.status == Data.PLAY)//播放的时候才调用
				{
					if (!_videoPlayer.buffering)//缓冲的时候不调用
					{
						var json:String = '{"videolong":"'+int(_videoPlayer.totalTime/1000)+'","nowtime":"'+_videoPlayer.currentTime+'"}';
						DispatchEvents.UPATEE_TIMER(json);
					}
				}
			}
		}
		private function hideLastPlayTimeAlertTimerHandler(evn:TimerEvent):void
		{
			alertMsg1 = "";
		}
		private function setVideoPlayer(v:AdvVideoPlayer):void
		{
			_videoPlayer = v;
			_videoPlayer.addEventListener(PlayStatusEvent.CHANGE, playStatusChangeHandler);
			_videoPlayer.addEventListener(PlayingEvent.PLAYING, playingHandler);
			_videoPlayer.addEventListener(BufferingEvent.BUFFERING, bufferingHandler);
			_videoPlayer.addEventListener(NetStreamEvent.CHANGE, netStreamChangeHandler);
			_videoPlayer.addEventListener(NetConnectionEvent.CHANGE, netConnectionChangeHandler);
			_videoPlayer.addEventListener(LoadingEvent.LOADING, loadingHandler);
			_videoPlayer.addEventListener(OnMetaDataEvent.ON_METADATA, onMetaDataHandler);
			_videoPlayer.addEventListener(RateEvent.RATE_CHANGE, videoPlayerRateChangeHandler);
			_videoPlayer.addEventListener("streamNotFound", streamNotFoundHandler);//所有的流都没有找到
			_videoPlayer.addEventListener("videoRatioChanged", videoRatioChangedHandler);
			_videoPlayer.addEventListener("loadingComplete", loadingCompleteHandler);
			_videoPlayer.addEventListener(StreamNotFountEvent.STREAM_NOT_FOUNT,streamNotFoundHandler2)//某个流没有找到
		}
		private function setSkin(s:Skin):void
		{
			_skin = s;
			
			_controlBarManager = new ControlBarManager();
			_controlBarManager.addEventListener("fullscreenBtnClick", fullscreenBtnClickHandler);
		    _controlBarManager.addEventListener("playBtnClick", playBtnClickHandler);
			_controlBarManager.addEventListener("pauseBtnClick", pauseBtnClickHandler);
			_controlBarManager.addEventListener("screenClickHotClick", screenClickHotClickHandler);
			_controlBarManager.addEventListener("bigPlayBtnClick", bigPlayBtnClickHandler);
			_controlBarManager.addEventListener(VolChangeEvent.CHANGE, volChangeHandler);
			_controlBarManager.addEventListener(ProgressChangeEvent.CHANGE, progressChangeHandler);
			_controlBarManager.addEventListener(RateEvent.RATE_CHANGE, controlBarRateChangeHandler);
			_controlBarManager.addEventListener(VideoAreaRateEvent.RATE_CHANGE, videoAreaRateEventHandler);
			_controlBarManager.addEventListener(ChangeLightEvent.CHANGE, changeLightEventHandler);
			_controlBarManager.add(_skin);
		}
		private function playStatusChangeHandler(evn:PlayStatusEvent):void
		{
			if (evn.status == Data.PLAY)
			{
				if (_videoPlayer.bufferFullCount > 0)
				{
					if (_videoPlayer.status == Data.PLAY)
					{
						_controlBarManager.setVideoStatus = evn.status;
					}
				}
			}
			else
			{
				_controlBarManager.setVideoStatus = evn.status;
			}
			
			switch(evn.status)
			{
				case Data.PLAY:
					_controlBarManager.previewVideo = true;
					break;
				case Data.COMPLETE:
					onPlayComplete();
					break;
				case Data.UN_PUBLISH:
					onUnPublish();
					break;
			}
		}
		private function onPlayComplete():void//点播播放完毕
		{
			_videoPlayer.visible = false;
			//_controlBarManager.progressBarActive = -1;
			//_controlBarManager.playBtnEnabled = false;
			_controlBarManager.setBuffering(false);
			//_callJSPerSecondTimer.reset();
			_controlBarManager.rateBtnEnabled = false;
			//DispatchEvents.STREAM_PLAY_COMPLETE();
			_controlBarManager.previewVideo = false;
			
			_dragStartTime = -1;
		    _bufferEmptyStartTime = -1;
			Submit.submitByteLoaded(_videoPlayer.byteLoaded, _loadingUsedTime);
			_loadingUsedTime = 0;
			_loadingStartTime = -1;
			//Submit.creatUUID()
			_isNewStartPlay = true;
			if (Data.canPlayNext)
			{
				Data.jumpOnPlayComplete = true;
				navigateToURL(new URLRequest(Data.nextVideo), "_self");
			}
		}
		private function onUnPublish():void//直播停止发布
		{
			_videoPlayer.visible = false;
			_controlBarManager.progressBarActive = -1;
			_controlBarManager.playBtnEnabled = false;
			_waitOnLive = true;
			_controlBarManager.setBuffering(false);
			//DispatchEvents.STREAM_PLAY_COMPLETE();
		}
		private function onConnectSuccess():void
		{
			/*if (Data.live)
			{
				this.alertMsg1 = "当前没有直播"
			}*/
			_connectSuccessTime = getTimer();
			_connectUsedTime = _connectSuccessTime - _connectStartTime;
			_connectStartTime = -1;
					
			if (_videoPlayer.playCount == 1)
			{
				if (_lastTime != 0)
				{
					alertMsg1 = "您上次观看到:" + MyDate.getFormatTime(_lastTime * 1000, true) + "，您将继续观看";
					_hideLastPlayTimeAlertTimer.start();
				}
			}
		}
		private function onNetConnectionClose():void
		{
			if (Data.live)
			{
				_waitOnLive = true;
			}
			_videoPlayer.visible = false;
			//_controlBarManager.progressBarActive = -1;
			//_controlBarManager.playBtnEnabled = false;
			_controlBarManager.setBuffering(false);
			_controlBarManager.rateBtnEnabled = false;
			_controlBarManager.setVideoStatus = Data.CLOSED;
			_controlBarManager.bigPlayBtnType = "connect";
			//alertMsg1 = "链接断开，请点击播放按钮重试";
			alertMsg1 = "";
			_hideLastPlayTimeAlertTimer.reset();
			_bufferEmptyStartTime = -1;
			_dragStartTime = -1;
		}
		private function playingHandler(evn:PlayingEvent):void
		{
			_controlBarManager.setTime(evn.currentTime, _videoPlayer.totalTime);
			if (!_callJSPerSecondTimer.running)
			{
				//_callJSPerSecondTimer.start();
			}
		}
		private function bufferingHandler(evn:BufferingEvent):void
		{
			if (Data.live)
			{
				if (evn.percent == 0)
				{
					if (_waitOnLive)
					{
						alertMsg1 = "正在等待直播";
					}
					else
					{
						setBuffering(String(int(evn.percent * 100)));
					}
				}
				else
				{
					_waitOnLive = false;
					setBuffering(String(int(evn.percent * 100)));
				}
				
			}
			else
			{
				setBuffering(String(int(evn.percent * 100)));
			}
		}
		private function setBuffering(str:String):void
		{
			if (!_hideLastPlayTimeAlertTimer.running)
			{
				alertMsg1 = "";
			}
			
			if (_videoPlayer.status != Data.PAUSE)
			{
				_controlBarManager.setBuffering(true, "已缓冲 " + str + "%");
			}
			else
			{
				_controlBarManager.setBuffering(false, "已缓冲 " + str + "%");
			}
		}
		private function loadingHandler(evn:LoadingEvent):void
		{
			_controlBarManager.loadPer = evn.percent;
		}
		private function loadingCompleteHandler(evn:Event):void
		{
			_loadingUsedTime += getTimer() - _loadingStartTime;
			_loadingStartTime = -1;
		}
		private function getDataRate(obj:Object):uint
		{
			var videoBitRate:uint = 0;
			var audioBitRate:uint = 0;
			if (obj.videodatarate != undefined)
			{
				videoBitRate=uint(obj.videodatarate)
			}
			if (obj.audiodatarate != undefined)
			{
				audioBitRate=uint(obj.audiodatarate)
			}
			return videoBitRate + audioBitRate;
		}
		private function getResolution(obj:Object):String
		{
			var str:String = "";
			if (obj.width != undefined && obj.height != undefined)
			{
				str=String(obj.width) + "-" + String(obj.height)
			}
			return str;
		}
		private function submitOnFirstPlay():void
		{
			var dateRate:uint = getDataRate(_meteData);
			var resolution:String = getResolution(_meteData);
			var videoCodeCid:String=""
			var audioCodeCid:String=""
			if (_meteData.videocodecid != undefined)
			{
				videoCodeCid = _meteData.videocodecid;
			}
			if (_meteData.audiocodecid != undefined)
			{
				audioCodeCid = _meteData.audiocodecid;
			}
			Submit.submitOnFirstPlayStart(_connectUsedTime, _firstBufferUsedTime, dateRate, resolution, _meteData.duration, videoCodeCid, audioCodeCid)
		}
		private function onMetaDataHandler(evn:OnMetaDataEvent):void
		{
			_meteData = evn.metaData;

			if (_meteData.width != undefined && _meteData.height != undefined)
			{
				YaoTrace.add(YaoTrace.ALL,"元数据中有视频长宽值，使用元数据的长宽值计算")
				Data.videoRatio = _meteData.width / _meteData.height;
			}
			else
			{
				YaoTrace.add(YaoTrace.ALERT,"元数据中没有视频长宽值,将使用默认比例")
			}
			scale(Data.isFullScreen, Data.videoRatio);
		}
		private function streamNotFoundHandler(evn:Event):void
		{
			alertMsg1 = "视频加载失败";
			_controlBarManager.rateBtnEnabled = false;
			_hideLastPlayTimeAlertTimer.reset();
			YaoTrace.add(YaoTrace.ERROR, "视频均没有找到");
		}
		private function videoRatioChangedHandler(evn:Event):void
		{
			Data.videoRatio = _videoPlayer.videoRatio;
			scale(Data.isFullScreen, Data.videoRatio);
		}
		private function streamNotFoundHandler2(evn:StreamNotFountEvent):void
		{
			_controlBarManager.unActiveRatePanelItem(evn.rate);
			Submit.submitOnPlayFailed("3")
		}
		private function netStreamChangeHandler(evn:NetStreamEvent)
		{
			switch(evn.status)
			{
				case "NetStream.Play.Start":
					_controlBarManager.rateBtnEnabled = true;
					_loadingStartTime = getTimer();
					break;
				case "NetStream.Play.Failed":
					Submit.submitOnPlayFailed("4")
					break;	
				case "NetStream.Buffer.Full":
					_videoPlayer.visible = true;
					if (!Data.live)
					{
						if (Data.progressBarDraged)
						{
							_controlBarManager.progressBarActive = 0;
						}
						else
						{
							_controlBarManager.progressBarActive = 1;
						}
					}
					_controlBarManager.playBtnEnabled = true;
					if (!_hideLastPlayTimeAlertTimer.running)
					{
						alertMsg1 = "";
					}
					_controlBarManager.setBuffering(false);
					if (_videoPlayer.bufferFullCount == 1)
					{
						_controlBarManager.setVideoStatus = Data.PLAY;
						if (!_hasDraged)
						{
							var now:Number = getTimer();
							_firstBufferUsedTime = now - _connectSuccessTime;
							_connectSuccessTime = -1;
						}
						submitOnFirstPlay();
						_firstBufferUsedTime = 0;
					}
					if (Data.live)
					{
						_controlBarManager.adMsg = "";
					}
					submitOnBufferFull()
					break;
				case "NetStream.Buffer.Empty":
					if (Data.live)
					{
						//trace("广告开始计时")
					}
					//_loadingStartTime=getTimer()
					_bufferEmptyStartTime=getTimer()
					break;
				case "NetStream.Play.UnpublishNotify":
					//onUnPublish()
					break;
				case "NetStream.Play.PublishNotify":
					_controlBarManager.adMsg = "";
				    _videoPlayer.visible = true;
					_controlBarManager.progressBarActive = -1;
					_controlBarManager.playBtnEnabled = true;
					break;
			}
		}
		private function netConnectionChangeHandler(evn:NetConnectionEvent)
		{
			switch(evn.status)
			{
				case "NetConnection.ReConnect.Failed":
					alertMsg1 = "服务器连接失败";
					_connectStartTime = -1;
					_hideLastPlayTimeAlertTimer.reset();
					Submit.submitOnPlayFailed("2")
					break;
				case "NetConnection.Connect.Rejected":
					_connectStartTime=-1
					Submit.submitOnPlayFailed("2")
				    break;
				case "NetConnection.Connect.Success":
					onConnectSuccess()
					break;
				case "NetConnection.Connect.Closed":
					//alertMsg1 = "服务器连接已断开"
					onNetConnectionClose();
					break;
			}
		}
		private function submitOnBufferFull():void
		{
			var now:Number = getTimer();
			if (_dragStartTime != -1)
			{
				Submit.submitBufferTimeByDrag(now - _dragStartTime);
				_dragStartTime = -1;
			}
			if (_bufferEmptyStartTime != -1)
			{
				Submit.submitBufferTimeNotByDrag(now - _bufferEmptyStartTime);
				_dragStartTime = -1;
			}
		}
		private function fullscreenBtnClickHandler(evn:Event):void
		{
			switch(_stage.displayState) 
			{
				case "normal":
					_stage.displayState = "fullScreen";  					
					scale(true,Data.videoRatio);
					break;
				case "fullScreen":
					default:
					_stage.displayState = "normal";  
					scale(false,Data.videoRatio);
					break;
			}
			/*trace("准备切换流")
			xx++;
			if (xx == 3)
			{
				xx = 0;
			}
			_videoPlayer.changeStreamRate(xx);	*/
		}
		private function playBtnClickHandler(evn:Event):void
		{
			if (_videoPlayer.status == Data.COMPLETE)
			{
			   
			}
			else
			{
				 _videoPlayer.resume();
			}
		}
		private function pauseBtnClickHandler(evn:Event):void
		{
			_videoPlayer.pause();
		}
		private function volChangeHandler(evn:VolChangeEvent):void
		{
			_videoPlayer.setVol(evn.vol);
		}
		private function progressChangeHandler(evn:ProgressChangeEvent):void
		{
			if (_videoPlayer.status == "")
			{
				_controlBarManager.loadPer = 0;
				_controlBarManager.playPer = 0;
				var cT:Number=evn.per * _videoPlayer.totalTime
				_controlBarManager.setTime(cT,_videoPlayer.totalTime)
				play(_videoPlayer.currentStream,_videoPlayer.currentFMS,cT/1000)
			}
			else
			{
				//_controlBarManager.setVideoStatus = Data.PLAY;
				_hasDraged = true;
				resumeSomePram();
				_bufferEmptyStartTime = -1;
				_loadingStartTime = getTimer();
				_dragStartTime = getTimer();
				var per:Number
				if(_videoPlayer.keyframes == null)
				{
					if(evn.per>= _videoPlayer.loadPer)
					{
						per = _videoPlayer.loadPer;
						_controlBarManager.playPer=per
					}
					else
					{
						per = evn.per;
					}
				}
				else
				{
					per = evn.per;
				}
				_videoPlayer.seek(per * _videoPlayer.totalTime / 1000);
			}
		}
		private function resumeSomePram():void
		{
			_connectStartTime = -1;//开始连接起始时间点
			_connectSuccessTime = -1;//连接成功起始时间点
			_connectUsedTime = 0;//连接耗时
			_firstBufferUsedTime = 0;//第一次缓冲用时
		}
		private function controlBarRateChangeHandler(evn:RateEvent):void
		{
			_videoPlayer.changeStreamRate(evn.rate);
		}
		private function videoAreaRateEventHandler(evn:VideoAreaRateEvent):void
		{
			var per:Number = 0
			switch(evn.rate)
			{
				case "0":
					per = Number(Data.videoRatio);
				    break;
				case "43":
					per = 4 / 3;
					break;
				case "169":
					per = 16 / 9;
					break;
			}
			scale(Data.isFullScreen, per);
		}
		private function changeLightEventHandler(evn:ChangeLightEvent):void
		{
			switch(evn.changeType)
			{
				case "brightness":
					setVideoBrightness(_videoPlayer,evn.value)
					break;
				case "contrast":
					setVideoContrast(_videoPlayer,evn.value)
					break;
			}
		}
		private function setVideoBrightness(obj:DisplayObject,value:Number):void
		{
			var ld_Matrix:ColorMatrix=new ColorMatrix();
			ld_Matrix.SetBrightnessMatrix(value);  //设置亮度值，值的大小是 -255--255   0为中间值，向右为亮向左为暗。
			_ld_Filter.matrix = ld_Matrix.GetFlatArray();
			obj.filters = [_ld_Filter,_db_Filter];
			//ld_MC.filters = [];//去除滤镜
		}
		private function setVideoContrast(obj:DisplayObject,value:Number):void
		{
			var db_Matrix:ColorMatrix=new ColorMatrix();  
			db_Matrix.SetContrastMatrix(value);    
			//设置对比度值，值的大小是 -255--255  127.5为中间值，  
			//向右对比鲜明向左对比偏暗。  
			_db_Filter.matrix = db_Matrix.GetFlatArray();  
			obj.filters = [_ld_Filter,_db_Filter];  
			//db_MC.filters = [];//去除滤镜  
		}
		private function videoPlayerRateChangeHandler(evn:RateEvent):void
		{
			_controlBarManager.setCurrentRate(evn.rate);
			Data.playURL = _videoPlayer.currentVideoURL;
		}
		private function screenClickHotClickHandler(evn:Event):void
		{
			if (_videoPlayer.bufferFullCount > 0)
			{
				switch(_videoPlayer.status)
				{
					case Data.PLAY:
						pause();
						break;
					case Data.PAUSE:
						resume();
						break;
				}
			}
		}
		private function bigPlayBtnClickHandler(evn:Event):void
		{
				if (_controlBarManager.bigPlayBtnType=="resume")
				{
					resume();
				}
				else if (_controlBarManager.bigPlayBtnType=="connect")
				{
					if (_isNewStartPlay)
					{
						_controlBarManager.playPer = 0;
						_controlBarManager.setTime(0,0)
					}
					_controlBarManager.bigPlayBtnType = "resume";
					play(Data.streams, Data.fms);
					if (!Data.live)
					{
						initRate();
					}
				}
				_controlBarManager.adMsg = "";
		}
		private function fullScreenHandler(evn:FullScreenEvent):void
		{
			if (!evn.fullScreen)
			{
				_controlBarManager.isFullScreen = false;
			}
		}
		private function stageClickHandler(evn:MouseEvent):void
		{
			if (evn.target.name != "rateBtn")
			{
				_controlBarManager.hideRatePanel();
			}
		}
		
		public function addObject(v:AdvVideoPlayer,s:Skin,sta:Stage):void
		{
			_stage = sta;
			_stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			_stage.addEventListener(MouseEvent.CLICK, stageClickHandler);
			
			//模拟断网
			/*_stage.addEventListener(KeyboardEvent.KEY_DOWN,deyhdfdf)
			function deyhdfdf(e)
			{
				_videoPlayer.closeNetconnection();
			}*/
			setSkin(s);
			setVideoPlayer(v);
		}
		public function scale(isFullScreen:Boolean,xx):void
		{
			Data.isFullScreen = isFullScreen;
			if (isFullScreen)
			{
				_videoPlayer.scale(new Rectangle(0,0,_stage.stageWidth,_stage.stageHeight),xx);
			}
			else
			{
				_videoPlayer.scale(new Rectangle(0,0,_stage.stageWidth,_stage.stageHeight-_skin.controlBar.height),xx);
			}
			_controlBarManager.scale();
			_controlBarManager.isFullScreen = isFullScreen;
		}
		public function pause():void
		{
			_videoPlayer.pause();
		}
		public function resume():void
		{
			_videoPlayer.resume();
		}
		public function pageClose():void
		{
			//_videoPlayer.resume();
			
			if (Data.jumpOnPlayComplete == false && Data.hasSubmitByPlayInit && Data.hasSubmitByPageClose == false)
			{
				Submit.submitByteLoaded(_videoPlayer.byteLoaded, _loadingUsedTime);
				Data.hasSubmitByPageClose = true
			}
		}
		
		//播放视频
		public function play(stream:Object,fms:String,startTime:Number=0):void
		{
			_connectStartTime = getTimer();
			alertMsg1 = "正在连接服务器......";
			if (_isNewStartPlay)
			{
				_bufferEmptyStartTime=-1
				Submit.creatUUID();
				Submit.submitOnInit();
				_isNewStartPlay = false;
			}
			if (Data.live)
			{
				_videoPlayer.play(stream,fms,"",0,Data.LIVE_BUFFERTIME,true);
			}
			else
			{
				_videoPlayer.play(stream,fms,_controlBarManager.currentRate,startTime,Data.VOD_BUFFERTIME,false);
				_controlBarManager.setPreviewVideo(Data.fms,Data.previewStream);
			}
			Data.playURL = _videoPlayer.currentVideoURL;
		}
		//设置码率面板
		public function initRate():void
		{
			_controlBarManager.initRate();
		}
		public function onVideoDateLoadError(errMsg:String=null):void
		{
			_controlBarManager.onVideoDateLoadError(errMsg)
		}
		
		//设置提示信息
		public function set alertMsg1(msg:String):void
		{
			_controlBarManager.alertMsg = msg;
		}
	}

}