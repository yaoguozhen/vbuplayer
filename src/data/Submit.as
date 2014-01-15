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
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Submit 
	{
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
		private static function getUUID(uid:String,vid:String):String
		{
			return MD5.hash(uid+vid+getDisTime())
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
		public static function submitOnInit(uid:String,vid:String,playUrl:String):void
		{
			var urlVar:URLVariables = new URLVariables()
			urlVar.type = "playinit";
			urlVar.uuid = getUUID(uid, vid)
			urlVar.playtime = getDisTime()
			urlVar.playurl = playUrl
			
			addToYaoTrace(urlVar)
			submit(urlVar)
		}
	}

}