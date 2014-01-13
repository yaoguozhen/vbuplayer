package skin.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author t
	 */
	public class ChangeLightEvent extends Event 
	{
		public static const CHANGE:String = "eredt5uhsdfe~!@11";
		public var changeType:String
		public var value:Number
		
		public function ChangeLightEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ChangeLightEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ChangeLightEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}