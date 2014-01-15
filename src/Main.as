package 
{
	import com.greensock.events.LoaderEvent;
	import data.DispatchEvents;
	import data.Submit;
	import data.VideoData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetFilterEvent;
	import flash.external.ExternalInterface;
	import skin.Skin;
	import video.AdvVideoPlayer;
	import data.Data
	import zhen.guo.yao.components.yaotrace.YaoTrace;

	/**
	 * ...
	 * @author yaoguozhen
	 */
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="30")] 
	public class Main extends Sprite 
	{
		private var _skin:Skin;
		private var _videoPlayer:AdvVideoPlayer;
		private var _abc:ABC;
		private var _videoData:VideoData;
		
		public function Main():void 
		{
			try
			{
				//ExternalInterface.addCallback("v_start", v_start);
				//ExternalInterface.addCallback("v_pause", v_pause);
				//ExternalInterface.addCallback("v_resume", v_resume);
			}
			catch (err:Error)
			{
				
			}
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			YaoTrace.init(stage, "xxx");
			//YaoTrace.add(YaoTrace.ALL, " 修改音量滑块拖动问题 ");
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
            
			stage.scaleMode=StageScaleMode.NO_SCALE  
			stage.align = StageAlign.TOP_LEFT
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			DispatchEvents.init(this);
			
			_videoPlayer = new AdvVideoPlayer();
			
			_videoData = new VideoData();
			_videoData.addEventListener(Event.COMPLETE, videoDataLoadComHandler);
			_videoData.addEventListener(IOErrorEvent.IO_ERROR, videoDataLoadErrHandler);
			
			Data.playURL=encodeURI(String(this.loaderInfo.url))
			Data.getData(stage);
			
			var checkRezult:String = CheckData.check();
			if (checkRezult == "")
			{
				Submit.submitOnInit(Data.uid, Data.vid, Data.playURL);
				initSkinLoader();
				_skin.load(Data.skin+"?random="+Math.random());
				//_skin.load(Data.skin);
			}
			else
			{
				YaoTrace.add(YaoTrace.ERROR, checkRezult);
			}
		}
		private function videoDataLoadComHandler(evn:Event):void
		{
			if (_videoData.analyseSuccess)
			{
				v_start(Data.streams, Data.fms);
			}
			else
			{
				YaoTrace.add(YaoTrace.ERROR, "视频信息格式不正确");
				_abc.onVideoDateLoadError("获取视频信息出错")
			}
		}
		private function videoDataLoadErrHandler(evn:IOErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "视频信息获取失败");
			_abc.onVideoDateLoadError("获取视频信息出错")
		}
		private function initSkinLoader():void
		{
			_skin = new Skin();
			_skin.addEventListener(Event.COMPLETE, skinLoadComHandler);
			_skin.addEventListener(IOErrorEvent.IO_ERROR, skinLoadErrHandler);
		}
		private function skinLoadComHandler(evn:Event):void
		{
			if (_skin.missComponent=="")
			{
				addChild(_skin.bg);
				addChild(_videoPlayer);
				addChild(_skin.alertMsgBg);
				addChild(_skin.alertMsg);
				addChild(_skin.controlBar);
				addChild(_skin.buffering);
				addChild(_skin.screenClickHot);
				addChild(_skin.bigPlayBtn);
				addChild(_skin.adMsg);
				addChild(_skin.ratePanel);
				addChild(_skin.settingPanel);
				addChild(_skin.preview);
				
				_abc = new ABC();
				_abc.addObject(_videoPlayer, _skin, stage);
				_abc.addEventListener("playNext",playNextHandler)
				_abc.scale(false, Data.videoRatio);
				
				_abc.alertMsg1 = " ";
				_videoData.load(Data.vid);
			}
			else
			{
				YaoTrace.add(YaoTrace.ERROR, "皮肤文件中缺少原件:"+_skin.missComponent);
				trace(_skin.missComponent)
			}
		}
		private function skinLoadErrHandler(evn:Event):void
		{
			
		}
		private function playNextHandler(evn:Event):void
		{
			_videoData.load(Data.nextVideo);
		}
		private function resizeHandler(evn:Event):void
		{
			_abc.scale(false,Data.videoRatio);
		}
		private function getVideoRatio(videoRatio:String):Number
		{
			if (videoRatio != "")
			{
				var array:Array = videoRatio.split(":");
				if (array.length == 2)
				{
					return Number(array[0]) / Number(array[1]);
				}
				else
				{
					YaoTrace.add(YaoTrace.ALERT, "设置视频比例数据格式不正确");
				}
			}
			return 0;
		}
		
		/*******************************************************************************************/
		
		public function v_start(streams:Object,fms:String="",videoRatio=""):void
		{
			//Data.videoRatio=getVideoRatio(videoRatio);
			if (Data.autoPlay)
			{
				_abc.play(streams, fms);
				_abc.initRate();
			}
		}
		public function v_pause():void
		{
			_abc.pause();
		}
		public function v_resume():void
		{
			_abc.resume();
		}
	}
}