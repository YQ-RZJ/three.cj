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
获取地面状态（0 = OnGround，1 = OnSteepGround，2 = NotSupported，3 = InAir）

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
获取虚拟角色线速度

返回: 

- 当前线速度（世界坐标，three 左手系）

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
获取虚拟角色位置

返回: 

- 当前位置（世界坐标，three 左手系）

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
虚拟角色是否在地面上（GroundState == OnGround）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>update 之后本帧地面状态即有效</p>

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
设置虚拟角色线速度（控制移动）

参数: 

|名称|类型|描述|
|---|---|---|
|velocity|Vector3|目标线速度（世界坐标，three 左手系）|

### func setPosition\(Vector3\)
```cj
public func setPosition(position: Vector3): Unit
```
设置虚拟角色位置（瞬移）

参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3|目标位置（世界坐标，three 左手系）|

### func update\(Float32,Vector3\)
```cj
public func update(deltaTime: Float32, gravity!: Vector3 = Vector3(0.0, - 9.81, 0.0)): Unit
```
更新虚拟角色（每帧在 PhysicsWorld.update 之后调用）

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float32|时间步长（秒）gravity 重力向量（默认 (0,-9.81,0)，与物理世界一致；水平移动请在调用前用 setLinearVelocity 设置，竖直分量会被本方法保留并叠加重力）|
|gravity|Vector3||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
虚拟角色是否有效（创建成功且未销毁）

