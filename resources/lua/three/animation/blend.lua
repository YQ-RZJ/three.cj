-- three/animation/blend.lua —— three.animation.blend 绑定模块
--
-- 返回 three.animation.blend 全局命名空间。需引擎侧先安装 blend 绑定：
--     LuaBindingFactory.installPackage(vm, "three.animation.blend")
--
-- 用法：
--     local blend = require "three.animation.blend"
--     local track = blend.KeyframeTrack.new('a.x', {0, 1}, {0, 10})
--
-- 已绑定类：
--   KeyframeTrack       关键帧轨道基类（插值器工厂 / 时间轴变换 / 校验 / 克隆）
--   AnimationAction     动画动作（播放控制 / 权重 / 淡入淡出 / 时间缩放）
--   AnimationMixer      动画混合器（clipAction / update / setTime / uncache*）
--   AnimationObjectGroup 动画对象组（add / remove / uncache）
--   PropertyBinding     属性绑定（仅静态：sanitizeNodeName / parseTrackName / findNode）

return require("three").animation.blend
