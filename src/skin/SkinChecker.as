package skin 
{
	import flash.display.MovieClip;
	/**
	 * 检查是否缺少原件
	 * @author yaoguozhen
	 */
	internal class SkinChecker 
	{
		
		public static  function check(mc:MovieClip):String
		{
			var controlBar = mc.getChildByName("controlBar");
			if (controlBar == null)
			{
				return "控制条：controlBar";
			}
			else
			{
				var playBtn = mc.controlBar.getChildByName("playBtn");
				if (playBtn == null)
				{
					return "播放按钮：controlBar.playBtn";
				}
				var pauseBtn = mc.controlBar.getChildByName("pauseBtn");
				if (pauseBtn == null)
				{
					return "暂停按钮：controlBar.pauseBtn";
				}
				var progressBar = mc.controlBar.getChildByName("progressBar");
				if (progressBar == null)
				{
					return "进度条：controlBar.progressBar";
				}
				else
				{
					var progressBarBg = mc.controlBar.progressBar.getChildByName("progressBarBg");
					if (progressBarBg == null)
					{
						return "controlBar.progressBar.progressBarBg";
					}
					var followBar = mc.controlBar.progressBar.getChildByName("followBar");
					if (followBar == null)
					{
						return "controlBar.progressBar.followBar";
					}
					var loadingBar = mc.controlBar.progressBar.getChildByName("loadingBar");
					if (loadingBar == null)
					{
						return "controlBar.progressBar.loadingBar";
					}
					var block = mc.controlBar.progressBar.getChildByName("block");
					if (block == null)
					{
						return "controlBar.progressBar.block";
					}
				}
				var volBar = mc.controlBar.getChildByName("volBar");
				if (volBar == null)
				{
					return "音量控制条：controlBar.volBar";
				}
				else
				{
					var path = mc.controlBar.volBar.getChildByName("path");
					if (path == null)
					{
						return "音量的滑到：controlBar.volBar.path";
					}
					var followBar = mc.controlBar.volBar.getChildByName("followBar");
					if (followBar == null)
					{
						return "音量的跟随条：controlBar.volBar.followBar";
					}
					var block = mc.controlBar.volBar.getChildByName("block");
					if (block == null)
					{
						return "音量滑块：controlBar.volBar.block";
					}
				}
				var volBtn = mc.controlBar.getChildByName("volBtn");
				if (volBtn == null)
				{
					return "音量按钮：controlBar.volBtn";
				}
				var fullscreenBtn = mc.controlBar.getChildByName("fullscreenBtn");
				if (fullscreenBtn == null)
				{
					return "全屏按钮：controlBar.fullscreenBtn";
				}
				var settingBtn = mc.controlBar.getChildByName("settingBtn");
				if (settingBtn == null)
				{
					return "设置按钮：controlBar.settingBtn";
				}
				var time = mc.controlBar.getChildByName("time");
				if (time == null)
				{
					return "时间显示文本框：controlBar.time";
				}
				var alertMsg = mc.getChildByName("alertMsg");
				if (alertMsg == null)
				{
					return "alertMsg";
				}
				var bigPlayBtn = mc.getChildByName("bigPlayBtn");
				if (bigPlayBtn == null)
				{
					return "bigPlayBtn";
				}
				var adMsg = mc.getChildByName("adMsg");
				if (adMsg == null)
				{
					return "adMsg";
				}
				var buffering = mc.getChildByName("buffering");
				if (buffering == null)
				{
					return "buffering";
				}
			}
			return "";
		}
	}

}