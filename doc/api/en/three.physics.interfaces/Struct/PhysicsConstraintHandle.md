# Struct
## struct PhysicsConstraintHandle
```cj
public struct PhysicsConstraintHandle
```
Constraint handle (backend-agnostic)

### func init\(UInt32\)
```cj
public init(constraintID!: UInt32)
```
Creates a constraint handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|constraintID|UInt32|The backend-assigned constraint ID|

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the handle is valid

Return: 

- true if valid

### let INVALID
```cj
public static let INVALID: PhysicsConstraintHandle = PhysicsConstraintHandle(constraintID: 0xFFFFFFFF)
```
The invalid handle

### let constraintID
```cj
public let constraintID: UInt32
```
The constraint ID

