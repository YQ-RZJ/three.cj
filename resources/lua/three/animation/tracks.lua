-- three/animation/tracks.lua —— three.animation.tracks 绑定模块
--
-- 返回 three.animation.tracks 全局命名空间。需引擎侧先安装 tracks 绑定：
--     LuaBindingFactory.installPackage(vm, "three.animation.tracks")
--
-- 用法：
--     local tracks = require "three.animation.tracks"
--     local track = tracks.NumberKeyframeTrack.new('a.x', {0, 1}, {0, 10})
--
-- 已绑定类（六个子类均含基类 KeyframeTrack 的全部成员）：
--   NumberKeyframeTrack / VectorKeyframeTrack / ColorKeyframeTrack /
--   QuaternionKeyframeTrack / BooleanKeyframeTrack / StringKeyframeTrack

return require("three").animation.tracks
