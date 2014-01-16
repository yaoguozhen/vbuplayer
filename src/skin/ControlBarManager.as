package skin 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.system.Capabilities;
	import com.greensock.*;
	import com.greensock.easing.*;
	import data.Data;
	import skin.events.ChangeLightEvent;
	import skin.events.ProgressChangeEvent;
	import skin.events.RateEvent;
	import skin.events.VideoAreaRateEvent;
	import skin.events.VolChangeEvent;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class ControlBarManager extends EventDispatcher 
	{
		private var _controlBar:MovieClip;
		private var _progressBar:YaoSlider;
		private var _volBar:YaoSlider;
		private var _brightnessBar:YaoSlider;//亮度
		private var _contrastBar:YaoSlider;//对比度
		private var _hideControlBarTime:Timer;
		private var _videoPreview:VideoPreview;
		
		private var _isShow:Boolean = true;
		private var _stage:Stage;
		private var _screenClickHot:Sprite;
		private var _bigPlayBtn:MovieClip;
		private var _buffering:MovieClip;
		private var _alertMsg:MovieClip;
		private var _adMsg:MovieClip;
		private var _bg:MovieClip;
		private var _ratePanel:MovieClip;
		private var _settingPanel:MovieClip;
		private var _preview:MovieClip;
		private var _alertMsgBg:MovieClip;

		private var _currentRate:String="1";
		
		private var _volNumBeforeClear:Number;
		
		private var _isFullScreen:Boolean = false;
		public var bigPlayBtnType:String=""//resume 被当做恢复播放按钮。connect被当做开始连接按钮
		
		public function ControlBarManager() :void
		{
			
		}
		private function initTimer():void
		{
			_hideControlBarTime = new Timer(3000, 1);
			_hideControlBarTime.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		private function timerHandler(evn:TimerEvent):void
		{
			if (_isShow)
			{
				hide();
			}
		}
		private function init(s:Skin):void
		{
			_screenClickHot = s.screenClickHot;
			_bigPlayBtn = s.bigPlayBtn;
			_buffering = s.buffering;
			_bg = s.bg;
			_alertMsgBg = s.alertMsgBg;
			_ratePanel = s.ratePanel;
			_settingPanel = s.settingPanel;
			_preview = s.preview;
			_alertMsg = s.alertMsg;
			_adMsg = s.adMsg;
			_controlBar = s.controlBar;
			_stage = _controlBar.stage;
			
			_adMsg.txt.autoSize = "left";
			
			_controlBar.playBtn.visible = true;
			_controlBar.playBtn.buttonMode = true;
			_controlBar.pauseBtn.visible = false;
			_controlBar.pauseBtn.buttonMode = true;
			_controlBar.settingBtn.buttonMode = true;
			_controlBar.fullscreenBtn.stop();
			_controlBar.fullscreenBtn.buttonMode = true;
			_bg.visible=false
			
			_controlBar.progressBar.followBar.width = 0;
			_controlBar.progressBar.loadingBar.width = 0;
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler123);
			
			_controlBar.volBtn.stop();
			_controlBar.volBtn.buttonMode = true;
			_controlBar.volBtn.addEventListener(MouseEvent.CLICK, volBtnClickHandler);
			
			_volBar = new YaoSlider();
			_volBar.init(_controlBar.volBar, 0, 1, true, true);
			_volBar.currentPercent = 1;
			_volBar.addEventListener(YaoSlider.CHANGE, volBarChangeHandler);
			//_volBar.addEventListener(YaoSlider.BLOCK_RELEASED, volBarReleasedHandler);
			
			_controlBar.fullscreenBtn.addEventListener(MouseEvent.CLICK, fullscreenBtnClickHandler);
			_controlBar.settingBtn.addEventListener(MouseEvent.CLICK, settingBtnClickHandler);
			_controlBar.playBtn.addEventListener(MouseEvent.CLICK, playBtnClickHandler);
			_controlBar.pauseBtn.addEventListener(MouseEvent.CLICK, pauseBtnClickHandler);
			
			
			_controlBar.progressBar.loadingBar.width = 0;
			_controlBar.progressBar.followBar.width = 0;
			
			_preview.visible = false;
			
			_progressBar = new YaoSlider();
			_progressBar.init(_controlBar.progressBar, 0, 1, false, true);
			_progressBar.active = -1;
			playPer = 0;
			_videoPreview = new VideoPreview()
			_videoPreview.init(_preview,_controlBar.progressBar.path)
			
			_progressBar.addEventListener(YaoSlider.CHANGE, progressBarChangeHandler);
			_progressBar.addEventListener(YaoSlider.BLOCK_PRESSED, progressBarPressedHandler);
			_progressBar.addEventListener(YaoSlider.BLOCK_RELEASED, progressBarReleasedHandler);
			//_progressBar.addEventListener(YaoSlider.PASS_CLICKED, passClickedHandler);
			
			_screenClickHot.addEventListener(MouseEvent.CLICK, screenClickHotClickHandler);
			_screenClickHot.addEventListener(MouseEvent.DOUBLE_CLICK, screenClickHotDoubleClickHandler);
			
			_ratePanel.visible = false;
			activeRatePanelItem(_ratePanel.btn1, false);
			activeRatePanelItem(_ratePanel.btn2, false);
			activeRatePanelItem(_ratePanel.btn3, false);
			
			_settingPanel.visible = false;
			initSettingPanel()
			
			_ratePanel.btn1.value = "1"
			_ratePanel.btn2.value = "2"
			_ratePanel.btn3.value = "3"
			
			if (Data.live)
			{
				_controlBar.rateBtn.visible = false;
				_controlBar.playBtn.visible = false;
				_controlBar.pauseBtn.visible = false;
				_screenClickHot.visible = false;
			}
			else
			{
				_controlBar.rateBtn.rate.text = "标准";
				_controlBar.rateBtn.mouseChildren = false;
				rateBtnEnabled = false;
			}
			
			if (Data.live)
			{
				_bigPlayBtn.visible = false;
				bigPlayBtnType = "resume";
			}
			else
			{
				if (Data.autoPlay)
				{
					_bigPlayBtn.visible = false;
					bigPlayBtnType = "resume";
				}
				else
				{
					bigPlayBtnType = "connect";
				}
			}
			_bigPlayBtn.buttonMode = true;
			_bigPlayBtn.addEventListener(MouseEvent.CLICK, bigPlayBtnClickHandler);
			
			_buffering.visible = false;
			
			if (Data.live)
			{
				_controlBar.progressBar.visible = false;
				_controlBar.time.visible = false;
			}

			recordInitNumber();
		}
		private function initSettingPanel():void
		{
			_settingPanel.rate0.gotoAndStop(2)
			_settingPanel.rate43.stop()
			_settingPanel.rate169.stop()
			_settingPanel.rate0.buttonMode = true;
			_settingPanel.rate43.buttonMode = true;
			_settingPanel.rate169.buttonMode = true;
			_settingPanel.rate0.value = "0"
			_settingPanel.rate43.value = "43"
			_settingPanel.rate169.value = "169"
			_settingPanel.rate0.addEventListener(MouseEvent.CLICK,settingPanelRateBtnClickHandler)
			_settingPanel.rate43.addEventListener(MouseEvent.CLICK,settingPanelRateBtnClickHandler)
			_settingPanel.rate169.addEventListener(MouseEvent.CLICK, settingPanelRateBtnClickHandler)
			_settingPanel.closeBtn.addEventListener(MouseEvent.CLICK, settingPanelCloseBtnClickHandler)
			
			_brightnessBar = new YaoSlider()
			_brightnessBar.init(_settingPanel.brightnessBar)
			_brightnessBar.currentPercent = 0.5
			_brightnessBar.addEventListener(YaoSlider.CHANGE, brightnessChangeHandler);
			_contrastBar = new YaoSlider()
			_contrastBar.init(_settingPanel.contrastBar)
			_contrastBar.currentPercent = 0.75
			_contrastBar.addEventListener(YaoSlider.CHANGE, contrastChangeHandler);
			
			_settingPanel.currentRateBtn = _settingPanel.rate0;
		}
		private function brightnessChangeHandler(evn:Event):void
		{
			var event:ChangeLightEvent = new ChangeLightEvent(ChangeLightEvent.CHANGE);
			event.changeType = "brightness"
			event.value=_brightnessBar.currentPercent*510-255
			dispatchEvent(event)
		}
		private function contrastChangeHandler(evn:Event):void
		{
			var event:ChangeLightEvent = new ChangeLightEvent(ChangeLightEvent.CHANGE);
			event.changeType = "contrast"
			event.value=_contrastBar.currentPercent*510-255
			dispatchEvent(event)
		}
		private function settingPanelRateBtnClickHandler(evn:MouseEvent ):void
		{
			if (evn.currentTarget != _settingPanel.currentRate)
			{
				if (_settingPanel.currentRateBtn)
				{
					_settingPanel.currentRateBtn.gotoAndStop(1)
				}
				
				_settingPanel.currentRateBtn = evn.currentTarget
			    _settingPanel.currentRateBtn.gotoAndStop(2)
			
				var event:VideoAreaRateEvent = new VideoAreaRateEvent(VideoAreaRateEvent.RATE_CHANGE);
				event.rate = _settingPanel.currentRateBtn.value;
				dispatchEvent(event)
			}
		}
		private function settingPanelCloseBtnClickHandler(evn:MouseEvent):void
		{
			_settingPanel.visible=!_settingPanel.visible
		}
		private function recordInitNumber():void
		{
			record(_controlBar.controlBarBg);
			record(_controlBar.playBtn);
			record(_controlBar.pauseBtn);
			record(_controlBar.fullscreenBtn);
			record(_controlBar.settingBtn);
			record(_controlBar.volBtn);
			record(_controlBar.volBar);
			record(_controlBar.time);
			record(_controlBar.progressBar);
			record(_controlBar.rateBtn);
			record(_ratePanel);
		}
		private function record(mc:MovieClip):void
		{
			mc.initX = mc.x;
			mc.initY = mc.y;
			mc.disRight = _controlBar.width - mc.x;
		}
		private function rateBtnClickHandler(evn:MouseEvent):void
		{
			_ratePanel.visible = !_ratePanel.visible
			if (_settingPanel.visible)
			{
				_settingPanel.visible=false
			}
		}
		private function stageMouseMoveHandler123(evn:MouseEvent):void
		{
			if (_isFullScreen)
			{
				_hideControlBarTime.reset();
				_hideControlBarTime.start();
				if (!_isShow)
				{
					show();
				}
			}
		}
		private function playBtnClickHandler(evn:MouseEvent):void
		{
			dispatchEvent(new Event("playBtnClick"));
		}
		private function pauseBtnClickHandler(evn:MouseEvent):void
		{
			dispatchEvent(new Event("pauseBtnClick"));
		}
		private function fullscreenBtnClickHandler(evn:MouseEvent):void
		{
			dispatchEvent(new Event("fullscreenBtnClick"));
		}
		private function settingBtnClickHandler(evn:MouseEvent ):void
		{
			_settingPanel.visible = !_settingPanel.visible
			if (_ratePanel.visible)
			{
				_ratePanel.visible = false;
			}
		}
		private function progressBarChangeHandler(evn:Event):void
		{
			trace("xxxxxx:"+playPer)
			var event:ProgressChangeEvent = new ProgressChangeEvent(ProgressChangeEvent.CHANGE);
			event.per = playPer;
			dispatchEvent(event);
		}
		private function progressBarPressedHandler(evn:Event):void
		{
			_videoPreview.active = false;
			dispatchEvent(new Event("progressBarBlockPressed"))
		}
		private function progressBarReleasedHandler(evn:Event):void
		{
			_videoPreview.active = true;
			dispatchEvent(new Event("progressBarBlockReleased"))
		}
		private function screenClickHotClickHandler(evn:Event):void
		{
			dispatchEvent(new Event("screenClickHotClick"));
		}
		private function screenClickHotDoubleClickHandler(evn:Event):void
		{
			//dispatchEvent(new Event("screenClickHotDoubleClick"));
		}
		private function bigPlayBtnClickHandler(evn:Event)
		{
			_bigPlayBtn.visible = false;
			dispatchEvent(new Event("bigPlayBtnClick"));
		}
		private function passClickedHandler(evn:Event):void
		{
			dispatchEvent(new Event("passClicked"))
		}
		private function pathClickHandler(evn:MouseEvent):void
		{
			if ((_controlBar.progressBar.path.mouseX / _controlBar.progressBar.width) < _controlBar.progressBar.loadingBar.scaleX)
			{
				playPer = _controlBar.progressBar.path.mouseX / _controlBar.progressBar.width;
				
				dispatchEvent(new Event("progressBarChange"));
			}
		}
		private function volBtnClickHandler(evn:MouseEvent):void
		{
			if (_controlBar.volBtn.currentFrame == 1)
			{
				_volNumBeforeClear = _volBar.currentPercent;
				
				_controlBar.volBtn.gotoAndStop(2);
				_volBar.currentPercent = 0;
				
				var event:VolChangeEvent = new VolChangeEvent(VolChangeEvent.CHANGE);
				event.vol = _volBar.currentPercent;
				dispatchEvent(event);
			}
			else
			{
				_controlBar.volBtn.gotoAndStop(1);
				_volBar.currentPercent = _volNumBeforeClear;
				
				var event:VolChangeEvent = new VolChangeEvent(VolChangeEvent.CHANGE);
				event.vol = _volBar.currentPercent;
				dispatchEvent(event);
			}
		}
		private function volBarChangeHandler(evn:Event):void
		{
			_controlBar.volBtn.gotoAndStop(1);
			
			var event:VolChangeEvent = new VolChangeEvent(VolChangeEvent.CHANGE);
			event.vol = _volBar.currentPercent;
			dispatchEvent(event);
		}
		private function show(immediately:Boolean=false):void
		{
				_isShow = true;
				TweenLite.killTweensOf(_controlBar);
				var targetPosition:Number = _stage.stageHeight - _controlBar.height;
				if (immediately)
				{
					_controlBar.y =targetPosition;
				}
				else
				{
					TweenLite.to(_controlBar, 0.5, { y:targetPosition, ease:Circ.easeOut } );
				}
		}
		private function hide(immediately:Boolean=false):void
		{
			_isShow = false;
			TweenLite.killTweensOf(_controlBar);
			var targetPosition:Number = _stage.stageHeight;
			if (immediately)
			{
				_controlBar.y = targetPosition;
			}
			else
			{
				TweenLite.to(_controlBar, 0.5, { y:targetPosition, ease:Circ.easeOut } );
			}
		}
		private function activeRatePanelItem(item:MovieClip,b:Boolean):void
		{
			item.rate.mouseEnabled = false;
			if (b)
			{
				item.rate.textColor = 0xffffff;
				item.btn.visible = true;
				item.addEventListener(MouseEvent.CLICK, itemClickHandler);
			}
			else
			{
				item.rate.textColor = 0x999999;
				item.btn.visible = false;
				item.removeEventListener(MouseEvent.CLICK, itemClickHandler);
			}
		}
		private function itemClickHandler(evn:MouseEvent):void
		{
			var item:MovieClip = MovieClip(evn.currentTarget);
			if (_currentRate != item.value)
			{
				_currentRate = item.value;
				_controlBar.rateBtn.rate.text = item.rate.text;

				var event:RateEvent = new RateEvent(RateEvent.RATE_CHANGE);
				event.rate = _currentRate;
				dispatchEvent(event);
			}
			_ratePanel.visible = false;
		}
		private function _setVideoStatus(status:String):void
		{
			switch(status)
			{
				case Data.PLAY:
					if (!Data.live)
					{
						_controlBar.playBtn.visible = false;
						_controlBar.pauseBtn.visible = true;
						_bigPlayBtn.visible = false;
					}
					break;
				case Data.PAUSE:
					if (!Data.live)
					{
						_controlBar.playBtn.visible = true;
						_controlBar.pauseBtn.visible = false;
						_bigPlayBtn.visible = true;
					}
					break;
				case Data.COMPLETE:
				case Data.UN_PUBLISH:
				case Data.CLOSED:
					if (!Data.live)
					{
						_controlBar.playBtn.visible = true;
						_controlBar.pauseBtn.visible = false;
					}
					if (Data.canPlayNext)
					{
						_bigPlayBtn.visible = false;
					}
					else 
					{
						_bigPlayBtn.visible = true;
					}
					break;
			}
		}
		private function _initRate():void
		{
			var n:uint = Data.streams.length;
			for (var i:uint = 0; i < n; i++)
			{
				switch(String(Data.streams[i].type))
				{
					case "1":
						activeRatePanelItem(_ratePanel.btn1,true);
						break;
					case "2":
						activeRatePanelItem(_ratePanel.btn2,true);
						break;
					case "3":
						activeRatePanelItem(_ratePanel.btn3,true);
						break;
				}
			}
		}
		private function _setCurrentRate(rate:String):void
		{
			switch(rate)
			{
				case "1":
					_controlBar.rateBtn.rate.text = "标清";
					break;
				case "2":
					_controlBar.rateBtn.rate.text = "高清";
					break;
				case "3":
					_controlBar.rateBtn.rate.text = "超清";
					break;
			}
			_currentRate = rate;
		}
		private function _scale():void
		{
			_controlBar.y = _stage.stageHeight - _controlBar.height;
			//控制条背景,右侧总是差一个像素对不起，不知道为什么，所以这里就多加了一个像素
			_controlBar.controlBarBg.width = _stage.stageWidth+1;
			_controlBar.volBtn.x = _controlBar.controlBarBg.width - _controlBar.volBtn.disRight;
			_controlBar.volBar.x = _controlBar.controlBarBg.width - _controlBar.volBar.disRight;
			_controlBar.fullscreenBtn.x = _controlBar.controlBarBg.width - _controlBar.fullscreenBtn.disRight;			
			_controlBar.settingBtn.x = _controlBar.controlBarBg.width - _controlBar.settingBtn.disRight;
			
			_screenClickHot.width = _controlBar.controlBarBg.width;
			_screenClickHot.height = _stage.stageHeight - _controlBar.controlBarBg.height;
			_bigPlayBtn.x = (_stage.stageWidth-_bigPlayBtn.width) / 2;
			_bigPlayBtn.y = (_stage.stageHeight-_bigPlayBtn.height) / 2;
			_buffering.x = _stage.stageWidth / 2;
			_buffering.y = _stage.stageHeight / 2;
			
			_bg.x = 0;
			_bg.y = 0;
			_bg.width = _stage.stageWidth;
			_bg.height = _stage.stageHeight - _controlBar.controlBarBg.height;
			_controlBar.rateBtn.x = _controlBar.controlBarBg.width - _controlBar.rateBtn.disRight;
			
			_controlBar.progressBar.progressBarBg2.width = _controlBar.volBtn.x - _controlBar.progressBar.x - 10;
			_controlBar.progressBar.progressBarBg.width = _controlBar.progressBar.progressBarBg2.width-10;
			/*
			    下面如果直接写
			        path.width=XXXXXXXX
				则
				    path.mouseX属性不准确
			*/
			_controlBar.progressBar.path.getChildAt(0).width = _controlBar.progressBar.progressBarBg.width;

			_ratePanel.x = _stage.stageWidth - _ratePanel.disRight;
			_ratePanel.y = _controlBar.y - _ratePanel.height;
			
			_settingPanel.x = _stage.stageWidth - _settingPanel.width-5;
			_settingPanel.y = _controlBar.y - _settingPanel.height-5;
			
			_adMsg.x = (_stage.stageWidth - _adMsg.width) / 2;
			_adMsg.y = 10;
			
			_alertMsgBg.x = 0;
			_alertMsgBg.y = _controlBar.y - _alertMsgBg.height;
			_alertMsgBg.width = _stage.stageWidth;
			_alertMsg.x = 10;
			_alertMsg.y = _stage.stageHeight - _controlBar.controlBarBg.height - _alertMsg.height - 3;
		}
		private function _setTime(currentTime:Number, totalTime:Number):void
		{
			_controlBar.time.txt.text = MyDate.getFormatTime(totalTime, true) + " / " +MyDate.getFormatTime(currentTime, true) ;
		    if (totalTime > 0)
			{
				playPer = currentTime / totalTime;
			}
		}
		private function _unActiveRatePanelItem(rate:String):void
		{
			switch(rate)
			{
				case "1":
					activeRatePanelItem(_ratePanel.btn1, false);
					break;
				case "2":
					activeRatePanelItem(_ratePanel.btn2, false);
					break;
				case "3":
					activeRatePanelItem(_ratePanel.btn3, false);
					break;
			}
		}
		public function onVideoDateLoadError(errMsg:String=null):void
		{
			alertMsg = errMsg;
			_bigPlayBtn.visible = false
			playBtnEnabled=false
		}
		public function add(skin:Skin):void
		{
			initTimer();
			init(skin);
		}
		//设置时间信息
		public function setTime(currentTime:Number,totalTime:Number):void
		{
			_setTime(currentTime, totalTime);
		}
		//设置缓冲
		public function setBuffering(show:Boolean,msg:String=""):void
		{
			_buffering.label.text = msg;
			_buffering.visible = show;
		}
		//初始化码率按钮
		public function initRate():void
		{
			_initRate();
		}
		//动态调整元件
		public function scale():void
		{
			_scale();
		}
		//设置当前码率
		public function setCurrentRate(rate:String):void
		{
			_setCurrentRate(rate);
		}
		//隐藏码率面板
		public function hideRatePanel():void
		{
			_ratePanel.visible = false;
		}
		//禁用码率面板按钮
		public function unActiveRatePanelItem(rate:String):void
		{
			_unActiveRatePanelItem(rate);
		}
		public function setPreviewVideo(fms:String, stream:String):void
		{
			_videoPreview.setVideo(fms, stream);
		}
		//是否全屏
		public function get isFullScreen():Boolean
		{
			return _isFullScreen;
		}
	    public function set isFullScreen(b:Boolean):void
		{
			_isFullScreen = b;
			if (b)
			{
				TweenLite.killTweensOf(_controlBar);
				_hideControlBarTime.start();
				_controlBar.fullscreenBtn.gotoAndStop(2);
			}
			else
			{
				TweenLite.killTweensOf(_controlBar);
				_hideControlBarTime.reset();
				show(true);
				_controlBar.fullscreenBtn.gotoAndStop(1);
			}
		}
		//设置播放按钮是否可用
		public function set playBtnEnabled(b:Boolean):void
		{
			if (b)
			{
				_controlBar.playBtn.addEventListener(MouseEvent.CLICK, playBtnClickHandler);
			}
			else
			{
				_controlBar.playBtn.removeEventListener(MouseEvent.CLICK, playBtnClickHandler);
			}
				
			_controlBar.playBtn.buttonMode = b;
		}
		//是否激活进度条
		public function set progressBarActive(n:Number):void
		{
			_progressBar.active = n;
		}
		//设置播放状态
		public function set setVideoStatus(status:String):void
		{
			_setVideoStatus(status);
		}
		//设置下载进度
		public function set loadPer(n:Number):void
		{
			_controlBar.progressBar.loadingBar.width = _controlBar.progressBar.progressBarBg.width*n;
		}
		//设置播放进度
		public function set playPer(n:Number):void
		{
			_progressBar.currentPercent = n;
		}
		//进度条当前值
		public function get playPer():Number
		{
			return _progressBar.currentPercent;
		}
		//进度条滑块是不是被按下了
		public function get progressBarBlockPressed():Boolean
		{
			return _progressBar.blockPressed;
		}
		//警告信息
		public function set alertMsg(msg:String):void
		{
			_alertMsg.txt.text = msg;
			if (msg == "")
			{
				_alertMsgBg.visible = false;
			}
			else
			{
				_alertMsgBg.visible = true;
			}
		}
		public function set adMsg(msg:String):void
		{
			_adMsg.txt.text = msg;
			_adMsg.x = (_stage.stageWidth - _adMsg.width) / 2;
		}
		//当前码率
		public function get currentRate():String
		{
			return _currentRate;
		}
		public function set previewVideo(b:Boolean):void
		{
			_videoPreview.active = b;
		}
		//切换码率按钮是否可用
		public function set rateBtnEnabled(b:Boolean):void
		{
			_controlBar.rateBtn.buttonMode = b;
			if (b)
			{
				_controlBar.rateBtn.addEventListener(MouseEvent.CLICK, rateBtnClickHandler);
				_controlBar.rateBtn.rate.textColor = 0x4a4a4a;
			}
			else
			{
				_controlBar.rateBtn.removeEventListener(MouseEvent.CLICK, rateBtnClickHandler);
				_ratePanel.visible = false;
				_controlBar.rateBtn.rate.textColor = 0xcccccc;
			}
		}
	}

}