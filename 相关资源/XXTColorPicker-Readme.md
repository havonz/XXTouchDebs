# XXTColorPicker 使用说明
此文档只针对 XXTColorPicker 当前的最新版本

## 通用  

- ### 截图保存路径  
    默认截图不保存到硬盘上，可以选择一个路径将截图保存到硬盘上  

- ### 截图方向  
    默认截图方向为竖屏 Home 向下，可以设置从设备上截图的默认的旋转方向  

- ### 主题选择  
    选择外观主题，切换主题后需要关闭软件再打开  

- ### 开发证书路径设置  
    设置开发证书的路径，没有开发证书设备端 X.X.T. 的运行将受到限制  
    没有开发证书无法加密脚本  

- ### 设备扫描  
    可扫描到局域网中所有的安装了 X.X.T. 并打开了 “远程访问” 开关的设备  
    连接到设备之后，可使用 截图 从设备端截图  
    可使用内置的简易编辑器，远程测试脚本  

- ### 如何展开简易编辑器  
    找到取色器主界面左侧边缘的三个小点，鼠标按住往右边拖  

- ### macOS 移动鼠标指针权限
    macOS 移动鼠标指针权限需要将 App 添加至 `设置--隐私与安全--辅助功能` 列表  
    若 `设置--隐私与安全--辅助功能` 列表中已经包含 App 却仍不能正常使用  
    则需要先将其从 `设置--隐私与安全--辅助功能` 列表中删除，然后关闭 `设置`  
    再重新将 App 拖动添加至 `设置--隐私与安全--辅助功能` 列表  

## 取色快捷键  

- ### `1`、`2`、`3`、`4`、`5`、`6`、`7`、`8`、`9`、`0`  
    将鼠标在图片上的坐标及颜色信息格式化缓存到对应的缓存位置上  
    格式配置决定缓存的格式  

- ### `Shift` + `1`、`2`、`3`、`4`、`5`、`6`、`7`、`8`、`9`、`0`  
    清除对应缓存位置的格式化坐标颜色信息  

- ### `鼠标左键单击缓存位置色块`  
    复制对应缓存位置缓存的颜色的 16 进制数值到剪贴板  
    [复制单点颜色或坐标](#复制单点颜色或坐标)  

- ### `鼠标左键双击缓存位置色块`  
    复制对应缓存位置缓存的坐标到剪贴板  
    [复制单点颜色或坐标](#复制单点颜色或坐标)  

- ### `鼠标左键双击缓存位置文本`  
    复制对应缓存位置缓存的格式化坐标颜色到剪贴板  
    [复制单点颜色或坐标](#复制单点颜色或坐标)  

- ### `回车键`/`鼠标左键单击图片`  
    将鼠标在图片上的坐标及颜色信息格式化缓存到下一个缓存位置上  

- ### `鼠标右键单击图片`  
    撤销上一次点色缓存（仅支持一步）  

- ### `选中一个缓存点色文本框` 然后按 `空格键`  
    将鼠标移动到该缓存点色的坐标上  

- ### `R`  
    对缓存位置上的所有的坐标从当前图片中重新取色  

- ### `Shift` + `R`  
    将剪贴板中特定格式的点色列表加载到点色缓存列表中
    [Shift + R 从剪贴板导入点色列表并使用 R 重新取色](#Shift-%2B-R-从剪贴板导入点色列表并使用-R-重新取色)  

- ### `M`  
    以第一个有效点为基点，将点色列表中的所有点平移到鼠标所指的另外一个位置重新取色  
    [使用 M 平移所有点重新取色](#使用-M-平移所有点重新取色)  

- ### `F`  
    使用格式化配置中的输出规则输出脚本  

- ### `鼠标左键双击`  
    双击 `输出的脚本` 或 `缓存位置文本框` 可以复制该位置文本内容到剪贴板  

- ### `Z`  
    清除所有缓存位置的坐标和颜色信息  

- ### `A`、`S`、`X`、`C`  
    将鼠标所指图片上的坐标缓存到对应的位置上  
    [使用A、S设置框选区域](使用A、S设置框选区域)  

- ### `Shift` + `鼠标框选`  
    将鼠标框选区域的左上角和右下角的坐标分别存入 `A`、`S` 缓存位置  
    [使用A、S设置框选区域](使用A、S设置框选区域)  

- ### `Ctrl` + `鼠标框选`  
    将鼠标框选区域的左上角和右下角的坐标分别存入 `X`、`C` 缓存位置  

- ### `鼠标右键拖拽`  
    在图像上平移 `Shift + 鼠标框选` 所框选的那个区域  

- ### `Ctrl` + `鼠标右键拖拽`  
    在图像上平移 `Ctrl + 鼠标框选` 所框选的那个区域  

- ### `Ctrl` + `C`  
    在图像上抠出 `Shift + 鼠标框选` （`A`、`S`）所框选的那个区域的 png 图像数据到系统剪贴板  
    如果 `A`、`S` 区域不存在，则将整张图片的 png 图像数据写入到系统剪贴板中  

- ### `Ctrl` + `V`  
    如果剪贴板中是 png 图像数据，则以新标签页打开该图片  

- ### `D`  
    将 `A`、`S` 缓存的坐标输出到系统剪贴板  

- ### `Shift` + `D`  
    将 `X`、`C` 缓存的坐标输出到系统剪贴板  

- ### `E`  
    将 `A`、`S` 缓存的坐标与 `X`、`C` 缓存的坐标交换  

- ### `Shift` + `E`  
    清除掉 `A`、`S` 缓存的坐标  

- ### `Shift` + `A`、`S`、`X`、`C`  
    将鼠标移动到 `A`、`S`、`X`、`C` 缓存的坐标位置上  
    macOS 上需要开启 [移动鼠标指针权限](#macOS-移动鼠标指针权限)  

- ### `J`  
    图片左旋转  

- ### `K`  
    图片右旋转  

- ### `↑`、`↓`、`←`、`→`  
    将鼠标在图片上的位置往上、下、左、右移动一个像素  
    macOS 上需要开启 [移动鼠标指针权限](#macOS-移动鼠标指针权限)  

- ### `Ctrl` + `↑`、`↓`、`←`、`→`  
    将鼠标在图片上的位置往上、下、左、右移动 10 个像素  
    macOS 上需要开启 [移动鼠标指针权限](#macOS-移动鼠标指针权限)  

- ### `鼠标滚轮向上/向下滚动`  
    将鼠标在图片上的位置往上、下移动一个像素  
    macOS 上需要开启 [移动鼠标指针权限](#macOS-移动鼠标指针权限)  

- ### `Shift` + `鼠标滚轮向上/向下滚动`  
    将鼠标在图片上的位置往左、右移动一个像素  
    macOS 上需要开启 [移动鼠标指针权限](#macOS-移动鼠标指针权限)  

## 简易编辑器快捷键  
Default 键在 Windows 为 Ctrl 键，在 macOS 为 Command 键  

- ### 常用文本编辑快捷键  
    所有平台  
    ```
    Default + C          复制
    Default + X          剪切
    Default + V          粘贴
    Default + Z          撤销
    Default + Y          重做
    ```
    macOS 特有  
    ```
    Default + Shift + Z  撤销
    ```

- ### 编程快捷键  
    所有平台
    ```
    TAB                  增加缩进
    Shift + TAB          减少缩进
    Default + /          注释或取消注释
    Detault + Shift + V  剪贴板历史
    Default + D          删除行
    Default + J          合并成行
    ```
    macOS 特有  
    ```
    Ctrl + F             光标前进
    Ctrl + B             光标后退
    Ctrl + A             光标到行首
    Ctrl + E             光标到行尾
    Ctrl + P             光标去上一行
    Ctrl + N             光标去下一行
    Ctrl + O             换行（和回车键一样）
    ```

## 自定义脚本  

- ### 目录结构  
    应用根目录的 `scripts` 子目录包含 快捷键、自定义格式 的脚本配置文件  
    取色器快捷键配置 `scripts/colorpicker/keymap.lua`  
    内置的自定义格式配置 `scripts/colorpicker/customformats/X_Y_Color.lua`  
    macOS 版程序工作目录为 `~/Library/Application Support/XXTColorPicker/`  

- ### 脚本  
    支持 Lua 5.2 所有内置函数  
    取色器 API 列表  
    
    ```lua
    loadImageData(data)
        打开图片数据到新的标签页
    loadImageFile(filename)
        打开图片文件到新标签页
    capture()
        从连接的设备上截屏并使用新标签页打开
    viewRotateLeft()
        当前图像向左旋转
    viewRotateRight()
        当前图像向右旋转
    w, h = getImageSize()
        获取当前图片尺寸
    a, s, x, c = getPosASXC()
        获取 A、S、X、C 四处缓存点的颜色
    poslist = getPosList()
        获取点色列表
    text = clipText()
        从剪贴板读取文本
    copyText(text)
        将文本写入剪贴板
    moveMouseToXY(x, y)
        将鼠标指针移动到图片上的 x, y 坐标上
    reloadPosColors(poscolors)
        将一个 {{x0, y0, c0}, {x1, y1, c1}, ...} 格式的点色列表覆盖加载到点色缓存列表中
    x, y, rgb = getCurrentXY()
        获取当前鼠标指针在图像上的位置
    posinfo = getCurrentPos()
        获取当前鼠标指针在图像上的位置信息
    rgb = getColor(x, y)
        获取当前标签页打开的图片上的某个坐标的颜色
    r, g, b = getColorRGB(x, y)
        获取当前标签页打开的图片上的某个坐标的颜色
    getRectPNGData(top, left, right, bottom)
        获取当前图片部分区域的图片的 PNG 数据
    getRectPNGDataHex(top, left, right, bottom)
        获取当前图片部分区域 Hex 格式的图片的 PNG 数据
    getRectJPEGData(top, left, right, bottom)
        获取当前图片部分区域的图片的 JPEG 数据
    getRectJPEGDataHex(top, left, right, bottom)
        获取当前图片部分区域 Hex 格式的图片的 JPEG 数据
    printLog(...)
        输出内容到日志
    alertInfo(msg, title)
        提示信息弹窗
    alertWarn(msg, title)
        警告弹窗
    alertError(msg, title)
        错误弹窗
    uploadScriptAndRun(data)
        上传脚本内容到设备并运行
    title = getImagesTabPane():getTitleAt(getImagesTabPane():getSelectedIndex())
        获取当前图片标签页的标题
    b64str = string.base64Encode(str)
    str = string.base64Decode(b64str)
        使用 base64 编码/解码字符串
    hexstr = string.toHex(str)
    str = string.fromHex(hexstr)
        使用 16 进制数文本编码/解码字符串
    ```

## 视频演示
- ### 连接到设备截图

    https://github.com/user-attachments/assets/e034d364-7cb9-4bc9-9763-24c4d0b1bf32

- ### 取色并在图像上显示标签

    https://github.com/user-attachments/assets/9c6d0868-d6c9-4eb7-aa14-924815cfb292

- ### 使用空格键将鼠标移动到指定点在图片上的位置

    https://github.com/user-attachments/assets/680a767a-b448-4085-8130-3a2fd0dac992

- ### 使用 M 平移所有点重新取色

    https://github.com/user-attachments/assets/cf4a780b-d8d2-4399-b02a-4a591d0d8a99

- ### 展开编辑器

    https://github.com/user-attachments/assets/9f6d4bdd-9979-4d39-a3a6-73c6fb78d4b7

- ### Shift + R 从剪贴板导入点色列表并使用 R 重新取色

    https://github.com/user-attachments/assets/76f91f8b-4ce6-4584-9e73-31bdfd14c822

- ### 复制单点颜色或坐标

    https://github.com/user-attachments/assets/469bde09-50a3-4255-ac40-00f6d49e8fb2

- ### 使用A、S设置框选区域

    https://github.com/user-attachments/assets/aaca6450-9902-4f0f-8374-106feac7e013