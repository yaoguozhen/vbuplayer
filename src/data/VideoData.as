package data 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import json.JSON;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class VideoData extends EventDispatcher 
	{
		public var 	analyseSuccess:Boolean = true;
		private var _urlLoader:URLLoader;

		public function VideoData() :void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
		}
		private function loadComHandler(evn:Event):void
		{
			_urlLoader.removeEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			
			var data:String = String(_urlLoader.data);
			YaoTrace.add(YaoTrace.ALL, "获取视频信息完毕，结果："+data);
			if (data == "")
			{
				YaoTrace.add(YaoTrace.ERROR, "获取视频信息完毕，但视频信息不可为空");
				analyseSuccess = false;
			}
			else
			{
				var jsonObject:Object;
				try
				{
					jsonObject = JSON.decode(data);
				}
				catch (err:Error)
				{
					YaoTrace.add(YaoTrace.ERROR, "视频信息json数据解析失败或是提交的数据没有通过验证！");
					analyseSuccess = false;
				}
				if (jsonObject)
				{
					Data.fms = jsonObject.fms;
					if (Data.fms == "")
					{
						YaoTrace.add(YaoTrace.ERROR, "视频信息json数据中fms参数不可为空！");
						analyseSuccess = false;
					}
					else
					{
						if (Data.live)
						{
							Data.streams = String(jsonObject.stream);
							if (Data.streams == "" || Data.streams == "null" || Data.streams == "undefined")
							{
								YaoTrace.add(YaoTrace.ERROR, "视频信息json数据中stream参数必须要被设置！");
								analyseSuccess = false;
							}
						}
						else
						{
							Data.streams = getStreamArray(jsonObject.stream);
							if (Data.streams.length == 0)
							{
								YaoTrace.add(YaoTrace.ERROR, "视频信息json数据中stream参数中流的数量必须不为0！");
								analyseSuccess = false;
							}
						}
					}
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function getStreamArray(str:String):Array
		{
			var array:Array = str.split(",");
			var n:uint = array.length;
			for (var i:uint = 0; i < n; i++)
			{
				array[i] = array[i].split("|");
				array[i][0]=array[i][0].split(".")[0];
				/*if (array[i][1] == "250")
				{
					array[i][1] = "liuchang";
				}
				if (array[i][1] == "500")
				{
					array[i][1] = "biaozhun";
				}
				if (array[i][1] == "800")
				{
					array[i][1] = "gaoqing";
				}*/
			}
			return array;
		}
		private function loadErrHandler(evn:Event):void
		{
			YaoTrace.add(YaoTrace.ERROR, "获取视频信息出错，无法播放视频");
			
			_urlLoader.removeEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		private function securityHandler(evn:SecurityErrorEvent):void
		{
			_urlLoader.removeEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			
			YaoTrace.add(YaoTrace.ERROR, "跨域获取视频信息出错,请检查api参数所指的域根目录是否放置了crossdomain.xml或者crossdomain.xml中是否设置允许跨域访问。错误信息:"+evn.text);
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		public function load():void
		{
			YaoTrace.add(YaoTrace.ALL, "开始获取视频数据，向服务器发送 :"+Data.uid);
			
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.data = Data.uid;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.url = Data.api+"?random="+String(Math.random());
			
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.load(urlRequest);
		}
	}

}