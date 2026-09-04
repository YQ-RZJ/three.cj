# Class
## class RigidBodyHelper
```cj
public class RigidBodyHelper <: Object3D
```


### func dispose\(\)
```cj
public func dispose(): Unit
```


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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape||

Return: 

- 

### func update\(\)
```cj
public func update(): Unit
```


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

