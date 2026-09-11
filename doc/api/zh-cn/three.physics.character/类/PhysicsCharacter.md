# 类
## class PhysicsCharacter
```cj
public class PhysicsCharacter
```
基于刚体的角色（对应 JPH_Character）

### func addToPhysicsSystem\(PhysicsActivation\)
```cj
public func addToPhysicsSystem(activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
将角色加入物理系统

参数: 

|名称|类型|描述|
|---|---|---|
|activation|PhysicsActivation|是否立即激活（默认 Activate）|

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁角色（自动从物理系统移除并释放底层句柄）

### func getGroundState\(\)
```cj
public func getGroundState(): UInt32
```
获取地面状态（0 = OnGround，1 = OnSteepGround，2 = NotSupported，3 = InAir）

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
获取角色线速度

返回: 

- 当前线速度（世界坐标，three 左手系）

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
获取角色位置

返回: 

- 当前位置（世界坐标，three 左手系）

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
角色是否在地面上（GroundState == OnGround）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>需先调用 postSimulation 刷新地面状态</p>

### func postSimulation\(Float32\)
```cj
public func postSimulation(maxSeparationDistance!: Float32 = 0.05f32): Unit
```
模拟后处理（检测地面接触）

参数: 

|名称|类型|描述|
|---|---|---|
|maxSeparationDistance|Float32|最大分离距离（米），默认 0.05|

### func removeFromPhysicsSystem\(\)
```cj
public func removeFromPhysicsSystem(): Unit
```
从物理系统移除角色（可再次 addToPhysicsSystem 加入）

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
设置角色线速度（控制移动）

参数: 

|名称|类型|描述|
|---|---|---|
|velocity|Vector3|目标线速度（世界坐标，three 左手系）|

### func setPosition\(Vector3,PhysicsActivation\)
```cj
public func setPosition(position: Vector3, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
设置角色位置（瞬移）

参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3|目标位置（世界坐标，three 左手系）activation 是否立即激活（默认 Activate）|
|activation|PhysicsActivation||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
角色是否有效（创建成功且未销毁）

