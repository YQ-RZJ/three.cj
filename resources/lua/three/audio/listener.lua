-- three/audio/listener.lua —— three.audio.listener 绑定模块
--
-- 返回 three.audio.listener 全局命名空间。需引擎侧先安装 listener 绑定：
--     LuaBindingFactory.installPackage(vm, "three.audio.listener")
--
-- 用法：
--     local listener = require "three.audio.listener"
--     local ears = listener.AudioListener.new()   -- 可传 AudioContext 作为首参
--     ears:setMasterVolume(0.8)
--
-- 已绑定类：
--   AudioListener  音频监听器（context / gain / timeDelta 可读写；
--                  getMasterVolume / setMasterVolume / updateMatrixWorld / release）
--
-- 说明：AudioListener 继承 Object3D，但 Object3D 尚未绑定，父类成员在 Lua 侧不可用。

return require("three").audio.listener
