-- 设置 -- 辅助功能 -- 触控 -- 振动
t = plist.read('/private/var/mobile/Library/Preferences/com.apple.Accessibility.plist')
t.VibrationDisabled = 1
plist.write('/private/var/mobile/Library/Preferences/com.apple.Accessibility.plist', t)
os.execute('killall -9 mediaserverd')
