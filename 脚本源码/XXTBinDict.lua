--[[

    XXTBinDict.lua

	Created by 苏泽 on 25-05-29.
	Copyright (c) 2025年 苏泽. All rights reserved.

    二值化找图字典模块
    可配合 XXTColorPicker 1.0.28 以上集成的 XXT-Bin-Dict 自定义格式开发

    更新日志：
    0.2.4 2025-06-28 优化 screen_ocr、image_ocr 识别文字排序
    0.2.3 2025-06-27 修正区域找目标没找到也会返回一个正数坐标的问题
    0.2.2 2025-06-23 修正 touchelf_dict_init
    0.2.1 2025-06-01 修正 image_find 和 screen_find 不支持 auto 模式二值化的问题
    0.2.0 2025-05-31 支持 XXTColorPicker 1.0.29 内置的 XXT-Bin-Dict 的 auto 模式的二值化选项
    0.1.0 2025-05-29 初始版本

    引入模块:
    local XXTDict = require("XXTBinDict")

    初始化字典:
    local dict = XXTDict.init{
        {"LINE", {csim_mode=true,{0xffffff,90},}, image.load_file(XXT_RES_PATH.."/LINE.png")};
        {"TrollStore", {csim_mode=true,{0xffffff,90},}, image.load_file(XXT_RES_PATH.."/TrollStore.png")};
    }

    从屏幕(区域)找到字典中的词：
    x, y = dict:screen_find("LINE", {confidence_threshold = 90}, 左, 上, 右, 下)

    从图片上找到字典中的词：
    x, y = dict:image_find(image.load_file(XXT_SCRIPTS_PATH.."/1.png"), "LINE", {confidence_threshold = 90})

    识别屏幕(区域)所有的字典中有的词：
    local text, info = dict:screen_ocr(百分制可信度, 左, 上, 右, 下)

    识别图片上所有的字典中有的词：
    local text, info = dict:image_ocr(image.load_file(XXT_SCRIPTS_PATH.."/1.png"), 百分制可信度)
--]]

if sys.xtversion():compare_version("1.3.8-20250501000000") < 0 then
	error('XXTBinDict 模块仅支持 XXT 1.3.8-20250501 或以后的版本')
end

local check_value = functor.argth.check_value
local opt_value = functor.argth.opt_value
local error = error
local ipairs = ipairs
local setmetatable = setmetatable
local type = type
local select = select
local rawget = rawget
local tonumber = tonumber
local tostring = tostring

local function _xxt_dict_image_find(...) -- (self, img, name, opt, start_x, start_y)
    local self = check_value(1, "table", ...)
    local img = select(2, ...)
    if not image.is(img) then
        return error("bad argument #2 to dict_image_find (image_object expected, got "..type(img) .. ")")
    end
    local name = check_value(3, "string", ...)
    local opt = opt_value(4, "number.table", rawget(self, "dict_confidence_threshold"), ...)
    local start_x = opt_value(5, "number", 0, ...)
    local start_y = opt_value(6, "number", 0, ...)
    local name_dict = rawget(self, "name_dict")
    local info = name_dict[name]
    if not info then
        return error("dict_image_find 没有字段 "..name)
    end
    if type(opt) == 'number' then
        opt = {downscale = rawget(self, "dict_donwscale"), confidence_threshold = opt}
    else
        opt.downscale = rawget(self, "dict_donwscale")
    end
    local bin_img
    if type(info[2]) == "string" and info[2] == "auto" then
        bin_img = img:binaryzation()
    else
        bin_img = img:binaryzation(info[2])
    end
    local found_rets = {bin_img:find_image(info[3], opt)}
    if type(found_rets[1]) == 'number' then
        if found_rets[1] > 0 then
            found_rets[1] = found_rets[1] + start_x
            found_rets[2] = found_rets[2] + start_y
        end
    else
        for _, v in ipairs(found_rets[1]) do
            v.x = v.x + start_x
            v.y = v.y + start_y
        end
    end
    return table.unpack(found_rets)
end

local function _xxt_dict_image_detect(...) -- (self, img, opt, start_x, start_y)
    local self = check_value(1, "table", ...)
    local img = select(2, ...)
    if not image.is(img) then
        return error("bad argument #2 to dict_image_detect (image_object expected, got "..type(img) .. ")")
    end
    local opt = opt_value(3, "number.table", {find_all = true, confidence_threshold = rawget(self, "dict_confidence_threshold")}, ...)
    local start_x = opt_value(4, "number", 0, ...)
    local start_y = opt_value(5, "number", 0, ...)
    local dict = rawget(self, "dict")
    local bin_img
    local rets = {}
    for _, dict_v in ipairs(dict) do
        if not bin_img then
            if type(dict_v[2]) == "string" and dict_v[2] == "auto" then
                bin_img = img:binaryzation()
            else
                bin_img = img:binaryzation(dict_v[2])
            end
        end
        local width, height = dict_v[3]:size()
        local found_rets = {bin_img:find_image(dict_v[3], opt)}
        if type(found_rets[1]) == 'number' then
            if found_rets[1] > 0 then
                local ret = {name = dict_v[1], width = width, height = height, x = found_rets[1] + start_x, y = found_rets[2] + start_y, confidence = opt}
                rets[#rets + 1] = ret
            end
        else
            for _, found_v in ipairs(found_rets[1]) do
                local ret = {name = dict_v[1], width = width, height = height, x = found_v.x + start_x, y = found_v.y + start_y}
                rets[#rets + 1] = ret
            end
        end
    end
    return rets
end

local function _xxt_dict_image_ocr(...) -- (self, img, confidence_threshold, start_x, start_y)
    local self = check_value(1, "table", ...)
    local img = select(2, ...)
    if not image.is(img) then
        return error("bad argument #2 to dict_image_ocr (image_object expected, got "..type(img) .. ")")
    end
    local confidence_threshold = opt_value(3, "number", rawget(self, "dict_confidence_threshold"), ...)
    local start_x = opt_value(4, "number", 0, ...)
    local start_y = opt_value(5, "number", 0, ...)
    local detected = _xxt_dict_image_detect(self, img, {confidence_threshold = confidence_threshold, find_all = true, downscale = rawget(self, "dict_donwscale")}, start_x, start_y)
    local rets = {}
    for i, v in ipairs(detected) do
        rets[#rets + 1] = {
            text = v.name,
            width = v.width,
            height = v.height,
            x = v.x,
            y = v.y,
            top = v.y,
            bottom = v.y + v.height - 1,
            left = v.x,
            right = v.x + v.width - 1
        }
    end
    table.sort(rets, function(a, b)
        if a.bottom < b.top then
            return true
        end
        local function ex_test(a, b)
            if a.right < b.left then
                return true
            else
                if ((b.left - a.left) / a.width) > ((b.top - a.top) / a.height) then
                    return true
                else
                    return false
                end
            end
        end
        if a.top < b.top then
            return ex_test(a, b)
        elseif a.top > b.top then
            return not ex_test(b, a)
        end
        return a.x < b.x
    end)
    local texts_buf = {}
    for i, v in ipairs(rets) do
        texts_buf[#texts_buf + 1] = v.text
        v.top = nil
        v.bottom = nil
        v.left = nil
        v.right = nil
    end
    return table.concat(texts_buf, '\t'), rets
end

local function _xxt_dict_screen_find(...) -- self, name, opt, left, top, right, bottom
    local self = check_value(1, "table", ...)
    local name = check_value(2, "string", ...)
    local opt = opt_value(3, "number.table", rawget(self, "dict_confidence_threshold"), ...)
    local left = opt_value(4, "number", 0, ...)
    local top = opt_value(5, "number", 0, ...)
    local w, h = screen.size()
    local right = opt_value(6, "number", w-1, ...)
    local bottom = opt_value(7, "number", h-1, ...)
    return _xxt_dict_image_find(self, screen.image(left, top, right, bottom), name, opt, left, top)
end

local function _xxt_dict_screen_detect(...) -- (self, opt, left, top, right, bottom)
    local self = check_value(1, "table", ...)
    local opt = opt_value(2, "number.table", {find_all = true, confidence_threshold = rawget(self, "dict_confidence_threshold"), downscale = rawget(self, "dict_donwscale")}, ...)
    local left = opt_value(3, "number", 0, ...)
    local top = opt_value(4, "number", 0, ...)
    local w, h = screen.size()
    local right = opt_value(5, "number", w-1, ...)
    local bottom = opt_value(6, "number", h-1, ...)
    return _xxt_dict_image_detect(self, screen.image(left, top, right, bottom), opt, left, top)
end

local function _xxt_dict_screen_ocr(...) -- (self, confidence_threshold, left, top, right, bottom)
    local self = check_value(1, "table", ...)
    local confidence_threshold = opt_value(2, "number", rawget(self, "dict_confidence_threshold"), ...)
    local left = opt_value(3, "number", 0, ...)
    local top = opt_value(4, "number", 0, ...)
    local w, h = screen.size()
    local right = opt_value(5, "number", w-1, ...)
    local bottom = opt_value(6, "number", h-1, ...)
    return _xxt_dict_image_ocr(self, screen.image(left, top, right, bottom), confidence_threshold, left, top)
end

local function _xxt_dict_set_donwscale(...) -- (self, downscale)
    local self = check_value(1, "table", ...)
    local downscale = check_value(2, "number", ...)
    if downscale < 0.1 then
        downscale = 0.1
    elseif downscale > 1 then
        downscale = 1
    elseif tostring(downscale) == tostring(0/0) then
        downscale = 1
    end
    rawset(self, "dict_donwscale", downscale)
end

local function _xxt_dict_set_confidence_threshold(...) -- (self, confidence_threshold)
    local self = check_value(1, "table", ...)
    local confidence_threshold = check_value(2, "number", ...)
    if confidence_threshold < 1 then
        confidence_threshold = 1
    elseif confidence_threshold > 100 then
        confidence_threshold = 100
    elseif tostring(confidence_threshold) == tostring(0/0) then
        confidence_threshold = 80
    end
    rawset(self, "dict_confidence_threshold", confidence_threshold)
end

local _xxt_dict_meta = {
    __index = {
        image_find = _xxt_dict_image_find;
        image_detect = _xxt_dict_image_detect;
        image_ocr = _xxt_dict_image_ocr;
        screen_find = _xxt_dict_screen_find;
        screen_detect = _xxt_dict_screen_detect;
        screen_ocr = _xxt_dict_screen_ocr;
        set_donwscale = _xxt_dict_set_donwscale;
        set_confidence_threshold = _xxt_dict_set_confidence_threshold;
    };
}

local _M = {
    _VERSION = "0.2.4";
}

function _M.init(...)
    local dict = check_value(1, "table", ...)
	local ret = {
        dict_donwscale = 1;
        dict_confidence_threshold = 80;
    }
    dict = table.deep_copy(dict)
    ret.dict = dict
    for i, v in ipairs(dict) do
        local name = v[1]
        if type(name) ~= "string" then
            return error("dict["..i.."] "..name.." name must be string")
        end
        if type(v[2]) ~= "table" and type(v[2]) ~= "string" then
            return error("dict["..i.."] "..name.." binopt must be table")
        end
        if type(v[2]) == "string" then
            local binopt = {}
            for _, co in ipairs(v[2]:split(",")) do
                co = co:split("-")
                if #co ~= 2 then
                    return error("dict["..i.."] "..name.." binopt must be table")
                end
                local c, o = tonumber(co[1], 16), tonumber(co[2], 16)
                if not c or not o then
                    return error("dict["..i.."] "..name.." binopt must be table")
                end
                binopt[#binopt + 1] = {c, o}
            end
            v[2] = binopt
        else
            for binopt_i, cso in ipairs(v[2]) do
                if type(cso) ~= "table" then
                    return error("dict["..i.."]["..binopt_i.."] "..name.." must be table")
                end
                if type(cso[1]) ~= "number" then
                    return error("dict["..i.."]["..binopt_i.."][1] "..name.." must be number")
                end
                if type(cso[2]) ~= "number" then
                    return error("dict["..i.."]["..binopt_i.."][2] "..name.." must be number")
                end
            end
        end
        if #(v[2]) < 1 then
            return error("dict["..i.."] "..name.." binopt size must > 0")
        end
        if not image.is(v[3]) then
            local img = image.load_data(v[3])
            if img then
                goto continue
            end
            img = image.load_file(v[3])
            if img then
                goto continue
            end
            img = image.load_file(XXT_RES_PATH.."/"..v[3])
            if img then
                goto continue
            end
            return error("dict["..i.."] "..tostring(v[1]).." image load failed")
        end
        ::continue::
    end
    ret.name_dict = {}
    for i, v in ipairs(dict) do
        ret.name_dict[v[1]] = v
    end
    return setmetatable(ret, _xxt_dict_meta)
end
local _xxt_dict_init = _M.init

function _M.touchelf_dict_init(...)
    local tedict = check_value(1, "table", ...)
    local dict = {}
    for i, te_v in ipairs(tedict) do
        local binopt = {
            csim_mode = true;
            csim_algorithm = 2;
            white_background = true;
        }
        for _,te_v_binopt in ipairs(te_v[2]) do
            binopt[#binopt + 1] = {te_v_binopt, te_v[3]}
        end
        local img = image.load_data(te_v[4]:base64_decode())
        if not img then
            return error("dict["..i.."] "..tostring(te_v[1]).." image load failed")
        end
        dict[#dict + 1] = {te_v[1], binopt, img}
    end
	return _xxt_dict_init(dict)
end

return _M