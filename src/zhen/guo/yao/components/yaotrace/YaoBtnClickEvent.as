package zhen.guo.yao.components.yaotrace 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	internal class YaoBtnClickEvent extends Event 
	{
		public static const BTN_CLICK:String = "btnClick";
		public var btnType:String;
		
		public function YaoBtnClickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new YaoBtnClickEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("BtnClickEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}