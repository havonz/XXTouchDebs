
local 尺寸缩放 = screen.scale_factor() / 2
local 屏幕纵向中间位置 = ({screen.size()})[2] / 2

webview.show{
	html = [[<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	<html>
		<script src="/js/jquery.min.js"></script>
		<script src="/js/jquery.json.min.js"></script>
		<style>
		.circle_button{
		-moz-user-select:none;
		-webkit-user-select:none;
		-ms-user-select:none;
		-khtml-user-select:none;
		user-select:none;
		text-align: center;
		width: 50px;
		height: 50px;
		line-height: 50px;
		border-radius:50%;
		border: none;
		}
		.circle_button:hover{
		animation: clicked 200ms;
		}
		@keyframes clicked {
		    0% {
		        transform: scale(1);
		    }
		    50% {
		        transform: scale(0.5);
		    }
		    100% {
		        transform: scale(1);
		    }
		}
		.padding_line{
		padding: 2px;
		}
		</style>
		<script type="text/javascript">
		$(document).ready(function(){
			$(".circle_button").click(function(e) {
				$.post("/proc_queue_push",
					'{"key": "circle_buttons_clicked","value": "' + $(e.target).text() + '"}',
					function(){}
				);
			});
		});
		</script>
		<body>
		    <div class="circle_button" id="make" style="background-color: #bdb7f7;">制作</div>
		    <div class="padding_line"></div>
		    <div class="circle_button" id="release" style="background-color: #f7ca0b;">发布</div>
		    <div class="padding_line"></div>
		    <div class="circle_button" id="select" style="background-color: #1a00f9;">选择</div>
		    <div class="padding_line"></div>
		    <div class="circle_button" id="clean" style="background-color: #e91209;">清理</div>
		</body>
	</html>
	]],
	y = 屏幕纵向中间位置,
	width = 120 * 尺寸缩放,
	height = 124 * 4 * 尺寸缩放,
	alpha = 1,
	animation_duration = 0,
	corner_radius = 25,
	can_drag = true,
	opaque = false,
	id = 101,
}
proc_queue_clear("circle_buttons_clicked")
thread.register_event("circle_buttons_clicked", function(val)
	sys.toast("你点击了"..val)
end)
