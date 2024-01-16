--[[

	X.X.T.自动化创建脚本向导.lua

	Created by 苏泽 on 22-09-28.
	Copyright (c) 2022年 苏泽. All rights reserved.

	一种编程去代码化方案
	用户可以使用该脚本以近似录制的方式实现判断较为简单的脚本而不用编写代码
	它使用触发器模式实现
	
	触发器模式解释：
		通常我们录制的模拟操作的脚本是这样的
			执行第一行
			执行第二行
			...
			执行第 N 行
		这种录制脚本总是从上到下逐行执行，无法处理意外情形
	
		触发器模式下是这样的
			当事件发生时 --> 执行动作
		在这种模式下，通常脚本是不会自动结束的
		它需要用户设置显式规则来结束脚本，这样保证了脚本在完成用户设定目标之前一直是运行着的
		当然具体能否达成用户设定目标依然是取决于触发器规则的合理性
	
	运行脚本试试吧！
	
	未得原作者许可，可以用于商业用途！

--]]

package.preload["XXTDo"] = function(...)
--[[
	XXTDo 基于界面匹配的脚本框架
	模块输出函数
	------------------------------------
	XXTDo.runloop   主函数，用于处理点色表列表，一个参数，参数为表
	用法：
		参数结构说明
		{
			name        = [文本型，当前界面列表名，必要参数],
			csim        = [实数型，可选，界面列表全局相似度，不填默认取 90],
			interval_ms = [实数型，可选，每轮检测到下轮检测开始的间隔毫秒数，默认 100],
			log         = [函数型，可选，日志处理函数，函数原型：log(日志文本) 无返回，默认空函数（丢弃所有日志）],
			log_date    = [布尔型，可选，日志信息是否额外附带日期时间，默认 否],
			error       = [函数型，可选，错误处理函数，函数原型：error(错误文本) 无返回，默认 error（抛出错误）],
			filter      = [函数型，可选，界面过滤器函数，函数原型：filter(表型界面信息, 范围0~100相似度) 返回假表示不通过，默认 screen.is_colors],
			pre_run     = [函数型，可选，每轮检测前需要执行的函数，函数原型：pre_run(整个界面列表) 无返回，默认空函数],
			post_run    = [函数型，可选，每轮检测后需要执行的函数，函数原型：post_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 无返回，默认空函数],
			else_run    = [函数型，可选，每轮所有界面都不匹配的的情况下需要执行的函数，在 post_run 之前执行，函数原型：else_run(整个界面列表) 无返回，默认空函数],
			timeout_s   = [实数型，可选，任意界面或不匹配超时时间，单位秒，默认 0 不超时],
			timeout_run = [函数型，可选，任意界面超时后的回调函数，函数原型：timeout_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 这个函数可以按需显式返回 false 或 'failed' 表示处理超时失败不重置超时计时器，默认空函数返回失败],
			enter       = [函数型，可选，进入界面循环之前会调用该函数一次，函数原型：enter(整个界面列表) 无返回，默认空函数],
			finally     = [函数型，可选，进入界面循环之前会调用该函数一次，函数原型：finally(整个界面列表[, XXTDo.breakloop 的参数列表]) 无返回，但它可以再次调用 XXTDo.breakloop 来更改 runloop 的返回值，默认空函数],
			{
				name        = [文本型，可选，当前匹配的界面名，默认 ""],
				csim        = [实数型，可选，当前界面相似度，不填默认取界面列表全局相似度],
				run         = [函数型，匹配到当前界面后需要执行的函数，函数原型：run(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表) 这个函数可以按需显式返回 false 或 'failed' 表示匹配该界面失败],
				timeout_s   = [实数型，可选，当前界面停留超时时间，单位秒，默认 0 不超时],
				timeout_run = [函数型，可选，当前界面超时后的回调函数，函数原型：timeout_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 这个函数可以按需显式返回 false 或 'failed' 表示处理超时失败不重置超时计时器，默认取界面列表全局 timeout_run],
				group       = [表型，可选，多组点色列表数组，其中任何一组匹配都表示该界面匹配],
				-- 以下是点色列表数组
				{x*, y*, color*},
				{x*, y*, color*},
				{x*, y*, color*},
				...
			},
			{
				name        = [文本型，可选，当前匹配的界面名，默认 ""],
				csim        = [实数型，可选，当前界面相似度，不填默认取界面列表全局相似度],
				run         = [函数型，匹配到当前界面后需要执行的函数，函数原型：run(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表) 这个函数可以按需显式返回 false 或 'failed' 表示匹配该界面失败],
				timeout_s   = [实数型，可选，当前界面停留超时时间，单位秒，默认 0 不超时],
				timeout_run = [函数型，可选，任意界面超时后的回调函数，函数原型：timeout_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 这个函数可以按需显式返回 false 或 'failed' 表示处理超时失败不重置超时计时器，默认取界面列表全局 timeout_run],
				group       = [表型，可选，多组点色列表数组，其中任何一组匹配都表示该界面匹配],
				-- 以下是点色列表数组
				{x*, y*, color*},
				{x*, y*, color*},
				{x*, y*, color*},
				...
			},
			...
		}

	------------------------------------
	XXTDo.breakloop 跳出函数，用于从 runloop 中跳出，参数可选，它的参数就是 XXTDo.runloop 的返回值
	该函数在非 finally 函数中调用之后，界面循环中的 finally 动作函数会触发，它的参数会传递给 finally，可以在 runloop 内的除界面过滤器函数的任何回调（也包括 enter 和 finally）中调用，不要在 loop 外调用
	用法：
		XXTDo.breakloop(...)

	------------------------------------
	XXTDo.config    持久化配置函数，用于持久化存储一些简单值（数字、字符串、布尔值），脚本结束之后这些值不会消失，下次启动脚本可继续读取
	用法：
		XXTDo.config('配置名字')         -- 关联一个配置
		XXTDo.config('配置名字').clear() -- 关联一个配置，并初始化（清空原有所有值）
		XXTDo.config.value = 1         -- 将当前配置的中的 value 键对应的值设为 1
		a = XXTDo.config.value         -- 读取当前配置 value 键所对应的值

		cfg = XXTDo.config('配置名字')
		cfg.clear()
		cfg.value = 1
		a = cfg.value

	------------------------------------
--]]

local _ENV = table.deep_copy(_ENV)
local _M = {}

_M._VERSION = '0.5'

local breakloop_tips = '请不要在界面过滤器函数或 XXTDo.runloop 外部执行 XXTDo.breakloop '..string.sub(string.sha256(string.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 1000)), 7, 16)

local function _dummy()
end
local function _dumpvarshort(v)
	return json.encode(table.load_string(table.deep_print(v)))
end
local function _isbreakerr(errmsg)
	return type(errmsg) == 'string' and #(string.split(errmsg, breakloop_tips)) > 1
end
local function _datetime(tm)
	return os.date('%Y-%m-%d %H:%M:%S', tm)
end

local lfs = require('lfs')

-- 简单数据存取实现
local homedir = '/private/var/mobile/Media/1ferver/'
local cfgfiledir = homedir..'/uicfg/'
lfs.mkdir(homedir)
lfs.mkdir(cfgfiledir)
local function _conf_meta_load(self, key)
	local cfgfilename = cfgfiledir..'/'..rawget(self, 'cfgname')..'.XXTDoConfig'
	local tab = json.decode(file.reads(cfgfilename) or '{}') or {}
	return tab[key]
end
local function _conf_meta_save(self, key, value)
	local cfgfilename = cfgfiledir..'/'..rawget(self, 'cfgname')..'.XXTDoConfig'
	local tab = json.decode(file.reads(cfgfilename) or '{}') or {}
	tab[key] = value
	file.writes(cfgfilename, json.encode(table.load_string(table.deep_print(tab))))
	return value
end
local function _conf_meta_tostring(self)
	local cfgfilename = cfgfiledir..'/'..rawget(self, 'cfgname')..'.XXTDoConfig'
	local str = file.reads(cfgfilename) or '{}'
	local tab = json.decode(str)
	if tab then
		return string.format('<XXTDo.config %q>: %s', rawget(self, 'cfgname'), str)
	else
		return string.format('<XXTDo.config %q>: %s', rawget(self, 'cfgname'), '{}')
	end
end
local _confmeta = {
	__call = function(self, name)
		name = type(name) == 'string' and name or '_____config_____'
		local ret = {
			clear = function()
				local cfgfilename = cfgfiledir..'/'..name..'.XXTDoConfig'
				os.remove(cfgfilename)
			end,
		}
		rawset(self, 'cfgname', name)
		rawset(ret, 'cfgname', name)
		setmetatable(ret, {
			__index = _conf_meta_load,
			__newindex = _conf_meta_save,
			__tostring = _conf_meta_tostring,
		})
		return ret
	end,
	__index = _conf_meta_load,
	__newindex = _conf_meta_save,
	__tostring = _conf_meta_tostring,
}
_M.config = {}
setmetatable(_M.config, _confmeta)

local _TMP = {}

-- 跳出循环实现
function _M.breakloop(...)
	local argv = {...}
	_TMP.unpack_breakloop_results = function()
		return table.unpack(argv)
	end
	error(breakloop_tips, 2)
end

-- 主功能跑环实现
function _M.runloop(orig_uilist)
	if type(orig_uilist) ~= 'table' then
		error(string.format('给 XXTDo.runloop 传递的参数不合法\n\n%s', debug.traceback()), 2)
	end
	local uilist = table.deep_copy(orig_uilist)
	local _L = {}
	_L.log = _dummy
	_L.error = error
	_L.filter = screen.is_colors
	_L.interval_ms = 100
	_L.timeout_s = 0
	_L.timeout_run = _dummy
	_L.loopname = type(uilist.name) == 'string' and uilist.name or nil
	if type(_L.loopname) ~= 'string' then
		error(string.format('给 XXTDo.runloop 参数 #1 需要至少包含 name 字段的表\n例如 {name = "一个名字"}\n\n%s', debug.traceback()), 2)
	end
	local _log_datetime_gen
	if type(uilist.log_date) == 'boolean' and uilist.log_date then
		_log_datetime_gen = function()
			return string.format('[%s] ', _datetime())
		end
	else
		_log_datetime_gen = function()
			return ''
		end
	end
	local function _callifexists(UI, func, ...)
		if (type(func) == 'function') then
			local noerr, errmsg = pcall(func, ...)
			if (not noerr) then
				if _isbreakerr(errmsg) then
					return 'breakloop'
				end
				_L.error(_dumpvarshort{
					error = errmsg,
					time = _datetime(),
					UI = UI,
				}, 3)
				return 'failed' -- 如果回调抛出错误脚本却没结束，则返回 failed
			else
				if errmsg == nil or errmsg == true or errmsg == 'success' then
					return 'success' -- 界面动作返回 nil 或 true 或 'success' 表示匹配成功，否则表示匹配失败，不中断当前轮匹配
				else
					return 'failed'
				end
			end
		else
			return 'failed'
		end
	end
	local function _filter_wrap(filter)
		return function(...)
			local noerr, errmsg = pcall(filter, ...)
			if (not noerr) then
				if _isbreakerr(errmsg) then
					_L.error(_dumpvarshort{
						error = string.format("尝试在界面循环 %s 的 filter（过滤器）函数使用 XXTDo.breakloop\nfilter（过滤器）函数中不允许使用 XXTDo.breakloop", _L.loopname),
						time = _datetime(),
						UI = 'filter',
					}, 3)
				else
					_L.error(_dumpvarshort{
						error = string.format("界面循环 %s 的 filter（过滤器）函数发生运行期错误\n%s", _L.loopname, errmsg),
						time = _datetime(),
						UI = 'filter',
					}, 3)
				end
			else
				return errmsg
			end
		end
	end
	if (type(uilist.log) == 'function') then
		_L.log = uilist.log
	end
	if (type(uilist.error) == 'function') then
		_L.error = uilist.error
	end
	if (type(uilist.founder) == 'function') then
		_L.filter = uilist.founder
	end
	if (type(uilist.filter) == 'function') then
		_L.filter = uilist.filter
	end
	_L.filter = _filter_wrap(_L.filter)
	if (type(uilist.timeout_run) == 'function') then
		_L.timeout_run = uilist.timeout_run
	end
	if (type(uilist.timeout_s) == 'number') then
		_L.timeout_s = uilist.timeout_s
	end
	if (type(uilist.interval_ms) == 'number') then
		_L.interval_ms = uilist.interval_ms
	end
	if (type(uilist.enter) == 'function') then
		_L.enter = uilist.enter
	end
	if (type(uilist.finally) == 'function') then
		_L.finally = uilist.finally
	end
	local _submeta = {
		__index = function(self, key)
			if (type(key) == 'string') then
				return uilist[key]
			else
				return nil
			end
		end
	}
	for _,ui in ipairs(uilist) do
		setmetatable(ui, _submeta)
	end
	_L.timer_begin_time    = os.time()
	_L.timer_last_found    = -1 -- -1 表示没匹配任何界面
	_L.timer_current_found = -1 -- -1 表示没匹配任何界面
	local function to_finally()
		local unpack_breakloop_results = _TMP.unpack_breakloop_results
		if _callifexists('finally', uilist.finally, uilist, unpack_breakloop_results()) == 'breakloop' then
			_L.log(string.format('%s从 finally 跳出界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
			unpack_breakloop_results = _TMP.unpack_breakloop_results
		end
		if type(unpack_breakloop_results) == 'function' then
			return unpack_breakloop_results()
		end
	end
	_L.log(string.format('%s开始进入界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
	if (_callifexists('enter', uilist.enter, uilist) == 'breakloop') then
		_L.log(string.format('%s从 enter 跳出界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
		return to_finally()
	end
	while (true) do
		local _current_interval_ms = type(uilist.interval_ms) == 'number' and uilist.interval_ms or _L.interval_ms
		screen.keep()
		sys.msleep(2)
		if (_callifexists('pre_run', uilist.pre_run, uilist) == 'breakloop') then
			_L.log(string.format('%s从 pre_run 跳出界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
			return to_finally()
		end
		local foundui = nil
		for idx, currentui in ipairs(uilist) do
			if type(currentui) == 'table' and (#currentui > 0 or (type(currentui.group) == 'table' and #(currentui.group) > 0)) then
				local found = false
				local subindex = -1
				if type(currentui.group) == 'table' and #(currentui.group) > 0 then
					for subidx, subui in ipairs(currentui.group) do
						if type(subui) == 'table' and #subui > 0 then
							if (_L.filter(subui, tonumber(subui.csim) or tonumber(currentui.csim) or 90)) then
								subindex = subidx
								found = true
							end
						end
					end
				end
				if (found or (#currentui > 0 and _L.filter(currentui, tonumber(currentui.csim) or 90))) then
					currentui.name = type(currentui.name) == 'string' and currentui.name or ''
					local idxstr
					if subindex > 0 then
						idxstr = string.format('[%d][%d]', idx, subindex)
					else
						idxstr = string.format('[%d]', idx)
					end
					_L.log(string.format('%s匹配 %s %s %q', _log_datetime_gen(), _L.loopname, idxstr, currentui.name))
					local runstat = _callifexists({ui = currentui, index = idx, subindex = subindex}, currentui.run, currentui, idx, uilist)
					if (runstat == 'breakloop') then
						_L.log(string.format('%s从 %s %q 跳出界面匹配循环 %s', _log_datetime_gen(), idxstr, currentui.name, _L.loopname))
						return to_finally()
					elseif (runstat == 'success') then
						_current_interval_ms = type(currentui.interval_ms) == 'number' and currentui.interval_ms or _L.interval_ms
						foundui = {ui = currentui, index = idx, subindex = subindex}
						_L.timer_current_found = idx
						if (_L.timer_current_found ~= _L.timer_last_found) then
							_L.timer_last_found = _L.timer_current_found
							_L.timer_begin_time = os.time()
						elseif ((tonumber(currentui.timeout_s) or 0) > 0 and os.difftime(os.time(), _L.timer_begin_time) > tonumber(currentui.timeout_s)) then
							local timeout_run = _L.timeout_run
							if type(currentui.timeout_run) == 'function' then
								timeout_run = currentui.timeout_run
							end
							_L.log(string.format('%s从 %s %s %q 超时', _log_datetime_gen(), _L.loopname, idxstr, currentui.name))
							local timeout_run_results = _callifexists({ui = currentui, index = idx, subindex = subindex}, timeout_run, uilist, foundui) 
							_L.log(string.format('%s%s 超时回调返回 %s ', _log_datetime_gen(), _L.loopname, timeout_run_results))
							if (timeout_run_results == 'success') then
								_L.timer_begin_time = os.time()
							elseif (timeout_run_results == 'breakloop') then
								_L.log(string.format('%s从 %s %q 超时回调跳出界面匹配循环 %s', _log_datetime_gen(), idxstr, currentui.name, _L.loopname))
								return to_finally()
							end
						end
						break
					end
				elseif #uilist == idx then
					_L.timer_current_found = -1
					if (_callifexists('else_run', uilist.else_run, uilist) == 'breakloop') then
						_L.log(string.format('%s从 else_run 跳出界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
						return to_finally()
					end
				end
			else
				_L.error(_dumpvarshort{
					error = string.format('界面列表 %s 中编号为 [%d] 的界面不是一个合法的界面', _L.loopname, idx),
					time = _datetime(),
					UI = currentui,
				}, 2)
			end
		end
		if (_callifexists('post_run', uilist.post_run, uilist, foundui) == 'breakloop') then
			_L.log(string.format('%s从 post_run 跳出界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
			return to_finally()
		end
		if (_L.timer_current_found ~= _L.timer_last_found) then
			_L.timer_last_found = _L.timer_current_found
			_L.timer_begin_time = os.time()
		elseif (_L.timeout_s > 0 and os.difftime(os.time(), _L.timer_begin_time) > _L.timeout_s) then
			_L.log(string.format('%s%s 未匹配任何界面超时', _log_datetime_gen(), _L.loopname))
			local timeout_run_results = _callifexists('global_timeout_run', _L.timeout_run, uilist, foundui)
			_L.log(string.format('%s%s 超时回调返回 %s', _log_datetime_gen(), _L.loopname, timeout_run_results))
			if (timeout_run_results == 'success') then
				_L.timer_begin_time = os.time()
			elseif (timeout_run_results == 'breakloop') then
				_L.log(string.format('%s从 未匹配任何界面的全局 超时回调跳出界面匹配循环 %s', _log_datetime_gen(), _L.loopname))
				return to_finally()
			end
		end
		sys.msleep(_current_interval_ms)
	end
end

return _M
end

if type(dialog) == 'table' then
	dialog.engine = 'xui'
	-- dialog.engine = 'webview'
end

local scr_w, scr_h = screen.size()

local factor = screen.scale_factor() -- 设备分辨率缩放，通常都是 2x 的了，plus 系列似乎是 3x

local event_dispatch_map = {}

function set_event_callback(eventname, callback)
	event_dispatch_map[eventname] = callback
end

local start_action_list = {}
local ui_action_list = {}

function ms_add_start_action(action)
	if action then
		sys.toast('脚本刚开始运行动作已添加')
		--sys.toast(table.concat({'添加脚本刚开始运行动作\n\n', action}, '\n'))
		start_action_list[#start_action_list + 1] = action
	end
end

function ms_add_ui_action(action)
	if action then
		sys.toast('界面判断动作已添加')
		-- sys.toast(table.concat({'添加界面判断动作\n\n', action}, '\n'))
		ui_action_list[#ui_action_list + 1] = action
	end
end

function ms_make(filename)
	if not package.preload["XXTDo"] then
		package.preload["XXTDo"] = loadfile('/var/mobile/Media/1ferver/lua/XXTDo.lua')
	end
	local xxtdobytes = string.dump(package.preload["XXTDo"])
	local script_flow = {}
	script_flow[#script_flow + 1] = [[
package.preload["XXTDo"] = load("]]..(xxtdobytes:to_hex():gsub('..', function(c) return '\\x'..c end))..[[")
local XXTDo = require('XXTDo')
local _init_func_list = {}
local function add_init_func(func)
	_init_func_list[#_init_func_list + 1] = func
end
local _ui_actions = {}
local function add_ui_action(uiaction)
	_ui_actions[#_ui_actions + 1] = uiaction
end
local function set_ui_name(uiname)
	_ui_actions.name = uiname
end
function __main__()
	for _,func in ipairs(_init_func_list) do
		thread.dispatch(func)
	end
	if #_ui_actions > 0 then
		XXTDo.runloop(_ui_actions)
	end
end
]]
	for _, action in ipairs(start_action_list) do
		script_flow[#script_flow + 1] = string.format('add_init_func(function()\n%s\nend)', action)
	end
	for _, uiaction in ipairs(ui_action_list) do
		script_flow[#script_flow + 1] = string.format('add_ui_action(%s)', uiaction)
	end
	script_flow[#script_flow + 1] = string.format('set_ui_name(%q)', filename or os.date("autoxxt_%Y%m%d%H%M%S.lua"))
	script_flow[#script_flow + 1] = '__main__()'
	return table.concat(script_flow, '\n')
end

function html_escape(value)
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

function str_wide(str)
	local wide = 0
	for _,c in utf8.codes(str) do
		if (c <= 0xFF) then
			wide = wide + 1
		else
			wide = wide + 2
		end
	end
	return wide
end

function str_fill_wide(str, wide, pad)
	if type(dialog) == 'table' and dialog.engine ~= 'webview' then
		return str
	end
	pad = pad or '-'
	local w = str_wide(str)
	local d = 0
	if (w < wide) then
		d = wide - w
	end
	local hd = 0
	if (d > 1) then
		hd = math.floor(d / 2)
		d = d - hd * 2
	end
	local pad_w = str_wide(pad)
	local hs = string.rep(pad, math.floor(hd / pad_w))
	local out = {hs, str, hs}
	if (d == pad_w) then
		out[#out + 1] = pad
	end
	return table.concat(out)
end

function window_wide()
	
end

function show_button(info)
	info.id = tonumber(info.id) or 1
	if info.hide then
		webview.hide(info.id)
		return
	end
	if info.can_drag == nil then
		info.can_drag = true
	else
		info.can_drag = type(info.can_drag) == 'boolean' and info.can_drag
	end
	info.title = tostring(info.title)
	if info.msg == nil then
		info.msg = info.title
	else
		info.msg = tostring(info.msg)
	end
	info.w = tonumber(info.w) or (str_wide(info.title) * 9.125)
	info.h = tonumber(info.h) or 34
	info.w = info.w * factor
	info.h = info.h * factor
	info.x = tonumber(info.x) or (scr_w - info.w) / 2
	info.y = tonumber(info.y) or (scr_h  - 140 * factor)
	if info.callback then
		set_event_callback(info.msg, info.callback)
	end
	webview.show{
		html = [[
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
		<html>
		<head>
		<style>
		#one_button {
			color: #FFFFFF;
			text-shadow: 0px 0px 10px #000000;
			font-family: character;
		}
		div { /* 禁止选中文字 */
			-moz-user-select:none;
			-webkit-user-select:none;
			-ms-user-select:none;
			-khtml-user-select:none;
			user-select:none;
		}
		body {
			overflow:hidden;
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
	                    key:"webview控件消息",
	                    value:]]..string.format("%q", info.msg)..[[
	                }),
	                function(){}
	            );
			});
		});
		</script>
		</head>
		<body>
		<div id="one_button">]]..html_escape(info.title)..[[</div>
		</body>
		</html>
		]],
		x = info.x,
		y = info.y,
		width = info.w,
		height = info.h,
		corner_radius = 1,
		alpha = 0.9,
		animation_duration = 0.3,
		rotate = rotate_ang,
		can_drag = info.can_drag,
		opaque = false,
		id = info.id,
	}
end

function show_tile(info)
	info.id = tonumber(info.id) or 1
	if info.hide then
		webview.hide(info.id)
		return
	end
	info.size = tonumber(info.size) or 15 * factor
	info.x = tonumber(info.x) or (scr_w / 2)
	info.y = tonumber(info.y) or (scr_h / 2)
	info.corner_radius = tonumber(info.corner_radius) or (info.size * (0.48 / factor))
	info.title = info.title or info.id
    webview.show{
        html = [[<meta name="viewport" content="width=device-width, initial-scale=1.0"><html><head></head>
		<style>
		#one_tile {
			color: #AAAAAA;
			text-shadow: 0px 0px 10px #000000;
			font-size: ]]..tostring(math.tointeger(math.floor(info.size / 50 * 175)))..[[%;
			text-align: center;
			font-family: character;
		}
		div { /* 禁止选中文字 */
			-moz-user-select:none;
			-webkit-user-select:none;
			-ms-user-select:none;
			-khtml-user-select:none;
			user-select:none;
		}
		body {
			overflow:hidden;
		}
		</style>
		<body bgcolor="]]..string.format("#%06x", tonumber(info.color) or 0xFFFFFF)..[["><div id="one_tile">]]..tostring(info.id)..[[</div><body></html>]],
        x = info.x - ((info.size/2) * factor);
        y = info.y - ((info.size/2) * factor);
        width = info.size * factor;
        height = info.size * factor;
        corner_radius = info.corner_radius * factor;
        alpha = 0.9;
        animation_duration = 0;
        can_drag = true;
        level = 2060;
        id = info.id;
    }
end

function get_tile_pos(info)
	info.id = tonumber(info.id) or 1
	info.size = tonumber(info.size) or 15 * factor
	info.x = tonumber(info.x) or (scr_w / 2)
	info.y = tonumber(info.y) or (scr_h / 2)
    local frame = webview.frame(info.id)
    local x, y = (frame.x * factor + (frame.width / 2) * factor), (frame.y * factor + (frame.height/ 2) * factor)
	return {x = math.floor(x), y = math.floor(y)}
end

function confirm_button(info)
	info = (type(info) == 'table' and info) or {hide = false}
	info.id = tonumber(info.id) or 111
	if not info.hide then
		show_button({
			title = info.title,
			msg = info.title,
			id = info.id,
			x = info.x,
			y = info.y,
			callback = info.callback,
		})
	else
		webview.hide(info.id)
	end
end

function show_new_trigger_button(info)
	info = (type(info) == 'table' and info) or {hide = false}
	info.title = " 创建触发器或预览结果 "
	info.msg = info.title
	info.callback = (type(info.callback) == 'function' and info.callback) or on_new_trigger_button_click
	info.id = 101
	confirm_button(info)
end

function hide_new_trigger_button()
	confirm_button{id = 101, hide = true}
end

function pick_pos_list(info)
	info = (type(info) == 'table' and info) or {}
	if info.title == nil then
		info.title = '拖拽小块到选定位置然后点这里'
	end
	info.id = type(info.id) == 'number' and info.id or 111
	info.count = type(info.count) == 'number' and info.count or 1
	hide_new_trigger_button()
	local pos_list = nil
	for i = 1, info.count do
		show_tile{id = i, size = info.size, corner_radius = info.corner_radius}
	end
	confirm_button({id = info.id , title = info.title, callback = function()
		pos_list = {}
		for i = 1, info.count do
			pos_list[#pos_list + 1] = get_tile_pos{id = i}
		end
	end})
	confirm_button({y = 30 * factor, id = info.id + 1, title = ' 取消拾取 ', callback = function()
		confirm_button{id = info.id, hide = true}
		pos_list = {}
	end})
	while not pos_list do
		sys.msleep(100)
	end
	for i = 1, info.count do
		show_tile{id = i, hide = true}
	end
	confirm_button{id = info.id, hide = true}
	confirm_button{id = info.id + 1, hide = true}
	show_new_trigger_button()
	return pos_list
end

function pick_pos(info)
	info = (type(info) == 'table' and info) or {}
	info.count = 1
	return pick_pos_list(info)[1]
end

function choose_app(eventtitle, actionlabel)
	local dlg = dialog()
	dlg:title('选择一个应用')
	dlg:set_size(scr_w - 40 * factor, 450 * factor)
	dlg:add_label(eventtitle)
	local bids = app.bundles()
	local appnames = {}
	local appnamemap = {}
	local needshowbid = false
	for i,bid in ipairs(bids) do
		local name = app.localized_name(bid)
		appnames[i] = name
		if not appnamemap[name] then
			appnamemap[name] = bid
		else
			-- App 名称有重复的，只能用 bid 定位
			needshowbid = true
		end
	end
	if needshowbid then
		bids.num_per_line = 1
		dlg:add_radio(actionlabel, bids)
	else
		appnames.num_per_line = 1
		dlg:add_radio(actionlabel, appnames)
	end
    local c, s = dlg:show()
	if c then
		local bid
		if needshowbid then
			bid = s[actionlabel]
		else
			local name = s[actionlabel]
			bid = appnamemap[name]
		end
		return bid
	end
end

function choose_apps(eventtitle, actionlabel)
	local dlg = dialog()
	dlg:title('选择多个应用')
	dlg:set_size(scr_w - 40 * factor, 450 * factor)
	dlg:add_label(eventtitle)
	local bids = app.bundles()
	local appnames = {}
	local appnamemap = {}
	local needshowbid = false
	for i,bid in ipairs(bids) do
		local name = app.localized_name(bid)
		appnames[i] = name
		if not appnamemap[name] then
			appnamemap[name] = bid
		else
			-- App 名称有重复的，只能用 bid 定位
			needshowbid = true
		end
	end
	if not appnamemap["[前台应用程序]"] then
		appnamemap["[前台应用程序]"] = 'app.front_bid()'
		bids[#bids + 1] = 'app.front_bid()'
		appnames[#appnames + 1] = '[前台应用程序]'
	end
	if not appnamemap["[所有应用程序]"] then
		appnamemap["[所有应用程序]"] = '*'
		bids[#bids + 1] = '*'
		appnames[#appnames + 1] = '[所有应用程序]'
	end
	if needshowbid then
		bids.num_per_line = 1
		dlg:add_checkbox(actionlabel, bids)
	else
		appnames.num_per_line = 1
		dlg:add_checkbox(actionlabel, appnames)
	end
    local c, s = dlg:show()
	if c then
		local bids = nil
		if needshowbid then
			bids = s[actionlabel]
		else
			local names = s[actionlabel]
			bids = {}
			for _, name in ipairs(names) do
				bids[#bids + 1] = appnamemap[name]
			end
		end
		return bids
	end
end

function choose_action_for_event(eventtitle)
	local dlg = dialog()
	dlg:title('为事件创建动作')
	dlg:set_size(scr_w - 40 * factor, scr_h - 20 * factor)
	dlg:add_label(eventtitle)
	dlg:add_range('延迟几毫秒', {0, 10000, 10}, 0)
	
	local actionname_tap = str_fill_wide('点击位置', math.floor((scr_w - 75 * factor) / (5.1724 * factor))) -- 600 / 58
	local actionname_find_tap = str_fill_wide('找到并点击位置', math.floor((scr_w - 75 * factor) / (5.4545 * factor))) -- 600 / 55
	local actionname_slide = str_fill_wide('触摸滑动到', math.floor((scr_w - 75 * factor) / (5.2631 * factor))) -- 600 / 57
	local actionname_run_app = str_fill_wide('启动一个 App', math.floor((scr_w - 75 * factor) / (5.3571 * factor))) -- 600 / 56
	local actionname_quit_app = str_fill_wide('退出一些 App', math.floor((scr_w - 75 * factor) / (5.3571 * factor)))
	local actionname_unlock = str_fill_wide('解锁屏幕', math.floor((scr_w - 75 * factor) / (5.1724 * factor)))
	local actionname_lock = str_fill_wide('锁定屏幕', math.floor((scr_w - 75 * factor) / (5.1724 * factor)))
	local actionname_exit = str_fill_wide('结束脚本', math.floor((scr_w - 75 * factor) / (5.1724 * factor)))
	dlg:add_radio('你想要创建的动作是？', {num_per_line = 1, actionname_tap, actionname_find_tap, actionname_slide, actionname_run_app, actionname_quit_app, actionname_unlock, actionname_lock, actionname_exit, })
	local actionname_append_action = str_fill_wide('附加一个动作', math.floor((scr_w - 75 * factor) / (5.3571 * factor)))
	dlg:add_checkbox('上述动作后附加一个动作', {num_per_line = 1, actionname_append_action})
    local c, s = dlg:show()
	if c then
		local outt = {}
		if s['延迟几毫秒'] > 0 then
			outt[#outt + 1] = string.format('sys.msleep(%d)', s['延迟几毫秒'])
		end
		local actionname = s['你想要创建的动作是？']
		if actionname == actionname_run_app then
			local bid = choose_app(eventtitle, '你想要启动的 App 是？')
			if bid then
				outt[#outt + 1] = string.format('app.run(%q)', bid)
			else
				return false
			end
		elseif actionname == actionname_quit_app then
			local bids = choose_apps(eventtitle, '你想要退出哪些 App？')
			if bids then
				for _, bid in ipairs(bids) do
					if bid == 'app.front_bid()' then
						outt[#outt + 1] = string.format('app.quit(%s)', bid)
					else
						outt[#outt + 1] = string.format('app.quit(%q)', bid)
					end
				end
			else
				return false
			end
		elseif actionname == actionname_find_tap then
			local p = pick_pos{size = 10 * 2, corner_radius = 0, title = "拖动小块到需要查找的特征位置并点这里"}
			if p then
				sys.msleep(300) -- 等待 webview 隐藏
				outt = {}
				screen.keep()
				local img = screen.image(p.x - 5 * factor, p.y - 5 * factor, p.x + 5 * factor - 1, p.y + 5 * factor - 1)
				img = img:cv_resize(scr_w - 10 * factor, scr_w - 10 * factor)
				screen.unkeep()
				local prevdlg = dialog()
				prevdlg:title('特征预览')
				prevdlg:add_image(img)
				local c = prevdlg:show()
				if c then
					outt[#outt + 1] = 'local x, y = screen.find_image("'..(img:jpeg_data():to_hex():gsub('..', function(c) return '\\x'..c end))..'", 90)'
					outt[#outt + 1] = 'if x ~= -1 then'
					outt[#outt + 1] = 'touch.tap(x, y)'
					outt[#outt + 1] = 'end'
				else
					sys.toast('丢弃该特征')
				end
			else
				return nil
			end
		elseif actionname == actionname_slide then
			local pos_list = pick_pos_list{count = 2, title = "从小块 1 滑动到小块 2 设置好点这里"}
			if pos_list and #pos_list > 0 then
				outt[#outt + 1] = string.format('touch.on(%d, %d)', pos_list[1].x, pos_list[1].y)
				outt[#outt + 1] = ':step_len(3)'
				outt[#outt + 1] = string.format(':move(%d, %d)', pos_list[2].x - 2, pos_list[2].y - 2)
				outt[#outt + 1] = ':step_len(1)'
				outt[#outt + 1] = string.format(':move(%d, %d)', pos_list[2].x, pos_list[2].y)
				outt[#outt + 1] = ':msleep(100)'
				outt[#outt + 1] = ':off()'
			else
				return nil
			end
		elseif actionname == actionname_unlock then
			outt[#outt + 1] = 'device.unlock_screen()'
		elseif actionname == actionname_lock then
			outt[#outt + 1] = 'device.lock_screen()'
		elseif actionname == actionname_exit then
			outt[#outt + 1] = 'os.exit()'
		else
			local p = pick_pos{title = "拖动小块到需要点击的位置然后点这里"}
			if p then
				outt[#outt + 1] = string.format('touch.tap(%d, %d)', p.x, p.y)
			else
				return nil
			end
		end
		if #(s['上述动作后附加一个动作']) > 0 then
			local action = choose_action_for_event(eventtitle.."\n"..(actionname:gsub('%-', '')))
			outt[#outt + 1] = action
		end
		local code = table.concat(outt, '\n')
		return code
	else
		return nil
	end
end

function choose_action_for_ui_event(eventtitle)
	local eventname_ui_spec1 = str_fill_wide('界面上一处特征', math.floor((scr_w - 75 * factor) / (5.4545 * factor)))
	local eventname_ui_spec2 = str_fill_wide('界面上两处特征', math.floor((scr_w - 75 * factor) / (5.4545 * factor)))
	local eventname_ui_spec3 = str_fill_wide('界面上三处特征', math.floor((scr_w - 75 * factor) / (5.4545 * factor)))
	local eventname_list = {num_per_line = 1, eventname_ui_spec1, eventname_ui_spec2, eventname_ui_spec3}
	local eventname_map = {}
	for i, v in ipairs(eventname_list) do
		eventname_map[v] = i
	end
	local ok, s = dialog()
		:title('选择特征')
		:set_size(scr_w - 40 * factor, 300 * factor)
		:add_radio('你需要判断界面上几处特征？', eventname_list)
	:show()
	if ok then
		local eventname = s['你需要判断界面上几处特征？']
		local pos_list = pick_pos_list{size = 10 * 2, corner_radius = 0, count = eventname_map[eventname]}
		if #pos_list == 0 then
			return nil
		end
		sys.msleep(300) -- 等待 webview 隐藏
		local prev = {}
		local outt = {}
		outt[#outt + 1] = '{'
		screen.keep()
		for _, pos in ipairs(pos_list) do
			pos.x = pos.x - 5 * factor
			pos.y = pos.y - 5 * factor
			for x = pos.x, pos.x + 10 * factor, 2 do
				for y = pos.y, pos.y + 10 * factor, 2 do
					outt[#outt + 1] = string.format('{%d, %d, 0x%06x},', x, y, screen.get_color(x, y))
				end
			end
			local img = screen.image(pos.x, pos.y, pos.x + 10 * factor - 1, pos.y + 10 * factor - 1)
			img = img:cv_resize(scr_w - 10 * factor, scr_w - 10 * factor)
			prev[#prev + 1] = img
		end
		screen.unkeep()
		sys.msleep(500)
		local prevdlg = dialog()
		prevdlg:title('特征预览')
		for _,v in ipairs(prev) do
			prevdlg:add_image(v)
		end
		local c = prevdlg:show()
		if c then
			local action = nil
			while 1 do
				action = choose_action_for_event((eventname:gsub('%-', '')))
				if action == nil then
					sys.toast('丢弃该特征')
					return nil
				elseif action then
					outt[#outt + 1] = string.format('run = (function()\n%s\nend),', action)
					outt[#outt + 1] = '}'
					return table.concat(outt, '\n')
				end
			end
		else
			sys.toast('丢弃该特征')
		end
	end
end

function on_new_trigger_button_click(msg)
	local eventname_start = str_fill_wide('当脚本刚开始运行', math.floor((scr_w - 75 * factor) / (5.55555 * factor)))
	local eventname_enter_ui = str_fill_wide('当进入某个界面', math.floor((scr_w - 75 * factor) / (5.4545 * factor)))
	local eventname_preview = str_fill_wide('预览或导出结果', math.floor((scr_w - 75 * factor) / (5.4545 * factor)))
    local ok, s = dialog()
		:title('创建事件')
		:set_size(scr_w - 40 * factor, 300 * factor)
		:add_radio('你想要创建的事件是？', {num_per_line = 1, eventname_start, eventname_enter_ui, eventname_preview})
	:show()
    if ok then
		local eventname = s['你想要创建的事件是？']
		if eventname == eventname_start then
			local action = choose_action_for_event((eventname:gsub('%-', '')))
			ms_add_start_action(action)
		elseif eventname == eventname_enter_ui then
			local action = choose_action_for_ui_event((eventname:gsub('%-', '')))
			ms_add_ui_action(action)
		elseif eventname == eventname_preview then
			local filename = os.date("autoxxt_%Y%m%d%H%M%S.lua")
			local outlua = ms_make(filename)
			local dlg = dialog()
			dlg:title('预览结果')
			if type(dialog) == 'table' and dialog.engine ~= 'webview' then
				dlg:add_input(filename, {multiline = true, default = outlua})
			else
				dlg:add_label(outlua)
			end
			dlg:add_radio("结束向导保存到文件？", {num_per_line = 1, "继续向导", "结束向导并导出脚本到文件"})
			local c, s = dlg:show()
			if c then
				if s["结束向导保存到文件？"] == "结束向导并导出脚本到文件" then
					local fullfilename = string.format('/var/mobile/Media/1ferver/lua/scripts/%s', filename)
					file.writes(fullfilename, outlua)
					sys.alert(string.format('已经保存到\n%s', fullfilename))
					os.exit()
				end
			end
		else
			--
		end
    end
end

show_new_trigger_button()

proc_queue_clear("webview控件消息", "") -- 清空需要监听的字典的值
local eid = thread.register_event( -- 注册监听字典状态有值事件
    "webview控件消息",
    function(msg)
		local action = event_dispatch_map[msg]
		if type(action) == 'function' then
			thread.dispatch(function()
				action(msg)
			end)
		end
    end
)
