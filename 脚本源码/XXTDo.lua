--[[
	XXTDo 基于界面匹配的脚本框架

	基本流程：
		1. 把每个可识别界面写成一个表，表里放点色列表和匹配后的 run 动作。
		2. 把这些界面表放入 XXTDo.runloop 的参数表中，并设置 name。
		3. 框架会按顺序循环匹配界面；匹配成功后执行当前界面的 run 动作。
		4. 需要退出循环时，在回调中调用 XXTDo.breakloop(...)。

	最小示例：
		local XXTDo = require 'XXTDo'

		XXTDo.runloop {
			name = '示例循环',
			csim = 90,
			interval_ms = 100,
			log = sys.log,

			{
				name = '首页',
				{100, 100, 0xffffff},
				{120, 100, 0x000000},
				run = function(self, index, parent, filter_result)
					XXTDo.log('匹配到首页')
					XXTDo.breakloop('done')
				end,
			},
		}

	------------------------------------
	XXTDo.runloop(loop_table)

	loop_table 是一个界面列表，同时也保存本次循环的全局设置：
		{
			name        = [字符串，必填，当前界面列表名],
			csim        = [数字，可选，全局相似度，默认 90],
			interval_ms = [数字，可选，每轮检测结束到下一轮检测开始的等待毫秒数，默认 100],
			log         = [函数，可选，日志函数，原型：log(日志文本)；不填则丢弃日志],
			log_date    = [布尔，可选，当日志首个参数不是 table 时，自动在其前面附加日期时间，默认 false],
			error       = [函数，可选，错误处理函数，原型：error(错误文本)；默认 error 抛错],
			filter      = [函数，可选，已弃用，界面过滤器；默认 screen.is_colors],
			match_rules = [表，可选，按界面 rule 分派过滤器，优先于 filter],
			pre_run     = [函数，可选，每轮检测前执行，原型：pre_run(整个界面列表)],
			post_run    = [函数，可选，每轮检测后执行，原型：post_run(整个界面列表, nil 或匹配结果)],
			else_run    = [函数，可选，本轮所有界面都未匹配成功时执行，会在 post_run 之前执行],
			timeout_s   = [数字，可选，全局超时时间，单位秒，默认 0 表示不超时],
			timeout_run = [函数，可选，全局超时回调，原型：timeout_run(整个界面列表, nil 或匹配结果)],
			enter       = [函数，可选，进入循环前执行一次，原型：enter(整个界面列表)],
			finally     = [函数，可选，runloop 因 XXTDo.breakloop 跳出时执行一次，可在此用 XXTDo.breakloop 覆盖 runloop 的返回值],
			界面1,
			界面2,
			...
		}

	match_rules 的写法：
		match_rules = {
			xxx = function(self, index, parent)
				-- self 是当前界面，index 是当前界面序号，parent 是整个界面列表
				-- 第一个返回值为真表示界面匹配，第二个返回值会传给 run
			end,
			default = function(self, index, parent)
				-- 当前界面没有可用 rule 时使用；不设置则使用框架默认匹配逻辑（默认 screen.is_colors，设置了 loop_table.filter 时会调用它）
			end,
		}

	界面表的写法：
		{
			name        = [字符串，可选，当前界面名，默认 ""],
			csim        = [数字，可选，当前界面相似度，默认使用 loop_table.csim],
			interval_ms = [数字，可选，匹配后到下一轮检测的等待毫秒数，优先于 loop_table.interval_ms],
			rule        = [字符串，可选，使用 match_rules[rule] 过滤器],
			run         = [函数，匹配后执行，原型：run(当前界面, 当前序号, 整个界面列表, 过滤器第二个返回值)],
			timeout_s   = [数字，可选，当前界面停留超时时间，优先于全局 timeout_s，默认 0],
			timeout_run = [函数，可选，当前界面超时回调，优先于全局 timeout_run，原型：timeout_run(整个界面列表, 匹配结果, 过滤器第二个返回值)],
			group       = [表，可选，多组点色列表；任意一组匹配即表示当前界面匹配；每组可单独设 csim 覆盖当前界面 csim],

			-- 不使用 group 时，直接在界面表中写点色列表
			{x, y, color},
			{x, y, color},
			...
		}

	run、timeout_run 的返回值约定：
		nil、true、'success' 表示处理成功；
		false、'failed' 或其它值表示处理失败。
		界面 run 返回失败时，本轮会继续尝试后续界面。
		timeout_run 返回失败时，不重置超时计时器。

	超时优先级：
		匹配界面自身的 timeout_s 优先；只有未匹配任何界面、或匹配界面未设 timeout_s > 0 时，
		才会以 loop_table.timeout_s 触发全局 timeout_run。

	匹配结果表格式：
		{
			index = 当前界面在界面列表中的序号,
			subindex = 当前匹配的 group 子界面序号；未使用 group 时为 -1,
			ui = 当前界面表,
		}

	说明：
		XXTDo.runloop 每一轮匹配都会先调用 screen.keep() 再进行界面匹配。
		如果 run 动作会改变画面，并且后续还要立即判断新画面，可在 run 中再次调用 screen.keep() 获取最新屏幕状态。

	------------------------------------
	XXTDo.log(...)

	在 runloop 的回调中输出日志，会调用当前 loop_table.log。
	如果未设置 log，日志会被丢弃；在 runloop 外调用没有效果。

	------------------------------------
	XXTDo.match_rules_default_super()

	在自定义 match_rules.default 中调用，用于转发到框架默认的点色匹配逻辑。

	------------------------------------
	XXTDo.breakloop(...)

	跳出当前 runloop。传入的参数会作为 XXTDo.runloop 的返回值。
	在非 finally 回调中调用后，框架会先执行 finally，并把这些参数传给 finally。
	finally 中也可以再次调用 XXTDo.breakloop(...) 来修改 runloop 的返回值。
	不要在界面过滤器函数或 runloop 外调用。

	------------------------------------
	XXTDo.config

	用于持久化保存简单值：数字、字符串、布尔值。
	这些值会保存到设备，下次启动脚本仍可读取。

	用法：
		cfg = XXTDo.config('配置名字')   -- 获取一个配置对象；第一次传入名字时会将该配置绑定为全局配置
		XXTDo.config('配置名字').clear() -- 清空同名配置
		XXTDo.config.value = 1          -- 写入全局配置
		a = XXTDo.config.value          -- 读取全局配置

		cfg = XXTDo.config('配置名字')
		cfg.clear()
		cfg.value = 1
		a = cfg.value

		cfg2 = XXTDo.config('配置名字2') -- 获取另一个配置对象；若全局配置已存在则不会覆盖全局配置
		cfg3 = XXTDo.config('配置名字')  -- 再次获取同名配置对象时返回同一个对象

	说明：
		XXTDo.config 和配置对象内部使用隐藏索引保存元数据，因此 data、cfgname 等字符串可直接作为配置字段使用。
		clear 为框架保留方法名。

	------------------------------------
	v0.8.2 [2026-04-27]:
		修复 XXTDo.config 配置管理问题
		增强运行循环上下文管理
		修正界面 run 动作返回失败时最后一个界面不会触发 else_run 的问题
		修正 enter 和 finally 中 XXTDo.log 无法正常输出的问题
	v0.8.1 [2025-03-01]:
		修正 name、timeout_s 和 group 为空时判断问题
	v0.8 [2025-02-28]:
		增加 match_rules 匹配规则用于替代 filter
		弃用 filter 过滤器
		增加 XXTDo.log 框架日志函数
		XXTDo.config 增加默认配置及读取缓存
	v0.7 [2024-12-17]:
		修正局部超时时间大于全局超时时间设置无效的问题
	v0.6 [2024-02-28]:
		使用兼容路径 XXT_HOME_PATH 替代 '/var/mobile/Media/1ferver'
--]]

local _ENV = table.deep_copy(_ENV)
local _M = {}

_M._VERSION = '0.8.2'

local breakloop_tips = '请不要在界面过滤器函数或 XXTDo.runloop 外部执行 XXTDo.breakloop '..string.sub(string.sha256(string.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 1000)), 7, 16)

local function _dummy(...)
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
local XXT_HOME_PATH = XXT_HOME_PATH or '/var/mobile/Media/1ferver'
local homedir = XXT_HOME_PATH..'/'
local cfgfiledir = homedir..'/uicfg/'
lfs.mkdir(homedir)
lfs.mkdir(cfgfiledir)
local _conf_default_name = '_____config_____'
local _conf_name_key = {}
local _conf_data_key = {}
local _conf_cache = {}
local _conf_global = nil
local function _ensure_a_table(tab, defer_default)
	if type(tab) ~= 'table' then
		if type(defer_default) == 'function' then
			local _
			_, tab = pcall(defer_default, tab)
			if type(tab) ~= 'table' then
				tab = {}
			end
		elseif type(defer_default) == 'table' then
			tab = defer_default
		else
			tab = {}
		end
	end
	return tab
end
local function _conf_name(self)
	local cfgname = rawget(self, _conf_name_key)
	if type(cfgname) == 'string' then
		return cfgname
	end
	return _conf_default_name
end
local function _conf_file_path(self)
	local cfgfilename = cfgfiledir.._conf_name(self)..'.XXTDoConfig'
	return cfgfilename
end
local function _conf_meta_data(self)
	local tab = rawget(self, _conf_data_key)
	if type(tab) ~= 'table' then
		local cfgfilename = _conf_file_path(self)
		tab = _ensure_a_table(json.decode(file.reads(cfgfilename) or '{}'))
		rawset(self, _conf_data_key, tab)
	end
	return tab
end
local function _conf_meta_load(self, key)
	local tab = _conf_meta_data(self)
	return tab[key]
end
local function _conf_meta_save(self, key, value)
	local cfgfilename = _conf_file_path(self)
	local tab = _conf_meta_data(self)
	tab[key] = value
	rawset(self, _conf_data_key, tab)
	file.writes(cfgfilename, json.encode(tab))
	return value
end
local function _conf_meta_clear(self)
	rawset(self, _conf_data_key, {})
	os.remove(_conf_file_path(self))
	return self
end
local function _conf_meta_tostring(self)
	local tab = _conf_meta_data(self)
	if tab then
		return string.format('<XXTDo.config %q>: %s', _conf_name(self), json.encode(tab))
	else
		return string.format('<XXTDo.config %q>: %s', _conf_name(self), '{}')
	end
end
local function _conf_object_clear(self)
	return _conf_meta_clear(self)
end
local _conf_object_meta = {
	__index = function(self, key)
		if key == 'clear' then
			return function()
				return _conf_object_clear(self)
			end
		end
		return _conf_meta_load(self, key)
	end,
	__newindex = function(self, key, value)
		return _conf_meta_save(self, key, value)
	end,
	__tostring = _conf_meta_tostring,
}
local function _conf_get(name)
	name = type(name) == 'string' and name or _conf_default_name
	local ret = _conf_cache[name]
	if type(ret) ~= 'table' then
		ret = {}
		rawset(ret, _conf_name_key, name)
		setmetatable(ret, _conf_object_meta)
		_conf_cache[name] = ret
	end
	return ret
end
local function _conf_current_global()
	if type(_conf_global) == 'table' then
		return _conf_global
	end
	return _conf_get(_conf_default_name)
end
local _confmeta = {
	__call = function(self, name)
		local ret = _conf_get(name)
		if type(name) == 'string' and type(_conf_global) ~= 'table' then
			_conf_global = ret
		end
		return ret
	end,
	__index = function(self, key)
		if key == 'clear' then
			return function()
				return _conf_meta_clear(_conf_current_global())
			end
		end
		return _conf_meta_load(_conf_current_global(), key)
	end,
	__newindex = function(self, key, value)
		return _conf_meta_save(_conf_current_global(), key, value)
	end,
	__tostring = function(self)
		return _conf_meta_tostring(_conf_current_global())
	end,
}
_M.config = {}
setmetatable(_M.config, _confmeta)

local _TMP = {
	runloop_context_stack = {},
}

local function _packvarargs(...)
	return {n = select('#', ...), ...}
end

local function _current_runloop_context()
	local stack = _TMP.runloop_context_stack
	return stack[#stack]
end

local function _push_runloop_context()
	local stack = _TMP.runloop_context_stack
	local ctx = {
		current_ui_state = {{}, 0, {}},
		current_log_func = _dummy,
		current_match_rules_default = nil,
		breakloop_results = nil,
	}
	stack[#stack + 1] = ctx
	return ctx
end

local function _pop_runloop_context(ctx)
	local stack = _TMP.runloop_context_stack
	if stack[#stack] == ctx then
		stack[#stack] = nil
	end
	return ctx
end

local function _unpack_breakloop_results(ctx)
	local breakloop_results = type(ctx) == 'table' and ctx.breakloop_results or nil
	if type(breakloop_results) == 'table' then
		return table.unpack(breakloop_results, 1, breakloop_results.n)
	end
end

-- 跳出循环实现
function _M.breakloop(...)
	local ctx = _current_runloop_context()
	if type(ctx) == 'table' then
		ctx.breakloop_results = _packvarargs(...)
	end
	error(breakloop_tips, 2)
end

-- 日志函数实现
function _M.log(...)
	local ctx = _current_runloop_context()
	local ok, errmsg = pcall(type(ctx) == 'table' and ctx.current_log_func or _dummy, ...)
	if not ok then
		error(string.format('XXTDo.log 发生异常: %s', errmsg), 2)
	end
end

-- 在任何 rule 中转发到 filter
function _M.match_rules_default_super()
	local ctx = _current_runloop_context()
	if type(ctx) == 'table' and type(ctx.current_match_rules_default) == 'function' then
		return ctx.current_match_rules_default(table.unpack(ctx.current_ui_state))
	end
end

-- 主功能跑环实现
function _M.runloop(orig_loop_table)
	if type(orig_loop_table) ~= 'table' then
		error(string.format('给 XXTDo.runloop 传递的参数不合法\n\n%s', debug.traceback()), 2)
	end
	local loop_table = table.deep_copy(orig_loop_table)
	local _L = {}
	_L.log = _dummy
	_L.error = error
	_L.filter = screen.is_colors
	_L.interval_ms = 100
	_L.timeout_s = 0
	_L.timeout_run = _dummy
	_L.loop_name = type(loop_table.name) == 'string' and loop_table.name or nil
	if type(_L.loop_name) ~= 'string' then
		error(string.format('给 XXTDo.runloop 参数 #1 需要至少包含 name 字段的表\n例如 {name = "一个名字"}\n\n%s', debug.traceback()), 2)
	end
	local function _log_func(...)
		if loop_table.log_date == true and select('#', ...) > 0 then
			local first = (select(1, ...))
			if type(first) ~= 'table' then
				return _L.log(string.format('[%s] %s', _datetime(), tostring(first)), select(2, ...))
			end
		end
		return _L.log(...)
	end
	local function _callifexists(UI, func, ...)
		if (type(func) == 'function') then
			local rets = {pcall(func, ...)}
			local ok = rets[1]
			if (not ok) then
				local errmsg = rets[2]
				if _isbreakerr(errmsg) then
					return 'breakloop'
				end
				_L.error(_dumpvarshort{
					error = string.format("界面循环 %s 发生运行期错误\n%s", _L.loop_name, errmsg),
					time = _datetime(),
					UI = UI,
				}, 3)
				return 'failed' -- 如果回调抛出错误脚本却没结束，则返回 failed
			else
				local ret = rets[2]
				if ret == nil or ret == true or ret == 'success' then
					return 'success' -- 界面动作返回 nil 或 true 或 'success' 表示匹配成功，否则表示匹配失败，不中断当前轮匹配
				else
					return 'failed'
				end
			end
		else
			return 'failed'
		end
	end
	local function _match_rules_default(self, index, parent)
		local csim = tonumber(self.csim) or 90
		local self_group = rawget(self, 'group')
		if type(self_group) == 'table' and #(self_group) > 0 then
			for subidx, subui in ipairs(self_group) do
				if type(subui) == 'table' and #subui > 0 then
					local filter_results = _L.filter(subui, tonumber(subui.csim) or csim or 90, {loop_table = parent, ui = self, index = index, subindex = subidx})
					if filter_results[1] then
						filter_results.subindex = subidx
						return filter_results
					end
				end
			end
		end
		if #self > 0 then
			local filter_results = _L.filter(self, csim or 90, {loop_table = parent, ui = self, index = index, subindex = -1})
			if filter_results[1] then
				return filter_results
			end
		end
		return {false}
	end
	local function _filter_wrap(filter, rule_name)
		rule_name = type(rule_name) =='string' and ('match_rules.'..rule_name) or 'filter'
		return function(...)
			local rets = {pcall(filter, ...)}
			local ok = rets[1]
			if (not ok) then
				local errmsg = rets[2]
				if _isbreakerr(errmsg) then
					_L.error(_dumpvarshort{
						error = string.format("尝试在界面循环 %s 的 %s 函数使用 XXTDo.breakloop\n%s 函数中不允许使用 XXTDo.breakloop", _L.loop_name, rule_name, rule_name),
						time = _datetime(),
						UI = rule_name,
					}, 3)
				else
					_L.error(_dumpvarshort{
						error = string.format("界面循环 %s 的 %s 函数发生运行期错误\n%s", _L.loop_name, rule_name, errmsg),
						time = _datetime(),
						UI = rule_name,
					}, 3)
				end
				return rets -- 如果过滤器抛出错误脚本却没结束，则表示不匹配
			else
				return {table.unpack(rets, 2)}
			end
		end
	end
	if (type(loop_table.log) == 'function') then
		_L.log = loop_table.log
	end
	if (type(loop_table.error) == 'function') then
		_L.error = loop_table.error
	end
	if (type(loop_table.founder) == 'function') then
		_L.filter = loop_table.founder
	end
	if (type(loop_table.filter) == 'function') then
		_L.filter = loop_table.filter
	end
	_L.filter = _filter_wrap(_L.filter)
	_L.match_rules = {}
	if (type(loop_table.match_rules) == 'table') then
		for key, value in pairs(loop_table.match_rules) do
			if type(value) == 'function' then
				_L.match_rules[key] = _filter_wrap(value, key)
			end
		end
	end
	if _L.match_rules.default == nil then
		_L.match_rules.default = _match_rules_default
	end
	if (type(loop_table.timeout_run) == 'function') then
		_L.timeout_run = loop_table.timeout_run
	end
	if (type(loop_table.timeout_s) == 'number') then
		_L.timeout_s = loop_table.timeout_s
	end
	if (type(loop_table.interval_ms) == 'number') then
		_L.interval_ms = loop_table.interval_ms
	end
	if (type(loop_table.enter) == 'function') then
		_L.enter = loop_table.enter
	end
	if (type(loop_table.finally) == 'function') then
		_L.finally = loop_table.finally
	end
	local _submeta = {
		__index = function(self, key)
			if (type(key) == 'string') then
				return loop_table[key]
			else
				return nil
			end
		end
	}
	for _,ui in ipairs(loop_table) do
		setmetatable(ui, _submeta)
	end
	local ctx = _push_runloop_context()
	local call_results = _packvarargs(xpcall(function()
		_L.timer_begin_time    = os.time()
		_L.timer_last_found    = -1 -- -1 表示没匹配任何界面
		_L.timer_current_found = -1 -- -1 表示没匹配任何界面
		ctx.current_log_func = _log_func
		ctx.current_match_rules_default = _match_rules_default
		local function to_finally()
			if _callifexists('finally', loop_table.finally, loop_table, _unpack_breakloop_results(ctx)) == 'breakloop' then
				_log_func(string.format('从 finally 跳出界面匹配循环 %s', _L.loop_name))
			end
			ctx.current_log_func = _dummy
			return _unpack_breakloop_results(ctx)
		end
		_log_func(string.format('开始进入界面匹配循环 %s', _L.loop_name))
		if (_callifexists('enter', loop_table.enter, loop_table) == 'breakloop') then
			_log_func(string.format('从 enter 跳出界面匹配循环 %s', _L.loop_name))
			return to_finally()
		end
		while (true) do
			local _current_interval_ms = tonumber(loop_table.interval_ms) or _L.interval_ms
			screen.keep()
			sys.msleep(2)
			ctx.current_log_func = _log_func
			ctx.current_match_rules_default = _match_rules_default
			if (_callifexists('pre_run', loop_table.pre_run, loop_table) == 'breakloop') then
				_log_func(string.format('从 pre_run 跳出界面匹配循环 %s', _L.loop_name))
				return to_finally()
			end
			local foundui = nil
			local filter_results = nil
			local match_rules = _L.match_rules
			local current_ui_state = ctx.current_ui_state
			for idx, currentui in ipairs(loop_table) do
				local is_valid_ui
				local currentui_rule, currentui_group
				if type(currentui) == 'table' then
					currentui_rule = match_rules[rawget(currentui, 'rule')]
					currentui_group = rawget(currentui, 'group')
					if #currentui > 0 then
						is_valid_ui =  true
					elseif currentui_rule then
						is_valid_ui = true
					elseif currentui_group and #(currentui_group) > 0 then
						is_valid_ui = true
					end
				end
				if is_valid_ui then
					local found = false
					local run_success = false
					local subindex = -1
					current_ui_state[1] = currentui
					current_ui_state[2] = idx
					current_ui_state[3] = loop_table
					if currentui_rule then
						filter_results = currentui_rule(currentui, idx, loop_table)
						found = filter_results[1] and true
					else
						filter_results = match_rules.default(currentui, idx, loop_table)
						found = filter_results[1] and true
					end
					if found and filter_results then
						local currentui_name = rawget(currentui, 'name')
						currentui_name = type(currentui_name) == 'string' and currentui_name or ''
						if type(filter_results.subindex) == 'number' then
							subindex = filter_results.subindex
						end
						local idxstr
						if subindex > 0 then
							idxstr = string.format('[%d][%d]', idx, subindex)
						else
							idxstr = string.format('[%d]', idx)
						end
						_log_func(string.format('匹配 %s %s %q', _L.loop_name, idxstr, currentui_name))
						local runstat = _callifexists({ui = currentui, index = idx, subindex = subindex}, currentui.run, currentui, idx, loop_table, filter_results[2])
						if (runstat == 'breakloop') then
							_log_func(string.format('从 %s %q 跳出界面匹配循环 %s', idxstr, currentui_name, _L.loop_name))
							return to_finally()
						elseif (runstat == 'success') then
							local currentui_timeout_s = tonumber(currentui.timeout_s) or 0
							_current_interval_ms = tonumber(currentui.interval_ms) or _L.interval_ms
							foundui = {ui = currentui, index = idx, subindex = subindex}
							run_success = true
							_L.timer_current_found = idx
							if (_L.timer_current_found ~= _L.timer_last_found) then
								_L.timer_last_found = _L.timer_current_found
								_L.timer_begin_time = os.time()
							elseif currentui_timeout_s > 0 and os.difftime(os.time(), _L.timer_begin_time) > currentui_timeout_s then
								local timeout_run = _L.timeout_run
								if type(currentui.timeout_run) == 'function' then
									timeout_run = currentui.timeout_run
								end
								_log_func(string.format('从 %s %s %q 超时', _L.loop_name, idxstr, currentui_name))
								local timeout_run_results = _callifexists({ui = currentui, index = idx, subindex = subindex}, timeout_run, loop_table, foundui, filter_results[2])
								_log_func(string.format('%s 超时回调返回 %s ', _L.loop_name, timeout_run_results))
								if (timeout_run_results == 'success') then
									_L.timer_begin_time = os.time()
								elseif (timeout_run_results == 'breakloop') then
									_log_func(string.format('从 %s %q 超时回调跳出界面匹配循环 %s', idxstr, currentui_name, _L.loop_name))
									return to_finally()
								end
							end
							break
						end
					end
					if (not run_success) and #loop_table == idx then
						_L.timer_current_found = -1
						if (_callifexists('else_run', loop_table.else_run, loop_table) == 'breakloop') then
							_log_func(string.format('从 else_run 跳出界面匹配循环 %s', _L.loop_name))
							return to_finally()
						end
					end
				else
					_L.error(_dumpvarshort{
						error = string.format('界面列表 %s 中编号为 [%d] 的界面不是一个合法的界面', _L.loop_name, idx),
						time = _datetime(),
						UI = currentui,
					}, 2)
				end
			end
			if (_callifexists('post_run', loop_table.post_run, loop_table, foundui) == 'breakloop') then
				_log_func(string.format('从 post_run 跳出界面匹配循环 %s', _L.loop_name))
				return to_finally()
			end
			if (_L.timer_current_found ~= _L.timer_last_found) then
				_L.timer_last_found = _L.timer_current_found
				_L.timer_begin_time = os.time()
			elseif (_L.timeout_s > 0 and os.difftime(os.time(), _L.timer_begin_time) > _L.timeout_s) then
				local matched_ui_has_timeout_s = type(foundui) == 'table' and type(foundui.ui) == 'table' and (tonumber(rawget(foundui.ui, 'timeout_s')) or 0) > 0
				if not matched_ui_has_timeout_s then -- 超时所在界面的超时配置优先权高于全局超时配置
					_log_func(string.format('%s 未匹配任何界面超时', _L.loop_name))
					local timeout_run_results = _callifexists('global_timeout_run', _L.timeout_run, loop_table, foundui)
					_log_func(string.format('%s 超时回调返回 %s', _L.loop_name, timeout_run_results))
					if (timeout_run_results == 'success') then
						_L.timer_begin_time = os.time()
					elseif (timeout_run_results == 'breakloop') then
						_log_func(string.format('从 未匹配任何界面的全局 超时回调跳出界面匹配循环 %s', _L.loop_name))
						return to_finally()
					end
				end
			end
			sys.msleep(_current_interval_ms)
		end
	end, function(errmsg)
		return debug.traceback(errmsg, 2)
	end))
	_pop_runloop_context(ctx)
	if not call_results[1] then
		error(call_results[2], 0)
	end
	return table.unpack(call_results, 2, call_results.n)
end

return _M