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

	while 1 do
		local c, h, r = http.get('https://raw.githubusercontent.com/havonz/XXTouchDebs/refs/heads/master/脚本源码/XXTDo.lua', 30, {})
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

XXTDo.runloop {

	name = '只是一个开心的脚本',

	log = sys.log,
	log_date = false,
	error = error,

	filter = screen.is_colors,
	csim = 90,

	pre_run = function(_P)
		_P.log('一轮新的判断开始')
	end,

	post_run = function(_P, matched)
		_P.log('本轮判断结束，匹配到的界面是：'..(type(matched) == 'table' and matched.name or '(无)'))
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