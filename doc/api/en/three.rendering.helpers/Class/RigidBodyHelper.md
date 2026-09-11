# Class
## class RigidBodyHelper
```cj
public class RigidBodyHelper <: Object3D
```
Physics rigid body helper object

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases GPU resources

### func init\(\)
```cj
public init()
```
Constructs a RigidBody helper

### func init\(RigidBody,PhysicsShape,UInt32\)
```cj
public init(body: RigidBody, shape!: PhysicsShape = PhysicsShape.box(1.0, 1.0, 1.0), color!: UInt32 = 0x00ff00)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|body|RigidBody||
|shape|PhysicsShape||
|color|UInt32||

### func setShape\(PhysicsShape\)
```cj
public func setShape(shape: PhysicsShape): RigidBodyHelper
```
Replaces the collision shape to display

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The new collision shape|

Return: 

- Self reference

### func update\(\)
```cj
public func update(): Unit
```
Syncs the rigid body state and updates the visualization

### var angularVelocityArrow
```cj
public var angularVelocityArrow: ArrowHelper
```
角速度箭头

### var body
```cj
public var body: RigidBody
```
被可视化的物理刚体

### var color
```cj
public var color: UInt32
```
辅助对象颜色

### var shapeLines
```cj
public var shapeLines: LineSegments
```
形状线框

### var shape
```cj
public var shape: PhysicsShape
```
当前显示用的碰撞形状（构造时传入，默认 Box）

### var velocityArrow
```cj
public var velocityArrow: ArrowHelper
```
线速度箭头

