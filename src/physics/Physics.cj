/**
 * @file[zh-cn] Physics 物理模块父包（仅用于声明 three.physics 包，便于 cjpm 识别 interfaces/world/body/backend 子包）
 * @brief[zh-cn] 本文件声明物理模块父包
 * @explain[zh-cn] 对照 Engine/Physics 目录规划（doc/dir.md）：
 * Physics/
 * ├── Collision/          # 碰撞检测
 * ├── RigidBody/          # 刚体模拟
 * ├── Character/          # 角色控制器
 * └── Constraint/         # 约束/关节
 * 仓颉侧拆分为子包：
 * three.physics.interfaces — 可插拔后端抽象（IPhysicsBackend + PhysicsShape/PhysicsBodyDesc 等）
 * three.physics.backend    — 具体后端适配（JoltBackend 封装 jolt4cj.jolt）
 * three.physics.world      — PhysicsWorld 门面 + 独立物理线程（three.core.thread SThread）
 * three.physics.body       — RigidBody/碰撞体/约束的运行时句柄与便捷构造
 * three.physics.binding    — Object3D ↔ 物理刚体绑定（PhysicsBinding）
 * 线程模型（对齐 AudioContext/BgfxRenderer）：
 * PhysicsWorld 持有独立 three.core.thread.SThread，所有后端调用经 _execPhysics 序列化到物理线程执行，
 * 渲染线程仅读回 transform 同步到 Object3D。后端实例（IPhysicsBackend）本身可在物理线程内创建/销毁。
 *
 * @file[en] Physics Physics module parent package (only declares the three.physics package so that cjpm can recognize the interfaces/world/body/backend sub-packages)
 * @brief[en] This file declares the physics module parent package
 * @explain[en] Mirrors the Engine/Physics directory plan (doc/dir.md):
 * Physics/
 * ├── Collision/          # collision detection
 * ├── RigidBody/          # rigid body simulation
 * ├── Character/          # character controller
 * └── Constraint/         # constraints/joints
 * Split into sub-packages on the Cangjie side:
 * three.physics.interfaces — pluggable backend abstraction (IPhysicsBackend + PhysicsShape/PhysicsBodyDesc, etc.)
 * three.physics.backend    — concrete backend adapter (JoltBackend wraps jolt4cj.jolt)
 * three.physics.world      — PhysicsWorld facade + dedicated physics thread (three.core.thread SThread)
 * three.physics.body       — runtime handles and convenience builders for rigid bodies
 * three.physics.binding    — Object3D ↔ rigid body binding (PhysicsBinding)
 * Threading model (aligned with AudioContext/BgfxRenderer): PhysicsWorld owns a dedicated
 * three.core.thread.SThread; all backend calls are serialized onto the physics thread via
 * _execPhysics, and the render thread only reads back transforms to sync Object3D. Backend
 * instances (IPhysicsBackend) may themselves be created/destroyed on the physics thread.
 *
 * @intro[zh-cn] three.physics 提供可插拔的物理后端抽象、Jolt 后端适配、物理世界门面以及刚体/角色/约束/绑定封装。
 * @intro[en] three.physics provides a pluggable physics backend abstraction, a Jolt backend adapter,
 * a physics world facade, and rigid body / character / constraint / binding wrappers.
 */
package three.physics
