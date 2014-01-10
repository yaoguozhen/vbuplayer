package skin.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class RateEvent extends Event 
	{
		public static const RATE_CHANGE:String = "rateChange";
		public var rate:String;
		
		public function RateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new RateEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("RateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}