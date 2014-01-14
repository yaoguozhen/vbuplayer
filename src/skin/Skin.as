package skin 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Skin extends EventDispatcher
	{
		private var _loader:Loader;
		private var _missComponent:String = "";
		private var _content:MovieClip;
		private var _controlBar:MovieClip;
		private var _screenClickHot:Sprite;
		private var _bigPlayBtn:MovieClip;
		private var _buffering:MovieClip;
		private var _alertMsg:MovieClip;
		private var _bg:MovieClip;
		private var _adMsg:MovieClip;
		private var _ratePanel:MovieClip;
		private var _settingPanel:MovieClip;
		private var _preview:MovieClip;
		private var _alertMsgBg:MovieClip
		
		public function Skin() :void
		{			
			initLoader();
			creatScreenClickHot();
		}
		private function initLoader():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
		}
		/**
		 * 加载完毕
		 * @param	evn
		 */
		private function loadComHandler(evn:Event):void
		{
			YaoTrace.add(YaoTrace.ALL, "皮肤文件加载完毕");
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
			
			_content = MovieClip(_loader.content);
			_controlBar = _content.controlBar;
			_bigPlayBtn = _content.bigPlayBtn;
			_buffering = _content.buffering;
			_alertMsg = _content.alertMsg;
			_adMsg = _content.adMsg;
			_bg = _content.bg;
			_alertMsgBg = _content.alertMsgBg;
			_ratePanel = _content.ratePanel;
			_settingPanel = _content.settingPanel;
			_preview = _content.preview;

			_missComponent = SkinChecker.check(_content);

			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function securityErrHandler(evn:SecurityErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "跨域加载皮肤文件出错，错误信息："+evn.text);
		}
		/**
		 * 加载失败
		 * @param	evn
		 */
		private function loadErrorHandler(evn:IOErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "皮肤文件加载出错，错误信息："+evn.text);
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
			
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		private function creatScreenClickHot():void
		{
			_screenClickHot = new Sprite();
			_screenClickHot.graphics.beginFill(0x0000ff, 0);
			_screenClickHot.graphics.drawRect(0, 0, 100, 100);
			_screenClickHot.doubleClickEnabled = true;
		}
		//加载皮肤
		public function load(skinURL:String):void
		{
			YaoTrace.add(YaoTrace.ALL, "开始加载皮肤文件:" + skinURL);
			_loader.load(new URLRequest(skinURL),new LoaderContext(true));
		}
		//缺少元件信息
		public function get missComponent():String
		{
			return _missComponent;
		}
		//控制条
		public function get controlBar():MovieClip
		{
			return _controlBar;
		}
		//屏幕点击热区
		public function get screenClickHot():Sprite
		{
			return _screenClickHot;
		}
		//大播放按钮
		public function get bigPlayBtn():MovieClip
		{
			return _bigPlayBtn;
		}
		//警告框
		public function get alertMsg():MovieClip
		{
			return _alertMsg;
		}
		public function get adMsg():MovieClip
		{
			return _adMsg;
		}
		//缓冲动画
		public function get buffering():MovieClip
		{
			return _buffering;
		}
		//视频背景
		public function get bg():MovieClip
		{
			return _bg;
		}
		//切换码率面板
		public function get ratePanel():MovieClip
		{
			return _ratePanel;
		}
		//切换码率面板
		public function get settingPanel():MovieClip
		{
			return _settingPanel;
		}
		public function get preview():MovieClip
		{
			return _preview;
		}
		//警告框背景
		public function get alertMsgBg():MovieClip
		{
			return _alertMsgBg;
		}
	}

}