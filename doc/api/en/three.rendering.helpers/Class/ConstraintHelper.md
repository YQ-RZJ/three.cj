# Class
## class ConstraintHelper
```cj
public class ConstraintHelper <: Object3D
```
Physics constraint helper object

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases GPU resources

### func init\(\)
```cj
public init()
```
Constructs a Constraint helper

### func init\(PhysicsWorld,PhysicsConstraintDesc,RigidBody,RigidBody,UInt32\)
```cj
public init(world: PhysicsWorld, desc: PhysicsConstraintDesc, bodyA: RigidBody, bodyB: RigidBody, color!: UInt32 = 0xffaa00)
```


Parameter: 

|Name|Type|Describe|
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
Syncs both rigid bodies' state and updates the visualization

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

