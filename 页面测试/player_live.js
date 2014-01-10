				var nextplay="";
			//是否支持flash
				function detectFlash() {
				         //navigator.mimeTypes是MIME类型，包含插件信息
				     if(navigator.mimeTypes.length>0){
				     //application/x-shockwave-flash是flash插件的名字
				         var flashAct = navigator.mimeTypes["application/x-shockwave-flash"];
				         return flashAct != null ? flashAct.enabledPlugin!=null : false;
				     } else if(self.ActiveXObject) {
				         try {
				             new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
				             return true;
				         } catch (oError) {
				             return false;
				         }
				     }
				 }
				 
				function checkhHtml5()   
				{   
					if (typeof(Worker) !== "undefined")   
					{   
						return true;  
					} else   
					{   
						return false; 
					}  
				}
			
				/* 
				* 智能机浏览器版本信息: 
				* 
				*/
				  var browser={ 
				    		versions:function(){  
				        var u = navigator.userAgent, app = navigator.appVersion; 
			   
			          var browserName=navigator.userAgent.toLowerCase(); 
				        return {//移动终端浏览器版本信息  
				               //IE内核 
														trident: /msie/i.test(browserName) && !/opera/.test(browserName), //IE内核
				                		presto: u.indexOf('Presto') > -1, //opera内核 
				                		webKit: u.indexOf('AppleWebKit') > -1, //苹果、谷歌内核 
				                		gecko: u.indexOf('Gecko') > -1 && u.indexOf('KHTML') == -1, //火狐内核 
											//是否为移动终端
														mobile: !!u.match(/AppleWebKit.*Mobile.*/),
				                		ios: !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/), //ios终端 
				                		android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1, //android终端或者uc浏览器 
				                		iPhone: u.indexOf('iPhone') > -1 || u.indexOf('Mac') > -1, //是否为iPhone或者QQHD浏览器 
				                		iPad: u.indexOf('iPad') > -1, //是否iPad 
				                		webApp: u.indexOf('Safari') == -1, //是否web应该程序，没有头部与底部 
				                		Windows: u.indexOf('Windows') > -1 //是否Windows
				            }; 
				         }(), 
				         language:(navigator.browserLanguage || navigator.language).toLowerCase() 
				}  
			
			  function play(url_1,url_2,stream,vwidth,vheight){			  	  			   
			  	  if (browser.versions.mobile){			  	     
							  document.write('<div class="video_control"  id="p_player">');
					  		document.write('<video id="video" width="'+vwidth+'" height="'+vheight+'" controls="controls" autoplay="true" src="'+url_2+'"/>');
					  		document.write('</div>');
			  	  }else{
			  	  	    document.write('<div id="player" style="width:667px;height:468px;margin:0 auto;text-align:center"></div>');
				        	var player = flowplayer("player", "/portal_media/flowplayer/flowplayer-3.2.16.swf",{   
						         clip: {
									      url: stream,
									      live: true,
									      provider: 'rtmp'
									    },  
						        plugins: {   
						            rtmp: {   
						                url: '/portal_media/flowplayer/flowplayer.rtmp-3.2.12.swf',   
						                netConnectionUrl: url_1   
						            },  
						              
						            controls: {   
						                url: '/portal_media/flowplayer/flowplayer.controls-3.2.15.swf',  
						                autoHide:'always',  
						                play: true,   
						                scrubber: true,   
						                playlist: false, 						                
						                tooltips: {   
						                    buttons: true,   
						                    play:'播放',  
						                    fullscreen: '全屏' ,  
						                    fullscreenExit:'退出全屏',  
						                    pause:'暂停',  
						                    mute:'静音',  
						                    unmute:'取消静音'  
						                }   
						            }  
						       }						       
						    }); 
			  			}						
			  }	      
  
  

