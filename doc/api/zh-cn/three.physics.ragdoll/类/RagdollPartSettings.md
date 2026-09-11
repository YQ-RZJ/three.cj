# 类
## class RagdollPartSettings
```cj
public class RagdollPartSettings
```
布娃娃单个部件描述（一个物理刚体 + 可选的到父级关节）

### func init\(PhysicsShape,Vector3,Quaternion,PhysicsMotionType,UInt32,Float32,Option<RagdollJoint>\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(), motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, layer!: UInt32 = 1, mass!: Float32 = 0.0f32, toParent!: Option < RagdollJoint >= None)
```
创建部件描述

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|碰撞形状（PhysicsShape.box/sphere/capsule/...）position 初始位置rotation 初始旋转motionType 运动类型layer 对象层mass 质量（<=0 自动）toParent 到父级关节|
|position|Vector3||
|rotation|Quaternion||
|motionType|PhysicsMotionType||
|layer|UInt32||
|mass|Float32||
|toParent|Option<RagdollJoint>||

### var layer
```cj
public var layer: UInt32 = 1
```


### var mass
```cj
public var mass: Float32 = 0.0f32
```


### var motionType
```cj
public var motionType: PhysicsMotionType = PhysicsMotionType.Dynamic
```


### var position
```cj
public var position: Vector3 = Vector3()
```


### var rotation
```cj
public var rotation: Quaternion = Quaternion()
```


### let shape
```cj
public let shape: PhysicsShape
```


### var toParent
```cj
public var toParent: Option < RagdollJoint >= None
```


