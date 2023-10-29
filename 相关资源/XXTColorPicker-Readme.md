# XXTColorPicker 使用说明

## 通用  

### 截图保存路径  
- 默认截图不保存到硬盘上，可以选择一个路径将截图保存到硬盘上  

### 截图方向  
- 默认截图方向为竖屏 Home 向下，可以设置从设备上截图的默认的旋转方向  

### 主题选择  
- 选择外观主题，切换主题后需要关闭软件再打开  

### 开发证书路径设置  
- 设置开发证书的路径，没有开发证书设备端 X.X.T. 的运行将受到限制  
- 没有开发证书无法加密脚本  

### 设备扫描  
- 可扫描到局域网中所有的安装了 X.X.T. 并打开了 “远程访问” 开关的设备  
- 连接到设备之后，可使用 截图 从设备端截图  
- 可使用内置的简易编辑器，远程测试脚本  

### 如何展开简易编辑器  
- 找到取色器主界面左侧边缘的三个小点，鼠标按住往右边拖  

## 快捷键  

### `1`、`2`、`3`、`4`、`5`、`6`、`7`、`8`、`9`、`0`  
- 将鼠标在图片上的坐标及颜色信息格式化缓存到对应的缓存位置上  
- 格式配置决定缓存的格式  

### `Shift` + `1`、`2`、`3`、`4`、`5`、`6`、`7`、`8`、`9`、`0`  
- 清除对应缓存位置的格式化坐标颜色信息  

### `鼠标左键单击缓存位置色块`  
- 复制对应缓存位置缓存的颜色的 16 进制数值到剪贴板  

### `鼠标左键双击缓存位置色块`  
- 复制对应缓存位置缓存的坐标到剪贴板  

### `鼠标左键双击缓存位置文本`  
- 复制对应缓存位置缓存的格式化坐标颜色到剪贴板  

### `回车键`/`鼠标左键单击图片`  
- 将鼠标在图片上的坐标及颜色信息格式化缓存到下一个缓存位置上  

### `鼠标右键单击图片`  
- 撤销上一次点色缓存（仅支持一步）  

### `R`  
- 对缓存位置上的所有的坐标从当前图片中重新取色  

### `F`  
- 使用格式化配置中的输出规则输出脚本  

### `鼠标左键双击`  
- 双击 `输出的脚本` 或 `缓存位置文本框` 可以复制该位置文本内容到剪贴板  

### `Z`  
- 清除所有缓存位置的坐标和颜色信息  

### `A`、`S`、`X`、`C`  
- 将鼠标所指图片上的坐标缓存到对应的位置上  

### `D`  
- 将 `A`、`S` 缓存的坐标输出到系统剪贴板  

### `Shift` + `D`  
- 将 `X`、`C` 缓存的坐标输出到系统剪贴板  

### `E`  
- 将 `A`、`S` 缓存的坐标与 `X`、`C` 缓存的坐标交换  

### `Shift` + `E`  
- 清除掉 `A`、`S` 缓存的坐标  

### `Shift` + `A`、`S`、`X`、`C`  
- 将鼠标移动到 `A`、`S`、`X`、`C` 缓存的坐标位置上  

### `J`  
- 图片左旋转  

### `K`  
- 图片右旋转  

### `↑`、`↓`、`←`、`→`  
- 将鼠标在图片上的位置往上、下、左、右移动一个像素  

### `Ctrl` + `↑`、`↓`、`←`、`→`  
- 将鼠标在图片上的位置往上、下、左、右移动 10 个像素  

### `鼠标滚轮向上/向下滚动`  
- 将鼠标在图片上的位置往上、下移动一个像素  

### `Shift` + `鼠标滚轮向上/向下滚动`  
- 将鼠标在图片上的位置往左、右移动一个像素  

## 自定义脚本  

### 目录结构  
- 应用根目录的 `scripts` 子目录包含 快捷键、自定义格式 的脚本配置文件  
- 取色器快捷键配置 `scripts/colorpicker/keymap.lua`  
- 内置的自定义格式配置 `scripts/colorpicker/customformats/X_Y_Color.lua`  

### 脚本  
- 支持 Lua 5.2 所有内置函数
- 取色器 API 列表
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