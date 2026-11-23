# 结构体
## struct PhysicsBodyHandle
```cj
public struct PhysicsBodyHandle
```
物理刚体句柄（后端无关）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>bodyID 选用 UInt32 与 Jolt BodyID 兼容；其他后端可自行映射内部 ID 到 UInt32。</p>

### func init\(UInt32\)
```cj
public init(bodyID!: UInt32)
```
创建刚体句柄

参数: 

|名称|类型|描述|
|---|---|---|
|bodyID|UInt32|后端分配的刚体 ID|

### func isValid\(\)
```cj
public func isValid(): Bool
```
是否有效

返回: 

- 有效返回 true

### let INVALID
```cj
public static let INVALID: PhysicsBodyHandle = PhysicsBodyHandle(bodyID: 0xFFFFFFFF)
```
无效句柄

### let bodyID
```cj
public let bodyID: UInt32
```
刚体 ID

