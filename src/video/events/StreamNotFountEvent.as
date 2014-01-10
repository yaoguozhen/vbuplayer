package video.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class StreamNotFountEvent extends Event 
	{
		public static const STREAM_NOT_FOUNT:String = "streamNotFount";
		public var rate:String;
		
		public function StreamNotFountEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new StreamNotFountEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("StreamNotFountEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}