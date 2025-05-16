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
			log_date    = [布尔型，可选，日志信息第一个参数前是否额外附带日期时间，日志函数第一个参数为字符串值时才会附带，默认 否],
			error       = [函数型，可选，错误处理函数，函数原型：error(错误文本) 无返回，默认 error（抛出错误）],
			filter      = [弃用，函数型，可选，界面过滤器函数，函数原型：filter(表型界面信息, 范围0~100相似度, {loop_table = 整个界面列表, ui = 表型当前界面信息, index = 当前界面在界面列表中的索引, subindex = 当前匹配的分组子界面索引}) 第一个返回值返回真表示界面匹配，默认 screen.is_colors],
			match_rules = { -- match_rules 设置优先于 filter 设置，若界面匹配 match_rules 任意规则则不再尝试使用 filter 匹配
				xxx     = [函数型，可选，rule 为 xxx 的界面过滤器函数，第一个返回值为 true 则表示当前界面匹配，函数原型：xxx(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表) 返回值预期：布尔值, 其它值],
				yyy     = [函数型，可选，rule 为 yyy 的界面过滤器函数，第一个返回值为 true 则表示当前界面匹配，函数原型：yyy(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表) 返回值预期：布尔值, 其它值],
				zzz     = [函数型，可选，rule 为 zzz 的界面过滤器函数，第一个返回值为 true 则表示当前界面匹配，函数原型：zzz(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表) 返回值预期：布尔值, 其它值],
				default = [函数型，可选，默认界面过滤器函数，当界面 rule 不符合其它过滤器时使用，默认将使用原 filter 匹配],
				...
			},
			pre_run     = [函数型，可选，每轮检测前需要执行的函数，函数原型：pre_run(整个界面列表) 无返回，默认空函数],
			post_run    = [函数型，可选，每轮检测后需要执行的函数，函数原型：post_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 无返回，默认空函数],
			else_run    = [函数型，可选，每轮所有界面都不匹配的的情况下需要执行的函数，在 post_run 之前执行，函数原型：else_run(整个界面列表) 无返回，默认空函数],
			timeout_s   = [实数型，可选，全局任意界面或不匹配超时时间，单位秒，默认 0 不超时],
			timeout_run = [函数型，可选，全局任意界面超时后的回调函数，函数原型：timeout_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 这个函数可以按需显式返回 false 或 'failed' 表示处理超时失败不重置超时计时器，默认空函数],
			enter       = [函数型，可选，进入界面循环之前会调用该函数一次，函数原型：enter(整个界面列表) 无返回，默认空函数],
			finally     = [函数型，可选，跳出界面循环（XXTDo.breakloop）之前会调用该函数一次，函数原型：finally(整个界面列表[, XXTDo.breakloop 的参数列表]) 无返回，但它可以再次调用 XXTDo.breakloop 来更改 runloop 的返回值，默认空函数],
			{
				name        = [文本型，可选，当前匹配的界面名，默认 ""],
				csim        = [实数型，可选，当前界面相似度，不填默认取界面列表全局相似度],
				rule        = [文本型，可选，当前界面的类型，表示对该界面将会使用 match_rules[rule] 过滤器，不设置则使用 match_rules.default 过滤器],
				run         = [函数型，匹配到当前界面后需要执行的函数，函数原型：run(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表, 过滤器第二个返回值) 这个函数可以按需显式返回 false 或 'failed' 表示匹配该界面失败],
				timeout_s   = [实数型，可选，当前界面停留超时时间，优先权高于全局界面超时时间，单位秒，默认 0 不超时],
				timeout_run = [函数型，可选，当前界面超时后的回调函数，优先权高于全局界面超时回调函数，函数原型：timeout_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 这个函数可以按需显式返回 false 或 'failed' 表示处理超时失败不重置超时计时器，默认取界面列表全局 timeout_run],
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
				rule        = [文本型，可选，当前界面的类型，表示对该界面将会使用 match_rules[rule] 过滤器，不设置则使用 match_rules.default 过滤器],
				run         = [函数型，匹配到当前界面后需要执行的函数，函数原型：run(表型当前界面信息, 当前界面在界面列表中的索引, 整个界面列表, 过滤器第二个返回值) 这个函数可以按需显式返回 false 或 'failed' 表示匹配该界面失败],
				timeout_s   = [实数型，可选，当前界面停留超时时间，优先权高于全局界面超时时间，单位秒，默认 0 不超时],
				timeout_run = [函数型，可选，当前界面超时后的回调函数，优先权高于全局界面超时回调函数，函数原型：timeout_run(整个界面列表, nil 或 {index = 当前界面在界面列表中的索引, ui = 表型当前界面信息}) 这个函数可以按需显式返回 false 或 'failed' 表示处理超时失败不重置超时计时器，默认取界面列表全局 timeout_run],
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
	XXTDo.log(...) 日志函数
	该函数可使用当前配置的日志函数输出日志，如果没有配置日志函数，则日志会被丢弃
	该函数在 runloop 之外调用没有任何效果
	用法：
		XXTDo.log('你好世界')

	------------------------------------
	XXTDo.match_rules_default_super() 将匹配规则转发到原来的 filter 中
	当 match_rules.default 被覆盖实现后，如果还需要使用原来的 match_rules.default 则可使用该函数
	该函数只应当在自定义实现的 match_rules.default 中调用
	用法：
		XXTDo.match_rules_default_super()

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

	说明：
		XXTDo.runloop 每一轮匹配都会使用一次 screen.keep() 然后再进行界面匹配，因此，如果匹配的 run 动作中若有操作会引起画面变动并需要进一步判断，可在 run 动作中再次使用 screen.keep() 以获取最新的屏幕状态

	------------------------------------
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

_M._VERSION = '0.8.1'

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
local function _conf_file_path(self)
	local cfgfilename = cfgfiledir..rawget(self, 'cfgname')..'.XXTDoConfig'
	return cfgfilename
end
local function _conf_meta_load(self, key)
	local tab = _ensure_a_table(rawget(self, 'data'), function ()
		local cfgfilename = _conf_file_path(self)
		return json.decode(file.reads(cfgfilename) or '{}')
	end)
	return tab[key]
end
local function _conf_meta_save(self, key, value)
	local cfgfilename = _conf_file_path(self)
	local tab = _ensure_a_table(rawget(self, 'data'), function ()
		return json.decode(file.reads(cfgfilename) or '{}')
	end)
	tab[key] = value
	rawset(self, 'data', tab)
	file.writes(cfgfilename, json.encode(table.load_string(table.deep_print(tab))))
	return value
end
local function _conf_meta_tostring(self)
	local tab = _ensure_a_table(rawget(self, 'data'), function ()
		local cfgfilename = _conf_file_path(self)
		return json.decode(file.reads(cfgfilename) or '{}')
	end)
	if tab then
		return string.format('<XXTDo.config %q>: %s', rawget(self, 'cfgname'), json.encode(tab))
	else
		return string.format('<XXTDo.config %q>: %s', rawget(self, 'cfgname'), '{}')
	end
end
local _confmeta = {
	__call = function(self, name)
		name = type(name) == 'string' and name or '_____config_____'
		local ret = {
			clear = function()
				rawset(self, 'data', tab)
				local cfgfilename = cfgfiledir..name..'.XXTDoConfig'
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
_M.config = {cfgname = '_____config_____'}
setmetatable(_M.config, _confmeta)

local _TMP = {}

_TMP.current_ui_state = {{}, 0, {}}

-- 跳出循环实现
function _M.breakloop(...)
	local argv = {...}
	_TMP.defer_unpack_breakloop_results = function()
		return table.unpack(argv)
	end
	error(breakloop_tips, 2)
end

-- 日志函数实现
function _M.log(...)
	local ok, errmsg = pcall(type(_TMP.current_log_func) == 'function' and _TMP.current_log_func or _dummy, ...)
	if not ok then
		error(string.format('XXTDo.log 发生异常: %s', errmsg), 2)
	end
end

-- 在任何 rule 中转发到 filter
function _M.match_rules_default_super()
	if type(_TMP.current_match_rules_default) == 'function' then
		return _TMP.current_match_rules_default(table.unpack(_TMP.current_ui_state))
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
	_L.timer_begin_time    = os.time()
	_L.timer_last_found    = -1 -- -1 表示没匹配任何界面
	_L.timer_current_found = -1 -- -1 表示没匹配任何界面
	local function to_finally()
		local unpack_breakloop_results = _TMP.defer_unpack_breakloop_results
		if _callifexists('finally', loop_table.finally, loop_table, unpack_breakloop_results()) == 'breakloop' then
			_log_func(string.format('从 finally 跳出界面匹配循环 %s', _L.loop_name))
			unpack_breakloop_results = _TMP.defer_unpack_breakloop_results
		end
		_TMP.current_log_func = _dummy
		if type(unpack_breakloop_results) == 'function' then
			return unpack_breakloop_results()
		end
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
		_TMP.current_log_func = _log_func
		_TMP.current_match_rules_default = _match_rules_default
		if (_callifexists('pre_run', loop_table.pre_run, loop_table) == 'breakloop') then
			_log_func(string.format('从 pre_run 跳出界面匹配循环 %s', _L.loop_name))
			return to_finally()
		end
		local foundui = nil
		local filter_results = nil
		local match_rules = _L.match_rules
		local current_ui_state = _TMP.current_ui_state
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
				elseif #loop_table == idx then
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
end

return _M