-- three/renderers/lights.lua —— three.renderers.lights 绑定模块
--
-- 返回 three.renderers.lights 全局命名空间。需引擎侧先安装 lights 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.lights")
--
-- 已绑定类：
--   Light / AmbientLight / DirectionalLight / HemisphereLight / PointLight
--   RectAreaLight / SpotLight / LightProbe
--   LightShadow / DirectionalLightShadow / PointLightShadow / SpotLightShadow
--   ShadowConstants（静态常量命名空间）

return require("three").renderers.lights
