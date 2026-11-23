-- three/physics/constraint.lua —— three.physics.constraint 绑定模块
--
-- 返回 three.physics.constraint 全局命名空间。需引擎侧先安装 constraint 绑定：
--     LuaBindingFactory.installPackage(vm, "three.physics.constraint")
--
-- 用法：
--     local C = require "three.physics.constraint"
--     local joint = C.PhysicsConstraint.hinge(world, bodyA, bodyB, anchor, axis)
--     joint:setEnabled(true)
--
-- 已绑定类：
--   PhysicsConstraint  约束封装（handle / releasable；isEnabled / setEnabled / release；
--                      静态工厂 fixed / point / hinge / slider / distance / cone /
--                      swingTwist / gear / sixDOF）

return require("three").physics.constraint
