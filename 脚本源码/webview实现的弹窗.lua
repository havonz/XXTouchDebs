--[[
作者：桃子
QQ：270001300
--]]

local function html_escape(value)
	value = tostring(value)
	local charmap = {
		['&'] = '&amp;',
		['<'] = '&lt;',
		['>'] = '&gt;',
		['"'] = '&quot;',
		["'"] = '&apos;',
		['\n'] = '&#10;',
		[' '] = '&nbsp;',
	}
	value = string.gsub(value, '[ &<>"\'\n]',  function(c)
		return charmap[c]
	end)
	return value
end

function alert(message,timeout,title,cancelbutton,button)
	local w, h = screen.size()
	local buttons = {}
	local button_index = 0
	if button then
		for k, v in ipairs(button or {}) do
			button_index = button_index + 1
			table.insert(buttons,
				string.format('<button type="button" class="mui-btn mui-btn-primary mui-btn-outlined" onclick="CallButton(%s)">%s</button>',button_index,html_escape(v))
			)
		end
	else
		button_index = button_index + 1
		table.insert(buttons,'<button type="button" class="mui-btn mui-btn-primary mui-btn-outlined" onclick="CallButton(1)">确定</button>')
	end
	if cancelbutton then
		button_index = button_index + 1
		table.insert(buttons,'<button type="button" class="mui-btn mui-btn-danger mui-btn-outlined" onclick="CallButton(0)">'..html_escape(cancelbutton)..'</button>')
	end
	message = html_escape(message)
	local but_width, webview_height, webview_bottom
	if button_index > 2 then
		but_width = "90"
		webview_height = 460 + (80 * (button_index - 1))
		webview_bottom = 60 + (40 * (button_index - 1))
	elseif button_index == 2 then
		but_width = "45"
		webview_height = 480
		webview_bottom = 60
	elseif button_index == 1 then
		but_width = "90"
		webview_height = 480
		webview_bottom = 60
	end
	if #(message:split('<br>')) > 6 then
		webview_height = webview_height + ((#(message:split('<br>')) - 6) * 45)
	end
	if webview_height > h - 100 then webview_height = h - 100 end
	local html = [=[<!doctype html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<meta name="viewport" content="width=]=]..(w/15)..[=[, height=]=]..(h/15)..[=[, initial-scale=1,maximum-scale=1,user-scalable=no">
		<meta name="apple-mobile-web-app-capable" content="yes">
		<meta name="apple-mobile-web-app-status-bar-style" content="black">
		<link rel="stylesheet" href="/mui/css/mui.min.css">
		<script src="/mui/js/mui.min.js"></script>
		<style>
			.mui-control-content{
			  	margin: 10px;
			}
			.buttons{
				padding-top: 3px;
				padding-bottom: 13px;
			}
			.mui-btn{
				width: ]=]..but_width..[=[%;
				height: 35px;
				margin: 3px;
			}
			.mui-content{
				height: 100px;
			}
			.mui-bar-nav{
				box-shadow: 0 1px 6px #FFFFFF;
			}
			.mui-active{
				padding-bottom: ]=]..webview_bottom..[=[px;
			}

		</style>
		<script>
	     	function CallButton(b) {
			    var RetMessage = JSON.stringify(
			    	{
			    		key:"alert-webview",
			    		value:JSON.stringify(
			    			{
			    				Submit:true,
			    				Data:b
			    			}
			    		)
			    	}
			    );
			    console.log(RetMessage);
				mui.ajax('/proc_queue_push',{
					data:RetMessage,
					dataType:'json',
					type:'post',
					timeout:10000,
					success:function(request){
						console.log(request.code);
					},
					error:function(xhr,type,errorThrown){
						console.log(type);
					}
				});
	    	};
	     	var _TimeOut = ]=] .. tonumber(timeout or '0') .. [=[;
			function TimeOut(){
				_TimeOut = _TimeOut - 1;
				if(_TimeOut==0){
					CallButton(-1);
				}
			};
			setInterval(TimeOut,1000);
		</script>
	</head>
	<body>
        <header class="mui-bar mui-bar-nav">
        	<h1 class="mui-title">]=]..(html_escape(title) or 'XXTouch')..[=[</h1>
        </header>
		<nav class="mui-bar mui-bar-tab">
			<center class="buttons">
				]=]..table.concat(buttons,'\r\n')..[=[
			</center>
		</nav>
		<div class="mui-content">
			<div id="tabbar" class="mui-control-content mui-active">
				<center><p>]=]..message..[=[</p></center>
			</div>
		</div>
	</body>
</html>]=]
	local ret = ''
	webview.show{
		id = 2,
		x = 0,
		y = 0,
		width = w,
		height = h,
		alpha = 0,
		animation_duration = 0,
		level = 1995.1
	}
	local hhh = (h - webview_height) / 2
	webview.show{
		id = 1,
		html = html,
		x = (w - 600) / 2,
		y = -hhh,
		width = 600,
		height = webview_height,
		alpha = 0,
		animation_duration = 0,
		level = 1995.2
	}
	webview.show{
		id = 2,
		x = 0,
		y = 0,
		width = w,
		height = h,
		alpha = 0.4,
		animation_duration = 0.2,
		level = 1995.1,
		html = [[<html><body style="background:#000000"></body></html>]]
	}
	webview.show{
		id = 1,
		html = html,
		x = (w - 600) / 2,
		y = hhh,
		width = 600,
		height = webview_height,
		corner_radius = 2,
		alpha = 1,
		animation_duration = 0.2,
		rotate = rotate_ang,
		level = 1995.2
	}
	sys.msleep(200)
	proc_queue_clear("alert-webview")
	while(ret=='')do
		ret = proc_queue_pop("alert-webview")
		sys.msleep(1)
	end
	webview.show{
		id = 1,
		x = (w - 600) / 2,
		y = h,
		width = 600,
		height = webview_height,
		alpha = 0,
		animation_duration = 0.2,
	}
	webview.show{
		id = 2,
		x = 0,
		y = 0,
		width = w,
		height = h,
		alpha = 0,
		animation_duration = 0.2
	}
	sys.msleep(200)
	webview.destroy(1)
	webview.destroy(2)
	return json.decode(ret).Data
end

---[[
while true do
	nLog('alert("aasdas",0,"啦啦啦","关闭",{"按钮1"})')
	nLog(alert("aasdas",0,"啦啦啦","关闭",{"按钮1","按钮2","按钮3","按钮4","按钮5"}))
	nLog('alert("aas\r\n\r\n\r\n",0,"啦啦啦","关闭",{"按钮1"})')
	nLog(alert("aas\r\n\r\n\r\nasd",0,"啦啦啦","关闭",{"按钮1"}))
	nLog('alert("aas\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\nxxx",0,"啦啦啦","关闭",{"按钮1"})')
	nLog(alert("aas\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\nxxx",0,"啦啦啦","关闭",{"按钮1"}))
end
--]]
