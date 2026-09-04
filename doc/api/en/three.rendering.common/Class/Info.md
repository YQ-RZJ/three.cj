# Class
## class Info
```cj
public open class Info
```
Rendering statistics

### func init\(\)
```cj
public init()
```
Constructs default render info

### func reset\(\)
```cj
public func reset(): Unit
```
Resets render statistics

### func update\(Int64\)
```cj
public func update(frame: Int64): Unit
```
Updates the current frame number

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frame|Int64|Frame number|

### var autoReset
```cj
public var autoReset: Bool
```
Whether to automatically reset statistics each frame

### var calls
```cj
public var calls: Int64
```
Total draw call count

### var compute
```cj
public var compute: ComputeInfo
```
Compute sub-statistics

### var frame
```cj
public var frame: Int64
```
Current frame number

### var memory
```cj
public var memory: MemoryInfo
```
Memory sub-statistics

### var render
```cj
public var render: RenderInfo
```
Render sub-statistics

### var triangles
```cj
public var triangles: Int64
```
Total triangle count

### var vertices
```cj
public var vertices: Int64
```
Total vertex count

