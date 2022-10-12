local function digit_to(n,s)
	assert(type(n)=="number", "arg #1 error: need a number value.")
	assert(type(s)=="string", "arg #2 error: need a string value.")
	assert((#s)>1, "arg #2 error: too short.")
	local fl = math.floor
	local i = 0
	while 1 do
		if n>(#s)^i then
			i = i + 1
		else
			break
		end
	end
	local ret = ""
	while i>=0 do
		if n>=(#s)^i then
			local tmp = fl(n/(#s)^i)
			n = n - tmp*(#s)^i
			ret = ret..s:sub(tmp+1, tmp+1)
		else
			if ret~="" then
				ret = ret..s:sub(1, 1)
			end
		end
		i = i - 1
	end
	return ret
end

local function to_digit(ns,s)
	assert(type(ns)=="string", "arg #1 error: need a string value.")
	assert(type(s)=="string", "arg #2 error: need a string value.")
	assert((#s)>1, "arg #2 error: too short.")
	local ret = 0
	for i=1,#ns do
		local fd = s:find(ns:sub(i,i))
		if not fd then
			return nil
		end
		fd = fd - 1
		ret = ret + fd*((#s)^((#ns)-i))
	end
	return ret
end

local function s2h(str,spacer)return (string.gsub(str,"(.)",function (c)return string.format("%02x%s",string.byte(c), spacer or"")end))end
local function h2s(h)return(h:gsub("(%x%x)[ ]?",function(w)return string.char(tonumber(w,16))end))end

local function utf8decode(us)
	local u16p = {
		0xdc00,
		0xd800,
	}
	local u16b = 0x3ff
	local u16fx = ""
	local padl = {
		["0"] = 7,
		["1"] = 11,
		["11"] = 16,
		["111"] = 21,
	}
	local padm = {}
	for k,v in pairs(padl) do
		padm[v] = k
	end
	local map = {7,11,16,21}
	return (string.gsub(us, "\\[Uu](%x%x%x%x)", function(uc)
		local ud = tonumber(uc,16)
		for i,v in ipairs(u16p) do
			if ud>=v and ud<(v+u16b) then
				ud = ud - v + (i-1) * 0x40
				if (i-1)>0 then
					u16fx = digit_to(ud, "01")
					return ""
				end
				local bi = digit_to(ud, "01")
				uc = string.format("%x", to_digit(u16fx..string.rep("0",10-#bi)..bi,"01"))
				u16fx = ""
				ud = tonumber(uc,16)
				break
			end
		end
		local bins = digit_to(ud,"01")
		local pads = ""
		for _,i in ipairs(map) do
			if #bins<=i then
				pads = padm[i]
				break
			end
		end
		while #bins<padl[pads] do
			bins = "0"..bins
		end
		local tmp = ""
		if pads~="0" then
			tmp = bins
			bins = ""
		end
		while #tmp>0 do
			bins = "10"..string.sub(tmp, -6, -1)..bins
			tmp = string.sub(tmp, 1, -7)
		end
		return (string.gsub(string.format("%x", to_digit(pads..bins, "01")), "(%x%x)", function(w)
			return string.char(tonumber(w,16))
		end))
	end))
end

local function unidecode(us,bged)
	local ms
	if bged then
		ms = "\0\\\0[Uu]\0(%x\0%x\0%x\0%x)"
	else
		ms = "\\\0[Uu]\0(%x\0%x\0%x\0%x\0)"
	end
	local tmp = ""
	for i=1,#us do
		if bged then
			tmp = tmp.."\0"..us:sub(i,i)
		else
			tmp = tmp..us:sub(i,i).."\0"
		end
	end
	return (string.gsub(tmp, ms, function(uc)
			uc = uc:gsub("\0", "")
			local h = uc:sub(3,4)
			local l = uc:sub(1,2)
			if bged then
				return h2s(l..h)
			end
			return h2s(h..l)
		end))
end

local function utf8encode(s, upper)
	local uec = 0
	if upper then
		upper = "\\U"
	else
		upper = "\\u"
	end
	local loop1 = string.gsub(s2h(s), "(%x%x)", function(w)
		local wc = tonumber(w,16)
		if wc>0x7F then
			if uec>0 then
				uec = uec - 1
				if uec==0 then
					return w.."/"
				end
				return w
			end
			local bi = digit_to(wc, "01")
			bi = string.sub(bi, 2, -1)
			while string.sub(bi, 1, 1)=="1" do
				bi = string.sub(bi, 2, -1)
				uec = uec + 1
			end
			return "u/"..w
		else
			if uec>0 then
				uec = 0
				return w.."/"
			end
		end
		return w
	end)
	local u16p = {
		0xdc00,
		0xd800,
	}
	local u16id = 0x10000
	local loop2 = string.gsub(loop1, "u/(%x%x*)/", function(w)
		local wc = tonumber(w,16)
		local tmp
		local bi = digit_to(wc, "01")
		tmp = ""
		while #bi>8 do
			tmp = string.sub(bi, -6, -1)..tmp
			bi = string.sub(bi, 1, -9)
		end
		bi = bi..tmp
		while string.sub(bi, 1, 1)=="1" do
			bi = string.sub(bi, 2, -1)
		end
		wc = to_digit(bi, "01")
		if (wc>=u16id) then
			wc = wc - u16id
			tmp = digit_to(wc, "01")
			tmp = string.rep("0", 20-#tmp)..tmp
			local low = to_digit(string.sub(tmp, -10, -1), "01") + u16p[1]
			local high = to_digit(string.sub(tmp, 1, -11), "01") + u16p[2]
			tmp = string.format("%4x", low)
			return s2h(upper..string.format("%4x", high)..upper..string.format("%4x", low))
		end
		local h = string.format("%x", wc)
		-- if (#h)%2~=0 then
		-- 	h = "0"..h
		-- end
		return s2h(upper..h)
	end)
	return h2s(loop2)
end

-- print(utf8decode("\\u4f60\\u597d\\uff0c\\u5c0f\\u7c73\\u624b\\u673a\\u7528\\u6237\\uE415"))

return {
	decode = utf8decode,
	encode = utf8encode,
	_VERSION = "1.0",
	_AUTHOR = "苏泽",
}


