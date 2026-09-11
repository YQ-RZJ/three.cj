# 类
## class ConstraintHelper
```cj
public class ConstraintHelper <: Object3D
```
物理约束辅助对象

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(\)
```cj
public init()
```
构造 Constraint 辅助对象

### func init\(PhysicsWorld,PhysicsConstraintDesc,RigidBody,RigidBody,UInt32\)
```cj
public init(world: PhysicsWorld, desc: PhysicsConstraintDesc, bodyA: RigidBody, bodyB: RigidBody, color!: UInt32 = 0xffaa00)
```


参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld||
|desc|PhysicsConstraintDesc||
|bodyA|RigidBody||
|bodyB|RigidBody||
|color|UInt32||

### func update\(\)
```cj
public func update(): Unit
```
同步两端刚体状态并更新可视化

### var anchorA
```cj
public var anchorA: PointLightHelper
```
锚点 A 标记

### var anchorB
```cj
public var anchorB: PointLightHelper
```
锚点 B 标记

### var axisArrow
```cj
public var axisArrow: ArrowHelper
```
约束轴箭头

### var bodyA
```cj
public var bodyA: RigidBody
```
刚体 A

### var bodyB
```cj
public var bodyB: RigidBody
```
刚体 B

### var color
```cj
public var color: UInt32
```
辅助对象颜色

### var connection
```cj
public var connection: Line
```
两锚点连线

### var desc
```cj
public var desc: PhysicsConstraintDesc
```
约束创建描述

### var world
```cj
public var world: PhysicsWorld
```
所属物理世界

