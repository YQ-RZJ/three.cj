-- three/animation/clip.lua —— three.animation.clip 绑定模块
--
-- 返回 three.animation.clip 全局命名空间。需引擎侧先安装 clip 绑定：
--     LuaBindingFactory.installPackage(vm, "three.animation.clip")
--
-- 用法：
--     local clip = require "three.animation.clip"
--     local c = clip.AnimationClip.new('demo', -1, {track})
--     c:validate():trim()
--
-- 已绑定类：
--   AnimationClip   动画剪辑（name / duration / tracks / blendMode / uuid；
--                   resetDuration / trim / validate / optimize / clone）
--   AnimationUtils  动画工具（getKeyframeOrder / sortedArray / subclip / makeClipAdditive）

return require("three").animation.clip
