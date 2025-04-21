# XXTouch iOS 开发手册

---

<p style="color:red;font-weight:bold;">Windows 平台按 Ctrl + F 可以输入文字搜索</p>
<p style="color:red;font-weight:bold;">Mac 平台按 command + F 可以输入文字搜索</p>

---

## 关于 XXTouch
XXTouch 使用 [Lua](http://www.lua.org/) 作为脚本语言，支持 [Lua 5.3](http://www.lua.org/manual/5.3/) 版的所有语法与基本函数，并于其基础之上添加了一些扩展功能， 用于取色、找色、发送触摸、键盘事件等高级功能的实现。XXTouch 仅支持 UTF\-8 编码的脚本。

---

## 如何阅读本手册
- 入门需要拥有 Lua 基础，可以参考[《Lua 5.3 中文手册》](http://cloudwu.github.io/lua53doc/manual.html)  
- 示例代码中使用 0x 开头的数字为 16 进制数 \( [什么是 16 进制数?](https://baike.baidu.com/item/%E5%8D%81%E5%85%AD%E8%BF%9B%E5%88%B6%E6%95%B0/5697828) \)
- 参数描述中可选参数使用中括号包围
- 参数或返回值如果是表型固定结构值，则使用大括号表示表型结构
- 类型描述中 文本型 和 字符串型 都是 Lua 的 string 类型，但 文本型 一般是指可以打印的明文文字
- 章或节用叹号 \( \! \) 开头的说明这个函数或者这个模块的函数包含隐式 **让出**（在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会）
- 若无额外说明，手册内示例代码均不处理边界情况，不应该直接复制到自己的脚本中用


---
<br />
<br />
<br />

## 如何使用 XXTouch

### 开发相关~~及交流 QQ 群 （40898074）群已满~~
- [开发及周边工具下载](#开发及周边工具下载)

---
<br />
<br />
<br />

### 脚本及相关资源存在设备的哪个位置？

- 脚本存放目录为 `/var/mobile/Media/1ferver/lua/scripts/`
- 插件存放目录为 `/var/mobile/Media/1ferver/lib/`
- 资源存放目录为 `/var/mobile/Media/1ferver/res/`
- 日志存放目录为 `/var/mobile/Media/1ferver/log/`
- 文字识别字库存放目录为 `/var/mobile/Media/1ferver/tessdata/`
- 文字识别推理模型存放目录为 `/var/mobile/Media/1ferver/models/`
- 内置脚本模块存放目录为 `/var/mobile/Media/1ferver/lua/`
- 无根越狱可能需要 [jbroot](#获取系统根路径对应的越狱根路径-jbroot) 来获取路径




---
<br />
<br />
<br />

## 保护脚本，正确接受 require
- 为何 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 可能带来安全风险？
    - XXTouch 加密的脚本模块可以被其它脚本或者模块以 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 方式引用
    - 当您的加密脚本被 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 时，全局环境是不可信的，您的脚本调用的函数可能已经被替换

- 如何正确使用 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 呢？
    - XXTouch 保证部分模块的函数会在 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 之前恢复初始状态，这包括
        - os、io、string、device、http、file、table 模块所有函数
        - 您可以深拷贝全局环境到模块内局部环境以确保安全调用上述模块中所有函数
        - 示例  
            
            ```
            -- 在脚本的最前面加上这个代码
            local _ENV = table.deep_copy(_ENV)
            -- 下面就是脚本的主体内容
            
            -- 最后您可能还需要返回一些导出函数或者常量
            ```
            
    - 并且保证当一个模块被 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 方式引用的时候，全局变量 been\_require 会无条件置为 true
        - 您可以通过这个全局变量的状态来判断自己是不是正在被 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require)

        - 示例  
        
            ```
            -- 在脚本的最前面加上这个代码
            if been_require then
                return -- 如果被 require 就直接退出
            end
            -- 下面就是脚本的主体内容
            ```


---
<br />
<br />
<br />

## 基本控制函数
- ### 结束脚本 (**os\.exit**)
    - 声明  
        ```lua
        os.exit()
        ```
    
    - 说明  
        > [os.exit](http://cloudwu.github.io/lua53doc/manual.html#pdf\-os.exit) 是 lua 自带的结束进程的函数，在 XXTouch 是结束逻辑上的脚本进程  
        > 在任意线程中调用都可以结束当前脚本进程，所有的线程、监听都会立即终止  
        
    - 示例  
        ```lua
        os.exit()
        ```



---
<br />

- ### 重启脚本 (**os\.restart**)
    - 声明  
        ```lua
        os.restart([ 脚本文件路径 ])
        ```
    
    - 参数及返回值
        > - 脚本文件路径 **\*1\.1\.2\-2 新增**  
            文本型，可选参数，当这里传入一个有效的脚本文件路径将会重启到目标脚本文件，默认为 ""  
    
    - 说明  
        > 在没有 **脚本文件路径** 参数的情况下这个函数调用会直接重启 **当前脚本** 进程，当前脚本会立即结束  
        > 传入了有效的 **脚本文件路径** 参数的时脚本会结束并重新启动到 **目标脚本文件**  
        > 操作失败的情况下，该函数会返回 false 并附带错误信息，操作失败通常是传入了非法参数  
    
    - 需要注意
        > - **当前脚本** 的定义是启动的那份脚本，脚本文件被更改后使用 os\.restart\(\) **不会** 启动更改之后的脚本文件  
        > - 如果可能，请 **不要** 在多线程环境使用该函数  
        > - 无延迟重启会导致的其它逻辑问题也需要作者规避  
        > - 当前函数暂 **不支持** 重启、启动 xpp **脚本包** 脚本  
        
        
    - 示例 1
        ```lua
        os.restart() -- 重启到 “当前脚本”（不是 “当前脚本文件”）
        ```
        
    - 示例 2
        ```lua
        os.restart(utils.launch_args().path) -- 重启到 “当前脚本文件”
        ```
        **注**：上述代码中使用了非本章函数 [`utils.launch_args`](#获得当前脚本的启动参数-utilslaunchargs)


---
<br />

- ### 脚本被终止时执行一些代码的方法
    - 说明  
        > 这不是一个函数  
        而是利用 Lua 的垃圾回收机制实现的，用于在脚本结束（或被结束）时执行一些代码的方法  
        - **原理**
            定义一个全局对象（表型值），将其 **析构函数** 设为一个函数  
            当 Lua 虚拟机结束之时，所有 Lua 对象（也包括你定义的这个）的 **析构函数** 会被调用  
            Lua 中的 **析构函数** 是指对象的[ \_\_gc 元方法](http://cloudwu.github.io/lua53doc/manual.html#2.4)  

    - 简易示例  
        ```lua
        -- 关键词 脚本终止回调 脚本结束回调
        随便取个变量名 = {}
        setmetatable(随便取个变量名, {
        	__gc = function(...)
        		sys.toast('被终止了！')
        		sys.msleep(500)
        	end
        })
        
        while (true) do
        	sys.toast("现在可尝试手动结束脚本\n\n"..os.date("%Y-%m-%d %H:%M:%S"))
        	sys.msleep(1000)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字-systoast)、[`sys.msleep`](#毫秒级延迟-sysmsleep)、[setmetatable](http://cloudwu.github.io/lua53doc/manual.html#pdf-setmetatable)
        
        
    - 完整封装示例  
        ```lua
        function atexit(callback) -- 参数为一个函数，使用 atexit(一个函数) 注册一个函数在脚本结束时执行，建议不要耗时太长
        	____atexit_guard____ = ____atexit_guard____ or {}
        	if type(____atexit_guard____) == 'table' then
        		if not getmetatable(____atexit_guard____) then
        			setmetatable(____atexit_guard____, {
        				__gc = function(self)
        					if type(self.callback) == 'function' then
        						pcall(self.callback)
        					end
        				end
        			})
        		end
        		____atexit_guard____.callback = callback
        	else
        		error('别用 `____atexit_guard____` 命名你的变量。')
        	end
        end
        -- 以上代码可拷贝到你的脚本的开头，以下为使用示例
        
        -- 使用 atexit 注册一个终止回调函数
        atexit(function() 
        	sys.toast('被终止了！')
        	sys.msleep(500)
        end)
        
        while (true) do
        	sys.toast("现在可尝试手动结束脚本\n\n"..os.date("%Y-%m-%d %H:%M:%S"))
        	sys.msleep(1000)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字-systoast)、[`sys.msleep`](#毫秒级延迟-sysmsleep)、[setmetatable](http://cloudwu.github.io/lua53doc/manual.html#pdf-setmetatable)



---
<br />
<br />
<br />

## 开发辅助函数
- ### 打印内容到缓冲区 (**print**)
    - 声明  
        ```lua
        print([ 参数1, 参数2, ... ])
        ```
    
    - 参数及返回值
        > - 参数1, 参数2, \.\.\.
            任意类型，可选参数，可变参数，将会转换成文本输出到缓冲区，参数之间用 `"\t"` 隔开
    - 说明  
        > [`print`](http://cloudwu.github.io/lua53doc/manual.html#pdf\-print) 是 lua 自带的打印输入函数，在 XXTouch 是将内容打印到缓冲区
        
    - 示例  
        ```lua
        print("hello world")
        ```



---
<br />

- ### 将打印缓冲区的内容提出来 (**print\.out**)
    - 声明  
        ```lua
        缓冲区内容 = print.out()
        ```
    
    - 说明  
        > 将 print 函数打印的缓冲区清空并返回缓冲区内容  
        
    - 示例  
        ```lua
        -- 使用一个弹窗显示 print 缓冲区内容
        sys.alert(print.out())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 网络日志 (**nLog**)
    - 声明  
        ```lua
        nLog(日志内容)
        ```
    
    - 参数及返回值  
        > - 日志内容  
            文本型，日志内容  
    
    - 说明  
        > 这个函数是协议函数（空函数），默认执行不会产生任何效果，实现细节由配套开发环境决定
        > 当使用配套开发环境进行调试的时候这个函数将会将日志发回开发环境的日志框
        
    - 示例  
        ```lua
        -- 将 print 缓冲区内容发回开发开发工具的日志窗
        nLog(print.out())
        ```



---
<br />

- ### 获取系统根路径对应的越狱根路径 (**jbroot**)
    - 声明  
        ```lua
        越狱根路径 = jbroot(系统根路径)
        ```
    
    - 参数及返回值  
        > - 系统根路径  
            文本型，系统根路径  
        > - 越狱根路径  
            文本型，参数 `系统根路径` 对应的 `越狱根路径`  
    
    - 说明  
        > 在 roothide 及 rootless 环境中，该函数返回一个绝对路径访问越狱根中的指定路径  
        > 在 rootful 环境中，该函数将直接返回传入的那个参数  
        > **软件版本在 1.3.8 或以上方可使用**  
        
    - 示例  
        ```lua
        nLog(jbroot('/')) -- /var/containers/Bundle/Application/.jbroot-XXXXXXXXXXXXXXXX/
        ```



---
<br />

- ### 获取越狱根对应的系统根路径 (**rootfs**)
    - 声明  
        ```lua
        系统根路径 = rootfs(越狱根路径)
        ```
    
    - 参数及返回值  
        > - 越狱根路径  
            文本型，路径  
        > - 系统根路径  
            文本型，参数 `越狱根路径` 对应的 `系统根路径`  
    
    - 说明  
        > 在 roothide 及 rootless 环境中，该函数用于将 jbroot 函数的结果转换回去  
        > 在 rootful 环境中，该函数将直接返回传入的那个参数  
        > **软件版本在 1.3.8 或以上方可使用**  
        
    - 示例  
        ```lua
        nLog(rootfs('/var/containers/Bundle/Application/.jbroot-XXXXXXXXXXXXXXXX/')) -- /
        ```
    
    


    ---
<br />
<br />
<br />


## 屏幕模块（screen）
- ### 初始化旋转坐标系 (**screen\.init**)
    - 声明  
        ```lua
        原坐标系 = screen.init(坐标系)
        ```
    
    - 参数及返回值  
        > - 坐标系  
            * 整数型，取值范围  
                0 \- 竖屏 home 在下  
                1 \- 横屏 home 在右  
                2 \- 横屏 home 在左  
                3 \- 竖屏 home 在上  
        > - 原坐标系  
            * 整数型，返回这个函数调用之前使用的坐标系  
    
    - 说明  
        > 初始化取色或点击的坐标系  
        > 使用以下别名调用也可以实现相同效果  
        ``` lua
        screen.init_home_on_bottom()    -- home 在下
        screen.init_home_on_right()     -- home 在右
        screen.init_home_on_left()      -- home 在左
        screen.init_home_on_top()       -- home 在上
        ```
        
    - 示例  
        ```lua
        screen.init(0)    -- home 在下
        screen.init(1)    -- home 在右
        screen.init(2)    -- home 在左
        screen.init(3)    -- home 在上
        ```


---
<br />

- ### 坐标旋转转换 (**screen\.rotate\_xy**)
    - 声明  
        ```lua
        旋转后的横坐标, 旋转后的纵坐标 = screen.rotate_xy(横坐标, 纵坐标, 旋转方向)
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            * 整数型，需要旋转的坐标  
        > - **旋转方向**  
            * 整数型，旋转选项  
                0 \- 不旋转  
                1 \- 往左 90 度旋转  
                2 \- 往右 90 度旋转  
                3 \- 180 度旋转  
        > - 旋转后的横坐标, 旋转后的纵坐标  
            * 整数型，返回使用 **旋转方向** 作为选项旋转后的坐标  
    
    - 说明  
        > 坐标旋转转换，通常用于将竖屏坐标转换成横屏坐标  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        rx, ry = screen.rotate_xy(100, 200, 1)
        ```


---
<br />

- ### 获取屏幕尺寸 (**screen\.size**)
    - 声明  
        ```lua
        屏宽, 屏高 = screen.size()
        ```
    
    - 参数及返回值  
        > - 屏宽 整数型  
        > - 屏高 整数型  
    
    - 说明  
        > 这个函数的返回值不受当前设备的桌面或者应用的的横竖屏状态影响，也不受放大模式影响  
        
    - 示例  
        ```lua
        -- 根据分辨率判断设备类型
        width, height = screen.size()
        if width == 640 and height == 1136 then
            -- iPhone 5, 5S, iPod touch 5
        elseif width == 640 and height == 960 then
            -- iPhone 4, 4S, iPod touch 4
        elseif width == 750 and height == 1334 then
            -- iPhone 6, 6S, 7, 8
        elseif width == 1242 and height == 2208 then
            -- iPhone 6+, 6S+, 7+, 8+
        elseif width == 768 and height == 1024 then
            -- iPad 1, 2, mini 1
        elseif width == 1536 and height == 2048 then
            -- iPad 3, 4, 5, mini 2
        elseif width == 320 and height == 480 then
            -- 这个应该不可能
        end
        ```



---
<br />

- ### 保持屏幕 (**screen\.keep**)
    - 声明  
        ```lua
        screen.keep()
        ```
        
    - 说明  
        > 在脚本中保持当前屏幕内容不变，多次调用取色、找色、截图、找图等函数时，直接调用保持的内容。  
        > 该函数为优化类函数，能够为大量的静态图像处理函数提供性能优化。  
        > 调用仅会影响 XXTouch 取色逻辑，**不会** 导致屏幕画面卡住不动！！！  
        
    - 示例  
        ```lua
        -- 遍历屏幕区块
        screen.keep()
        for k = 1, 640, 10 do
            for j = 1, 960, 10 do
                --格式化为十六进制文本
                color = string.format("%X", screen.get_color(k, j));
                --输出到系统日志
                sys.log("("..k..", "..j..") Color: "..color..".");
            end
        end
        screen.unkeep()
        ```
        **注**：上述代码中使用了非本章函数 [`sys.log`](#输出标准系统日志-syslog)  
    
    
    - 小知识  
        > - 针对同一位置两行连续单独的 screen\.get\_color 调用可能取到不同的值  
        > - screen\.keep 的情况下 screen\.get\_color 单独调用耗时会超过一次 screen\.keep 的耗时  
        > - 调用 screen\.keep 之后，再连续调用 50 次 screen\.get\_color 耗时可以等同于调用一次 screen\.keep  



---
<br />

- ### 取消保持屏幕 (**screen\.unkeep**)  
    - 声明  
        ```lua
        screen.unkeep()  
        ```
    
    - 说明  
        > 取消 [screen.keep](#保持屏幕-screenkeep) 函数的效果，释放内存中的屏幕图像  
        
    - 示例  
        [`参考 screen.keep 示例`](#保持屏幕-screenkeep)  



---
<br />

- ### 获取屏幕上某点颜色 (**screen\.get\_color**)
    - 声明  
        ```lua
        颜色值 = screen.get_color(横坐标, 纵坐标)
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            整数型，代表目标点的坐标  
        > - 颜色值  
            整数型，返回目标点颜色的 RGB 值  
                
    - 说明  
        > 获取屏幕上某个坐标点的颜色  
        
    - 示例  
        ```lua
        local c = screen.get_color(512, 133)
        if c==0xffffff then
            sys.alert("512, 133 这个点是纯白色")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取屏幕上某点颜色 RGB (**screen\.get\_color\_rgb**)
    - 声明  
        ```lua
        红, 绿, 蓝 = screen.get_color_rgb(横坐标, 纵坐标)
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            整数型，代表目标点的坐标  
        > - 红, 绿, 蓝  
            整数型，返回目标点颜色的 `红、绿、蓝` 值，取值范围 0~255  
                
    - 说明  
        > 获取屏幕上某个坐标点的颜色并拆分成 红\(R\) 绿\(G\) 蓝\(B\) 形式  
        
    - 示例  
        ```lua
        local r, g, b = screen.get_color_rgb(512, 133)
        if r==0xff and g==0xff and b==0xff then
            sys.alert("512, 133 这个点是纯白色")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 屏幕多点颜色匹配 (**screen\.is\_colors**)
    - 声明  
        ```lua
        是否完全匹配 = screen.is_colors({
            {横坐标*, 纵坐标*, 颜色*},
            {横坐标*, 纵坐标*, 颜色*},
            ...
        }[, 颜色相似度])
        ```
    
    - 参数及返回值  
        > - 横坐标\*, 纵坐标\*  
            整数型，代表其中某点坐标  
        > - 颜色\*  
            整数型，代表其中某点需要匹配的颜色值  
        > - 颜色相似度  
            整数型，可选参数，代表需要的颜色的相似度，取值范围 1~100，默认 100  
        > - 是否完全匹配  
            布尔型，所有点的颜色都匹配则返回 true，否则返回 false  
                
    - 说明  
        > 匹配屏幕上若干点的颜色  
        
    - 示例  
        ```lua
        if screen.is_colors({
        	{ 509, 488, 0xec1c23}, -- 如果坐标 (509, 488) 的颜色与 0xec1c23 相似度在 90% 以上
        	{ 514, 470, 0x00adee}, -- 同时坐标 (514, 470) 的颜色与 0x00adee 相似度在 90% 以上
        	{ 508, 478, 0xffc823}, -- 同时坐标 (508, 478) 的颜色与 0xffc823 相似度在 90% 以上
        	{ 511, 454, 0xa78217}, -- 同时坐标 (511, 454) 的颜色与 0xa78217 相似度在 90% 以上
        	{ 521, 433, 0xd0d2d2}, -- 同时坐标 (521, 433) 的颜色与 0xd0d2d2 相似度在 90% 以上
        }, 90) then                -- 则匹配
            sys.alert("匹配！")
        else
            sys.alert("不匹配！")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 多点相似度模式找色 (**screen\.find\_color**)
    - 声明  
        ```lua
        横坐标, 纵坐标 = screen.find_color({
            [find_all = 是否搜索多个结果],
            [max_results = 最大结果数],
            [max_miss = 允许最多未命中数],
            {起始点横坐标, 起始点纵坐标, 起始点颜色[, 起始点相似度]},
            {偏移点横坐标*, 偏移点纵坐标*, 偏移点颜色*[, 偏移点相似度*]},
            {偏移点横坐标*, 偏移点纵坐标*, 偏移点颜色*[, 偏移点相似度*]},
            ...
        } [, 全局相似度, 左, 上, 右, 下 ])
        ```
    
    - 参数及返回值
        > - 是否搜索多个结果  
            布尔型，可选参数，这个标签设置为 true 会返回范围内所有匹配位置的一个表，格式为 \{\{x1, y1\}, \{x2, y2\}, ...\}，默认 false  
        > - 最大结果数  
            整数型，可选参数，当 find\_all（是否搜索多个结果） 标签设置为 true 的时候，这个表示最多返回结果数，最多可以设为 1000，默认 100  
        > - 允许最多未命中数 **\*1\.2\-3 新增**  
            整数型，可选参数，可以允许最多的不匹配的点的数量，默认为 0，也就是全命中才算找到  
        > - 起始点横坐标, 起始点纵坐标  
            整数型，代表起始坐标，它并不是限制找色的范围为固定这一点，而仅仅是给偏移位置一个相对坐标，不理解就填 0, 0  
        > - 起始点颜色  
            整数型，代表需要搜索的那一点的颜色  
        > - 起始点相似度  
            整数型，可选参数，需要搜索的那一点颜色的相似度，取值范围 1~100，默认 100  
        > - 偏移点横坐标\*, 偏移点纵坐标\*  
            整数型，代表一个偏移位置坐标  
        > - 偏移点颜色\*  
            整数型，代表偏移位置需要匹配的颜色  
        > - 偏移点相似度\*  
            整数型，可选参数，偏移位置的颜色的相似度，取值范围 \-100~100，默认 100，负相似度意味着匹配小于该绝对值的相似度  
        > - 全局相似度  
            整数型，可选参数，如果没有给单个点设置相似度，那么每一点都会用这个相似度，取值范围 1~100，默认 100  
        > - 左, 上, 右, 下  
            整数型，可选参数，代表搜索区域，默认 全屏  
        > - 横坐标, 纵坐标  
            整数型，返回匹配色的第一个色的坐标，搜索失败返回 \-1, \-1  
                
    - 说明  
        > 使用相似度模式查找，获取区域中第一个完全匹配的多点颜色结构的位置  
        
    - 示例  
        ```lua
        x, y = screen.find_color({
        	{  0,   0, 0xec1c23},
        	{ 12,  -3, 0xffffff, 85},
        	{  5, -18, 0x00adee},
        	{ -1, -10, 0xffc823},
        	{  2, -34, 0xa78217},
        	{ 12, -55, 0xd0d2d2},
        }, 90, 0, 0, 100, 100)
        
        --[[
            在左上为 0, 0 右下为 100, 100 的区域找到第一点与 0xec1c23 相似度大于 90 
            且它的相对坐标 (12, -3) 的位置的颜色与 0xffffff 相似度大于 85
            且它的相对坐标 (5, -18) 的位置的颜色与 0x00adee 相似度大于 90 
            且……（后面的同理）都能匹配的那个点
        --]]
        
        -- 等效代码如下：
        
        x, y = screen.find_color({
        	{ 509, 488, 0xec1c23},
        	{ 521, 485, 0xffffff, 85},
        	{ 514, 470, 0x00adee},
        	{ 508, 478, 0xffc823},
        	{ 511, 454, 0xa78217},
        	{ 521, 433, 0xd0d2d2},
        }, 90, 0, 0, 100, 100)
        
        --[[
            在左上为 0, 0 右下为 100, 100 的区域找到第一点与 0xec1c23 相似度大于 90 
            且它的相对坐标 (521-509, 485-488) 的位置的颜色与 0xffffff 相似度大于 85 
            且它的相对坐标 (514-509, 470-488) 的位置的颜色与 0x00adee 相似度大于 90 
            且……（后面的同理）都能匹配的那个点
        --]]
        
        -- 不换行无缩进就是这个效果：
        x, y = screen.find_color({{0,0,0xec1c23},{12,-3,0xffffff,85},{5,-18,0x00adee},{-1,-10,0xffc823},{2,-34,0xa78217},{12,-55,0xd0d2d2},},90,0,0,100,100)
        
        x, y = screen.find_color({ -- 反匹配演示，在 5C 主屏幕运行可获得结果
        	{ 516,  288, 0xffffff },
        	{ 519,  286, 0xffffff },
        	{ 521,  289, 0xffffff },
        	{ 516,  296, 0xffffff },
        	{ 522,  297, 0xffffff },
        	{ 520,  295, 0xffffff, -10 }, -- 这一点颜色与 0xffffff 相似度小于 10 才匹配，下同
        	{ 515,  291, 0xffffff, -10 },
        	{ 518,  284, 0xffffff, -10 },
        	{ 523,  298, 0xffffff, -10 },
        	{ 514,  298, 0xffffff, -10 },
        	{ 514,  296, 0xffffff, -10 },
        }, 90) -- 不写区域参数表示全屏找
        
        results = screen.find_color({ -- 范围匹配全输出演示
        	{  527,  278, 0xde1d26 },
        	{  524,  285, 0x007aff },
        	{  555,  292, 0xe4ddc9 },
        	{  536,  314, 0xffde02 },
        	{  502,  291, 0xffde02 },
        	{  502,  283, 0xe4ddc9 },
        	find_all = true, -- 带这个标签将返回范围所有匹配的位置的一个表，格式为 {{x1, y1}, {x2, y2}, ...}
        }, 90) -- 不写区域参数表示全屏找
        ```



---
<br />

- ### 多点色偏模式找色 (**screen\.find\_color**)
    - 声明  
        ```lua
        横坐标, 纵坐标 = screen.find_color({
            [find_all = 是否搜索多个结果],
            [max_results = 最大结果数],
            [max_miss = 允许最多未命中数],
            {起始点横坐标, 起始点纵坐标, {起始点颜色[, 起始点色偏]}},
            {偏移点横坐标*, 偏移点纵坐标*, {偏移点颜色*, 偏移点色偏*}},
            {偏移点横坐标*, 偏移点纵坐标*, {偏移点颜色*, 偏移点色偏*}},
            ...
        } [, 左, 上, 右, 下 ])
        ```
    
    - 参数及返回值  
        > - 是否搜索多个结果  
            布尔型，可选参数，这个标签设置为 true 会返回范围内所有匹配位置的一个表，格式为 \{\{x1, y1\}, \{x2, y2\}, ...\}，默认 false  
        > - 最大结果数  
            整数型，可选参数，当 find\_all（是否搜索多个结果） 标签设置为 true 的时候，这个表示最多返回结果数，最多可以设为 1000，默认 100  
        > - 允许最多未命中数 **\*1\.2\-3 新增**  
            整数型，可选参数，可以允许最多的不匹配的点的数量，默认为 0，也就是全命中才算找到  
        > - 起始点横坐标, 起始点纵坐标  
            整数型，代表起始坐标，它并不是限制找色的范围为固定这一点，而仅仅是给偏移位置一个相对坐标，不理解就填 0, 0  
        > - 起始点颜色  
            整数型，代表需要搜索的那一点的颜色  
        > - 起始点色偏  
            整数型，需要搜索的颜色的最大色偏（或偏色），大于 0xff000000 则为反匹配模式  
        > - 偏移点横坐标\*, 偏移点纵坐标\*  
            整数型，代表一个偏移位置坐标  
        > - 偏移点颜色\*  
            整数型，代表偏移位置需要匹配的颜色  
        > - 偏移点色偏\*  
            整数型，偏移位置的颜色的色偏（或偏色），大于 0xff000000 则为反匹配模式  
        > - 左, 上, 右, 下  
            整数型，可选参数，代表搜索区域，默认 全屏  
        > - 横坐标, 纵坐标  
            整数型，返回匹配色的第一个色的坐标，搜索失败返回 \-1, \-1  
                
    - 说明  
        > 使用色偏（或偏色）模式查找，获取区域中第一个完全匹配的多点颜色结构的位置  
        
        > **色偏（或偏色）**通常用于表示某个颜色范围，一个颜色附带色偏（或偏色）是指该颜色的红、绿、蓝偏移范围内的所有颜色  
        当 0x456789 色偏为 0x123456 的时候表示 0x456789 的红正负范围 0x12、绿正负范围 0x34、蓝正负范围 0x56  
        也就是其红色范围为 0x45 ± 0x12、绿色范围为 0x67 ± 0x34、蓝色的范围为 0x89 ± 0x56，如下表所示  
        
        |负|正|
        |:-|:-|
        |0x45 \- 0x12 = 0x33|0x45 \+ 0x12 = 0x57|
        |0x67 \- 0x34 = 0x33|0x67 \+ 0x34 = 0x9B|
        |0x89 \- 0x56 = 0x33|0x89 \+ 0x56 = 0xDF|
        
        > 上表所述 \{0x456789, 0x123456\} 实际上就是表示从 0x333333 到 0x579BDF 之间所有的颜色  
          
        > **使用 0x 开头的数字为 16 进制数** \( [什么是 16 进制数?](https://baike.baidu.com/item/%E5%8D%81%E5%85%AD%E8%BF%9B%E5%88%B6%E6%95%B0/5697828) \)  
        
    - 示例  
        ``` lua
        x, y = screen.find_color({
            {  0,   0, {0xec1c23, 0x000000}},
            { 12,  -3, {0xffffff, 0x101010}},
            {  5, -18, {0x00adee, 0x123456}},
            { -1, -10, {0xffc823, 0x101001}},
            {  2, -34, {0xa78217, 0x101001}},
            { 12, -55, {0xd0d2d2, 0x101001}},
        }, 0, 0, 100, 100)
        
        --[[
            在左上为 0, 0 右下为 100, 100 的区域找到第一点与 0xec1c23 完全相似 (色偏为 0)
            且它的相对坐标 (12, -3) 的位置的颜色与 0xffffff 的色偏小于 0x101010
            且它的相对坐标 (5, -18) 的位置的颜色与 0x00adee 色偏小于 0x123456
            且……（后面的同理）都能匹配的那个点
        --]]
        
        -- 等效代码如下：
        
        x, y = screen.find_color({
            { 509, 488, {0xec1c23, 0x000000}},
            { 521, 485, {0xffffff, 0x101010}},
            { 514, 470, {0x00adee, 0x123456}},
            { 508, 478, {0xffc823, 0x101001}},
            { 511, 454, {0xa78217, 0x101001}},
            { 521, 433, {0xd0d2d2, 0x101001}},
        }, 0, 0, 100, 100)
        
        --[[
            在左上为 0, 0 右下为 100, 100 的区域找到第一点与 0xec1c23 完全相似 (色偏为 0)
            且它的相对坐标 (521-509, 485-488) 的位置的颜色与 0xffffff 的色偏小于 0x101010
            且它的相对坐标 (514-509, 470-488) 的位置的颜色与 0x00adee 色偏小于 0x123456
            且……（后面的同理）都能匹配的那个点
        --]]
        
        -- 不换行无缩进就是这个效果：
        x, y = screen.find_color({{0,0,{0xec1c23,0x000000}},{12,-3,{0xffffff,0x101010}},{5,-18,{0x00adee,0x123456}},{-1,-10,{0xffc823,0x101001}},{2,-34,{0xa78217,0x101001}},{12,-55,{0xd0d2d2,0x101001}},},0,0,100,100)
        
        x, y = screen.find_color({ -- 反匹配演示，在 5C 主屏幕运行可获得结果
            { 516,  288, {0xffffff, 0x101010} },
            { 519,  286, {0xffffff, 0x101010} },
            { 521,  289, {0xffffff, 0x101010} },
            { 516,  296, {0xffffff, 0x101010} },
            { 522,  297, {0xffffff, 0x101010} },
            { 520,  295, {0xffffff, 0xff101010} }, -- 这一点颜色与 0xffffff 色差大于 0x101010 才匹配，下同
            { 515,  291, {0xffffff, 0xff101010} },
            { 518,  284, {0xffffff, 0xff101010} },
            { 523,  298, {0xffffff, 0xff101010} },
            { 514,  298, {0xffffff, 0xff101010} },
            { 514,  296, {0xffffff, 0xff101010} },
        }) -- 不写区域参数表示全屏找
        
        results = screen.find_color({ -- 范围匹配全输出演示
            {  527,  278, {0xde1d26, 0x101010} },
            {  524,  285, {0x007aff, 0x101010} },
            {  555,  292, {0xe4ddc9, 0x101010} },
            {  536,  314, {0xffde02, 0x101010} },
            {  502,  291, {0xffde02, 0x101010} },
            {  502,  283, {0xe4ddc9, 0x101010} },
            find_all = true, -- 带这个标签将返回范围所有匹配的位置的一个表，格式为 {{x1, y1}, {x2, y2}, ...}
        }) -- 不写区域参数表示全屏找
        ```



---
<br />

- ### 获取屏幕图像 (**screen\.image**)
    - 声明  
        ```lua
        图像 = screen.image([ 左, 上, 右, 下 ])
        ```
    
    - 参数及返回值  
        > - 左, 上, 右, 下  
            整数型，可选参数，代表图像区域，默认 全屏  
        > - 图像  
            图片对象，返回一个图片对象，用法参考 [图片对象模块（image）](#图片对象模块image)  
    
    - 说明  
        > 获取屏幕上区域或全部图像  
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        ```lua
        -- screen.image 的示例代码
        
        screen.image():save_to_album() -- 全屏截图并保存到相册
        
        screen.image():save_to_png_file("/User/1.png") -- 全屏截图并保存到文件 /User/1.png
        
        screen.image(100, 100, 200, 200):save_to_album() -- 截取左上坐标为 100, 100 右下坐标为 200, 200 的区域图像保存到相册
        
        pasteboard.write(screen.image(100, 100, 200, 200):png_data(), "public.png")
        -- 截取左上坐标为 100, 100 右下坐标为 200, 200 的区域图像写入到剪贴板
        
        ```
    **注**：上述代码中使用了非本章函数 [`:save_to_album`](#保存图片对象到相册\-savetoalbum)、[`:save_to_png_file`](#输出图片对象到一个\-png\-格式的文件\-savetopngfile)、[`:png_data`](#获取图片对象的\-png\-格式数据\-pngdata)、[`pasteboard.write`](#写内容进剪贴板\-write)



---
<br />
<br />

- ### 屏幕区域文字识别 (**screen\.ocr\_text**)
    - 声明  
        ```lua
        识别结果, 结果详情 = screen.ocr_text(左, 上, 右, 下 [, 引擎选项, 二值化选项 ])
        ```
    
    - 参数及返回值  
        - 左, 上, 右, 下  
            整数型，用于表示屏幕上的区域, 传入 `0, 0, 0, 0` 代表全屏  
        - 引擎选项  
            可选参数，用于选择识别语言及识别引擎  
            <details><summary>展开结构</summary>

            ```lua
            {
                -- 如果将 engine 字段设为 "apple"，则使用 iOS 13 以上苹果自带的 Vision.framework 进行识别
                -- 你可以使用 image.vision_supported_recognition_languages() 函数获取 Vision.framework 支持的 OCR 模型列表
                -- 如果将 engine 字段设为 "paddle"，则使用 Paddle-Lite 引擎识别。可使用 lang 指定模型，例如 lang = "ppocr_ch" 则使用模型 /var/mobile/Media/1ferver/models/ppocr_ch
                -- Paddle-Lite 引擎支持 *.nb 格式的 Slim 模型
                engine = "apple" | "paddle" | "tesseract",
                lang = "zh-Hans",
            }
            ```
            </details>
            <details><summary>各版本 iOS 内置的 Vision.framework 支持的 OCR 模型列表</summary>

            ```lua
            { -- iOS 13
                [1] = "en-US",
            }

            { -- iOS 14~15
                [1] = "en-US",
                [2] = "fr-FR",
                [3] = "it-IT",
                [4] = "de-DE",
                [5] = "es-ES",
                [6] = "pt-BR",
                [7] = "zh-Hans",
                [8] = "zh-Hant",
            }

            { -- iOS 16
                [ 1] = "en-US",
                [ 2] = "fr-FR",
                [ 3] = "it-IT",
                [ 4] = "de-DE",
                [ 5] = "es-ES",
                [ 6] = "pt-BR",
                [ 7] = "zh-Hans",
                [ 8] = "zh-Hant",
                [ 9] = "yue-Hans",
                [10] = "yue-Hant",
                [11] = "ko-KR",
                [12] = "ja-JP",
                [13] = "ru-RU",
                [14] = "uk-UA",
            }
            ```
            </details>
        - 二值化选项  
            * 可以是 实数型 或 文本型 或 表型 参数，分别代表  
                实数型，二值化阈值，可参考 [图片自动二值化](#opencv\-图片自动二值化\-cvbinaryzation)  
                表型，自定义二值化色偏，参考 [图片手动二值化](#二值化处理图片对象\-binaryzation)  
                文本型，自定义二值化色偏，参考 [图片手动二值化](#二值化处理图片对象\-binaryzation)  
        - 识别结果  
            文本型，识别返回的文字  
        - 结果详情 \*1\.1\.3\-1 新增  
            表型，OCR 识别的结果的详情  
            <details><summary>展开结构</summary>

            ```lua
            {
                {
                    ["y"] = number_value,
                    ["x"] = number_value,
                    ["w"] = number_value,
                    ["h"] = number_value,
                    ["confidence"] = number_value(0.0000 ~ 1.0000),
                    ["text"] = string_value,
                },
                ...
            }
            ```
            </details>
    
    - 说明  
        > 识别屏幕区域上的文字，该函数会引用 image\.tess_ocr 模块  
        > 内置 OCR 识别库引擎为 tesseract 3\.02 版，版本不对或者字库文件损坏会导致 XXTouch 脚本服务崩溃  
        > XXTouch 已内置 eng 识别库 \[A\-Za\-z0\-9\] 能识别常规英文和数字  
        > 如果需要做简体中文或是其它语言文字识别  
        > 需要手动导入相关的字库文件到设备的 `/var/mobile/Media/1ferver/tessdata/` 目录  
        > 这里提供 [简体中文字库（点击下载）](https://github.com/havonz/XXTouchDebs/blob/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/chi_sim.traineddata.gz)  
        > **软件版本在 1.3.8 以上方支持 Apple 和 PaddleLite 识别引擎** 
        
    - 示例  
        ```lua
        -- 示例 1：
        local txt = screen.ocr_text(187, 882, 298, 914) -- 默认配置是使用英文数字模式识别文字
        sys.toast("识别结果："..txt:atrim())
        
        -- 示例 2（1.1.0-1 新增）：
        local txt = screen.ocr_text(465, 241, 505, 269, "eng", "9D5D39-0F1F26,D3D3D2-2C2C2D") -- 使用色偏二值化识别
        sys.toast("识别结果："..txt:atrim())
        
        -- 示例 3（1.1.0-1 新增）：
        local txt = screen.ocr_text(465, 241, 505, 269, "eng", {{0x9D5D39, 0x0F1F26},{0xD3D3D2, 0x2C2C2D}}) -- 使用色偏二值化识别，同上
        sys.toast("识别结果："..txt:atrim())
        
        -- 示例 4：
        local txt = screen.ocr_text(187, 882, 298, 914, {
          lang = "eng",
          white_list = "1234567890",      -- 自定义使用白名单限制仅识别为数字
        })
        sys.toast("识别结果："..txt:atrim())
        
        -- 示例 5（1.1.0-1 新增）：
        local txt = screen.ocr_text(187, 882, 298, 914, {
          lang = "eng",
          white_list = "1234567890",      -- 自定义使用白名单限制仅识别为数字
        }, "9D5D39-0F1F26,D3D3D2-2C2C2D") -- 使用色偏二值化识别
        sys.toast("识别结果："..txt:atrim())

        -- 1.3.8 以上示例
        txt, info = screen.ocr_text(187, 882, 298, 914, {
            engine = "apple", -- 使用 Apple 引擎
            lang = "zh-Hans"  -- 使用简体中文识别模型
        })

        txt, info = screen.ocr_text(187, 882, 298, 914, {
            lang = "zh-Hans" -- 默认会尝试搜索是否是 Apple 引擎支持的模型
        }, "9D5D39-0F1F26,D3D3D2-2C2C2D")

        txt, info = screen.ocr_text(0, 0, 0, 0, {
            engine = "paddle", -- 使用 PaddleLite OCR 引擎
            lang = "ppocr_ch", -- 使用 ppocr_ch 模型
        })
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)、[`string.atrim`](#去除文本中所有的空白字符-stringatrim)



---
<br />

- ### 屏幕找图 (**screen\.find\_image**)
    - 声明  
        ```lua
        横坐标, 纵坐标 = screen.find_image(图片 [, 相似度, 左, 上, 右, 下 ])
        ```
    
    - 参数及返回值  
        > - 图片  
            * 字符串型  
                需要找的图片，可以是 png 或是 jpeg 格式的图片数据  
            * 图片对象  
                或是一个图片对象（可参考 [图片对象模块（image）](#图片对象模块image)）  
            * 文本型 \*1\.1\.2\-1 新增  
                需要找的图片文件路径，如果不是合法路径则会以数据方式解析  
        > - 相似度  
            整数型，可选参数，需要找的图片的相似度，范围 1~100，默认为 95  
        > - 左, 上, 右, 下  
            整数型，可选参数，搜索区域，默认 全屏  
        > - 横坐标, 纵坐标  
            整数型，返回找到的图片的左上角坐标，搜索失败返回 \-1, \-1  
    
    - 说明  
        > 在屏幕上寻找一个图像的位置，该函数会引用 image\.cv 模块  
        > **注意：** 如果需要做多分辨率兼容，那么建议是于分辨率最小的设备上截图；大分辨率上的截图会无法在小分辨率设备上找到  
        
    - 示例  
        [XXT 取色器 1.0.25 Windows 版.7z](https://raw.githubusercontent.com/havonz/XXTouchDebs/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/XXT%20%E5%8F%96%E8%89%B2%E5%99%A8%201.0.25%20For%20Windows.7z)
        ```lua
        -- 示例 1（使用 XXT 取色器 Shift + 鼠标左键框选图像上的区域 可直接生成这样的代码）：
        x, y = screen.find_image( -- 原图位置 左上: 354, 274 | 右下: 358, 284
        "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52\x00\x00\x00\x04\x00\x00\x00\x0a\x08\x02\x00\x00\x00\x1c\x99\x68\x59\x00\x00\x00\x61\x49\x44\x41\x54\x78\xda\x63\x78\xfd\xf4\xda\xff\xff\xff\xff\xfd\xfb\xf7\xed\xcb\x5b\x86\xf7\xaf\x1f\xfc\x87\x01\x86\x2f\x1f\x5f\x02\xa9\xef\xa7\xce\x7c\xdd\xb1\x9b\xe1\xe7\xf7\xcf\x40\xce\xeb\xb2\xea\x7b\xb2\x6a\x0c\x7f\xff\xfe\x01\x72\x9e\x78\x06\x82\x38\x20\xdd\xbf\x7e\xdd\x57\xd4\x82\x72\x7e\xdd\xba\x0d\x64\x41\x39\x08\xd3\x80\x38\x6b\xe3\x7f\x86\x2a\x30\x02\x72\x8c\xa6\x40\x39\x00\xd5\x7b\x5f\x2e\xfd\xba\xd5\x32\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82"
        , 95, 0, 0, 639, 1135)
        
        -- 示例 2：
        img = image.load_file("/User/1.png")
        x, y = screen.find_image(img)
        x, y = screen.find_image(img, 95)
        
        -- 示例 4（1.1.2-1 新增）：
        x, y = screen.find_image("/User/1.png", 95, 0, 0, 639, 1135)
        ```
        **说明**：在 Lua 源码中，字符串中 `\x` 开头，后面跟两位 16 进制数表示以该数字编码的单个字节。例如：`\x58` 表示 `X` 这个字符，可打印字符部分参考[《ASCII 编码》](https://baike.baidu.com/item/ASCII/309296)
    
    - 复杂例子  
        ```lua
        -- 从网上下载个小图片（一部分 XXTouch 图标）然后从屏幕上找到它并点击
        local c, h, r = http.get("https://www.xxtouch.com/img/find_image_test.png", 10)
        if (c == 200) then
            local img = image.load_data(r)
            if img then
                x, y = screen.find_image(img, 95)
                if x~=-1 then
                    touch.tap(x, y)
                else
                    sys.alert("没有在屏幕上找到 XXTouch 图标")
                end
            else
                sys.alert("可能下载到了一个假图片")
            end
        else
        	sys.alert("下载失败")
        end
        ```
        
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`image.load_data`](#从数据创建图片对象-imageloaddata)、[`touch.tap`](#模拟手指轻触一次屏幕-touchtap)、[`http.get`](#发起-get-请求-httpget)



---
<br />
<br />
<br />
## 模拟触摸模块（touch）

- ### \! 模拟手指轻触一次屏幕 (**touch\.tap**)
    - 声明  
        ```lua
        touch.tap(横坐标, 纵坐标 [, 延迟毫秒, 操作后等待毫秒 ])
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标   
            整数型，需要轻触的点于当前旋转坐标系的坐标  
        > - 延迟毫秒  
            整数型，可选参数，接触屏幕到离开屏幕之间的间隔时间，单位毫秒，默认 30  
        > - 操作后等待毫秒  
            整数型，可选参数，轻触完成之后的等待时间，单位毫秒，默认 0  
    
    - 说明  
        > 模拟手指轻触一次屏幕指定位置  
        > **这个方法可能会让出，在这个方法返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        > **注:** 该方法在调用完成之前会占用一个手指 id，手指 id 的数量是有限的（大约 30 个），超出限制再调用 [touch.on](#模拟手指接触屏幕-touchon) 或 [touch.tap](#模拟手指轻触一次屏幕-touchtap) 会抛出 `finger pool overflow` 错误，注意不要**同时占用**过多手指 id，及时调用 \:off 方法释放手指  
        
    - 示例  
        ```lua
        touch.tap(100, 100) -- 点一下屏幕上 100, 100 这个位置
        
        touch.tap(100, 100, 300) -- 在屏幕上的 100, 100 这个位置按下，等待 0.3 秒再抬起
        
        touch.tap(100, 100, 300, 1000) -- 在屏幕上的 100, 100 这个位置按下，等待 0.3 秒再抬起，再等待 1 秒
        ```



---
<br />

- ### 模拟手指接触屏幕 (**touch\.on**)
    - 声明  
        ```lua
        触摸事件 = touch.on(横坐标, 纵坐标)
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            整数型，需要接触的点于当前旋转坐标系的坐标  
        > - 触摸事件  
            触摸事件对象，通过调用 [`touch.on`](#模拟手指接触屏幕-touchon) 函数可以并获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 模拟手指接触屏幕指定位置，并返回一个用于操纵本次触摸过程的触摸事件对象  
        > **注:** 该函数会占用一个手指 id，手指 id 的数量是有限的（大约 30 个），超出限制再调用 [touch.on](#模拟手指接触屏幕-touchon) 或 [touch.tap](#模拟手指轻触一次屏幕-touchtap) 会抛出 `finger pool overflow` 错误，注意不要**同时占用**过多手指 id，及时调用 \:off 方法释放手指  
        
    - 示例  
        ```lua
        touch.on(100, 100):move(200,200):off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，然后匀速滑动到点 200, 200 的位置，然后松开
        ```



---
<br />

- ### \! 模拟手指在屏幕上移动 (**:move**)
    - 声明  
        ```lua
        触摸事件 = 触摸事件:move(横坐标, 纵坐标)
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            整数型，需要移动至的点于当前旋转坐标系的坐标  
        > - 触摸事件  
            触摸事件对象，通过调用 [touch.on](#模拟手指接触屏幕-touchon) 函数可以获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 模拟手指从当前位置移动到其它的位置  
        > **这个方法可能会让出，在这个方法返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```lua
        touch.on(100, 100):move(200,200):off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，然后匀速滑动到点 200, 200 的位置，然后松开
        ```



---
<br />

- ### \! 模拟手指在屏幕上施加压力 (**:press**)
    - 声明  
        ```lua
        触摸事件 = 触摸事件:press([ 压力, 速度 ])
        ```
    
    - 参数及返回值  
        > - 压力  
            整数型，可选参数，压力，范围 1~10000，默认 1000  
        > - 速度  
            整数型，可选参数，施加压力的速度，范围 1~100，默认 最快速  
        > - 触摸事件  
            触摸事件对象，通过调用 [touch.on](#模拟手指接触屏幕-touchon) 函数可以获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 模拟手指在当前位置施加压力，该方法仅能用于支持 3D Touch 的设备  
        > **这个方法可能会让出，在这个方法返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```lua
        touch.on(100, 100):press():off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，然后用力按下去，然后松手
        
        touch.on(100, 100):press(2000):off() -- 上面例子改一点压力
        
        touch.on(100, 100):press(2000, 50):off() -- 上面例子改一点压力，按压速度放慢
        ```



---
<br />

- ### 模拟手指离开屏幕 (**:off**)
    - 声明  
        ```lua
        触摸事件:off([ 横坐标, 纵坐标 ])
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            整数型，可选参数，手指离开屏幕的点于当前旋转坐标系的坐标，默认 当前 te 事件记录的坐标  
        > - 触摸事件  
            触摸事件对象，通过调用 [touch.on](#模拟手指接触屏幕-touchon) 函数可以获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 模拟手指从当前位置或指定位置离开屏幕，该方法调用会释放当前触摸事件对象  
        > 该方法会释放掉 [touch.on](#模拟手指接触屏幕-touchon) 返回的触摸事件对象所占用的手指 id  
        
    - 示例  
        ```lua
        touch.on(100, 100):off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，然后于当前位置离开屏幕
        
        touch.on(100, 100):off(105, 95) -- 模拟一个手指于点 100, 100 的位置接触屏幕，然后于 105, 95 这个位置离开屏幕
        ```



---
<br />

- ### 设置触摸事件对象移动步长 (**:step\_len**)
    - 声明  
        ```lua
        触摸事件 = 触摸事件:step_len(步长)
        ```
    
    - 参数及返回值  
        > - 步长  
            整数型，可选参数，默认为 2  
        > - 触摸事件  
            触摸事件对象，通过调用 [touch.on](#模拟手指接触屏幕-touchon) 函数可以获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 设置当前触摸事件对象使用 move 方法滑动的步长  
        
    - 示例  
        ```lua
        touch.on(100, 100):step_len(3):step_delay(0.2):move(200,200):off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，以步长为 3 、每步延迟为 0.2 毫秒的速度滑动到点 200, 200 的位置离开屏幕
        ```



---
<br />

- ### 设置触摸事件对象移动每步延迟 (**:step\_delay**)
    - 声明  
        ```lua
        触摸事件 = 触摸事件:step_delay(每步延迟)
        ```
    
    - 参数及返回值  
        > - 每步延迟毫秒  
            实数型，可选参数，每步延迟时间，单位毫秒，默认 0\.1  
        > - 触摸事件  
            触摸事件对象，通过调用 [touch.on](#模拟手指接触屏幕-touchon) 函数可以获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 设置当前触摸事件对象使用 move 方法滑动的每步延迟  
        
    - 示例  
        ```lua
        touch.on(100, 100):step_len(3):step_delay(0.2):move(200,200):off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，以步长为 3 、每步延迟为 0.2 毫秒的速度滑动到点 200, 200 的位置离开屏幕
        ```



---
<br />

- ### \! 毫秒级延迟 (**:msleep**)
    - 声明  
        ```lua
        触摸事件 = 触摸事件:msleep(毫秒数)
        ```
    
    - 参数及返回值  
        > - 毫秒数  
            实数型，可选参数，延迟时间，单位毫秒，默认 0\.1  
        > - 触摸事件  
            触摸事件对象，通过调用 [touch.on](#模拟手指接触屏幕-touchon) 函数可以获得一个用于操控当前触摸的事件对象  
    
    - 说明  
        > 延迟函数，这个函数不会对对象有影响，仅仅起个阻塞当前线程的作用，该方法有个别名 :delay
        > **这个方法可能会让出，在这个方法返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**
        
    - 示例  
        ```lua
        touch.on(100, 100):msleep(300):off() -- 模拟一个手指于点 100, 100 的位置接触屏幕，等待 300 毫秒，离开屏幕
        ```



---
<br />

- ### 设置触摸圆点显示 (**touch\.show\_pose**)
    - 声明  
        ```lua
        touch.show_pose(是否显示)
        ```
    
    - 参数及返回值
        > - 是否显示
            布尔型，true 为显示；false 为不显示
    
    - 说明  
        > 设置 touch 模块函数调用时是否显示圆点在屏幕上
        > **打开圆点显示会极大降低 touch 模块函数的效率，并且长时间使用会影响系统稳定性，建议仅用于调试环境**
        
    - 示例  
        ```lua
        touch.show_pose(true)
        touch.tap(100, 100)
        ```



---
<br />

- ### touch 示例代码
    ```lua
    -- 可以这样：
    touch.on(306, 300):step_len(2):step_delay(0):move(350, 800):msleep(1000):off()
    
    -- 上面那个例子也能写成这样：
    touch.on(306, 300)  -- 模拟手指在 306,300 这个坐标点接触屏幕
    	:step_len(2)   -- 设置移动步长为 2
    	:step_delay(0) -- 设置移动每步延迟为 0
    	:move(350, 800) -- 以上面两个参数所设置移动到 350,800 这个坐标
    	:msleep(1000)   -- 等 1000 毫秒（也就是 1 秒）
    :off()             -- 手指离开屏幕
    
    -- 或是这样：
    local te = touch.on(306,300)
    te:step_len(2)
    te:step_delay(0)
    te:move(350, 800)
    te:msleep(1000)
    te:off()
    
    -- 通常情况下，滑动代码可以写成这样
    touch.on(306, 300)
    	:move(350, 800)
    	:msleep(1000)
    :off()
    
    -- 等效于
    touch.on(306, 300):move(350, 800):msleep(1000):off()
    
    -- 也可以这样用于模拟轻触屏幕一次
    touch.on(306, 300):msleep(30):off()
    
    ```

- ### 精确滑动的实现示例
    ```lua
    -- 快速精确滑动可能需要一些技巧，看下面的例子以及注释
    
    touch.on(125, 2000) -- 在起始坐标按下
    	:step_len(10)   -- 步长设长以便加速滑动
    	:move(125, 555) -- 快速移动到接近目标位置
    	:step_len(1)    -- 步长设短缓冲防止惯性
    	:move(125, 505) -- 慢速移动目标位置
    	:delay(100)     -- 抬起前等待一段时间
    :off()              -- 抬起手指
    ```



---
<br />
<br />
<br />

## 模拟按键模块（key）
- ### 模拟按一下物理按键 (**key\.press**)
    - 声明  
        ```lua
        key.press(按键码)
        ```
    
    - 参数及返回值
        > - 按键码  
            文本型，物理按键的按键码，键码在 [示例及支持的键码列表](#示例及支持的键码列表) 一节查看  
    
    - 说明  
        > 模拟按下物理按键然后松开它
        > **与此函数已知的冲突插件：Background Manager**
        
    - 示例  
        [`本章结尾`](#示例及支持的键码列表)



---
<br />

- ### 模拟按下物理按键 (**key\.down**)
    - 声明  
        ```lua
        key.down(按键码)
        ```
    
    - 参数及返回值
        > - 按键码
            文本型，物理按键的按键码，键码在 [示例及支持的键码列表](#示例及支持的键码列表) 一节查看
    
    - 说明  
        > 模拟按下物理按键
        > **注意** 这个函数应当有对应的 [`key.up`](#松开按下的物理按键-keyup) 调用，否则在脚本终止之后，会发生按键一直不释放的问题。
        > **与此函数已知的冲突插件：Background Manager**
        
    - 示例  
        [`本章结尾`](#示例及支持的键码列表)



---
<br />

- ### 松开按下的物理按键 (**key\.up**)
    - 声明  
        ```lua
        key.up(按键码)
        ```
    
    - 参数及返回值  
        > - 按键码  
            文本型，物理按键的按键码，键码在 [示例及支持的键码列表](#示例及支持的键码列表) 一节查看  
    
    - 说明  
        > 模拟松开按下物理按键  
        > **与此函数已知的冲突插件：Background Manager**  
        
    - 示例  
        [`本章结尾`](#示例及支持的键码列表)



---
<br />

- ### 模拟键入文本 (**key\.send\_text**)
    - 声明  
        ```lua
        key.send_text(文本 [, 每键延迟, Shift键延迟 ])
        ```
    
    - 参数及返回值  
        > - 文本  
            文本型，待输入的文字，只能是英文数字和半角字符还有 `"\b"` `"\r"` `"\t"`  
        > - 每键延迟  
            整数型，输入每次按键延迟，默认没有延迟以设备性能极限输入  
        > - Shift键延迟  
            整数型，大写字母或是某些特殊符号需要按住 Shift 输入，例如 `@` 是 `Shift + 2`  
    
    - 说明  
        > 该函数可用于所有的 input\_text 函数都无效的情况下，强行模拟键盘键入  
        > 亲测可以输入支付宝的支付密码  
        > **与此函数已知的冲突插件：Background Manager**  
        
    - 示例  
        ```lua
        key.send_text("AbC12#") -- 尽可能快的键入文本
        
        key.send_text("AbC12#", 300) -- 每键入一次延迟 0.3 秒
        ```



---
<br />

### 示例及支持的键码列表

- 模拟按 HOME 键
    ```lua
    key.press("HOMEBUTTON")
    ```

- 模拟长按 HOME 键
    ```lua
    key.down("HOMEBUTTON") -- 按下 HOME 键
    sys.msleep(1000) -- 等待 1 秒
    key.up("HOMEBUTTON") -- 松开 HOME 键
    ```

- 模拟双击 HOME 键
    ```lua
    key.press("HOMEBUTTON")
    key.press("HOMEBUTTON")
    ```

- 模拟按锁屏键（电源键）
    ```lua
    key.press("LOCK")
    ```

- 模拟按回车键
    ```lua
    key.press("RETURN")
    ```

- 其它模拟
    ```lua
    -- 下面这个例子是模拟组合键 [command + v] 粘贴剪贴板的文本（不是 windows 上的 control + v ）
    key.down("LEFTCOMMAND") -- 按下 command 键
    sys.msleep(20) -- 等待 20 毫秒
    key.press("V") -- 按一下 v 键
    sys.msleep(20) -- 等待 20 毫秒
    key.up("LEFTCOMMAND") -- 松开 command 键
    
    key.press("VOLUMEUP") -- 按一下音量 + 键
    key.press("VOLUMEDOWN") -- 按一下音量 - 键
    
    key.down("VOLUMEUP") -- 按下音量 + 键
    sys.msleep(1000) -- 等待 1 秒
    key.up("VOLUMEUP") -- 松开音量 + 键
    
    key.down("LOCK") -- 按下锁屏键（电源键）
    sys.msleep(3000) -- 等待 3 秒
    key.up("LOCK") -- 松开锁屏键（电源键）
    
    key.press("SHOW_HIDE_KEYBOARD") -- 按一下[隐藏/显示键盘键]隐藏虚拟键盘
    
    key.press("SHOW_HIDE_KEYBOARD") -- 再按一下[隐藏/显示键盘键]显示虚拟键盘
    
    -- 下面这个例子是模拟组合键 [锁屏键 + HOME键] 实现截屏到相册
    key.down("LOCK") -- 按下锁屏键（电源键）
    sys.msleep(100) -- 等待 100 毫秒
    key.press("HOMEBUTTON") -- 按一下 HOME 键
    sys.msleep(100) -- 等待 100 毫秒
    key.up("LOCK") -- 松开锁屏键（电源键）
    
    -- iOS7、iOS8 切换输入法的组合键
    key.down("LEFTCOMMAND")
    sys.msleep(50)
    key.press(" ")
    sys.msleep(50)
    key.up("LEFTCOMMAND")
    
    -- iOS9 切换输入法的组合键
    key.down("LEFTCONTROL")
    sys.msleep(50)
    key.press("SPACE")
    sys.msleep(50)
    key.up("LEFTCONTROL")
    
    
    ```

    **注**：上述代码中使用了非本章函数 [`sys.msleep`](#毫秒级延迟\-msleep)

- 支持的键码列表

    ```lua
    -- 字母键：
    "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"
    
    -- 数字键：
    "1" "2" "3" "4" "5" "6" "7" "8" "9" "0"
    
    -- 功能键：
    "F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8" "F9" "F10" "F11" "F12"
    
    -- 其它键：
    "RETURN"        --< 回车键
    "ESCAPE"        --< ESC键
    "BACKSPACE"     --< 退格键
    "TAB"           --< 制表符键
    "SPACE"         --< 空格键
    "HYPHEN"        --< "-" 或 "_" 键
    "EQUAL"         --< "=" 或 "+" 键
    "BRACKETOPEN"   --< "[" 或 "{" 键
    "BRACKETCLOSE"  --< "]" 或 "}" 键
    "BACKSLASH"     --< "\" 或 "|" 键
    "SEMICOLON"     --< ";" 或 ":" 键
    "QUOTATION"     --< 单引号或双引号键
    "ACCENT"        --< "`" 或 "~" 键
    "COMMA"         --< "," 或 "<" 键
    "DOT"           --< "." 或 ">" 键
    "SLASH"         --< "/" 或 "?" 键
    "CAPSLOCK"      --< 大小写锁定键
    "PAUSE"
    "INSERT"
    "HOME"          --< 这个不完全等于 iOS 设备的 HOME 键
    "PAGEUP"
    "DELETE"
    "END"
    "PAGEDOWN"
    "RIGHTARROW"    --< 向右箭头键
    "LEFTARROW"     --< 向左箭头键
    "DOWNARROW"     --< 向下箭头键
    "UPARROW"       --< 向上箭头键
    "LEFTCONTROL"   --< 左侧 Ctrl 键
    "LEFTSHIFT"     --< 左侧 Shift 键
    "LEFTALT"       --< 左侧 Alt 键
    "LEFTCOMMAND"   --< 左侧 Command 键
    "RIGHTCONTROL"  --< 右侧 Ctrl 键
    "RIGHTSHIFT"    --< 右侧 Shift 键
    "RIGHTALT"      --< 右侧 Alt 键
    "RIGHTCOMMAND"  --< 右侧 Command 键
    "LOCK"          --< 锁屏键，或电源键
    "HOMEBUTTON"    --< 这个才等于 iOS 设备的 HOME 键
    "FORWARD"       --< 多媒体下一首
    "REWIND"        --< 多媒体上一首
    "FORWARD2"      --< 多媒体下一首2
    "REWIND2"       --< 多媒体上一首2
    "EJECT"
    "PLAYPAUSE"     --< 多媒体暂停键
    "MUTE"          --< 静音键
    "VOLUMEUP"      --< 音量 + 键
    "VOLUMEDOWN"    --< 音量 - 键
    "SPOTLIGHT"     --< Spotlight 键
    "BRIGHTUP"      --< 屏幕亮度 + 键
    "BRIGHTDOWN"    --< 屏幕亮度 - 键
    "SHOW_HIDE_KEYBOARD" --< 隐藏/显示键盘键
    ```



---
<br />
<br />
<br />

## 模拟重力加速计模块（accelerometer）
- ### 模拟加速计数据 (**accelerometer\.simulate**)
    - 声明  
        ```lua
        accelerometer.simulate(横坐标, 纵坐标, 垂直坐标, 附加选项)
        ```
    
    - 参数及返回值  
        > - 横坐标  
            实数型， x 轴加速度  
        > - 纵坐标  
            实数型， y 轴加速度  
        > - 垂直坐标  
            实数型， z 轴加速度  
        > - 附加选项  
            * 整数型  
                0 为普通  
                1 为摇晃  
    
    - 说明  
        > 模拟加速器数据  
        **这个函数不支持 iOS 10 及以上版本操作系统**  
        
    - 示例  
        ```lua
        for i = 1, 100 do
            accelerometer.simulate(i, i, i, 0)
        end
        ```



---
<br />

- ### 模拟摇一摇 (**accelerometer\.shake**)
    - 声明  
        ```lua
        accelerometer.shake()
        ```
    
    - 说明  
        > 对 accelerometer\.simulate 的封装，模拟摇一摇手机  
        **这个函数不支持 iOS 10 及以上版本操作系统**  
        
    - 示例  
        ```lua
        for i = 1, 10 do -- 摇十下
            accelerometer.shake()
            sys.msleep(1000)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.msleep`](#毫秒级延迟\-sysmsleep)



---
<br />

- ### 改变当前重力方向为 home 在左 (**accelerometer\.rotate\_home\_on\_left**)
    - 声明  
        ```lua
        accelerometer.rotate_home_on_left()
        ```
    
    - 说明  
        > 对 accelerometer\.simulate 的封装  
        > 如果前台 App 并不支持横屏，那这个调用无效果  
        **这个函数不支持 iOS 10 及以上版本操作系统**  
        
    - 示例  
        ```lua
        --
        ```



---
<br />

- ### 改变当前重力方向为 home 在右 (**accelerometer\.rotate\_home\_on\_right**)
    - 声明  
        ```lua
        accelerometer.rotate_home_on_right()
        ```
    
    - 说明  
        > 对 accelerometer\.simulate 的封装  
        > 如果前台 App 并不支持横屏，那这个调用无效果  
        **这个函数不支持 iOS 10 及以上版本操作系统**  
        
    - 示例  
        ```lua
        --
        ```



---
<br />

- ### 改变当前重力方向为 home 在上 (**accelerometer\.rotate\_home\_on\_top**)
    - 声明  
        ```lua
        accelerometer.rotate_home_on_top()  
        ```
    
    - 说明  
        > 对 accelerometer\.simulate 的封装  
        > 如果前台 App 并不支持竖屏，那这个调用无效果  
        **这个函数不支持 iOS 10 及以上版本操作系统**  
        
    - 示例  
        ```lua
        --
        ```



---
<br />

- ### 改变当前重力方向为 home 在下 (**accelerometer\.rotate\_home\_on\_bottom**)
    - 声明  
        ```lua
        accelerometer.rotate_home_on_bottom()
        ```
    
    - 说明  
        > 对 accelerometer\.simulate 的封装  
        > 如果前台 App 并不支持竖屏，那这个调用无效果  
        **这个函数不支持 iOS 10 及以上版本操作系统**  
        
    - 示例  
        ```lua
        --
        ```



---
<br />
<br />
<br />

## 系统模块（sys）
- ### 显示提示文字 (**sys\.toast**)
    - 声明  
        ```lua
        sys.toast(文字内容 [, 旋转方向 ])
        ```
    
    - 参数及返回值  
        > - 文字内容  
            文本型， 代表需要显示的文字  
        > - 旋转方向  
            整数型，屏幕旋转方向，可选参数，默认为最后一次调用 [screen.init](#初始化旋转坐标系-init) 所设的那个方向  
                有效取值范围：  
                `0` \- 竖屏 home 在下  
                `1` \- 横屏 home 在右  
                `2` \- 横屏 home 在左  
                `3` \- 竖屏 home 在上  
                `-1` \- 立刻隐藏 toast  
    
    - 说明  
        > 在当前旋转坐标系的屏幕下方显示提示文字  
        > **该函数是异步进行的，提示文字总计显示时间为 2\.8 秒，会影响取色，不会拦截点击**  
        
    - 示例  
        ```lua
        -- 显示一个 toast
        sys.toast("果断 hello world")
        ```
        
        ```lua
        -- 实时显示当前日期时间
        while (true) do
        	sys.toast("默认长按音量键可停止脚本\n\n"..os.date("%Y年%m月%d日%H点%M分%S秒"), device.front_orien())
        	sys.msleep(1000)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`device.front_orien`](#获取前台应用的画面方向\-devicefrontorien)、[`os.date`](#osdate-日期格式化相关)
        



---
<br />

- ### 弹出系统提示 (**sys\.alert**)
    - 声明  
        ```lua
        选择 = sys.alert(文字内容 [, 自动消失秒数, 标题, 按钮0标题, 按钮1标题, 按钮2标题 ])
        ```
    
    - 参数及返回值  
        > - 文字内容
            文本型， 代表弹出提示内容  
        > - 自动消失秒数  
            实数型， 可选参数，代表弹窗自动消失时间，单位秒，设置 `0` 不自动消失，默认 `0`  
        > - 标题  
            文本型， 可选参数，代表弹出提示的标题，默认 `"XXT"`  
            \* 1\.2\-1 版以上默认标题为 `"脚本提示"`  
        > - 按钮0（取消按钮）标题  
            文本型， 可选参数，代表弹出提示窗的默认按钮的标题，默认为 `"好"`  
        > - 按钮1标题  
            文本型， 可选参数，代表弹出提示窗的额外的第 1 个按钮标题，默认不显示这个按钮  
        > - 按钮2标题  
            文本型， 可选参数，代表弹出提示窗的额外的第 2 个按钮标题，默认不显示这个按钮  
        > - 选择  
            * 整数型  
                返回 `0` 代表选择了 按钮0（取消按钮）  
                返回 `1` 代表选择了 按钮1  
                返回 `2` 代表选择了 按钮2  
                返回 `3` 代表超时自动消失  
                返回 `71` 代表春板（SpringBoard）挂了  
    
    - 说明  
        > 弹出一个系统提示对话框，最多可以有 3 个按钮，阻塞所有线程等待返回  
        
    - 示例  
        ```lua
        local choice = sys.alert('你现在将要干啥？', 10, '你的选择', '取消', '吃饭', '睡觉')
        if choice==0 then
            sys.alert('你选择‘取消’')
        elseif choice==1 then
            sys.alert('你选择‘吃饭’')
        elseif choice==2 then
            sys.alert('你选择‘睡觉’')
        elseif choice==3 then
            sys.alert('你没有选择，超时了')
        else
            sys.alert('春板挂了')
        end
        ```



---
<br />

- ### 弹出输入提示 (**sys\.input\_box**)
    
    - 说明  
        > 弹出一个系统输入对话框，最多可以有 3 个按钮，2 个文本框，阻塞所有线程等待返回  
        > 标题默认为 `"XXT"`  
        > \* 1\.2\-1 版以上默认标题为 `"脚本提示"`  
        
    - 示例  
        ```lua
        输入的内容 = sys.input_box("描述内容")

        输入的内容 = sys.input_box("标题", "这是描述内容")
        
        输入的内容 = sys.input_box("标题", "这是描述内容", 0)
        
        输入的内容 = sys.input_box("标题", "描述内容", "文本框阴影提示", 0)
        
        输入的内容 = sys.input_box("标题", "描述内容", "文本框阴影提示", "文本框里面的内容", 0)
        
        输入的内容 = sys.input_box("标题", "描述内容", "文本框阴影提示", "文本框里面的内容", "默认按钮标题", 0)
        
        输入的内容, 做出的选择 = sys.input_box("标题", "描述内容", "文本框阴影提示", "文本框里面的内容", "默认按钮标题", "按钮1标题", 0)
        
        输入的内容, 做出的选择 = sys.input_box("标题", "描述内容", "文本框阴影提示", "文本框里面的内容", "默认按钮标题", "按钮1标题", "按钮2标题", 0)
        
        输入的内容1, 输入的内容2 = sys.input_box("标题", "描述内容", {"文本框1阴影提示", "文本框2阴影提示"}, 0)
        
        输入的内容1, 输入的内容2 = sys.input_box("标题", "描述内容", {"文本框1阴影提示", "文本框2阴影提示"}, {"文本框1里面的内容", "文本框2里面的内容"}, 0)
        
        输入的内容1, 输入的内容2, 做出的选择 = sys.input_box("标题", "描述内容", {"文本框1阴影提示", "文本框2阴影提示"}, {"文本框1里面的内容", "文本框2里面的内容"}, "默认按钮标题", "按钮1标题", "按钮2标题", 0)
        ```



---
<br />

- ### 输入文字 (**sys\.input\_text**)
    - 声明  
        ```lua
        sys.input_text(文字内容 [, 输入完成按回车 ])
        ```
    
    - 参数及返回值  
        > - 文字内容  
            文本型，需要输入的文字，**不支持** \\b （退格键）  
        > - 输入完成按回车  
            布尔型，是否在输入完毕后按下键盘上的回车键（发送、搜索等），默认 false  
    
    - 说明  
        > 在前台程序的可以输入文本的地方输入文字  
        > 该函数原理为先将文本写入剪贴板，然后调用粘贴快捷键（**command \+ v**）粘贴文本  
        > **该函数的调用会影响公共剪贴板，请注意在调用之前备份好剪贴板中的重要数据**  
        > **在系统公共剪贴板损坏的情况下，该函数的文字输入会失效。也就是不能复制粘贴文字，就不能用**  
        > **与此函数已知的冲突插件：Background Manager**  
        > 如果遇到无法作用的情况可以参考 [`app.input_text`](#输入文字\-appinputtext) 或许能解决  
        
    - 示例  
        ```lua
        sys.input_text("我爱你") -- 在当前光标所在文本框输入“我爱你”
        
        sys.input_text("我爱你", true) -- 在QQ聊天界面输入“我爱你”然后按下回车发送出去
        ```



---
<br />

- ### \! 毫秒级延迟 (**sys\.msleep**)
    - 声明  
        ```lua
        sys.msleep(毫秒数)
        ```
    
    - 参数及返回值  
        > - 毫秒数  
            实数型， 需要延迟等待的时间，单位毫秒  
    
    - 说明  
        > 让当前线程阻塞等待一定时间  
        > **这个方法可能会让出，在这个方法返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```lua
        sys.msleep(1000) -- 等待 1 秒
        ```



---
<br />

- ### 获取当前毫秒级时间戳 (**sys\.mtime**)
    - 声明  
        ```lua
        时间戳 = sys.mtime()
        ```
    
    - 参数及返回值  
        > - 时间戳  
            整数型， 返回毫秒级 UNIX 时间戳  
        
    - 示例  
        ```lua
        local ms = sys.mtime()
        screen.keep()
        sys.alert('一次 screen.keep 耗时：'..sys.mtime()-ms..'毫秒')
        ```
        **注**：上述代码中使用了非本章函数 [`screen.keep`](#保持屏幕\-screenkeep)



---
<br />

- ### \! 获取网络时间 (**sys\.net\_time**)
    - 声明  
        ```lua
        时间戳 = sys.net_time([ 超时时间 ])
        ```
    
    - 参数及返回值  
        > - 超时时间  
            实数型，可选参数，用于设置获取网络时间联网的最大等待时间（单位：秒），默认 2  
        > - 时间戳  
            整数型， 成功则返回当前网络时间的时间戳，连接超时或未能成功获取网络时间返回 0  
    
    - 说明  
        > **这个方法可能会让出，在这个方法返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```lua
        local nt = sys.net_time() -- 获取网络时间，默认 2 秒超时，超时返回 0
        
        local nt = sys.net_time(5) -- 获取网络时间，5 秒超时，超时返回 0
        if nt==0 then
            sys.alert('获取网络时间失败')
        else
            sys.alert(os.date('当前网络时间\n%Y-%m-%d %H:%M:%S', nt))
        end
        ```
        **注**：上述代码中使用了 [os\.date 日期格式化相关](#osdate\-日期格式化相关)



---
<br />

- ### 产生一个随机数 (**sys\.rnd**)
    - 声明  
        ```lua
        随机数字 = sys.rnd()
        ```
    
    - 参数及返回值
        > - 随机数字
            整数型，返回一个随机数字，范围 0~4294967295
    
    - 说明  
        > 产生一个真随机数
        
    - 示例  
        ```lua
        math.randomseed(sys.rnd()) -- 初始化随机因子为一个真随机数
        local r = math.random(1, 100) -- 产生一个 1~100 范围的随机数
        ```



---
<br />

- ### 获取设备当前内存状态信息 (**sys\.memory\_info**)
    - 声明  
        ```lua
        内存状态 = sys.memory_info()
        ```
    
    - 参数及返回值  
        > - 内存状态  
            表型，返回的内存状态信息，里面的 key \- value 对应自己理解吧  
        
    - 示例  
        ```lua
        sys.alert(table.deep_print(sys.memory_info()))
        ```
        **注**：上述代码中使用了非本章函数 [`table.deep_print`](#深打印一个表\-tabledeepprint)


---
<br />

- ### 获取设备当前可用内存值 (**sys\.available\_memory**)
    - 声明  
        ```lua
        可用内存 = sys.available_memory()
        ```
    
    - 参数及返回值  
        > - 可用内存  
            实数型，返回当前设备的空闲内存值（单位：MB）  
        
    - 示例  
        ```lua
        sys.alert('当前可用内存为：'..sys.available_memory()..'MB')
        ```



---
<br />

- ### 获取设备当前未使用的存储空间值 (**sys\.free\_disk\_space**)
    - 声明  
        ```lua
        剩余空间 = sys.free_disk_space([挂载点])
        ```
    
    - 参数及返回值  
        > - 挂载点  
            文本型，默认有效取值范围为 `"/var"` 或是 `"/"`，分别代表用户空间和系统空间。有外部存储比如内存卡的时候可以有其它值  
        > - 剩余空间  
            实数型，返回设备当前未使用的存储空间值（单位：MB）  
        
    - 示例  
        ```lua
        sys.alert(
        	'当前系统空间剩余\n'..sys.free_disk_space('/')..'MB\n\n'..
        	'当前用户空间剩余\n'..sys.free_disk_space('/var')..'MB'
        )
        ```



---
<br />

- ### 输出标准系统日志 (**sys\.log**)
    - 声明  
        ```lua
        sys.log(日志内容)
        ```
    
    - 参数及返回值  
        > - 日志内容  
            文本型，代表需要输出的日志内容  
    
    - 说明  
        > 输出标准系统日志  
        日志可以使用电脑浏览器打开远程接口 **http://<设备IP地址\>:46952/log\.html** 实时查看  
        日志会同时存储到设备上的 **/var/mobile/Meida/1ferver/log/sys.log** 文件中  
        **/var/mobile/Meida/1ferver/log/sys\.log** 记录的日志最多不会超过 4000 行，超过则删前面的  
        
    - 示例  
        ```lua
        sys.log("当然是 Hello World 啦")
        ```



---
<br />

- ### 问系统一个问题 (**sys\.mgcopyanswer**)
    - 声明  
        ```lua
        答案 = sys.mgcopyanswer(问题)
        ```
    
    - 参数及返回值  
        > - 问题  
            文本型，问题名字，一些 问题名字 参考 [MobileGestalt.h](https://github.com/Cykey/ios-reversed-headers/blob/master/MobileGestalt/MobileGestalt.h)  
        > - 答案  
            字符串型 或 表型 或 实数型 或 整数型 或 布尔型 或 nil，系统的回复，如果问题不被支持，则返回 nil  
    
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        > 获取一些系统信息，底层使用 MGCopyAnswer 完成  
        > 获取系统信息 读取系统信息 获取设备信息 读取设备信息 设备标识  
        
    - 示例  
        ```lua
        sys.alert("设备的序列号是："..sys.mgcopyanswer("SerialNumber"))
        sys.alert("设备的IMEI是："..sys.mgcopyanswer("InternationalMobileEquipmentIdentity"))
        sys.alert("设备的MEID是："..sys.mgcopyanswer("MobileEquipmentIdentifier"))
        ```



---
<br />

- ### 获取系统版本 (**sys\.version**)
    - 声明  
        ```lua
        系统版本 = sys.version()
        ```
    
    - 参数及返回值  
        > - 系统版本  
            文本型，返回系统版本号  
        
    - 示例  
        ```lua
        sys.alert('当前系统版本：'..sys.version())
        ```



---
<br />

- ### 获取 XXTouch 版本 (**sys\.xtversion**)
    - 声明  
        ```lua
        版本号 = sys.xtversion()
        ```
    
    - 参数及返回值  
        > - 版本号  
            文本型，返回 XXTouch 版本号  
        
    - 示例  
        ```lua
        sys.alert('当前 XXTouch 版本：'..sys.xtversion())
        ```



---
<br />

- ### 获取 CoreFoundation 版本 (**sys.cfversion**)
    - 声明  
        ```lua
        版本号 = sys.cfversion()
        ```
    
    - 参数及返回值  
        > - 版本号  
            文本型，返回 CoreFoundation 版本号  
    - 说明
        > **软件版本在 1.3.8 或以上方可使用**  

    - 示例  
        ```lua
        sys.alert('当前 CoreFoundation 版本：'..sys.cfversion())
        ```



---
<br />
<br />
<br />

## 剪贴板模块（pasteboard）
- ### 写内容进剪贴板 (**pasteboard\.write**)
    - 声明  
        ```lua
        pasteboard.write(数据 [, 通用类型标识 ])
        ```
    
    - 参数及返回值  
        > - 数据  
            字符串型，需要写入到剪贴板的内容  
        > - 通用类型标识  
            文本型，可选参数，[Uniform Type Identifiers](https://developer.apple.com/library/ios/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)，默认 "public\.utf8\-plain\-text"  
        
    - 示例  
        ```lua
        pasteboard.write("演示啊") -- 将“演示啊”（不含引号）写入到剪贴板中
        
        pasteboard.write(screen.image():png_data(), 'public.png') -- 将当前屏幕截图写入到剪贴板
        ```
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)



---
<br />

- ### 获取剪贴板中的数据 (**pasteboard\.read**)
    - 声明  
        ```lua
        数据 = pasteboard.read([ 通用类型标识 ])
        ```
    
    - 参数及返回值  
        > - 通用类型标识  
            文本型，可选参数，[Uniform Type Identifiers](https://developer.apple.com/library/ios/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)，默认 自动判断格式  
            **存在 通用类型标识 参数的情况下，会强制以该 通用类型标识 格式读取剪贴板中数据，若是剪贴板中数据无法以该 通用类型标识 读取，则返回空字符串**  
        > - 数据  
            字符串型，返回剪贴板中的数据，可能是文本，也可能是二进制数据，如果不能以该方式读取，则返回 `""`（空文本）  
        
    - 示例  
        ```lua
        sys.alert("剪贴板中的内容："..pasteboard.read())
        
        sys.alert("剪贴板中的内容："..pasteboard.read('public.text')) -- 富文本也强行以文本方式读取剪贴板
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


---
<br />
<br />
<br />

## 对话框模块（dialog）
- ### \! 建立一个对话框对象 (**dialog**)
    - 声明  
        ```lua
        对话框对象 = dialog()
        ```
    
    - 参数及返回值  
        > - 对话框对象  
            对话框，返回一个对话框对象  
    
    - 说明  
        > 建立一个对话框对象  
        > **注意** 这个函数没有参数，**请不要** 给任何参数，带参数调用是弹出一个弹窗，声明如下  
        ```lua
        dialog(弹窗内容:文本型, 超时秒:实数型)
        ```
        > 例如  
        ```lua
        dialog('Hello, XXTouch!', 10)
        ```
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 配置对话框配置保存文件名 (**:config**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:config(配置名)
        ```
    
    - 参数及返回值  
        > - 配置名  
            文本型，配置对话框对象的选项配置保存名  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > 对话框显示出来，并且用户按下 **提交** 后会保存配置选项，再次显示出来的时候默认选上保存好的配置  
        > 配置将以文件形式保存在 /private/var/mobile/Media/1ferver/uicfg/**<配置名>**.xcfg  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 配置对话框配置保存文件名 (**:set_config**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:set_config(配置名)
        ```
    
    - 参数及返回值  
        > - 配置名  
            文本型，配置对话框对象的选项配置保存名  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.2\-1 版以上方可使用**  
        > 对话框显示出来，并且用户按下 **提交** 后会保存配置选项，再次显示出来的时候默认选上保存好的配置  
        > 配置将以文件形式保存在 /private/var/mobile/Media/1ferver/uicfg/**<配置名>**.xcfg  
        > 与旧版 \:config 方法等效  



---
<br />

- ### 配置对话框自动消失时间 (**:timeout**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:timeout(超时秒[, 是否提交])
        ```
    
    - 参数及返回值  
        > - 超时秒  
            实数型，对话框对象自动消失时间，单位秒  
        > - 是否提交 \* 1\.2\-1 新增  
            布尔型，可选参数，对话框自动消失是否算提交，true 为是，false 为否，默认 false 超时算不提交  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > 配置对话框自动消失时间  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 配置对话框自动消失时间 (**:set_timeout**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:set_timeout(超时秒[, 是否提交])
        ```
    
    - 参数及返回值  
        > - 超时秒  
            实数型，对话框对象自动消失时间，单位秒  
        > - 是否提交  
            布尔型，可选参数，对话框自动消失是否算提交，true 为是，false 为否，默认 false 超时算不提交  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.2\-1 版以上方可使用**  
        > 配置对话框自动消失时间，与旧版 \:timeout 方法等效  



---
<br />

- ### 配置对话框的标题 (**:title**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:title(标题文本)
        ```
    
    - 参数及返回值  
        > - 标题文本  
            文本型，对话框的标题  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > 配置对话框的标题  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 配置对话框的标题 (**:set_title**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:set_title(标题文本)
        ```
    
    - 参数及返回值  
        > - 标题文本  
            文本型，对话框的标题  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.2\-1 版以上方可使用**  
        > 配置对话框的标题，与旧版 \:title 方法等效  



---
<br />

- ### 配置对话框的尺寸 (**:set_size**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:set_size(宽度, 高度)
        ```
    
    - 参数及返回值  
        > - 宽度, 高度  
            整数型，对话框对象宽高，如果不设置默认是全屏宽高  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.2\-1 版以上方可使用**  
        > 设置对话框的尺寸，如果对话框不是全屏，则会居中于屏幕，并使用半径为 10 的圆角  
        
    - 示例  
        ```lua
        local dlg = dialog()
        dlg:set_size(600, 800)
        dlg:show()
        ```



---
<br />

- ### 配置对话框的位置及尺寸 (**:set_frame**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:set_frame(横坐标, 纵坐标, 宽度, 高度)
        ```
    
    - 参数及返回值  
        > - 横坐标, 纵坐标  
            整数型，对话框对象左上角位置的横坐标及纵坐标  
        > - 宽度, 高度  
            整数型，对话框对象宽高，如果不设置默认是全屏宽高  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.2\-1 版以上方可使用**  
        > 配置对话框的位置及尺寸，使用方角  
        
    - 示例  
        ```lua
        local dlg = dialog()
        dlg:set_frame(0, 0, 600, 800)
        dlg:show()
        ```



---
<br />

- ### 配置对话框的圆角半径 (**:set_corner_radius**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:set_corner_radius(圆角半径)
        ```
    
    - 参数及返回值  
        > - 圆弧半径  
            整数型，圆角半径，0 为方角  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.2\-1 版以上方可使用**  
        > 配置对话框的圆角半径，需要使用圆角对话框的时候可以派上用场  
        
    - 示例  
        ```lua
        local dlg = dialog()
        dlg:set_frame(0, 0, 600, 800)
        dlg:set_corner_radius(50)
        dlg:show()
        ```



---
<br />

- ### 给对话框加上一个文本标签 (**:add\_label**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_label(标签内容)
        ```
    
    - 参数及返回值  
        > - 标签内容  
            文本型，标签显示的文本  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > 给对话框加上一个文本标签  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 给对话框加上一个文本输入框 (**:add\_input**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_input(输入框标签 [, 输入框默认内容 ])
        ```
    
    - 参数及返回值  
        > - 输入框标签  
            文本型，文本框左侧标签显示的文本  
        > - 输入框默认内容  
            文本型 或 实数型，文本框中的默认值  
        > - 对话框对象  
            对话框，返回对话框本身  
        > - 使用 :show\(\) 返回类型  
            文本型，返回输入的内容  
    
    - 说明  
        > 给对话框加上一个文本输入框  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 给对话框加上一个图片 (**:add\_image**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_image(图片)
        ```
    
    - 参数及返回值  
        > - 图片  
            图片对象，需要添加到对话框的图片  
        > - 对话框对象  
            对话框，返回对话框本身  
    
    - 说明  
        > **这个方法在 1\.1\.0\-1 版以上方可使用**  
        > 给对话框加上一个图片  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 给对话框加上一个开关 (**:add\_switch**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_switch(开关标签 [, 开关默认状态 ])
        ```
    
    - 参数及返回值  
        > - 开关标签  
            文本型，开关左侧标签显示的文本  
        > - 开关默认状态  
            布尔型，可选参数，开关的开启状态，默认 false （关）  
        > - 对话框对象  
            对话框，返回对话框本身  
        > - 使用 :show\(\) 返回类型  
            布尔型，返回这个开关被开启的状态  
    
    - 说明  
        > 给对话框加上一个开关  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 给对话框加上一个选择器 (**:add\_picker**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_picker(选择器标签, 选择器的选项们 [, 默认选择 ])
        ```
    
    - 参数及返回值  
        > - 选择器标签  
            文本型，选择器左侧标签显示的文本  
        > - 选择器的选项们  
            表型，选择器中的顺序选项名列表，不能有一样的  
        > - 默认选择  
            文本型，可选参数，选择器的默认选项名，默认为第一个  
        > - 对话框对象  
            对话框，返回对话框本身  
        > - 使用 :show\(\) 返回类型  
            文本型，返回被选择的选项名  
    
    - 说明  
        > 给对话框加上一个选择器  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 给对话框加上一个单选组 (**:add\_radio**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_radio(单选组标签, 单选组选项们 [, 默认选择 ])
        ```
    
    - 参数及返回值  
        > - 单选组标签  
            文本型，单选组标题标签显示的文本  
        > - 单选组选项们  
            表型，单选组中的顺序选项名列表，不能有一样的  
        > - 默认选择  
            文本型，可选参数，被选中的选项名，默认为 单选组选项们 中第一项  
        > - 对话框对象  
            对话框，返回对话框本身  
        > - 使用 :show\(\) 返回类型  
            文本型，返回被选中的选项名  
    
    - 说明  
        > **这个方法在 1\.1\.1\-1 版以上方可使用**  
        > 给对话框加上一个单选组  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### 给对话框加上一个多选组 (**:add\_checkbox**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_checkbox(多选组标签, 多选组选项们 [, 默认选择们 ])
        ```
    
    - 参数及返回值  
        > - 多选组标签  
            文本型，多选组标题标签显示的文本  
        > - 多选组选项们  
            表型，多选组中的顺序选项名列表，不能有一样的  
        > - 默认选择们  
            表型，可选参数，多选组的默认选项名列表，默认为 空表  
        > - 对话框对象  
            对话框，返回对话框本身  
        > - 使用 :show\(\) 返回类型  
            表型，返回所有包含所有被选择的选项的一个顺序表  
    
    - 说明  
        > 给对话框加上一个多选组  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)  



---
<br />

- ### 给对话框加上一个数值选择器 (**:add\_range**)
    - 声明  
        ```lua
        对话框对象 = 对话框对象:add_range(范围选择器标签, 范围选择器参数 [, 默认位置 ])
        ```
    
    - 参数及返回值  
        > - 范围选择器标签  
            文本型，数值选择器标题标签显示的文本  
        > - 范围选择器参数  
            表型，用于描述范围以及步进的一个表，格式为 \{最小值, 最大值, 步进值\}  
            - 最小值  
                实数型，为数值选择条最左边的位置  
            - 最大值  
                实数型，为数值选择条最右边的位置  
            - 步进值  
                实数型，可选参数，为选择条拖动的最小单位，默认为 1  
        > - 默认位置  
            实数型，可选参数，默认值，默认为最小值  
        > - 对话框对象  
            对话框，返回对话框本身  
        > - 使用 :show\(\) 返回类型  
            实数型，返回所选择的数字  
    
    - 说明  
        > **这个方法在 1\.1\.1\-1 版以上方可使用**  
        > 给对话框加上一个数值选择器  
        
    - 示例  
        [`本章结尾 :show() `](#将对话框弹出来并返回用户的选择\-show)



---
<br />

- ### \! 将对话框弹出来并返回用户的选择 (**:show**)
    - 声明  
        ```lua
        是否提交, 选项关联表 = 对话框对象:show()
        ```
    
    - 参数及返回值  
        > - 对话框对象  
            对话框，需要弹出的对话框  
        > - 是否提交  
            布尔型，返回是否按下了提交按钮，超时或点右上角叉返回 false  
        > - 选项关联表  
            表型，返回一个以选项标签映射的键值表  
    
    - 说明  
        > **这个方法在 1\.1\.1\-1 版以上方可使用**  
        > 将对话框弹出来并返回用户的选择  
        > 当对话框设置了配置保存（:config\(配置名\)）的情况下，按下 **提交** 会保存配置，按下右上的 **×** 或超时则不会保存  
        
    - 简单示例  
        ```lua
        local c, s = dialog():add_switch('一个开关', false):show()
        sys.alert(s["一个开关"])
        ```
        
    - 复杂示例  
        ```lua
        local dlg = dialog() -- 创建一个 dialog 对象
        
        -- 以下为此 dialog 对象配置
        dlg:config('test') -- 配置保存ID
        dlg:timeout(30)
        dlg:add_label('简易的效果展示')
        dlg:add_range('血量', {0, 1000, 1}, 300)
        dlg:add_input('账号', 'ccc')
        dlg:add_input('密码', 'aaaa')
        dlg:add_picker('性别', {'男', '女', '未知'}, '男')
        dlg:add_switch('你是变态?', false)
        dlg:add_checkbox('喜欢的游戏', {'守望先锋', '魔兽世界', '炉石传说'}, {'守望先锋', '魔兽世界'})
        dlg:add_radio('最喜欢的游戏', {'守望先锋', '魔兽世界', '炉石传说'}, '魔兽世界')
        	
        local confirm, selects = dlg:show() -- 显示 dialog 对象到前台并获得其返回值
        	
        if (confirm) then
            print("你按下了提交")
        else
            print("你没有按下提交")
        end
        
        print("账号", selects["账号"])
        print("密码", selects["密码"])
        print("性别", selects["性别"])
        print("血量", selects["血量"])
        
        if (selects['你是变态?']) then
        	print("你承认了自己是变态")
        else
        	print("你不承认自己是变态")
        end
        
        print("你喜欢游戏列表")
        for _,gamename in ipairs(selects['喜欢的游戏']) do
        	print(gamename)
        end
        
        print("你最喜欢游戏:"..selects["最喜欢的游戏"])
        
        sys.alert(print.out())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### \! 在不弹出对话框的情况下获得对话框配置 (**:load**)
    - 声明  
        ```lua
        是否提交, 选项关联表 = 对话框对象:load()
        ```
    
    - 参数及返回值  
        > - 对话框对象  
            对话框，需要获取返回值的对话框  
        > - 是否提交  
            布尔型，返回是否按下了提交按钮，这里将会无限返回 false  
        > - 选项关联表  
            表型，返回一个以选项标签映射的键值表  
    
    - 说明  
        > **这个方法在 1\.1\.1\-1 版以上方可使用**  
        > 在不弹出对话框的情况下获得对话框配置，如果对话框当前没有保存配置，则加载默认值  
        
    - 示例  
        ```lua
        local dlg = dialog()
        
        dlg:config('test') -- 配置保存ID
        dlg:timeout(30)
        dlg:add_label('简易的效果展示')
        dlg:add_range('血量', {0, 1000, 1}, 300)
        dlg:add_input('账号', 'ccc')
        dlg:add_input('密码', 'aaaa')
        dlg:add_picker('性别', {'男', '女', '未知'}, '男')
        dlg:add_switch('你是变态?', false)
        dlg:add_checkbox('喜欢的游戏', {'守望先锋', '魔兽世界', '炉石传说'}, {'守望先锋', '魔兽世界'})
        dlg:add_radio('最喜欢的游戏', {'守望先锋', '魔兽世界', '炉石传说'}, '魔兽世界')
        
        local _, selects
        
        if (utils.is_launch_via_app()) then -- 判断当前是否从 app 启动
            _, selects = dlg:show()         -- 从 app 启动的脚本则弹出配置窗
        else
            _, selects = dlg:load()         -- 音量键或其它方式启动的脚本则不再弹出
        end
        
        print("账号", selects["账号"])
        print("密码", selects["密码"])
        print("性别", selects["性别"])
        print("血量", selects["血量"])
        
        if (selects['你是变态?']) then
            print("你承认了自己是变态")
        else
            print("你不承认自己是变态")
        end
        
        print("你喜欢游戏列表")
        for _,gamename in ipairs(selects['喜欢的游戏']) do
            print(gamename)
        end
        
        print("你最喜欢游戏:"..selects["最喜欢的游戏"])
        
        sys.alert(print.out())
        ```
        **注**：上述代码中使用了非本章函数 [`utils.is_launch_via_app`](#判断当前脚本是否从\-app\-内启动\-utilsislaunchviaapp)、 [`sys.alert`](#弹出系统提示\-sysalert)


---
<br />
<br />
<br />

## 清理模块（clear）

- ### 清理某个或某组钥匙串信息 (**clear\.keychain**)
    - 声明  
        ```lua
        clear.keychain(信息关联名)
        ```
    
    - 参数及返回值  
        > - 信息关联名  
            文本型，一般传入公司反域名，例如 `"com.tencent"`，切不可乱传参数  
    
    - 说明  
        > 清理某个应用程序或分组的钥匙串信息，若不懂请直接用 [`clear.all_keychain`](#清理所有应用程序钥匙串信息-clearallkeychain)  
        > **警告：这个函数调用产生的效果不可逆转**  
        > **警告：切不可乱传参数！！！**  
        > **警告：该函数在给不正确的参数的情况下可能产生极其严重的后果！！！**  
        
    - 示例  
        ```lua
        clear.keychain("com.tencent") -- 清理掉与 com.tencent 相关的 keychain 信息
        ```



---
<br />

- ### 清理所有应用程序钥匙串信息 (**clear\.all\_keychain**)
    - 声明  
        ```lua
        clear.all_keychain()
        ```
    
    - 说明  
        > 清理所有应用程序钥匙串信息  
        > **警告：这个函数调用产生的效果不可逆转**  
        
    - 示例  
        ```lua
        clear.all_keychain()
        ```



---
<br />

- ### ~~清理剪贴板 (**clear\.pasteboard**)~~
    - 声明  
        ```lua
        clear.pasteboard()
        ```
    
    - 说明  
        > 清理剪贴板信息，一些信息会存在剪贴板中，比如 OpenUDID  
        > **警告：这个函数调用产生的效果不可逆转**  
        > **已弃用：** iOS 8 以后，这个函数应该只留下破坏剪贴板服务的副作用了，非必要请不要再使用它  
        
    - 示例  
        ```lua
        clear.pasteboard()
        ```



---
<br />

- ### 清理浏览器Cookies (**clear\.cookies**)
    - 声明  
        ```lua
        clear.cookies()
        ```
    
    - 说明  
        > 清理浏览器Cookies  
        > **警告：这个函数调用产生的效果不可逆转**  
        
    - 示例  
        ```lua
        clear.cookies()
        ```



---
<br />

- ### 清理系统缓存 (**clear\.caches**)
    - 声明  
        ```lua
        clear.caches()
        ```
    
    - 说明  
        > 清理系统缓存，这个函数执行会卡顿一段时间，而且卡顿期间所有线程都阻塞  
        
    - 示例  
        ```lua
        clear.caches()
        
        clear.caches{no_uicache = true} -- 1.2-2 以上版本支持不使用 uicache 清理，uicache 耗时很长，可使用 os.execute('su mobile -c uicache') 来代替
        ```



---
<br />

- ### 清除相册中所有本地照片 (**clear\.all\_photos**)
    - 声明  
        ```lua
        clear.all_photos()
        ```
    
    - 说明  
        > 清除相册中所有本地照片，不会影响 iCloud 照片流  
        > **警告：这个函数调用产生的效果不可逆转**  
        
    - 示例  
        ```lua
        clear.all_photos()
        ```



---
<br />

- ### 清理某个应用的存档数据 (**clear\.app\_data**)
    - 声明  
        ```lua
        是否成功 = clear.app_data(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，应用程序包名  
        > - 是否成功  
            布尔型，清理成功返回 true；否则返回 false  
    
    - 说明  
        > **警告：这个函数调用产生的效果不可逆转**  
        
    - 示例  
        ```lua
        clear.app_data("com.tencent.xin")
        ```



---
<br />

- ### 清理 IDFA/V (**clear\.idfav**)
    - 声明  
        ```lua
        旧IDFAV信息 = clear.idfav([ 新IDFAV信息 ])
        ```
    
    - 参数及返回值  
        > - 新IDFAV信息  
            文本型，可选参数，表示指定使用这些信息作为设备的新的 idfav 信息  
        > - 旧IDFAV信息  
            文本型 或 nil，返回设备原来的 idfav 信息，如果操作失败，则返回 nil  
    
    - 说明  
        > 重置设备 IDFA 和 IDFV 等标识信息  
        > 传入了不正确的 idfav 信息的情况下，会操作失败返回 nil  
        > 不传入参数的情况下，会清除掉设备原来的 idfav 信息，iOS系统会在之后重新随机分配 idfav  
        > 返回的 idfav 信息文本可以自行保存在文件中，等到需要恢复的时候，再当作参数传回即可  
        
    - 示例  
        ```lua
        function close_all_app() -- 定义一个遍历关闭所有的 app 的函数
            for _,bid in ipairs(app.bundles()) do
            	app.close(bid)
            end
        end
        
        -- 备份 idfav 信息
        close_all_app() -- 关闭所有应用
        local old_idfavs = clear.idfav()
        local f = io.open("/var/mobile/Media/1ferver/res/old_idfavs.txt", "wb")
        if f then
            f:write(old_idfavs)
            f:close()
            clear.caches() -- 清理一下系统缓存
            sys.alert("备份成功")
        else
            clear.idfav(old_idfavs) -- 无法备份的情况下立马恢复
            clear.caches() -- 清理一下系统缓存
            sys.alert("备份失败")
        end
        
        -- 从文件中恢复 idfav 信息
        local f = io.open("/var/mobile/Media/1ferver/res/old_idfavs.txt", "rb")
        if f then
            local old_idfavs = f:read("*a")
            f:close()
            close_all_app() -- 关闭所有应用
            local current_idfavs = clear.idfav(old_idfavs)
            if current_idfavs then
                f = io.open("/var/mobile/Media/1ferver/res/current_idfavs.txt", "wb")
                f:write(current_idfavs) -- 将现有的 idfav 信息保存到另一个文件
                f:close()
                clear.caches() -- 清理一下系统缓存
                sys.alert("恢复 idfav 信息成功")
            else
                sys.alert("恢复 idfav 信息失败")
            end
        else
            sys.alert("文件打开失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`app.close`](#关闭应用程序\-appclose)、[`app.bundles`](#获取设备所有的应用的\-bundle\-identifier\-列表\-appbundles)



---
<br />
<br />
<br />
<br />

## 应用程序模块（app）
- ### 获取 App 的应用程序包路径 (**app\.bundle\_path**)
    - 声明  
        ```lua
        包路径 = app.bundle_path(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要定位的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 包路径  
            文本型 或 nil，返回的应用程序包路径，如果应用不存在则返回 nil  
    
    - 说明  
        > 获取 App 的应用程序包路径  
        
    - 示例  
        ```lua
        path = app.bundle_path("com.tencent.mqq") -- 获得 QQ 的应用包路径
        ```



---
<br />

- ### 获取 App 的应用存档路径 (**app\.data\_path**)
    - 声明  
        ```lua
        存档路径 = app.data_path(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要定位的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 存档路径  
            文本型 或 nil，返回应用程序的存档路径，如果应用不存在则返回 nil  
    
    - 说明  
        > 获取 App 的应用存档路径  
        
    - 示例  
        ```lua
        path = app.data_path("com.tencent.mqq") -- 获得 QQ 的应用存档路径
        ```



---
<br />

- ### 获取 App 的应用分组信息 (**app\.group\_info**)
    - 声明  
        ```lua
        应用分组信息 = app.group_info(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要定位的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 应用分组信息  
            表型，返回应用程序的分组信息，如果不存在返回空表  
    
    - 说明  
        > **软件版本在 1\.1\.3\-1 或以上方可使用**  
        > 注意：应用程序分组信息 是 iOS 8 开始才有的概念，iOS 7 没有这个概念  
        
    - 示例  
        ```lua
        info = app.group_info("com.tencent.mqq") -- 获得 QQ 的分组信息
        ```



---
<br />

- ### 获取 App 应用插件信息 (app.plugin_info)
    - 声明
        - `plugin_info` = app.plugin_info(`bundle_id`)

    - 参数
        - `bundle_id` : `string`

    - 返回值
        - `plugin_info` : `table`

    - 说明
        > **软件版本在 1.3.8 或以上方可使用**

    - 示例
        ```lua
        nLog(app.plugin_info('com.apple.Preferences'))
        ```



---
<br />

- ### 获取 App 打开的文件 (app.lsof)
    - 声明
        - `ofs`, `error_msg` = app.lsof(`bid_or_pid`)

    - 说明
        - 列出指定 App 打开的文件描述符及 socket 描述符
            > **软件版本在 1.3.8 或以上方可使用**

    - 参数
        - `bid_or_pid` : `string | integer`

    - 返回值
        - `ofs` : `table | nil`  
            成功返回一个特定结构的表，失败返回 nil <details><summary>展开结构</summary>

            ```lua
            {
                opensockets = {
                    {
                        fd = integer_value,
                        kind = "TCP" | "IN",
                        ["local"] = {
                            address = string_value,
                            port = integer_value,
                        },
                        ["remote"] = {
                            address = string_value,
                            port = integer_value,
                        },
                    },
                    ...
                },
                openfiles = {
                    {
                        fd = integer_value,
                        path = string_value,
                    },
                    ...
                },
            }
            ```
            </details>
        - `error_msg` : `string | nil`  
            如果执行失败，则这个返回值为失败文本描述

    - 示例
        ```lua
        nLog(app.lsof('com.apple.Preferences'))
        ```



---
<br />

- ### 设置 App 的 TCC 权限 (app.set_tcc)
    - 声明
        - `success`, `orig_auth_value` = app.set_tcc(`bundle_id`, `service_id`, `auth_value`)

    - 参数
        - `bundle_id` : `string`  
        - `service_id` : `string`  
            <details><summary>TCC 服务 ID 列表</summary>

            ```lua
            kTCCServiceAccessibility
            kTCCServiceAddressBook
            kTCCServiceAppleEvents
            kTCCServiceCalendar
            kTCCServiceCamera
            kTCCServiceContactsFull
            kTCCServiceContactsLimited
            kTCCServiceDeveloperTool
            kTCCServiceFacebook
            kTCCServiceLinkedIn
            kTCCServiceListenEvent
            kTCCServiceLiverpool
            kTCCServiceLocation
            kTCCServiceMediaLibrary
            kTCCServiceMicrophone
            kTCCServiceMotion
            kTCCServicePhotos
            kTCCServicePhotosAdd
            kTCCServicePostEvent
            kTCCServiceReminders
            kTCCServiceScreenCapture
            kTCCServiceShareKit
            kTCCServiceSinaWeibo
            kTCCServiceSiri
            kTCCServiceSpeechRecognition
            kTCCServiceSystemPolicyAllFiles
            kTCCServiceSystemPolicyDesktopFolder
            kTCCServiceSystemPolicyDeveloperFiles
            kTCCServiceSystemPolicyDocumentsFolder
            kTCCServiceSystemPolicyDownloadsFolder
            kTCCServiceSystemPolicyNetworkVolumes
            kTCCServiceSystemPolicyRemovableVolumes
            kTCCServiceSystemPolicySysAdminFiles
            kTCCServiceTencentWeibo
            kTCCServiceTwitter
            kTCCServiceUbiquity
            kTCCServiceWillow
            kTCCServicePasteboard
            ```
            </details>

        - `auth_value` : `integer`  
            设置 `auth_value` 为 `-1` 删除 `bundle_id` 这个应用的 TCC 权限  

    - 返回值
        - `success` : `boolean`  
        - `orig_auth_value` : `integer`  

    - 说明  
        > **软件版本在 1.3.8 或以上方可使用**  

    - 示例
        ```lua
        app.set_tcc("com.apple.SafariViewService", "kTCCServicePasteboard", 2)
        ```


---
<br />

- ### 弹出一个应用通知 (**app\.pop\_banner**)
    - 声明  
        ```lua
        app.pop_banner(应用程序包名, 标题, 内容)
        ```
    
    * 参数  
        > - 应用程序包名  
            文本型，应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 标题  
            文本型，通知的标题  
        > - 内容  
            文本型，通知的内容  
    
    - 说明  
        > **软件版本在 1\.1\.3\-1 或以上方可使用**  
        
    - 示例  
        ```lua
        app.pop_banner('com.tencent.mqq', 'QQ', '[QQ红包]您收到一个假红包')
        ```


---
<br />

- ### 运行应用程序 (**app\.run**)
    - 声明  
        ```lua
        状态 = app.run(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要定位的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 状态  
            整数型，返回运行状态  
            返回 0 表示启动成功  
            返回 其它值 表示启动失败  
        
    - 示例  
        ```lua
        -- 打开内置天气应用，然后退出
        local r = app.run("com.apple.weather") -- 启动应用 包名可在 XXT 应用程序--更多--应用列表 中查看
        sys.msleep(10 * 1000) -- 等 10 秒
        if r == 0 then
            app.close("com.apple.weather") -- 退出应用
        else
            sys.alert("启动失败", 3)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 关闭应用程序 (**app\.close**)
    - 声明  
        ```lua
        app.close(应用程序包名 或 进程号)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要关闭的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 进程号  
            整数型，需要关闭的应用的 process identifier（进程标识符）  
    
    - 说明  
        > 关闭应用程序，参数可以是 应用程序包名 也可以是 进程号，如果应用不在运行则什么都不发生，该操作不会失败  
        > 这个关闭应用是不可拒绝的强杀，目标应用在被关闭的时候不会收到任何通知  
        
    - 示例  
        [`参考 app.run 示例`](#运行应用程序-apprun)
        [`参考 app.bundles 示例`](#获取设备所有的应用的\-bundle\-identifier\-列表\-appbundles)



---
<br />

- ### 模拟使用上划退出应用程序 (**app\.quit**)
    - 声明  
        ```lua
        app.quit(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要退出的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
            传入 ```"*"``` 表示退出所有  
    
    - 说明  
        > 这个当然也是强杀，但是与 [app.close](#关闭应用程序\-appclose) 不同的是，应用在退出前会收到通知；并且它会清除掉多任务切换界面的标签  
        > **请不要在锁屏状态使用，该函数可能不能良好退出 root 权限的 App，使用该函数退出 root 权限程序可能会导致屏幕卡住点图标无响应等现象，root 权限的 App 推荐使用 [app.close](#关闭应用程序\-appclose) 强杀**  
        
    - 示例  
        ```
        -- 退出所有的 App
        app.quit("*")
        
        -- 退出QQ，如果QQ正在运行的话
        app.quit("com.tencent.mqq")
        ```



---
<br />

- ### 检测应用程序是否正在运行 (**app\.is\_running**)
    - 声明  
        ```lua
        状态 = app.is_running(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要定位的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 状态  
            布尔型，是否正在运行  
    
    - 说明  
        > 本函数用于检查一个应用程序是否正在运行，它不区分前后台  
        
        > 如果要判断一个应用是否在前台运行，可以使用 [app.front_bid](#%E8%8E%B7%E5%8F%96%E5%89%8D%E5%8F%B0%E5%BA%94%E7%94%A8%E7%9A%84-bundle-identifier-appfrontbid) 获取前台应用 bid 进行对比，如下  
        ```lua
        if "com.tencent.mqq" == app.front_bid() then
            sys.alert('QQ 正在前台运行')
        end
        ```
        > **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


    - 示例  
        ```lua
        if app.is_running("com.tencent.mqq") then
            sys.alert('QQ 正在运行')
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### ~~输入文字 (**app\.input\_text**)~~
    - 声明  
        ```lua
        app.input_text(文本内容)
        ```
    
    - 参数及返回值  
        > - 文本内容  
            文本型，需要输入的文字，支持退格键 \\b  
    
    - 说明  
        > 在 App 中弹出键盘的情况下输入文字  
        > 已知的无法输入的位置有 AppStore 的评论  
        > 如果遇到无法作用的情况可以参考 [sys.input_text](#输入文字-sysinputtext) 或许能解决  
        > **XXT 1\.3\-1 以上版本已剔除** 
        
    - 示例  
        ```lua
        -- 示例 1：
        app.input_text("嘿嘿嘿") -- 弹出键盘后可以输入文字
        
        -- 示例 2：
        app.input_text("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b") -- 删除文本框原来的内容
        ```



---
<br />

- ### 通过应用程序 bid 获取应用的本地化名字 (**app\.localized_name**)
    - 声明  
        ```lua
        本地化名字 = app.localized_name(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 本地化名字  
            文本型 或 nil，返回应用的本地化名字，如果应用不存在则返回 nil  
        
    - 示例  
        ```lua
        local name = app.localized_name("com.tencent.xin")
        sys.alert(name) -- 弹出显示 “微信”
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 通过应用程序 bid 获取应用的图标数据 (**app\.png\_data\_for\_bid**)
    - 声明  
        ```lua
        PNG图片数据 = app.png_data_for_bid(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - PNG图片数据  
            字符串型 或 nil，应用的图标的 png 数据（二进制数据），如果应用不存在则返回 nil  
        
    - 示例  
        ```lua
        -- 将微信的图标保存到相册
        image.load_data(app.png_data_for_bid("com.tencent.xin")):save_to_album()
        ```
        **注**：上述代码中使用了非本章函数 [`image.load_data`](#从数据创建图片对象\-imageloaddata)、[`:save_to_album`](#保存图片对象到相册\-savetoalbum)



---
<br />

- ### 通过应用程序 bid 获取其 pid (**app\.pid\_for\_bid**)
    - 声明  
        ```lua
        进程号 = app.pid_for_bid(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要检测的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 进程号  
            整数型，如果应用程序正在运行，则返回其 pid，否则返回 0  
        
    - 示例  
        ```lua
        local qqpid = app.pid_for_bid("com.tencent.mqq")
        if qqpid~=0 then
            sys.alert("当前QQ正在运行，进程号是："..qqpid)
        else
            sys.alert("当前QQ没有在运行")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取应用程序当前内存消耗 (**app\.used\_memory**)
    - 声明  
        ```lua
        内存占用 = app.used_memory(应用程序包名 或 进程号)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要检测的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 进程号  
            整数型，需要检测的应用的 process identifier（进程标识符）  
        > - 内存占用  
            实数型 或 nil，如果应用正在运行则返回其所占用的内存（单位 MB），否则返回 nil  
        
    - 示例  
        ```lua
        local qqmem = app.used_memory("com.tencent.mqq")
        sys.alert("当前QQ进程所占用的内存是："..qqmem.."MB")
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取前台应用的 Bundle Identifier (**app\.front\_bid**)
    - 声明  
        ```lua
        应用程序包名 = app.front_bid()
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，返回前台应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
            没有应用处于前台但桌面服务已加载返回 `"com.apple.springboard"`  
            没有应用处于前台且桌面服务尚未启动返回 `"com.apple.backboardd"`  
    
    - 说明  
        > 获取前台应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        
    - 示例  
        ```lua
        local bid = app.front_bid()
        sys.alert("前台应用的应用包名是："..bid)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取前台应用的 Process Identifier (**app\.front\_pid**)
    - 声明  
        ```lua
        进程号 = app.front_pid()
        ```
    
    - 参数及返回值  
        > - 进程号  
            整数型，返回前台应用的 process identifier（进程标识符），前台没有应用返回 0  
    
    - 说明  
        > 获取前台应用的 process identifier（进程标识符）  
        > 前台没有应用返回 0 而不是桌面服务的进程号  
        > 要获取桌面进程 pid 请用  
        ```lua
        local desktop_pid = app.pid_for_bid('com.apple.springboard')
        sys.alert("桌面服务的进程号是："..desktop_pid)
        ```
        
    - 示例  
        ```lua
        local pid = app.front_pid()
        sys.alert("前台应用的进程号是："..pid)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 前台打开一个 URL (**app\.open\_url**)
    - 声明  
        ```lua
        app.open_url(URL)
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，需要打开的 URL ，可以打开 [URL Scheme](https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html)（[“URL Scheme” 的相关应用](#url\-scheme\-的相关应用)）  
    
    - 说明  
        > 前台打开一个 URL，可以打开 [URL Scheme](https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html)（[“URL Scheme” 的相关应用](#url\-scheme\-的相关应用)）  
        > 部分 URL 用该 API 跳转可能不是想要的效果，可试试  
        
        ```lua
        local function sh_escape(path) -- XXTouch 原创函数，未经 XXTouch 许可，可以用于商业用途
        	path = string.gsub(path, "([ \\()<>'\"`#&*;?~$|])", "\\%1")
        	return path
        end
        os.execute('uiopen '..sh_escape('http://www.google.com'))
        os.execute('uiopen '..sh_escape('prefs:root=General&path=ACCESSIBILITY'))
        ```
        
    - 示例  
        ```lua
        app.open_url("http://www.google.com") -- 用 Safari 打开 Google 的主页，当然，不一定打得开
        
        app.open_url("prefs:root=General&path=ACCESSIBILITY") -- 跳转到 设置--通用--辅助功能
        ```



---
<br />

- ### 获取设备所有的应用的 Bundle Identifier 列表 (**app\.bundles**)
    - 声明  
        ```lua
        应用程序包名数组 = app.bundles()
        ```
    
    - 参数及返回值  
        > - 应用程序包名数组  
            顺序表型，返回很多 bid 的一个表，也包括系统自带的  
    
    - 说明  
        > 获取设备所有的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）列表  
        
    - 示例  
        ```lua
        -- 遍历关闭所有的 app
        for _,bid in ipairs(app.bundles()) do
        	app.close(bid)
        end
        ```



---
<br />

- ### 获取当前设备的进程列表 (**app\.all\_procs**)
    - 声明  
        ```lua
        进程信息数组 = app.all_procs()
        ```
    
    - 参数及返回值  
        > - 进程信息数组  
            顺序表型，返回进程列表，结构是这样 \{\{pid = pid1, name = name1\}, \{pid = pid2, name = name2\}, ...\}  
        
    - 示例  
        ```lua
        proc_list = app.all_procs()
        ```



---
<br />

- ### ~~设置前台应用程序加速齿轮 (**app\.set\_speed\_add**)~~
    - 声明  
        ```lua
        app.set_speed_add(需要加的速度 [, 强力模式 ])
        ```
    
    - 参数及返回值  
        > - 需要加的速度  
            实数型，代表加速齿轮倍数，负数为减速，正数为加速，0为不加速也不减速。前台应用重新开启后，加速效果消失  
        > - 强力模式  
            布尔型，可选参数，是否需要支持 unity 引擎加速，默认 false  
    
    - 说明  
        > **强力模式 参数需要软件版本在 1\.1\.2\-2 或以上方可使用**  
        > 设置前台应用程序加速齿轮  
        > 加速并不是对所有的应用都有效果，确切的说，只对小部分游戏有效  
        > **使用该函数可能导致严重后果（包括但不限于应用卡死崩溃、系统崩溃、脚本停止、账号被封、被请喝茶）**  
        > **不得将此函数用于非法用途，使用则代表同意**  
        > **XXT 1\.3\-1 以上版本已剔除** 
        
    - 示例  
        ```lua
        app.set_speed_add(3) -- 给前台 cocos2d 的游戏加速 3 倍
        
        app.set_speed_add(3, true) -- 给前台 unity3d 的游戏加速 3 倍
        ```


---
<br />

- ### 安装IPA安装包 (**app\.install**)
    - 声明  
        ```lua
        安装成败 = app.install(文件路径 [, 强行安装 ])
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，需要安装的 App 安装包（ipa 格式）绝对路径  
        > - 强行安装 \*1\.1\.3\-1 新增  
            布尔型，可选参数，是否强行安装，true 为强行安装，false 为大于当前 ipa 版本不覆盖安装，默认为 false  
        > - 安装成败  
            布尔型，安装成功返回 true，安装失败返回 false  
    
    - 说明  
        > 后台安装一个 ipa 格式的安装包  
        > **安装的完成之前脚本不能被自然终止并会一直阻塞**  
        > 调用此函数前需确保在目标设备中已安装过 [AppSyncUnified.deb](https://cydia.akemi.ai/debs/nodelete-ai.akemi.appsyncunified.deb) 或 [AppSyncUnified-Rootless.deb](https://cydia.akemi.ai/debs/nodelete-rootless-ai.akemi.appsyncunified.deb)  
        
    - 示例  
        ```lua
        app.install("/User/1.ipa", true) -- 强行覆盖安装，用于降级安装 App
        
        if app.install("/User/1.ipa") then
            -- 安装成功
        else
            -- 安装失败
        end
        ```



---
<br />

- ### 卸载一个应用 (**app\.uninstall**)
    - 声明  
        ```lua
        卸载成败 = app.uninstall(应用程序包名)
        ```
    
    - 参数及返回值  
        > - 应用程序包名  
            文本型，需要卸载的应用的 bundle identifier（应用包名，可在 **XXT 应用程序\-\-更多\-\-应用列表** 中查看）  
        > - 卸载成败  
            布尔型，卸载成功返回 true，卸载失败返回 false  
    
    - 说明  
        > 后台卸载一个应用程序  
        > **卸载的过程脚本不能被自然终止并会一直阻塞**  
        
    - 示例  
        ```lua
        if app.uninstall("com.tencent.mqq") then
            -- 卸载成功
        else
            -- 卸载失败
        end
        ```



---
<br />

### **app 模块 额外说明**  
Process Identifier（进程标识符）为应用运行期的进程号，是个整数，每次运行都不一样  



---
<br />
<br />
<br />

## 设备相关模块（device）
- ### 重置自动锁屏倒计时 (**device\.reset_idle**)
    - 声明  
        ```lua
        device.reset_idle()
        ```
    
    - 说明  
        > 重置自动锁屏倒计时（使屏幕常亮）  
        
    - 示例  
        ```lua
        -- 派发一个每 29 秒重置 IDLE 倒计时的任务
        thread.dispatch(function()
            while 1 do
                device.reset_idle()
                sys.msleep(29 * 1000)
            end
        end)
        ```
        **注**：上述代码中使用了非本章函数及方法 [`thread.dispatch`](#派发一个任务-threaddispatch)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)



---
<br />

- ### 锁定屏幕 (**device\.lock_screen**)
    - 声明  
        ```lua
        device.lock_screen()
        ```
        
    - 示例  
        ```lua
        device.lock_screen()
        ```



---
<br />

- ### 解锁屏幕 (**device\.unlock_screen**)
    - 声明  
        ```lua
        device.unlock_screen([ 锁屏密码 ])
        ```
    
    - 参数及返回值  
        > - 锁屏密码  
            文本型，可选参数，锁屏密码，如果有锁屏密码也可以使用这个参数，如果没有则不填即可，不推荐使用  
        
    - 示例  
        ```lua
        device.unlock_screen()
        ```



---
<br />

- ### 获取屏幕锁定状态 (**device\.is_screen_locked**)
    - 声明  
        ```lua
        是否锁屏 = device.is_screen_locked()
        ```
    
    - 参数及返回值  
        > - 是否锁屏  
            布尔型，返回是否已经锁定屏幕  
    
    - 说明  
        > 判断是否已经锁定屏幕  
        
    - 示例  
        ```lua
        if device.is_screen_locked() then
            -- 屏幕已锁定
        else
            -- 屏幕是解锁状态
        end
        ```



---
<br />

- ### 获取前台应用的画面方向 (**device\.front\_orien**)
    - 声明  
        ```lua
        旋转状态 = device.front_orien()
        ```
    
    - 参数及返回值  
        > - 旋转状态  
            * 整数型，相对于画面  
                返回 0 表示 home 在下  
                返回 1 表示 home 在右  
                返回 2 表示 home 在左  
                返回 3 表示 home 在上  
                返回 4 表示 出错了  
        
    - 示例  
        ```lua
        sys.toast('这个提示会以前台应用的旋转方向显示', device.front_orien())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)



---
<br />

- ### 锁定设备屏幕旋转 (**device\.lock\_orien**)
    - 声明  
        ```lua
        device.lock_orien()
        ```
        
    - 示例  
        ```lua
        device.lock_orien()
        ```



---
<br />

- ### 解锁设备屏幕旋转锁 (**device\.unlock\_orien**)
    - 声明  
        ```lua
        device.unlock_orien()
        ```
        
    - 示例  
        ```lua
        device.unlock_orien()
        ```



---
<br />

- ### 获取屏幕旋转锁锁定状态 (**device\.is\_orien\_locked**)
    - 声明  
        ```lua
        是否锁定 = device.is_orien_locked()
        ```
    
    - 参数及返回值  
        > - 是否锁定  
            布尔型，返回是否已经锁定屏幕旋转锁  
        
    - 示例  
        ```lua
        if device.is_orien_locked() then
            -- 屏幕旋转已锁定
        else
            -- 屏幕旋转没锁定
        end
        ```



---
<br />

- ### 振动设备 (**device\.vibrator**)
    - 声明  
        ```lua
        device.vibrator()
        ```
    
    - 说明  
        > 振我一下（没有振动马达的设备不能振）  
        
    - 示例  
        ```lua
        device.vibrator()
        ```



---
<br />

- ### 后台播放声音 (**device\.play\_sound**)
    - 声明  
        ```lua
        device.play_sound(声音文件路径)
        ```
    
    - 参数及返回值  
        > - 声音文件路径  
            文本型，声音文件的绝对路径，支持 mp3、wav、aac 音频格式  
    
    - 说明  
        > 后台播放一段声音  
        > 该函数不会影响脚本运行，且播放的声音会在脚本停止的时候停止，如果脚本需要播放完整声音，请做好延迟退出  
        
    - 示例  
        ```lua
        device.play_sound("/User/十年.mp3")
        sys.msleep(205 * 1000) -- 等待 205 秒（3分25秒）
        ```
        **注**：上述代码中使用了非本章函数 [`sys.msleep`](#毫秒级延迟\-sysmsleep)



---
<br />

- ### 获取设备类型 (**device\.type**)
    - 声明  
        ```lua
        设备类型 = device.type()
        ```
    
    - 参数及返回值  
        > - 设备类型  
            文本型，返回设备类型，大约是 `"iPhone3,1"` 这种形式的字符串  
    
    - 说明  
        > 获取设备类型  
        
    - 示例  
        ```lua
        if device.type() == "iPhone3,1" then
            -- 是 iPhone 4
        end
        ```



---
<br />

- ### 获取设备名 (**device\.name**)
    - 声明  
        ```lua
        设备名 = device.name()
        ```
    
    - 参数及返回值  
        > - 设备名  
            文本型，返回用户给设备取的名字  
        
    - 示例  
        ```lua
        sys.alert("设备的名字是："..device.name())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 设置设备名 (**device\.set\_name**)
    - 声明  
        ```lua
        device.set_name(名字)
        ```
    
    - 参数及返回值  
        > - 名字  
            文本型，需要设置的设备名字  
        
    - 示例  
        ```lua
        device.set_name("iPhavonz")
        ```



---
<br />

- ### 获取设备UDID (**device\.udid**)
    - 声明  
        ```lua
        udid = device.udid()
        ```
    
    - 参数及返回值  
        > - udid  
            文本型，返回设备的 UDID  
    
    - 说明  
        > UDID 参考资料：https://www.theiphonewiki.com/wiki/UDID  
        
    - 示例  
        ```lua
        sys.alert("设备的 UDID 是："..device.udid())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取设备的序列号 (**device\.serial\_number**)
    - 声明  
        ```lua
        序列号 = device.serial_number()
        ```
    
    - 参数及返回值  
        > - 序列号  
            文本型，返回设备的序列号  
        
    - 示例  
        ```lua
        sys.alert("设备的序列号是："..device.serial_number())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取设备的 WiFi MAC 地址 (**device\.wifi\_mac**)
    - 声明  
        ```lua
        歪坏麦克 = device.wifi_mac()
        ```
    
    - 参数及返回值  
        > - 歪坏麦克  
            文本型，返回设备的 WiFi MAC 地址  
        
    - 示例  
        ```lua
        sys.alert("设备的 WiFi MAC 地址是："..device.wifi_mac())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取设备所有的接口 IP (**device\.ifaddrs**)
    - 声明  
        ```lua
        接口信息数组 = device.ifaddrs()
        ```
    
    - 参数及返回值  
        > - 接口信息数组  
            表型，返回设备的所有接口的信息结构如下  
            \{\{"ifname1", "ip1"\}, \{"ifname2", "ip2"\}, \.\.\.\}  
    
    - 说明  
        > 获取设备所有的接口 IP  
        
    - 示例  
        ```lua
        -- 获取设备的 WiFi IP
        local ip = "没开 WiFi"
        for i,v in ipairs(device.ifaddrs()) do
        	if (v[1]=="en0") then
        		ip = v[2]
        	end
        end
        sys.alert(ip)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取当前设备电池剩余电量 (**device\.battery\_level**)
    - 声明  
        ```lua
        电量 = device.battery_level()
        ```
    
    - 参数及返回值
        > - 电量
            实数型，当前设备电池剩余电量，范围 0\.0~1\.0
        
    - 示例  
        ```lua
        sys.alert("当前设备电池剩余电量："..(device.battery_level() * 100).."%")
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取当前设备充电状态 (**device\.battery\_state**)
    - 声明  
        ```lua
        充电状态 = device.battery_state()
        ```
    
    - 参数及返回值  
        > - 充电状态  
            文本型，充电状态，有这么几种状态  
            返回 "Full" 表示连接了电源并已经充满  
            返回 "Charging" 表示连接了电源并正在充电中  
            返回 "Unplugged" 表示没有接电源  
            返回 "Unknown" 表示未知状态  
        
    - 示例  
        ```lua
        状态表 = {
        	Full = "连接并已充满",
        	Charging = "连接并在充电",
        	Unplugged = "没插电源",
        	Unknown = "未知状态",
        }
        
        sys.alert("当前设备电池充电状态："..状态表[device.battery_state()])
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 打开设备 WiFi (**device\.turn\_on\_wifi**)
    - 声明  
        ```lua
        device.turn_on_wifi()
        ```
        
    - 示例  
        ```lua
        device.turn_on_wifi()
        ```



---
<br />

- ### 关闭设备 WiFi (**device\.turn\_off\_wifi**)
    - 声明  
        ```lua
        device.turn_off_wifi()
        ```
        
    - 示例  
        ```lua
        device.turn_off_wifi()
        ```



---
<br />

- ### 打开设备蜂窝数据 (**device\.turn\_on\_data**)
    - 声明  
        ```lua
        device.turn_on_data()
        ```
        
    - 示例  
        ```lua
        device.turn_on_data()
        ```



---
<br />

- ### 关闭设备蜂窝数据 (**device\.turn\_off\_data**)
    - 声明  
        ```lua
        device.turn_off_data()
        ```
        
    - 示例  
        ```lua
        device.turn_off_data()
        ```



---
<br />

- ### 打开设备蓝牙 (**device\.turn\_on\_bluetooth**)
    - 声明  
        ```lua
        device.turn_on_bluetooth()
        ```
        
    - 示例  
        ```lua
        device.turn_on_bluetooth()
        ```



---
<br />

- ### 关闭设备蓝牙 (**device\.turn\_off\_bluetooth**)
    - 声明  
        ```lua
        device.turn_off_bluetooth()
        ```
        
    - 示例  
        ```lua
        device.turn_off_bluetooth()
        ```



---
<br />

- ### 打开设备飞行模式 (**device\.turn\_on\_airplane**)
    - 声明  
        ```lua
        device.turn_on_airplane()
        ```
    
    - 说明  
        > 打开设备飞行模式（断网哦）  
        
    - 示例  
        ```lua
        device.turn_on_airplane()
        ```



---
<br />

- ### 关闭设备飞行模式 (**device\.turn\_off\_airplane**)
    - 声明  
        ```lua
        device.turn_off_airplane()
        ```
    
    - 说明  
        > 关闭设备飞行模式（不是关网，是开网）  
        
    - 示例  
        ```lua
        device.turn_off_airplane()
        ```



---
<br />

- ### 连接到当前设置所选 VPN (**device\.turn\_on\_vpn**)
    - 声明  
        ```lua
        device.turn_on_vpn()
        ```
    
    - 说明  
        > 尝试连接到所选 VPN，如果没选，则什么也不发生  
        > **注**：该函数稳定性有限，在 iOS7 上碰到 VPN 没有设置密码的情况下调用会导致进入安全模式，**推荐**使用更加稳定的解决方案 [VPN 配置模块（vpnconf）](#vpn-%E9%85%8D%E7%BD%AE%E6%A8%A1%E5%9D%97vpnconf)  
        
    - 示例  
        ```lua
        device.turn_on_vpn()
        ```



---
<br />

- ### 断开已有的 VPN 连接 (**device\.turn\_off\_vpn**)
    - 声明  
        ```lua
        device.turn_off_vpn()
        ```
    
    - 说明  
        > 断开已经连上的 VPN 连接，如果当前没有尝试连接或已经连接的 VPN 则什么也不发生  
        > **注**：该函数稳定性有限，有可能调用无效，**推荐**使用更加稳定的解决方案 [VPN 配置模块（vpnconf）](#vpn-%E9%85%8D%E7%BD%AE%E6%A8%A1%E5%9D%97vpnconf)  
        
    - 示例  
        ```lua
        device.turn_off_vpn()
        ```



---
<br />

- ### 判断当前是否打开了 VPN 开关 (**device\.is\_vpn\_on**)
    - 声明  
        ```lua
        开关状态, 状态描述 = device.is_vpn_on()
        ```
    
    - 参数及返回值  
        > - 开关状态  
            布尔型，VPN 开关为打开（正在连接或已经连接成功）状态则返回 true，否则返回 false  
        > - 状态描述  
            文本型 或 nil，当第一个返回值为 true 的时候，这个返回值返回一个用于描述 VPN 连接状态的字符串  
    
    - 说明  
        > - **注意**：  
            当 VPN 正在连接（还没有连接成功）的时候，开关状态 会返回 true。  
            状态描述 在不同的语言环境或系统版本中返回的同一状态描述不保证相同。  
        > 更多 VPN 相关功能尽在 [VPN 配置模块（vpnconf）](#vpn-%E9%85%8D%E7%BD%AE%E6%A8%A1%E5%9D%97vpnconf)  
        
    - 示例  
        ```lua
        while (true) do
        	local is_on, stat = device.is_vpn_on()
        	if (is_on) then
        		sys.toast(stat)
        	else
        		device.turn_on_vpn()
        	end
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)



---
<br />

- ### 打开设备闪光灯 (**device\.flash\_on**)
    - 声明  
        ```lua
        是否成功 = device.flash_on()
        ```
    
    - 参数及返回值  
        > - 是否成功  
            布尔型，设备可以打开相机并且有闪光灯硬件返回 true，否则返回 false  
    
    - 说明  
        > **iPad Pro 的闪光灯无法开启**  
        > 打开设备闪光灯，脚本终止的时候，由脚本启动的闪光灯会自动关闭  
        
    - 示例  
        ```lua
        device.flash_on()
        ```



---
<br />

- ### 关闭设备闪光灯 (**device\.flash\_off**)
    - 声明  
        ```lua
        是否成功 = device.flash_off()
        ```
    
    - 参数及返回值  
        > - 是否成功  
            设备可以打开相机并且有闪光灯硬件返回 true，否则返回 false  
    
    - 说明  
        > **iPad Pro 的闪光灯无法开启**  
        > 如果闪光灯是开启状态，那么该函数会关闭闪光灯，否则什么都不发生  
        
    - 示例  
        ```lua
        if device.flash_off() then
            -- 设备有闪光灯
        else
            -- 设备没闪光灯
        end
        ```



---
<br />

- ### 打开“减少动态效果”开关 (**device\.reduce\_motion\_on**)
    - 声明  
        ```lua
        device.reduce_motion_on()
        ```
    
    - 说明  
        > 减少动态效果的开关在设备上的 设置\-\-通用\-\-辅助功能\-\-减少动态效果  
        
    - 示例  
        ```lua
        device.reduce_motion_on()
        ```



---
<br />

- ### 关闭“减少动态效果”开关 (**device\.reduce\_motion\_off**)
    - 声明  
        ```lua
        device.reduce_motion_off()
        ```
    
    - 说明  
        > 减少动态效果的开关在设备上的 设置\-\-通用\-\-辅助功能\-\-减少动态效果  
        
    - 示例  
        ```lua
        device.reduce_motion_off()
        ```



---
<br />

- ### 打开 AssistiveTouch (**device\.assistive\_touch\_on**)
    - 声明  
        ```lua
        device.assistive_touch_on()
        ```
    
    - 说明  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > AssistiveTouch 开关在设备上的 设置\-\-通用\-\-辅助功能\-\-AssistiveTouch  
        
    - 示例  
        ```lua
        device.assistive_touch_on()
        ```



---
<br />

- ### 关闭 AssistiveTouch (**device\.assistive\_touch\_off**)
    - 声明  
        ```lua
        device.assistive_touch_off()
        ```
    
    - 说明  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > AssistiveTouch 的开关在设备上的 设置\-\-通用\-\-辅助功能\-\-AssistiveTouch  
        
    - 示例  
        ```lua
        device.assistive_touch_off()
        ```



---
<br />

- ### 获取背光亮度值 (**device\.brightness**)
    - 声明  
        ```lua
        亮度 = device.brightness()
        ```
    
    - 参数及返回值  
        > - 亮度  
            实数型，返回当前设备的背光亮度，范围 0\.0~1\.0  
        
    - 示例  
        [`device.set_brightness 示例`](#设置背光亮度-devicesetbrightness)



---
<br />

- ### 设置背光亮度 (**device\.set\_brightness**)
    - 声明  
        ```lua
        device.set_brightness(亮度)
        ```
    
    - 参数及返回值  
        > - 亮度  
            实数型，用于设置设备的背光亮度，范围 0\.0~1\.0  
    
    - 说明  
        > 该函数调用会关闭设备的自动调整背光功能  
        
    - 示例  
        ```lua
        sys.toast(device.brightness())
        for i = 1, 10 do
        	device.set_brightness(i/10)
        	sys.msleep(200)
        end
        for i = 10, 5, -1 do
        	device.set_brightness(i/10)
        	sys.msleep(200)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-msleep)



---
<br />

- ### 设置自动锁屏分钟数 (**device\.set\_autolock\_time**)
    - 声明  
        ```lua
        device.set_autolock_time(分钟数)
        ```
    
    - 参数及返回值  
        > - 分钟数  
            整数型，用于设置设备自动锁屏分钟数，设置为 0 则永不锁屏  
    
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        只能设置为设备有的分钟等级  
        
    - 示例  
        ```lua
        device.set_autolock_time(0)
        ```



---
<br />

- ### 设置设备音量 (**device\.set\_volume**)
    - 声明  
        ```lua
        device.set_volume(音量)
        ```
    
    - 参数及返回值  
        > - 音量  
            实数型，用于设置设备的音量，范围 0\.0~1\.0  
        
    - 示例  
        ```lua
        device.set_volume(0) -- 设备静音
        ```



---
<br />

- ### 加入到一个无线局域网 (**device\.join\_wifi**)
    - 声明  
        ```lua
        device.join_wifi(SSID, 密码, 加密类型)
        ```
    
    - 参数及返回值  
        > - SSID  
            文本型，无线局域网的 SSID，也就是名字  
        > - 密码  
            文本型，无线局域网的密码  
        > - 加密类型  
            整数型，加密类型，可以是  
                `0` \- 不加密网络  
                `1` \- 有密码网络  
    
    - 说明  
        > **这个函数在 1\.2\-1 版以上方可使用**  
        > **这个函数不支持 iOS 10 及以上版本操作系统**  
        **注意**：加入无线局域网可能会需要较长时间，也可能加入失败，请自行写代码延迟并判断  
        
    - 示例  
        ```lua
        device.join_wifi('Tenda_9B3F', '123456', 1)
        ```



---
<br />

- ### 获取当前 Wi-Fi 的信息 (device.wifi_info)
    - 声明
        - `wifi_info` = device.wifi_info()

    - 返回值
        - `wifi_info` : `table | nil`  
            <details><summary>展开结构</summary>

            ```lua
            {
                SSID = string_value,
                BSSID = string_value,
                hidden = boolean_value,
                encryption = string_value,
                password = string_value,
                channel = integer_value,
            }
            ```
            </details>

    - 说明
        > **软件版本在 1.3.8 或以上方可使用**

    - 示例
        ```lua
        nLog(device.wifi_info())
        ```


---
<br />
<br />
<br />

## 图片对象模块（image）
- ### 判断一个值是否是图片对象 (**image\.is**)
    - 声明  
        ```lua
        是否图片 = image.is(需要判断的值)
        ```
    
    - 参数及返回值  
        > - 需要判断的值  
            值，需要判断是否是图片对象的值  
        > - 是否图片  
            布尔型，值是图片对象返回 true，否则返回 false  
    
    - 说明  
        > 判断一个值是否是图片对象  
        
    - 示例  
        ```lua
        if image.is(img) then
            -- img 是个图片对象
        else
            -- img 不是图片对象
        end
        ```



---
<br />

- ### 创建指定尺寸空白图片对象 (**image\.new**)
    - 声明  
        ```lua
        图像 = image.new(宽, 高)
        ```
    
    - 参数及返回值  
        > - 宽, 高  
            整数型，新建的图片对象的宽, 高  
        > - 图像  
            图片对象，返回新建的图片对象  
    
    - 说明  
        > 创建空白图片对象，默认这图像上所有的点的颜色皆为0x000000（黑）  
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        ```lua
        
        ```



---
<br />

- ### 图像合并 (**image\.oper\_merge**)
    - 声明  
        ```lua
        操作成败 = image.oper_merge(图片文件名数组, 输出路径, 合并类型, 生成质量)
        ```
    
    - 参数及返回值  
        > - 图片文件名数组  
            表型，需合并图片的文件名列表，支持使用绝对路径  
        > - 输出路径  
            文本型，生成新图片的文件名，支持使用绝对路径  
        > - 合并类型  
            整数型，合并类型，0 \- 横向合并；1 \- 竖向合并  
        > - 生成质量  
            实数型，当生成图片格式为 jpg 时，可控制图片质量，范围 0\.0 ~ 1\.0  
        > - 操作成败  
            整数型，0 \- 成功；1 \- 失败；2 \- 失败；3 \- 失败  
    
    - 说明  
        > 默认图片路径为 /var/mobile/Media/1ferver/img，自建目录请填写相对路径  
        
    - 示例  
        ```lua
        image.oper_merge({"1.png","2.png","3.png"}, "4.jpg", 0, 0.5)
        ```



---
<br />

- ### 新建一个文本图片对象 (**image\.new\_text\_image**)
    - 声明  
        ```lua
        图像 = image.new_text_image(文本[, {
           font = 字体,
           size = 字体大小,
           color = 字体颜色,
           alpha = 字体不透明度,
           back_color = 背景色,
           back_alpha = 背景不透明度,
        }])
        ```
    
    - 参数及返回值  
        > - 文本  
            文本型，需要绘制的文本内容  
        > - 字体  
            文本型，可选参数，需要绘制的文本的字体，默认 "Arial"  
        > - 字体大小  
            实数型，可选参数，需要绘制的文本的字体大小，默认 20\.0  
        > - 字体颜色  
            整数型，可选参数，需要绘制的文本的字体颜色，默认 0xffffff（白）  
        > - 字体不透明度  
            整数型，可选参数，需要绘制的文本的字体不透明度，范围 0~255，默认 255  
        > - 背景色  
            整数型，可选参数，图片背景色，默认 0x000000（黑）  
        > - 背景不透明度  
            整数型，可选参数，图片背景不透明度，范围 0~255，默认 255  
        > - 图像  
            图片对象，返回新建的图片对象  
    
    - 说明  
        > 新建一个适合尺寸的图片对象，并将文本绘制于上  
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        ```lua
        
        ```



---
<br />

- ### 从文件创建图片对象 (**image\.load_file**)
    - 声明  
        ```lua
        图像 = image.load_file(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，图片文件绝对路径  
        > - 图像  
            图片对象 或 nil，返回新建的图片对象，如果文件不存在则返回 nil  
    
    - 说明  
        > 从文件创建图片对象
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        [`将文件转存到相册`](#保存图片对象到相册-savetoalbum)



---
<br />

- ### 从数据创建图片对象 (**image\.load_data**)
    - 声明  
        ```lua
        图像 = image.load_data(图像数据)
        ```
    
    - 参数及返回值  
        > - 图像数据  
            字符串型，png 或 jpeg 格式的图片数据  
        > - 图像  
            图片对象 或 nil，返回新建的图片对象，如果数据不是图像格式则返回 nil  
    
    - 说明  
        > 从数据创建图片对象
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        [`从网上下载个小图片直接转存到相册`](#保存图片对象到相册-savetoalbum)



---
<br />

- ### 从图片对象创建拷贝图片对象 (**:copy**)
    - 声明  
        ```lua
        图像2 = 图像1:copy()
        ```
    
    - 参数及返回值  
        > - 图像1  
            图片对象，原始图片对象  
        > - 图像2  
            图片对象，返回新建的图片对象  
    
    - 说明  
        > 从图片对象创建拷贝图片对象  
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        ```lua
        scrn = screen.image()
        img2 = scrn:copy()
        ```
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)



---
<br />

- ### 从图片对象截取部分新建拷贝图片对象 (**:crop**)
    - 声明  
        ```lua
        图像2 = 图像1:crop([左, 上, 右, 下])
        ```
    
    - 参数及返回值  
        > - 图像1  
            图片对象，原始图片对象  
        > - 左, 上, 右, 下  
            整数型，可选参数，原始图像中的区域左上右下坐标，默认 0, 0, 原图宽\-1, 原图高\-1  
        > - 图像2  
            图片对象，返回新建的图片对象  
    
    - 说明  
        > 从图片对象截取部分新建拷贝图片对象  
        > 该方法会产出一个新的图片对象，如需保证高效频繁使用请搭配 [image:destroy](#销毁一个图片对象\-destroy) 方法使用  
        
    - 示例  
        ```lua
        scrn = screen.image()
        img2 = scrn:crop(100, 100, 200, 200)
        ```
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)



---
<br />

- ### 保存图片对象到相册 (**:save\_to\_album**)
    - 声明  
        ```lua
        图像:save_to_album()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，需要保存到相册的图片对象  
    
    - 说明  
        > 导出图片对象的图片到系统相册  
        
    - 示例  
        ```lua
        -- 从网上下载个小图片直接转存到相册
        local c, h, r = http.get("https://www.xxtouch.com/img/Logo.png", 10)
        if (c == 200) then
            local img = image.load_data(r)
        	img:save_to_album()
        	sys.alert("图片已存到相册")
        else
        	sys.alert("下载失败")
        end
        ```
        
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`http.get`](#发起-get-请求-httpget)
        
        ```lua
        -- 截全屏图像保存到相册
        screen.image():save_to_album()
        ```
        
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)
        
        ```lua
        -- 将文件转存到相册（这只是例子，文件不存在会报错，请在保存之前先做判断）
        image.load_file("/var/mobile/1.png"):save_to_album()
        ```
        
        ```lua
        -- 将文件转存到相册
        img = image.load_file("/var/mobile/1.png")
        if image.is(img) then
            img:save_to_album()
        end
        ```


---
<br />

- ### 输出图片对象到一个 PNG 格式的文件 (**:save\_to\_png\_file**)
    - 声明  
        ```lua
        图像:save_to_png_file(文件路径)
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，需要保存到文件的图片对象  
        > - 文件路径  
            文本型，需要保存到图片文件的绝对路径  
    
    - 说明  
        > 输出图片对象到一个 PNG 格式的文件，扩展名可以不是 PNG  
        
    - 示例  
        
        ```lua
        -- 截全屏图像保存到文件
        screen.image():save_to_png_file("/var/mobile/1.png")
        ```
        
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)



---
<br />

- ### 输出图片对象到一个 JPEG 格式的文件 (**:save\_to\_jpeg\_file**)
    - 声明  
        ```lua
        图像:save_to_jpeg_file(文件路径 [, 图像质量 ])
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，需要保存到文件的图片对象  
        > - 文件路径  
            文本型，需要保存到图片文件的绝对路径  
        > - 图像质量  
            实数型，可选参数，图片质量，取值范围 0\.0~1\.0，默认 1\.0  
    
    - 说明  
        > 输出图片对象到一个 JPEG 格式的文件，扩展名可以不是 JPG  
        
    - 示例  
        
        ```lua
        -- 截全屏图像保存到文件
        screen.image():save_to_jpeg_file("/var/mobile/1.jpg")
        ```
        
        ```lua
        -- 截全屏图像保存到文件并设置图片为低质量
        screen.image():save_to_jpeg_file("/var/mobile/1.jpg", 0.4)
        ```
        
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)



---
<br />

- ### 获取图片对象的 PNG 格式数据 (**:png\_data**)
    - 声明  
        ```lua
        图像PNG数据 = 图像:png_data()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 图像PNG数据  
            字符串型，返回 PNG 数据，对这份数据的修改不会影响图片对象  
    
    - 说明  
        > 获取图片对象的 PNG 格式数据  
        > 性能上，该函数操作过程产生两次数据拷贝  
        
    - 示例  
        ```lua
        file.writes('/var/mobile/1.png', screen.image():png_data())
        ```
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)、[`file.writes`](#将数据覆盖写入到文件-filewrites)



---
<br />

- ### 获取图片对象的 JPEG 格式数据 (**:jpeg\_data**)
    - 声明  
        ```lua
        图像JPG数据 = img:jpeg_data([ 图像质量 ])
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 图像质量  
            实数型，可选参数，图片质量，取值范围 0\.0~1\.0，默认 1\.0  
        > - 图像JPG数据  
            字符串型，返回 JPEG 数据，对这份数据的修改不会影响图片对象  
    
    - 说明  
        > 获取图片对象的 JPEG 格式数据  
        > 性能上，该函数操作过程产生两次数据拷贝  
        
    - 示例  
        ```lua
        file.writes('/var/mobile/1.jpg', screen.image():jpeg_data(0.8))
        ```
        **注**：上述代码中使用了非本章函数 [`screen.image`](#获取屏幕图像-screenimage)、[`file.writes`](#将数据覆盖写入到文件-filewrites)



---
<br />

- ### 90度左旋图片对象 (**:turn\_left**)
    - 声明  
        ```lua
        图像 = 图像:turn_left()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
    
    - 说明  
        > 90 度左旋图片对象  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 90度右旋图片对象 (**:turn\_right**)
    - 声明  
        ```lua
        图像 = 图像:turn_right()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
    
    - 说明  
        > 90 度右旋图片对象  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 180度旋转图片对象 (**:turn\_upondown**)
    - 声明  
        ```lua
        图像 = 图像:turn_upondown()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
    
    - 说明  
        > 180 度旋转图片对象  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 获取图片对象的尺寸 (**:size**)
    - 声明  
        ```lua
        宽, 高 = 图像:size()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 宽, 高  
            整数型，当前操作的图片对象的 宽、高  
    
    - 说明  
        > 获取图片对象的尺寸，注意这里返回的 w 不一定比 h 短，旋转会发生改变  
        
    - 示例  
        ```lua
        local img = image.load_file("/var/mobile/1.png")
        local w, h = img:size()
        sys.alert("图像的宽："..w.."\n图像的高："..h)
        ```



---
<br />

- ### 获取图片对象某点颜色 (**:get\_color**)
    - 声明  
        ```lua
        颜色 = 图像:get_color(横坐标, 纵坐标)
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 横坐标, 纵坐标  
            整数型，需要获取颜色的点于当前图片对象上的坐标  
        > - 颜色  
            整数型，返回当前图片对象上的这个坐标的颜色值  
    
    - 说明  
        > 获取图片对象某点颜色  
        
    - 示例  
        ```lua
        local img = image.load_file("/var/mobile/1.png")
        local clr = img:get_color(100, 100)
        sys.alert(string.format("图像上坐标 (100, 100) 的颜色为：0x%06x", clr))
        ```



---
<br />

- ### 设置图片对象某点颜色 (**:set\_color**)
    - 声明  
        ```lua
        图像 = 图像:set_color(横坐标, 纵坐标, 颜色)
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 横坐标, 纵坐标  
            整数型，需要设置颜色的点于当前图片对象上的坐标  
        > - 颜色  
            整数型，需要设置的颜色值  
    
    - 说明  
        > 设置图片对象某点颜色  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 颜色替换 (**:replace\_color**)
    - 声明  
        ```lua
        图像 = 图像:replace_color(原色, 替换色[, 原色相似度])
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 原色  
            整数型，原来的颜色  
        > - 替换色  
            整数型，需要变成的颜色  
        > - 原色相似度  
            整数型，可选参数，颜色相似度，范围 0~100，默认 100  
    
    - 说明  
        > 将图片对象上某种颜色（或及近似色）替换为另外的颜色  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        [`二维码背景色替换`](#将文本编码成二维码图片-utilsqrencode)



---
<br />

- ### 图中贴图 (**:draw\_image**)
    - 声明  
        ```lua
        大图像 = 大图像:draw_image(小图像[, {
           left = 左上的 x 坐标,
           top = 左上的 y 坐标,
           alpha = 不透明度,
           background = {
              {颜色*, 色偏*},
              {颜色*, 色偏*},
              ...
           },
        }])
        ```
    
    - 参数及返回值  
        > - 大图像  
            图片对象，当前操作的图片对象  
        > - 小图像  
            图片对象，需要绘制到 大图像 上的图像  
        > - 左上的 x 坐标  
            整数型，可选参数，需要将 小图像 绘制到 大图像 的左上角的 x 坐标，默认 0  
        > - 左上的 y 坐标  
            整数型，可选参数，需要将 小图像 绘制到 大图像 的左上角的 y 坐标，默认 0  
        > - 不透明度  
            整数型，可选参数，小图像 的不透明度，范围 0~255，默认 255  
        > - 颜色\*, 色偏\*  
            顺序表型，可选参数，小图像 上的与 颜色\* 色差在 色偏\* 范围内的颜色将不会绘制到 大图像 上，默认 不忽略任何颜色  
    
    - 说明  
        > 在图像上绘制另外一个图像  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 二值化处理图片对象 (**:binaryzation**)
    - 声明  
        ```lua
        图像 = 图像:binaryzation({
           {颜色*, 色偏*},
           {颜色*, 色偏*},
           ...
        })
        ```
        
        ```lua
        图像 = 图像:binaryzation("cx*-cox*,cx*-cox*...")
        ```
    
    - 参数及返回值
        > - 图像
            图片对象，当前操作的图片对象  
        > - 颜色\*, 色偏\*  
            整数型，颜色值白名单，颜色\* 是颜色值本身，色偏\* 是 颜色\* 的最大色差值  
        > - cx\*\-cox\*  
            文本型，颜色值白名单，cx\* 是颜色值本身的16进制文本描述，cox\* 是 cx\* 的最大色差值16进制文本描述  
    
    - 说明  
        > 二值化处理图片对象  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        -- 示例 1：
        local pic = screen.image(462, 242, 569, 272)
    	pic = pic:binaryzation({
    		{0x9D5D39, 0x0F1F26},
    		{0xD3D3D2, 0x2C2C2D},
    	})
    	
    	-- 示例 2：
    	local pic = screen.image(462, 242, 569, 272)
    	pic = pic:binaryzation("9D5D39-0F1F26,D3D3D2-2C2C2D")
        ```



---
<br />

- ### 在图上找色 (**:find\_color**)
    - 声明  
        ```lua
        横坐标, 纵坐标 = 图像:find_color(...)
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > 详细用法参考 [screen.find_color](#单点相似度模式找色\-screenfindcolor)  
    
    - 说明  
        > 在图上找色  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 图片多点颜色匹配 (**:is\_colors**)
    - 声明  
        ```lua
        是否完全匹配 = 图像:is_colors(...)
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > 详细用法参考 [screen.is_colors](#屏幕多点颜色匹配\-screeniscolors)  
    
    - 说明  
        > 图片多点颜色匹配  
        
    - 示例  
        ```lua
        -- 没有
        ```



---
<br />

- ### 解码一个二维码图片 (**:qr\_decode**)
    - 声明  
        ```lua
        识别文本 = 图像:qr_decode()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 识别文本  
            文本型 或 nil，返回当前二维码解码之后的文字，如果不是二维码或不能解码则返回 nil  
    
    - 说明  
        > 解码一个包含二维码图片，不一定需要纯二维码图像，有杂物可能也能正确识别  
        
    - 示例  
        ```lua
        -- 解码一个本地二维码图片文件
        local img = image.load_file("/User/qr.png")
        if img then
            local str = img:qr_decode()
            img:destroy()
            if str then
                sys.alert("识别成功\n识别结果是："..str)
            else
                sys.alert("识别失败")
            end
        else
            sys.alert("图片文件加载失败，文件或许不存在")
        end
        ```
        
        ```lua
        -- 解码当前屏幕上显示的二维码
        local str = screen.image():qr_decode()
        if str then
            sys.alert("识别成功\n识别结果是："..str)
        else
            sys.alert("识别失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 销毁一个图片对象 (**:destroy**)
    - 声明  
        ```lua
        图像:destroy()
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
    
    - 说明  
        > 立即释放图片对象的内存占用，被销毁的图片对象不能再使用  
        > 该方法属性能优化方法，在频繁创建新图片对象的情形下，建议一定要使用该方法释放掉不再使用的图片对象以防止内存占用过高导致设备卡死崩溃等问题  
        > 不是频繁创建图片对象的情况下可以不使用当前方法，并不会有内存泄露，lua  自带的垃圾回收机制会延迟一段时间将不再使用的数据回收  
        
    - 示例  
        ```lua
        sys.alert("点击确定1秒后开始监控屏幕状态")

        sys.msleep(1000)
        
        local img = screen.image()
        while 1 do
            local scn = screen.image()
            local x, y, s = scn:cv_find_image(img)
            scn:destroy()
            if s < 95 then
                break
            end
            sys.msleep(10)
        end
        
        sys.alert("屏幕动了")
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`sys.msleep`](#毫秒级延迟\-msleep)



---
<br />

- ### cv \- 图中找图 (**:cv\_find\_image**)
    - 声明  
        ```lua
        require("image.cv") -- 需要提前加载

        横坐标, 纵坐标, 相似度 = 大图像:cv_find_image(小图像)
        ```
    
    - 参数及返回值  
        > - 大图像  
            图片对象，当前操作的图片对象  
        > - 小图像  
            图片对象，需要找的小图  
        > - 横坐标, 纵坐标  
            整数型，找到的小图在大图上的最匹配的位置的左上角坐标  
        > - 相似度  
            实数型，返回找到的小图在大图上的最匹配的位置的相似度，范围 0~100  
    
    - 说明  
        > opencv 扩展功能，在一个图片对象中找另外一个图片对象位置  
        
    - 示例  
        ```lua
        
        ```



---
<br />

- ### cv \- 图片自动二值化 (**:cv\_binaryzation**)
    - 声明  
        ```lua
        require("image.cv") -- 需要提前加载

        图像 = 图像:cv_binaryzation([ 二值化阈值 ])
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 二值化阈值  
            实数型，可选参数，阈值，范围 0~255，默认选理论上最合适的阈值  
    
    - 说明  
        > opencv 扩展功能，图片自动二值化  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        
    - 示例  
        ```lua
        
        ```



---
<br />

- ### cv \- 从图片创建一个拉伸的另外尺寸的图片 (**:cv\_resize**)
    - 声明  
        ```lua
        require("image.cv") -- 需要提前加载

        新图像 = 图像:cv_resize(宽, 高)
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 宽, 高  
            整数型，设定的新图片宽高  
        > - 新图像  
            图片对象，返回一个全新尺寸的图片对象  
    
    - 说明  
        > opencv 扩展功能，从图片创建一个拉伸的另外尺寸的图片  
        > 会对对象本身产生影响  
        
    - 示例  
        ```lua
        
        ```



---
<br />

- ### tesseract \- 对图片进行 ocr 识别 (**:tess\_ocr**)
    - 声明  
        ```lua
        require("image.tess_ocr") -- 需要提前加载
        
        识别结果, 结果详情 = 图像:tess_ocr([{
          [lang = 语言,]
          [white_list = 白名单,]
          [black_list = 黑名单,]
        }])
        ```
    
    - 参数及返回值  
        > - 图像  
            图片对象，当前操作的图片对象  
        > - 语言  
            文本型，可选参数，使用的字库名称，默认 "eng"  
        > - 白名单  
            文本型，可选参数，只允许展示的白名单，默认 无  
        > - 黑名单  
            文本型，可选参数，只过滤的黑名单，默认 ""  
        > - 识别结果  
            文本型，返回识别的结果  
        > - 结果详情 \*1\.1\.3\-1 新增  
            表型，识别结果的每个可见字符的位置描述  
    
    - 说明  
        > tesseract 扩展功能，识别文字（XXTouch 已内置 eng 识别库 \[A\-Za\-z0\-9\] 能识别常规英文和数字）  
        > 内置 tesseract 引擎版本为 3\.02，版本不对或者字库文件损坏会导致 XXTouch 脚本服务崩溃  
        > 白名单参数和黑名单参数不可同时存在  
        > 会对对象本身产生影响  
        > 性能上，该函数操作过程不产生数据拷贝  
        > 如果需要做简体中文或是其它语言文字识别  
        > 需要手动导入相关的字库文件到设备的 ```/var/mobile/Media/1ferver/tessdata/``` 目录  
        > 这里提供 [简体中文字库（点击下载）](https://github.com/havonz/XXTouchDebs/blob/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/chi_sim.traineddata.gz)  
        > 如果想自己进行 tesseract 字库训练可以 [百度搜索“tesseract 训练”](https://www.baidu.com/s?wd=tesseract%20训练)  
        
    - 示例  
    ```lua
    require("image.tess_ocr")           -- 需要提前加载
    
    text = img:tess_ocr()               -- 默认为 "eng"，英文识别
    
    text = img:tess_ocr('chi_sim')      -- 简体中文识别
    
    text = img:tess_ocr{
        lang = "eng",                   -- 英文字库
        white_list = "0123456789",      -- 白名单
    }
    
    text = img:tess_ocr{
        lang = "eng",                   -- 英文字库
        black_list = "abcdefghijk",     -- 黑名单
    }
    
    text = img:tess_ocr{
        lang = "chi_sim",               -- 简体中文字库
        white_list = "0123456789.元",    -- 白名单
    }
    ```



---
<br />
<br />
<br />

## 进程字典


- ### 存储值到进程字典 (**proc\_put**)

    - 声明  
        ```lua
        old_value = proc_put(key, value)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，代表需要设置的值  
        > - old\_value  
            字符串型，返回这个键位置的旧的值，如果没有则返回空字符串  
    
    - 说明  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程词典全部被保留**  
        > 存储值到进程字典并返回该键位置原来的值  
        > 如果该键位置原先没有值，则返回空字符串  
        > 存储空字符串代表清空该键位置  
        
    - 示例  
        ```lua
        local bill = ""
        while bill=="" do
            bill = proc_put("billno", "")
        end
        print("billno: ".. bill)
        ```




---
<br />

- ### 查看进程字典存储的值 (**proc\_get**)

    - 声明  
        ```lua
        value = proc_get(key)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，返回该键位置存储的值，如果该键位置没有值则返回空字符串  
    
    - 说明  
        > **这个函数已不推荐使用，可以尝试使用 [proc_put](#存储值到进程字典\-procput) 来代替**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程词典全部被保留**  
        > 从进程词典的指定键位中读取值  
        > 如果该键位置原先没有值，则返回空字符串  
        
    - 示例  
        ```lua
        local bill = proc_get("billno")
        if bill~="" then
            print("has a bill: ".. bill)
        else
            print("no bill")
        end
        ```



---
<br />

- ### 向进程队列词典中压入一个值 (**proc\_queue\_push**)
    - 声明  
        ```lua
        size = proc_queue_push(key, value)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，代表需要压入的值  
        > - size  
            整数型，压入值之后，返回该队列的尺寸，如果返回 0 ，则为压入失败  
    
    - 说明  
        > **此函数效果等同 [proc_queue_push_back](#向进程队列词典尾部压入一个值-procqueuepushback)**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > **进程队列词典的队列尺寸不能大于 10000，尺寸超过的队列将丢弃最先压入的值**  
        > 往进程队列词典中压入一个值，压入值之后，返回该队列的尺寸  
        > 不能压入空字符串  
        
    - 示例  
        ```lua
        local size = proc_queue_push("billnos", "name")
        if size~=0 then
            print("has "..size.." bill(s)")
        else
            print("failed")
        end
        ```



---
<br />

- ### 从进程队列词典中弹出一个值 (**proc\_queue\_pop**)
    - 声明  
        ```lua
        value = proc_queue_pop(key)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，返回弹出的值，如果队列不存在或为空，则返回空字符串  
    
    - 说明  
        > **此函数效果等同 [proc_queue_pop_front](#从进程队列词典头部弹出一个值-procqueuepopfront)**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > 从进程队列词典中弹出一个值  
        > 如果队列不存在或为空，则弹出一个空字符串  
        
    - 示例  
        ```lua
        local billno = proc_queue_pop("billnos")
        if billno~="" then
            print(billno)
        else
            print("no bill")
        end
        ```



---
<br />

- ### 从进程队列词典中弹出所有值 (**proc\_queue\_clear**)
    - 声明  
        ```lua
        values = proc_queue_clear(key)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - values  
            顺序表型，返回包含弹出的所有值的顺序表，如果队列不存在或为空，则返回空表  
    
    - 说明  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > 从进程队列词典中弹出所有值，清空指定队列  
        
    - 示例  
        ```lua
        local billnos = proc_queue_clear("billnos")
        if #billnos~=0 then
            for i, billno in ipairs(billnos) do
                print(i, billno)
            end
        else
            print("no bill")
        end
        ```



---
<br />

- ### 获取进程队列词典的尺寸 (**proc\_queue\_size**)
    - 声明  
        ```lua
        size = proc_queue_size(key)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - size  
            整数型，返回该进程队列词典中的有效条目数  
    
    - 说明  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > 获取进程队列词典的尺寸  
        
    - 示例  
        ```lua
        local size = proc_queue_size("billnos")
        if size~=0 then
            print("has "..size.." bill(s)")
        else
            print("no bill")
        end
        ```



---
<br />

- ### 向进程队列词典头部压入一个值 (**proc\_queue\_push\_front**)
    - 声明  
        ```lua
        size = proc_queue_push_front(key, value)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，代表需要压入的值  
        > - size  
            整数型，压入值之后，返回该队列的尺寸，如果返回 0 ，则为压入失败  
    
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > **进程队列词典的队列尺寸不能大于 10000，尺寸超过的队列将丢弃最先压入的值**  
        > 往进程队列词典头部压入一个值，压入值之后，返回该队列的尺寸  
        > 不能压入空字符串  
        
    - 示例  
        ```lua
        local size = proc_queue_push_front("billnos", "name")
        if size~=0 then
            print("has "..size.." bill(s)")
        else
            print("failed")
        end
        ```



---
<br />

- ### 向进程队列词典尾部压入一个值 (**proc\_queue\_push\_back**)
    - 声明  
        ```lua
        size = proc_queue_push_back(key, value)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，代表需要压入的值  
        > - size  
            整数型，压入值之后，返回该队列的尺寸，如果返回 0 ，则为压入失败  
    
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        > **此函数效果等同 [proc_queue_push](#向进程队列词典中压入一个值-procqueuepush)**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > **进程队列词典的队列尺寸不能大于 10000，尺寸超过的队列将丢弃最先压入的值**  
        > 往进程队列词典尾部压入一个值，压入值之后，返回该队列的尺寸  
        > 不能压入空字符串  
        
    - 示例  
        ```lua
        local size = proc_queue_push_back("billnos", "name")
        if size~=0 then
            print("has "..size.." bill(s)")
        else
            print("failed")
        end
        ```



---
<br />

- ### 从进程队列词典头部弹出一个值 (**proc\_queue\_pop\_front**)
    - 声明  
        ```lua
        value = proc_queue_pop_front(key)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，返回弹出的值，如果队列不存在或为空，则返回空字符串  
    
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        > **此函数效果等同 [proc_queue_pop](#从进程队列词典中弹出一个值-procqueuepop)**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > 从进程队列词典头部弹出一个值  
        > 如果队列不存在或为空，则弹出一个空字符串  
        
    - 示例  
        ```lua
        local billno = proc_queue_pop_front("billnos")
        if billno~="" then
            print(billno)
        else
            print("no bill")
        end
        ```



---
<br />

- ### 从进程队列词典尾部弹出一个值 (**proc\_queue\_pop\_back**)
    - 声明  
        ```lua
        value = proc_queue_pop_back(key)
        ```
    
    - 参数及返回值  
        > - key  
            字符串型，代表键  
        > - value  
            字符串型，返回弹出的值，如果队列不存在或为空，则返回空字符串  
    
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        > **所有以 "xxtouch\." 或 "1ferver\." 开头的进程队列词典全部被保留**  
        > 从进程队列词典尾部弹出一个值  
        > 如果队列不存在或为空，则弹出一个空字符串  
        
    - 示例  
        ```lua
        local billno = proc_queue_pop_back("billnos")
        if billno~="" then
            print(billno)
        else
            print("no bill")
        end
        ```


---
<br />
<br />
<br />

## 线程模块（thread）
thread 模块使用 Lua 自带协程（coroutine）模块实现，非通常意义上的多线程  

- ### 派发一个任务 (**thread\.dispatch**)
    - 声明  
        ```lua
        tid = thread.dispatch(task [, error_callback ])
        ```
    
    - 参数及返回值  
        > - task  
            函数型，这个函数将加入任务队列  
        > - error\_callback  
            函数型，错误回调，当执行任务时发生异常，则会回调这个函数并不再抛出，可选参数，默认在异常时抛出错误  
        > - tid  
            整数型，任务 id，这个 id 可用于结束或是等待一个任务  
    
    - 说明  
        > 派发一个任务到队列，当其它任务空闲时则会开始该项任务  
        
    - 示例  
        [`本章最后`](#thread\-示例代码)
        



---
<br />

- ### 获取当前任务的 ID (**thread\.current\_id**)
    - 声明  
        ```lua
        tid = thread.current_id()
        ```
    
    - 参数及返回值  
        > - tid  
            整数型，任务 id，这个 id 可用于结束或是等待一个任务  
    
    - 说明  
        > 获取当前任务的 id  
        
    - 示例  
        [`本章最后`](#thread\-示例代码)



---
<br />

- ### 从队列中移除一项任务 (**thread\.kill**)
    - 声明  
        ```lua
        thread.kill(tid)
        ```
    
    - 参数及返回值  
        > - tid  
            整数型，任务 id，这个 id 可用于结束或是等待一个任务  
    
    - 说明  
        > 从队列中移除一项任务，不管它是否已经开始，是否已经完成  
        
    - 示例  
        [`本章最后`](#thread\-示例代码)



---
<br />

- ### 阻塞等待一个任务完成 (**thread\.wait**)
    - 声明  
        ```lua
        thread.wait(tid, timeout)
        ```
    
    - 参数及返回值
        > - timeout
            实数型，等待超时时间，超时后将返回，单位：秒
        > - tid
            整数型，任务 id，这个 id 可用于结束或是等待一个任务
    
    - 说明  
        > 当前线程阻塞等待一个任务完成
        
    - 示例  
        [`本章最后`](#thread\-示例代码)



---
<br />

- ### 注册监听一个事件 (**thread\.register\_event**)
    - 声明  
        ```lua
        eid = thread.register_event(event, callback [, error_callback ])
        ```
    
    - 参数及返回值  
        > - event  
            字符串型，代表事件名  
        > - callback  
            函数型，事件将会触发的回调函数  
        > - error\_callback  
            函数型，错误回调，当执行任务时发生异常，则会回调这个函数并不再抛出，可选参数，默认在异常时抛出错误  
        > - eid  
            整数型，事件 id，可以用于反注册监听该事件  
    
    - 说明  
        > 注册监听一个事件 
        
    - 示例  
        [`本章最后`](#thread\-示例代码)



---
<br />

- ### 反注册监听一个事件 (**thread\.unregister\_event**)
    - 声明  
        ```lua
        eid = thread.unregister_event(event, eid)
        ```
    
    - 参数及返回值  
        > - event  
            字符串型，代表事件名  
        > - eid  
            整数型，事件 id，可以用于反注册监听该事件  
    
    - 说明  
        > 反注册监听一个事件  
        
    - 示例  
        [`本章最后`](#thread\-示例代码)



---
<br />

### thread 示例代码
```lua

tmid = thread.dispatch( -- 派发一个异步任务
	function()
	    sys.msleep(2700)
		sys.toast("这是第 2.7 秒")
	end
)

tid = thread.dispatch( -- 派发一个异步任务
	function()
		sys.msleep(300)
		for i=1,10 do
			sys.toast("线程 2: "..i)
			sys.msleep(1000)
		end
		sys.toast("应该运行不到这里")
	end
)

-- iPhone 5C 双指合拢缩小相册图片示例

thread.dispatch(function() -- 派发一个滑动任务
	touch.on(59,165)
	    :move(297,522)
	    :delay(500)
    :off()
end)

thread.dispatch(function() -- 再派发一个滑动任务
	touch.on(580,1049)
	    :move(371,1049)
	    :delay(500)
    :off()
end)

proc_queue_clear("来自远方的消息")
eid = thread.register_event( -- 注册监听字典状态有值事件
	"来自远方的消息",
	function(val)
		sys.toast("收到消息："..val)
	end
)

sys.msleep(300)
thread.wait(tmid)

for i=1,10 do
	sys.toast("线程 1: "..i)
	sys.msleep(400)
end

thread.kill(tid) -- 杀死 线程 2
thread.unregister_event("来自远方的消息", eid) -- 取消一个字典状态有值事件

sys.toast("完了")

```
**注**：上述代码中使用了非本章函数及方法  [`proc_queue_clear`](#从进程队列词典中弹出所有值\-procqueueclear)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`sys.toast`](#显示提示文字\-systoast)、[`touch.on`](#模拟手指接触屏幕-touchon)、[`:move`](#模拟手指在屏幕上移动-move)、[`:delay`](#毫秒级延迟-delay)、[`:off`](#模拟手指离开屏幕-off)



---
<br />
<br />
<br />

## Web 视图模块（webview）

webview 模块在 iOS 16 以上已无法使用  

- ### 展现一个 webview (**webview.show**)
    - 声明  
        ```lua
        webview.show { -- 所有参数皆为可选参数
            html = HTML内容,
            x = 原点横坐标,
            y = 原点纵坐标,
            width = 宽度,
            height = 高度,
            corner_radius = 圆角半径,
            alpha = 不透明度,
            animation_duration = 动画时间,
            rotate = 旋转角度,
            level = 窗体层级,
            opaque = 范围不透明,
            ignores_hit = 是否忽略触摸事件,
            can_drag = 是否能被拖动,
        }
        ```
    
    * 字段说明  
        > - html  
            文本型，可选参数，页面 html 内容。默认为 上次调用 webview.show 时候所设  
        > - id  
            整数型，可选参数，表示当前 webview 的 id，可使用不同的 id 来同时展现多个 webview，范围 1 ~ 1000，默认为 1  
        > - x  
            整数型，可选参数，距离左侧的距离。默认为 0  
        > - y  
            整数型，可选参数，距离顶端的距离。默认为 0  
        > - width  
            整数型，可选参数，弹出窗口的宽度。默认为 屏幕宽度  
        > - height  
            整数型，可选参数，弹出的窗口高度。默认为 屏幕高度  
        > - alpha  
            实数型，可选参数，不透明度，范围 0\.0 ~ 1\.0。默认为 1\.0  
        > - corner\_radius  
            实数型，可选参数，圆角半径，0\.0 则是方角。默认为 0\.0  
        > - animation_duration  
            实数型，可选参数，从上次状态到参数所设状态的动画时间。默认为 0\.0  
        > - rotate  
            实数型，可选参数，旋转状态， 0\.0（竖屏）、90\.0（横屏 Home 在右）、180\.0（竖屏翻转）、270\.0（横屏 Home 在左）。默认为 0\.0  
        > - level  
            实数型，可选参数，窗体层级，默认 1100\.0  
        > - opaque  
            布尔型，可选参数，背景不透明选项，默认为 true 背景不透明  
        > - ignores\_hit  
            布尔型，可选参数，用于设置忽略（不拦截）触摸事件，默认为 false 不忽略，这个属性在 webview 创建后不能更改，而且 opaque 必须设为 false  
        > - can\_drag  
            布尔型，可选参数，用于设置是否可拖拽移动 webview，默认为 false 不能拖动  
    
    - 说明  
        > 让 webview 以参数设置的那样出现  
        > 除了 html 参数会保持上一次 show 的状态，其它参数一律会在调用时重设成默认值  
        > iOS 16 以上已不能使用  
        
    - 示例  
        [`本章结尾`](#webview\-使用示例)


---
<br />

- ### 隐藏一个 webview (**webview.hide**)
    - 声明  
        ```lua
        webview.hide([ id ])
        ```
    
    - 参数及返回值  
        > - id  
            整数型，可选参数，表示当前 webview 的 id，范围 1 ~ 1000，默认为 1  
    
    - 说明  
        > 暂时隐藏一个 webview  
        
    - 示例  
        [`本章结尾`](#webview\-使用示例)




---
<br />

- ### 在一个 webview 上执行一段 JS (**webview.eval**)
    - 声明  
        ```lua
        str = webview.eval(js [, id ])
        ```
    
    - 参数及返回值  
        > - js  
            文本型，需要执行的 JS 代码  
        > - id  
            整数型，可选参数，表示当前 webview 的 id，范围 1 ~ 1000，默认为 1  
        > - str  
            文本型，返回执行 JS 代码产生的返回值  
    
    - 说明  
        > 在一个 webview 上执行一段 JS 并获得返回值文字  
        > iOS 16 以上已不能使用  
        
    - 示例  
        ```lua
        r = webview.eval("a = 3; b = 2; a * b;")
        ```




---
<br />

- ### 获取一个 webview 的区域及层级信息 (**webview.frame**)
    - 声明  
        ```lua
        frame = webview.frame([ id ])
        ```
    
    - 参数及返回值  
        > - id  
            整数型，可选参数，表示当前 webview 的 id，范围 1 ~ 1000，默认为 1  
        > - frame  
            表型，返回当前 webview 的区域及层级信息  
    
    - 说明  
        > 获取一个 webview 的区域及层级信息  
        
    - 示例  
        ```lua
        local frame = webview.frame(1)
        sys.alert(
            "位置为:".."("..frame.x..","..frame.y..")\n"..
            "大小为:".."(宽:"..frame.width..",高:"..frame.height..")\n"..
            "层级为:".."("..frame.level..")"
        )
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)




---
<br />

- ### 销毁一个 webview (**webview.destroy**)
    - 声明  
        ```lua
        webview.destroy([ id ])
        ```
    
    - 参数及返回值  
        > - id  
            整数型，可选参数，表示当前 webview 的 id，可使用不同的 id 来同时展现多个 webview，范围 1 ~ 1000，默认为 1  
    
    - 说明  
        > 销毁一个 webview  
        > 脚本停止的时候，会自动调用销毁所有展现过的 webview  
        
    - 示例  
        [`本章结尾`](#webview\-使用示例)




---
<br />


### webview 使用示例
- 更多示例脚本下载  
    [\[演示\]WV高阶UI-自制toast.lua](https://github.com/havonz/XXTouchDebs/blob/master/%E8%84%9A%E6%9C%AC%E6%BA%90%E7%A0%81/%5B%E6%BC%94%E7%A4%BA%5DWV%E9%AB%98%E9%98%B6UI-%E8%87%AA%E5%88%B6toast.lua)

- 一个演示  
    ```lua
    local html = [=[
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
    	</body>
    </html>
    ]=]
    
    local w, h = screen.size()
    
    local factor = 1 -- 默认高度为 2x 设备所设
    if w == 1242 or w == 1080 then
    	factor = 1.5 -- iPhone 6(S)+ 的分辨率是 3x 的
    elseif w == 320 or w == 768 then
    	factor = 0.5 -- 3Gs 以前的 iPhone 的分辨率是 1x 的
    end
    
    webview.show{ -- 重置 webview 位置到左上角
    	x = 0,
    	y = 0,
    	width = w - 40 * factor,
    	height = (500) * factor,
    	alpha = 0,
    	animation_duration = 0,
    }
    
    webview.show{ -- 从左上角用0.3秒的时间滑动出来
    	html = html,
    	x = 20 * factor,
    	y = 50 * factor,
    	width = (w - 40 * factor),
    	height = (500) * factor,
    	corner_radius = 10,
    	alpha = 0.7,
    	animation_duration = 0.3,
    }
    
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
    
    sys.msleep(3000)
    sys.toast("主线程结束")
    
    ```
    **注**：上述代码中使用了非本章函数 [`screen.size`](#获取屏幕尺寸-screensize)、[`proc_queue_clear`](##从进程队列词典中弹出所有值\-procqueueclear)、[`thread.register_event`](#注册监听一个事件\-threadregisterevent)、[`proc_get`](#查看进程字典存储的值-procget)、[`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)


---
<br />
<br />
<br />

## 脚本包模块（xpp）  

- ### 获取当前脚本包的元信息 (**xpp\.info**)  
    - 声明  
        ```lua
        元信息 = xpp.info()
        ```
    
    - 参数及返回值  
        > - 元信息  
            表型，返回当前脚本包的元信息，如果当前正在运行的脚本不是脚本包，返回一个空表  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 用于从运行着的脚本中获取当前脚本的元信息  
        
    - 示例  
        ```lua
        local info = xpp.info()
        ```



---
<br />


- ### 获取当前脚本包的包路径 (**xpp\.bundle_path**)  
    - 声明  
        ```lua
        包路径 = xpp.bundle_path()
        ```
    
    - 参数及返回值  
        > - 包路径  
            文本型，返回当前脚本包的包路径，如果当前正在运行的脚本不是脚本包，返回当前运行的脚本路径  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 用于从运行着的脚本中获取当前脚本的路径  
        
    - 示例  
        ```lua
        local path = xpp.bundle_path()
        ```



---
<br />


- ### 获取当前脚本包中的资源路径 (**xpp\.resource_path**)  
    - 声明  
        ```lua
        资源路径 = xpp.resource_path(资源文件名)
        ```
    
    - 参数及返回值  
        > - 资源路径  
            文本型 或 nil，返回当前脚本包的某个资源文件的路径，如果资源不存在，则返回 nil  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 用于从运行着的脚本中获取当前脚本包中的某个资源文件的路径，支持本地化  
        
    - 示例  
        ```lua
        local path = xpp.resource_path('appicon.png')
        ```



---
<br />
<br />
<br />



## 脚本配置界面模块（xui）  

- ### 展示一个配置界面 (**xui\.show**)  
    - 声明  
        ```lua
        xui.show(配置界面文件名)
        ```
    
    - 参数及返回值  
        > - 配置界面文件名  
            文本型，需要展示的当前脚本包中的配置界面文件（\.xui）的文件名，只能是当前脚本包内的配置界面文件（\.xui）  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 立刻使用 App 展示展示配置界面  
        该函数不会阻塞，没有返回值，会调起 App 尝试展示，展示失败会在 App 内显示  
        
    - 示例  
        ```lua
        xui.show('interface.xui')
        ```



---
<br />


- ### 收起正在展示的配置界面 (**xui\.dismiss**)  
    - 声明  
        ```lua
        xui.dismiss()
        ```
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 尝试让 App 收起配置界面回到主界面  
        该函数不会阻塞，没有返回值，会调起 App 尝试收起配置界面，如果没有配置界面正在展示则跳转到 App 什么都不发生  
        
    - 示例  
        ```lua
        xui.dismiss()
        ```



---
<br />


- ### 校验配置界面的配置 (**xui\.setup**)  
    - 声明  
        ```lua
        xui.setup(配置界面文件名)
        ```
    
    - 参数及返回值  
        > - 配置界面文件名  
            文本型，需要校验的当前脚本包中的配置界面文件（\.xui）的文件名，只能是当前脚本包内的配置界面文件（\.xui）  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 如果配置界面没有被配置过，则此函数用于生成该配置界面的默认配置，并且同时它会根据配置界面中的控件校验并修正存储的配置的值类型  
        
    - 示例  
        ```lua
        xui.setup('interface.xui')
        ```



---
<br />


- ### 重新加载当前正在展示的配置界面 (**xui\.reload**)  
    - 声明  
        ```lua
        xui.reload()
        ```
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 如果当前没有正在展示配置界面，则什么都不发生  
        > 注意控制好这个函数的调用频率，频率太高会导致 App 卡死  
        
    - 示例  
        ```lua
        xui.reload()
        ```



---
<br />


- ### 获取配置界面的配置值 (**xui\.get**)  
    - 声明  
        ```lua
        值 = xui.get(配置分区, 配置键)
        ```
    
    - 参数及返回值  
        > - 配置分区  
            文本型，配置界面中的配置分区（defaults）标识符  
        > - 配置键  
            文本型，配置界面中的控件的配置键（key）标识符  
        > - 值  
            任意类型，不同的控件类型会返回不同的值，如果没有该配置值，返回 nil  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 该函数不负责过滤值类型，如果需要保证获取的值类型合法，可先使用 xui\.setup 来校验修正再读取  
        
    - 示例  
        ```lua
        xui.setup('interface.xui')
        local enabled = xui.get('com.yourcompany.A-Script-Bundle', 'enabled')
        ```



---
<br />


- ### 设置配置界面上的某个控件的值 (**xui\.set**)  
    - 声明  
        ```lua
        xui.set(配置分区, 配置键, 值)
        ```
    
    - 参数及返回值  
        > - 配置分区  
            文本型，配置界面中的配置分区（defaults）标识符  
        > - 配置键  
            文本型，配置界面中的控件的配置键（key）标识符  
        > - 值  
            任意类型，不同的控件类型可以设置不同的值  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 如果当前正显示着配置界面，则该函数会立刻更新界面上的显示值  
        该函数不负责过滤值类型，如果需要保证值类型合法，可于设置后使用 xui\.setup 来校验修正  
        
    - 示例  
        ```lua
        xui.set('com.yourcompany.A-Script-Bundle', 'enabled', true)
        xui.setup('interface.xui')
        ```



---
<br />


- ### 读取某个配置分区所有配置 (**xui\.read**)
    - 声明  
        ```lua
        配置 = xui.read(配置分区)
        ```
    
    - 参数及返回值  
        > - 配置分区  
            文本型，配置界面中的配置分区（defaults）标识符  
        > - 配置  
            表型，这个配置分区所有配置的键值对，如果没有该配置分区，则返回空表  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 该函数用于优化读取多个配置  
        该函数不负责过滤值类型，如果需要保证获取的值类型合法，可先使用 xui\.setup 来校验修正再读取  
        
    - 示例  
        ```lua
        xui.setup('interface.xui')
        local dict = xui.read('com.yourcompany.A-Script-Bundle')
        local enabled = dict['enabled']
        ```



---
<br />


- ### 覆盖写入配置表到某个配置分区 (**xui\.write**)  
    - 声明  
        ```lua
        操作成败 = xui.write(配置分区, 配置)
        ```
    
    - 参数及返回值  
        > - 配置分区  
            文本型，配置界面中的配置分区（defaults）标识符  
        > - 配置  
            表型，配置的键值对  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 该函数用于优化同时设置多项配置，如果当前正显示着配置界面，则该函数会立刻更新界面上的显示值  
        该函数不负责过滤值类型，如果需要保证值类型合法，可于写入后使用 xui\.setup 来校验修正  
        
    - 示例
        ```lua
        xui.setup('interface.xui')
        local dict = xui.read('com.yourcompany.A-Script-Bundle')
        dict['enabled'] = true
        xui.write('com.yourcompany.A-Script-Bundle', dict)
        xui.setup('interface.xui')
        ```



---
<br />


- ### 清除某个配置分区所有的配置 (**xui\.clear**)  
    - 声明  
        ```lua
        操作成败 = xui.clear(配置分区)
        ```
    
    - 参数及返回值  
        > - 配置分区  
            文本型，配置界面中的配置分区（defaults）标识符  
    
    - 说明  
        > **这个函数在 1\.2\-10 版以上方可使用**  
        > 该函数用于优化同时设置多项配置，如果当前正显示着配置界面，则该函数会立刻更新界面上的显示值  
        可于清除后使用 xui\.setup 再次生成配置界面的默认配置  
        
    - 示例  
        ```lua
        xui.clear('com.yourcompany.A-Script-Bundle')
        xui.setup('interface.xui')
        ```



---
<br />
<br />
<br />

## 扩展 table 模块
**[table](http://cloudwu.github.io/lua53doc/manual.html#6.6) 模块是 Lua 基础模块，XXTouch 在其基础上做了一些扩展。**  

- ### 深拷贝一个表 (**table\.deep\_copy**)
    - 声明  
        ```lua
        被复制的表 = table.deep_copy(一个表)
        ```
    
    - 参数及返回值  
        > - 一个表  
            表型，需要拷贝的表  
        > - 被复制的表  
            表型，返回表的拷贝份  
    
    - 说明  
        > 迭代拷贝一个表到另外一个表，表中除 function 和 userdata 以外的所有值都会拷贝  
        > 拷贝出来的表中如果有循环引用，那么引用关系也会获得拷贝  
        
    - 示例  
        ```lua
        local _g = table.deep_copy(_G)
        ```



---
<br />

- ### 深打印一个表 (**table\.deep\_print**)
    - 声明  
        ```lua
        表文本 = table.deep_print(关联表)
        ```
    
    - 参数及返回值  
        > - 关联表  
            表型，需要打印成字符串的表  
        > - 表文本  
            文本型，返回表的树形结构的文本，这个文本不保证格式兼容  
    
    - 说明  
        > 将一个表的树形结构打印出来  
        > 打印出来的结构**不保证格式兼容**，不同版本打印出来可能不一样  
        > 非表型引用类型（用户数据、函数）不可通过 [table.load_string](#从字符串加载一个表-tableloadstring) 反序列，只保证人类可读性  
        > 这个函数会将内容输出到 [print 缓冲区](#打印内容到缓冲区-print)  
        
    - 示例  
        ```lua
        local s = table.deep_print(_G)
        sys.alert(s)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 从字符串加载一个表 (**table\.load\_string**)
    - 声明  
        ```lua
        关联表 = table.load_string(表文本)
        ```
    
    - 参数及返回值  
        > - 表文本  
            文本型，表的树形结构的文本，只能包含静态数据，不能包含任何动态代码  
        > - 关联表  
            表型 或 nil，加载成功返回表结构，失败返回 nil  
    
    - 说明  
        > **这个函数在 1\.1\.2\-6 版以上方可使用**  
        > 将一个树形结构文本描述转换成一个表对象  
        > 一定意义上，[table.load_string](#从字符串加载一个表-tableloadstring) 是 [table.deep_print](#深打印一个表-tabledeepprint) 的反函数（这取决有没有循环引用或非表引用类型）  
        > 它与 [load](http://cloudwu.github.io/lua53doc/manual.html#pdf-load) 的区别在于，它不会运行文本中的代码，只会使用静态数据  
        > 例如以下示例包含奇怪代码，结果是 b 为 nil  
        ```lua
        b = table.load_string[[ {
            a = os.execute('reboot'), -- 这里的代码将不会运行，并且会返回 nil
        } ]]
        ```
        
    - 示例  
        ```lua
        local t = table.load_string[[ {
            a = 1,
            b = 2,
            c = 3,
        } ]]
        sys.alert(t.b)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />
<br />
<br />

## 扩展 string 模块
**[string](http://cloudwu.github.io/lua53doc/manual.html#6.4) 模块是 Lua 基础模块，XXTouch 在其基础上做了一些扩展。**  

- ### 转成 16 进制文本 (**string\.to\_hex**)
    - 声明  
        ```lua
        16进制文本 = string.to_hex(数据内容)
        ```
    
    - 参数及返回值  
        > - 数据内容  
            字符串型，需要转换成 16 进制的字符串  
        > - 16进制文本  
            文本型，返回 16 进制文本  
    
    - 说明  
        > 将字符串（或二进制数据块）转换成可打印的 16 进制文本  
        
    - 示例  
        ```lua
        -- 示例 1：
        sys.alert(string.to_hex('一些数据'))
        -- 输出 "e4b880e4ba9be695b0e68dae"
        
        -- 示例 2：
        sys.alert((string.to_hex('一些数据'):gsub('(..)', '\\x%1')))
        -- 输出 "\xe4\xb8\x80\xe4\xba\x9b\xe6\x95\xb0\xe6\x8d\xae"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
    - 更多示例
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 从 16 进制文本转回 (**string\.from\_hex**)
    - 声明  
        ```lua
        数据内容 = string.from_hex(16进制文本)
        ```
    
    - 参数及返回值  
        > - 16进制文本  
            文本型，需要转换成字符串的 16 进制文本  
        > - 数据内容  
            字符串型 或 nil，返回字符串，如果输入参数不是 16 进制文本，则返回 nil  
    
    - 说明  
        > string\.to\_hex 的反函数，将可打印的 16 进制文本转换成字符串（或二进制数据块）  
        
        
    - 示例  
        ```lua
        sys.alert(string.from_hex('e4b880e4ba9be695b0e68dae'))
        -- 输出 "一些数据"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
    - 更多示例
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 将 GBK 编码的文本转成 UTF\-8 编码的文本 (**string\.from\_gbk**)
    - 声明  
        ```lua
        可以直接用的文本 = string.from_gbk(GBK编码的文本)
        ```
    
    - 参数及返回值  
        > - GBK编码的文本  
            文本型，需要转换成 UTF\-8 编码的 GBK 编码文本  
        > - 可以直接用的文本  
            字符串型 或 nil，返回 UTF\-8 编码的文本，如果编码错误导致转换无法完成，返回 nil  
    
    - 说明  
        > 将 GBK 编码的文本转成 UTF\-8 编码的文本，转换返回乱码字符串可能是编码不正确，但是能完成编码对应转换，这不是函数的问题  
        > 更复杂的编码转换需求请参考 [luaiconv（编码转换库）](#luaiconv-扩展库编码转换库)  
        > 注：GBK 编码包含 GB2312 编码，所以如果需要 GB2312 编码的文本转换也是这个函数  
        
    - 示例  
        ```lua
        -- 中文编码 中文标准编码 国标扩展编码 GB2312
        gbkstr = '\x58\x58\x54\x6f\x75\x63\x68\x20\xba\xdc\xc7\xbf'
        
        sys.alert(gbkstr)                  -- GBK 编码的字符串无法显示
        sys.alert(string.from_gbk(gbkstr)) -- 输出 "XXTouch 很强"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        **说明**：在 Lua 源码中，字符串中 `\x` 开头，后面跟两位 16 进制数表示以该数字编码的单个字节。例如：`\x58` 表示 `X` 这个字符，可打印字符部分参考[《ASCII 编码》](https://baike.baidu.com/item/ASCII/309296)



---
<br />

- ### 计算字符串的 md5 哈希值 (**string\.md5**)
    - 声明  
        ```lua
        哈希值 = string.md5(数据内容)
        ```
    
    - 参数及返回值  
        > - 数据内容  
            字符串型，原始字符串  
        > - 哈希值  
            文本型，返回字符串的 md5 哈希值的 16 进制文本  
    
    - 说明  
        > 计算字符串（或二进制数据块）的 md5 校验值  
        
    - 示例  
        ```lua
        sys.alert(string.md5('XXTouch 真棒')) -- 输出 "4921dbf380df452fa959dc47cef30e4b"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
    - 更多示例
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 计算字符串的 sha1 哈希值 (**string\.sha1**)
    - 声明  
        ```lua
        哈希值 = string.sha1(数据内容)
        ```
    
    - 参数及返回值  
        > - 数据内容  
            字符串型，原始字符串  
        > - 哈希值  
            文本型，返回字符串的 sha1 哈希值的 16 进制文本  
    
    - 说明  
        > 计算字符串（或二进制数据块）的 sha1 校验值  
        
    - 示例  
        ```lua
        sys.alert(string.sha1('XXTouch 真棒')) -- 输出 "a959c48d904c1075c7ddfdb1fda49effb2142493"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
    - 更多示例
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 对字符串进行 base64 编码 (**string\.base64\_encode**)
    - 声明  
        ```lua
        b64文本 = string.base64_encode(数据内容)
        ```
    
    - 参数及返回值  
        > - 数据内容  
            字符串型，原始字符串  
        > - b64文本  
            文本型，返回字符串的 base64 编码文本  
    
    - 说明  
        > 对字符串（或二进制数据块）进行 base64 编码  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 对 base64 编码的文本进行解码 (**string\.base64\_decode**)
    - 声明  
        ```lua
        数据内容 = string.base64_decode(b64文本)
        ```
    
    - 参数及返回值  
        > - b64文本  
            文本型，base64 编码的文本  
        > - 数据内容  
            字符串型，返回解码后的字符串  
    
    - 说明  
        > string\.base64\_encode 的反函数，将 base64 编码的文本转换回字符串（或二进制数据块）  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 对字符串进行加密 (**string\.aes128\_encrypt**)
    - 声明  
        ```lua
        加密的数据 = string.aes128_encrypt(数据内容, 密钥)
        ```
    
    - 参数及返回值  
        > - 数据内容  
            字符串型，需要加密的字符串  
        > - 密钥  
            字符串型，密码  
        > - 加密的数据  
            字符串型，加密后的二进制数据块  
    
    - 说明  
        > 使用 AES128 算法 ECB 模式将字符串（或二进制数据块）加密  
        > 注：AES128 算法 ECB 模式不存在 iv（偏移向量） 参数，如果对接开发中一定需要写，那么是 0  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 解密一段已加密的字符串 (**string\.aes128\_decrypt**)
    - 声明  
        ```lua
        数据内容 = string.aes128_decrypt(加密的数据, 密钥)
        ```
    
    - 参数及返回值  
        > - 加密的数据  
            字符串型，已经加密的字符串  
        > - 密钥  
            字符串型，密码  
        > - 数据内容  
            字符串型，解密之后的字符串  
    
    - 说明  
        > 使用 AES128 算法 ECB 模式将加密的字符串（或二进制数据块）解密  
        > 注：AES128 算法 ECB 模式不存在 iv（偏移向量） 参数，如果对接开发中一定需要写，那么是 0  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 用分隔符规则分割一个字符串 (**string\.split**)
    - 声明  
        ```lua
        分割好的文本数组 = string.split(待分割文本, 分隔符)
        ```
    
    - 参数及返回值  
        > - 待分割文本  
            文本型，需要分割的字符串  
        > - 分隔符  
            文本型，分隔符  
        > - 分割好的文本数组  
            表型，分割后的字符串片段按顺序排列于此表  
    
    - 说明  
        > 用分隔符规则分割一个字符串  
        > 字符串分割 文本分割 字符串分割 文本切割 文本分段  
        
    - 示例  
        ```lua
        -- 示例 1（分割账号密码）：
        t = string.split('lfue6841214----123456', '----')
        sys.alert('账号是：'..t[1])
        
        -- 示例 2（取文本中间部分，两个 # 之间的文字）：
        t = string.split('您好，验证码是#4937#，15分钟内有效。【爆炸科技】', '#')
        sys.alert('验证码是：'..t[2])
        
        -- 示例 3（复杂点的取文本中间部分）：
        t = string.split('您好，验证码是4937，15分钟内有效。【爆炸科技】', '验证码是')
        t = string.split(t[2], '，15分钟')
        sys.alert('验证码是：'..t[1])
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
        ```lua
        -- 取文本中间部分的封装（找不到匹配返回 nil）
        function str_middle(str, sep1, sep2)
            assert(type(str) == 'string', '`str_middle` 第 #1 参数必须是字符串')
            assert(type(sep1) == 'string', '`str_middle` 第 #2 参数必须是字符串')
            assert(type(sep2) == 'nil' or type(sep2) == 'string', '`str_middle` 第 #3 参数可选，但必须是字符串')
            local t = string.split(str, sep1)
            if not sep2 or sep1==sep2 then
                return t[2]
            else
                if t[2] == nil then
                    return nil
                else
                    t = string.split(t[2], sep2)
                    if t[2] == nil then
                        return nil
                    else
                        return t[1]
                    end
                end
            end
        end
        -- 以上封装可复制到脚本中用
        
        r = str_middle('您好，验证码是4937，15分钟内有效。【爆炸科技】', '码是', '，15分')
        sys.alert('验证码是：'..r)
        -- 输出 "验证码是：4937"
        
        r = str_middle('您好，验证码是#8346#，15分钟内有效。【爆炸科技】', '#')
        sys.alert('验证码是：'..r)
        -- 输出 "验证码是：8346"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
        ```lua
        -- 取绝对路径的文件名
        function strip_dirname(path)
        	local d = string.split(path, '/')
        	return d[#d]
        end
        
        -- 取绝对路径的目录
        function strip_filename(path)
        	local d = string.split(path, '/')
        	d[#d] = nil
        	return table.concat(d, '/')
        end
        
        sys.alert(strip_dirname("/private/var/mobile/Media/1ferver/lua/scripts/1.lua"))
        -- 输出 "1.lua"
        
        sys.alert(strip_filename("/private/var/mobile/Media/1ferver/lua/scripts/1.lua"))
        -- 输出 "/private/var/mobile/Media/1ferver/lua/scripts"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[table.concat](http://cloudwu.github.io/lua53doc/manual.html#pdf-table.concat)
        
        
    - 可能相关的示例（将中英混合的字符串爆开成一个个的字符）
        ```lua
        -- 这不是使用 string.split 实现的例子
        function string_explode(str)
        	local ret = {}
        	for p, c in utf8.codes(str) do
        		ret[#ret + 1] = utf8.char(c)
        	end
        	return ret
        end
        
        local t = string_explode('你好，XXTouch')
        sys.alert(table.concat(t, '/')) -- 输出 "你/好/，/X/X/T/o/u/c/h"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[table.concat](http://cloudwu.github.io/lua53doc/manual.html#pdf-table.concat)、[utf8.char](http://cloudwu.github.io/lua53doc/manual.html#pdf-utf8.char)、[utf8.codes](http://cloudwu.github.io/lua53doc/manual.html#pdf-utf8.codes)
        
    - 更多示例
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 判断字符串起始于 (**string\.starts_with**)
    - 声明  
        ```lua
        是否以该前缀起始 = string.starts_with(源字符串, 前缀[, 位置])
        ```
    
    - 参数及返回值  
        > - 源字符串  
            字符串型  
        > - 前缀  
            字符串型  
        > - 位置  
            整数型，可选参数，指定开始搜索的位置，默认 1  
        > - 是否以该前缀起始  
            布尔型  
    
    - 说明  
        > 判断字符串 `源字符串` 是否以 `前缀` 开头  
        > **这个函数在 20250313 以后版本方可使用**  
        
    - 示例  
        ```lua
        nLog(string.starts_with('Hello, XXTouch', 'Hello')) -- 输出 true
        nLog(string.starts_with('Hello, XXTouch', 'ello', 2)) -- 输出 true
        ```



---
<br />

- ### 判断字符串结束于 (**string\.ends_with**)
    - 声明  
        ```lua
        是否以该后缀结尾 = string.ends_with(源字符串, 后缀[, 长度])
        ```
    
    - 参数及返回值  
        > - 源字符串  
            字符串型  
        > - 后缀  
            字符串型  
        > - 长度  
            整数型，可选参数，指定搜索的长度，默认为 `源字符串` 的长度  
        > - 是否以该后缀结尾  
            布尔型  
    
    - 说明  
        > 判断字符串 `源字符串` 是否以 `后缀` 结尾  
        > **这个函数在 20250313 以后版本方可使用**  
        
    - 示例  
        ```lua
        nLog(string.ends_with('Hello, XXTouch', 'XXTouch')) -- 输出 true
        nLog(string.ends_with('Hello, XXTouch', 'ello', 5)) -- 输出 true
        ```



---
<br />

- ### 左填充字符串 (**string\.lpad**)
    - 声明  
        ```lua
        填充后的字符串 = string.lpad(源字符串, 长度, 填充字符)
        ```
    
    - 参数及返回值  
        > - 源字符串  
            字符串型  
        > - 长度  
            整数型，指定填充后的字符串长度  
        > - 填充字符  
            字符串型，可选参数，指定填充的字符，默认为空格  
        > - 填充后的字符串  
            字符串型  
    
    - 说明  
        > 左填充字符串 `源字符串`，使其长度达到 `长度`，不足的用 `填充字符` 填充  
        > **这个函数在 20250313 以后版本方可使用**  
        
    - 示例  
        ```lua
        nLog(string.lpad('ff',   6, '0'))  -- 输出 0000ff
        nLog(string.lpad('100',  6, '0'))  -- 输出 000100
        nLog(string.lpad('1234', 6, '0'))  -- 输出 001234
        nLog(string.lpad('123',  6, 'xy')) -- 输出 xyx123
        ```



---
<br />

- ### 右填充字符串 (**string\.rpad**)
    - 声明  
        ```lua
        填充后的字符串 = string.rpad(源字符串, 长度, 填充字符)
        ```
    
    - 参数及返回值  
        > - 源字符串  
            字符串型  
        > - 长度  
            整数型，指定填充后的字符串长度  
        > - 填充字符  
            字符串型，可选参数，指定填充的字符，默认为空格  
        > - 填充后的字符串  
            字符串型  
    
    - 说明  
        > 右填充字符串 `源字符串`，使其长度达到 `长度`，不足的用 `填充字符` 填充  
        > **这个函数在 20250313 以后版本方可使用**  
        
    - 示例  
        ```lua
        nLog(string.rpad('ff',   6, '0'))  -- 输出 ff0000
        nLog(string.rpad('100',  6, '0'))  -- 输出 100000
        nLog(string.rpad('1234', 6, '0'))  -- 输出 123400
        nLog(string.rpad('123',  6, 'xy')) -- 输出 123xyx
        ```



---
<br />

- ### 去除文本左边空白字符 (**string\.ltrim**)
    - 声明  
        ```lua
        处理后文本 = string.ltrim(处理前文本)
        ```
    
    - 参数及返回值  
        > - 处理前文本  
            文本型，需要去除左边空白字符的文本  
        > - 处理后文本  
            文本型，返回已经去除左边空白字符的文本  
    
    - 说明  
        > 去除文本左边空白字符  
        > 空白字符包括 `"\r"` `"\n"` `"\t"`  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 去除文本右边空白字符 (**string\.rtrim**)
    - 声明  
        ```lua
        处理后文本 = string.rtrim(处理前文本)
        ```
    
    - 参数及返回值  
        > - 处理前文本  
            文本型，需要去除右边空白字符的文本  
        > - 处理后文本  
            文本型，返回已经去除右边空白字符的文本  
    
    - 说明  
        > 去除文本右边空白字符  
        > 空白字符包括 `"\r"` `"\n"` `"\t"`  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 去除文本左右两边空白字符 (**string\.trim**)
    - 声明  
        ```lua
        处理后文本 = string.trim(处理前文本)
        ```
    
    - 参数及返回值  
        > - 处理前文本  
            文本型，需要去除左右两边空白字符的文本  
        > - 处理后文本  
            文本型，返回已经去除左右两边空白字符的文本  
    
    - 说明  
        > 去除文本左右两边空白字符  
        > 空白字符包括 `"\r"` `"\n"` `"\t"`  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 去除文本中所有的空白字符 (**string\.atrim**)
    - 声明  
        ```lua
        处理后文本 = string.atrim(处理前文本)
        ```
    
    - 参数及返回值  
        > - 处理前文本  
            文本型，需要去除所有的空白字符的文本  
        > - 处理后文本  
            文本型，返回已经去除所有的空白字符的文本  
    
    - 说明  
        > 去除文本所有的空白字符  
        > 空白字符包括 `"\r"` `"\n"` `"\t"`  
        
    - 示例  
        [`本章最后`](#扩展\-string\-示例代码)



---
<br />

- ### 去除掉文本前的 UTF8\-BOM (**string\.strip_utf8_bom**)
    - 声明  
        ```lua
        处理后文本 = string.strip_utf8_bom(处理前文本)
        ```
    
    - 参数及返回值  
        > - 处理前文本  
            文本型，需要剔除掉 UTF8\-BOM 字符的文本  
        > - 处理后文本  
            文本型，返回已经剔除掉 UTF8\-BOM 字符的文本  
    
    - 说明  
        > UTF8\-BOM 的表现形式是文档开头的三个看不见的字符 `"\xEF\xBB\xBF"` （在 Lua 源码中，字符串中 `\x` 开头，后面跟两位 16 进制数表示以该数字编码的单个字节。例如：`\x58` 表示 `X` 这个字符，可打印字符部分参考[《ASCII 编码》](https://baike.baidu.com/item/ASCII/309296)）  
        > **这个函数在 1\.1\.3\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        txt = "\xEF\xBB\xBFXXTouch"
        sys.alert(txt..', '..#txt) -- 输出 "XXTouch, 10"
        
        txt = string.strip_utf8_bom(txt)
        sys.alert(txt..', '..#txt) -- 输出 "XXTouch, 7"
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
    
        
    - 小知识  
        > UTF\-8 **不需要** BOM，尽管 Unicode 标准允许在 UTF\-8 中使用 BOM。  
        > 所以不含 BOM 的 UTF\-8 才是标准形式，在 UTF\-8 文件中放置 BOM 主要是微软的习惯（顺便提一下：把带有 BOM 的小端序 UTF\-16 称作「Unicode」而又不详细说明，这也是微软的习惯）。  
        > BOM（byte order mark）是为 UTF\-16 和 UTF\-32 准备的，用于标记字节序（byte order）。微软在 UTF\-8 中使用 BOM 是因为这样可以把 UTF\-8 和 ASCII 等编码明确区分开，但这样的文件在 Windows 之外的操作系统里会带来问题。（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  



---
<br />

- ### 生成随机字符串 (**string\.random**)
    - 声明  
        ```lua
        随机字符串 = string.random(字符池 [, 生成字符个数, 每字符的字节数 ])
        ```
    
    - 参数及返回值  
        > - 字符池  
            文本型，需要生成字符串的字典  
        > - 生成字符个数  
            整数型，可选参数，需要生成的随机字符串中的字符个数，默认 6  
        > - 每字符的字节数  
            整数型，可选参数，每个字符的长度，默认 1  
        > - 随机字符串  
            文本型，返回生成的随机字符串  
    
    - 说明  
        > 生成随机字符串，UTF\-8 编码的中文每个字符的长度为 3  
        
    - 示例  
        ```lua
        rs = string.random("qwertyuiopasdfghjklzxcvbnm", 20, 1)
        rs = string.random("一二三四五六七八九十", 20, 3)
        ```



---
<br />

- ### 比较两个版本号大小 (**string\.compare\_version**)
    - 声明
        ```lua
        比较结果 = string.compare_version(版本号甲, 版本号乙)
        ```
    
    - 参数及返回值
        > - 版本号甲, 版本号乙
            文本型，需要比较大小的两个版本号
        > - 比较结果
            整数型，版本号甲大于版本号乙返回 1，版本号甲小于版本号乙返回 \-1，版本号相等返回 0
    
    - 说明
        > 比较两个版本号字符串大小，遵守如下比较规则  
        > 使用点 \(\.\) 或减号 \(\-\) 或空格隔开的纯数字值  
        > 不同分隔符效果相等，多个分隔符连在一起被认为是一个分隔符    
        > 权值随分段从左至右逐步降低  
        > 遇到任何非法字符将截断不对比后面的内容  
        > 如果段数不等，则不够段数用 '0' 补齐对比  
        > 空字符串或非法串会被认为版本号是 '0'  
        > 例如 '1\.1' 与 '1\.1\.0' 是相等的两个版本号  
        > 例如 '1\.1' 与 '1\.1\-0' 是相等的两个版本号  
        > 例如 '1\.1' 与 '1\-1' 是相等的两个版本号  
        > 例如 '1\.0' 与 '1 0' \(1 和 0 之间有个空格\) 是相等的两个版本号  
        > 例如 '1\.0' 大于 '0\.99999'  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 这个函数在 1\.2\-10 版以上可以在 XUI 中使用  
        
    - 示例
        ```lua
        assert(string.compare_version("", "") == 0)
        assert(string.compare_version("1", "") == 1)
        assert(string.compare_version("", "1") == -1)
        assert(string.compare_version("1", "1") == 0)
        assert(string.compare_version("1.0", "1") == 0)
        assert(string.compare_version("1", "1.0") == 0)
        assert(string.compare_version("1.", "1") == 0)
        assert(string.compare_version("1", "1.") == 0)
        assert(string.compare_version("1.", "1.0") == 0)
        assert(string.compare_version("1.0", "1.") == 0)
        assert(string.compare_version("1.0", "1.0") == 0)
        assert(string.compare_version("1.0.0", "1.0.0") == 0)
        assert(string.compare_version("1.1", "1.0") == 1)
        assert(string.compare_version("1.0", "1.1") == -1)
        assert(string.compare_version("1.1", "1.10") == -1)
        assert(string.compare_version("1.2", "1.11") == -1)
        assert(string.compare_version("1.1", "1.1.1") == -1)
        assert(string.compare_version("1.2", "1.1.1") == 1)
        assert(string.compare_version("1.0", "0.99999") == 1)
        assert(string.compare_version("1.10.1", "1.10") == 1)
        assert(string.compare_version("1.2-4", "1.2-3") == 1)
        assert(string.compare_version("1.2-3", "1.2.3") == 0)
        assert(string.compare_version("1.2-4", "1.2.3.0") == 1)
        assert(string.compare_version("1.2-4", "1.2.3.10") == 1)
        assert(string.compare_version("1.2-4", "1.2.30.10") == -1)
        assert(string.compare_version("1.2-3", "1.2.4") == -1)
        assert(string.compare_version("2.2", "1.2") == 1)
        assert(string.compare_version("2.2", "10.2") == -1)
        assert(string.compare_version("2..2", "2.2") == 0)
        assert(string.compare_version("2.2.x.3", "2.2") == 0)
        assert(string.compare_version("x", "") == 0)
        ```



---
<br />

### 扩展 string 示例代码
```lua
-- 哈希校验
local str = "sozereal"
sys.alert('"'..str..'" 的 16 进制编码为: <'..str:to_hex()..'>')
sys.alert('<'..str:to_hex()..'> 转换成明文为: "'..str:to_hex():from_hex()..'"')
sys.alert('"'..str..'" 的 MD5 值是: '..str:md5())
sys.alert('"'..str..'" 的 SHA1 值是: '..str:sha1())
local binstr = "\0\1\2\3\4\5"
sys.alert('<'..binstr:to_hex()..'> 的 MD5 值是: '..binstr:md5())
sys.alert('<'..binstr:to_hex()..'> 的 SHA1 值是: '..binstr:sha1())

-- 数据加/解密
local msg = "\5\4\3\2\1\0"
local key = "sozereal"
local emsg = msg:aes128_encrypt(key)
local emsgb64 = emsg:base64_encode()
sys.alert('二进制数据<'..msg:to_hex()..'> \n 使用 AES128 算法 密钥 "'..key..'" 加密 值是: <'..emsg:to_hex()..'> \n base64 串为 "'..emsgb64..'"')
local tmp = emsgb64:base64_decode()
msg = tmp:aes128_decrypt(key)
sys.alert('"'..emsgb64..'" base64 解码后的数据为 <'..tmp:to_hex()..'> \n使用 AES128 算法 密钥 "'..key..'" 解密 值是: <'..msg:to_hex()..'>')

-- 字符串小工具
str = "  哈哈,he he,1,3,6  "
new = str:split(",") --将字符串str按照 `,` 分割并返回一个表
sys.alert(new[2])
sys.alert(str:rtrim()) -- 结果 "  哈哈,he he,1,3,6" ,删除字符串尾部的空白字符
sys.alert(str:ltrim()) -- 结果 "哈哈,he he,1,3,6  " ,删除字符串首部的空白字符
sys.alert(str:trim()) -- 结果 "哈哈,he he,1,3,6"    ,删除字符串首尾的空白字符
sys.alert(str:atrim()) -- 结果 "哈哈,hehe,1,3,6"    ,删除字符串所有的空白字符

```
**注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)





---
<br />
<br />
<br />

## \! HTTP 模块（http）

当前模块并不支持 HTTP/1\.0 或更低版本的 HTTP 协议，需求若无法使用当前模块完成，也可以使用 [`lcurl 模块`](#lcurl-模块) 来实现。

- ### 发起 GET 请求 (**http\.get**)
    - 声明  
        ```lua
        HTTP状态码, 返回头JSON文本, 返回主体 = http.get(URL [, 超时秒, 请求头, URL不ESCAPE ])
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，需要请求的 URL 地址，该方法默认会对 URL 进行百分号 escape 处理，如不需要可参考 **URL不ESCAPE** 参数说明  
        > - 超时秒  
            实数型，可选参数，请求超时时间，单位秒，默认 2  
        > - 请求头  
            表型，可选参数，发出的请求的头部信息，形式 \{field1 = value1, field2 = value2, \.\.\.\}，默认 \{\}  
        > - **URL不ESCAPE** \*1\.1\.3\-1 新增  
            布尔型，可选参数，true 表示不对 URL 进行 escape 直接请求，默认 false  
            对 URL 进行自定义 escape 可参考 [lcurl 模块](#lcurl-模块) 的 [easy:escape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:escape)、[easy:unescape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:unescape)  
        > - HTTP状态码  
            整数型，返回当次请求的 http 状态码，请求超时返回 \-1  
        > - 返回头JSON文本  
            文本型 或 nil，请求完成返回的 JSON 形式头部信息，请求超时返回 nil  
        > - 返回主体  
            字符串型 或 nil，请求完成返回的内容，请求超时返回 nil  
    
    - 说明  
        > 使用 HTTP/1\.1 协议的 GET 方法请求获取网络资源  
        > 这个函数不会将资源存储到磁盘上，如果需要下载较大的网络资源，建议使用 [http.download](#http\-文件下载\-httpdownload)  
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        > 若服务器协议版本为 HTTP/1\.0 或 HTTP/0\.9，可使用  
        ```lua
        返回主体 = httpGet(URL, 超时秒)
        ```
        > 这个方法替代
        
    - 示例  
        ```lua
        local code, res_headers, body = http.get("http://www.baidu.com", 1, {
            ["User-Agent"] = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)"; -- 模拟 IE8 的请求
            ["Cookie"] = "大佬你会不会啊？"; -- 顺带 Cookie 提交
        })
        if code==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(body) -- 输出百度首页的网页 HTML
        end
        ```
        
        ```lua
        -- 中文 URL 默认自动会 escape，包含中文的 URL 可直接像下面这样调用
        local c, h, r = http.get("https://www.xxtouch.com/测试文本.txt")
        if c==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(r) -- 输出内容
        end
        
        -- 1.1.3-1 新增 no_escape（URL不ESCAPE） 参数示例，下面的例子与上面例子等效
        local c, h, r = http.get("https://www.xxtouch.com/%E6%B5%8B%E8%AF%95%E6%96%87%E6%9C%AC.txt", 5, {}, true--[[这里]])
        if c==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(r) -- 输出内容
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        
    

    - #### http\.get 封装获取外网IP实例
    
        ```lua
        function get_ip()
        	local done = false
        	thread.dispatch(function()
        		while (true) do
        			if (done) then
        				sys.toast("", -1)
        				return
        			else
        				sys.toast("正在获取 IP 地址...", device.front_orien())
        			end
        			sys.msleep(2000)
        		end
        	end)
        	while (true) do
        		local c, h, b = http.get("http://ip.chinaz.com/getip.aspx?ts="..tostring(sys.rnd()), 60)
        		if (c==200) then
        			sys.toast("", -1)
        			done = true
        			return b:match('%d+%.%d+%.%d+%.%d+')
        		end
        	end
        end
        
        -- 将以上代码拷贝到自己的脚本最前面，然后在脚本中使用
        sys.alert(get_ip())
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`sys.toast`](#显示提示文字-systoast)、[`sys.msleep`](#毫秒级延迟-sysmsleep)、[`sys.rnd`](#产生一个随机数-sysrnd)、[`thread.dispatch`](#派发一个任务-threaddispatch)、[`device.front_orien`](#获取前台应用的画面方向-devicefrontorien)


---
<br />

- ### 发起 POST 请求 (**http\.post**)
    - 声明  
        ```lua
        HTTP状态码, 返回头JSON文本, 返回主体 = http.post(URL [, 超时秒, 请求头, 请求主体, URL不ESCAPE ])
        ```
    
    - 参数及返回值
        > - URL  
            文本型，需要请求的 URL 地址，该方法默认会对 URL 进行 escape 处理，如不需要可参考 **URL不ESCAPE** 参数说明  
        > - 超时秒  
            实数型，可选参数，请求超时时间，单位秒，默认 2  
        > - 请求头  
            表型，可选参数，发出的请求的头部信息，形式 \{field1 = value1, field2 = value2, \.\.\.\}，默认 \{\}  
        > - 请求主体  
            字符串型，可选参数，使用 post 发送出去的内容，默认是空字符串  
        > - **URL不ESCAPE** \*1\.1\.3\-1 新增  
            布尔型，可选参数，true 表示不对 URL 进行 escape 直接请求，默认 false  
            对 URL 进行自定义 escape 可参考 [lcurl 模块](#lcurl-模块) 的 [easy:escape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:escape)、[easy:unescape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:unescape)  
        > - HTTP状态码  
            整数型，返回当次请求的 http 状态码，请求超时返回 \-1  
        > - 返回头JSON文本  
            文本型 或 nil，请求完成返回的 JSON 形式头部信息，请求超时返回 nil  
        > - 返回主体  
            字符串型 或 nil，请求完成返回的内容，请求超时返回 nil  
    
    - 说明  
        > 使用 HTTP/1\.1 协议的 POST 方法发送数据到网络中  
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        > 若服务器协议版本为 HTTP/1\.0 或 HTTP/0\.9，可使用  
        ```lua
        返回主体 = httpPost(URL, 请求主体, 超时秒)
        ```
        > 这个方法替代
        
    - 示例  
        ```lua
        local code, res_headers, body = http.post("http://www.baidu.com", 1, {
            ["User-Agent"] = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)", -- 模拟 IE8 的请求
            ["Cookie"] = "大佬你会不会啊？"; -- 顺带 Cookie 提交
        }, "需要发送过去的数据")
        if code==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(body) -- 输出百度首页的网页html
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### HTTP 文件下载 (**http\.download**)
    - 声明  
        ```lua
        下载成败, 下载信息 = http.download(URL, 本地文件路径 [, 连接超时秒, 断点续传模式, 分块回调函数, 缓冲区尺寸 ])
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，远端文件地址  
        > - 本地文件路径  
            文本型，需要保存到的本地路径  
        > - 连接超时秒  
            实数型，可选参数，连接超时时间，单位秒，默认 10  
        > - 断点续传模式  
            布尔型，可选参数，是否需要支持断点续传，是为 true，否为 false，默认 false  
        > - 分块回调函数  
            * 函数型  
                * 可选参数，分块回调函数，每下载完一个分块都会回调一次这个函数，默认 空函数  
                * 分块回调函数第一个参数为当前下载的信息，回调函数返回 true 则打断这次下载  
        > - 缓冲区尺寸  
            整数型，可选参数，缓冲区大小字节数，默认自动最优配置  
        > - 下载成败  
            布尔型，连接是否成功  
        > - 下载信息  
            表型 或 文本型，如果连接成功则返回表型下载信息，否则返回连接失败原因文本描述  
    
    - 说明  
        ```lua
        -- 第二个返回值下载信息结构如下
        {
            resource_size = 远端资源总字节数,
            start_pos = 本次下载从资源的开始的位置,
            size_download = 本次下载的字节数,
            speed_download = 本次下载的速度（单位：字节/秒）,
        }
        ```
        > 这个函数适合大文件下载，在传输的过程中停止脚本可能会缓慢
        > **这个函数在 1\.1\.0\-1 版以上方可使用**
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**
        
        
    - 简单示例
        ```lua
        local done, info = http.download("http://192.168.31.13/1.zip", "/var/mobile/1.zip")
        if (done) then
            sys.alert("如果没有意外，已经下载好了")
        else
            sys.alert("连接失败："..info)
        end
        ```
        
    - 复杂示例
        ```lua
        local done, info = http.download("http://192.168.31.13/1.zip", "/var/mobile/1.zip", 10, true, function(binfo)
            local percent = math.floor(((binfo.start_pos + binfo.size_download) / binfo.resource_size) * 100)
            sys.toast("下载进度 "..percent.."%")
        end, 4096 * 1024)
        
        if (done) then
        	if (info.start_pos + info.size_download < info.resource_size) then
        	    sys.alert(
        	        "下载中断\n本次下载 "..info.size_download.." 字节"
        	        .."\n从第 "..info.start_pos.." 字节开始下载"
        	        .."\n平均速度为 "..math.floor(info.speed_download/1024).." kB/s"
        	        .."\n还有剩 "..(info.resource_size - (info.start_pos + info.size_download)).." 字节"
        	    )
        	else
        	    sys.alert(
        	        "下载完成\n本次下载 "..info.size_download.." 字节"
        	        .."\n从第 "..info.start_pos.." 字节开始下载"
        	        .."\n平均速度为 "..math.floor(info.speed_download/1024).." kB/s"
        	    )
        	end
        else
        	sys.alert("连接失败："..info)
        end
        
        ```
        
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`sys.toast`](#显示提示文字\-systoast)
        
    - 错误信息参考  
        **Requested range was not delivered by the server** 这个错误表示服务器可能不支持断点续传，将断点续传选项设为 false 即可  


---
<br />

- ### 发起 HEAD 请求 (**http\.head**)
    - 声明  
        ```lua
        HTTP状态码, 返回头JSON文本 = http.head(URL [, 超时秒, 请求头, URL不ESCAPE ])
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，需要请求的 URL 地址，该方法默认会对 URL 进行 escape 处理，如不需要可参考 **URL不ESCAPE** 参数说明  
        > - 超时秒  
            实数型，可选参数，请求超时时间，单位秒，默认 2  
        > - 请求头  
            表型，可选参数，发出的请求的头部信息，形式 \{field1 = value1, field2 = value2, \.\.\.\}，默认 \{\}  
        > - **URL不ESCAPE** \*1\.1\.3\-1 新增  
            布尔型，可选参数，true 表示不对 URL 进行 escape 直接请求，默认 false  
            对 URL 进行自定义 escape 可参考 [lcurl 模块](#lcurl-模块) 的 [easy:escape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:escape)、[easy:unescape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:unescape)  
        > - HTTP状态码  
            整数型，返回当次请求的 http 状态码，请求超时返回 \-1  
        > - 返回头JSON文本  
            文本型 或 nil，请求完成返回的 JSON 形式头部信息，请求超时返回 nil  
    
    - 说明  
        > 使用 HTTP/1\.1 协议的 HEAD 方法请求获取网络资源的头部信息  
        > HEAD 协议通常和 GET 请求会获得同样的返回头，但 HEAD 请求不会返回实际主体内容  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```lua
        local c, h = http.head("https://www.xxtouch.com/测试文本.txt")
        if c==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(h) -- 输出请求到的头信息
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


---
<br />

- ### 发起 DELETE 请求 (**http\.delete**)
    - 声明  
        ```lua
        HTTP状态码, 返回头JSON文本, 返回主体 = http.delete(URL [, 超时秒, 请求头, URL不ESCAPE ])
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，需要请求的 URL 地址，该方法默认会对 URL 进行 escape 处理，如不需要可参考 **URL不ESCAPE** 参数说明  
        > - 超时秒  
            实数型，可选参数，请求超时时间，单位秒，默认 2  
        > - 请求头  
            表型，可选参数，发出的请求的头部信息，形式 \{field1 = value1, field2 = value2, \.\.\.\}，默认 \{\}  
        > - **URL不ESCAPE** \*1\.1\.3\-1 新增  
            布尔型，可选参数，true 表示不对 URL 进行 escape 直接请求，默认 false  
            对 URL 进行自定义 escape 可参考 [lcurl 模块](#lcurl-模块) 的 [easy:escape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:escape)、[easy:unescape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:unescape)  
        > - HTTP状态码  
            整数型，返回当次请求的 http 状态码，请求超时返回 \-1  
        > - 返回头JSON文本  
            文本型 或 nil，请求完成返回的 JSON 形式头部信息，请求超时返回 nil  
        > - 返回主体  
            字符串型 或 nil，请求完成返回的内容，请求超时返回 nil  
    
    - 说明  
        > 使用 HTTP/1\.1 协议的 DELETE 方法请求获取网络资源，它通常用于删除一个网络资源，该协议一般会有权限验证  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```
        local c, h, r = http.delete("https://www.xxtouch.com/测试文本.txt")
        if c==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(r) -- 输出结果
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


---
<br />

- ### 发起 PUT 请求 (**http\.put**)
    - 声明  
        ```lua
        HTTP状态码, 返回头JSON文本, 返回主体 = http.put(URL [, 超时秒, 请求头, 请求主体, URL不ESCAPE ])
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，需要请求的 URL 地址，该方法默认会对 URL 进行 escape 处理，如不需要可参考 **URL不ESCAPE** 参数说明  
        > - 超时秒  
            实数型，可选参数，请求超时时间，单位秒，默认 2  
        > - 请求头  
            表型，可选参数，发出的请求的头部信息，形式 \{field1 = value1, field2 = value2, \.\.\.\}，默认 \{\}  
        > - 请求主体  
            字符串型，可选参数，使用 put 发送出去的内容，默认是空字符串  
        > - **URL不ESCAPE** \*1\.1\.3\-1 新增  
            布尔型，可选参数，true 表示不对 URL 进行 escape 直接请求，默认 false  
            对 URL 进行自定义 escape 可参考 [lcurl 模块](#lcurl-模块) 的 [easy:escape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:escape)、[easy:unescape](http://lua-curl.github.io/lcurl/modules/lcurl.html#easy:unescape)  
        > - HTTP状态码  
            整数型，返回当次请求的 http 状态码，请求超时返回 \-1  
        > - 返回头JSON文本  
            文本型 或 nil，请求完成返回的 JSON 形式头部信息，请求超时返回 nil  
        > - 返回主体  
            字符串型 或 nil，请求完成返回的内容，请求超时返回 nil  
    
    - 说明  
        > 使用 HTTP/1\.1 协议的 PUT 方法发送数据到网络中，它与 POST 用法一致  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
    - 示例  
        ```lua
        local code, res_headers, body = http.put("http://www.baidu.com", 1, {
            ["User-Agent"] = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)", -- 模拟 IE8 的请求
            ["Cookie"] = "大佬你会不会啊？"; -- 顺带 Cookie 提交
        }, "需要发送过去的数据")
        if code==200 then -- 如果返回的状态码是 HTTP_OK
            sys.alert(body) -- 输出百度首页的网页html
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


---
<br />


- ### 编码 HTTP URLENCODED 表单 (**http\.table_to_form_urlencoded**)
    - 声明  
        ```lua
        编码好的文本 = http.table_to_form_urlencoded(需要编码的表单)
        ```
    
    - 参数及返回值  
        > - 需要编码的表单  
            表型  
        > - 编码好的文本  
            文本型  
    
    - 说明  
        > **这个函数在 20250313 以后版本方可使用**  
        
    - 示例  
        ```lua
        form = http.table_to_form_urlencoded{
            num = 1,
            str = '你好',
            arr = {12, 34, '好'},
        }

        nLog(form) -- arr%5B0%5D=12&arr%5B1%5D=34&arr%5B2%5D=%E5%A5%BD&str=%E4%BD%A0%E5%A5%BD&num=1

        c, h, r = http.get('https://httpbin.org/get?'..form, 10, {}, true) -- 通过 GET Query 提交表单，URL 默认会自动 Escape，除非最后一个参数是 true
        nLog(r)

        c, h, r = http.post('https://httpbin.org/post', 10, {}, form) -- 通过 POST 提交表单
        nLog(r)
        ```


---
<br />
<br />
<br />

## \! FTP 模块（ftp）
- ### FTP 文件下载 (**ftp\.download**)
    - 声明  
        ```lua
        下载成败, 下载信息 = ftp.download(URL, 本地文件路径 [, 连接超时秒, 断点续传模式, 分块回调函数, 缓冲区尺寸 ])
        ```
    
    - 参数及返回值  
        > - URL  
            文本型，远端文件地址，账号及密码被包含在这一参数中  
        > - 本地文件路径  
            文本型，需要保存到的本地路径  
        > - 连接超时秒  
            实数型，可选参数，连接超时时间，单位秒，默认 10  
        > - 断点续传模式  
            布尔型，可选参数，是否需要支持断点续传，是为 true，否为 false，默认 false  
        > - 分块回调函数  
            * 函数型  
                * 可选参数，分块回调函数，每下载完一个分块都会回调一次这个函数，默认 空函数  
                * 分块回调函数第一个参数为当前下载的信息，回调函数返回 true 则打断这次下载  
        > - 缓冲区尺寸  
            整数型，可选参数，缓冲区大小字节数，默认自动最优配置  
        > - 下载成败  
            布尔型，连接是否成功  
        > - 下载信息  
            表型 或 文本型，如果连接成功则返回表型下载信息，否则返回连接失败原因文本描述  
    
    - 说明  
        ```lua
        -- 第二个返回值下载信息结构如下
        {
            resource_size = 远端资源总字节数,
            start_pos = 本次下载从资源的开始的位置,
            size_download = 本次下载的字节数,
            speed_download = 本次下载的速度（单位：字节/秒）,
        }
        ```
        > 这个函数适合大文件下载，在传输的过程中停止脚本可能会缓慢  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**  
        
        
    - 简单示例
        > 账号密码写在 URL 中，具体 URL 格式如下（中括号内是可选参数）
        ```lua
        ftp://[账号:密码@]地址[:端口]/路径
        ```
        > 账号或密码中包含 `@`、`:`、`/` 这三个字符可分别用 `%40`、`%3A`、`%2F`（若还有其它 URL 中不能包含的字符可使用 URLEncode 进行编码）
        > 例如账号是 ``havonz`` 密码是 ``11@@22`` 参考下例
        ```lua
        local done, info = ftp.download("ftp://havonz:11%40%4022@192.168.31.13/1.zip", "/var/mobile/1.zip")
        if (done) then
            sys.alert("如果没有意外，已经下载好了")
        else
            sys.alert("连接失败："..info)
        end
        ```
        
    - 复杂示例
        ```lua
        local done, info = ftp.download("ftp://havonz:123456@192.168.31.13/1.zip", "/var/mobile/1.zip", 10, true, function(binfo)
            local percent = math.floor(((binfo.start_pos + binfo.size_download) / binfo.resource_size) * 100)
            sys.toast("下载进度 "..percent.."%")
        end, 4096 * 1024)
        
        if (done) then
        	if (info.start_pos + info.size_download < info.resource_size) then
        	    sys.alert(
        	        "下载中断\n本次下载 "..info.size_download.." 字节"
        	        .."\n从第 "..info.start_pos.." 字节开始下载"
        	        .."\n平均速度为 "..math.floor(info.speed_download/1024).." kB/s"
        	        .."\n还有剩 "..(info.resource_size - (info.start_pos + info.size_download)).." 字节"
        	    )
        	else
        	    sys.alert(
        	        "下载完成\n本次下载 "..info.size_download.." 字节"
        	        .."\n从第 "..info.start_pos.." 字节开始下载"
        	        .."\n平均速度为 "..math.floor(info.speed_download/1024).." kB/s"
        	    )
        	end
        else
        	sys.alert("连接失败："..info)
        end
        
        ```
        
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`sys.toast`](#显示提示文字\-systoast)


---
<br />

- ### FTP 文件上传 (**ftp\.upload**)
    - 声明  
        ```lua
        上传成败, 上传信息 = ftp.upload(本地文件路径, URL [, 连接超时秒, 断点续传模式, 分块回调函数, 缓冲区尺寸 ])
        ```
    
    - 参数及返回值  
        > - 本地文件路径  
            文本型，本地文件路径  
        > - URL  
            文本型，需要上传到的远端地址，账号及密码被包含在这一参数中  
        > - 连接超时秒  
            实数型，可选参数，连接超时时间，单位秒，默认 10  
        > - 断点续传模式  
            布尔型，可选参数，是否需要支持断点续传，是为 true，否为 false，默认 false  
        > - 分块回调函数  
            * 函数型  
                * 可选参数，分块回调函数，每上传完一个分块都会回调一次这个函数，默认 空函数  
                * 分块回调函数第一个参数为当前上传的信息，回调函数返回 true 则打断这次上传  
        > - 缓冲区尺寸  
            整数型，可选参数，缓冲区大小字节数，默认自动最优配置  
        > - 上传成败  
            布尔型，连接是否成功  
        > - 上传信息  
            表型 或 文本型，如果连接成功则返回表型上传信息，否则返回连接失败原因文本描述  
    
    - 说明  
        ```lua
        -- 第二个返回值下载信息结构如下
        {
            resource_size = 本地文件总字节数,
            start_pos = 本次上传从本地文件的开始的位置,
            size_upload = 本次上传的字节数,
            speed_upload = 本次上传的速度（单位：字节/秒）,
        }
        ```
        > 这个函数适合大文件上传，在传输的过程中停止脚本可能会缓慢
        > **这个函数在 1\.1\.0\-1 版以上方可使用**
        > **这个函数可能会让出，在这个函数返回之前，其它的 [线程](#thread\-模块) 可能会得到运行机会**
        
        
    - 简单示例
        > 账号密码写在 URL 中，具体 URL 格式如下（中括号内是可选参数）
        ```lua
        ftp://[账号:密码@]地址[:端口]/路径
        ```
        > 账号或密码中包含 `@`、`:`、`/` 这三个字符可分别用 `%40`、`%3A`、`%2F`（若还有其它 URL 中不能包含的字符可使用 URLEncode 进行编码）
        > 例如账号是 ``havonz`` 密码是 ``11@@22`` 参考下例
        ```lua
        local done, info = ftp.upload("/var/mobile/1.zip", "ftp://havonz:11%40%4022@192.168.31.13/1.zip")
        if (done) then
            sys.alert("如果没有意外，已经上传好了")
        else
            sys.alert("连接失败："..info)
        end
        ```
        
    - 复杂示例
        ```lua
        local done, info = ftp.upload("/var/mobile/1.zip", "ftp://havonz:123456@192.168.31.13/1.zip", 10, true, function(binfo)
            local percent = math.floor(((binfo.start_pos + binfo.size_upload) / binfo.resource_size) * 100)
            sys.toast("上传进度 "..percent.."%")
        end, 4096 * 1024)
        
        if (done) then
        	if (info.start_pos + info.size_upload < info.resource_size) then
        	    sys.alert(
        	        "上传中断\n本次上传 "..info.size_upload.." 字节"
        	        .."\n从第 "..info.start_pos.." 字节开始上传"
        	        .."\n平均速度为 "..math.floor(info.speed_upload/1024).." kB/s"
        	        .."\n还有剩 "..(info.resource_size - (info.start_pos + info.size_upload)).." 字节"
        	    )
        	else
        	    sys.alert(
        	        "上传完成\n本次上传 "..info.size_upload.." 字节"
        	        .."\n从第 "..info.start_pos.." 字节开始上传"
        	        .."\n平均速度为 "..math.floor(info.speed_upload/1024).." kB/s"
        	    )
        	end
        else
        	sys.alert("连接失败："..info)
        end
        
        ```
        
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`sys.toast`](#显示提示文字\-systoast)


---
<br />
<br />
<br />

## JSON 模块（json）

JSON \(JavaScript Object Notation, JS 对象标记\) 是一种轻量级的数据交换格式。详情见：http://www.json.org/  

该 JSON 模块 完全等同于 [LuaCJSON 扩展库](#luacjson-扩展库)，非原创模块  

- ### 将 Lua 值转成 JSON 字符串 (**json\.encode**)
    - 声明  
        ```
        JSON文本, 错误信息 = json.encode(值)
        
        ```
    
    - 参数及返回值  
        > - 值  
            表型 或 文本型 或 数值型 或 布尔型 或 json\.null，需要转换成 json 文本的 lua 值  
        > - **JSON文本**  
            文本型 或 nil，转换成功则返回一个 json 字符串，否则返回 nil  
        > - 错误信息  
            文本型 或 nil， 转换失败 **JSON文本** 的值为 nil 的情况下，这个返回值则是具体的错误信息  
    
    - 说明  
        > 将 lua 中的数据值转成 json 形式可以方便与其它语言交互传输  
        > **注意** 不是任何 lua 值都可以转成 json。例如：用户数据或函数及包含用户数据或函数的表  
        
    - 示例  
        ```lua
        local tb = {
            ["膜"] = "图样图森破桑叹斯乃衣服",
            ["蛤"] = "比你们高到不知道哪里去了",
            moha = {
                1,0,0,4,6,9,5,1,0,0,
            },
            nullvalue = json.null,
        }
        local jsonstr = json.encode(tb)
        sys.alert(jsonstr)
        
        local tmp = json.decode(jsonstr)
        sys.alert(tmp.moha[5])
        sys.alert(tostring(tmp.nullvalue))
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 将 JSON 字符串转换成 Lua 值 (**json\.decode**)
    - 声明  
        ```
        值, 错误信息 = json.decode(JSON文本)
        ```
    
    - 参数及返回值  
        > - JSON文本  
            文本型，需要转换成表的 json 文本  
        > - **值**  
            表型 或 文本型 或 数值型 或 布尔型 或 json\.null 或 nil，转换成功则返回一个与 json 字符串结构相对应的 lua 值，否则返回 nil  
        > - 错误信息  
            文本型 或 nil， 转换失败 **值** 为 nil 的情况下，这个返回值则是具体的错误信息  
    
    - 说明  
        > 将 json 文本转换成 lua 的中对应的数据值  
        
    - 示例  
        ```lua
        print(json.decode('true'))
        print(json.decode('17'))
        print(json.decode('"哈哈"'))
        print(json.decode('null'))
        print(json.decode(''))
        table.deep_print(json.decode('{}'))
        table.deep_print(json.decode('{"娘子":"啊哈","你好":"世界"}'))
        table.deep_print(json.decode('[]'))
        table.deep_print(json.decode('[1, 0, 0, "4695100"]'))
        
        sys.alert(print.out())
        ```
        **注**：上述代码中使用了非本章函数 [`table.deep_print`](#深打印一个表-tabledeepprint) 、[`print.out`](#打印内容到缓冲区-print)、[`sys.alert`](#弹出系统提示\-sysalert)
    
        ```lua
        -- 使用 json.decode 转换 Unicode 编码为文字
        sys.alert(json.decode([["\u82cf\u6cfd"]]))
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


---
<br />

- ### JSON 中的 NULL 常量 (**json\.null**)
    - 声明  
        ```
        json.null
        ```
        
    - 说明  
        > 这不是一个函数，是一个常量。以文本形式打印为 “`userdata: 0x0`”  
        > 它用于表示 json 中对应的 null 值  
        > **为什么它有必要存在** 因为 lua table 中的 nil 会被判定为不存在，转换成 json 之后，key 会消失，所以需要一个特定的值来表示这个 null  
        
    - 示例  
        ```lua
        local tb = json.decode('{"nullvalue":null}')
        if tb['nullvalue'] == json.null then
            sys.alert(json.null)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />
<br />
<br />

## PLIST 文件读写模块（plist）
- ### 读取 plist 文件 (**plist\.read**)
    - 声明  
        ```lua
        plist = require("plist") -- 需要先引入 plist 模块
        关联表 = plist.read(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，需要读取的 plist 文件的绝对路径  
        > - 关联表  
            表型 或 nil，读取成功则返回 plist 的树形结构对应的一个表，否则返回 nil  
    
    - 说明  
        > 读取 plist 文件转换成表  
        
    - 示例  
        ```lua
        local plist = require("plist")
        local plfilename = "/var/mobile/Library/Caches/com.apple.mobile.installation.plist" --设置plist路径
        local tmp2 = plist.read(plfilename)           --读取plist文件内容并返回一个TABLE
        sys.alert(tmp2.Metadata.ProductBuildVersion)  --显示ProductBuildVersion的键值
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 写入 plist 文件 (**plist\.write**)
    - 声明  
        ```lua
        plist = require("plist") -- 需要先引入 plist 模块
        plist.write(文件路径, 关联表[, with_binary])
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，需要写入的 plist 文件的绝对路径  
        > - 关联表  
            表型，这个表的树形结构将会转换成 plist  
        > - with_binary  
            boolean, If this parameter is set to true, the output will be in binary plist format  
    
    - 说明  
        > 将一个表的树形结构写入到 plist 文件中  
        > **请注意不要传入有引用环的表，会导致脚本无法终止甚至卡死**  
        > **使用该函数操作文件会导致文件所有者变 root，如果需要更改用户级应用的 plist 需要在修改后将权限修正方可生效**  
        
    - 示例  
        ```lua
        local plist = require("plist")
        local plfilename = "/var/mobile/Library/Caches/com.apple.mobile.installation.plist" --设置plist路径
        local tmp2 = plist.read(plfilename)                --读取plist文件内容并返回一个TABLE
        tmp2["Metadata"]["ProductBuildVersion"] = "havonz" --将表中ProductBuildVersion键值改为havonz
        plist.write(plfilename, tmp2)                      --将修改后的表写入PLIST文件
        os.execute("chown mobile:mobile "..plfilename)     -- 修正文件权限
        os.execute("chmod 644 "..plfilename)
        ```



---
<br />

- ### Plist Dump Table (**plist\.dump**)
    - Declaration  
        ```lua
        plist = require("plist")
        data = plist.dump(table[, with_binary])
        ```
    
    - Parameters and return values  
        > - table  
            table, The tree structure of this table will be converted to plist data  
        > - with_binary  
            boolean, If this parameter is set to true, the output will be in binary plist format  
        > - data  
            string, plist data  
    
    - Explanation  
        > Converts the tree structure of a table into plist data  
        
    - Example  
        ```lua
        local plist = require("plist")
        nLog(plist.dump({a = 1}))
        ```


---
<br />

- ### Plist Load Data (**plist\.load**)
    - Declaration  
        ```lua
        plist = require("plist")
        table = plist.load(data)
        ```
    
    - Parameters and return values  
        > - data  
            string, This parameter is the plist data to be converted into a table  
        > - table  
            table, Table from the input plist data  
    
    - Explanation  
        > Convert the plist data to a table  
        
    - Example  
        ```lua
        local plist = require("plist")
        tab = plist.load([[
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>a</key>
            <integer>1</integer>
        </dict>
        </plist>
        ]])
        ```


---
<br />
<br />
<br />
## 小工具模块（utils）

- ### 给通讯录添加一个或多个联系人 (**utils\.add\_contacts**)
    - 声明  
        ```lua
        success = utils.add_contacts({
        	{
        		firstName = "姓1",
        		lastName = "名1",
        		phoneNumbers = {
        			"联系人1号码1",
        			"联系人1号码2",
        		},
        		emails = {
        		    "联系人1邮箱1",
        		    "联系人1邮箱2",
        		},
        	},
        	{
        		firstName = "姓2",
        		lastName = "名2",
        		phoneNumbers = {
        			"联系人2号码1",
        			"联系人2号码2",
        		},
        		emails = {
        		    "联系人2邮箱1",
        		    "联系人2邮箱2",
        		},
        	},
        	...
        })
        ```
    
    - 参数及返回值  
        > - firstName  
            文本型，联系人姓  
        > - lastName  
            文本型，联系人名  
        > - phoneNumbers  
            表型，这个人的号码列表  
        > - emails  
            表型，这个人的邮箱号列表  
        > - success  
            布尔型，添加成功返回 true，失败返回 false  
    
    - 说明  
        > 将一个或多个联系人记录添加到系统通讯录  
        > **注意：大批量导入很慢，特大批量导入会导致注销**  
        
    - 示例  
        ```lua
        utils.add_contacts({
        	{
        		firstName = "小",
        		lastName = "明",
        		phoneNumbers = {
        			"13800001111",
        			"13800002222",
        		},
        		emails = {
        		    "xiaoming@qq.com",
        		    "xiaoming@163.com",
        		},
        	},
        	{
        		firstName = "小",
        		lastName = "红",
        		phoneNumbers = {
        			"13800003333",
        			"13800004444",
        		},
        		emails = {
        		    "xiaohong@qq.com",
        		    "xiaohong@163.com",
        		},
        	},
        })
        ```



---
<br />

- ### 删除通讯录所有联系人 (**utils\.remove\_all\_contacts**)
    - 声明  
        ```lua
        操作成败 = utils.remove_all_contacts()
        ```
    
    - 参数及返回值  
        > - 操作成败  
            布尔型，删除成功返回 true，失败返回 false  
    
    - 说明  
        > 删除通讯录所有联系人  
        > 联系人很多的时候会需要消耗一些时间  
        
    - 示例  
        ```lua
        utils.remove_all_contacts()
        ```



---
<br />

- ### ~~打开扫码器 (**utils\.open\_code\_scanner**)~~
    - 声明  
        ```lua
        打开成败 = utils.open_code_scanner()
        ```
    
    - 参数及返回值  
        > - 打开成败  
            布尔型，相机打开成功会返回 true，否则返回 false  
    
    - 说明  
        > **iOS 9 以上的 iPad 无法开启扫码器**  
        > 打开条码/二维码扫描器，会启动相机，与所有需要用到摄像头的应用不能同时使用  
        > 这个函数调用不会返回扫描的结果  
        > 扫描器的结果将通过 [系统消息](#系统回调消息) [`xxtouch.scan_code_callback](#扫码结果回调消息) 传回  
        
    - 示例  
        [`扫码消息回调示例`](#扫码结果回调消息)
        ```lua
        -- 简易二维码扫描器演示
        
        proc_queue_clear("xxtouch.scan_code_callback") -- 清空消息队列
        local success = utils.open_code_scanner()      -- 打开扫码相机
        if not success then
        	sys.alert("可以于 “设置-通用-访问限制” 中取消 “相机” 的访问限制", 0, "无法访问系统相机")
        	return
        end
        
        local w, h = screen.size()
        webview.show({ -- 屏幕上方创建一个半透明的条
        	html = [[<html>
        	<h2><center>二维码置入镜头范围</center></h2>
        	</html>]],
        	x = 0, y = 0,
        	width = w, height = 100,
        	alpha = 0.2, opaque = false,
        	animation_duration = 0.2,
        })
        
        while (true) do -- 循环等待消息
        	local ret = proc_queue_pop("xxtouch.scan_code_callback")
        	if (ret ~= "") then
        		local rt = json.decode(ret)
        		if (rt.type == "org.iso.QRCode") then
        			utils.close_code_scanner()
        			webview.show({
        				x = 0, y = 0,
        				width = 0, height = 0,
        				animation_duration = 0.2, opaque = false,
        			})
        			local choice = sys.alert(rt.string, 0, "扫描到二维码内容",
									        "取消", "拷贝", "转存相册")
        			if (choice == 1) then
        				pasteboard.write(rt.string)
        			elseif (choice == 2) then
        				utils.qr_encode(rt.string, {
        					size = 320,
        					fill_color = 0xff409bff,
        					shadow_color = 0xff308bef,
        				}):save_to_album()
        				sys.alert("已经保存到相册")
        			end
        			break
        		else
        			sys.toast(
        				"扫描到条码："..rt.type.."\n"..
        				"条码内容为："..rt.string
        			)
        		end
        	end
        	sys.msleep(10)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`proc_queue_clear`](#从进程队列词典中弹出所有值\-procqueueclear)、[`proc_queue_pop`](#从进程队列词典中弹出一个值-procqueuepop)、[`json.decode`](#将-json-字符串转换成-lua-值-jsondecode)、[`:save_to_album`](#保存图片对象到相册\-savetoalbum)、
        [`pasteboard.write`](#写内容进剪贴板-pasteboardwrite)、[`webview.show`](#展现一个-webview-webviewshow)、[`screen.size`](#获取屏幕尺寸-screensize)



---
<br />

- ### ~~关闭扫码器 (**utils\.close\_code\_scanner**)~~
    - 声明  
        ```lua
        utils.close_code_scanner()
        ```
    
    - 说明  
        > 关闭条码/二维码扫描器  
        > iOS 9 以上不再有效  
        
    - 示例  
        [`utils.open_code_scanner 示例`](#打开扫码器-utilsopencodescanner)


---
<br />

- ### 将文本编码成二维码图片 (**utils\.qr\_encode**)
    - 声明  
        ```lua
        图像 = utils.qr_encode(文本内容[, {
            size = 尺寸,
            fill_color = 填充颜色,
            shadow_color = 阴影颜色,
        }])
        ```
    
    - 参数及返回值  
        > - 文本内容  
            文本型，需要编码成二维码的文本内容  
        > - size  
            整数型，需要编码成二维码的边长，默认 320  
        > - fill\_color  
            整数型，填充二维码图像的颜色，默认 0xff000000（黑色不透明）  
        > - shadow\_color  
            整数型，二维码阴影，默认 0x00000000（完全透明）  
        > - 图像  
            图片对象，返回生成的二维码图片对象  
    
    - 说明  
        > 将文本编码成一个指定尺寸背景色透明的二维码图片  
        
    - 示例  
        - [`utils.open_code_scanner 示例`](#打开扫码器-utilsopencodescanner)
        
        - 生成一个尺寸为 320 蓝色的二维码存到相册
            ```lua
            local img = utils.qr_encode("XXTouch 真棒", {
    			size = 320,
    			fill_color = 0xff409bff,
    			shadow_color = 0xff308bef,
    		})
            img:save_to_album()
            ```
            **注**：上述代码中使用了非本章函数 [`:save_to_album`](#保存图片对象到相册\-savetoalbum)
        
        - 微信等 App 无法识别透明色、深色背景的二维码，可以使用 [`:replace_color`](#颜色替换-replacecolor) 将背景色替换成白色以解决：
            ```lua
            local img = utils.qr_encode("XXTouch 真棒", {
    			size = 320,
    			fill_color = 0xff409bff,
    		})
    		img:replace_color(0x00000000, 0xffffffff) -- 透明色替换成白色
            img:save_to_album()
            ```
            **注**：上述代码中使用了非本章函数 [`:replace_color`](#颜色替换-replacecolor)、[`:save_to_album`](#保存图片对象到相册\-savetoalbum)
        



---
<br />

- ### 获得当前脚本的启动参数 (**utils\.launch\_args**)
    - 声明  
        ```lua
        启动参数关联表 = utils.launch_args()
        ```
    
    - 参数及返回值  
        > - 启动参数关联表  
            表型，返回一个用于描述当次启动的参数表，结构可以自行用 [table.deep_print](#深打印一个表-tabledeepprint) 打印查看  
    
    - 说明  
        > **在 1\.1\.0\-1 版或以上版本 App 内启动有额外的参数**  
        > 获得当前脚本的启动参数，推荐配合 [Activator](http://cydia.saurik.com/package/libactivator/) 激活脚本  
        
    - 示例  
        ```lua
        sys.alert(table.deep_print(utils.launch_args()))
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示-sysalert)、[`table.deep_print`](#深打印一个表\-tabledeepprint)
        
        ```lua
        -- 获取当前脚本文件路径（注：不是任何情况下脚本都有一个文件路径）
        sys.alert("当前的脚本路径是："..tostring(utils.launch_args().path))
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示-sysalert)、[tostring](http://cloudwu.github.io/lua53doc/manual.html#pdf-tostring)



---
<br />

- ### 判断当前脚本是否从 App 内启动 (**utils\.is\_launch\_via\_app**)
    - 声明  
        ```lua
        是否从App内启动 = utils.is_launch_via_app()
        ```
    
    - 参数及返回值  
        > - 是否从App内启动  
            布尔型，如果当前脚本是从 App 内的启动按钮启动，则返回 true，否则返回 false  
    
    - 说明  
        > 判断当前脚本是否从 App 内的启动按钮启动  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        [`dialog:load`](#在不弹出对话框的情况下获得对话框配置-load)



---
<br />

- ### 导入一个视频文件到相册 (**utils\.video\_to\_album**)
    - 声明  
        ```lua
        utils.video_to_album(视频文件名)
        ```
    
    - 参数及返回值  
        > - 视频文件名  
            文本型，视频文件的文件名，支持的格式有 mp4、m4v、mov  
            
    - 说明  
        > **这个函数在 1\.1\.2\-1 版以上方可使用**  
        > 将 mp4、m4v、mov 视频保存到相册  
        
    - 示例  
        ```lua
        utils.video_to_album("/var/mobile/1.mp4")
        ```



---
<br />

- ### 生成一个 UUID (**utils.gen_uuid**)
    - 声明
        - `uuid` = utils.gen_uuid()

    - 返回值
        - `uuid` : `string`  

    - 说明
        > **软件版本在 1.3.8 或以上方可使用**  

    - 示例
        ```lua
        nLog(utils.gen_uuid())
        ```


---
<br />
<br />
<br />

## 文件操作模块（file）
- ### 判断一个文件或目录是否存在 (**file\.exists**)
    - 声明  
        ```lua
        存在信息 = file.exists(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件或目录绝对路径  
        > - 存在信息  
            * false 或 "file" 或 "directory"  
                * false，路径不存在  
                * "file"， 路径是一个文件  
                * "directory"， 路径是一个目录  
    
    - 说明  
        > 用于判断一个路径是文件还是目录还是不存在  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        if file.exists("/var/mobile/1.zip") then
            sys.alert("`/var/mobile/1.zip` 存在")
        else
            sys.alert("`/var/mobile/1.zip` 不存在")
        end
        
        if file.exists("/var/mobile/1.zip")=="file" then
            sys.alert("`/var/mobile/1.zip` 存在并且是个文件")
        else
            sys.alert("`/var/mobile/1.zip` 不是文件")
        end
        
        if file.exists("/var/mobile/123/")=="directory" then
            sys.alert("`/var/mobile/123/` 存在并且是个目录")
        else
            sys.alert("`/var/mobile/123/` 不是目录")
        end
        
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

- ### 获取目录所有文件名列表 (**file\.list**)
    - 声明  
        ```lua
        文件列表 = file.list(文件路径[, 深层完整遍历])
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，目录绝对路径  
        > - 深层完整遍历
            布尔型，可选参数，20250313 新增，用于控制是否递归获取子目录文件完全路径列表，默认为 false
        > - 文件列表  
            顺序表型 或 nil，如果目录不存在或路径是一个文件则返回 nil，否则返回目录文件列表  
    
    - 说明  
        > 获取目录所有文件名列表  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        local list = file.list("/var/mobile/")
        if list then
            print("目录 `/var/mobile/` 中有"..#list.."个文件或目录")
            for _, name in ipairs(list) do
                print(name)
            end
            sys.alert(print.out())
        else
            sys.alert("`/var/mobile/` 不是目录")
        end
        ```
        深层完整遍历示例（20250313 以后版本方可使用）
        ```lua
        -- 完整文件路径列表 = file.list(文件路径, 深层完整遍历)
        -- 获取一个目录的文件名列表，第二个参数用于控制是否递归获取子目录文件完全路径列表，默认为 false
        list = file.list("/var/mobile/Media/1ferver", true)
        nLog(list)
        --[[
        可能输出
        { -- table: 0xc4cc58a30
            [1] = "/var/mobile/Media/1ferver/snippets/syntax - do __ end.snippet",
            [2] = "/var/mobile/Media/1ferver/snippets/app - app.uninstall(bid).snippet",
            [3] = "/var/mobile/Media/1ferver/snippets/test - snippet.snippet",
            ...
        }
        --]]
        ```

---
<br />

- ### 删除文件或目录 (**file\.remove**)
    - 声明  
        ```lua
        操作成败, 错误信息 = file.remove(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型  
        > - 操作成败, 错误信息  
            布尔型，成功返回 true，失败返回 (false, 错误信息)  
    
    - 说明  
        > 删除一个文件或目录  
        > **这个函数在 20250313 以后的版本方可使用**  
        
    - 示例  
        ```lua
        ok, err = file.remove(XXT_SCRIPTS_PATH.."/1.zip")
        if not ok then
            sys.alert('删除失败：'..err)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 拷贝文件或目录 (**file\.copy**)
    - 声明  
        ```lua
        操作成败, 错误信息 = file.copy(源路径, 目标路径)
        ```
    
    - 参数及返回值  
        > - 源路径  
            文本型  
        > - 目标路径  
            文本型  
        > - 操作成败, 错误信息  
            布尔型，成功返回 true，失败返回 (false, 错误信息)  
    
    - 说明  
        > 复制一个文件或目录 源路径 到 目标路径  
        > **这个函数在 20250313 以后的版本方可使用**  
        
    - 示例  
        ```lua
        ok, err = file.copy(XXT_SCRIPTS_PATH..'/1.zip', XXT_SCRIPTS_PATH..'/2.zip')
        if not ok then
            sys.alert('拷贝失败：'..err)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 移动文件或目录 (**file\.move**)
    - 声明  
        ```lua
        操作成败, 错误信息 = file.move(源路径, 目标路径)
        ```
    
    - 参数及返回值  
        > - 源路径  
            文本型  
        > - 目标路径  
            文本型  
        > - 操作成败, 错误信息  
            布尔型，成功返回 true，失败返回 (false, 错误信息)  
    
    - 说明  
        > 移动一个文件或目录 源路径 到 目标路径  
        > **这个函数在 20250313 以后的版本方可使用**  
        
    - 示例  
        ```lua
        ok, err = file.move(XXT_SCRIPTS_PATH..'/1.zip', XXT_SCRIPTS_PATH..'/2.zip')
        if not ok then
            sys.alert('拷贝失败：'..err)
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 查找文件或目录 (**file\.find**)
    - 声明  
        ```lua
        文件列表 = file.find(匹配模式)
        ```
    
    - 参数及返回值  
        > - 匹配模式  
            表型 | 文本型  
        > - 文件列表  
            表型，返回找到的文件名列表  
    
    - 说明  
        > 使用通配符模式或 Lua 精确匹配搜索文件或目录，返回匹配的文件名列表。  
        > 如果 `匹配模式` 是字符串，则使用通配符模式匹配，通配符模式匹配仅支持 \*、?、\[\.\.\.\] 这三种通配符。  
        > 如果 `匹配模式` 是表，则使用 Lua 精确匹配。  
        > 使用通配符模式或 Lua 精确匹配搜索文件或目录，返回匹配的文件名列表。  
        > **这个函数在 20250416 以后的版本方可使用**  
        
    - 示例  
        简单通配符模式
        ```lua
        -- 简单通配符模式，仅支持 * ? [...] 三种基本通配符
        -- * 表示匹配任意长度任意字符（长度也可以是 0）
        -- ? 表示匹配单个任意字符
        -- [...]  表示匹配单个中括号里的任意字符，例如 [abc]haha.txt 表示 ahaha.txt bhaha.txt chaha.txt 都匹配
        -- [!...] 表示匹配单个非中括号里的任意字符，例如 [!abc]haha.txt 表示 ahaha.txt bhaha.txt chaha.txt 不匹配，其它单个字符例如 xhaha.txt 才能匹配
        local results = file.find("/private/var/mobile/Containers/Shared/AppGroup/*/Library/Preferences/*.plist")
        ```
        精确通配模式
        ```lua
        -- 精确 Lua 模式匹配模式
        -- 精确匹配使用 Lua 表分段构造匹配模式，字符串为字面量判断，模式匹配可以使用返回真假的函数来决定当前分段是否有效
        local results = file.find{ --<--- 注意这里是大括号
            "/private/var/mobile/Containers/Shared/AppGroup/", -- 普通字符串不需要模式匹配
            function(s) return s:match("^[A-F0-9]+%-[A-F0-9]+%-[A-F0-9]+%-[A-F0-9]+%-[A-F0-9]+$") end, -- 使用函数匹配当前分段
            "/Library/Preferences/",
            function(s) return s:match("%.plist$") end, -- 使用函数匹配当前分段
        }
        -- 精确 Lua 模式匹配模式也可使用大括号包裹单个字符串以构造一个简易模式匹配函数
        local results = file.find{ --<--- 注意这里是大括号
            "/private/var/mobile/Containers/Shared/AppGroup/", -- 普通字符串不需要模式匹配
            {"^[A-F0-9]+%-[A-F0-9]+%-[A-F0-9]+%-[A-F0-9]+%-[A-F0-9]+$"}, -- 使用表包裹单个字符串表示这是一个需要使用模式匹配的分段
            "/Library/Preferences/", -- 普通字符串不需要模式匹配
            {"%.plist$"}, -- 使用表包裹单个字符串表示这是一个需要使用模式匹配的分段
        }
        ```

---
<br />

- ### 获得一个文件的尺寸 (**file\.size**)
    - 声明  
        ```lua
        尺寸 = file.size(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 尺寸  
            整数型 或 nil，如果文件不存在或文件名是一个目录则返回 nil，否则返回文件尺寸（单位: 字节）  
    
    - 说明  
        > 获得一个文件的尺寸  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        local fsize = file.size("/var/mobile/1.zip")
        if fsize then
            sys.alert("`/var/mobile/1.zip` 的尺寸为："..fsize.."字节")
        else
            sys.alert("`/var/mobile/1.zip` 不是文件")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 读取一个文件中的所有数据 (**file\.reads**)
    - 声明  
        ```lua
        内容 = file.reads(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 内容  
            字符串型 或 nil，文件不存在返回 nil，否则返回整个文件的数据  
    
    - 说明  
        > 读取一个文件中的所有数据  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        local data = file.reads("/var/mobile/1.zip")
        if data then
            sys.alert("`/var/mobile/1.zip` 的尺寸为："..#data.."字节")
        else
            sys.alert("`/var/mobile/1.zip` 不是文件")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 将数据覆盖写入到文件 (**file\.writes**)
    - 声明  
        ```lua
        写入成败 = file.writes(文件路径, 待写入内容)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 待写入内容  
            字符串型，需要写入的数据  
        > - 写入成败  
            布尔型，操作成功返回 true，操作失败返回 false  
    
    - 说明  
        > 将数据覆盖写入到文件，文件不存在会创建文件，目录不存在会返回 false  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        local success = file.writes("/var/mobile/1.txt", "苟")
        if success then
            sys.alert("写入成功")
        else
            sys.alert("写入失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 将数据追加到文件末尾 (**file\.appends**)
    - 声明  
        ```lua
        操作成败 = file.appends(文件路径, 待追加内容)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 待追加内容  
            字符串型，需要追加写入的数据  
        > - 操作成败  
            布尔型，操作成功返回 true，操作失败返回 false  
    
    - 说明  
        > 将数据追加到文件末尾，文件不存在会创建文件，目录不存在会返回 false  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        local success = file.appends("/var/mobile/1.txt", "利国家生死矣")
        if success then
            sys.alert("写入成功")
        else
            sys.alert("写入失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 统计一个文本文件的总行数 (**file\.line\_count**)
    - 声明  
        ```lua
        行数 = file.line_count(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行数  
            整数型 或 nil，返回文件总行数，空文件将返回 0，文件不存在返回 nil  
    
    - 说明  
        > 统计一个文本文件的总行数，空文件将返回 0  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        
    - 示例  
        ```lua
        local linecount = file.line_count("/var/mobile/1.txt")
        if linecount then
            sys.alert("`/var/mobile/1.txt` 一共有 "..linecount.." 行")
        else
            sys.alert("`/var/mobile/1.txt` 不是文件")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 获取一个文本文件指定行的数据 (**file\.get\_line**)
    - 声明  
        ```lua
        行内容 = file.get_line(文件路径, 行号)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行号  
            整数型，指定行号，0 为最后一行 \+1，负数则为倒数行号  
        > - 行内容  
            字符串型 或 nil，行数不够返回空字符串，文件不存在返回 nil  
    
    - 说明  
        > 获取一个文本文件指定行的数据  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  
        
    - 常见问题
        > 如果读取到文本的第一行包含不可见字符，请检查是否处理了 UTF8\-BOM，可使用 [`string.strip_utf8_bom`](#去除掉文本前的-utf8-bom-stringstriputf8bom) 剔除  
        
    - 示例  
        ```lua
        local data = file.get_line("/var/mobile/1.txt", 1)
        if data then
            data = string.strip_utf8_bom(data) -- 处理掉可能存在的 UTF8-BOM
            sys.alert("`/var/mobile/1.txt` 第一行的内容是 "..data)
        else
            sys.alert("`/var/mobile/1.txt` 不是文件")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`string.strip_utf8_bom`](#去除掉文本前的-utf8-bom-stringstriputf8bom)  

---
<br />

- ### 设置文本文件指定行的内容 (**file\.set\_line**)
    - 声明  
        ```lua
        写入成败 = file.set_line(文件路径, 行号, 待写入内容)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行号  
            整数型，指定行号，0 为最后一行 \+1，负数则为倒数行号  
        > - 待写入内容  
            字符串型，需要设置为指定行的数据  
        > - 写入成败  
            布尔型，操作成功返回 true，操作失败返回 false  
    
    - 说明  
        > 设置文本文件指定行的内容，行数不够用空行补足，文件不存在会创建文件，目录不存在会返回 false  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  

    - 示例  
        ```lua
        local success = file.set_line("/var/mobile/1.txt", 3, "哈哈哈")
        if success then
            sys.alert("操作成功")
        else
            sys.alert("操作失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 在文本文件指定行前插入内容 (**file\.insert\_line**)
    - 声明  
        ```lua
        写入成败 = file.insert_line(文件路径, 行号, 待插入的内容)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行号  
            整数型，指定行号，0 为最后一行 \+1，负数则为倒数行号  
        > - 待插入的内容  
            字符串型，需要插入到指定行前的数据  
        > - 写入成败  
            布尔型，操作成功返回 true，操作失败返回 false  
    
    - 说明  
        > 在文本文件指定行前插入内容，行数不够用空行补足，文件不存在会创建文件，目录不存在会返回 false  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  
        
    - 示例  
        ```lua
        local success = file.insert_line("/var/mobile/1.txt", 2, "岂因祸福避趋之")
        if success then
            sys.alert("操作成功")
        else
            sys.alert("操作失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 移除文件中指定行 (**file\.remove\_line**)
    - 声明  
        ```lua
        操作成败, 被删除行的内容 = file.remove_line(文件路径, 行号)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行号  
            整数型，指定行号，0 为最后一行 \+1，负数则为倒数行号  
        > - 操作成败  
            布尔型，操作成功返回 true，操作失败返回 false  
        > - 被删除行的内容  
            字符串型，当操作成功的时候，返回被移除的行  
    
    - 说明  
        > 移除文件中指定行，如果被移除的行之后还有行，那么后面行会往前移  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  
        
    - 常见问题  
        > 如果读取到文本的第一行包含不可见字符，请检查是否处理了 UTF8\-BOM，可使用 [`string.strip_utf8_bom`](#去除掉文本前的-utf8-bom-stringstriputf8bom) 剔除  
        
    - 示例  
        ```lua
        local success, line = file.remove_line("/var/mobile/1.txt", 3)
        if success then
            sys.alert("操作成功，被删除的行的内容是："..line)
        else
            sys.alert("操作失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 获取一个文本文件的所有行 (**file\.get\_lines**)
    - 声明  
        ```lua
        行数组 = file.get_lines(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行数组  
            顺序表型 或 nil，返回一个顺序表，文件不存在返回 nil  
    
    - 说明  
        > 获取一个文本文件的所有行，空文件返回 0 行  
        > **这个函数在 1\.1\.1\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  
        
    - 常见问题
        > 如果读取到文本的第一行包含不可见字符，请检查是否处理了 UTF8\-BOM，可使用 [`string.strip_utf8_bom`](#去除掉文本前的-utf8-bom-stringstriputf8bom) 剔除  
        
    - 示例  
        ```lua
        local lines = file.get_lines("/var/mobile/1.txt")
        if lines then
            if #lines > 0 then
                lines[1] = string.strip_utf8_bom(lines[1]) -- 处理掉可能存在的 UTF8-BOM
                sys.alert("文件第一行的内容是 "..lines[1])
            else
                sys.alert("文件是空的")
            end
        else
            sys.alert("操作失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`string.strip_utf8_bom`](#去除掉文本前的-utf8-bom-stringstriputf8bom)

---
<br />

- ### 将一个顺序表转换逐行覆盖写入到文件中 (**file\.set\_lines**)
    - 声明  
        ```lua
        写入成败 = file.set_lines(文件路径, 行数组)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行数组  
            顺序表型，需要转换写入到文件的表  
        > - 写入成败  
            布尔型，操作成功返回 true，操作失败返回 false  
    
    - 说明  
        > 将一个顺序表转换逐行覆盖写入到文件中，文件不存在会创建文件，目录不存在会返回 false  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  
        
    - 示例  
        ```lua
        local success = file.set_lines("/var/mobile/1.txt", {
            "苟利国家生死以",
            "岂因祸福避趋之",
        })
        if success then
            sys.alert("+1s")
        else
            sys.alert("操作失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 将一个顺序表转换逐行插入到文件指定行前 (**file\.insert\_lines**)
    - 声明  
        ```lua
        写入成败 = file.insert_lines(文件路径, 行号, 行数组)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 行号  
            整数型，指定行号，0 为最后一行 \+1，负数则为倒数行号  
        > - 行数组  
            顺序表型，需要转换插入到文件的表  
        > - 写入成败  
            布尔型，操作成功返回 true，操作失败返回 false  
    
    - 说明  
        > 将一个顺序表转换逐行插入到文件指定行前，文件不存在会创建文件，目录不存在会返回 false  
        > **这个函数在 1\.1\.0\-1 版以上方可使用**  
        > **这个函数在 1\.2\-1 版以上将自动剔除 UTF8\-BOM**（[百度搜索 UTF8-BOM 查看更多资料](https://www.baidu.com/s?wd=UTF8-BOM)）  
        
    - 示例  
        ```lua
        local success = file.insert_lines("/var/mobile/1.txt", 0, { -- 将下面两行字追加到文件末尾
            "I will do whatever it takes to serve my country even at the cost of my own life,",
            "regardless of fortune or misfortune to myself.",
        })
        if success then
            sys.alert("+1s")
        else
            sys.alert("操作失败")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

---
<br />

- ### 计算一个文件的 MD5 (**file\.md5**)
    - 声明  
        ```lua
        校验值 = file.md5(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 校验值  
            字符串型 或 nil，文件不存在返回 nil，否则返回其 MD5 校验值  
    
    - 说明  
        > 计算一个文件的 MD5  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        
    - 示例  
        ```lua
        local hash = file.md5("/var/mobile/1.zip")
        if hash then
            sys.alert("`/var/mobile/1.zip` 的 MD5 校验值："..hash)
        else
            sys.alert("`/var/mobile/1.zip` 不是文件")
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)  

---
<br />

- ### 计算一个文件的 SHA1 (**file\.sha1**)
    - 声明  
        ```lua
        校验值 = file.sha1(文件路径)
        ```
    
    - 参数及返回值  
        > - 文件路径  
            文本型，文件绝对路径  
        > - 校验值  
            字符串型 或 nil，文件不存在返回 nil，否则返回其 SHA1 校验值  
    
    - 说明  
        > 计算一个文件的 MD5  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        
    - 示例  
        ```lua
        local hash = file.sha1("/var/mobile/1.zip")
        if hash then
            sys.alert("`/var/mobile/1.zip` 的 SHA1 校验值："..hash)
        else
            sys.alert("`/var/mobile/1.zip` 不是文件")
        end
        ```  
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)  

---
<br />
<br />
<br />

## VPN 配置模块（vpnconf）
- ### 创建一个 VPN 配置(**vpnconf.create**)
    - 声明  
        ```lua
        创建成败 = vpnconf.create(配置表)
        ```
    
    - 参数及返回值  
        > - 配置表  
            表型，用于描述需要创建的 VPN 配置的描述的字典  
        > - 创建成败  
            布尔型，创建成功返回 true，创建失败返回 false，创建失败通常是因为参数不全或错误  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 用于快速创建一个 VPN 配置，不支持 IKEv2 类型创建
        
    - 配置表支持的字段及意义
        |字段名|类型|意义|
        |------|----|----|
        |dispName|文本型|VPN 的显示名|
        |VPNType|文本型|VPN 的类型，支持 `"PPTP"`、`"L2TP"`、`"IPSec"`|
        |server|文本型|服务器地址|
        |authorization|文本型|账号|
        |password|文本型|密码|
        |secret|文本型，可选参数|密钥，PPTP 可不填|
        |encrypLevel|整数型，可选参数|加密级别，默认 `1`|
        |group|文本型，可选参数|群组名称，默认 `""`|
        |VPNSendAllTraffic|整数型，可选参数|是否发送所有流量，默认 `1`|
        
    - 示例  
        ```lua
        local success = vpnconf.create{
            dispName = '1个测试VPN',       -- VPN 的显示名
            VPNType = "L2TP",              -- VPN 的类型，支持 PPTP、L2TP、IPSec、IKEv2
            server = 'www.xxtouch.com',    -- 服务器地址
            authorization = 'havonz',      -- 账号
            password = '123456',           -- 密码
            secret = 'XXTOUCH',            -- 密钥，PPTP 可不填
            encrypLevel = 1,               -- 加密级别，选填，默认 1
            group = '',                    -- 群组名称，选填，默认 ""
            VPNSendAllTraffic = 1,         -- 是否发送所有流量，选填，默认 1
        }
        if success then
            sys.alert('创建成功')
        else
            sys.alert('创建失败，确定人品没有问题？')
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        



---
<br />

- ### 获取当前系统 VPN 的列表(**vpnconf.list**)
    - 声明  
        ```lua
        VPN列表 = vpnconf.list()
        ```
    
    - 参数及返回值  
        > - VPN列表  
            表型 或 nil，获取成功返回当前系统 VPN 的顺序表，获取失败返回 nil  
            
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 返回的 VPN 列表结构如下  
        ```lua
        {
            {dispName = 显示名1, VPNID = VPNID1},
            {dispName = 显示名2, VPNID = VPNID2},
            ...
        }
        ```


    - 示例  
        ```lua
        local list = vpnconf.list()
        if list then
            sys.alert(table.deep_print(list))
        else
            sys.alert('获取失败，确定人品没有问题？')
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`table.deep_print`](#深打印一个表-tabledeepprint)
        



---
<br />

- ### 选择一个 VPN 配置(**vpnconf.select**)
    - 声明  
        ```lua
        操作成败 = vpnconf.select(显示名或VPNID)
        ```
    
    - 参数及返回值  
        > - 显示名或VPNID  
            文本型，选择一个 VPN，多个同显示名 VPN 不保证选择哪个。如果需要精确选择可传入 VPNID  
        > - 操作成败  
            布尔型，操作成功返回 true，操作失败返回 false，操作失败通常是因为指定配置不存在  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > VPNID 可通过 [vpnconf.list](#%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%B3%BB%E7%BB%9F-vpn-%E7%9A%84%E5%88%97%E8%A1%A8vpnconflist) 函数获得  


    - 示例  
        ```lua
        local success = vpnconf.select('1个测试VPN')
        if success then
            sys.alert('操作成功')
        else
            sys.alert('操作失败，确认你要选中的 VPN 配置存在？')
        end
        ```
        



---
<br />

- ### 删除一个 VPN 配置(**vpnconf.delete**)
    - 声明  
        ```lua
        操作成败 = vpnconf.delete(显示名或VPNID)
        ```
    
    - 参数及返回值  
        > - 显示名或VPNID  
            文本型，删除一个 VPN，多个同显示名 VPN 不保证删除哪个。如果需要精确删除可传入 VPNID  
        > - 操作成败  
            布尔型，操作成功返回 true，操作失败返回 false，操作失败通常是因为指定配置不存在  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**
        > VPNID 可通过 [vpnconf.list](#%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%B3%BB%E7%BB%9F-vpn-%E7%9A%84%E5%88%97%E8%A1%A8vpnconflist) 函数获得  


    - 示例  
        ```lua
        local success = vpnconf.delete('1个测试VPN')
        if success then
            sys.alert('操作成功')
        else
            sys.alert('操作失败，确认你要删除的 VPN 配置存在？')
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        



---
<br />

- ### 以当前选择的 VPN 建立连接(**vpnconf.connect**)
    - 声明  
        ```lua
        操作成败 = vpnconf.connect()
        ```
    
    - 参数及返回值  
        > - 操作成败  
            布尔型，操作成功（不是连接成功）返回 true，操作失败返回 false，操作失败通常是因为没有选中的配置  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  


    - 示例  
        ```lua
        local success = vpnconf.connect()
        if success then
            sys.alert('操作成功，正在建立连接……')
        else
            sys.alert('当前并无选中任何 VPN 配置，成功创建 VPN 之后，记得调用 vpnconf.select 选中它')
        end
        ```
        



---
<br />

- ### 断开当前的 VPN 连接(**vpnconf.disconnect**)
    - 声明  
        ```lua
        操作成败 = vpnconf.disconnect()
        ```
    
    - 参数及返回值  
        > - 操作成败  
            布尔型，操作成功（不是断开连接成功）返回 true，操作失败返回 false，操作失败通常是因为没有选中的配置  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  


    - 示例  
        ```lua
        local success = vpnconf.disconnect()
        if success then
            sys.alert('操作成功，正在断开连接……')
        else
            sys.alert('当前并无选中任何 VPN 配置，成功创建 VPN 之后，记得调用 vpnconf.select 选中它')
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
        



---
<br />

- ### 获取当前选择的 VPN 的状态(**vpnconf.status**)
    - 声明  
        ```lua
        状态 = vpnconf.status()
        ```
    
    - 参数及返回值  
        > - 状态  
            表型 或 nil，操作成功返回状态描述表，没有选择任何 VPN 返回 nil  
    
    - 说明  
        > **这个函数在 1\.2\-3 版以上方可使用**  
        > 返回的状态表结构如下  
        ```lua
        {
        	text = 当前状态的文字描述,
        	connected = 是否已经连接成功,
        }
        ```


    - 示例  
        ```lua
        local status = vpnconf.status()
        if status then
            sys.alert(table.deep_print(status))
        else
            sys.alert('当前并无选中任何 VPN 配置，成功创建 VPN 之后，记得调用 vpnconf.select 选中它')
        end
        ```
        **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`table.deep_print`](#深打印一个表-tabledeepprint)
        



---
<br />
<br />
<br />

## ~~云打码模块（cloud_ocr）~~
- ### ~~初始化一个云打码平台(**cloud\_ocr\.ocr**)~~
    - 声明  
        ```lua
        local cloud_ocr = require('cloud_ocr')
        local plat = cloud_ocr.ocr(平台名, 账号, 密码)
        ```
    
    - 参数及返回值  
        > - 平台名  
            文本型，平台（目前支持 'ruokuai', 'dama2', '好爱'）  
        > - 账号  
            文本型，云验证码识别网站账号  
        > - 密码  
            文本型，云验证码识别网站密码  
        > - plat  
            表型，云打码平台对象，用于后面几个 API  
    
    - 说明  
        > 初始化一个云打码平台，云平台账号需要在各自平台官网注册  
        - XXTouch 目前已经集成的云打码平台有若快打码、打码兔、好爱答题  
            - ruokuai（若快打码）  
                - 平台官网：http://www.ruokuai.com/  
                - 注意：若快的开发者账号不能用于打码，需要注册一个用户账号用于打码  
            - dama2（打码兔）  
                - 平台官网：http://www.dama2.com/  
            - 好爱  
                - 平台官网：http://www.haoi23.net/  
                - **好爱 平台支持在软件版本 1\.2\-1 或以上集成**  
        
    - 示例  
        [`本章最后`](#cloudocr\-示例代码)
        



---
<br />

- ### ~~识别屏幕上的范围 (**plat.ocr\_screen**)~~
    - 声明  
        ```lua
        识别结果, 结果标签或错误信息 = plat.ocr_screen(左, 上, 右, 下, 打码类型 [, 超时秒数, 缩放比例 ])
        ```
    
    - 参数及返回值  
        > - plat  
            表型，云打码平台对象，可以使用 [初始化一个云打码平台](#初始化一个云打码平台cloudocrocr) 来获得  
        > - 左, 上, 右, 下  
            整数型，需要打码的图像在屏幕上的范围  
        > - 打码类型  
            文本型，打码类型  
        > - 超时秒数  
            整数型，可选参数，超时时间设置，单位秒，默认 30  
        > - 缩放比例  
            整数型，可选参数，缩放比例，默认 100 不处理  
        > - 识别结果  
            文本型 或 nil，识别成功返回打码结果文字，识别失败返回 nil  
        > - **结果标签**或错误信息  
            文本型，识别成功返回 **结果标签**，识别失败返回错误信息文本描述  
    
    - 说明  
        > 使用打码平台识别屏幕上的范围  
        > - 打码题型参考  
            - 若快题型及价格：http://www.ruokuai.com/home/pricetype  
            - 打码兔题型及价格：http://wiki.dama2.com/index.php?n=ApiDoc.Pricedesc  
        
    - 示例  
        [`本章最后`](#cloudocr\-示例代码)
        



---
<br />

- ### ~~识别图片文件 (**plat.ocr\_image**)~~
    - 声明  
        ```lua
        识别结果, 结果标签或错误信息 = plat.ocr_image(文件路径, 打码类型 [, 超时秒数, 缩放比例 ])
        ```
    
    - 参数及返回值  
        > - plat  
            表型，云打码平台对象，可以使用 [初始化一个云打码平台](#初始化一个云打码平台cloudocrocr) 来获得  
        > - 文件路径  
            文本型，需要打码的图像文件名  
        > - 打码类型  
            文本型，打码类型  
        > - 超时秒数  
            整数型，可选参数，超时时间设置，单位秒，默认 30  
        > - 缩放比例  
            整数型，可选参数，缩放比例，默认 100 不处理  
        > - 识别结果  
            文本型 或 nil，识别成功返回打码结果文字，识别失败返回 nil  
        > - **结果标签**或错误信息  
            文本型，识别成功返回 **结果标签**，识别失败返回错误信息文本描述  
    
    - 说明  
        > 使用打码平台识别图像文件  
        > 文件名如果不使用绝对路径，那么加载 ```/var/mobile/Media/1ferver/res/``` 这个目录的图片文件  
        > - 打码题型参考  
            - 若快题型及价格：http://www.ruokuai.com/home/pricetype  
            - 打码兔题型及价格：http://wiki.dama2.com/index.php?n=ApiDoc.Pricedesc  
        
    - 示例  
        [`本章最后`](#cloudocr\-示例代码)
        



---
<br />

- ### ~~识别图片对象 (**plat.ocr\_obj**)~~
    - 声明  
        ```lua
        识别结果, 结果标签或错误信息 = plat.ocr_obj(图像, 打码类型 [, 超时秒数, 缩放比例 ])
        ```
    
    - 参数及返回值  
        > - plat  
            表型，云打码平台对象，可以使用 [初始化一个云打码平台](#初始化一个云打码平台cloudocrocr) 来获得  
        > - 图像  
            [图片对象](#image图片对象\-模块)，需要打码的图片对象  
        > - 打码类型  
            文本型，打码类型  
        > - 超时秒数  
            整数型，可选参数，超时时间设置，单位秒，默认 30  
        > - 缩放比例  
            整数型，可选参数，缩放比例，默认 100 不处理  
        > - 识别结果  
            文本型 或 nil，识别成功返回打码结果文字，识别失败返回 nil  
        > - **结果标签**或错误信息  
            文本型，识别成功返回 **结果标签**，识别失败返回错误信息文本描述  
    
    - 说明  
        > 使用打码平台识别图片对象  
        > - 打码题型参考  
            - 若快题型及价格：http://www.ruokuai.com/home/pricetype  
            - 打码兔题型及价格：http://wiki.dama2.com/index.php?n=ApiDoc.Pricedesc  
        
    - 示例  
        [`本章最后`](#cloudocr\-示例代码)
        



---
<br />

- ### ~~提交错误的识别 (**plat.report\_error**)~~
    - 声明  
        ```lua
        提交成败, 状态信息 = plat.report_error([ 结果标签 ])
        ```
    
    - 参数及返回值  
        > - plat  
            表型，云打码平台对象，可以使用 [初始化一个云打码平台](#初始化一个云打码平台cloudocrocr) 来获得  
        > - **结果标签**  
            文本型，可选参数，对应打码返回的 **结果标签**，默认提交上次成功的 **结果标签**  
        > - 提交成败  
            布尔型，返回是否提交成功  
        > - 状态信息  
            文本型 或 nil，正确返回状态信息（可不判断），错误返回 nil  
    
    - 说明  
        > 提交错误的识别到打码平台  
        
    - 示例  
        [`本章最后`](#cloudocr\-示例代码)
        



---
<br />

- ### ~~cloud\_ocr 示例代码~~

    ```lua
    local cloud_ocr = require('cloud_ocr')
    local plat = cloud_ocr.ocr('ruokuai','平台账号','平台密码') -- 初始化一个平台对象
    local text, id_or_err = plat.ocr_screen(3, 448, 628, 724, 1040) -- 使用这个平台打屏幕上的码获得结果
    if text then
    	sys.alert('识别成功\n'..
    		'结果标签:'..id_or_err..'\n'..
    		'识别结果:'..text)
    else
    	sys.alert('识别失败\n'..
    		'错误信息:'..id_or_err)
    end
    ```
    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />
<br />
<br />



## 系统回调消息  

* 当系统发生一些事件的时候，会产生一些消息，脚本可以监听这些消息来完成一些希望做的事  
* 消息回调机制需要结合 [进程词典](#进程字典)、[thread](#thread\-模块) 等模块使用  
* **本章没有自定义函数**  


- ### 电话呼入呼出回调消息
    - 声明  
        ```lua
        thread.register_event("xxtouch.call_callback", function(val)
        	if (val == "in") then
        		-- 有电话呼入
        	elseif (val == "out") then
        	    -- 有电话呼出
        	elseif (val == "disconnected") then
        		-- 电话被挂断
        	end
        end)
        ```
    
    * 状态  
        > - in  
            来电呼入的时候，以 xxtouch\.call\_callback 标识的进程队列词典会推入这个值  
        > - out  
            呼出电话的时候，以 xxtouch\.call\_callback 标识的进程队列词典会推入这个值  
        > - disconnected  
            当来电或去电挂断的时候，以 xxtouch\.call\_callback 标识的进程队列词典会推入这个值  
    
    - 说明  
        > 当收到系统电话呼入呼出消息的时候，这个消息标识的进程队列词典会推入一个状态  
        
    - 示例  
        ```lua
        -- 清空消息队列
        proc_queue_clear("xxtouch.call_callback")
        
        sys.toast("脚本从现在开始监听来电事件，二十秒后取消监听")
        
        -- 开始建立监听回调
        local eid = thread.register_event("xxtouch.call_callback", function(val)
        	if (val == "in") then
        		sys.toast("来电话了")
        	elseif (val == "out") then
        		sys.toast("正在打电话出去")
        	elseif (val == "disconnected") then
        		sys.toast("电话挂断了")
        	end
        end)
        
        sys.msleep(20000) -- 等待 20 秒
        
        -- 反注册回调函数，如果不反注册监听，那么脚本不会在此结束
        thread.unregister_event("xxtouch.call_callback", eid)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`proc_queue_clear`](#从进程队列词典中弹出所有值\-procqueueclear)、[`thread.register_event`](#注册监听一个事件\-threadregisterevent)、[`thread.unregister_event`](#反注册监听一个事件\-threadunregisterevent)



---
<br />

- ### 扫码结果回调消息
    - 声明  
        ```lua
        thread.register_event("xxtouch.scan_code_callback", function(val)
            local ret = json.decode(val) -- 返回的是一个 json 字符串
        	if (ret.type == "org.iso.QRCode") then
        	    -- 扫到一个二维码回调 ret.string 是结果
        	else
        	    -- 其它类型回调可以根据 ret.type 来区分
        	end
        end)
        ```
    
    * 状态  
        > - val  
            当使用扫码器扫到一个能识别的值的时候，以 xxtouch.scan\_code\_callback 标识的进程队列词典会推入这个值以及它的相关信息  
    
    - 说明  
        > 当扫码器扫到一个能识别的值的时候，这个消息标识的进程队列词典会推入一个状态  
        
    - 示例  
        ```lua
        -- 清空消息队列
        proc_queue_clear("xxtouch.scan_code_callback")
        
        local success = utils.open_code_scanner()
        if not success then
        	sys.alert("可以于 “设置-通用-访问限制” 中取消 “相机” 的访问限制", 0, "无法访问系统相机")
        	return
        end
        
        sys.toast("脚本从现在开始监扫码结果事件，二十秒后取消监听")
        
        -- 开始建立监听回调
        local eid = thread.register_event("xxtouch.scan_code_callback", function(val)
        	local ret = json.decode(val)
        	if (ret.type == "org.iso.QRCode") then
        	    sys.toast("扫到一个二维码\n"..ret.string)
        	else
        	    sys.toast("扫到一个条码\n"..ret.string)
        	end
        end)
        
        sys.msleep(20000) -- 等待 20 秒
        
        -- 反注册回调函数，如果不反注册监听，那么脚本不会在此结束
        thread.unregister_event("xxtouch.scan_code_callback", eid)
        ```
        **注**：上述代码中使用了非本章函数 [`utils.open_code_scanner`](#打开扫码器-utilsopencodescanner)、[`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`proc_queue_clear`](#从进程队列词典中弹出所有值\-procqueueclear)、[`thread.register_event`](#注册监听一个事件\-threadregisterevent)、
        [`thread.unregister_event`](#反注册监听一个事件\-threadunregisterevent)、[`json.decode`](#将-json-字符串转换成-lua-值-jsondecode)



---
<br />


- ### Activator 事件回调消息
    - 声明  
        ```lua
        thread.register_event("xxtouch.activator_callback", function(val)
            local ret = json.decode(val)
            sys.toast("mode:"..ret.mode.."\n"
                    .."event:"..ret.event.."\n"
                    .."time:"..ret.time)
        end)
        ```
    
    * 状态  
        > - val  
            当配置了 [Activator](http://cydia.saurik.com/package/libactivator/) 回调并且触发了响应的 [Activator](http://cydia.saurik.com/package/libactivator/) 事件的时候，事件的详情会传到这里  
            
    - 说明  
        > 需要安装 [Activator](http://cydia.saurik.com/package/libactivator/) 并于 [Activator](http://cydia.saurik.com/package/libactivator/) 中做好相应的配置配合使用  
        
    - 示例  
        ```lua
        -- 清空消息队列
        proc_queue_clear("xxtouch.activator_callback")
        
        -- 开始建立监听回调
        local eid = thread.register_event("xxtouch.activator_callback", function(val)
        	local ret = json.decode(val)
        	if ret.event=="libactivator.statusbar.tap.double" then
        	    sys.toast("双击状态栏回调")
        	end
        end)
        
        sys.msleep(20000) -- 等待 20 秒
        
        -- 反注册回调函数，如果不反注册监听，那么脚本不会在此结束
        thread.unregister_event("xxtouch.activator_callback", eid)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`proc_queue_clear`](#从进程队列词典中弹出所有值\-procqueueclear)、[`thread.register_event`](#注册监听一个事件\-threadregisterevent)、[`thread.unregister_event`](#反注册监听一个事件\-threadunregisterevent)



---
<br />


- ### HID 事件消息
    - 声明  
        ```lua
        thread.register_event("xxtouch.hid_event", function(val)
            local event = json.decode(val)
            if event.event_type=="touch" then
                if event.event_name=="touch.on" then
                    sys.toast("触摸接触位置: ("..event.x..", "..event.y..")\n"..event.time)
                elseif event.event_name=="touch.move" then
                    sys.toast("触摸移动到位置: ("..event.x..", "..event.y..")\n"..event.time)
                elseif event.event_name=="touch.off" then
                    sys.toast("触摸从位置: ("..event.x..", "..event.y..") 离开屏幕\n"..event.time)
                end
            else
                if event.event_name=="key.down" then
                    sys.toast("按下按键: "..event.key_name.."\n"..event.time)
                elseif event.event_name=="key.up" then
                    sys.toast("抬起按键: "..event.key_name.."\n"..event.time)
                end
            end
        end)
        ```
    
    * 状态  
        > - val  
            注册监听则所有的 hid 事件信息都会传递到这里，极度影响脚本运行效率，不需要了请及时反注册  
            HID 事件中所有的触摸坐标都是以竖屏 HOME 键在下为初始化坐标系，如果需要，可以使用 [screen.rotate_xy](#坐标旋转转换-screenrotatexy) 转换后使用  

        
    - 示例  
        ```lua
        -- 清空消息队列
        proc_queue_clear("xxtouch.hid_event")
        
        -- 建立监听回调
        local eid = thread.register_event("xxtouch.hid_event", function(val)
            local event = json.decode(val)
            if event.event_type=="touch" then
                if event.event_name=="touch.on" then
                    sys.toast("触摸接触位置: ("..event.x..", "..event.y..")\n"..event.time)
                elseif event.event_name=="touch.move" then
                    sys.toast("触摸移动到位置: ("..event.x..", "..event.y..")\n"..event.time)
                elseif event.event_name=="touch.off" then
                    sys.toast("触摸从位置: ("..event.x..", "..event.y..") 离开屏幕\n"..event.time)
                end
            else
                if event.event_name=="key.down" then
                    sys.toast("按下按键: "..event.key_name.."\n"..event.time)
                elseif event.event_name=="key.up" then
                    sys.toast("抬起按键: "..event.key_name.."\n"..event.time)
                end
            end
        end)
        
        touch.on(100, 100):off()
        sys.msleep(1000)
        key.press('homebutton')
        
        sys.msleep(20000) -- 等待 20 秒
        
        -- 反注册回调函数，如果不反注册监听，那么脚本不会在此结束
        thread.unregister_event("xxtouch.hid_event", eid)
        ```
        **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)、[`sys.msleep`](#毫秒级延迟\-sysmsleep)、[`proc_queue_clear`](#从进程队列词典中弹出所有值\-procqueueclear)、[`thread.register_event`](#注册监听一个事件\-threadregisterevent)、[`thread.unregister_event`](#反注册监听一个事件\-threadunregisterevent)



---
<br />
<br />
<br />

## 外部扩展



---
<br />

### ~~地理位置伪装模块（gps）~~
- #### ~~伪装GPS位置 (**gps\.fake**)~~
    - 声明  
        ```lua
        gps.fake(应用包名, 纬度, 经度)
        ```
    
    - 参数及返回值  
        > - 应用包名  
            文本型，指定应用包名  
        > - 纬度  
            实数型，纬度  
        > - 经度  
            实数型，经度  
    
    - 说明  
        > **XXT 1\.1\.1\-1 版以下需要导入 [地理位置伪装插件（点击下载）](http://xxtouch.oss-cn-shanghai.aliyuncs.com/XXT%E5%9C%B0%E7%90%86%E4%BD%8D%E7%BD%AE%E4%BC%AA%E8%A3%85%E6%8F%92%E4%BB%B6.zip) 方可使用**  
        > 对指定应用伪装 GPS 位置，脚本或者服务停止后依然有效  
        > 更新、重装或是卸载 XXTouch 会清空所有的伪装信息  
        > 电脑端拾取经纬度坐标可以用 [这个（百度地图坐标拾取）](http://api.map.baidu.com/lbsapi/getpoint/index.html)  
        > **XXT 1\.3\-1 以上版本已剔除** 
        
    - 示例  
        ```lua
        gps.fake("com.baidu.map", 39.806139606082951, 116.2303211298582)
        ```


---
<br />

- #### ~~清除GPS伪装信息 (**gps\.clear**)~~
    - 声明  
        ```lua
        gps.clear([应用包名])
        ```
    
    - 参数及返回值  
        > - 应用包名  
            文本型，可选参数，指定应用包名，如果不填，则清除所有应用的 GPS 伪装信息  
    
    - 说明  
        > 清除指定应用的 GPS 伪装信息  
        > 更新、重装或是卸载 XXTouch 会清空所有的伪装信息  
        > **XXT 1\.3\-1 以上版本已剔除** 
        
    - 示例  
        ```lua
        gps.clear("com.baidu.map")
        ```

---
<br />
<br />
<br />

### ~~大漠找字/文字识别 模块~~
- 工具下载
    > 下载链接没了  

- 说明  
    > 大漠找字识字不用我解释是什么了吧？  
    > 这个模块使用废弃的 matrix_dict 模块封装，源代码开放。  
    > 安装 XXTouch 之后可以在设备 ```/var/mobile/Media/1ferver/lua/dm.lua``` 查看源代码  
    > **这个模块在 1\.1\.0\-1 版以上方可使用**  

- 示例  
    ```lua
    -- 看例子！！
    local dm = require("dm")                    -- 引用 dm 库
	dm.SetPath("/var/mobile/Media/1ferver/res") -- 设置字库查找目录，默认 /var/mobile/Media/1ferver/res
	dm.SetDict(0, "dm_soft.txt")                -- 设置一个编号对应的字库文件
	dm.UseDict(0)                               -- 选择字库编号，默认 0

	local found, x, y = dm.FindStr(0, 0, 307, 215, "相机", "4d4226-404010", 1.0)
	local text = dm.Ocr(0, 0, 307, 215, "4d4226-404010", 1.0)
	sys.alert(table.deep_print({found, x, y, text}))
    ```
    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[`table.deep_print`](#深打印一个表-tabledeepprint)

---
<br />
<br />
<br />


## 已集成的开源扩展库

---
<br />

### LuaCJSON 扩展库

- [LuaCJSON 手册地址](http://www.kyne.com.au/~mark/software/lua-cjson-manual.html)

**注：** XXTouch 内置的 JSON 模块就是 LuaCJSON，参考 [JSON 模块（json）](#json-模块json)

---
<br />

### LuaSocket 扩展库

- [LuaSocket 手册地址](http://w3.impa.br/~diego/software/luasocket/reference.html)

- #### 连接超时示例
    ```lua
    local socket = require("socket")
    local sock = socket.tcp()
    sock:settimeout(0.2) -- 设置连接超时秒数
    if (sock:connect("220.181.57.217", 80)) then
        sock:close() -- 关闭连接
        sys.alert("能连上")
    else
        sys.alert("超时了")
    end
    ```

    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
    
- #### 模拟 HTTP 请求百度首页示例  
    ```lua
    local socket = require('socket')
    
    local sock = socket.tcp()
    local ip = assert(socket.dns.toip('www.baidu.com'), '域名解析失败')
    sock:settimeout(10)
    assert(sock:connect(ip, 80) == 1, '连接失败或超时')
    
    assert(
        sock:send(
            'GET / HTTP/1.1\r\n'..
            'Host: www.baidu.com\r\n'..
            'Accept: */*\r\n'..
            'Connection: close\r\n'..
            '\r\n'
        ),
        '发送数据超时'
    )
    
    local buf = {}
    repeat
        local chunk, status, partial = sock:receive(4096)
        if (chunk) then
            buf[#buf + 1] = chunk
        else
            if (partial) then
                buf[#buf + 1] = partial
            end
        end
    until status == "closed"
    sock:close()
    
    sys.alert(table.concat(buf))
    ```

    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)、[table.concat](http://cloudwu.github.io/lua53doc/manual.html#pdf-table.concat)


---
<br />

### luaiconv 扩展库（编码转换库）
- [luaiconv 手册地址](http://ittner.github.io/lua-iconv/#api-documentation)


- #### GBK 编码转 UTF\-8 编码示例
    ```lua
    local iconv = require("iconv")
    local cd = iconv.new("utf-8", "gbk") -- 新建一个 GBK 编码到 UTF8 编码的转换器
    local f = io.open("/User/1.txt", "rb")
    local s = f:read("*a")
    f:close()
    sys.alert(cd:iconv(s))
    ```

    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


- #### Unicode Little Endian（UTF\-16LE） 编码转 UTF\-8 编码示例
    ```lua
    local iconv = require("iconv")
    local cd = iconv.new("utf-8", "utf-16le") -- 新建一个 UTF-16LE 编码到 UTF8 编码的转换器
    local f = io.open("/User/1.txt", "rb")
    local s = f:read("*a")
    f:close()
    sys.alert(cd:iconv(s))
    ```

    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

- #### Unicode Big Endian（UTF\-16BE） 编码转 UTF\-8 编码示例
    ```lua
    local iconv = require("iconv")
    local cd = iconv.new("utf-8", "utf-16be") -- 新建一个 UTF-16BE 编码到 UTF8 编码的转换器
    local f = io.open("/User/1.txt", "rb")
    local s = f:read("*a")
    f:close()
    sys.alert(cd:iconv(s))
    ```

    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />

### lpeg 扩展库
- [lpeg 手册地址](http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html)



---
<br />


### LuaFileSystem 扩展库
- [LuaFileSystem 手册地址](http://keplerproject.github.io/luafilesystem/manual.html)

- #### 获取路径中所有文件名示例
    ```lua
    local lfs = require("lfs")
    for filename in lfs.dir("/var/mobile") do
    	if (filename ~= ".." and filename ~= ".") then
    		print(filename)
    	end
    end
    sys.alert(print.out())
    ```
    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)


- #### 获取文件（夹）属性示例
    ```lua
    local lfs = require("lfs")
    
    local attr = lfs.attributes("/var/mobile")
    
    print("类型", attr.mode)
    print("最后访问时间", os.date("%Y-%m-%d %H:%M:%S", attr.access))
    print("最后修改时间", os.date("%Y-%m-%d %H:%M:%S", attr.modification))
    print("最后状态变更时间", os.date("%Y-%m-%d %H:%M:%S", attr.change))
    
    sys.alert(print.out())
    ```
    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)
    
    
- #### 获取及切换脚本当前目录示例
    ```lua
    local lfs = require 'lfs'
    
    sys.alert(lfs.currentdir()) -- 输出 "/"

    lfs.chdir('/var/mobile/Media/1ferver/lua/scripts')
    
    sys.alert(lfs.currentdir()) -- 输出 "/var/mobile/Media/1ferver/lua/scripts"
    ```
    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)



---
<br />


### LuaSQLite3 模块
- [LuaSQLite3 手册地址](http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki)

- 引用示例
    ```lua
    local sqlite3 = require('sqlite3')
    ```

- #### 读取短信示例
    ```lua
    local sqlite3 = require('sqlite3')

    local db = sqlite3.open('/private/var/mobile/Library/SMS/sms.db')
    
    local handle_map = {}
    local messages = {}
    
    db:exec('select handle_id, text, date from message', function (ud, ncols, values, names)
    	messages[#messages + 1] = {
    		handle_id = values[1],
    		text = values[2],
    		date = os.date("%Y-%m-%d %H:%M:%S", os.time({year = 2001, month = 1, day = 1}) + tonumber(values[3]))
    	}
    	return sqlite3.OK
    end)
    
    db:exec('select ROWID, id from handle', function (ud, ncols, values, names)
    	handle_map[values[1]] = values[2]
    	return sqlite3.OK
    end)
    
    for _,v in ipairs(messages) do
    	v.id = handle_map[v.handle_id]
    	v.handle_id = nil
    end
    
    local results = {}
    for _,v in ipairs(messages) do
    	results[#results + 1] = string.format("[%s](%s):%s", v.date, v.id, v.text)
    end
    
    sys.toast(table.concat(results, '\n'))
    ```
    **注**：上述代码中使用了非本章函数 [`sys.toast`](#显示提示文字\-systoast)

---
<br />


### lcurl 模块
**这个模块在 1\.1\.0\-1 版以上方可使用**

- [lcurl 手册地址](http://lua-curl.github.io/lcurl/modules/lcurl.html)

- #### URIEncode 和 URIDecode
    ```lua
    -- URL编码 URI编码 百分号编码 URLEncode URLDecode URLEscape URIEscape PercentEscape
	local curl = require('lcurl')
	local e = curl.easy()

	print(e:escape('abcd$%^&*()'))                 -- 输出 "abcd%24%25%5E%26%2A%28%29"
	
	print(e:unescape('abcd%24%25%5E%26%2A%28%29')) -- 输出 "abcd$%^&*()"
	
	sys.alert(print.out())
	
    ```
    **注**：上述代码中使用了非本章函数 [`sys.alert`](#弹出系统提示\-sysalert)

- #### 模拟触摸精灵 httpGet 实现示例
    ```lua
    function httpGet(url) -- 也能请求 ftp 资源（此函数已内置，不需要再拷贝到自己脚本中，只是 lcurl 使用实例而已）
    	if (url:sub(1, 6) ~= "ftp://" and
    		url:sub(1, 7) ~= "http://" and
    		url:sub(1, 8) ~= "https://") then
    		url = "http://"..url
    	end
    	local curl = require("curl.safe")
    	local buffer_t = {}
    	local write_f = function(s)
    		buffer_t[#buffer_t + 1] = s
    	end
    	local noerr, err = pcall(function()
    		curl.easy()
    			:setopt(curl.OPT_URL, url)
    			:setopt(curl.OPT_CONNECTTIMEOUT, 60)
    			:setopt_writefunction(write_f)
    		:perform()
    	end)
    	if (noerr) then
    		return table.concat(buffer_t)
    	else
    		return nil, err
    	end
    end
    ```




---
<br />
<br />
<br />


## 更多的编译好的开源扩展库

---
<br />

- ~~XML格式扩展库.zip-9.6kB~~  
项目源码：https://github.com/LuaDist/luaxml  

---

- ~~ZIP压缩文件操作库.zip-40.4kB~~  
项目源码：https://github.com/brimworks/lua-zip  

---

- ~~zlib字符串压缩解压库.zip-9.7kB~~  
项目源码：https://github.com/LuaDist/lzlib  

---

- ~~ZeroMQ_ZMQ_ØMQ_扩展库.zip-245.9kB~~  
项目源码：https://github.com/zeromq/lzmq  

---

- ~~OpenSSL扩展库.zip-796.6kB~~  
项目源码：https://github.com/zhaozg/lua-openssl  

---

- ~~UNIX系统API对接库.zip-49.3kB~~  
项目源码：https://github.com/wahern/lunix  
使用文档：http://25thandclement.com/~william/projects/lunix.pdf  

---

- ~~POSIX标准API扩展库.zip-197.5kB~~  
项目源码：https://github.com/luaposix/luaposix  
使用文档：http://luaposix.github.io/luaposix  

---

- ~~MySQL客户端扩展库.zip-127.2kB~~  
项目源码：https://github.com/keplerproject/luasql  
使用文档：http://keplerproject.github.io/luasql/manual.html  

---

<br />
<br />
<br />


## 附录

### 开发及周边工具下载

- Windows 平台工具
    > - [XXT_编辑器-20250421_Windows_版.zip](https://raw.githubusercontent.com/havonz/XXTouchDebs/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/XXT_%E7%BC%96%E8%BE%91%E5%99%A8-Win-20250421125905.zip)  
    > - [XXT_编辑器-20250421_macOS_版.zip](https://raw.githubusercontent.com/havonz/XXTouchDebs/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/XXT_%E7%BC%96%E8%BE%91%E5%99%A8-macOS-20250421125905.zip)  
    > - [XXT 取色器 1.0.25 Windows 版.7z](https://raw.githubusercontent.com/havonz/XXTouchDebs/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/XXT%20%E5%8F%96%E8%89%B2%E5%99%A8%201.0.25%20For%20Windows.7z)  
    > - [XXT 取色器 1.0.25 macOS 版 (depends JRE).zip](https://raw.githubusercontent.com/havonz/XXTouchDebs/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/XXT%20%E5%8F%96%E8%89%B2%E5%99%A8%201.0.25%20For%20macOS%20(depends%20JRE).zip)  
    > - [XXT_局域网集中控制器_2.7.6.4](https://raw.githubusercontent.com/havonz/XXTouchDebs/master/%E7%9B%B8%E5%85%B3%E8%B5%84%E6%BA%90/XXT_%E5%B1%80%E5%9F%9F%E7%BD%91%E6%8E%A7%E5%88%B6%E5%99%A8_V2.7.6.4.zip)  
    > - ~~XXT 网络授权 1.12.0.1.zip-2397.9kB~~  
    > - ~~大漠综合工具.zip-1520.5kB~~  


---
<br />

### 扩展库及远程扩展接口


- 扩展库
    - 除 XXTouch 团队已编译的强大的扩展库以外  
    - 开发者还可自行为 XXTouch 扩展更多的功能  
    - 有兴趣赶快下载下面模板尝试一下吧！  
        > ~~Lua扩展库模板.zip-934.8kB~~  

<br />

- 远程扩展接口  
    - 如果有兴趣给 XXTouch 开发周边平台配套软件  
    - 例如：基于局域网的 集中控制系统、截图取色工具、脚本开发调试环境、设备间数据共享  

<br />

---
<br />

### 脚本守护模式是什么？
- 脚本守护模式会保证脚本在被外力因素（如服务程序崩溃、设备断电）终止后，设备再次恢复正常状态的时候能够再次启动脚本。例外情形如下：  
    - 设备断电后再无充电  
    - 设备开不了机  
    - 设备重启后丢失越狱状态  
    - 设备处于安全模式  
    - 设备有锁屏密码并重启  
    - 用户终止  
    - 脚本因运行期错误终止  
- 守护模式会先于开机启动脚本启动，所以在设备发生故障重启后可以在脚本头部加上如下代码以确保当次脚本启动的时候，屏幕已经处于解锁状态  
    
    ```lua
    while (device.is_screen_locked()) do
    	device.unlock_screen()
    	sys.msleep(1000)
    end
    sys.toast("屏幕已解锁，脚本开始")
    -- 这下面就可以开始脚本
    -- ...
    ```
    



---
<br />

### 开机启动的时机说明
- 开机启动脚本需要主屏幕完全准备好之后才会运作，一般而言会在开机之后延迟一会儿再启动。  
- 较为常见的开机不启动情形如下：  
    - 无法进入桌面  
    - 开机后进入安全模式  
    - 设置了锁屏密码  



---
<br />

### "URL Scheme" 的相关应用
具体使用方法参考：[app.open_url](#前台打开一个-url-appopenurl)
|URL Scheme|跳转到|
|----|----|
|prefs:root=WIFI|设置\-WiFi（或无线局域网）|
|prefs:root=Bluetooth|设置\-蓝牙|
|prefs:root=INTERNET\_TETHERING|设置\-个人热点|
|prefs:root=Wallpaper|设置\-墙纸与亮度|
|prefs:root=Sounds|设置\-声音|
|prefs:root=Sounds&path=Ringtone|设置\-声音\-电话铃声|
|prefs:root=Photos|设置\-照片与相机|
|prefs:root=STORE|设置\-iTunes Store 和 App Store|
|prefs:root=Safari|设置\-Safari|
|prefs:root=MUSIC|设置\-音乐|
|prefs:root=MUSIC&path=EQ|设置\-音乐\-均衡器|
|prefs:root=VIDEO|设置\-视频|
|prefs:root=NOTES|设置\-备忘录|
|prefs:root=Phone|设置\-电话|
|prefs:root=CASTLE|设置\-iCloud|
|prefs:root=CASTLE&path=STORAGE\_AND\_BACKUP|设置\-iCloud\-存储与备份|
|prefs:root=NOTIFICATIONS\_ID|设置\-通知中心|
|prefs:root=ACCOUNT\_SETTINGS|设置\-邮件、日历、通讯录|
|prefs:root=LOCATION\_SERVICES|设置\-定位服务|
|prefs:root=MESSAGES|设置\-信息|
|prefs:root=GAMECENTER|设置\-Game Center|
|prefs:root=General|设置\-通用|
|prefs:root=General&path=About|设置\-通用\-关于本机|
|prefs:root=General&path=SOFTWARE\_UPDATE\_LINK|设置\-通用\-软件更新|
|prefs:root=General&path=ACCESSIBILITY|设置\-通用\-辅助功能|
|prefs:root=General&path=ACCESSIBILITY/REDUCE\_MOTION|设置\-通用\-辅助功能\-减少动态效果|
|prefs:root=General&path=ACCESSIBILITY/ENHANCE\_BACKGROUND\_CONTRAST|设置\-通用\-辅助功能\-增强对比度|
|prefs:root=General&path=AUTO\_CONTENT\_DOWNLOAD|设置\-通用\-后台应用刷新|
|prefs:root=General&path=USAGE|设置\-通用\-用量|
|prefs:root=General&path=AUTOLOCK|设置\-通用\-自动锁定|
|prefs:root=General&path=DATE\_AND\_TIME|设置\-通用\-日期与时间|
|prefs:root=General&path=Keyboard|设置\-通用\-键盘|
|prefs:root=General&path=INTERNATIONAL|设置\-通用\-多语言环境|
|prefs:root=General&path=VPN|设置\-通用\-VPN|
|prefs:root=General&path=Bluetooth|设置\-通用\-蓝牙|
|prefs:root=General&path=Network|设置\-通用\-网络|
|prefs:root=General&path=Network/VPN|设置\-通用\-网络\-VPN|
|prefs:root=General&path=ManagedConfigurationList|设置\-通用\-描述文件|
|prefs:root=General&path=Reset|设置\-通用\-还原|




---
<br />

### "[os.date](http://cloudwu.github.io/lua53doc/manual.html#pdf-os.date)" 日期格式化相关
[os.date](http://cloudwu.github.io/lua53doc/manual.html#pdf-os.date) 第二个参数是可选参数，默认为当前时间
|格式|示例|描述|结果|
|----|----|----|----|
|%Y\-%m\-%d %H:%M:%S|os\.date\("%Y\-%m\-%d %H:%M:%S", 1487356783\)|一种常用日期时间格式|2017\-02\-18 02:39:43|
|%Y\-%m\-%d|os\.date\("%Y\-%m\-%d", 1487356783\)|一种常用日期格式|2017\-02\-18|
|%a|os\.date\("%a", 1487356783\)|短星期名|Sat|
|%A|os\.date\("%A", 1487356783\)|全星期名|Saturday|
|%b|os\.date\("%b", 1487356783\)|简写的月份名|Feb|
|%B|os\.date\("%B", 1487356783\)|月份的全称|February|
|%c|os\.date\("%c", 1487356783\)|标准的日期的时间串|Sat Feb 18 02:39:43 2017|
|%d|os\.date\("%d", 1487356783\)|月的天[01\-31]|18|
|%H|os\.date\("%H", 1487356783\)|24小时制的时[00\-23]|02|
|%I|os\.date\("%I", 1487356783\)|12小时制的时[01\-12]|02|
|%j|os\.date\("%j", 1487356783\)|年的天[001\-366]|049|
|%M|os\.date\("%M", 1487356783\)|分钟[00\-59]|39|
|%m|os\.date\("%m", 1487356783\)|月份[01\-12]|02|
|%p|os\.date\("%p", 1487356783\)|上午AM 下午PM|AM|
|%S|os\.date\("%S", 1487356783\)|秒钟[00\-61]|43|
|%w|os\.date\("%w", 1487356783\)|星期几（星期日为0）[0\-6]|6|
|%x|os\.date\("%x", 1487356783\)|标准的日期串|02/18/17|
|%X|os\.date\("%X", 1487356783\)|标准的时间串|02:39:43|
|%y|os\.date\("%y", 1487356783\)|不带世纪的年份|17|
|%Y|os\.date\("%Y", 1487356783\)|带世纪部分的年份|2017|
|%%|os\.date\("%%", 1487356783\)|百分号|%|

更多 [os.date](http://cloudwu.github.io/lua53doc/manual.html#pdf-os.date) 使用示例
[`实时显示当前日期时间`](#显示提示文字-systoast)


---
<br />

### "[os.execute](http://cloudwu.github.io/lua53doc/manual.html#pdf-os.execute)" 相关示例代码

#### 重启设备
```lua
os.execute('reboot')
```

#### 注销设备
```lua
os.execute('killall -9 SpringBoard;killall -9 backboardd')
```

#### 重建图标缓存
```lua
os.execute('su mobile -c uicache')
```

#### 创建脚本日志连接到脚本目录
```lua
os.execute('ln -s /private/var/mobile/Media/1ferver/log/sys.log /private/var/mobile/Media/1ferver/lua/scripts/脚本日志.txt')
```


#### 常用操作封装
```lua
--[[
    删除文件 文件删除 删除目录 重命名文件 文件重命名 移动文件 文件移动 新建目录 创建目录 新建文件夹 创建文件夹
    以上是关键词，便于在手册中搜索到此处
--]]

local function sh_escape(path) -- XXTouch 原创函数，未经 XXTouch 许可，可以用于商业用途
	path = string.gsub(path, "([ \\()<>'\"`#&*;?~$|])", "\\%1")
	return path
end

function fdelete(path) -- 删除一个文件或目录（递归删除子项）
    assert(type(path)=="string" and path~="", 'fremove 参数异常')
    os.execute('rm -rf '..sh_escape(path))
end

function frename(from, to) -- 重命名（移动）一个文件或目录
    assert(type(from)=="string" and from~="", 'frename 参数 1 异常')
    assert(type(to)=="string" and to~="", 'frename 参数 2 异常')
    os.execute('mv -f '..sh_escape(from).." "..sh_escape(to))
end

function fcopy(from, to) -- 拷贝一个文件或目录 (递归拷贝子项) 
    assert(type(from)=="string" and from~="", 'fcopy 参数 1 异常')
    assert(type(to)=="string" and to~="", 'fcopy 参数 2 异常')
    os.execute('cp -rf '..sh_escape(from).." "..sh_escape(to))
end

function mkdir(path) -- 新建一个目录（递归创建子目录）
    assert(type(path)=="string" and path~="", 'mkdir 参数异常')
    os.execute('mkdir -p '..sh_escape(path))
end

function openurl(url) -- 跳转到一个链接
    assert(type(url)=="string" and url~="", 'openurl 参数异常')
    os.execute('uiopen '..sh_escape(url))
end

-- 以上是封装好的函数，拷贝到自己脚本前就可以用。
-- 以下是使用方式（不用拷贝）

-- 删除 /var/mobile/1.png
fdelete("/var/mobile/1.png")

-- 将 /var/mobile/2.png 重命名为 /var/mobile/1.png
frename("/var/mobile/2.png", "/var/mobile/1.png")

-- 将 /var/mobile/1.png 移动到 /var/mobile/Media/1ferver/res/3.png
frename("/var/mobile/1.png", "/var/mobile/Media/1ferver/res/3.png")

-- 将 /var/mobile/1.png 拷贝到 /var/mobile/Media/1ferver/res/4.png
fcopy("/var/mobile/1.png", "/var/mobile/Media/1ferver/res/4.png")

-- 建立 /var/mobile/1/2/3/4/ 目录
mkdir("/var/mobile/1/2/3/4")

-- 跳转到 www.google.com
openurl("http://www.google.com")

```


---
<br />

### "[string库](http://cloudwu.github.io/lua53doc/manual.html#6.4)" 的相关应用

- 基本函数
    |函数|描述|示例|结果|
    |----|----|----|----|
    |len|计算字符串长度|string\.len\("abcd"\)|4|
    |rep|返回字符串s的n个拷贝|string\.rep\("abcd",2\)|abcdabcd|
    |lower|返回字符串全部字母小写|string\.lower\("AbcD"\)|abcd|
    |upper|返回字符串全部字母大写|string\.upper\("AbcD"\)|ABCD|
    |format|格式化字符串|string\.format\("the value is:%d",4\)|the value is:4|
    |sub|从字符串里截取字符串|string\.sub\("abcd",2\)|bcd|
    |||string\.sub\("abcd",\-2\)|cd|
    |||string\.sub\("abcd",2,\-2\)|bc|
    |||string\.sub\("abcd",2,3\)|bc|
    |find|在字符串中查找(显示位置)|string\.find\("cdcdcdcd","ab"\)|nil|
    |||string\.find\("cdcdcdcd","cd"\)|1 2|
    |||string\.find\("cdcdcdcd","cd",7\)|7 8|
    |match|在字符串中查找(显示内容)|string\.match\("cdcdcdcd","ab"\)|nil|
    |||string\.match\("cdcdcdcd","cd"\)|cd|
    |gsub|在字符串中替换|string\.gsub\("abcdabcd","a","z"\)|zbcdzbcd 2|
    |||string\.gsub\("aaaa","a","z",3\)|zzza 3|
    |byte|返回字符的整数形式|string\.byte\("ABCD",4\)|68|
    |char|将整型数字转成字符并连接|string\.char\(97,98,99,100\)|abcd|



- 基本模式串
    |字符类|描述|示例|结果|
    |------|----|----|----|
    |\.|任意字符|string\.find\("","\."\)|nil|
    |%s|空白符|string\.find\("ab cd","%s%s"\)|3 4|
    |%S|非空白符|string\.find\("ab cd","%S%S"\)|1 2|
    |%p|标点字符|string\.find\("ab,\.cd","%p%p"\)|3 4|
    |%P|非标点字符|string\.find\("ab,\.cd","%P%P"\)|1 2|
    |%c|控制字符|string\.find\("abcd\\t\\n","%c%c"\)|5 6|
    |%C|非控制字符|string\.find\("\\t\\nabcd","%C%C"\)|3 4|
    |%d|数字|string\.find\("abcd12","%d%d"\)|5 6|
    |%D|非数字|string\.find\("12abcd","%D%D"\)|3 4|
    |%x|十六进制数字|string\.find\("efgh","%x%x"\)|1 2|
    |%X|非十六进制数字|string\.find\("efgh","%X%X"\)|3 4|
    |%a|字母|string\.find\("AB12","%a%a"\)|1 2|
    |%A|非字母|string\.find\("AB12","%A%A"\)|3 4|
    |%l|小写字母|string\.find\("ABab","%l%l"\)|3 4|
    |%L|大写字母|string\.find\("ABab","%L%L"\)|1 2|
    |%u|大写字母|string\.find\("ABab","%u%u"\)|1 2|
    |%U|非大写字母|string\.find\("ABab","%U%U"\)|3 4|
    |%w|字母和数字|string\.find\("a1\(\)","%w%w"\)|1 2|
    |%W|非字母非数字|string\.find\("a1\(\)","%W%W"\)|3 4|



- 转义字符%
    |字符类|描述|示例|结果|
    |------|----|----|----|
    |%|转义字符|string\.find\("abc%\.\.","%%"\)|4 4|
    |||string\.find\("abc\.\.d","%\.%\."\)|4 5|



- 用\[\]创建字符集，"\-"为连字符，"^"表示字符集的补集
    |字符类|描述|示例|结果|
    |------|----|----|----|
    |\[01\]|匹配二进制数|string\.find\("32123","\[01\]"\)|3 3|
    |\[AB\]\[CD\]|匹配AC、AD、BC、BD|string\.find\("ABCDEF","\[AB\]\[CD\]"\)|2 3|
    |\[\[\]\]|匹配一对方括号\[\]|string\.find\("ABC\[\]D","\[\[\]\]"\)|4 5|
    |\[1\-3\]|匹配数字1\-3|string\.find\("312","\[1\-3\]\[1\-3\]\[1\-3\]"\)|1 3|
    |\[b\-d\]|匹配字母b\-d|string\.find\("dbc","\[b\-d\]\[b\-d\]\[b\-d\]"\)|1 3|
    |\[^%s\]|匹配任意非空字符|string\.find\(" a ","\[^%s\]"\)|3 3|
    |\[^%d\]|匹配任意非数字字符|string\.find\("123a","\[^%d\]"\)|4 4|
    |\[^%a\]|匹配任意非字母字符|string\.find\("abc1","\[^%a\]"\)|4 4|



- 用"\(\)"进行捕获
    |字符类|描述|示例|结果|
    |------|----|----|----|
    |\(\)|捕获字符串|string\.find\("12ab","\(%a%a\)"\)|3 4 ab|
    |||string\.find\("ab12","\(%d%d\)"\)|3 4 12|



- 模式修饰符
    |修饰符|描述|示例|结果|
    |------|----|----|----|
    |\+|表示1个或多个，匹配最多个|string\.find\("aaabbb","\(a\+b\)"\)|1 4 aaab|
    |||string\.find\("cccbbb","\(a\+b\)"\)|nil|
    |\-|表示0个或多个，匹配最少个|string\.find\("zzxyyy","\(xy\-\)"\)|3 3 x|
    |||string\.find\("zzzyyy","\(x\-y\)"\)|4 4 y|
    |\*|表示0个或多个，匹配最多个|string\.find\("mmmnnn","\(m\*n\)"\)|1 4 mmmb|
    |||string\.find\("lllnnn","\(m\*n\)"\)|4 4 n|
    |?|表示0个或1个|string\.find\("aaabbb","\(a?b\)"\)|3 4 ab|
    |||string\.find\("cccbbb","\(a?b\)"\)|4 4 b|



- match的常见用法
    |描述|示例|结果|
    |----|----|----|
    |匹配中文|string\.match\("男女abc123","\([^%w%p]\+\)"\)|男女|
    |匹配英文|string\.match\("男女abc123","\(%a\+\)"\)|abc|
    |匹配数字|string\.match\("男女abc123","\(%d\+\)"\)|123|
    |匹配英文和数字|string\.match\("男女abc123","\(%w\+\)"\)|abc123|



---
<br />

### "[math库](http://cloudwu.github.io/lua53doc/manual.html#6.7)" 的相关应用
|函数名|描述|示例|结果|
|------|----|----|----|
|pi|圆周率|math\.pi|3\.1415926535898|
|abs|取绝对值|math\.abs\(\-2012\)|2012|
|ceil|向上取整|math\.ceil\(9\.1\)|10|
|floor|向下取整|math\.floor\(9\.9\)|9|
|max|取参数最大值|math\.max\(2,4,6,8\)|8|
|min|取参数最小值|math\.min\(2,4,6,8\)|2|
|pow|计算x的y次幂|math\.pow\(2,16\)|65536\.0|
|sqrt|开平方|math\.sqrt\(65536\)|256\.0|
|modf|取整数和小数部分|math\.modf\(20\.12\)|20 0\.12|
|randomseed|设随机数种子|math\.randomseed\(os\.time\(\)\)||
|random|取随机数|math\.random\(5,90\)|5~90|
|rad|角度转弧度|math\.rad\(180\)|3\.1415926535898|
|deg|弧度转角度|math\.deg\(math\.pi\)|180\.0|
|exp|e的x次方|math\.exp\(4\)|54\.598150033144|
|log|计算x的自然对数|math\.log\(54\.598150033144\)|4\.0|
|log10|计算10为底，x的对数|math\.log10\(1000\)|3\.0|
|frexp|将参数拆成x \* \(2 ^ y\)的形式|math\.frexp\(160\)|0\.625 8|
|ldexp|计算x \* \(2 ^ y\)|math\.ldexp\(0\.625,8\)|160\.0|
|sin|正弦|math\.sin\(math\.rad\(30\)\)|0\.5|
|cos|余弦|math\.cos\(math\.rad\(60\)\)|0\.5|
|tan|正切|math\.tan\(math\.rad\(45\)\)|1\.0|
|asin|反正弦|math\.deg\(math\.asin\(0\.5\)\)|30\.0|
|acos|反余弦|math\.deg\(math\.acos\(0\.5\)\)|60\.0|
|atan|反正切|math\.deg\(math\.atan\(1\)\)|45\.0|



---
<br />
<br />
<br />

### 学习 Lua 注意避开的坑
- 数组下标是从 1 开始的（区别于 C 语言系的 0 开始）
- string\.len 不是取字符串的字符个数，而是取字节数
- 所有未初始化的变量都是 nil，对一个表中的值赋 nil 会从表中删除它
- 只有 nil 和 false 是逻辑假，其它值都是逻辑真，包括 0
- 字符串和数字在做数学运算和对比大小时会自动转换，比如 a = '1' \+ 2
- 两个浮点数（带小数点的数）不能用全等号（`==`）做对比，错误用法比如 `if 89.7 == (3 * 29.9) then`
- 一个可以完全表示为整数的浮点数和对应的整数相等 （例如：`1.0 == 1`）


---
<br />
<br />
<br />

### 开发常见运行期错误参考
|错误描述片段|原因|处理方式|
|------|----|----|
|attempt to perform arithmetic on a|尝试对非数值进行了数学运算（\+、\-、\*、/）|数学运算之前，检查运算输入是否都为数字|
|attempt to compare|尝试对非法值进行了比较运算（\>、<、\>=、<=）|比较运算之前，检查运算输入是否双方可以进行比较运算|
|attempt to concatenate a|尝试对非字符串值进行了连接（\.\.）|在进行字符串连接之前，先确定连接双方都为字符串|
|attempt to call a|尝试调用了一个不是函数的变量|调用一个函数之前，先确定其是否为一个函数|
|attempt to index a|尝试对一个非表变量进行索引（下标运算）|在从数组变量或关联数组变量中取值前，先确定其是否为一个表|
|attempt to yield across a C\-call boundary|尝试在不能让出的调用块中让出|[require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 一个模块的时候，请确认被 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 的模块返回之前没有调用会让出的函数（手册上函数前带叹号）。还有就是不要尝试在带 C 回调的函数中使用会让出的函数（手册上函数前带叹号）。|
|invalid order function for sorting|非法的排序函数，通常发生在排序函数的规则逻辑不够明确的情况下|调用排序函数时，明确排序规则，不要出现 a 大于 b 成立同时小于 b 也成立的规则|
|bad argument \#1 to 'xxx' \(number expected, got nil\)|调用 xxx 函数时，第 \#1 个参数的类型不正确，需要 number 却传入了 nil|参数错误，传入合适的参数就不会出错了|
|bad argument \#2 to 'xxx' \(number has no integer representation\)|调用 xxx 函数时，第 \#2 个参数无法转换成整数|参数错误，传入合适的参数就不会出错了|
|bad argument \#3 to 'xxx'|调用 xxx 函数时，第 \#3 个参数非法|参数错误，传入合适的参数就不会出错了|



- 使用 [require](http://cloudwu.github.io/lua53doc/manual.html#pdf\-require) 的时候抛出 attempt to yield across a C\-call boundary 错误的权宜解决方案
    + 1、在被 require 的模块代码前加上一行 `return function()`
    + 2、在被 require 的模块代码最后加上一行 `end`
    + 3、require 的时候，后面多加一对括号，例如 `require('A')` 改成 `require('A')()`
    + 看完上面仍然不会操作的下载参考例子
        > ~~像dofile一样使用require.zip-0.5kB~~


---
<br />
<br />
<br />