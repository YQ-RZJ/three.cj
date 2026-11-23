-- three/renderers/helpers.lua —— three.renderers.helpers 绑定模块
--
-- 返回 three.renderers.helpers 全局命名空间。需引擎侧先安装 helpers 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.helpers")
--
-- 已绑定类：
--   ArrowHelper / AudioListenerHelper / AxesHelper / Box3Helper / BoxHelper
--   CameraHelper / ConstraintHelper / DirectionalLightHelper / GridHelper
--   HemisphereLightHelper / PlaneHelper / PointLightHelper / PolarGridHelper
--   PositionalAudioHelper / RigidBodyHelper / SkeletonHelper / SpotLightHelper

return require("three").renderers.helpers
