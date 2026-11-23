-- three/utils/allocator.lua —— three.utils.allocator 绑定模块
--
-- 返回 three.utils.allocator 全局命名空间。需引擎侧先安装 allocator 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.allocator")
--
-- 用法：
--     local allocator = require "three.utils.allocator"
--     local a = allocator.IdAllocator.new(0)
--     local id = a:allocate()
--     a:release(id)
--
-- 已绑定类：
--   IdAllocator   整数 id 分配器（构造可选起始 ID；allocate / release（带参回收单个 /
--                 无参重置）/ freeCount / releasable 只读属性）

return require("three").utils.allocator
