package data 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Data
	{
		//播放状态
		public static const PLAY:String = "_play";
		public static const PAUSE:String = "_pause";
		public static const COMPLETE:String = "_playComplete";
		public static const UN_PUBLISH:String = "_unPublish";
		public static const CLOSED:String = "_closed";

		public static const VOD_BUFFERTIME:Number = 10*1000;//点播缓冲时间
		public static var LIVE_BUFFERTIME:Number = 3*1000;//直播缓冲时间
		
		public static var videoRatio:Object="";//视频宽高比例
		public static var autoPlay:Boolean = true;//是否自动播放
		public static var autoPlayNext:Boolean = true;//是否自动播放下一集
		
		public static var fms:String;//fms地址
		public static var streams:Object;//流名称
		public static var previewStream:String//预览流名称
		public static var nextVideo:String

		public static var isFullScreen:Boolean = false;//是否是全屏		
		
		//接收页面传来的参数
		public static var uid:String;
		public static var api:String;
		public static var progressBarDraged:Boolean = true;//进度条是否可用
		public static var live:Boolean = false;//是否是直播
		public static var skin:String;//皮肤地址
		
		public static function get canPlayNext():Boolean
		{
			if (Data.autoPlayNext)
			{
				if (Data.nextVideo && Data.nextVideo != "" && Data.nextVideo != "null" && Data.nextVideo != "undefined")
				{
					return true;
				}
			}
			return false
		}
		public static function getData(obj:Stage):void
		{
			/***************** 真实数据 **********************/
			/*var _skin = obj.loaderInfo.parameters.skin;
			var _uid = obj.loaderInfo.parameters.vid;
			var _api = obj.loaderInfo.parameters.api;
			var _progressBarDraged = obj.loaderInfo.parameters.progressBarDraged;
			var _live = obj.loaderInfo.parameters.live;*/

			/***************** 测试数据 **********************/
			/*var _skin ="videoPlayerSkin.swf";
			var _uid = '[{"appid":"88668301940490240","appkey":"88668301940490240","method":"getVideoInfo","param":[{ "VideoId" : "92905205036745986"}]}]';
			var _api = "http://115.28.6.41/VideoControl/library/VideoLibrary.php";
			var _progressBarDraged = "false";
			var _live = "false";*/
			
			var _skin ="videoPlayerSkin.swf";
			var _uid = '12';
			var _api = "http://localhost/vbuplayer/api.asp";
			var _autoPlay="true"
			//var _progressBarDraged = "true";
			//var _live = "false";

		    YaoTrace.add(YaoTrace.ALL, "接收到 skin 值为：" + _skin);
			YaoTrace.add(YaoTrace.ALL, "接收到 vid 值为：" + _uid);
			YaoTrace.add(YaoTrace.ALL, "接收到 api 值为：" + _api);
			YaoTrace.add(YaoTrace.ALL, "接收到 autoPlay 值为：" + _autoPlay);
			//YaoTrace.add(YaoTrace.ALL, "接收到 progressBarDraged 值为：" + _progressBarDraged);
		    //YaoTrace.add(YaoTrace.ALL, "接收到 live 值为：" + _live);
			
			if (_skin != null && _skin != undefined && _skin != "null" && _skin != "undefined" && _skin != "")
			{
				Data.skin = _skin;
			}
			if (_uid != null && _uid != undefined && _uid != "null" && _uid != "undefined")
			{
				Data.uid = _uid;
			}
			if (_api != null && _api != undefined && _api != "null" && _api != "undefined" && _api != "")
			{
				Data.api = _api;
			}
			if (_autoPlay != null && _api != _autoPlay && _autoPlay != "null" && _autoPlay != "undefined" && _autoPlay != "")
			{
				if (_autoPlay == "false")
				{
					Data.autoPlay = false;
				}
			}
			/*if (_live == "true")
			{
				Data.live = true;
			}
			else
			{
				Data.live = false;
			}
			if (_progressBarDraged == "false")
			{
				Data.progressBarDraged = false;
			}
			else
			{
				Data.progressBarDraged = true;
			}*/
		}
		
	}

}