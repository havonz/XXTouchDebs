local scale = screen.scale_factor() / 2

webview.show{
	html = [[
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	<html>
	<head>
	<style>
	#one_button {
		color: #FFFFFF;
		text-shadow: 0px 0px 10px #000000;
	}
	div { /* 禁止选中文字 */
		-moz-user-select:none;
		-webkit-user-select:none;
		-ms-user-select:none;
		-khtml-user-select:none;
		user-select:none;
	}
	</style>
	<script src="/js/jquery.min.js">
	</script>
	<script type="text/javascript">
	$(document).ready(function(){
		$("#one_button").click(function(){
			if ($("#one_button").text()=="暂停"){
				$.post(
					"/pause_script", '',
					function(){
						$("#one_button").text("继续");
					}
				);
			} else {
				$.post(
					"/resume_script", '',
					function(){
						$("#one_button").text("暂停");
					}
				);
			}
		});
	});
	</script>
	</head>
	<body>
	<div id="one_button">暂停</div>
	</body>
	</html>
	]],
	x = 30 * scale,
	y = 100 * scale,
	width = 100 * scale,
	height = 100 * scale,
	corner_radius = 10,
	alpha = 0.7,
	animation_duration = 0.3,
	rotate = ({
		[0] = 0,
		[1] = 90,
		[2] = 270,
		[3] = 180
	})[screen.current_init_orien()],
	can_drag = true,
	opaque = false,
	id = 2,
}

for i=1,100 do
	sys.toast("计数器："..i)
	sys.msleep(1000)
end