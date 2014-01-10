package zhen.guo.yao.components.yaotrace 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author t
	 */
	internal class YaoData extends EventDispatcher 
	{	
		
		public static var areaWidth:Number = 500;
		public static var areaHeight:Number = 300;
		
		public static var btnArray = [["警告",YaoTrace.ALERT,false],["错误",YaoTrace.ERROR,false],["全部","",false],["清除",YaoTrace.CLEAR,true],["上滚",YaoTrace.PREV_PAGE,true],["下滚",YaoTrace.NEXT_PAGE,true]];
		
		public static var msgArray:Array=[];
		
		public function addMsg(msg:String, msgType:String = ""):void
		{
			msgArray.push([msg, msgType]);	
			dispatchEvent(new Event("dataChanged"));
		}
		public function getCount(msgType:String=""):String
		{
			var count:uint = 0;
			var n:uint = msgArray.length;
			if (msgType == "")
			{
				count = n;
			}
			else
			{
				for (var i:uint = 0; i < n; i++)
				{
					if (msgArray[i][1] == msgType)
					{
						count++;
					}
				}
			}
			return String(count);
		}
		public function clearMsg():void
		{
			msgArray = [];
			dispatchEvent(new Event("clearMsg"));
		}
	}
	
}