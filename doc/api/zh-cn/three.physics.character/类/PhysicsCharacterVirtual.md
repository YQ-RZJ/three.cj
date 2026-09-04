# 类
## class PhysicsCharacterVirtual
```cj
public class PhysicsCharacterVirtual
```
虚拟角色（对应 JPH_CharacterVirtual）

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁虚拟角色并释放底层句柄

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
获取虚拟角色线速度

返回: 

- 当前线速度（世界坐标）

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
获取虚拟角色位置

返回: 

- 当前位置（世界坐标）

### func init\(CPointer<Unit>,Vector3,CPointer<Unit>,Quaternion,Float32,Float32\)
```cj
public init(shape: CPointer < Unit >, position: Vector3, system: CPointer < Unit >, rotation!: Quaternion = Quaternion(), mass!: Float32 = 70.0f32, maxSlopeAngle!: Float32 = 0.7853982f32)
```
创建虚拟角色

参数: 

|名称|类型|描述|
|---|---|---|
|shape|CPointer<Unit>|角色碰撞形状句柄（JPH_Shape 句柄，由调用方创建并保持）position 初始位置（世界坐标）system 物理系统句柄rotation 初始旋转（四元数）mass 质量（千克，用于冲量计算）maxSlopeAngle 最大可站立坡度角（弧度）|
|position|Vector3||
|system|CPointer<Unit>||
|rotation|Quaternion||
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

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
设置虚拟角色线速度（控制移动）

参数: 

|名称|类型|描述|
|---|---|---|
|velocity|Vector3|目标线速度（世界坐标方向）|

### func setPosition\(Vector3\)
```cj
public func setPosition(position: Vector3): Unit
```
设置虚拟角色位置（瞬移）

参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3|目标位置（世界坐标）|

### func update\(Float32,UInt32,CPointer<Unit>\)
```cj
public func update(deltaTime: Float32, layer: UInt32, system: CPointer < Unit >): Unit
```
更新虚拟角色（每帧调用）

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float32|时间步长（秒）layer 对象层（角色移动时的碰撞层）system 物理系统句柄|
|layer|UInt32||
|system|CPointer<Unit>||

