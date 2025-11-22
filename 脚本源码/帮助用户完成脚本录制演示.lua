local scr_w, scr_h = screen.size()

local scale = screen.scale_factor() / 2

webview.show{
	html = [[
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	<html>
	<head>
	<style>
	#one_button {
		color: #FFFFFF;
		text-shadow: 0px 0px 10px #000000;
	}
	div { /* 禁止选中文字 */
		-moz-user-select:none;
		-webkit-user-select:none;
		-ms-user-select:none;
		-khtml-user-select:none;
		user-select:none;
	}
	</style>
    <script src="/js/jquery.min.js"></script>
    <script src="/js/jquery.json.min.js"></script>
	<script type="text/javascript">
	$(document).ready(function(){
		$("#one_button").click(function(){
			$.post(
                "/proc_queue_push", // 将点击事件消息发送到进程词典
                $.toJSON({
                    key:"来自webview的消息",
                    value:"捕捉完毕"
                }),
                function(){}
            );
		});
	});
	</script>
	</head>
	<body>
	<div id="one_button">将小块移动到“签到”按钮上然后点这里</div>
	</body>
	</html>
	]],
	x = (scr_w - 570 * scale) / 2,
	y = scr_h - 280 * scale,
	width = 580 * scale,
	height = 100 * scale,
	corner_radius = 10,
	alpha = 0.7,
	animation_duration = 0.3,
	rotate = rotate_ang,
	can_drag = true,
	opaque = false,
	id = 2, -- 这里的 webview 编号可用于隐藏、销毁该 webview
}

function show_tile(tileid)
    local x = scr_w / 2   -- 居中横坐标
    local y = scr_h - 380 * scale -- 屏幕底部向上偏移 380 像素的纵坐标
    webview.show{
        html = [[<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">]],
        x = x - 50 * scale;
        y = y - 50 * scale;
        width = 100 * scale;
        height = 100 * scale;
        corner_radius = 25;
        alpha = 0.7;
        animation_duration = 0;
        can_drag = true;
        level = 2060;
        use_wkwebview = true;
        id = tileid;
    }
end

show_tile(3) -- 显示可以拖拽的小块，webview 编号为 3，可以使用 webview.destroy(3) 销毁它

proc_queue_clear("来自webview的消息", "") -- 清空需要监听的字典的值
local eid = thread.register_event( -- 注册监听字典状态有值事件
    "来自webview的消息",
    function(val)
        if val == '捕捉完毕' then
            local frame = webview.frame(3) -- 获取小块 frame 信息
            local x, y = (frame.x * (scale * 2) + 50 * scale), (frame.y * (scale * 2) + 50 * scale) -- 通过 frame 信息换算出小块位置
            webview.destroy(3) -- 销毁 编号为 3 的小块
            webview.destroy(2) -- 销毁 将小块移动到“签到”按钮上然后点这里 按钮
            sys.toast("测试点击捕捉到的位置\n"..x..", "..y)
            -- sys.msleep(300)
            touch.show_pose(true)
            touch.tap(x, y)
            sys.msleep(1000)
            sys.alert("捕捉到位置\n"..x..", "..y)
            os.exit()
        end
    end
)

--[[
while 1 do
    local frame = webview.frame(3)
    local x, y = (frame.x* factor + 25 * factor), (frame.y * factor + 25 * factor)
	sys.toast("小块位置："..x..", "..y)
	sys.msleep(1000)
end
--]]