-- three/core/thread.lua —— three.core.thread 绑定模块
--
-- 需引擎侧先安装 thread 绑定：
--     LuaBindingFactory.installPackage(vm, "three.core.thread")
--
-- 已绑定类：Mutex / RecursiveMutex / RWLock / Condition / Semaphore / FrameFence
-- （泛型线程类 SThread / SPSCQueue 暂不绑定）

return require("three").core.thread