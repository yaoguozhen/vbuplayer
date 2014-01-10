package
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class AlertManager
	{
		[Embed(source="alert.swf",mimeType="application/octet-stream")]
		private static var AlertClass:Class;
		private static var _alert:MovieClip;
		private static var _stage:Stage;
		private static var _bg:Sprite;
		private static var _quitFun:Function;
		
		public function QuitAlertManager():void
		{
			
		}
		private static function getAlert():void
		{
			var lcoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			lcoaderContext.allowCodeImport=true;
			
			var loader:Loader=new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComHandler);
			loader.loadBytes(new AlertClass(),lcoaderContext);
		}
		private static function loadComHandler(evn:Event):void
		{
			_alert=MovieClip(evn.target.content);
			
			_alert.hot.addEventListener(MouseEvent.MOUSE_DOWN,hotMouseDownHandler);
			
			_alert.okBtn.buttonMode=true;
			_alert.canelBtn.buttonMode=true;
			_alert.okBtn.addEventListener(MouseEvent.CLICK,okBtnClickHandler);
			_alert.canelBtn.addEventListener(MouseEvent.CLICK,canelBtnClickHandler);
		}
		private static function okBtnClickHandler(evn:MouseEvent):void
		{
			_quitFun();
			hideAlert();
		}
		private static function canelBtnClickHandler(evn:MouseEvent):void
		{
			hideAlert();
		}
		private static function hideAlert():void
		{
			_stage.removeChild(_bg);
			_stage.removeChild(_alert);
		}
		private static function hotMouseDownHandler(evn:MouseEvent):void
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE,hotMouseMoveHandler);
			_stage.addEventListener(MouseEvent.MOUSE_UP,hotMouseUpHandler);
			_alert.startDrag(false,new Rectangle(0,0,_stage.stageWidth-_alert.width,_stage.stageHeight-_alert.height));
		}
		private static function hotMouseMoveHandler(evn:MouseEvent):void
		{
			evn.updateAfterEvent();
		}
		private static function hotMouseUpHandler(evn:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE,hotMouseMoveHandler);
			_stage.removeEventListener(MouseEvent.MOUSE_UP,hotMouseUpHandler);
			_alert.stopDrag();
		}
		
		private static function creatBg():void
		{
			_bg=new Sprite()
			_bg.graphics.beginFill(0xffffff,0.7);
			_bg.graphics.drawRect(0,0,100,100);
		}
		
		public static function init(obj:Stage,quitFun:Function):void
		{
			_stage=obj;
			_quitFun=quitFun;
			getAlert();
			creatBg();
		}
		public static function show():void
		{
			_alert.x=(_stage.stageWidth-_alert.width)/2;
			_alert.y=(_stage.stageHeight-_alert.height)/2;
			
			_bg.width=_stage.stageWidth;
			_bg.height=_stage.stageHeight;
			
			_stage.addChild(_bg);
			_stage.addChild(_alert);
		}
		
	}
}