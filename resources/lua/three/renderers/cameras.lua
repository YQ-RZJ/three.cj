-- three/renderers/cameras.lua —— three.renderers.cameras 绑定模块
--
-- 返回 three.renderers.cameras 全局命名空间。需引擎侧先安装 cameras 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.cameras")
--
-- 已绑定类：
--   Camera / PerspectiveCamera / OrthographicCamera / ArrayCamera / CubeCamera
--   StereoCamera / CameraView

return require("three").renderers.cameras
