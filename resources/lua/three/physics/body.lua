-- three/physics/body.lua —— three.physics.body 绑定模块
--
-- 返回 three.physics.body 全局命名空间。需引擎侧先安装 body 绑定：
--     LuaBindingFactory.installPackage(vm, "three.physics.body")
--
-- 用法：
--     local I = require "three.physics.interfaces"
--     local B = require "three.physics.body"
--     local body = B.RigidBody.new(world, I.PhysicsShape.box(1, 1, 1))
--     body:setDynamic():setPosition(0, 5, 0)
--     body:attach(mesh)
--
-- 已绑定类：
--   RigidBody  刚体构建器（链式 setShape/setPosition/setRotation/setRotationEuler/
--              setDynamic/setKinematic/setStatic/setFriction/setRestitution/
--              setActivation/setLayer/setSensor；attach / release；速度 / 位置 /
--              旋转 / 运动类型 / 力 / 力矩 / 冲量 / 质量 / 重力因子 / moveKinematic）

return require("three").physics.body
