-- three/scene/objects.lua —— three.scene.objects 绑定模块
--
-- 返回 three.scene.objects 全局命名空间。需引擎侧先安装 objects 绑定：
--     LuaBindingFactory.installPackage(vm, "three.scene.objects")
--
-- 已绑定类：
--   Object3D   场景对象基类（transform / 层级 / 矩阵 / 遍历 / 可见性）
--   Layers     图层掩码
--   Raycaster  射线拾取

return require("three").scene.objects
