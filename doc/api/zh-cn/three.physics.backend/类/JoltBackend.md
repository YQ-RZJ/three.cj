# 类
## class JoltBackend
```cj
public class JoltBackend <: IPhysicsBackend
```
IPhysicsBackend 的 JoltPhysics 后端实现

### func addAngularImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit
```
向刚体施加角冲量

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄angularImpulse 角冲量（伪向量，three 左手系）|
|angularImpulse|Vector3||

### func addForceAtPosition\(PhysicsBodyHandle,Vector3,Vector3\)
```cj
public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit
```
在刚体指定作用点上施加作用力

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄force 作用力（three 左手系）point 作用点（刚体局部空间，three 左手系）|
|force|Vector3||
|point|Vector3||

### func addForce\(PhysicsBodyHandle,Vector3\)
```cj
public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit
```
对刚体施加作用力（线性）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄force 作用力（three 左手系）|
|force|Vector3||

### func addImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit
```
对刚体施加线性冲量（瞬间改变线速度）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄impulse 冲量（three 左手系）|
|impulse|Vector3||

### func addTorque\(PhysicsBodyHandle,Vector3\)
```cj
public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit
```
对刚体施加力矩（伪向量）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄torque 力矩（three 左手系）|
|torque|Vector3||

### func backendName\(\)
```cj
public func backendName(): String
```
返回后端名称

返回: 

- 后端名称字符串

### func castShape\(PhysicsShape,Vector3,Quaternion,Vector3,ArrayList<PhysicsShapeHit>\)
```cj
public func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3, hits: ArrayList < PhysicsShapeHit >): Int64
```
沿给定方向投射形状，返回沿途命中的所有形状（形状扫掠）

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|投射形状描述position 投射起点位置（three 左手系）rotation 投射形状旋转（three 左手系）direction 投射方向（three 左手系，无需归一化）hits 接收命中结果的列表（会被清空后填充）|
|position|Vector3||
|rotation|Quaternion||
|direction|Vector3||
|hits|ArrayList<PhysicsShapeHit>||

返回: 

- 命中数量

### func collidePoint\(Vector3,ArrayList<PhysicsPointHit>\)
```cj
public func collidePoint(point: Vector3, hits: ArrayList < PhysicsPointHit >): Int64
```
查询给定点所处位置的所有重叠形状（点碰撞）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|查询点（three 左手系）hits 接收命中结果的列表（会被清空后填充）|
|hits|ArrayList<PhysicsPointHit>||

返回: 

- 命中数量

### func collideShape\(PhysicsShape,Vector3,Quaternion,ArrayList<PhysicsShapeHit>\)
```cj
public func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, hits: ArrayList < PhysicsShapeHit >): Int64
```
查询给定位姿的形状与世界中的哪些形状重叠（形状碰撞）

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|查询形状描述position 形状位置（three 左手系）rotation 形状旋转（three 左手系）hits 接收命中结果的列表（会被清空后填充）|
|position|Vector3||
|rotation|Quaternion||
|hits|ArrayList<PhysicsShapeHit>||

返回: 

- 命中数量

### func createBody\(PhysicsBodyDesc\)
```cj
public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle
```
按描述创建刚体并加入世界

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsBodyDesc|刚体描述（形状、质量、运动类型、层、初始位姿等）|

返回: 

- 刚体句柄；创建失败返回 PhysicsBodyHandle.INVALID

### func createConstraint\(PhysicsConstraintDesc,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
public func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle
```
在两个刚体之间创建约束并加入世界

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsConstraintDesc|约束描述（类型、空间、锚点、轴、限制等）bodyA 刚体 A 句柄bodyB 刚体 B 句柄|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||

返回: 

- 约束句柄；创建失败返回 PhysicsConstraintHandle.INVALID

### func destroyBody\(PhysicsBodyHandle\)
```cj
public func destroyBody(handle: PhysicsBodyHandle): Unit
```
从世界移除并销毁刚体，释放其形状句柄

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

### func destroyConstraint\(PhysicsConstraintHandle\)
```cj
public func destroyConstraint(handle: PhysicsConstraintHandle): Unit
```
从世界移除并销毁约束

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

### func getAngularVelocity\(PhysicsBodyHandle\)
```cj
public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3
```
获取刚体角速度（伪向量）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 角速度（three 左手系）

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

- 摩擦系数

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

- 重力因子（1.0 为正常重力，0.0 为失重）

### func getInverseInertia\(PhysicsBodyHandle\)
```cj
public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4
```
获取刚体逆惯量张量

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 逆惯量张量（Matrix4 左上 3x3，three 左手系）

### func getLinearVelocity\(PhysicsBodyHandle\)
```cj
public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3
```
获取刚体线速度

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 线速度（three 左手系）

### func getMass\(PhysicsBodyHandle\)
```cj
public func getMass(handle: PhysicsBodyHandle): Float64
```
获取刚体质量

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 质量（kg）；无效句柄或未设置时返回 0.0

### func getMotionType\(PhysicsBodyHandle\)
```cj
public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType
```
获取刚体运动类型（静态/运动学/动态）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 运动类型

### func getObjectLayer\(PhysicsBodyHandle\)
```cj
public func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer
```
获取刚体所在对象层（决定碰撞过滤）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 对象层（NonMoving/Moving）

### func getPosition\(PhysicsBodyHandle\)
```cj
public func getPosition(handle: PhysicsBodyHandle): Vector3
```
获取刚体世界位置

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 世界位置（three 左手系）

### func getRestitution\(PhysicsBodyHandle\)
```cj
public func getRestitution(handle: PhysicsBodyHandle): Float64
```
获取刚体恢复系数（弹性）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 恢复系数

### func getRotation\(PhysicsBodyHandle\)
```cj
public func getRotation(handle: PhysicsBodyHandle): Quaternion
```
获取刚体旋转

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 旋转四元数（three 左手系）

### func init\(\)
```cj
public init()
```
创建 Jolt 后端实例（尚未初始化，需调用 initialize）

### func initialize\(UInt32,Vector3\)
```cj
public func initialize(maxBodies: UInt32, gravity: Vector3): Bool
```
初始化物理系统（创建 Jolt 物理系统、作业系统、碰撞过滤与监听器）

参数: 

|名称|类型|描述|
|---|---|---|
|maxBodies|UInt32|系统支持的最大刚体数量gravity 初始重力向量（three 左手系）|
|gravity|Vector3||

返回: 

- 初始化成功返回 true

### func isBodyActive\(PhysicsBodyHandle\)
```cj
public func isBodyActive(handle: PhysicsBodyHandle): Bool
```
查询刚体是否处于活动（模拟中）状态

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
查询约束是否处于启用状态

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
查询物理系统是否已成功初始化

返回: 

- 已初始化返回 true

### func moveKinematic\(PhysicsBodyHandle,Vector3,Quaternion,Float32\)
```cj
public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
```
移动运动学刚体到给定位姿（由物理系统插值，应在 update 前调用）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄position 目标位置（three 左手系）rotation 目标旋转（three 左手系）deltaTime 本帧时间步长（秒）|
|position|Vector3||
|rotation|Quaternion||
|deltaTime|Float32||

### func optimizeBroadPhase\(\)
```cj
public func optimizeBroadPhase(): Unit
```
优化宽相位结构（动态物体位置变化后调用，提升查询性能）

### func raycastAll\(Vector3,Vector3,ArrayList<PhysicsRayHit>\)
```cj
public func raycastAll(origin: Vector3, direction: Vector3, hits: ArrayList < PhysicsRayHit >): Int64
```
发射批量射线，返回全部按距离排序的命中

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线起点（three 左手系）direction 射线方向（three 左手系）hits 接收命中结果的列表（会被清空后填充）|
|direction|Vector3||
|hits|ArrayList<PhysicsRayHit>||

返回: 

- 命中数量

### func raycast\(Vector3,Vector3,PhysicsRayHit\)
```cj
public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool
```
发射单条射线，返回最近命中

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线起点（three 左手系）direction 射线方向（three 左手系，无需归一化）hit 命中结果容器（命中时填充 bodyID/fraction/point/normal）|
|direction|Vector3||
|hit|PhysicsRayHit||

返回: 

- 是否命中

### func setAngularVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit
```
设置刚体角速度（伪向量）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄angularVelocity 角速度（three 左手系）|
|angularVelocity|Vector3||

### func setConstraintEnabled\(PhysicsConstraintHandle,Bool\)
```cj
public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit
```
启用或禁用约束

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄enabled 是否启用|
|enabled|Bool||

### func setContactListener\(Option<IPhysicsSensorListener>\)
```cj
public func setContactListener(listener: Option < IPhysicsSensorListener >): Unit
```
注册碰撞事件监听器（接触/激活/休眠回调）

参数: 

|名称|类型|描述|
|---|---|---|
|listener|Option<IPhysicsSensorListener>|传感器监听器；传 None 取消注册|

### func setFriction\(PhysicsBodyHandle,Float64\)
```cj
public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit
```
设置刚体摩擦系数

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄friction 摩擦系数（0.0 为无摩擦）|
|friction|Float64||

### func setGravityFactor\(PhysicsBodyHandle,Float64\)
```cj
public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit
```
设置刚体重力因子（缩放施加到该刚体的重力）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄gravityFactor 重力因子（1.0 为正常重力，0.0 为失重）|
|gravityFactor|Float64||

### func setGravity\(Vector3\)
```cj
public func setGravity(gravity: Vector3): Unit
```
设置世界重力

参数: 

|名称|类型|描述|
|---|---|---|
|gravity|Vector3|重力向量（three 左手系）|

### func setIsSensor\(PhysicsBodyHandle,Bool\)
```cj
public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit
```
设置刚体是否为传感器（只检测碰撞、不产生物理响应）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄isSensor 是否作为传感器|
|isSensor|Bool||

### func setLinearVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit
```
设置刚体线速度

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄velocity 线速度（three 左手系）|
|velocity|Vector3||

### func setMass\(PhysicsBodyHandle,Float64\)
```cj
public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit
```
设置刚体质量（动态刚体）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄mass 质量（千克，必须大于 0）|
|mass|Float64||

### func setMotionType\(PhysicsBodyHandle,PhysicsMotionType,PhysicsActivation\)
```cj
public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation: PhysicsActivation): Unit
```
设置刚体运动类型（静态/运动学/动态）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄motionType 运动类型activation 是否同时激活刚体|
|motionType|PhysicsMotionType||
|activation|PhysicsActivation||

### func setObjectLayer\(PhysicsBodyHandle,PhysicsLayer\)
```cj
public func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit
```
设置刚体所在对象层（决定碰撞过滤）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄layer 对象层（NonMoving/Moving）|
|layer|PhysicsLayer||

### func setPosition\(PhysicsBodyHandle,Vector3,PhysicsActivation\)
```cj
public func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation: PhysicsActivation): Unit
```
设置刚体世界位置

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄position 世界位置（three 左手系）activation 是否同时激活刚体|
|position|Vector3||
|activation|PhysicsActivation||

### func setRestitution\(PhysicsBodyHandle,Float64\)
```cj
public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit
```
设置刚体恢复系数（弹性）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄restitution 恢复系数（0.0 为完全无弹性，1.0 为完全弹性）|
|restitution|Float64||

### func setRotation\(PhysicsBodyHandle,Quaternion,PhysicsActivation\)
```cj
public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation: PhysicsActivation): Unit
```
设置刚体旋转

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄rotation 旋转四元数（three 左手系）activation 是否同时激活刚体|
|rotation|Quaternion||
|activation|PhysicsActivation||

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
关闭物理系统并释放全部资源（形状句柄、物理系统、监听器）

### func update\(Float32,Int32\)
```cj
public func update(deltaTime: Float32, collisionSteps: Int32): UInt32
```
步进物理世界一个时间片

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float32|步进时间步长（秒）collisionSteps 每个时间步内的碰撞求解迭代次数|
|collisionSteps|Int32||

返回: 

- 本步产生的冲突数

