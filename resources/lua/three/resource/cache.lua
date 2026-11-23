-- three/resource/cache.lua —— three.resource.cache 绑定模块
--
-- 返回 three.resource.cache 全局命名空间。需引擎侧先安装 cache 绑定：
--     LuaBindingFactory.installPackage(vm, "three.resource.cache")
--
-- 已绑定类：
--   Cache  全局文件缓存（enabled / files；add / get / remove / clear）

return require("three").resource.cache
