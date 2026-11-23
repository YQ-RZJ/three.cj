-- three/physics/binding.lua —— three.physics.binding 绑定模块
--
-- 返回 three.physics.binding 全局命名空间。需引擎侧先安装 binding 绑定：
--     LuaBindingFactory.installPackage(vm, "three.physics.binding")
--
-- 用法：
--     local P = require "three.physics.binding"
--     local body = P.PhysicsBinding.meshBox(world, mesh)
--     P.PhysicsBinding.unbind(world, mesh)
--
-- 已绑定类：
--   PhysicsBinding  纯静态工具（bind / meshBox / meshSphere / meshCapsule /
--                   meshCylinder / ground / unbind）
--
-- 说明：object3d / mesh 参数为 three.scene 对象，需场景绑定建立后传入。

return require("three").physics.binding
