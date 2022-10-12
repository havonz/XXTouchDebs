;(function()
	local w, h = screen.size()

	local factor = 1 -- 默认高度为 2x 设备所设
	if w == 1242 or w == 1080 then
		factor = 1.5 -- iPhone 6(S)+ 的分辨率是 3x 的
	elseif w == 320 or w == 768 then
		factor = 0.5 -- 3Gs 以前的 iPhone 的分辨率是 1x 的
	end
	
	local tips_th
	
	function show_tips(text, timeout)
		local tips_wvid = 719
		if tips_th then
			thread.kill(tips_th)
			tips_th = nil
			webview.hide(tips_wvid)
		end
		timeout = tonumber(timeout) or 0
		timeout = timeout * 1000 + 3000
		text = text:gsub("<", "<")
		text = text:gsub(">", ">")
		text = text:gsub("\n", "</br>")
		webview.show({ -- 创建一个 webview 在顶点
			html = [[<meta name="viewport" content="width=device-width, initial-scale=1.0">
            <html>
			<head>
				<style>
					h5 {
						color: #FFFFFF;
						text-shadow: 0px 0px 10px #000000;
					}
				</style>
			</head>
			<body><center><h5>]]..text..[[</h5></center></body>
			</html>]],
			x = 0, y = 0,
			width = w, height = h - 60 * factor,
			alpha = 1, opaque = false,
			animation_duration = 0,
			ignores_hit = true,
			id = tips_wvid,
		})
		webview.show({ -- 从顶点使用 0.2 秒时间往下滑 30 个坐标单位
			x = 0, y = 30 * factor,
			width = w, height = h - 60 * factor,
			alpha = 1, opaque = false,
			animation_duration = 0.2,
			ignores_hit = true,
			id = tips_wvid,
		})
		tips_th = thread.dispatch(function() -- 创建一个线程
			sys.msleep(timeout - 2200) -- 等待一段时间
			webview.show({ -- 使用 2.2 秒的时间渐隐
				x = 0, y = 30 * factor,
				width = w, height = h - 60 * factor,
				alpha = 0, opaque = false,
				animation_duration = 2.2,
				id = tips_wvid,
			})
			sys.msleep(2200) -- 等待异步的渐隐完成
			webview.hide(tips_wvid) -- 完全隐藏掉 webview
			tips_th = nil
		end)
	end
end)()

show_tips("XXTouch 真棒~~")
sys.msleep(1000)
show_tips("开发讨论QQ群：40898074\n未得原作者许可，可以用于商业用途！", 5)



