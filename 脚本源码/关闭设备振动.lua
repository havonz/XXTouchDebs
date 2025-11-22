-- 设置 -- 辅助功能 -- 触控 -- 振动
local t = plist.read('/private/var/mobile/Library/Preferences/com.apple.Accessibility.plist') or {}
t.VibrationDisabled = 1
plist.write('/private/var/mobile/Library/Preferences/com.apple.Accessibility.plist', t)
if type(sys.killall) == 'function' then
    sys.killall(9, 'mediaserverd')
else
    os.execute('killall -9 mediaserverd')
end