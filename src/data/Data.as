package data 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import json.JSON2;
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
		public static var nextVideo:String = "";
		public static var playURL:String;
		public static var playHtmlPageURL:String;

		public static var isFullScreen:Boolean = false;//是否是全屏		
		
		//接收页面传来的参数
		//public static var uid:String;
		//public static var vid:String;
		//public static var api:String;
		public static var submitURl:String;
		public static var progressBarDraged:Boolean = true;//进度条是否可用
		public static var live:Boolean = false;//是否是直播
		public static var skin:String;//皮肤地址
		
		public static function get canPlayNext():Boolean
		{
			if (Data.autoPlayNext)
			{
				if (Data.nextVideo!="")
				{
					return true;
				}
			}
			return false
		}
		public static function getData(obj:Stage):Boolean
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
			Data.playHtmlPageURL=String(obj.loaderInfo.url)
			//var data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"","streams":[{"type":"0","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"},{"type":"1","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"},{"type":"2","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"},{"type":"3","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"}],"nextStream":""}'
			var data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"rtmp://localhost/vod/","streams":[{"type":"0","stream":"mp4:stream_yulan.f4v"},{"type":"1","stream":"mp4:stream_biaoqing.f4v"},{"type":"2","stream":"mp4:stream_gaoqing.f4v"},{"type":"3","stream":"mp4:stream_chaoqing.f4v"}],"nextStream":""}'
			YaoTrace.add(YaoTrace.ALL, "接收到 data 值为：" + data);
			
			var dataObject:Object = JSON2.decode(data);
			var rezult:Object = CheckData.check(dataObject);
			if (rezult.errorMsg == "")
			{
				Data.skin = dataObject.skin;
				Data.submitURl = dataObject.submitURl;
				if (dataObject.fms == undefined)
				{
					Data.fms = "";
				}
				else
				{
					Data.fms = dataObject.fms;
				}
				Data.streams = dataObject.streams;
				Data.nextVideo = dataObject.nextStream
				if (dataObject.nextVideo != undefined)
				{
					Data.nextVideo = dataObject.nextVideo;
				}

				var n = Data.streams.length;
				for (var i:uint = 0; i < n; i++)
				{
					if (Data.streams[i].type == "0")
					{
						Data.previewStream = String(Data.streams[i].stream);
						break
					}
				}

				if (rezult.errorMsg != "")
				{
					YaoTrace.add(YaoTrace.ERROR, rezult.alertMsg);
				}
			}
			else
			{
				YaoTrace.add(YaoTrace.ERROR, rezult.errorMsg);
				return false
				
			}
			return true
		}
		
	}

}