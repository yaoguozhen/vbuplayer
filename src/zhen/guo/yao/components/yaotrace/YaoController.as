package zhen.guo.yao.components.yaotrace 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	internal class YaoController extends Sprite 
	{		
		public const DIS:Number = 5;
		
		/**
		 * 构造函数
		 * @param	w 高度
		 * @param	h 宽度
		 */
		public function YaoController():void
		{
			var btn:YaoButton;
			var n:uint = YaoData.btnArray.length;
			for (var i:uint = 0; i < n; i++)
			{
				if (YaoData.btnArray[i][2])
				{
					btn = new YaoButton(YaoData.btnArray[i][0]);
				}
				else
				{
					btn = new YaoButton(YaoData.btnArray[i][0]+"[0]");
				}
				
				btn.btnType = YaoData.btnArray[i][1];
				//btn.selected = true;
				btn.addEventListener(MouseEvent.CLICK, btnClickHandler);
				YaoData.btnArray[i].push(btn);
				addChild(btn);
			}
			
			setBtnsPosition();
		}
		 //按钮点击事件侦听器
		private function btnClickHandler(evn:MouseEvent):void
		{
			var btn:YaoButton = YaoButton(evn.target);
			
			var event:YaoBtnClickEvent = new YaoBtnClickEvent(YaoBtnClickEvent.BTN_CLICK);
			event.btnType = btn.btnType;
			dispatchEvent(event);
		}
		private function setBtnsPosition():void
		{
			var lastBtn:YaoButton;
			var n:uint = YaoData.btnArray.length;
			for (var i:uint = 0; i < n; i++)
			{
				if (lastBtn == null)
				{
					YaoData.btnArray[i][3].x = DIS;
					lastBtn = YaoData.btnArray[i][3];
				}
				else
				{
					YaoData.btnArray[i][3].x = lastBtn.x + lastBtn.width + DIS;
					lastBtn = YaoData.btnArray[i][3];
				}
				YaoData.btnArray[i][3].y = YaoData.areaHeight - YaoData.btnArray[i][3].height - DIS;
			}
		}
		public function setCount(msgType:String, count:String ):void
		{
			var n:uint = YaoData.btnArray.length;
			for (var i:uint = 0; i < n; i++)
			{
				if (YaoData.btnArray[i][1] == msgType)
				{
					YaoData.btnArray[i][3].label = YaoData.btnArray[i][0] + "[" + count + "]";
					setBtnsPosition();
					break;
				}
				
			}
		}
		public function clearMsg():void
		{
			var n:uint = YaoData.btnArray.length;
			for (var i:uint = 0; i < n; i++)
			{
				switch(YaoData.btnArray[i][1])
				{
					case YaoTrace.ALERT:
					case YaoTrace.ERROR:
					case YaoTrace.ALL:
						YaoData.btnArray[i][3].label = YaoData.btnArray[i][0] + "[0]";
						break;
					case YaoTrace.CLEAR:
						YaoData.btnArray[i][3].label = YaoData.btnArray[i][0];
						break;	
				}
			}
		}
	}

}