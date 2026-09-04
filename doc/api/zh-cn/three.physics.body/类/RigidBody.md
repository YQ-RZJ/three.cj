# 类
## class RigidBody
```cj
public class RigidBody
```
物理刚体便捷封装

### func addAngularImpulse\(Float64,Float64,Float64\)
```cj
public func addAngularImpulse(x: Float64, y: Float64, z: Float64): RigidBody
```
施加角冲量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|绕 X 轴的角冲量y 绕 Y 轴的角冲量z 绕 Z 轴的角冲量|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func addForceAtPosition\(Vector3,Vector3\)
```cj
public func addForceAtPosition(force: Vector3, point: Vector3): RigidBody
```
在指定世界位置施加力

参数: 

|名称|类型|描述|
|---|---|---|
|force|Vector3|力向量point 力的作用点（世界坐标）|
|point|Vector3||

返回: 

- 返回自身（可链式）

### func addForceV\(Vector3\)
```cj
public func addForceV(force: Vector3): RigidBody
```
在质心施加力（Vector3）

参数: 

|名称|类型|描述|
|---|---|---|
|force|Vector3|力向量|

返回: 

- 返回自身（可链式）

### func addForce\(Float64,Float64,Float64\)
```cj
public func addForce(x: Float64, y: Float64, z: Float64): RigidBody
```
在质心施加力（牛顿）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|力在 X 方向的分量y 力在 Y 方向的分量z 力在 Z 方向的分量|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func addImpulse\(Float64,Float64,Float64\)
```cj
public func addImpulse(x: Float64, y: Float64, z: Float64): RigidBody
```
在质心施加冲量

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|冲量在 X 方向的分量y 冲量在 Y 方向的分量z 冲量在 Z 方向的分量|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func addTorque\(Float64,Float64,Float64\)
```cj
public func addTorque(x: Float64, y: Float64, z: Float64): RigidBody
```
施加力矩（牛顿·米）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|绕 X 轴的力矩y 绕 Y 轴的力矩z 绕 Z 轴的力矩|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func attach\(Object3D,Bool\)
```cj
public func attach(object3d: Object3D, syncToObj!: Bool = true): RigidBody
```
创建刚体并绑定到渲染对象

参数: 

|名称|类型|描述|
|---|---|---|
|object3d|Object3D|被绑定的渲染对象syncToObj true=物理→渲染（Dynamic/Kinematic）|
|syncToObj|Bool||

返回: 

- 返回自身（可链式）

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁刚体并解除绑定

### func getAngularVelocity\(\)
```cj
public func getAngularVelocity(): Vector3
```
获取角速度

返回: 

- 角速度（未 attach 时返回零向量）

### func getGravityFactor\(\)
```cj
public func getGravityFactor(): Float64
```
获取重力因子

返回: 

- 重力因子（未 attach 时返回 1.0）

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
获取线速度

返回: 

- 线速度（未 attach 时返回零向量）

### func getMass\(\)
```cj
public func getMass(): Float64
```
获取刚体质量（千克）

返回: 

- 刚体质量（未 attach 时返回 0.0）

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
获取当前位置

返回: 

- 当前位置

### func getRotation\(\)
```cj
public func getRotation(): Quaternion
```
获取当前旋转

返回: 

- 当前旋转四元数

### func init\(PhysicsWorld,PhysicsShape,PhysicsLayer\)
```cj
public init(world!: PhysicsWorld, shape!: PhysicsShape = PhysicsShape(shapeType: PhysicsShapeType.Box, halfExtent: Vector3(0.5, 0.5, 0.5)), layer!: PhysicsLayer = PhysicsLayer.Moving)
```
构造刚体构建器

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界shape 初始形状（默认 Box(0.5,0.5,0.5)）layer 物理层（默认 Moving）|
|shape|PhysicsShape||
|layer|PhysicsLayer||

### func isActive\(\)
```cj
public func isActive(): Bool
```
刚体是否处于活动（模拟）状态

返回: 

- 是否处于活动状态

### func moveKinematic\(Vector3,Quaternion,Float32\)
```cj
public func moveKinematic(position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
```
运动学刚体移动到指定位置/旋转（每帧调用）

参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3|目标位置rotation 目标旋转deltaTime 距上一帧的时间差（秒）|
|rotation|Quaternion||
|deltaTime|Float32||

### func setActivation\(PhysicsActivation\)
```cj
public func setActivation(activation: PhysicsActivation): RigidBody
```
设置激活策略

参数: 

|名称|类型|描述|
|---|---|---|
|activation|PhysicsActivation|激活策略|

返回: 

- 返回自身（可链式）

### func setAngularVelocity\(Float64,Float64,Float64\)
```cj
public func setAngularVelocity(x: Float64, y: Float64, z: Float64): RigidBody
```
设置角速度（世界空间，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 轴角速度y Y 轴角速度z Z 轴角速度|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func setDynamic\(\)
```cj
public func setDynamic(): RigidBody
```
标记为 Dynamic 刚体（受重力/碰撞驱动）

返回: 

- 返回自身（可链式）

### func setFriction\(Float64\)
```cj
public func setFriction(friction: Float64): RigidBody
```
设置摩擦系数（0~1）

参数: 

|名称|类型|描述|
|---|---|---|
|friction|Float64|摩擦系数|

返回: 

- 返回自身（可链式）

### func setGravityFactor\(Float64\)
```cj
public func setGravityFactor(gravityFactor: Float64): RigidBody
```
设置重力因子（1 = 正常重力，0 = 无重力）

参数: 

|名称|类型|描述|
|---|---|---|
|gravityFactor|Float64|重力因子|

返回: 

- 返回自身（可链式）

### func setKinematic\(\)
```cj
public func setKinematic(): RigidBody
```
标记为 Kinematic 刚体（由用户控制，不受力）

返回: 

- 返回自身（可链式）

### func setLayer\(PhysicsLayer\)
```cj
public func setLayer(layer: PhysicsLayer): RigidBody
```
设置物理层

参数: 

|名称|类型|描述|
|---|---|---|
|layer|PhysicsLayer|物理层|

返回: 

- 返回自身（可链式）

### func setLinearVelocity\(Float64,Float64,Float64\)
```cj
public func setLinearVelocity(x: Float64, y: Float64, z: Float64): RigidBody
```
设置线速度（世界空间，米/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 方向线速度y Y 方向线速度z Z 方向线速度|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func setMass\(Float64\)
```cj
public func setMass(mass: Float64): RigidBody
```
设置刚体质量（千克）

参数: 

|名称|类型|描述|
|---|---|---|
|mass|Float64|新的质量|

返回: 

- 返回自身（可链式）

### func setMotionTypeRuntime\(PhysicsMotionType,PhysicsActivation\)
```cj
public func setMotionTypeRuntime(motionType: PhysicsMotionType, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
切换运动类型（运行时）

参数: 

|名称|类型|描述|
|---|---|---|
|motionType|PhysicsMotionType|新的运动类型activation 激活策略，默认 Activate|
|activation|PhysicsActivation||

### func setPositionRuntime\(Float64,Float64,Float64,PhysicsActivation\)
```cj
public func setPositionRuntime(x: Float64, y: Float64, z: Float64, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置位置（运行时）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|世界 X 坐标y 世界 Y 坐标z 世界 Z 坐标activation 激活策略，默认 Activate|
|y|Float64||
|z|Float64||
|activation|PhysicsActivation||

### func setPosition\(Float64,Float64,Float64\)
```cj
public func setPosition(x: Float64, y: Float64, z: Float64): RigidBody
```
设置初始位置（世界坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|世界 X 坐标y 世界 Y 坐标z 世界 Z 坐标|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func setRestitution\(Float64\)
```cj
public func setRestitution(restitution: Float64): RigidBody
```
设置弹性系数（0~1）

参数: 

|名称|类型|描述|
|---|---|---|
|restitution|Float64|弹性系数|

返回: 

- 返回自身（可链式）

### func setRotationEuler\(Float64,Float64,Float64\)
```cj
public func setRotationEuler(x: Float64, y: Float64, z: Float64): RigidBody
```
设置初始旋转（欧拉角，单位弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 轴旋转角（弧度）y Y 轴旋转角（弧度）z Z 轴旋转角（弧度）|
|y|Float64||
|z|Float64||

返回: 

- 返回自身（可链式）

### func setRotationRuntime\(Quaternion,PhysicsActivation\)
```cj
public func setRotationRuntime(quat: Quaternion, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置旋转（运行时）

参数: 

|名称|类型|描述|
|---|---|---|
|quat|Quaternion|目标四元数activation 激活策略，默认 Activate|
|activation|PhysicsActivation||

### func setRotation\(Quaternion\)
```cj
public func setRotation(quat: Quaternion): RigidBody
```
设置初始旋转（四元数）

参数: 

|名称|类型|描述|
|---|---|---|
|quat|Quaternion|初始四元数|

返回: 

- 返回自身（可链式）

### func setSensor\(Bool\)
```cj
public func setSensor(sensor: Bool): RigidBody
```
设置是否为传感器刚体（只检测碰撞、不产生物理响应）

参数: 

|名称|类型|描述|
|---|---|---|
|sensor|Bool|是否为传感器|

返回: 

- 返回自身（可链式）

### func setShape\(PhysicsShape\)
```cj
public func setShape(shape: PhysicsShape): RigidBody
```
设置碰撞形状

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|新的碰撞形状|

返回: 

- 返回自身（可链式）

### func setStatic\(\)
```cj
public func setStatic(): RigidBody
```
标记为 Static 刚体（完全不动，如地面）

返回: 

- 返回自身（可链式）

### prop attached: Bool
```cj
public prop attached: Bool
```
是否已 attach

### prop boundObject: Option < Object3D >
```cj
public prop boundObject: Option < Object3D >
```
获取绑定的渲染对象

### prop handle: PhysicsBodyHandle
```cj
public prop handle: PhysicsBodyHandle
```
获取刚体句柄（attach 后有效）

### prop isSensor: Bool
```cj
public prop isSensor: Bool
```
查询是否为传感器刚体

### prop world: PhysicsWorld
```cj
public prop world: PhysicsWorld
```
获取所属物理世界

