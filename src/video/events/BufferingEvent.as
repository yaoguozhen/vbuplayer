package video.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class BufferingEvent extends Event 
	{
		public static const BUFFERING:String = "524asdfaweff";
		public var percent:Number;
		
		public function BufferingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new BufferingEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("BufferingEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}