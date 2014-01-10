package  
{
	import data.Data;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class CheckData 
	{
		public static function check():String
		{
			var msg:String = "";
			if (Data.skin== null)
			{
				msg+="参数 skin 必须被设置 | "
			}
			if (Data.uid==null)
			{
				msg+="参数 vid 必须被设置 | "
			}
			if (Data.api==null)
			{
				msg+="参数 api 必须被设置 | "
			}
			return msg;
		}
	}

}