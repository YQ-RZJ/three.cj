-- three/utils/safe.lua —— three.utils.safe 绑定模块
--
-- 返回 three.utils.safe 全局命名空间。需引擎侧先安装 safe 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.safe")
--
-- 用法：
--     local safe = require "three.utils.safe"
--     local holder = safe.Safe.new(resource)   -- resource 为任意 IReleasable
--     holder:release()
--
-- 已绑定类：
--   Safe   IReleasable 所有权包装（构造接收被托管对象；value / releasable 只读属性；
--          release() 幂等，返回本次是否真正释放）
--
-- 说明：泛型 Safe<T> 按 IReleasable 具体化；接口 IReleasable 本身不绑。

return require("three").utils.safe
