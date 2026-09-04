# 类
## class PhysicsBinding
```cj
public class PhysicsBinding
```
Object3D 与物理刚体的绑定便捷 API（静态方法集合，无实例状态）

### func bind\(PhysicsWorld,Object3D,PhysicsShape,PhysicsMotionType,Float64,Float64,Bool,Bool\)
```cj
public static func bind(world: PhysicsWorld, object3d: Object3D, shape: PhysicsShape, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0, syncToObj!: Bool = true, isSensor!: Bool = false): RigidBody
```
创建物理刚体并绑定到渲染对象

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例object3d 需要绑定物理的渲染对象shape 物理形状motionType 运动类型（Dynamic/Kinematic/Static），默认 Dynamicfriction 摩擦系数，默认 0.2restitution 恢复系数，默认 0.0syncToObj 是否每帧把刚体 transform 同步回对象，默认 trueisSensor 是否作为传感器（穿透不产生碰撞），默认 false|
|object3d|Object3D||
|shape|PhysicsShape||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||
|syncToObj|Bool||
|isSensor|Bool||

返回: 

- 返回创建的 RigidBody 实例（用于运行时控制）

### func ground\(PhysicsWorld,Mesh,Float64\)
```cj
public static func ground(world: PhysicsWorld, mesh: Mesh, yPosition!: Float64 = 0.0): RigidBody
```
创建静态地面（大平面）并绑定

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Plane 形状在后端用大盒子近似。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例mesh 用作地面外观的 MeshyPosition 地面 y 坐标，默认 0|
|mesh|Mesh||
|yPosition|Float64||

返回: 

- 返回创建的静态 RigidBody 实例

### func meshBox\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshBox(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
为 Mesh 添加物理（从 BoxGeometry 自动派生 Box 形状）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例mesh 目标 Mesh（将从其几何体派生形状）motionType 运动类型，默认 Dynamicfriction 摩擦系数，默认 0.2restitution 恢复系数，默认 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

返回: 

- 返回创建的 RigidBody 实例

### func meshCapsule\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshCapsule(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
为 Mesh 添加物理（从 CapsuleGeometry 自动派生 Capsule 形状）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>CapsuleGeometry(radius, length) 的 length 含半球帽总高，
halfHeight = (length - 2 * radius) / 2。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例mesh 目标 Mesh（将从其几何体派生形状）motionType 运动类型，默认 Dynamicfriction 摩擦系数，默认 0.2restitution 恢复系数，默认 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

返回: 

- 返回创建的 RigidBody 实例

### func meshCylinder\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshCylinder(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
为 Mesh 添加物理（从 CylinderGeometry 自动派生 Cylinder 形状）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>CylinderGeometry(radiusTop, radiusBottom, height) 的 height 是总高，
halfHeight = height / 2。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例mesh 目标 Mesh（将从其几何体派生形状）motionType 运动类型，默认 Dynamicfriction 摩擦系数，默认 0.2restitution 恢复系数，默认 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

返回: 

- 返回创建的 RigidBody 实例

### func meshSphere\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshSphere(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
为 Mesh 添加物理（从 SphereGeometry 自动派生 Sphere 形状）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例mesh 目标 Mesh（将从其几何体派生形状）motionType 运动类型，默认 Dynamicfriction 摩擦系数，默认 0.2restitution 恢复系数，默认 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

返回: 

- 返回创建的 RigidBody 实例

### func unbind\(PhysicsWorld,Object3D\)
```cj
public static func unbind(world: PhysicsWorld, object3d: Object3D): Unit
```
解除 Mesh 的物理绑定（不销毁刚体）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|物理世界实例object3d 需要解除绑定的渲染对象|
|object3d|Object3D||

