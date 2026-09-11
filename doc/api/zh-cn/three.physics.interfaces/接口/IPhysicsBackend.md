# 接口
## interface IPhysicsBackend
```cj
public interface IPhysicsBackend
```
可插拔物理后端接口

### func addAngularImpulse\(PhysicsBodyHandle,Vector3\)
```cj
func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit
```
施加角冲量

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄angularImpulse 角冲量向量|
|angularImpulse|Vector3||

### func addForceAtPosition\(PhysicsBodyHandle,Vector3,Vector3\)
```cj
func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit
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
func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit
```
在刚体质心施加力（牛顿）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄force 力向量|
|force|Vector3||

### func addImpulse\(PhysicsBodyHandle,Vector3\)
```cj
func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit
```
在刚体质心施加冲量（冲量 = 力 × 时间）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄impulse 冲量向量|
|impulse|Vector3||

### func addTorque\(PhysicsBodyHandle,Vector3\)
```cj
func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit
```
施加力矩（牛顿·米）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄torque 力矩向量|
|torque|Vector3||

### func backendName\(\)
```cj
func backendName(): String
```
后端名称（如 "JoltPhysics"），用于日志/调试

返回: 

- 后端名称字符串

### func castShape\(PhysicsShape,Vector3,Quaternion,Vector3,ArrayList<PhysicsShapeHit>\)
```cj
func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3, hits: ArrayList < PhysicsShapeHit >): Int64
```
形状投射（shape 沿 direction 扫掠，检测首个/全部阻挡）

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|投射形状描述position 投射起点位置（世界坐标）rotation 投射形状旋转direction 投射方向（长度即最大扫掠距离）hits 命中结果输出（按 fraction 升序）|
|position|Vector3||
|rotation|Quaternion||
|direction|Vector3||
|hits|ArrayList<PhysicsShapeHit>||

返回: 

- 命中数量

### func collidePoint\(Vector3,ArrayList<PhysicsPointHit>\)
```cj
func collidePoint(point: Vector3, hits: ArrayList < PhysicsPointHit >): Int64
```
世界点碰撞检测（检测点位于哪些形状内部/表面）

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|世界坐标检测点hits 命中结果输出（后端填充）|
|hits|ArrayList<PhysicsPointHit>||

返回: 

- 命中数量

### func collideShape\(PhysicsShape,Vector3,Quaternion,ArrayList<PhysicsShapeHit>\)
```cj
func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, hits: ArrayList < PhysicsShapeHit >): Int64
```
形状 vs 世界碰撞检测（查询形状摆到 pose 后与场景求交）

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|查询形状描述position 查询形状位置（世界坐标）rotation 查询形状旋转hits 命中结果输出（后端填充）|
|position|Vector3||
|rotation|Quaternion||
|hits|ArrayList<PhysicsShapeHit>||

返回: 

- 命中数量

### func createBody\(PhysicsBodyDesc\)
```cj
func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle
```
创建刚体并加入物理世界（一步完成）

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsBodyDesc|刚体创建描述|

返回: 

- 刚体句柄；失败返回 INVALID

### func createConstraint\(PhysicsConstraintDesc,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle
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
func destroyBody(handle: PhysicsBodyHandle): Unit
```
移除并销毁刚体（一步完成，句柄立即失效）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

### func destroyConstraint\(PhysicsConstraintHandle\)
```cj
func destroyConstraint(handle: PhysicsConstraintHandle): Unit
```
销毁约束并从世界移除（句柄立即失效）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

### func getAngularVelocity\(PhysicsBodyHandle\)
```cj
func getAngularVelocity(handle: PhysicsBodyHandle): Vector3
```
获取刚体角速度（世界空间，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前角速度

### func getConstraintCurrentAngle\(PhysicsConstraintHandle\)
```cj
func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64
```
获取铰链约束当前角度（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

返回: 

- 当前角度（弧度）；无效句柄返回 0

### func getFriction\(PhysicsBodyHandle\)
```cj
func getFriction(handle: PhysicsBodyHandle): Float64
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
func getGravityFactor(handle: PhysicsBodyHandle): Float64
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
func getInverseInertia(handle: PhysicsBodyHandle): Matrix4
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
func getLinearVelocity(handle: PhysicsBodyHandle): Vector3
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
func getMass(handle: PhysicsBodyHandle): Float64
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
func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType
```
获取刚体运动类型

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前运动类型

### func getObjectLayer\(PhysicsBodyHandle\)
```cj
func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer
```
获取刚体对象层

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄|

返回: 

- 刚体当前对象层

### func getPosition\(PhysicsBodyHandle\)
```cj
func getPosition(handle: PhysicsBodyHandle): Vector3
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
func getRestitution(handle: PhysicsBodyHandle): Float64
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
func getRotation(handle: PhysicsBodyHandle): Quaternion
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
func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64
```
获取滑块约束当前位置（米）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄|

返回: 

- 当前位置（米）；无效句柄返回 0

### func initialize\(UInt32,Vector3\)
```cj
func initialize(maxBodies: UInt32, gravity: Vector3): Bool
```
初始化后端（全局初始化 + 创建物理系统/作业系统/层过滤）

参数: 

|名称|类型|描述|
|---|---|---|
|maxBodies|UInt32|世界最多刚体数gravity 全局重力向量（如 (0, -9.81, 0)）|
|gravity|Vector3||

返回: 

- 是否成功

### func isBodyActive\(PhysicsBodyHandle\)
```cj
func isBodyActive(handle: PhysicsBodyHandle): Bool
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
func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool
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
func isInitialized(): Bool
```
是否已初始化

返回: 

- 已初始化返回 true

### func moveKinematic\(PhysicsBodyHandle,Vector3,Quaternion,Float32\)
```cj
func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
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
func optimizeBroadPhase(): Unit
```
优化 BroadPhase 包围盒树

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>在批量插入刚体后、正式模拟前调用一次。</p>

### func raycastAll\(Vector3,Vector3,ArrayList<PhysicsRayHit>\)
```cj
func raycastAll(origin: Vector3, direction: Vector3, hits: ArrayList < PhysicsRayHit >): Int64
```
世界射线批量检测（收集所有命中，按距离升序）

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线起点（世界坐标）direction 射线方向（长度即最大检测距离）hits 命中结果输出（调用方传入空列表，后端按距离升序填充）|
|direction|Vector3||
|hits|ArrayList<PhysicsRayHit>||

返回: 

- 命中数量

### func raycast\(Vector3,Vector3,PhysicsRayHit\)
```cj
func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool
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
func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit
```
设置刚体角速度（世界空间，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄angularVelocity 角速度|
|angularVelocity|Vector3||

### func setConstraintEnabled\(PhysicsConstraintHandle,Bool\)
```cj
func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit
```
设置约束是否启用

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄enabled 是否启用|
|enabled|Bool||

### func setConstraintLimits\(PhysicsConstraintHandle,Float64,Float64\)
```cj
func setConstraintLimits(handle: PhysicsConstraintHandle, limitMin: Float64, limitMax: Float64): Unit
```
运行时修改约束限位（Hinge/Slider，弧度或米）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>仅对 Hinge/Slider 约束有效</p>

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄limitMin 限位最小值limitMax 限位最大值|
|limitMin|Float64||
|limitMax|Float64||

### func setConstraintMaxFriction\(PhysicsConstraintHandle,Float64\)
```cj
func setConstraintMaxFriction(handle: PhysicsConstraintHandle, friction: Float64): Unit
```
设置约束最大摩擦（Hinge 为力矩，Slider 为力）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄friction 最大摩擦值|
|friction|Float64||

### func setConstraintMotorState\(PhysicsConstraintHandle,PhysicsMotorState\)
```cj
func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit
```
设置约束电机状态（Hinge/Slider 约束）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>仅对 Hinge/Slider 约束有效；SixDOF 请用六自由度专用接口</p>

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄state 电机状态（Off/Velocity/Position）|
|state|PhysicsMotorState||

### func setConstraintTargetAngle\(PhysicsConstraintHandle,Float64\)
```cj
func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit
```
设置铰链约束目标角度（电机位置模式，弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄angle 目标角度（弧度）|
|angle|Float64||

### func setConstraintTargetAngularVelocity\(PhysicsConstraintHandle,Float64\)
```cj
func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit
```
设置铰链约束目标角速度（电机速度模式，弧度/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄angularVelocity 目标角速度（弧度/秒）|
|angularVelocity|Float64||

### func setContactListener\(Option<IPhysicsSensorListener>\)
```cj
func setContactListener(listener: Option < IPhysicsSensorListener >): Unit
```
注册碰撞事件监听器（接触回调 + 激活/休眠回调）

参数: 

|名称|类型|描述|
|---|---|---|
|listener|Option<IPhysicsSensorListener>|监听器；None 注销|

### func setFriction\(PhysicsBodyHandle,Float64\)
```cj
func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit
```
设置刚体摩擦系数（0~1）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄friction 摩擦系数|
|friction|Float64||

### func setGravityFactor\(PhysicsBodyHandle,Float64\)
```cj
func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit
```
设置刚体重力因子（1 = 正常重力，0 = 无重力）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄gravityFactor 重力因子|
|gravityFactor|Float64||

### func setGravity\(Vector3\)
```cj
func setGravity(gravity: Vector3): Unit
```
设置全局重力

参数: 

|名称|类型|描述|
|---|---|---|
|gravity|Vector3|重力向量（如 (0, -9.81, 0)）|

### func setIsSensor\(PhysicsBodyHandle,Bool\)
```cj
func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit
```
设置刚体是否为传感器

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄isSensor 是否传感器（只检测碰撞、不产生物理响应）|
|isSensor|Bool||

### func setLinearVelocity\(PhysicsBodyHandle,Vector3\)
```cj
func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit
```
设置刚体线速度（世界空间，米/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄velocity 线速度|
|velocity|Vector3||

### func setMass\(PhysicsBodyHandle,Float64\)
```cj
func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit
```
设置刚体质量（千克）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄mass 目标质量|
|mass|Float64||

### func setMotionType\(PhysicsBodyHandle,PhysicsMotionType,PhysicsActivation\)
```cj
func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation: PhysicsActivation): Unit
```
设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄motionType 目标运动类型activation 激活策略|
|motionType|PhysicsMotionType||
|activation|PhysicsActivation||

### func setObjectLayer\(PhysicsBodyHandle,PhysicsLayer\)
```cj
func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit
```
设置刚体对象层（运行时改变碰撞分组）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄layer 目标对象层|
|layer|PhysicsLayer||

### func setPosition\(PhysicsBodyHandle,Vector3,PhysicsActivation\)
```cj
func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation: PhysicsActivation): Unit
```
设置刚体位置（世界坐标）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄position 新位置activation 激活策略|
|position|Vector3||
|activation|PhysicsActivation||

### func setRestitution\(PhysicsBodyHandle,Float64\)
```cj
func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit
```
设置刚体弹性系数（0~1）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄restitution 弹性系数|
|restitution|Float64||

### func setRotation\(PhysicsBodyHandle,Quaternion,PhysicsActivation\)
```cj
func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation: PhysicsActivation): Unit
```
设置刚体旋转（四元数）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsBodyHandle|刚体句柄rotation 新旋转activation 激活策略|
|rotation|Quaternion||
|activation|PhysicsActivation||

### func setSixDOFMotorState\(PhysicsConstraintHandle,Int64,PhysicsMotorState\)
```cj
func setSixDOFMotorState(handle: PhysicsConstraintHandle, axis: Int64, state: PhysicsMotorState): Unit
```
设置六自由度约束指定轴的电机状态

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄axis 轴索引（0=X 平移,1=Y,2=Z,3=X 旋转,4=Y,5=Z）state 电机状态|
|axis|Int64||
|state|PhysicsMotorState||

### func setSixDOFTargetPosition\(PhysicsConstraintHandle,Vector3\)
```cj
func setSixDOFTargetPosition(handle: PhysicsConstraintHandle, target: Vector3): Unit
```
设置六自由度约束约束空间目标位置（平移电机）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄target 约束空间目标位置|
|target|Vector3||

### func setSixDOFTargetVelocity\(PhysicsConstraintHandle,Vector3\)
```cj
func setSixDOFTargetVelocity(handle: PhysicsConstraintHandle, target: Vector3): Unit
```
设置六自由度约束约束空间目标速度（平移电机）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄target 约束空间目标速度|
|target|Vector3||

### func setSliderTargetPosition\(PhysicsConstraintHandle,Float64\)
```cj
func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit
```
设置滑块约束目标位置（电机位置模式，米）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄position 目标位置（米）|
|position|Float64||

### func setSliderTargetVelocity\(PhysicsConstraintHandle,Float64\)
```cj
func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit
```
设置滑块约束目标速度（电机速度模式，米/秒）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|PhysicsConstraintHandle|约束句柄velocity 目标速度（米/秒）|
|velocity|Float64||

### func shutdown\(\)
```cj
func shutdown(): Unit
```
关闭后端（销毁物理系统 + 全局卸载）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>调用后本实例不可再用。</p>

### func update\(Float32,Int32\)
```cj
func update(deltaTime: Float32, collisionSteps: Int32): UInt32
```
步进物理世界一帧

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float32|时间步长（秒），典型 1/60collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1）|
|collisionSteps|Int32||

返回: 

- 更新错误标志（0 = 完整完成）

