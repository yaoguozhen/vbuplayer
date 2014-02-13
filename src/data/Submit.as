package data 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Submit 
	{
		private static var uuid:String
		private static function removeListener(target):void
		{
			target.removeEventListener(Event.COMPLETE, loadComHandler);
			target.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
		}
		private static function loadComHandler(evn:Event):void
		{
			removeListener(evn.target)
		}
		private static function loadErrHandler(evn:IOErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "提交信息出错，错误信息：" + evn.text);
			removeListener(evn.target)
		}
		private static function securityHandler(evn:SecurityErrorEvent):void
		{			
			YaoTrace.add(YaoTrace.ERROR, "提交信息出错。跨域问题,请检查crossdomain.xml。错误信息:"+evn.text);
			removeListener(evn.target)
		}
		private static function submit(urlVar:URLVariables):void
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.data = urlVar;
			urlRequest.method =  URLRequestMethod.POST;
			urlRequest.url = Data.submitURl + "?random=" + String(Math.random());
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, loadComHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			urlLoader.load(urlRequest);
		}
		public static function creatUUID():void
		{
			uuid = MD5.hash(String(getTimer()) + String(Math.random()) + String(Math.random()) + getDisTime());
		}
		private static function getDisTime():String
		{
			var d:Date = new Date();
			return String(d.time)
		}
		private static function addToYaoTrace(urlVar:URLVariables):void
		{
			var msg:String = "";
			for (var key in urlVar)
			{
				msg+=key+":"+urlVar[key]+","
			}
			YaoTrace.add(YaoTrace.ALL, "提交信息:"+msg);
		}
		public static function submitOnInit():void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "play_init";
			urlVar.uuid = uuid
			urlVar.playurl = encodeURI(Data.playHtmlPageURL)
			
			urlVar.playtime = getDisTime()
			
			addToYaoTrace(urlVar)
			submit(urlVar)
			
			Data.hasSubmitByPlayInit = true;
		}
		public static function submitBufferTimeByDrag(time:Number):void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "play_drag";
			urlVar.uuid = uuid;
			urlVar.playurl = encodeURI(Data.playURL);
			
			urlVar.dbuffertime = String(time);
			
			addToYaoTrace(urlVar)
			submit(urlVar)
		}
		public static function submitBufferTimeNotByDrag(time:Number):void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "play_buffer";
			urlVar.uuid = uuid
			urlVar.playurl = encodeURI(Data.playURL)
			
			urlVar.buffertime = String(time);
			
			addToYaoTrace(urlVar)
			submit(urlVar)
		}
		/**
		* 1 视频信息不正确
		* 2 连接服务器失败
		* 3 某个码率的视频播放没有找到
		* 4 某个码率的视频由于列表之外的原因播放失败
		* 5 皮肤文件加载失败
		**/
		public static function submitOnPlayFailed(errorCode:String):void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "play_fail";
			urlVar.uuid = uuid
			urlVar.playurl = encodeURI(Data.playURL)
			
			urlVar.errorcode = errorCode
			
			addToYaoTrace(urlVar)
			submit(urlVar)
		}
		public static function submitByteLoaded(datasize:uint, datatime:uint):void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "play_finish";
			urlVar.uuid = uuid
			urlVar.playurl = encodeURI(Data.playURL)
			
			urlVar.datasize = datasize
			urlVar.datatime = datatime
			
			addToYaoTrace(urlVar)
			submit(urlVar)
		}
		public static function submitOnFirstPlayStart(pretime:Number,fbuffertime:Number,bitrate:Number,resolution:String,duration:Number,videoformat:String,audioformat:String):void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "play_start";
			urlVar.uuid = uuid
			urlVar.playurl = encodeURI(Data.playURL)
			
			urlVar.pretime = pretime;//最终播放URL获取耗时，单位毫秒
			urlVar.fbuffertime = fbuffertime;//获取最终URL后到开始播放的耗时，单位毫秒
			urlVar.bitrate = bitrate;//视频码率。单位(kbit per second)
			urlVar.resolution = resolution;//视频分辨率。视频的长宽，中间用-分隔，例如1024-768
			urlVar.duration = duration;//总时长。单位秒
			urlVar.videoformat = videoformat;//视频编码
			urlVar.audioformat = audioformat;//音频编码
			
			addToYaoTrace(urlVar)
			submit(urlVar)
		}
	}

}