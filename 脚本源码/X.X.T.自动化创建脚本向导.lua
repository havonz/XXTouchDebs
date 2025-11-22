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
end

if type(dialog) == 'table' then
	dialog.engine = 'xui'
	-- dialog.engine = 'webview'
end

function is_webview_dialog()
	return (type(dialog) == 'table' and dialog.engine == 'webview') or type(dialog) == 'function'
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

local XXT_HOME_PATH = XXT_HOME_PATH or '/var/mobile/Media/1ferver'

function ms_make(filename)
	if not package.preload["XXTDo"] then
		package.preload["XXTDo"] = loadfile(XXT_HOME_PATH..'/lua/XXTDo.lua')
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
	info.w = tonumber(info.w) or (str_wide(info.title) * 9.125 + 48)
	info.h = tonumber(info.h) or 44
	info.w = info.w * factor
	info.h = info.h * factor
	info.x = tonumber(info.x) or (scr_w - info.w) / 2
	info.y = tonumber(info.y) or (scr_h  - 140 * factor)
	if info.callback then
		set_event_callback(info.msg, info.callback)
	end
	webview.show{
		html = [[
	    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
		<html>
		<head>
		<style>
		html, body {
			margin: 0;
			padding: 0;
			width: 100%;
			height: 100%;
			overflow: hidden;
		}
		body {
			display: flex;
			align-items: center;
			justify-content: center;
		}
		#one_button {
			color: #FFFFFF;
			background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
			text-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3);
			font-family: character, -apple-system, BlinkMacSystemFont, sans-serif;
			font-size: 16px;
			font-weight: 500;
			padding: 12px 24px;
			border-radius: 8px;
			box-shadow: 0 4px 15px rgba(52, 152, 219, 0.3);
			cursor: pointer;
			transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
			display: inline-block;
			text-align: center;
			min-width: 120px;
			width: 100%;
			height: 100%;
			box-sizing: border-box;
			display: flex;
			align-items: center;
			justify-content: center;
			white-space: nowrap;
			position: relative;
			overflow: hidden;
		}
		.ripple {
			position: absolute;
			border-radius: 50%;
			background: rgba(255, 255, 255, 0.6);
			width: 0;
			height: 0;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			animation: ripple-animation 0.6s ease-out;
		}
		@keyframes ripple-animation {
			to {
				width: 200%;
				height: 200%;
				opacity: 0;
			}
		}
		#one_button:active {
			transform: scale(0.95);
			box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
		}
		div { /* 禁止选中文字 */
			-moz-user-select: none;
			-webkit-user-select: none;
			-ms-user-select: none;
			-khtml-user-select: none;
			user-select: none;
		}
		</style>
	    <script src="/js/jquery.min.js"></script>
	    <script src="/js/jquery.json.min.js"></script>
		<script type="text/javascript">
		$(document).ready(function(){
			$("#one_button").click(function(){
				var btn = $(this);
				// 添加点击动画效果
				btn.css({
					'transform': 'scale(0.95)',
					'box-shadow': '0 2px 8px rgba(0, 0, 0, 0.2)'
				});
				
				// 添加波纹效果
				var ripple = $('<span class="ripple"></span>');
				btn.append(ripple);
				
				setTimeout(function() {
					btn.css({
						'transform': 'scale(1)',
						'box-shadow': '0 4px 15px rgba(0, 0, 0, 0.2)'
					});
					ripple.remove();
				}, 300);
				
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
		corner_radius = 5,
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
	info.size = (tonumber(info.size) or 30) * (factor / 2)
	info.x = tonumber(info.x) or (scr_w / 2)
	info.y = tonumber(info.y) or (scr_h / 2)
	info.corner_radius = tonumber(info.corner_radius) or (info.size / factor) * (factor / 2)
	info.title = info.title or info.id
    webview.show{
        html = [[<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><html><head></head>
		<style>
		html, body {
			margin: 0;
			padding: 0;
			width: 100%;
			height: 100%;
			overflow: hidden;
		}
		#one_tile {
			color: #FFFFFF;
			background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
			text-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3);
			font-size: 70vmin;
			text-align: center;
			font-family: character, -apple-system, BlinkMacSystemFont, sans-serif;
			font-weight: 600;
			width: 100%;
			height: 100%;
			display: flex;
			align-items: center;
			justify-content: center;
			box-shadow: 0 4px 15px rgba(52, 152, 219, 0.4);
		}
		div { /* 禁止选中文字 */
			-moz-user-select:none;
			-webkit-user-select:none;
			-ms-user-select:none;
			-khtml-user-select:none;
			user-select:none;
		}
		</style>
		<body><div id="one_tile">]]..tostring(info.id)..[[</div><body></html>]],
        x = info.x - ((info.size/2) * factor);
        y = info.y - ((info.size/2) * factor);
        width = info.size * factor;
        height = info.size * factor;
        corner_radius = info.corner_radius;
        alpha = 0.9;
        animation_duration = 0;
        can_drag = true;
        level = 2060;
        id = info.id;
    }
end

function get_tile_pos(info)
	info.id = tonumber(info.id) or 1
	info.size = (tonumber(info.size) or 30) * (factor / 2)
	info.x = tonumber(info.x) or (scr_w / 2)
	info.y = tonumber(info.y) or (scr_h / 2)
    local frame = webview.frame(info.id) or {x = 0, y = 0, width = 0, height = 0}
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
	confirm_button({y = 80 * factor, id = info.id + 1, title = ' 取消拾取 ', callback = function()
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
	if is_webview_dialog() then
		dlg:set_size(scr_w - 40 * factor, 450 * factor)
	end
	dlg:add_label(eventtitle)
	local bids = app.bundles()
	local appnames = {}
	local appnamemap = {}
	local needshowbid = false
	for i,bid in ipairs(bids) do
		local name = app.localized_name(bid) or bid
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
	if is_webview_dialog() then
		dlg:set_size(scr_w - 40 * factor, 450 * factor)
	end
	dlg:add_label(eventtitle)
	local bids = app.bundles()
	local appnames = {}
	local appnamemap = {}
	local needshowbid = false
	for i,bid in ipairs(bids) do
		local name = app.localized_name(bid) or bid
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
	if is_webview_dialog() then
		dlg:set_size(scr_w - 40 * factor, scr_h - 20 * factor)
	end
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
	local dlg = dialog()
	if is_webview_dialog() then
		dlg:set_size(scr_w - 40 * factor, 300 * factor)
	end
	dlg:title('选择特征')
	dlg:add_radio('你需要判断界面上几处特征？', eventname_list)
	local ok, s = dlg:show()
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
	local dlg = dialog()
	if is_webview_dialog() then
		dlg:set_size(scr_w - 40 * factor, 300 * factor)
	end
	dlg:title('创建事件')
	dlg:add_radio('你想要创建的事件是？', {num_per_line = 1, eventname_start, eventname_enter_ui, eventname_preview})
	local ok, s = dlg:show()
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

proc_queue_clear("webview控件消息") -- 清空需要监听的字典的值
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
