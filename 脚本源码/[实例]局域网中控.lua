local recieve_port = 35452
local socket = require('socket')
local device_list = {}		--创建用于储存的列表
XXT_HOME_PATH = XXT_HOME_PATH or '/var/mobile/Media/1ferver'

local udp_service = socket.udp4()
udp_service:settimeout(0.05)
udp_service:setsockname('*', recieve_port)

function search_device()	--搜索设备
	for i, v in ipairs(device.ifaddrs()) do
		local sender = socket.udp4()
		sender:setsockname(v[2], math.random(40000, 60000))
		sender:setoption("broadcast", true)
		sender:sendto('{"ip":"'..v[2]..'","port":'..recieve_port..'}', "255.255.255.255", 46953)
		sender:close()
	end
	sys.msleep(200)
	while true do
		local receive = udp_service:receivefrom()
		if receive then
			local device_json = json.decode(receive)
			device_list[device_json['deviceid']] = device_json
		else
			break
		end
	end
end
search_device()

while true do
	local tmp_device_name = {}	--创建设备用于展示的列表
	local tmp_device_id = {}	--创建用于索引的列表
	for deviceid, device_json in pairs(device_list) do
		table.insert(
			tmp_device_name,
			device_json['devname'] .. ' ' .. device_json['ip']
		)
		tmp_device_id[device_json['devname'] .. ' ' .. device_json['ip']] = device_json
	end
	local confirm, selects = dialog()
		:add_label('Lua 中控演示')
		:add_radio('操作',{'扫描','启动','停止'})
		:add_checkbox('设备',tmp_device_name)
		:add_radio('脚本',file.list(XXT_HOME_PATH..'/lua/scripts'))
		:show()
	if not confirm then break end
	if selects['操作'] == '扫描' then
		search_device()
	elseif selects['操作'] == '启动' then
		for _, device_name in ipairs(selects['设备']) do
			local state, headers, body = http.post(
				'http://' .. tmp_device_id[device_name]['ip'] .. ':46952/spawn',
				5, {}, file.reads(XXT_HOME_PATH..'/lua/scripts/' .. selects['脚本'])
			)
			if state == 200 then
				local receive_json = json.decode(body)
				if type(receive_json) == 'table' then
					if receive_json.code == 0 then
						sys.toast('成功:' .. receive_json.message)
					else
						sys.toast('失败:' .. receive_json.message)
					end
				end
			else
				sys.toast('失败:超时')
			end
		end
	elseif selects['操作'] == '停止' then
		for _, device_name in ipairs(selects['设备']) do
			local state, headers, body = http.post(
				'http://' .. tmp_device_id[device_name]['ip'] .. ':46952/recycle',
				5, {}, ''
			)
			if state == 200 then
				local receive_json = json.decode(body)
				if type(receive_json) == 'table' then
					if receive_json.code == 0 then
						sys.toast('成功:' .. receive_json.message)
					else
						sys.toast('失败:' .. receive_json.message)
					end
				end
			else
				sys.toast('失败:超时')
			end
		end
	end
end

