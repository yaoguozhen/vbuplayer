package  
{
	import data.Data;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class CheckData 
	{
		public static function check(obj:Object):Object
		{
			var msg:Object = new Object();
			msg.alertMsg = "";
			msg.errorMsg = "";
			if (obj.skin==undefined)
			{
				msg.errorMsg+="参数 skin 必须被设置 | "
			}
			if (obj.submitURl==undefined)
			{
				msg.alertMsg+="submitURl 参数没有被设置，将不能提交数据 "
			}
			if (obj.streams==undefined)
			{
				msg.errorMsg+="参数 streams 必须被设置 | "
			}
			return msg;
		}
	}

}