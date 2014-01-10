需要在页面里传给flash的参数
    vid:视频id
    api:获取视频信息的地址
	    期望从该地址返回如下json数据
		    点播
			    {fms:"rtmp://localhost/vod", stream:"sample1|250,stream2|500,stream3|800" }
			直播
			    {fms:"rtmp://localhost/vod", stream:"sample" }
    skin:播放器皮肤文件地址。
    live:是否是直播
	    点播
		    false
		直播
		    true

flash调用js的方法
    videoUpatetime()
	    说明
		    flash每秒会调用js该方法
		参数
		    视频总持续时间、当前时间。形如： { videolong = 120; nowtime = 45 }
		返回
		    无
	setFlashtPlayerStart()
	    说明
		    flash在开始播放前，调用js该方法，来获取上次结束观看的时间点
		参数
		    无
		返回
		    以秒为单位的数字。如：127
			如果该视频是第一次观看，则返回0.
	videoend()
	    说明
		    视频播放结束时，调用js该方法
		参数
		    无
		返回
		    无
		    