# 结构体
## struct PhysicsCompoundPart
```cj
public struct PhysicsCompoundPart
```
复合形状子部件（Compound 用）

### func init\(PhysicsShape,Vector3,Quaternion\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion())
```
创建复合子部件

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|子形状position 相对父级质心的位置（默认原点）rotation 相对父级质心的旋转（默认单位四元数）|
|position|Vector3||
|rotation|Quaternion||

### let position
```cj
public let position: Vector3
```
相对父级质心的位置

### let rotation
```cj
public let rotation: Quaternion
```
相对父级质心的旋转

### let shape
```cj
public let shape: PhysicsShape
```
子形状

