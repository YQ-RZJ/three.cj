# 结构体
## struct PhysicsConstraintHandle
```cj
public struct PhysicsConstraintHandle
```
约束句柄（后端无关）

### func init\(UInt32\)
```cj
public init(constraintID!: UInt32)
```
创建约束句柄

参数: 

|名称|类型|描述|
|---|---|---|
|constraintID|UInt32|后端分配的约束 ID|

### func isValid\(\)
```cj
public func isValid(): Bool
```
是否有效

返回: 

- 有效返回 true

### let INVALID
```cj
public static let INVALID: PhysicsConstraintHandle = PhysicsConstraintHandle(constraintID: 0xFFFFFFFF)
```
无效句柄

### let constraintID
```cj
public let constraintID: UInt32
```
约束 ID

