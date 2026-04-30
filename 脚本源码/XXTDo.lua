--[[
	XXTDo script framework based on UI matching

	Basic flow:
		1. Write each recognizable UI as a table containing point-color lists and the run action after matching.
		2. Put these UI tables into the argument table of XXTDo.runloop and set name.
		3. The framework loops through UI matching in order; after a match succeeds, it executes the run action of the current UI.
		4. When the loop needs to exit, call XXTDo.breakloop(...) inside a callback.

	Minimal example:
		local XXTDo = require 'XXTDo'

		XXTDo.runloop {
			name = 'demo_loop',
			csim = 90,
			interval_ms = 100,
			log = sys.log,

			{
				name = 'Home',
				{100, 100, 0xffffff},
				{120, 100, 0x000000},
				run = function(self, index, parent, filter_result)
					XXTDo.log('Matched Home')
					XXTDo.breakloop('done')
				end,
			},
		}

	------------------------------------
	XXTDo.runloop(loop_table)

	loop_table is a UI list and also stores global settings for this loop:
		{
			name        = [string, required, current UI list name],
			csim        = [number, optional, global similarity, default 90],
			interval_ms = [number, optional, delay in milliseconds between detection rounds, default 100],
			log         = [function, optional, log function, prototype: log(log_text); logs are discarded when omitted],
			log_date    = [boolean, optional, when the first log argument is not a table, automatically prefix it with date/time, default false],
			log_language = [string, optional, runtime log language: "auto", "zh", or "en"; default "auto"],
			error       = [function, optional, error handler, prototype: error(error_text); defaults to throwing with error],
			filter      = [function, optional, deprecated UI filter hook; default screen.is_colors],
			match_rules = [table, optional, dispatch filters by each UI's rule, takes priority over filter],
			pre_run     = [function, optional, executed before each detection round, prototype: pre_run(entire_ui_list)],
			post_run    = [function, optional, executed after each detection round, prototype: post_run(entire_ui_list, nil_or_match_result)],
			else_run    = [function, optional, executed when no UI matched in this round, before post_run],
			timeout_s   = [number, optional, global timeout in seconds, default 0 means no timeout],
			timeout_run = [function, optional, global timeout callback, prototype: timeout_run(entire_ui_list, nil_or_match_result)],
			enter       = [function, optional, executed once before entering the loop, prototype: enter(entire_ui_list)],
			finally     = [function, optional, executed once when runloop exits through XXTDo.breakloop; XXTDo.breakloop can override the runloop return values here],
			ui1,
			ui2,
			...
		}

	match_rules format:
		match_rules = {
			xxx = function(self, index, parent)
				-- self is the current UI, index is the current UI index, and parent is the entire UI list.
				-- A truthy first return value means the UI matched; the second return value is passed to run.
			end,
			default = function(self, index, parent)
				-- Used when the current UI has no available rule; when omitted, the framework default matching logic is used (default screen.is_colors, or loop_table.filter when set).
			end,
		}

	UI table format:
		{
			name        = [string, optional, UI name, default ""],
			csim        = [number, optional, per-UI similarity, defaults to loop_table.csim],
			interval_ms = [number, optional, delay in milliseconds after a match, takes priority over loop_table.interval_ms],
			rule        = [string, optional, use the match_rules[rule] filter],
			run         = [function, executed after matching, prototype: run(current_ui, current_index, entire_ui_list, filter_payload)],
			timeout_s   = [number, optional, per-UI timeout, takes priority over global timeout_s, default 0],
			timeout_run = [function, optional, per-UI timeout callback, takes priority over global timeout_run, prototype: timeout_run(entire_ui_list, match_result, filter_payload)],
			group       = [table, optional, multiple point-color lists; matching any group means the current UI matches; each group can set csim separately to override the current UI csim],

			-- When group is not used, write point-color lists directly in the UI table.
			{x, y, color},
			{x, y, color},
			...
		}

	Return value convention for run and timeout_run:
		nil, true, and 'success' mean success;
		false, 'failed', or any other value means failure.
		When a UI run returns failure, this round continues trying subsequent UIs.
		When timeout_run returns failure, the timeout timer is not reset.

	Timeout priority:
		The matched UI's timeout_s takes priority. Only when no UI matched, or the matched UI did not set timeout_s > 0,
		loop_table.timeout_s triggers the global timeout_run.

	Match result table format:
		{
			index = current UI index in the UI list,
			subindex = matched group index; -1 when group is not used,
			ui = current UI table,
		}

	Notes:
		XXTDo.runloop calls screen.keep() before UI matching in every round.
		If a run action changes the screen and the next screen needs to be checked immediately, call screen.keep() again inside run to get the latest screen state.

	------------------------------------
	XXTDo.log(...)

	Log output inside runloop callbacks calls the current loop_table.log.
	If log is not set, logs are discarded; calling it outside runloop has no effect.
	Runtime logs use `log_language = "auto"` by default. In auto mode, `sys.language()` is used; `zh-Hans`, `zh-Hant`, and other `zh*` values use Chinese logs, while other languages use English logs. If `sys.language` is unavailable or fails, Chinese is used.

	------------------------------------
	XXTDo.match_rules_default_super()

	Call inside a custom match_rules.default to forward to the framework's default point-color matching logic.

	------------------------------------
	XXTDo.breakloop(...)

	Exit the current runloop. Passed arguments become the return values of XXTDo.runloop.
	When called in a non-finally callback, the framework first executes finally and passes these arguments to finally.
	finally can call XXTDo.breakloop(...) again to modify the runloop return values.
	Do not call it inside UI filter functions or outside runloop.

	------------------------------------
	XXTDo.config

	Persistently stores simple values: numbers, strings, and booleans.
	These values are saved to the device and can still be read the next time the script starts.

	Usage:
		cfg = XXTDo.config('config_name')   -- Get a config object; the first name passed binds this config as the global config.
		XXTDo.config('config_name').clear() -- Clear the config with the same name.
		XXTDo.config.value = 1              -- Write to the global config.
		a = XXTDo.config.value              -- Read from the global config.

		cfg = XXTDo.config('config_name')
		cfg.clear()
		cfg.value = 1
		a = cfg.value

		cfg2 = XXTDo.config('config_name2') -- Get another config object; if the global config already exists, it will not be overwritten.
		cfg3 = XXTDo.config('config_name')  -- Getting a config object with the same name again returns the same object.

	Notes:
		XXTDo.config and config objects store metadata with hidden indexes, so strings such as data and cfgname can be used directly as config fields.
		clear is a framework-reserved method name.

	------------------------------------
	v0.8.3 [2026-04-30]:
		Added runtime log language selection.
	v0.8.2 [2026-04-27]:
		Fixed XXTDo.config configuration management issues.
		Improved runloop context management.
		Fixed the issue where else_run was not triggered for the last UI when a UI run action returned failure.
		Fixed XXTDo.log not working correctly in enter and finally.
	v0.8.1 [2025-03-01]:
		Fixed checks when name, timeout_s, and group are empty.
	v0.8 [2025-02-28]:
		Added match_rules as a replacement for filter.
		Deprecated the filter hook.
		Added the XXTDo.log framework log function.
		Added default configuration and read cache to XXTDo.config.
	v0.7 [2024-12-17]:
		Fixed ineffective settings when local timeout was greater than global timeout.
	v0.6 [2024-02-28]:
		Used compatible path XXT_HOME_PATH instead of '/var/mobile/Media/1ferver'.
--]]

local _ENV = table.deep_copy(_ENV)
local table_deep_dump = table.deep_dump or table.deep_print
local _M = {}

_M._VERSION = '0.8.3'

local breakloop_token = 'XXTDo.breakloop '..string.sub(string.sha256(string.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 1000)), 7, 16)
local breakloop_tips = breakloop_token
local _LANG_TEXT = {
	en = {
		breakloop_outside = 'Do not call XXTDo.breakloop inside UI filter functions or outside XXTDo.runloop',
		log_exception = 'XXTDo.log raised an exception: %s',
		invalid_runloop_arg = 'Invalid argument passed to XXTDo.runloop\n\n%s',
		missing_name = 'Argument #1 passed to XXTDo.runloop must be a table containing at least a name field\nFor example: {name = "a_name"}\n\n%s',
		callback_runtime_error = 'UI loop %s raised a runtime error\n%s',
		filter_breakloop = 'In UI loop %s, %s tried to call XXTDo.breakloop\nXXTDo.breakloop is not allowed in %s',
		filter_runtime_error = 'In UI loop %s, %s raised a runtime error\n%s',
		exit_from_finally = 'Leaving UI matching loop %s from finally',
		enter_loop = 'Entering UI matching loop %s',
		exit_from_enter = 'Leaving UI matching loop %s from enter',
		exit_from_pre_run = 'Leaving UI matching loop %s from pre_run',
		matched = 'Matched %s %s %q',
		exit_from_ui = 'Leaving UI matching loop %s from %s %q',
		ui_timeout = 'Matching loop %s UI %s %q timed out',
		timeout_return = '%s timeout callback returned %s',
		exit_from_ui_timeout = 'Leaving UI matching loop %s from timeout callback of %s %q',
		exit_from_else_run = 'Leaving UI matching loop %s from else_run',
		invalid_ui = 'UI list %s has invalid UI at index [%d]',
		exit_from_post_run = 'Leaving UI matching loop %s from post_run',
		no_ui_timeout = 'Matching loop %s timed out without a matched UI',
		global_timeout_return = '%s timeout callback returned %s',
		exit_from_global_timeout = 'Leaving UI matching loop %s from global timeout callback without a matched UI',
	},
	zh = {
		breakloop_outside = '请不要在界面过滤器函数或 XXTDo.runloop 外部执行 XXTDo.breakloop',
		log_exception = 'XXTDo.log 发生异常: %s',
		invalid_runloop_arg = '给 XXTDo.runloop 传递的参数不合法\n\n%s',
		missing_name = '给 XXTDo.runloop 参数 #1 需要至少包含 name 字段的表\n例如 {name = "一个名字"}\n\n%s',
		callback_runtime_error = '界面循环 %s 发生运行期错误\n%s',
		filter_breakloop = '尝试在界面循环 %s 的 %s 函数使用 XXTDo.breakloop\n%s 函数中不允许使用 XXTDo.breakloop',
		filter_runtime_error = '界面循环 %s 的 %s 函数发生运行期错误\n%s',
		exit_from_finally = '从 finally 跳出界面匹配循环 %s',
		enter_loop = '开始进入界面匹配循环 %s',
		exit_from_enter = '从 enter 跳出界面匹配循环 %s',
		exit_from_pre_run = '从 pre_run 跳出界面匹配循环 %s',
		matched = '匹配 %s %s %q',
		exit_from_ui = '从界面匹配循环 %s 的 %s %q 跳出',
		ui_timeout = '界面匹配循环 %s 的 %s %q 超时',
		timeout_return = '%s 超时回调返回 %s',
		exit_from_ui_timeout = '从界面匹配循环 %s 的 %s %q 超时回调跳出',
		exit_from_else_run = '从 else_run 跳出界面匹配循环 %s',
		invalid_ui = '界面列表 %s 中编号为 [%d] 的界面不是一个合法的界面',
		exit_from_post_run = '从 post_run 跳出界面匹配循环 %s',
		no_ui_timeout = '界面匹配循环 %s 未匹配任何界面而超时',
		global_timeout_return = '%s 超时回调返回 %s',
		exit_from_global_timeout = '未匹配任何界面时，从全局超时回调跳出界面匹配循环 %s',
	},
}

local function _normalize_log_language(language)
	if type(language) ~= 'string' then
		return nil
	end
	local value = string.lower(language)
	if value == 'auto' or value == 'system' or value == 'device' or value == '' then
		return nil
	elseif value == 'cn' or value == 'chinese' or string.sub(value, 1, 2) == 'zh' then
		return 'zh'
	elseif value == 'english' or string.sub(value, 1, 2) == 'en' then
		return 'en'
	end
end

local function _device_log_language()
	if type(sys) ~= 'table' or type(sys.language) ~= 'function' then
		return 'zh'
	end
	local ok, language = pcall(sys.language)
	if not ok or type(language) ~= 'string' or language == '' then
		return 'zh'
	end
	return string.sub(string.lower(language), 1, 2) == 'zh' and 'zh' or 'en'
end

local function _resolve_log_language(language)
	return _normalize_log_language(language) or _device_log_language()
end

local function _text(language, key)
	local lang = language == 'en' and 'en' or 'zh'
	return (_LANG_TEXT[lang] and _LANG_TEXT[lang][key]) or _LANG_TEXT.en[key] or key
end

local function _format(language, key, ...)
	return string.format(_text(language, key), ...)
end

local function _dummy(...)
end
local function _dumpvarshort(v)
	return json.encode(table.load_string(table_deep_dump(v)))
end
local function _isbreakerr(errmsg)
	return type(errmsg) == 'string' and #(string.split(errmsg, breakloop_tips)) > 1
end
local function _datetime(tm)
	return os.date('%Y-%m-%d %H:%M:%S', tm)
end

local lfs = require('lfs')

-- Simple data storage implementation
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

-- Loop exit implementation
function _M.breakloop(...)
	local ctx = _current_runloop_context()
	if type(ctx) == 'table' then
		ctx.breakloop_results = _packvarargs(...)
	else
		error(_format(_resolve_log_language(), 'breakloop_outside')..' '..breakloop_token, 2)
	end
	error(breakloop_tips, 2)
end

-- Log function implementation
function _M.log(...)
	local ctx = _current_runloop_context()
	local ok, errmsg = pcall(type(ctx) == 'table' and ctx.current_log_func or _dummy, ...)
	if not ok then
		local language = type(ctx) == 'table' and ctx.log_language or _resolve_log_language()
		error(_format(language, 'log_exception', errmsg), 2)
	end
end

-- Forward to filter from any rule
function _M.match_rules_default_super()
	local ctx = _current_runloop_context()
	if type(ctx) == 'table' and type(ctx.current_match_rules_default) == 'function' then
		return ctx.current_match_rules_default(table.unpack(ctx.current_ui_state))
	end
end

-- Main runloop implementation
function _M.runloop(orig_loop_table)
	if type(orig_loop_table) ~= 'table' then
		error(_format(_resolve_log_language(), 'invalid_runloop_arg', debug.traceback()), 2)
	end
	local loop_table = table.deep_copy(orig_loop_table)
	local _L = {}
	_L.log_language = _resolve_log_language(loop_table.log_language)
	_L.log = _dummy
	_L.error = error
	_L.filter = screen.is_colors
	_L.interval_ms = 100
	_L.timeout_s = 0
	_L.timeout_run = _dummy
	_L.loop_name = type(loop_table.name) == 'string' and loop_table.name or nil
	if type(_L.loop_name) ~= 'string' then
		error(_format(_L.log_language, 'missing_name', debug.traceback()), 2)
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
					error = _format(_L.log_language, 'callback_runtime_error', _L.loop_name, errmsg),
					time = _datetime(),
					UI = UI,
				}, 3)
				return 'failed' -- If the callback throws but the script does not end, return failed.
			else
				local ret = rets[2]
				if ret == nil or ret == true or ret == 'success' then
					return 'success' -- nil, true, or 'success' from a UI action means the match succeeded; otherwise it failed without interrupting this round.
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
						error = _format(_L.log_language, 'filter_breakloop', _L.loop_name, rule_name, rule_name),
						time = _datetime(),
						UI = rule_name,
					}, 3)
				else
					_L.error(_dumpvarshort{
						error = _format(_L.log_language, 'filter_runtime_error', _L.loop_name, rule_name, errmsg),
						time = _datetime(),
						UI = rule_name,
					}, 3)
				end
				return rets -- If the filter throws but the script does not end, treat it as not matched.
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
	ctx.log_language = _L.log_language
	local call_results = _packvarargs(xpcall(function()
		_L.timer_begin_time    = os.time()
		_L.timer_last_found    = -1 -- -1 means no UI matched.
		_L.timer_current_found = -1 -- -1 means no UI matched.
		ctx.current_log_func = _log_func
		ctx.current_match_rules_default = _match_rules_default
		local function to_finally()
			if _callifexists('finally', loop_table.finally, loop_table, _unpack_breakloop_results(ctx)) == 'breakloop' then
				_log_func(_format(_L.log_language, 'exit_from_finally', _L.loop_name))
			end
			ctx.current_log_func = _dummy
			return _unpack_breakloop_results(ctx)
		end
		_log_func(_format(_L.log_language, 'enter_loop', _L.loop_name))
		if (_callifexists('enter', loop_table.enter, loop_table) == 'breakloop') then
			_log_func(_format(_L.log_language, 'exit_from_enter', _L.loop_name))
			return to_finally()
		end
		while (true) do
			local _current_interval_ms = tonumber(loop_table.interval_ms) or _L.interval_ms
			screen.keep()
			sys.msleep(2)
			ctx.current_log_func = _log_func
			ctx.current_match_rules_default = _match_rules_default
			if (_callifexists('pre_run', loop_table.pre_run, loop_table) == 'breakloop') then
				_log_func(_format(_L.log_language, 'exit_from_pre_run', _L.loop_name))
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
						_log_func(_format(_L.log_language, 'matched', _L.loop_name, idxstr, currentui_name))
						local runstat = _callifexists({ui = currentui, index = idx, subindex = subindex}, currentui.run, currentui, idx, loop_table, filter_results[2])
						if (runstat == 'breakloop') then
							_log_func(_format(_L.log_language, 'exit_from_ui', _L.loop_name, idxstr, currentui_name))
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
								_log_func(_format(_L.log_language, 'ui_timeout', _L.loop_name, idxstr, currentui_name))
								local timeout_run_results = _callifexists({ui = currentui, index = idx, subindex = subindex}, timeout_run, loop_table, foundui, filter_results[2])
								_log_func(_format(_L.log_language, 'timeout_return', _L.loop_name, timeout_run_results))
								if (timeout_run_results == 'success') then
									_L.timer_begin_time = os.time()
								elseif (timeout_run_results == 'breakloop') then
									_log_func(_format(_L.log_language, 'exit_from_ui_timeout', _L.loop_name, idxstr, currentui_name))
									return to_finally()
								end
							end
							break
						end
					end
					if (not run_success) and #loop_table == idx then
						_L.timer_current_found = -1
						if (_callifexists('else_run', loop_table.else_run, loop_table) == 'breakloop') then
							_log_func(_format(_L.log_language, 'exit_from_else_run', _L.loop_name))
							return to_finally()
						end
					end
				else
					_L.error(_dumpvarshort{
						error = _format(_L.log_language, 'invalid_ui', _L.loop_name, idx),
						time = _datetime(),
						UI = currentui,
					}, 2)
				end
			end
			if (_callifexists('post_run', loop_table.post_run, loop_table, foundui) == 'breakloop') then
				_log_func(_format(_L.log_language, 'exit_from_post_run', _L.loop_name))
				return to_finally()
			end
			if (_L.timer_current_found ~= _L.timer_last_found) then
				_L.timer_last_found = _L.timer_current_found
				_L.timer_begin_time = os.time()
			elseif (_L.timeout_s > 0 and os.difftime(os.time(), _L.timer_begin_time) > _L.timeout_s) then
				local matched_ui_has_timeout_s = type(foundui) == 'table' and type(foundui.ui) == 'table' and (tonumber(rawget(foundui.ui, 'timeout_s')) or 0) > 0
				if not matched_ui_has_timeout_s then -- The timeout configuration of the matched UI takes priority over the global timeout configuration.
					_log_func(_format(_L.log_language, 'no_ui_timeout', _L.loop_name))
					local timeout_run_results = _callifexists('global_timeout_run', _L.timeout_run, loop_table, foundui)
					_log_func(_format(_L.log_language, 'global_timeout_return', _L.loop_name, timeout_run_results))
					if (timeout_run_results == 'success') then
						_L.timer_begin_time = os.time()
					elseif (timeout_run_results == 'breakloop') then
						_log_func(_format(_L.log_language, 'exit_from_global_timeout', _L.loop_name))
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
