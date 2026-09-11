# 类
## class RigidBodyHelper
```cj
public class RigidBodyHelper <: Object3D
```
物理刚体辅助对象

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(\)
```cj
public init()
```
构造 RigidBody 辅助对象

### func init\(RigidBody,PhysicsShape,UInt32\)
```cj
public init(body: RigidBody, shape!: PhysicsShape = PhysicsShape.box(1.0, 1.0, 1.0), color!: UInt32 = 0x00ff00)
```


参数: 

|名称|类型|描述|
|---|---|---|
|body|RigidBody||
|shape|PhysicsShape||
|color|UInt32||

### func setShape\(PhysicsShape\)
```cj
public func setShape(shape: PhysicsShape): RigidBodyHelper
```
更换要显示的碰撞形状

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|新的碰撞形状|

返回: 

- 自身引用

### func update\(\)
```cj
public func update(): Unit
```
同步刚体状态并更新可视化

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

