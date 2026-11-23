-- three/renderers/buffer.lua —— three.renderers.buffer 绑定模块
--
-- 返回 three.renderers.buffer 全局命名空间。需引擎侧先安装 buffer 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.buffer")
--
-- 已绑定类：
--   BufferAttribute / Float32BufferAttribute / Uint16BufferAttribute / Uint32BufferAttribute
--   InstancedBufferAttribute / InterleavedBuffer / InstancedInterleavedBuffer
--   InterleavedBufferAttribute / GLBufferAttribute / UpdateRange

return require("three").renderers.buffer
