-- three/renderers/rendertarget.lua —— three.renderers.rendertarget 绑定模块
--
-- 返回 three.renderers.rendertarget 全局命名空间。需引擎侧先安装 rendertarget 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.rendertarget")
--
-- 已绑定类：
--   RenderTargetOptions / RenderTarget / RenderTarget3D

return require("three").renderers.rendertarget
