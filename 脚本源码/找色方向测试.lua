--[[
	image_object:find_color
	支持新字段 find_order 表示找色方向
	字段取值说明
		1 上下左右
		2 左右上下
		3 右左上下
		4 上下右左
		5 下上右左
		6 右左下上
		7 左右下上
		8 下上左右
--]]

webview.show{
	html = [[
	<!DOCTYPE html>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	<html>
	<head>
		<meta charset="UTF-8">
		<title>八边形</title>
		<style type="text/css" >
		#octagon{
		    position:relative;
		    width:100px;
		    height:0;
			margin: 55% auto;
		    border-width:0 71px 71px;
		    border-style:solid;
		    border-color:transparent transparent black;
		}
		#octagon:before{
		    position:absolute;
		    content:"";
		    top:171px;
		    left:-71px;
		    width:100px;
		    height:0;
		    border-width:71px 71px 0;
		    border-style:solid;
		    border-color: black transparent transparent;
		}
		#octagon:after{
		    position:absolute;
		    content:"";
		    top:71px;
		    left:-71px;
		    width:242px;
		    height:0;
		    border-width:0 0 100px;
		    background:none;
		    border-style:solid;
		    border-color:transparent transparent black;
		}
		</style>
	</head>
	<body>
	<div id="octagon"></div>
	</body>
	</html>
	]];
	id = 1;
	level = 2000;
}

sys.toast('该脚本用于演示不同的找色顺序会先找到哪个点')
sys.msleep(2500)

local scale = screen.scale_factor() / 2

local function showp(id, x, y)
	local current_init_orien = screen.current_init_orien()
	if current_init_orien<=0 then
		x, y = x, y
	elseif current_init_orien==1 then
		local w, h = screen.size()
		x, y = w-y, x
	elseif current_init_orien==2 then
		local w, h = screen.size()
		x, y = y, h-x
	elseif current_init_orien>=3 then
		local w, h = screen.size()
		x, y = w-x, h-y
	end
	webview.show{
		html = [[<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"></head><body bgcolor="red"></body></html>]];
		level = 2001;
		x = x - 20 * scale;
		y = y - 20 * scale;
		width = 40 * scale;
		height = 40 * scale;
		corner_radius = 10;
		id = id;
	}
end

local function hidep(id)
	webview.hide(id)
end

local 找色顺序编码 = {
	[1] = "上下左右",
	[2] = "左右上下",
	[3] = "右左上下",
	[4] = "上下右左",
	[5] = "下上右左",
	[6] = "右左下上",
	[7] = "左右下上",
	[8] = "下上左右",
}

for o = 0, 3 do
	screen.init(o)
	sys.toast('screen.init('..o..')\n找到第一个黑色坐标')
	sys.msleep(1000)
	sys.toast('', -1)
	local img = screen.image()
	for i = 1, 8 do
		sys.toast(i..' : '..找色顺序编码[i])
		local x, y = img:find_color({
			find_order = i;
			{0, 0, 0x000000};
		}, 100)
		showp(7, x, y)
		sys.msleep(350)
		hidep(7)
	end
end

webview.hide(1)

screen.init(0)
sys.toast('演示完毕')
sys.msleep(1000)

