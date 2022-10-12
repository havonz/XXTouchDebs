local img = screen.image(160,160,325,325)

local html_c = [[<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
	    <script src="/js/jquery.min.js"></script>
	    <script src="/js/jquery.json.min.js"></script>
		<title></title>
	</head>
	<body>
		<img id="_img" src="data:image/png;base64,]] .. img:png_data():base64_encode() .. [[" />
	</body>
</html>
<script>
window.onload = function(){
	var img = document.getElementById('_img');
	var canvas = document.createElement("canvas");
	var ctx = canvas.getContext("2d");
	$(canvas).attr("height", img.height);
	$(canvas).attr("width", img.width);
	ctx.drawImage(img, 0, 0, img.width, img.height);
	
	// 画一个矩形实心 绿色
	ctx.save();
	ctx.fillStyle='#00FF00';
	ctx.fillRect(5,5,30,30);
	ctx.restore();
	
	
	// 图片上添加文字
    ctx.save();
	ctx.font = "20px 微软雅黑";
    ctx.textAlign = "left";
    ctx.fillText("添加一串文字", 40, 40);
    ctx.restore();
	
	//发送
	$.post(
		"/proc_put",
    	JSON.stringify(
    		{
    			key: "xxtimage.class",
    			value: canvas.toDataURL("image/png")
    		}
    	),
        function(data){
        	
        },
        'json'
	);
};
$(document).ready(function(){
});
</script>
]]

proc_put("xxtimage.class", '')

webview.show{
	x = 0,
	y = h,
	width = w,
	height = h,
	html = html_c,
	alpha = 0,
}

local ret = ''
while(1)do
	ret = proc_put("xxtimage.class", '')
	if ret ~= '' then break end
	sys.msleep(1)
end
webview.hide()

nLog(ret)

ret = ret:sub(#('data:image/png;base64,') + 1, -1)

local new_img = image.load_data(ret:base64_decode())

dialog():add_image(img):add_image(new_img):show()




