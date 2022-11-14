# XXTouch 更新日志

---

* 更新 [2022-11-14]
  * 1.3-6 Changes:
    * Fixed an issue where `screen.image(0,x,x,x)` was misjudged as `screen.image()`
  * 1.3-6 改动如下：
    * 修正 `screen.image(0,x,x,x)` 会被误判为 `screen.image()` 的问题

* 更新 [2022-10-25]
  * 1.3-5 Changes:
    * Fixed an issue where the remote CC page could not scan the device
    * Fixed sys.log slow
    * Fixed an issue with daemon.lua using xxtouch.post to return an incorrect value
    * Add custom OpenAPI features
  * 1.3-5 改动如下：
    * 修正远程管理中控页面扫不到设备的问题
    * 修正 sys.log 耗时长的问题
    * 修正 daemon.lua 中 xxtouch.post 返回值不正确的问题
    * 增加自定义 OpenAPI

* 更新 [2022-09-29]
  * 1.3-4 Changes:
    * Fixed App crash on iOS11
  * 1.3-4 改动如下：
    * 修正 App 在 iOS11 崩溃的问题

* 更新 [2022-09-28]
  * 1.3-3 Changes:
    * Fixed App crash when opening the *Application List* on iOS13 or above
    * Updated the vpnconf module to support iOS12 to 14
    * Updated the built-in luasocket module to version 3.1.0
    * Updated the built-in luasec module to version 1.2.0
    * Updated the built-in copas module to version 4.3.1
    * Updated the built-in websocket module
  * 1.3-3 改动如下：
    * 修正 App 在 iOS13 以上系统中打开 *应用列表* 会崩溃的问题
    * 更新 vpnconf 模块支持 iOS12～14
    * 更新内置 luasocket 模块到 3.1.0 版
    * 更新内置 luasec 模块到 1.2.0 版
    * 更新内置 copas 模块到 4.3.1 版
    * 更新内置 websocket 模块

* 更新 [2022-09-15]
  * 1.3-2 Changes:
    * fix app.quit
  * 1.3-2 改动如下：
    * 修正了 app.quit 不好使的问题

* 更新 [2022-09-13]
  * 1.3-1 Changes:
    * Authorization removed
    * 32-bit devices are no longer supported
    * No longer specifically supports devices below iOS 12
    * The encript interface is closed
    * app.input_text function removed
    * GPS module has been removed
    * Memory read/write module removed
    * app.shake function removed
    * app.set_orien function removed
    * app.eval function removed
    * The volume key shortcut is no longer activated by default
  * 1.3-1 改动如下：
    * 软件免费使用，不再需要授权码
    * 不再支持 32 位设备
    * 不再特意支持 iOS 12 以下设备
    * 加密脚本接口关闭
    * app.input_text 函数剔除
    * gps 伪装模块剔除
    * 内存读写模块剔除
    * app.shake 函数剔除
    * app.set_orien 函数剔除
    * app.eval 函数剔除
    * 默认不再激活音量键快捷键
