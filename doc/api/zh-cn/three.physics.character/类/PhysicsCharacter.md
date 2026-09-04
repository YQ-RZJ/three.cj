# 类
## class PhysicsCharacter
```cj
public class PhysicsCharacter
```
基于刚体的角色（对应 JPH_Character）

### func addToPhysicsSystem\(PhysicsActivation\)
```cj
public func addToPhysicsSystem(activation: PhysicsActivation): Unit
```
将角色添加到物理系统

参数: 

|名称|类型|描述|
|---|---|---|
|activation|PhysicsActivation|是否激活角色（Activate/DontActivate）|

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁角色并释放底层句柄

### func getGroundState\(\)
```cj
public func getGroundState(): UInt32
```
获取地面状态（GroundState 枚举值）

返回: 

- GroundState 枚举值（0 = OnGround）

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
获取角色线速度

返回: 

- 当前线速度（世界坐标）

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
获取角色位置

返回: 

- 当前位置（世界坐标）

### func init\(CPointer<Unit>,Vector3,CPointer<Unit>,Quaternion,UInt32,Float32,Float32\)
```cj
public init(shape: CPointer < Unit >, position: Vector3, system: CPointer < Unit >, rotation!: Quaternion = Quaternion(), layer!: UInt32 = 1, mass!: Float32 = 80.0f32, maxSlopeAngle!: Float32 = 0.7853982f32)
```
创建角色

参数: 

|名称|类型|描述|
|---|---|---|
|shape|CPointer<Unit>|角色碰撞形状句柄（JPH_Shape 句柄，由调用方创建并保持）position 初始位置（世界坐标）system 物理系统句柄（PhysicsWorld 内部 system，经 _getSystem 传入）rotation 初始旋转（四元数）layer 对象层（0 = NonMoving，1 = Moving）mass 质量（千克）maxSlopeAngle 最大可站立坡度角（弧度）|
|position|Vector3||
|system|CPointer<Unit>||
|rotation|Quaternion||
|layer|UInt32||
|mass|Float32||
|maxSlopeAngle|Float32||

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
角色是否在地面上（OnGround）

返回: 

- 在地面返回 true

### func isValid\(\)
```cj
public func isValid(): Bool
```
是否创建成功（句柄有效且未销毁）

返回: 

- 有效返回 true

### func postSimulation\(Float32\)
```cj
public func postSimulation(maxSeparationDistance: Float32): Unit
```
模拟后处理（检测地面接触，PhysicsWorld.update 后调用）

参数: 

|名称|类型|描述|
|---|---|---|
|maxSeparationDistance|Float32|最大分离距离（米），用于判定"是否离地"|

### func removeFromPhysicsSystem\(\)
```cj
public func removeFromPhysicsSystem(): Unit
```
从物理系统移除角色

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
设置角色线速度（控制移动）

参数: 

|名称|类型|描述|
|---|---|---|
|velocity|Vector3|目标线速度（世界坐标方向）|

### func setPosition\(Vector3,PhysicsActivation\)
```cj
public func setPosition(position: Vector3, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置角色位置（瞬移）

参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3|目标位置（世界坐标）activation 是否激活角色（Activate/DontActivate）|
|activation|PhysicsActivation||

