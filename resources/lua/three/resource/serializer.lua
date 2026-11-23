-- three/resource/serializer.lua —— three.resource.serializer 绑定模块
--
-- 返回 three.resource.serializer 全局命名空间。需引擎侧先安装 serializer 绑定：
--     LuaBindingFactory.installPackage(vm, "three.resource.serializer")
--
-- 已绑定类：
--   JsonSerializer  JSON 序列化 / 反序列化

return require("three").resource.serializer
