if sys.xtversion():sub(1, 5) == '1.3.8' then
	return
end

return json.encode{
	['package-id'] = 'com.1func.xxtouch.bigboss',
	['latest'] = '1.3-7',
	['cydia-url'] = 'cydia://package/com.1func.xxtouch.bigboss',
	['url'] = 'https://github.com/havonz/XXTouchDebs/raw/master/com.1func.xxtouch.bigboss_1.3-7_iphoneos-arm.deb',
	['description'] = [[
[2022-11-30]
1.3-7 Changes:
Fixed iOS 11 RGB10 device screenshot corruption issue 
Fixed iOS 13 not working on A12 + devices 
Fixed clipboard permission issues in iOS 15
1.3-7 改动如下：
修正 iOS 11 广色域屏设备取色截图不正常问题
修正 A12 以上设备 iOS 13 插件无法被加载的问题
修正 iOS 15 剪贴板权限的问题]],
}