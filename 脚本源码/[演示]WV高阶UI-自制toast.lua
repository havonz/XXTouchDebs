;(function()
	local w, h = screen.size()

	local factor = screen.scale_factor() / 2

	local function html_escape(value)
		value = tostring(value)
		local charmap = {
			['&'] = '&amp;',
			['<'] = '&lt;',
			['>'] = '&gt;',
			['"'] = '&quot;',
			["'"] = '&apos;',
			['\n'] = '<br>',
			[' '] = '&nbsp;',
		}
		value = string.gsub(value, '[ &<>"\'\n]',  function(c)
			return charmap[c]
		end)
		return value
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
		webview.show({ -- 创建一个 webview 在顶点
			html = [[<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <html>
			<head>
				<style>
					* {
						margin: 0;
						padding: 0;
						box-sizing: border-box;
					}
					body {
						display: flex;
						justify-content: center;
						align-items: flex-start;
						padding-top: 20px;
						font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
					}
					.toast {
						background: rgba(40, 40, 40, 0.95);
						backdrop-filter: blur(10px);
						-webkit-backdrop-filter: blur(10px);
						color: #FFFFFF;
						padding: 12px 20px;
						border-radius: 12px;
						box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4), 
									0 2px 8px rgba(0, 0, 0, 0.2);
						font-size: 15px;
						font-weight: 500;
						line-height: 1.4;
						max-width: 85%;
						word-wrap: break-word;
						text-align: center;
						border: 1px solid rgba(255, 255, 255, 0.1);
					}
				</style>
			</head>
			<body>
				<div class="toast">]]..html_escape(text)..[[</div>
			</body>
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
			sys.msleep(timeout - 300) -- 等待一段时间
			webview.show({ -- 使用 0.3 秒的时间往上缩回屏幕外
				x = 0, y = -(h - 60 * factor),
				width = w, height = h - 60 * factor,
				alpha = 1, opaque = false,
				animation_duration = 0.3,
				id = tips_wvid,
			})
			sys.msleep(300) -- 等待异步的动画完成
			webview.hide(tips_wvid) -- 完全隐藏掉 webview
			tips_th = nil
		end)
	end
end)()

show_tips("XXTouch 真棒~~")
sys.msleep(1000)
show_tips("开发讨论QQ群：40898074\n未得原作者许可，可以用于商业用途！", 5)