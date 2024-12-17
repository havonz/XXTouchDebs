local XXTDo = (function()
	local ok, XXTDo  = pcall(require, 'XXTDo')
	if ok then
		return XXTDo
	end

	local done = false

	thread.dispatch(function()
		while not done do
			sys.toast('Downloading XXTDo.lua ...', device.front_orien())
			sys.msleep(1000)
		end
		sys.toast('', -1)
	end)

	local jbroot = jbroot or function(path) return path end
	local XXT_HOME_PATH = XXT_HOME_PATH or jbroot('/var/mobile/Media/1ferver')

	local function gh_get(info)
		local url_buf = {'https://raw.githubusercontent.com'}
		url_buf[#url_buf + 1] = info.username
		url_buf[#url_buf + 1] = info.repo
		url_buf[#url_buf + 1] = info.branch or 'master'
		url_buf[#url_buf + 1] = info.path
		local get = info.get or http.get
		local url = table.concat(url_buf, '/')
		return get(url, 60)
	end

	while 1 do
		local c, _, r = gh_get{
			username = 'havonz',
			repo = 'XXTouchDebs',
			path = '脚本源码/XXTDo.lua',
		}
		if c == 200 then
			file.writes(XXT_HOME_PATH..'/lua/XXTDo.lua', r)
			local ok, XXTDo  = pcall(require, 'XXTDo')
			if ok then
				done = true
				return XXTDo
			end
		end
		sys.msleep(100)
	end
end)()

function get_poscolors_rect(poscolors)
	local minx, miny, maxx, maxy = 99999, 99999, 0, 0
	for i,pc in ipairs(poscolors) do
		if pc[1] >= maxx then
			maxx = pc[1]
		end
		if pc[2] >= maxy then
			maxy = pc[2]
		end
		if pc[1] <= minx then
			minx = pc[1]
		end
		if pc[2] <= miny then
			miny = pc[2]
		end
	end
	return minx, miny, maxx, maxy
end

XXTDo.runloop {

	name = '只是一个开心的脚本',

	log = sys.log,
	log_date = false,
	error = error,

	-- filter = screen.is_colors,
	filter = function (poscolors, csim)
		local edge = 5
		if type(poscolors._rect) ~= 'table' then
			poscolors._rect = {get_poscolors_rect(poscolors)}
		end
		local minx, miny, maxx, maxy = table.unpack(poscolors._rect)
		if minx == 99999 then
			error('What the ?')
		end
		local x, y = screen.find_color(poscolors, csim, minx - edge, miny - edge, maxx + edge, maxy + edge)
		return x ~= -1
	end,

	csim = 90,

	pre_run = function(_P)
		_P.log('一轮新的判断开始')
	end,

	post_run = function(_P, matched_info)
		_P.log('本轮判断结束，匹配到的界面是：'..(type(matched_info) == 'table' and matched_info.ui.name or '(无)'))
	end,

	else_run = function(_P)
		_P.log('本轮没有匹配任何界面')
	end,

	finally = function(_P, results)

	end,

	{name = '只是某个界面判断', group = {
			{
				{  443,  465, 0xd21c0f},
				{  444,  479, 0xad3e62},
				{  441,  495, 0xae8ec2},
				{  471,  491, 0x3c74a0},
				{  484,  483, 0x3f9750},
				{  481,  463, 0x7bb218},
				{  481,  463, 0x7bb218},
			},
		},
		run = function(self, index, _P)
			touch.tap(481, 463)
		end,
	},
}