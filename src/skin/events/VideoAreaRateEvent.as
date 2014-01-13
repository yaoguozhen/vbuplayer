package skin.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class VideoAreaRateEvent extends Event 
	{
		public static const RATE_CHANGE:String = "rateChange231458";
		public var rate:String;
		
		public function VideoAreaRateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new VideoAreaRateEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("VideoAreaRateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}