# Struct
## struct PhysicsBodyHandle
```cj
public struct PhysicsBodyHandle
```
Physics body handle (backend-agnostic)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>bodyID uses UInt32 for compatibility with the Jolt BodyID; other backends
may map their internal IDs to UInt32.</p>

### func init\(UInt32\)
```cj
public init(bodyID!: UInt32)
```
Creates a body handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bodyID|UInt32|The backend-assigned body ID|

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the handle is valid

Return: 

- true if valid

### let INVALID
```cj
public static let INVALID: PhysicsBodyHandle = PhysicsBodyHandle(bodyID: 0xFFFFFFFF)
```
The invalid handle

### let bodyID
```cj
public let bodyID: UInt32
```
The body ID

