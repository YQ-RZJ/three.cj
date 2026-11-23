-- three/utils/memory.lua —— three.utils.memory 绑定模块
--
-- 返回 three.utils.memory 全局命名空间。需引擎侧先安装 memory 绑定：
--     LuaBindingFactory.installPackage(vm, "three.utils.memory")
--
-- 已绑定类：
--   BgfxMemory   内存读写封装（writeFloats / writeUInt16 / writeUInt8 / writeFloat / readFloat；
--                静态 getAvailTransientIndexBuffer / getAvailInstanceDataBuffer）
--
-- 说明：泛型指针类未绑定。

return require("three").utils.memory
