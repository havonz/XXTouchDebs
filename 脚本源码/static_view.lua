--[[

	static_view.lua

	Created by 苏泽 on 25-01-03.
	Copyright (c) 2025年 苏泽. All rights reserved.

	-- 创建一些只能看不能交互的控件在屏幕上
	-- iOS 13.2 以上可以在安全模式下使用，并且支持 secure 属性
	-- 阅读源码需要有 Objective-C 和 Lua 基础

	-- 2025-11-15 版本更新 0.2.3：
	-- 给 new_rectangle_border、new_text_label、new_image_label 三个函数添加了 background_color 属性
	-- new_rectangle_border 的 color 属性现在支持 ARGB 颜色值，可以设置边框的透明度
	-- new_text_label 的 text_color 属性现在支持 ARGB 颜色值，可以设置文本的透明度
	-- 增加 init 和 remove_all_views 函数，分别用于初始化静态视图服务和清理掉所有的控件

	-- 2025-11-01 版本更新 0.2.2：
	-- 修正 13.2 以下设备不正常的问题
	-- 增加 kill_toast_service 函数，可以手动停止 toast 服务以释放内存

	-- 2025-02-21 版本更新 0.2.1：
	-- 优化在新版 XXT 中使用内建 API 发送通知消息

	-- 2025-01-21 版本更新 0.2：
	-- 为所有控件添加了 orientation 属性，可以设置控件的参考坐标系，0 - 竖屏 Home 在下，1 - 横屏 Home 在右，2 - 横屏 Home 在左，3 - 竖屏 Home 在上

	-- 2025-01-03 版本更新 0.1：
	-- 发布第一个版本

	-- 引用 static_view 模块
	local static_view = require('static_view')

	-- 初始化静态视图服务，可以不手动执行，模块在创建第一个控件时会自动初始化，显式初始化可以避免创建第一个控件时的延迟
	static_view.init()

	-- 终止静态视图服务，清理掉所有的控件，释放内存，脚本结束时会自动执行
	static_view.remove_all_views()

	-- 在屏幕上创建一个四边形方框
	border = static_view.new_rectangle_border{
		width = 143,          -- 可读写属性，方框宽度
		height = 143,         -- 可读写属性，方框高度
		x = 45,               -- 可选参数，可读写属性，左上角横坐标，默认 0
		y = 231,              -- 可选参数，可读写属性，左上角纵坐标，默认 0
		size = 2,             -- 可选参数，可读写属性，边框粗细尺寸，默认 2
		color = 0xFF0000,   -- 可选参数，可读写属性，边框颜色，默认 0xFFFFFF
		background_color = 0, -- 可选参数，可读写属性，背景颜色，默认 0（透明），需要注意的是 0xFF000000 表示黑色，0 - 透明，0xFF000000 - 黑色，其他值表示 ARGB 颜色值，例如 0x80FF0000 表示半透明红色
		orientation = 0,      -- 可选参数，可读写属性，参考坐标系方向，0 - 竖屏 Home 在下，1 - 横屏 Home 在右，2 - 横屏 Home 在左，3 - 竖屏 Home 在上，默认为 screen.init 初始化的那个方向
		secure = false,       -- 可选参数，只读属性，为 true 则截屏录屏取色会忽略这个视图，默认为 false
	}

	-- 属性读写
	border.x = border.x + 100
	border.y = border.y + 100

	-- 将属性更新到界面上
	border:refresh(0.5) -- 修改属性后可使用该方法刷新视图，可传入动画时长参数，默认 0

	-- 对四边形方框执行一些自定义动作
	-- 错误的代码会导致 toast 服务崩溃
	border:eval(function(border)
		require('objc').UIView.animateWithDuration(0.3).animations(oneTimeBlock(function()
			border.transform = CGAffineTransformRotate(border.transform(), 45 * (math.pi / 180.0))
		end))()
	end)
	
	-- 在屏幕上创建一个文本标签
	txt_label = static_view.new_text_label{
		text = 'Hello',           -- 可读写属性，文本内容
		x = 300,                  -- 可选参数，可读写属性，左上角横坐标，默认 0
		y = 300,                  -- 可选参数，可读写属性，左上角纵坐标，默认 0
		text_color = 0xFF0000,  -- 可选参数，可读写属性，文本颜色，默认 0xFFFFFF
		background_color = 0,     -- 可选参数，可读写属性，背景颜色，默认 0（透明），需要注意的是 0xFF000000 表示黑色，0 - 透明，0xFF000000 - 黑色，其他值表示 ARGB 颜色值，例如 0x80FF0000 表示半透明红色
		font_name = 'Helvetica',  -- 可选参数，可读写属性，文本字体，默认 'Helvetica'
		font_size = 12,           -- 可选参数，可读写属性，文本字体尺寸，默认 12
		orientation = 0,          -- 可选参数，可读写属性，参考坐标系方向，0 - 竖屏 Home 在下，1 - 横屏 Home 在右，2 - 横屏 Home 在左，3 - 竖屏 Home 在上，默认为 screen.init 初始化的那个方向
		secure = false,           -- 可选参数，只读属性，为 true 则截屏录屏取色会忽略这个视图，默认为 false
	}

	-- 属性读写
	txt_label.x = txt_label.x + 100
	txt_label.y = txt_label.y + 100

	-- 将属性更新到界面上
	txt_label:refresh(0.5) -- 修改属性后可使用该方法刷新视图，可传入动画时长参数，默认 0

	-- 对文本标签执行一些自定义动作
	-- 错误的代码会导致 toast 服务崩溃
	txt_label:eval(function(txt_label)
		require('objc').UIView.animateWithDuration(0.3).animations(oneTimeBlock(function()
			txt_label.transform = CGAffineTransformRotate(txt_label.transform(), 45 * (math.pi / 180.0))
		end))()
	end)
	
	-- 在屏幕上创建一个图像标签
	img_label = static_view.new_image_label{
		image = img,          -- 可读写属性，图像内容
		width = 143,          -- 可读写属性，方框宽度
		height = 143,         -- 可读写属性，方框高度
		x = 45,               -- 可选参数，可读写属性，左上角横坐标，默认 0
		y = 231,              -- 可选参数，可读写属性，左上角纵坐标，默认 0
		background_color = 0, -- 可选参数，可读写属性，背景颜色，默认 0（透明），需要注意的是 0xFF000000 表示黑色，0 - 透明，0xFF000000 - 黑色，其他值表示 ARGB 颜色值，例如 0x80FF0000 表示半透明红色
		orientation = 0,      -- 可选参数，可读写属性，参考坐标系方向，0 - 竖屏 Home 在下，1 - 横屏 Home 在右，2 - 横屏 Home 在左，3 - 竖屏 Home 在上，默认为 screen.init 初始化的那个方向
		secure = false,       -- 可选参数，只读属性，为 true 则截屏录屏取色会忽略这个视图，默认为 false
	}

	-- 属性读写
	img_label.x = img_label.x + 100
	img_label.y = img_label.y + 100

	-- 将属性更新到界面上
	img_label:refresh(0.5) -- 修改属性后可使用该方法刷新视图，可传入动画时长参数，默认 0

	-- 对图像标签执行一些自定义动作
	-- 错误的代码会导致 toast 服务崩溃
	img_label:eval(function(img_label)
		require('objc').UIView.animateWithDuration(0.3).animations(oneTimeBlock(function()
			img_label.transform = CGAffineTransformRotate(img_label.transform(), 45 * (math.pi / 180.0))
		end))()
	end)
--]]

if type(sys.task) ~= 'function' then
	error('static_view 模块需要更新版本的 XXT')
	return {}, 'static_view 模块需要更新版本的 XXT'
end

local argchecker = require("argchecker")
local opt_value_ex = argchecker.opt_value_ex
local check_value_ex = argchecker.check_value_ex
local check_value = argchecker.check_value
local bad_arg = argchecker.bad_arg

local objc = require('objc')

local shared_defined = lua_closure_dump(function()
	local objc = require('objc')
	local ffi = require('ffi')

	if CGAffineTransformMakeRotation == nil then
		-- XXT 内置的 ffi 模块似乎无法支持 CGAffineTransform 相关函数
		-- 只能自己在 Lua 层实现
		function CGAffineTransformMakeRotation(angle)
			local result = ffi.new('CGAffineTransform')
			local cosAngle = math.cos(angle)
			local sinAngle = math.sin(angle)
			result.a = cosAngle
			result.b = sinAngle
			result.c = -sinAngle
			result.d = cosAngle
			result.tx = 0
			result.ty = 0
			return result
		end
		function CGAffineTransformRotate(transform, angle)
			local cosAngle = math.cos(angle)
			local sinAngle = math.sin(angle)
			local result = ffi.new('CGAffineTransform')
			result.a = transform.a * cosAngle - transform.b * sinAngle
			result.b = transform.a * sinAngle + transform.b * cosAngle
			result.c = transform.c * cosAngle - transform.d * sinAngle
			result.d = transform.c * sinAngle + transform.d * cosAngle
			result.tx = transform.tx
			result.ty = transform.ty
			return result
		end
	end

	CGRectMake = CGRectMake or function(x, y, width, height)
		local rect = ffi.new("CGRect")
		rect.origin.x = x
		rect.origin.y = y
		rect.size.width = width
		rect.size.height = height
		return rect
	end

	CGSizeMake = CGSizeMake or function(width, height)
		local size = ffi.new("CGSize")
		size.width = width
		size.height = height
		return size
	end

	XXTColor2UIColor = XXTColor2UIColor or function(color)
		return objc.UIColor.colorWithRed(((color & 0xFF0000) >> 16) / 255).green(((color & 0x00FF00) >> 8) / 255).blue((color & 0x0000FF) / 255).alpha(1)()
	end

	XXTColor2UIColorAlpha = XXTColor2UIColorAlpha or function(color)
		return objc.UIColor.colorWithRed(((color & 0xFF0000) >> 16) / 255).green(((color & 0x00FF00) >> 8) / 255).blue((color & 0x0000FF) / 255).alpha(((color & 0xFF000000) >> 24) / 255)()
	end

	UIApp = UIApp or objc.UIApplication.sharedApplication()

	if not oneTimeBlockTie then
		local release_fixed_block = release_fixed_block
		local new_fixed_block_8 = new_fixed_block_8
	
		local oneTimeBlockInternal = function(func, blocks)
			blocks = blocks or {}
			blocks[#blocks + 1] = new_fixed_block_8(function(...)
				dispatch_async('main', function()
					for i=#blocks, 1, -1 do
						release_fixed_block(table.remove(blocks, i))
					end
				end)
				return func(...)
			end)
			return ffi.cast('id', blocks[#blocks])
		end
	
		oneTimeBlockTie = function() -- 创建多个绑定在一起的一次性 block，它只允许其中任意一个 block 被执行一次
			return setmetatable({}, {
				__call = function(self, func)
					return oneTimeBlockInternal(func, self)
				end,
				__index = {
					release = function(self)
						for i=#self, 1, -1 do
							release_fixed_block(table.remove(self, i))
						end
					end,
				},
			})
		end
	
		oneTimeBlock = function(func) -- 创建一个一次性 block，该 block 会在执行一次后被释放
			return oneTimeBlockTie()(func)
		end
	end

	setWindowActive = setWindowActive or function(window)
		if 0 == UIApp.respondsToSelector(objc.SEL("connectedScenes"))() then
			return
		end
		local scenes = UIApp.connectedScenes().allObjects()
		for i, windowScene in objc.ipairs(scenes) do
			if windowScene.activationState() == 0 then
				window.setWindowScene(windowScene)()
				break
			end
		end
	end

	if rootVC == nil then
		_G.objc = objc
		_G.ffi = ffi
		dispatch_sync('main', function()
			local fullScreenFrame = objc.UIScreen.mainScreen().bounds()
			local secureview = require('secureview')
			if secureview then
				sharedSecureView = secureview.create()
				sharedSecureView.setFrame(fullScreenFrame)()
				sharedSecureView.hidden = false
				secureview.set_ignores_hit(sharedSecureView, true)
			end
			if objc.XXTUIToastWindow ~= ffi.nullptr then
				sharedToastWindow = objc.XXTUIToastWindow.alloc().initWithFrame(fullScreenFrame)()
				rootVC = objc.UIViewController.alloc().init()
				rootVC.autorelease()
				sharedToastWindow.setRootViewController(rootVC)()
				sharedToastWindow.setWindowLevel(2052)()
				sharedToastWindow.setHidden(0)()
				setWindowActive(sharedToastWindow)
				sharedToastWindow.addSubview(sharedSecureView)()
			else
				rootVC = UIApp.keyWindow().rootViewController()
				rootVC.view().addSubview(sharedSecureView)()
			end
		end)
	end
end):to_hex('\\x')

local ensure_static_view_toast_service, stop_static_view_toast_service, static_view_service_uuid

local destroy_all_views_code = [[
	dispatch_async('main', function()
		if type(borderMap) == 'table' then
			local k_list = {}
			for k, v in pairs(borderMap) do
				k_list[#k_list + 1] = k
			end
			for _, k in ipairs(k_list) do
				local v = borderMap[k]
				v.setHidden(true)()
				v.removeFromSuperview()
				borderMap[k] = nil
			end
		end
		if type(textLabelMap) == 'table' then
			local k_list = {}
			for k, v in pairs(textLabelMap) do
				k_list[#k_list + 1] = k
			end
			for _, k in ipairs(k_list) do
				local v = textLabelMap[k]
				v.setHidden(true)()
				v.removeFromSuperview()
				textLabelMap[k] = nil
			end
		end
		if type(imageLabelMap) == 'table' then
			local k_list = {}
			for k, v in pairs(imageLabelMap) do
				k_list[#k_list + 1] = k
			end
			for _, k in ipairs(k_list) do
				local v = imageLabelMap[k]
				v.setHidden(true)()
				v.removeFromSuperview()
				imageLabelMap[k] = nil
			end
		end
	end)
]]

if sys.cfversion() < 1673.126 then -- iOS < 13.2
	sys.toast('') sys.toast('', -1)
	local last_sb_pid
	local function sb_pid_refresh()
		local tmp_pid = app.pid_for_bid('com.apple.springboard')
		if last_sb_pid ~= tmp_pid then
			last_sb_pid = tmp_pid
			static_view_service_uuid = nil
		end
	end
	function ensure_static_view_toast_service()
		if not sb_ping() then
			error('iOS 13.2 以下安全模式不能用这个', 3)
		end
		local wait_uuid = utils.gen_uuid()
		app.eval({
			bid = 'com.apple.springboard',
			lua = string.format("proc_put(%q, 'ok')\n", wait_uuid),
		})
		local tm = sys.mtime()
		while sys.mtime() - tm < 5000 and proc_put(wait_uuid, '') == '' do
			sys.msleep(5)
		end
		sb_pid_refresh()
		if not static_view_service_uuid then
			static_view_service_uuid = utils.gen_uuid()
		end
	end
	function toast_service_run_script(func, ...)
		if not sb_ping() then
			error('iOS 13.2 以下安全模式不能用这个', 3)
		end
		local wait_uuid = utils.gen_uuid()
		app.eval({
			bid = 'com.apple.springboard',
			lua = string.format("autoreleasepool(function() load('%s')() local ok,err = pcall(load('%s')) if not ok then sys.log(err) end end) proc_put(%q, 'ok')", shared_defined, lua_closure_dump(func, ...):to_hex('\\x'), wait_uuid),
		})
		local tm = sys.mtime()
		while sys.mtime() - tm < 5000 and proc_put(wait_uuid, '') == '' do
			sys.msleep(5)
		end
		sb_pid_refresh()
		if not static_view_service_uuid then
			static_view_service_uuid = utils.gen_uuid()
		end
	end
	function stop_static_view_toast_service()
		if not sb_ping() then
			error('iOS 13.2 以下安全模式不能用这个', 3)
		end
		local wait_uuid = utils.gen_uuid()
		app.eval({
			bid = 'com.apple.springboard',
			lua = string.format("proc_put(%q, 'ok')\n", wait_uuid)..destroy_all_views_code,
		})
		local tm = sys.mtime()
		while sys.mtime() - tm < 5000 and proc_put(wait_uuid, '') == '' do
			sys.msleep(5)
		end
		static_view_service_uuid = nil
	end
else
    local XXT_SYSTEM_PATH = XXT_SYSTEM_PATH
	local cpdistributed_messaging_center_send_message_and_receive_reply = cpdistributed_messaging_center_send_message_and_receive_reply
	local toast_service_task = nil
	local toast_service_center_name = "xxtouch.toast-service-center"
	function ensure_static_view_toast_service()
		if toast_service_task then
			if toast_service_task:is_running() then
				return
			end
			toast_service_task:wait_until_exit()
			toast_service_task = nil
		end
		static_view_service_uuid = utils.gen_uuid()
		toast_service_center_name = "xxtouch.toast-service-center."..static_view_service_uuid
        local fn = '/tmp/'..toast_service_center_name
        proc_put(toast_service_center_name, '')
        file.writes(fn, lua_closure_dump(function(toast_service_center_name)
            dispatch_async('concurrent', function()
				toast_service_start(toast_service_center_name)
                proc_put(toast_service_center_name, 'ok')
				CFRunLoopRunWithAutoreleasePool()
			end)
			return CFRunLoopRunWithAutoreleasePool()
        end, toast_service_center_name))
		toast_service_task = sys.task(XXT_SYSTEM_PATH..'/XXTUIService.app/XXTUIService', '--ignores-hit', '--file', fn)
        toast_service_task:set_stdin('/dev/null')
        toast_service_task:set_stdout('/dev/null')
        toast_service_task:set_stderr('/dev/null')
		toast_service_task:launch()
		register_atexit('xxtouch.static_view_service_cleanup', function()
			if toast_service_task then
				toast_service_task:kill()
				toast_service_task = nil
			end
            file.remove(fn)
		end)
		repeat
			sys.msleep(30)
		until proc_put(toast_service_center_name, '') ~= ''
        file.remove(fn)
	end
	function stop_static_view_toast_service()
		if toast_service_task then
			toast_service_task:kill()
			toast_service_task = nil
			static_view_service_uuid = nil
		end
	end
	function toast_service_run_script(func, ...)
        local a = toast_service_task
		return cpdistributed_messaging_center_send_message_and_receive_reply(toast_service_center_name, "eval-script", {
			script = string.format("load('%s')() local ok,err = pcall(load('%s')) if not ok then sys.log(err) end", shared_defined, lua_closure_dump(func, ...):to_hex('\\x')),
		})
	end
end

local toast_service_run_script = toast_service_run_script

local function rect_rotate90(x, y, width, height, orientation)
	if orientation < 0 then
		orientation = 0
	elseif orientation > 3 then
		orientation = orientation % 4
	end
	if orientation ~= 0 then
		local left, top, right, bottom = x, y, x + width - 1, y + height - 1
		left, top = screen.unrotate_xy(left, top, orientation)
		right, bottom = screen.unrotate_xy(right, bottom, orientation)
		x = math.min(left, right)
		width = math.abs(right - left) + 1
		y = math.min(top, bottom)
		height = math.abs(bottom - top) + 1
	end
	return x, y, width, height, orientation
end

function new_rectangle_border(...)
	local tab = check_value(1, 'table', ...)
	local width = check_value_ex('new_rectangle_border', 1, '(.width)', 'number', tab.width)
	local height = check_value_ex('new_rectangle_border', 1, '(.height)', 'number', tab.height)
	local x = opt_value_ex('new_rectangle_border', 1, '(.x)', 'number', 0, tab.x)
	local y = opt_value_ex('new_rectangle_border', 1, '(.y)', 'number', 0, tab.y)
	local size = opt_value_ex('new_rectangle_border', 1, '(.size)', 'number', 2, tab.size)
	local color = opt_value_ex('new_rectangle_border', 1, '(.color)', 'number', 0xFFFFFF, tab.color)
    local background_color = opt_value_ex('new_rectangle_border', 1, '(.background_color)', 'number', 0, tab.background_color)
	local duration = opt_value_ex('new_rectangle_border', 1, '(.duration)', 'number', 0, tab.duration)
	local secure = opt_value_ex('new_rectangle_border', 1, '(.secure)', 'boolean', false, tab.secure)
	local orientation = opt_value_ex('new_rectangle_border', 1, '(.orientation)', 'integer', screen.current_init_orien(), tab.orientation)

	ensure_static_view_toast_service()

	local has_been_destroyed = false

	local props = {
		uuid = utils.gen_uuid(),
		service_uuid = static_view_service_uuid,
		size = size,
		color = color or 0xFFFFFF,
        background_color = background_color or 0x000000,
		x = x,
		y = y,
		width = width,
		height = height,
		secure = secure,
		orientation = orientation,
		screen_scale = screen.scale_factor(),
	}

	props.real_x, props.real_y, props.real_width, props.real_height, props.orientation = rect_rotate90(props.x, props.y, props.width, props.height, props.orientation)

	local refresh_the_rectangle_border = function(self, ...)
		local duration = opt_value_ex(':refresh', 1, '(duration)', 'number', 0, ...)
		ensure_static_view_toast_service()
		if has_been_destroyed then
			has_been_destroyed = false
			props.service_uuid = static_view_service_uuid
		end
		toast_service_run_script(function(props, duration)
			borderMap = borderMap or {}
			local objc = require('objc')
			local ffi = require('ffi')
			dispatch_sync('main', function()
				local frame = CGRectMake(props.real_x // props.screen_scale, props.real_y // props.screen_scale, props.real_width // props.screen_scale, props.real_height // props.screen_scale)
				local border
				if borderMap[props.uuid] then
					border = borderMap[props.uuid]
				else
					border = objc.UIView.alloc().init()
					border.autorelease()
					borderMap[props.uuid] = border
					if props.secure then
						local secureview = require('secureview')
						secureview.add_subview(sharedSecureView, border)
					else
						if sharedToastWindow then
							sharedToastWindow.addSubview(border)()
						else
							rootVC.view().addSubview(border)()
						end
					end
				end
				border.setHidden(false)()
				objc.UIView.animateWithDuration(duration).animations(oneTimeBlock(function()
					border.setFrame(frame)()
					if props.background_color == 0 then
						border.backgroundColor = objc.UIColor.clearColor()
					else
						border.backgroundColor = XXTColor2UIColorAlpha(props.background_color)
					end
                    if props.color > 0xFFFFFF then
						border.layer().borderColor = XXTColor2UIColorAlpha(props.color).CGColor()
					else
						border.layer().borderColor = XXTColor2UIColor(props.color).CGColor()
					end
					border.layer().borderWidth = props.size
				end))()
			end)
		end, props, duration)
	end

	local eval = function(self, ...)
		local actions = check_value_ex(':eval', 1, '(actions)', 'function', ...)
		if not has_been_destroyed then
			if props.service_uuid ~= static_view_service_uuid then
				has_been_destroyed = true
				return
			end
			toast_service_run_script(function(actions, props, ...)
				borderMap = borderMap or {}
				local border = borderMap[props.uuid]
				if border then
					local args = {...}
					dispatch_sync('main', function()
						actions(border, table.unpack(args))
					end)
				end
			end, actions, props, ...)
		end
	end

	refresh_the_rectangle_border(nil, duration)

	local destroy_func = function()
		if not has_been_destroyed then
			if props.service_uuid ~= static_view_service_uuid then
				has_been_destroyed = true
				return
			end
			has_been_destroyed = true
			toast_service_run_script(function(props)
				borderMap = borderMap or {}
				if borderMap[props.uuid] then
					dispatch_sync('main', function()
						borderMap[props.uuid].setHidden(true)()
						borderMap[props.uuid].removeFromSuperview()
						borderMap[props.uuid] = nil
					end)
				end
			end, props)
		end
	end

	local setter_type = {
		size = 'number',
		color = 'number',
        background_color = 'number',
		x = 'number',
		y = 'number',
		width = 'number',
		height = 'number',
	}

	return setmetatable({}, {
		__index = function(self, field)
			field = string.lower(field)
			if field == 'destroy' then
				return destroy_func
			elseif field == 'refresh' then
				return refresh_the_rectangle_border
			elseif field == 'eval' then
				return eval
			elseif field == 'uuid' or field == 'secure' or setter_type[field] then
				return props[field]
			end
		end,
		__newindex = function(self, field, value)
			field = string.lower(field)
			if setter_type[field] and type(value) == setter_type[field] then
				props[field] = value
				props.real_x, props.real_y, props.real_width, props.real_height, props.orientation = rect_rotate90(props.x, props.y, props.width, props.height, props.orientation)
			else
				error('The rectangle_border object has no such (' .. type(value) ..') field named `' .. field .. '`', 2)
			end
		end,
		__gc = destroy_func, -- 自动回收销毁矩形边框
		__tostring = function()
			return string.format('rectangle_border: (%s)', props.uuid)
		end,
	})
end

function new_text_label(...)
	local tab = check_value(1, 'table', ...)
	local text = check_value_ex('new_text_label', 1, '(.text)', 'string', tab.text)
	local x = opt_value_ex('new_text_label', 1, '(.x)', 'number', 0, tab.x)
	local y = opt_value_ex('new_text_label', 1, '(.y)', 'number', 0, tab.y)
	local font_name = opt_value_ex('new_text_label', 1, '(.font_name)', 'string', 'Helvetica', tab.font_name)
	local font_size = opt_value_ex('new_text_label', 1, '(.font_size)', 'number', 12, tab.font_size)
	local text_color = opt_value_ex('new_text_label', 1, '(.text_color)', 'number', 0xFFFFFF, tab.text_color)
    local background_color = opt_value_ex('new_text_label', 1, '(.background_color)', 'number', 0, tab.background_color)
	local duration = opt_value_ex('new_text_label', 1, '(.duration)', 'number', 0, tab.duration)
	local secure = opt_value_ex('new_text_label', 1, '(.secure)', 'boolean', false, tab.secure)
	local orientation = opt_value_ex('new_text_label', 1, '(.orientation)', 'integer', screen.current_init_orien(), tab.orientation)

	ensure_static_view_toast_service()

	local has_been_destroyed = false

	local props = {
		uuid = utils.gen_uuid(),
		service_uuid = static_view_service_uuid,
		text = text,
		font_size = font_size,
		font_name = font_name,
		text_color = text_color or 0xFFFFFF,
        background_color = background_color or 0x000000,
		x = x,
		y = y,
		secure = secure,
		orientation = orientation,
		screen_scale = screen.scale_factor(),
	}

	if type(autoreleasewrap) ~= 'function' then
		autoreleasewrap = function(...)
			local args = {...}
			return function() return autoreleasepool(table.unpack(args)) end
		end
	end

	local compute_label_size = autoreleasewrap(function()
		local CGSizeMake = function(width, height)
			local size = ffi.new("CGSize")
			size.width = width
			size.height = height
			return size
		end
		local text = objc.toobj(props.text)
		local font = objc.UIFont.fontWithName(props.font_name).size(props.font_size)()
		if font == ffi.nullptr then
			font = objc.UIFont.fontWithName('Helvetica').size(props.font_size)()
			props.font_name = 'Helvetica'
		end
		local size = text.sizeWithFont(font).constrainedToSize(CGSizeMake(0xFFFFFFFF, 0xFFFFFFFF)).lineBreakMode(0)()
		props.width = size.width * props.screen_scale
		props.height = size.height * props.screen_scale
		props.real_x, props.real_y, props.real_width, props.real_height, props.orientation = rect_rotate90(props.x, props.y, props.width, props.height, props.orientation)
	end)

	local refresh_the_text_label = function(self, ...)
		local duration = opt_value_ex(':refresh', 1, '(duration)', 'number', 0, ...)
		ensure_static_view_toast_service()
		if has_been_destroyed then
			has_been_destroyed = false
			props.service_uuid = static_view_service_uuid
		end
		toast_service_run_script(function(props, duration)
			textLabelMap = textLabelMap or {}
			local objc = require('objc')
			local ffi = require('ffi')
			local font = objc.UIFont.fontWithName(props.font_name).size(props.font_size)()
			dispatch_sync('main', function()
				local frame = CGRectMake(props.real_x // props.screen_scale, props.real_y // props.screen_scale, props.real_width // props.screen_scale, props.real_height // props.screen_scale)
				local textLabel
				if textLabelMap[props.uuid] then
					textLabel = textLabelMap[props.uuid]
				else
					textLabel = objc.UILabel.alloc().init()
					textLabel.autorelease()
					textLabelMap[props.uuid] = textLabel
					if props.secure then
						local secureview = require('secureview')
						secureview.add_subview(sharedSecureView, textLabel)
					else
						if sharedToastWindow then
							sharedToastWindow.addSubview(textLabel)()
						else
							rootVC.view().addSubview(textLabel)()
						end
					end
				end
				textLabel.setHidden(false)()
				objc.UIView.animateWithDuration(duration).animations(oneTimeBlock(function()
					if props.orientation == 1 then
						textLabel.transform = CGAffineTransformMakeRotation(90 * (math.pi / 180.0))
					elseif props.orientation == 2 then
						textLabel.transform = CGAffineTransformMakeRotation(270 * (math.pi / 180.0))
					elseif props.orientation == 3 then
						textLabel.transform = CGAffineTransformMakeRotation(180 * (math.pi / 180.0))
					end
					textLabel.setFrame(frame)()
                    if props.background_color == 0 then
                        textLabel.backgroundColor = objc.UIColor.clearColor()
                    else
                        textLabel.backgroundColor = XXTColor2UIColorAlpha(props.background_color)
                    end
					textLabel.font = font
                    if props.text_color > 0xFFFFFF then
                        textLabel.textColor = XXTColor2UIColorAlpha(props.text_color)
                    else
                        textLabel.textColor = XXTColor2UIColor(props.text_color)
                    end
					textLabel.lineBreakMode = 0 -- NSLineBreakByWordWrapping
					textLabel.textAlignment = 0 -- NSTextAlignmentLeft
					textLabel.text = props.text
				end))()
			end)
		end, props, duration)
	end

	local eval = function(self, ...)
		local actions = check_value_ex(':eval', 1, '(actions)', 'function', ...)
		if not has_been_destroyed then
			if props.service_uuid ~= static_view_service_uuid then
				has_been_destroyed = true
				return
			end
			toast_service_run_script(function(actions, props, ...)
				textLabelMap = textLabelMap or {}
				local textLabel = textLabelMap[props.uuid]
				if textLabel then
					local args = {...}
					dispatch_sync('main', function()
						actions(textLabel, table.unpack(args))
					end)
				end
			end, actions, props, ...)
		end
	end

	compute_label_size()
	refresh_the_text_label(nil, duration)

	local destroy_func = function()
		if not has_been_destroyed then
			if props.service_uuid ~= static_view_service_uuid then
				has_been_destroyed = true
				return
			end
			has_been_destroyed = true
			toast_service_run_script(function(props)
				textLabelMap = textLabelMap or {}
				if textLabelMap[props.uuid] then
					dispatch_sync('main', function()
						textLabelMap[props.uuid].setHidden(true)()
						textLabelMap[props.uuid].removeFromSuperview()
						textLabelMap[props.uuid] = nil
					end)
				end
			end, props)
		end
	end

	local setter_type = {
		text = 'string',
		font_name = 'string',
		font_size = 'number',
		text_color = 'number',
        background_color = 'number',
		x = 'number',
		y = 'number',
		orientation = 'number',
	}

	local setter_actions = {
		text = compute_label_size,
		font_name = compute_label_size,
		font_size = compute_label_size,
		x = compute_label_size,
		y = compute_label_size,
		orientation = compute_label_size,
	}

	return setmetatable({}, {
		__index = function(self, field)
			field = string.lower(field)
			if field == 'destroy' then
				return destroy_func
			elseif field == 'refresh' then
				return refresh_the_text_label
			elseif field == 'eval' then
				return eval
			elseif field == 'uuid' or field == 'secure' or field == 'width' or field == 'height' or setter_type[field] then
				return props[field]
			end
		end,
		__newindex = function(self, field, value)
			field = string.lower(field)
			if setter_type[field] and type(value) == setter_type[field] then
				props[field] = value
				if setter_actions[field] then
					setter_actions[field]()
				end
			else
				error('The text_label object has no such (' .. type(value) ..') field named `' .. field .. '`', 2)
			end
		end,
		__gc = destroy_func, -- 自动回收销毁
		__tostring = function()
			return string.format('text_label: (%s)', props.uuid)
		end,
	})
end

function new_image_label(...)
	local tab = check_value(1, 'table', ...)
	local img = check_value_ex('new_image_label', 1, '(.image)', 'userdata', tab.image)
	if not image.is(img) then
		bad_arg('new_image_label', 1, '(.image)', 'image_object', type(img))
		return
	end
	local width = check_value_ex('new_image_label', 1, '(.width)', 'number', tab.width)
	local height = check_value_ex('new_image_label', 1, '(.height)', 'number', tab.height)
	local x = opt_value_ex('new_image_label', 1, '(.x)', 'number', 0, tab.x)
	local y = opt_value_ex('new_image_label', 1, '(.y)', 'number', 0, tab.y)
    local background_color = opt_value_ex('new_image_label', 1, '(.background_color)', 'number', 0, tab.background_color)
	local duration = opt_value_ex('new_image_label', 1, '(.duration)', 'number', 0, tab.duration)
	local secure = opt_value_ex('new_image_label', 1, '(.secure)', 'boolean', false, tab.secure)
	local orientation = opt_value_ex('new_image_label', 1, '(.orientation)', 'integer', screen.current_init_orien(), tab.orientation)

	ensure_static_view_toast_service()

	local the_image = img:copy()

	local props = {
		uuid = utils.gen_uuid(),
		service_uuid = static_view_service_uuid,
		image_data = the_image:png_data(),
		x = x,
		y = y,
        background_color = background_color or 0x000000,
		width = width,
		height = height,
		secure = secure,
		orientation = orientation,
		screen_scale = screen.scale_factor(),
	}

	props.real_x, props.real_y, props.real_width, props.real_height, props.orientation = rect_rotate90(props.x, props.y, props.width, props.height, props.orientation)

	local refresh_the_image_label = function(self, ...)
		local duration = opt_value_ex(':refresh', 1, '(duration)', 'number', 0, ...)
		ensure_static_view_toast_service()
		if has_been_destroyed then
			has_been_destroyed = false
			props.service_uuid = static_view_service_uuid
		end
		toast_service_run_script(function(props, duration)
			imageLabelMap = imageLabelMap or {}
			local objc = require('objc')
			local ffi = require('ffi')
			dispatch_sync('main', function()
				local frame = CGRectMake(props.real_x // props.screen_scale, props.real_y // props.screen_scale, props.real_width // props.screen_scale, props.real_height // props.screen_scale)
				local image_data = objc.NSData.dataWithBytes(ffi.cast('const char *', props.image_data)).length(#(props.image_data))()
				local image = objc.UIImage.imageWithData(image_data)()
				local imageLabel
				if imageLabelMap[props.uuid] then
					imageLabel = imageLabelMap[props.uuid]
				else
					imageLabel = objc.UIImageView.alloc().init()
					imageLabel.autorelease()
					imageLabelMap[props.uuid] = imageLabel
					if props.secure then
						local secureview = require('secureview')
						secureview.add_subview(sharedSecureView, imageLabel)
					else
						if sharedToastWindow then
							sharedToastWindow.addSubview(imageLabel)()
						else
							rootVC.view().addSubview(imageLabel)()
						end
					end
				end
				imageLabel.setImage(image)()
				imageLabel.setHidden(false)()
				objc.UIView.animateWithDuration(duration).animations(oneTimeBlock(function()
					if props.orientation == 1 then
						imageLabel.transform = CGAffineTransformMakeRotation(90 * (math.pi / 180.0))
					elseif props.orientation == 2 then
						imageLabel.transform = CGAffineTransformMakeRotation(270 * (math.pi / 180.0))
					elseif props.orientation == 3 then
						imageLabel.transform = CGAffineTransformMakeRotation(180 * (math.pi / 180.0))
					end
					imageLabel.setContentMode(2)() -- UIViewContentModeScaleAspectFill
					imageLabel.setFrame(frame)()
					if props.background_color == 0 then
						imageLabel.backgroundColor = objc.UIColor.clearColor()
                    else
                        imageLabel.backgroundColor = XXTColor2UIColorAlpha(props.background_color)
                    end
				end))()
			end)
		end, props, duration)
	end

	local eval = function(self, ...)
		local actions = check_value_ex(':eval', 1, '(actions)', 'function', ...)
		if not has_been_destroyed then
			if props.service_uuid ~= static_view_service_uuid then
				has_been_destroyed = true
				return
			end
			toast_service_run_script(function(actions, props, ...)
				imageLabelMap = imageLabelMap or {}
				local imageLabel = imageLabelMap[props.uuid]
				if imageLabel then
					local args = {...}
					dispatch_sync('main', function()
						actions(imageLabel, table.unpack(args))
					end)
				end
			end, actions, props, ...)
		end
	end

	refresh_the_image_label(nil, duration)

	local has_been_destroyed = false

	local destroy_func = function()
		if not has_been_destroyed then
			if props.service_uuid ~= static_view_service_uuid then
				has_been_destroyed = true
				return
			end
			has_been_destroyed = true
			toast_service_run_script(function(props)
				imageLabelMap = imageLabelMap or {}
				if imageLabelMap[props.uuid] then
					dispatch_sync('main', function()
						imageLabelMap[props.uuid].setHidden(true)()
						imageLabelMap[props.uuid].removeFromSuperview()
						imageLabelMap[props.uuid] = nil
					end)
				end
			end, props)
		end
	end

	local setter_type = {
		x = 'number',
		y = 'number',
		width = 'number',
		height = 'number',
        background_color = 'number',
		orientation = 'number',
	}

	return setmetatable({}, {
		__index = function(self, field)
			field = string.lower(field)
			if field == 'destroy' then
				return destroy_func
			elseif field == 'refresh' then
				return refresh_the_image_label
			elseif field == 'eval' then
				return eval
			elseif field == 'image' then
				return the_image:copy()
			elseif field == 'uuid' or field == 'secure' or setter_type[field] then
				return props[field]
			end
		end,
		__newindex = function(self, field, value)
			field = string.lower(field)
			if setter_type[field] and type(value) == setter_type[field] then
				if field == 'orientation' then
					if value < 0 then
						value = 0
					elseif value > 3 then
						value = value % 4
					end
				end
				props[field] = value
				props.real_x, props.real_y, props.real_width, props.real_height, props.orientation = rect_rotate90(props.x, props.y, props.width, props.height, props.orientation)
			elseif field == 'image' and image.is(value) then
				the_image = value:copy()
				props.image_data = the_image:png_data()
			else
				error('The image_label object has no such (' .. type(value) ..') field named `' .. field .. '`', 2)
			end
		end,
		__gc = destroy_func, -- 自动回收销毁
		__tostring = function()
			return string.format('image_label: (%s)', props.uuid)
		end,
	})
end

local function kill_toast_service()
	if type(stop_static_view_toast_service) == 'function' then
		stop_static_view_toast_service()
	end
end

local function edges_to_rect(left, top, right, bottom)
	return {x = left, y = top, width = right - left, height = bottom - top}
end

local function rect_to_edges(rect)
	return rect.x, rect.y, rect.x + rect.width, rect.y + rect.height
end

return {
	new_text_label = new_text_label,
	new_image_label = new_image_label,
	new_rectangle_border = new_rectangle_border,
	edges_to_rect = edges_to_rect,
	rect_to_edges = rect_to_edges,
	kill_toast_service = kill_toast_service,
	init = ensure_static_view_toast_service,
	remove_all_views = kill_toast_service,
	_VERSION = "0.2.3",
	_AUTHOR = "havonz",
}
