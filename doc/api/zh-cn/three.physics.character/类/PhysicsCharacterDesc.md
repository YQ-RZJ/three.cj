# 类
## class PhysicsCharacterDesc
```cj
public class PhysicsCharacterDesc
```
角色控制器描述

### func init\(PhysicsShape,Vector3,Quaternion,UInt32,Float32,Float32\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(), layer!: UInt32 = 1, mass!: Float32 = 70.0f32, maxSlopeAngle!: Float32 = 0.7853982f32)
```
创建角色描述

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|碰撞形状position 初始位置rotation 初始旋转layer 对象层mass 质量（千克）maxSlopeAngle 最大可站立坡度角（弧度）|
|position|Vector3||
|rotation|Quaternion||
|layer|UInt32||
|mass|Float32||
|maxSlopeAngle|Float32||

### var layer
```cj
public var layer: UInt32 = 1
```
对象层（0 = NonMoving，1 = Moving）

### var mass
```cj
public var mass: Float32 = 70.0f32
```
质量（千克，用于冲量计算）

### var maxSlopeAngle
```cj
public var maxSlopeAngle: Float32 = 0.7853982f32
```
最大可站立坡度角（弧度，默认 π/4 = 45°）

### var position
```cj
public var position: Vector3 = Vector3()
```
初始位置（世界空间，three 左手系）

### var rotation
```cj
public var rotation: Quaternion = Quaternion()
```
初始旋转

### let shape
```cj
public let shape: PhysicsShape
```
角色碰撞形状（通常为胶囊）

