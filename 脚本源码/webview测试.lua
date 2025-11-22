local html = [=[
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<!DOCTYPE html>
<html>
    <head>
    <script src="/js/jquery.min.js"></script>
    <script src="/js/jquery.json.min.js"></script>
    <script type="text/javascript">
    $(document).ready(function(){
        $("#toast_content").val("toast内容");
        $("#close_page").click(function(){
            $.post(
                "/proc_queue_push",
                '{"key": "来自webview的消息","value": "关闭页面"}',
                function(){}
            );
        });

        $("#show_toast").click(function(){
            $.post(
                "/proc_put",
                $.toJSON({
                    key:"toast内容",
                    value:$("#toast_content").val()
                }),
                function(){}
            );
            $.post(
                "/proc_queue_push",
                '{"key": "来自webview的消息","value": "显示toast"}',
                function(){}
            );
        });

        $("#slide_down").click(function(){
            $.post(
                "/proc_queue_push",
                '{"key": "来自webview的消息","value": "往下滑动"}',
                function(){}
            );
            $(this).hide();
        });

        $("#full_vertical").click(function(){
            $.post(
                "/proc_queue_push",
                '{"key": "来自webview的消息","value": "竖屏全屏"}',
                function(){}
            );
        });

        $("#full_landscape").click(function(){
            $.post(
                "/proc_queue_push",
                '{"key": "来自webview的消息","value": "横屏全屏"}',
                function(){}
            );
        });

        $("#confirm_test").click(function(){
            var r = confirm("按下按钮");
            if (r==true) {
                x="你按下了\"确定\"按钮!";
            } else {
                x="你按下了\"取消\"按钮!";
            }
            $.post(
                "/proc_put",
                $.toJSON({
                    key:"toast内容",
                    value:x
                }),
                function(){}
            );
            $.post(
                "/proc_queue_push",
                '{"key": "来自webview的消息","value": "显示toast"}',
                function(){}
            );
        });

        $("#prompt_test").click(function(){
            var p =  prompt("请输入你的名字","Harry Potter");
            if (p!=null && p!="") {
                x="你好 " + p + "! 今天感觉如何?";
                $.post(
                    "/proc_put",
                    $.toJSON({
                        key:"toast内容",
                        value:x
                    }),
                    function(){}
                );
                $.post(
                    "/proc_queue_push",
                    '{"key": "来自webview的消息","value": "显示toast"}',
                    function(){}
                );
            }
        });
    });
    </script>
    </head>
    <body>
        <p>动脚webview演示</p>
        <p><button id="close_page" type="button">点我关闭页面</button></p>
        <p><button id="show_toast" type="button">显示一个toast</button><input type="text" id="toast_content" /></p>
        <p><button id="full_vertical" type="button">竖屏全屏</button><button id="full_landscape" type="button">横屏全屏</button></p>
        <p><button id="slide_down" type="button">视图往下滑动</button></p>
        <select>
            <option value="o1">第1个选项</option>
            <option value="o2">第2个选项</option>
            <option value="o3">第3个选项</option>
            <option value="o4">第4个选项</option>
        </select>
        <p><button id="confirm_test" type="button">选择弹窗测试</button></p>
        <p><button id="prompt_test" type="button">输入文字弹窗测试</button></p>
    </body>
</html>
]=]
--
local w, h = screen.size()
local factor = screen.scale_factor() / 2
--
webview.show{ -- 重置 webview 位置到左上角
    x = 0,
    y = 0,
    width = w - 40 * factor,
    height = (500) * factor,
    alpha = 0,
    animation_duration = 0,
    can_drag = true,
}
--
webview.show{ -- 从左上角用0.3秒的时间滑动出来
    html = html,
    x = 20 * factor,
    y = 50 * factor,
    width = (w - 40 * factor),
    height = (500) * factor,
    corner_radius = 10,
    alpha = 0.7,
    animation_duration = 0.3,
    can_drag = true,
}
--
proc_queue_clear("来自webview的消息", "") -- 清空需要监听的字典的值
local eid = thread.register_event( -- 注册监听字典状态有值事件
    "来自webview的消息",
    function(val)
        if val == "关闭页面" then
            webview.show{
                x = 20 * factor,
                y = 500 * factor * 2,
                width = (w - 40 * factor),
                height = (500 - 70) * factor,
                corner_radius = 10,
                alpha = 0,
                animation_duration = 0.8,
                can_drag = true,
            }
            sys.msleep(800)
            webview.destroy()
            sys.toast("页面线程结束")
            return true -- 返回 true 停止当前监听
        elseif val == "往下滑动" then
            webview.show{
                x = 20 * factor,
                y = (50 + 300) * factor, -- 纵坐标 + 300
                width = (w - 40  * factor),
                height = (500 - 70) * factor, -- 往下滑动按钮被隐藏了，高度调整
                corner_radius = 10,
                alpha = 0.7,
                animation_duration = 0.5, -- 耗时 0.5 秒
                can_drag = true,
            }
        elseif val == "竖屏全屏" then
            webview.show{} -- 此处将会把 webview 置为全屏
        elseif val == "横屏全屏" then
            webview.show{rotate=90} -- 此处将会把 webview 置为横屏全屏
        elseif val == "显示toast" then
            sys.toast(proc_get("toast内容"))
        end
    end
)
--
sys.msleep(3000)
sys.toast("主线程结束")