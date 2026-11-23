-- three/utils/pool.lua —— three.utils.pool 绑定模块
--
-- 返回 three.utils.pool 全局命名空间。需引擎侧先安装 pool 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.pool")
--
-- 用法：
--     local pool = require "three.utils.pool"
--     local pm = pool.PoolManager.new()
--     local obj = pm:get("bullet")
--
-- 已绑定类：
--   PoolManager   对象池管理器（isRegister / get / recycle / unregister / clear）
--
-- 说明：泛型 ObjectPool 未绑定。

return require("three").utils.pool
