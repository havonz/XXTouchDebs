-- 计算二次贝塞尔曲线
local function quadraticBezier(t, p0, p1, p2)
    local x = (1 - t)^2 * p0[1] + 2 * (1 - t) * t * p1[1] + t^2 * p2[1]
    local y = (1 - t)^2 * p0[2] + 2 * (1 - t) * t * p1[2] + t^2 * p2[2]
    return {x, y}
end

-- 计算三次贝塞尔曲线
local function cubicBezier(t, p0, p1, p2, p3)
    local x = (1 - t)^3 * p0[1] + 3 * (1 - t)^2 * t * p1[1] + 3 * (1 - t) * t^2 * p2[1] + t^3 * p3[1]
    local y = (1 - t)^3 * p0[2] + 3 * (1 - t)^2 * t * p1[2] + 3 * (1 - t) * t^2 * p2[2] + t^3 * p3[2]
    return {x, y}
end

-- 计算曲线上的点
local function generatePointsBezier(curveType, points, steps)
    local results = {}
    for i = 0, steps do
        local t = i / steps
        local point
        if curveType == "quadratic" then
            point = quadraticBezier(t, points[1], points[2], points[3])
        elseif curveType == "cubic" then
            point = cubicBezier(t, points[1], points[2], points[3], points[4])
        end
        table.insert(results, point)
    end
    return results
end

function touchMoveUsingBezier(info)
	local fingerId = info.fingerId or 1
	local startPoint = info.startPoint
	local controlPoint = info.controlPoint
	local endPoint = info.endPoint
	local stepLen = info.stepLen or 2
	local stepDelay = info.stepDelay or 1
	local offDelay = info.offDelay or 200
	local steps = (pos(startPoint[1], startPoint[2]):distanceBetween(pos(endPoint[1], endPoint[2]))) // stepLen
	local curvePoints
	if #controlPoint == 4 then
		curvePoints = generatePointsBezier("cubic", {startPoint, {controlPoint[1], controlPoint[2]}, {controlPoint[3], controlPoint[4]}, endPoint}, steps)
	else
		curvePoints = generatePointsBezier("quadratic", {startPoint, controlPoint, endPoint}, steps)
	end
	touch.on(fingerId, startPoint[1], startPoint[2])
	for _, point in ipairs(curvePoints) do
		touch.move(fingerId, point[1], point[2])
	    sys.msleep(stepDelay)
	end
	sys.msleep(offDelay)
	touch.off(fingerId, endPoint[1], endPoint[2])
end

touch.show_pose(true)

for i = 1, 5 do
	touchMoveUsingBezier{
		startPoint = {50, 630},    -- 滑动起始位置
		controlPoint = {255 + i * 15, 500 - i * 50}, -- 控制点，起始位置和结束位置中间的一个或两个坐标，控制曲线曲度
		endPoint = {700, 630},     -- 滑动结束位置
		fingerId = i,              -- 手指 ID，可选参数，默认 1
		stepLen = 2,               -- 每一步步长，可选参数，默认 2
		stepDelay = 1,             -- 每一步的延迟毫秒数，可选参数，默认 1
		offDelay = 200,            -- 到目的地抬起前延迟毫秒数，可选参数，默认 200
	}
	sys.msleep(500)
end

for i = 1, 5 do
	touchMoveUsingBezier{
		startPoint = {50, 630},    -- 滑动起始位置
		controlPoint = {500 - i * 15, 740 + i * 50}, -- 控制点，起始位置和结束位置中间的一个或两个坐标，控制曲线曲度
		endPoint = {700, 630},     -- 滑动结束位置
		fingerId = i,              -- 手指 ID，可选参数，默认 1
		stepLen = 2,               -- 每一步步长，可选参数，默认 2
		stepDelay = 1,             -- 每一步的延迟毫秒数，可选参数，默认 1
		offDelay = 200,            -- 到目的地抬起前延迟毫秒数，可选参数，默认 200
	}
	sys.msleep(500)
end

for i = 1, 5 do
	touchMoveUsingBezier{
		startPoint = {50, 630},    -- 滑动起始位置
		controlPoint = {255 + i * 15, 500 - i * 50, 500 - i * 15, 740 + i * 50}, -- 控制点，起始位置和结束位置中间的一个或两个坐标，控制曲线曲度
		endPoint = {700, 630},     -- 滑动结束位置
		fingerId = i,              -- 手指 ID，可选参数，默认 1
		stepLen = 2,               -- 每一步步长，可选参数，默认 2
		stepDelay = 1,             -- 每一步的延迟毫秒数，可选参数，默认 1
		offDelay = 200,            -- 到目的地抬起前延迟毫秒数，可选参数，默认 200
	}
	sys.msleep(500)
end

