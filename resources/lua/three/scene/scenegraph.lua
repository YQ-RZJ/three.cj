-- three/scene/scenegraph.lua —— three.scene.scenegraph 绑定模块
--
-- 返回 three.scene.scenegraph 全局命名空间。需引擎侧先安装 scenegraph 绑定：
--     LuaBindingFactory.installPackage(vm, "three.scene.scenegraph")
--
-- 已绑定类：
--   Scene / Group / Fog / FogExp2 / ClippingGroup

return require("three").scene.scenegraph
