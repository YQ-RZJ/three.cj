-- three/physics.lua —— three.physics 绑定模块
--
-- 返回 three.physics 全局命名空间。需引擎侧先安装 physics 绑定：
--     LuaBindingFactory.installPackage(vm, "three.physics")
--
-- 子模块（不创建新的状态，均指向同一全局表）：
--     require "three.physics.interfaces"  枚举 / 形状 / 刚体与约束描述 / 句柄 / 查询结果
--     require "three.physics.world"       PhysicsWorld 物理世界门面
--     require "three.physics.body"        RigidBody 刚体构建器
--     require "three.physics.constraint"  PhysicsConstraint 约束封装
--     require "three.physics.character"   角色控制器
--     require "three.physics.heightfield" 高度场地形
--     require "three.physics.softbody"    软体
--     require "three.physics.vehicle"     载具
--     require "three.physics.ragdoll"     布娃娃
--     require "three.physics.debug"       调试渲染
--     require "three.physics.binding"     Object3D ↔ 刚体绑定工具
--     require "three.physics.backend"     JoltBackend 后端

return require("three").physics
