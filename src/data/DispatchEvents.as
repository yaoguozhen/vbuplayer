package data 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	/**
	 * ...
	 * @author t
	 */
	public class DispatchEvents 
	{
		private static var _obj:Sprite;
		
		public function DispatchEvents() :void
		{
			
		}
		public static function init(obj:Sprite)
		{
			DispatchEvents._obj = obj;
		}
		public static function STREAM_PLAY_COMPLETE():void
		{
			try
			{
				ExternalInterface.call("videoend");
			}
			catch (err:Error)
			{
				YaoTrace.add(YaoTrace.ALERT, "调用js videoend 方法失败");
			}
		}
		public static function UPATEE_TIMER(msg:String):void
		{
			try
			{
				ExternalInterface.call("videoUpatetime",msg);
			}
			catch (err:Error)
			{
				YaoTrace.add(YaoTrace.ALERT, "调用js videoUpatetime 方法失败")
			}
		}
		public static function GET_STARTTIME():Number
		{
			try
			{
				var msg:String = String(ExternalInterface.call("setFlashtPlayerStart"));
				YaoTrace.add(YaoTrace.ALL, "调用js setFlashtPlayerStart 方法返回：" + msg);
				if (msg == "undefined")
				{
					YaoTrace.add(YaoTrace.ALERT, "调用 setFlashtPlayerStart 方法返回值非法，将从头开始播放视频")
					return 0;
				}
				return Number(msg);
			}
			catch (err:Error)
			{
				YaoTrace.add(YaoTrace.ALERT, "调用js setFlashtPlayerStart 方法失败，将从头开始播放视频")
			}
			return 0;
		}
	}

}