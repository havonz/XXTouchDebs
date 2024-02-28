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

_M._VERSION = '0.6'

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
local XXT_HOME_PATH = XXT_HOME_PATH or '/var/mobile/Media/1ferver'
local homedir = XXT_HOME_PATH..'/'
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