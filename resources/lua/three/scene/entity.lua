-- three/scene/entity.lua —— three.scene.entity 绑定模块
--
-- 返回 three.scene.entity 全局命名空间。需引擎侧先安装 entity 绑定：
--     LuaBindingFactory.installPackage(vm, "three.scene.entity")
--
-- 已绑定类：
--   Mesh / SkinnedMesh / Bone / Skeleton / InstancedMesh / BatchedMesh / StaticBatch
--   Line / LineLoop / LineSegments / Points / Sprite / LOD / GroundReflector

return require("three").scene.entity
