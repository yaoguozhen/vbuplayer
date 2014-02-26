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
		
		public static var hasSubmitByPageClose:Boolean = false;
		public static var hasSubmitByPlayInit:Boolean = false;
		public static var jumpOnPlayComplete:Boolean = false;
		
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
			Data.playHtmlPageURL = String(obj.loaderInfo.url)
			
			/***************** 真实数据 **********************/
            /*var _data:String = String(obj.loaderInfo.parameters.data);
            _data = decodeURIComponent(_data)
	        var myPattern:RegExp = /'/gi;      
			_data = _data.replace(myPattern, "\"");*/
			/***************** 测试数据 **********************/
			//var _data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"","streams":[{"type":"0","stream":"http://v.cctv.ccgslb.net/flash/mp4video32/TMS/2014/02/16/818281e6b4f745688c375464d873af65_h264818000nero_aac32-11.mp4"},{"type":"1","stream":"http://v.cctv.ccgslb.net/flash/mp4video32/TMS/2014/02/16/818281e6b4f745688c375464d873af65_h264818000nero_aac32-11.mp4"},{"type":"2","stream":"http://v.cctv.ccgslb.net/flash/mp4video32/TMS/2014/02/16/818281e6b4f745688c375464d873af65_h264818000nero_aac32-11.mp4"},{"type":"3","stream":"http://v.cctv.ccgslb.net/flash/mp4video32/TMS/2014/02/16/818281e6b4f745688c375464d873af65_h264818000nero_aac32-11.mp4"}],"nextStream":""}'
			var _data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"","streams":[{"type":"0","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"},{"type":"1","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"},{"type":"2","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"},{"type":"3","stream":"http://flv5.bn.netease.com/videolib3/1401/09/KdCQr7550/SD/KdCQr7550.flv"}],"nextStream":""}'
			//var _data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"","streams":[{"type":"0","stream":"http://vhotlx.video.qq.com/flv/131/30/m0013ny7p4k.p202.1.mp4?vkey=82BECEC879AE06B9D09FF1B8E7A4EB79B26C82C32F5610B4481D4741D693C393&type=mp4"},{"type":"1","stream":"http://vhotlx.video.qq.com/flv/131/30/m0013ny7p4k.p202.1.mp4?vkey=82BECEC879AE06B9D09FF1B8E7A4EB79B26C82C32F5610B4481D4741D693C393&type=mp4"},{"type":"2","stream":"http://vhotlx.video.qq.com/flv/131/30/m0013ny7p4k.p202.1.mp4?vkey=82BECEC879AE06B9D09FF1B8E7A4EB79B26C82C32F5610B4481D4741D693C393&type=mp4"},{"type":"3","stream":"http://vhotlx.video.qq.com/flv/131/30/m0013ny7p4k.p202.1.mp4?vkey=82BECEC879AE06B9D09FF1B8E7A4EB79B26C82C32F5610B4481D4741D693C393&type=mp4"}],"nextStream":""}'
			//var _data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"","streams":[{"type":"0","stream":"http://60.217.224.113/youku/67722D3AA7E43839B1A9056AF2/030008010052FC75FF6017150136FC8AC5FAEB-20A4-62F0-5BA7-A7E68FF615CA.mp4"},{"type":"1","stream":"http://60.217.224.113/youku/67722D3AA7E43839B1A9056AF2/030008010052FC75FF6017150136FC8AC5FAEB-20A4-62F0-5BA7-A7E68FF615CA.mp4"},{"type":"2","stream":"http://60.217.224.113/youku/67722D3AA7E43839B1A9056AF2/030008010052FC75FF6017150136FC8AC5FAEB-20A4-62F0-5BA7-A7E68FF615CA.mp4"},{"type":"3","stream":"http://60.217.224.113/youku/67722D3AA7E43839B1A9056AF2/030008010052FC75FF6017150136FC8AC5FAEB-20A4-62F0-5BA7-A7E68FF615CA.mp4"}],"nextStream":""}'
			//var _data:String='{"skin":"videoPlayerSkin.swf","submitURl":"http://localhost/vbuplayer/submit.asp","fms":"","streams":[{"type":"0","stream":"http://vliveachy.tc.qq.com/vkp.tc.qq.com/x0011iru47w.p202.1.mp4?sdtfrom=v1000&type=mp4&vkey=00D1A7E02FEAFB072548CD9E21D77B67D0AC42B79E81E61823201F7D9B048D6E942B3951A7AC40A8&level=3&platform=1&br=72&fmt=hd&sp=0&ocid=3373932460"},{"type":"1","stream":"http://vliveachy.tc.qq.com/vkp.tc.qq.com/x0011iru47w.p202.1.mp4?sdtfrom=v1000&type=mp4&vkey=00D1A7E02FEAFB072548CD9E21D77B67D0AC42B79E81E61823201F7D9B048D6E942B3951A7AC40A8&level=3&platform=1&br=72&fmt=hd&sp=0&ocid=3373932460"},{"type":"2","stream":"http://vliveachy.tc.qq.com/vkp.tc.qq.com/x0011iru47w.p202.1.mp4?sdtfrom=v1000&type=mp4&vkey=00D1A7E02FEAFB072548CD9E21D77B67D0AC42B79E81E61823201F7D9B048D6E942B3951A7AC40A8&level=3&platform=1&br=72&fmt=hd&sp=0&ocid=3373932460"},{"type":"3","stream":"http://vliveachy.tc.qq.com/vkp.tc.qq.com/x0011iru47w.p202.1.mp4?sdtfrom=v1000&type=mp4&vkey=00D1A7E02FEAFB072548CD9E21D77B67D0AC42B79E81E61823201F7D9B048D6E942B3951A7AC40A8&level=3&platform=1&br=72&fmt=hd&sp=0&ocid=3373932460"}],"nextStream":""}'
			
			YaoTrace.add(YaoTrace.ALL, "接收到 data 值为：" + _data);
			
			if (_data == "undefined"||_data == "")
			{
				YaoTrace.add(YaoTrace.ERROR, "接受到的值非法");
				return false;
			}
            
			var dataObject:Object = JSON2.decode(_data);
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