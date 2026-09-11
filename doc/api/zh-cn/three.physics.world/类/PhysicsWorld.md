# 类
## class PhysicsWorld
```cj
public class PhysicsWorld
```
物理世界门面

### func addAngularImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit
```
施加角冲量

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄angularImpulse 角冲量向量|
|angularImpulse|Vector3||

### func addForceAtPosition\(PhysicsBodyHandle,Vector3,Vector3\)
```cj
public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit
```
在刚体指定世界位置施加力（牛顿）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄force 力向量point 作用点（世界坐标）|
|force|Vector3||
|point|Vector3||

### func addForce\(PhysicsBodyHandle,Vector3\)
```cj
public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit
```
在刚体质心施加力（牛顿）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄force 力向量|
|force|Vector3||

### func addImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit
```
在刚体质心施加冲量（冲量 = 力 × 时间）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄impulse 冲量向量|
|impulse|Vector3||

### func addTorque\(PhysicsBodyHandle,Vector3\)
```cj
public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit
```
施加力矩（牛顿·米）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄torque 力矩向量|
|torque|Vector3||

### func bindObject\(Object3D,PhysicsBodyHandle,Bool\)
```cj
public func bindObject(object3d: Object3D, handle: PhysicsBodyHandle, syncToObj!: Bool = true): Unit
```
绑定 Object3D 与已有刚体：步进后自动将刚体 transform 同步到 object3d

参数: 

|名称|类型|描述|
|---|---|---|
|object3d|Object3D|被绑定的渲染对象handle 物理刚体句柄syncToObj true=物理→渲染（Dynamic/Kinematic 刚体）；false=渲染→物理（Kinematic 由用户驱动时可选）|
|handle|PhysicsBodyHandle||
|syncToObj|Bool||

### func castShape\(PhysicsShape,Vector3,Quaternion,Vector3\)
```cj
public func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3): ArrayList < PhysicsShapeHit >
```
形状投射（shape 沿 direction 扫掠，检测首个/全部阻挡）

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|投射形状描述position 投射起点位置（世界坐标）rotation 投射形状旋转direction 投射方向（长度即最大扫掠距离）|
|position|Vector3||
|rotation|Quaternion||
|direction|Vector3||

返回: 

- 命中列表（按 fraction 升序；空 = 无阻挡）

### func collidePoint\(Vector3\)
```cj
public func collidePoint(point: Vector3): ArrayList < PhysicsPointHit >
```
世界点碰撞检测（检测点位于哪些形状内部/表面）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|世界坐标检测点|

返回: 

- 命中列表

### func collideShape\(PhysicsShape,Vector3,Quaternion\)
```cj
public func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion): ArrayList < PhysicsShapeHit >
```
形状 vs 世界碰撞检测（查询形状摆到 pose 后与场景求交）

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|查询形状描述position 查询形状位置（世界坐标）rotation 查询形状旋转|
|position|Vector3||
|rotation|Quaternion||

返回: 

- 命中列表

### func createBody\(PhysicsBodyDesc\)
```cj
public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle
```
创建刚体（一步完成）

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsBodyDesc|刚体创建描述|

返回: 

- 刚体句柄；失败返回 INVALID

### func createConstraint\(PhysicsConstraintDesc,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
public func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle
```
创建约束并加入世界（连接两个刚体）

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsConstraintDesc|约束创建描述bodyA 约束刚体 1bodyB 约束刚体 2|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||

返回: 

- 约束句柄；失败返回 INVALID

### func destroyBody\(PhysicsBodyHandle\)
```cj
public func destroyBody(handle: PhysicsBodyHandle): Unit
```
销毁刚体并解除任何绑定

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

### func destroyConstraint\(PhysicsConstraintHandle\)
```cj
public func destroyConstraint(handle: PhysicsConstraintHandle): Unit
```
销毁约束并从世界移除（句柄立即失效）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

### func getAngularVelocity\(PhysicsBodyHandle\)
```cj
public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3
```
获取刚体角速度（世界空间，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前角速度

### func getBoundHandle\(Object3D\)
```cj
public func getBoundHandle(object3d: Object3D): PhysicsBodyHandle
```
获取某 Object3D 绑定的刚体句柄

参数: 

|名称|类型|描述|
|---|---|---|
|object3d|Object3D|渲染对象|

返回: 

- 刚体句柄；无绑定返回 INVALID

### func getConstraintCurrentAngle\(PhysicsConstraintHandle\)
```cj
public func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64
```
读取铰链约束当前角度（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

返回: 

- 当前角度

### func getFriction\(PhysicsBodyHandle\)
```cj
public func getFriction(handle: PhysicsBodyHandle): Float64
```
获取刚体摩擦系数

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前摩擦系数

### func getGravityFactor\(PhysicsBodyHandle\)
```cj
public func getGravityFactor(handle: PhysicsBodyHandle): Float64
```
获取刚体重力因子

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前重力因子

### func getInverseInertia\(PhysicsBodyHandle\)
```cj
public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4
```
获取刚体逆惯量（3x3，输出 4x4 矩阵左上角）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前逆惯量矩阵

### func getLinearVelocity\(PhysicsBodyHandle\)
```cj
public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3
```
获取刚体线速度（世界空间，米/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前线速度

### func getMass\(PhysicsBodyHandle\)
```cj
public func getMass(handle: PhysicsBodyHandle): Float64
```
获取刚体质量（千克）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前质量

### func getMotionType\(PhysicsBodyHandle\)
```cj
public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType
```
获取刚体运动类型

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前运动类型

### func getPosition\(PhysicsBodyHandle\)
```cj
public func getPosition(handle: PhysicsBodyHandle): Vector3
```
获取刚体位置（世界坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前位置

### func getRestitution\(PhysicsBodyHandle\)
```cj
public func getRestitution(handle: PhysicsBodyHandle): Float64
```
获取刚体弹性系数

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前弹性系数

### func getRotation\(PhysicsBodyHandle\)
```cj
public func getRotation(handle: PhysicsBodyHandle): Quaternion
```
获取刚体旋转（四元数）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前旋转

### func getSliderCurrentPosition\(PhysicsConstraintHandle\)
```cj
public func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64
```
读取滑块约束当前位置（米）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

返回: 

- 当前位置

### func init\(IPhysicsBackend\)
```cj
public init(backend!: IPhysicsBackend = JoltBackend())
```
构造物理世界

参数: 

|名称|类型|描述|
|---|---|---|
|backend|IPhysicsBackend|物理后端实例（默认 JoltBackend）；可替换为其他 IPhysicsBackend 实现|

### func isBodyActive\(PhysicsBodyHandle\)
```cj
public func isBodyActive(handle: PhysicsBodyHandle): Bool
```
查询刚体是否处于活动（模拟）状态

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 活动返回 true

### func isConstraintEnabled\(PhysicsConstraintHandle\)
```cj
public func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool
```
约束是否启用

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

返回: 

- 启用返回 true

### func isInitialized\(\)
```cj
public func isInitialized(): Bool
```
后端是否已初始化

返回: 

- 已初始化返回 true

### func moveKinematic\(PhysicsBodyHandle,Vector3,Quaternion,Float32\)
```cj
public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
```
运动学刚体移动到指定位置/旋转

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>每帧调用，由 deltaTime 步长驱动。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄position 目标位置（世界坐标）rotation 目标旋转deltaTime 时间步长（秒）|
|position|Vector3||
|rotation|Quaternion||
|deltaTime|Float32||

### func optimizeBroadPhase\(\)
```cj
public func optimizeBroadPhase(): Unit
```
优化 BroadPhase 包围盒树

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>在批量插入刚体后、正式模拟前调用一次。</p>

### func raycastAll\(Vector3,Vector3\)
```cj
public func raycastAll(origin: Vector3, direction: Vector3): ArrayList < PhysicsRayHit >
```
世界射线批量检测（收集所有命中，按距离升序）

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线起点（世界坐标）direction 射线方向（长度即最大检测距离）|
|direction|Vector3||

返回: 

- 命中列表（按 fraction 升序）

### func raycast\(Vector3,Vector3,PhysicsRayHit\)
```cj
public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool
```
世界射线检测（最近命中）

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线起点（世界坐标）direction 射线方向（长度即最大检测距离）hit 命中结果输出（命中时有效）|
|direction|Vector3||
|hit|PhysicsRayHit||

返回: 

- 是否命中

### func setAngularVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit
```
设置刚体角速度（世界空间，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄angularVelocity 角速度|
|angularVelocity|Vector3||

### func setBackend\(IPhysicsBackend\)
```cj
public func setBackend(newBackend: IPhysicsBackend): Unit
```
替换后端（运行时切换底层物理库）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>旧后端必须先 shutdown；新后端需 init 后方可使用。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|newBackend|IPhysicsBackend|新的后端实例|

### func setConstraintEnabled\(PhysicsConstraintHandle,Bool\)
```cj
public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit
```
设置约束是否启用

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄enabled 是否启用|
|enabled|Bool||

### func setConstraintMotorState\(PhysicsConstraintHandle,PhysicsMotorState\)
```cj
public func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit
```
设置约束电机状态（Hinge/Slider：Off/Velocity/Position）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄state 电机状态|
|state|PhysicsMotorState||

### func setConstraintTargetAngle\(PhysicsConstraintHandle,Float64\)
```cj
public func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit
```
设置铰链约束电机目标角度（位置模式，弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄angle 目标角度|
|angle|Float64||

### func setConstraintTargetAngularVelocity\(PhysicsConstraintHandle,Float64\)
```cj
public func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit
```
设置铰链约束电机目标角速度（速度模式，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄angularVelocity 目标角速度|
|angularVelocity|Float64||

### func setContactListener\(Option<IPhysicsSensorListener>\)
```cj
public func setContactListener(listener: Option < IPhysicsSensorListener >): Unit
```
注册碰撞事件监听器（接触回调 + 激活/休眠回调）

参数: 

|名称|类型|描述|
|---|---|---|
|listener|Option<IPhysicsSensorListener>|监听器；None 注销|

### func setFriction\(PhysicsBodyHandle,Float64\)
```cj
public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit
```
设置刚体摩擦系数（0~1）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄friction 摩擦系数|
|friction|Float64||

### func setGravityFactor\(PhysicsBodyHandle,Float64\)
```cj
public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit
```
设置刚体重力因子（1 = 正常重力，0 = 无重力）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄gravityFactor 重力因子|
|gravityFactor|Float64||

### func setGravity\(Vector3\)
```cj
public func setGravity(gravity: Vector3): Unit
```
设置全局重力

参数: 

|名称|类型|描述|
|---|---|---|
|gravity|Vector3|重力向量（如 (0, -9.81, 0)）|

### func setIsSensor\(PhysicsBodyHandle,Bool\)
```cj
public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit
```
设置刚体是否为传感器

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄isSensor 是否传感器（只检测碰撞、不产生物理响应）|
|isSensor|Bool||

### func setLinearVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit
```
设置刚体线速度（世界空间，米/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄velocity 线速度|
|velocity|Vector3||

### func setMass\(PhysicsBodyHandle,Float64\)
```cj
public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit
```
设置刚体质量（千克）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄mass 目标质量|
|mass|Float64||

### func setMotionType\(PhysicsBodyHandle,PhysicsMotionType,PhysicsActivation\)
```cj
public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄motionType 目标运动类型activation 激活策略（默认 Activate）|
|motionType|PhysicsMotionType||
|activation|PhysicsActivation||

### func setPosition\(PhysicsBodyHandle,Vector3,PhysicsActivation\)
```cj
public func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置刚体位置（世界坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄position 新位置activation 激活策略（默认 Activate）|
|position|Vector3||
|activation|PhysicsActivation||

### func setRestitution\(PhysicsBodyHandle,Float64\)
```cj
public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit
```
设置刚体弹性系数（0~1）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄restitution 弹性系数|
|restitution|Float64||

### func setRotation\(PhysicsBodyHandle,Quaternion,PhysicsActivation\)
```cj
public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置刚体旋转（四元数）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄rotation 新旋转activation 激活策略（默认 Activate）|
|rotation|Quaternion||
|activation|PhysicsActivation||

### func setSliderTargetPosition\(PhysicsConstraintHandle,Float64\)
```cj
public func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit
```
设置滑块约束电机目标位置（位置模式，米）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄position 目标位置|
|position|Float64||

### func setSliderTargetVelocity\(PhysicsConstraintHandle,Float64\)
```cj
public func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit
```
设置滑块约束电机目标速度（速度模式，米/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄velocity 目标速度|
|velocity|Float64||

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
关闭物理世界：销毁所有绑定/刚体 → backend.shutdown → 通知物理线程退出

### func start\(UInt32,Vector3\)
```cj
public func start(maxBodies!: UInt32 = 1024u32, gravity!: Vector3 = Vector3(0.0, - 9.81, 0.0)): Bool
```
启动物理世界（初始化后端 + 启动物理线程）

参数: 

|名称|类型|描述|
|---|---|---|
|maxBodies|UInt32|世界最多刚体数（默认 1024）gravity 全局重力（默认 (0, -9.81, 0)）|
|gravity|Vector3||

返回: 

- 是否成功

### func unbindObject\(Object3D\)
```cj
public func unbindObject(object3d: Object3D): Unit
```
解除 Object3D 的物理绑定（不销毁刚体）

参数: 

|名称|类型|描述|
|---|---|---|
|object3d|Object3D|要解除绑定的渲染对象|

### func update\(Float32,Int32\)
```cj
public func update(deltaTime: Float32, collisionSteps!: Int32 = 1): UInt32
```
步进物理世界一帧 + 同步刚体 transform 到绑定的 Object3D

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float32|时间步长（秒），典型 1/60collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1）|
|collisionSteps|Int32||

返回: 

- 更新错误标志（0 = 完整完成）

### prop backend: IPhysicsBackend
```cj
public prop backend: IPhysicsBackend
```
当前后端实例

