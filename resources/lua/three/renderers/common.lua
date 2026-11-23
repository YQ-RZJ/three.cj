-- three/renderers/common.lua —— three.renderers.common 绑定模块
--
-- 返回 three.renderers.common 全局命名空间。需引擎侧先安装 common 绑定：
--     LuaBindingFactory.installPackage(vm, "three.renderers.common")
--
-- 已绑定类：
--   渲染统计：Info（autoReset / frame / calls / triangles / vertices /
--             render / compute / memory / reset() / update(frame)）
--             RenderInfo（calls / triangles / vertices）
--             ComputeInfo（calls / computeCalls）
--             MemoryInfo（textures / geometries）
--   通用常量：Constants（TRIANGLES() / LINES() / POINTS() / BACKEND()）
--
-- 用法：ThreeRenderer.info 返回与渲染器同一实例的 Info 注册对象，
-- 读到的 calls / triangles 等即当前最新统计（引用同一实例，非快照）。

return require("three").renderers.common
