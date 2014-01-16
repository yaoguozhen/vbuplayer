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
	import json.JSON2;
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
		private function removeListener():void
		{
			_urlLoader.removeEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
		}
		private function loadComHandler(evn:Event):void
		{
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
					jsonObject = JSON2.decode(data)
				}
				catch (err:Error)
				{
					YaoTrace.add(YaoTrace.ERROR, "视频信息json数据解析失败！");
					analyseSuccess = false;
				}
				if (jsonObject)
				{
					Data.fms = jsonObject.fms;
					if (Data.fms == null || Data.fms == undefined)
					{
						Data.fms=""
						//YaoTrace.add(YaoTrace.ERROR, "视频信息json数据中fms参数不可为空！");
						analyseSuccess = true;
					}
					Data.nextVideo = String(jsonObject.nextStream);
					Data.streams = jsonObject.streams;
					if (Data.streams.length == 0)
					{
						YaoTrace.add(YaoTrace.ERROR, "视频信息json数据中stream参数中流的数量必须不为0！");
						analyseSuccess = false;
					}
					else
					{
						var n = Data.streams.length;
						for (var i:uint = 0; i < n; i++)
						{
							if (Data.streams[i].type == "0")
							{
								Data.previewStream = String(Data.streams[i].stream);
								break
							}
						}
					}
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function loadErrHandler(evn:IOErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "获取视频信息出错，无法播放视频，错误信息："+evn.text);
			removeListener()
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		private function securityHandler(evn:SecurityErrorEvent):void
		{			
			YaoTrace.add(YaoTrace.ERROR, "跨域获取视频信息出错,请检查api参数所指的域根目录是否放置了crossdomain.xml或者crossdomain.xml中是否设置允许跨域访问。错误信息:"+evn.text);
			removeListener()
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		public function load(vid:String):void
		{
			YaoTrace.add(YaoTrace.ALL, "开始获取视频数据，向 "+Data.api+" 发送 :"+Data.uid);
			
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.data = vid;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.url = Data.api+"?random="+String(Math.random());
			
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.load(urlRequest);
		}
	}

}