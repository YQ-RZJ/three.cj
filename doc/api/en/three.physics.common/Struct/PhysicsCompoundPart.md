# Struct
## struct PhysicsCompoundPart
```cj
public struct PhysicsCompoundPart
```
Sub-part of a compound shape (used by Compound)

### func init\(PhysicsShape,Vector3,Quaternion\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion())
```
Creates a compound sub-part

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The sub-shapeposition Position relative to the parent's center of mass (origin by default)rotation Rotation relative to the parent's center of mass (identity by default)|
|position|Vector3||
|rotation|Quaternion||

### let position
```cj
public let position: Vector3
```
Position relative to the parent's center of mass

### let rotation
```cj
public let rotation: Quaternion
```
Rotation relative to the parent's center of mass

### let shape
```cj
public let shape: PhysicsShape
```
The sub-shape

