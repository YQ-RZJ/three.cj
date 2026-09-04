# Class
## class BgfxInfo
```cj
public class BgfxInfo
```
bgfx rendering statistics

### func beginFrame\(\)
```cj
public func beginFrame(): Unit
```
Called at frame start

### func init\(\)
```cj
public init()
```


### func reset\(\)
```cj
public func reset(): Unit
```
Resets render statistics

### func update\(Int64,UInt64,Int64\)
```cj
public func update(count: Int64, mode: UInt64, instanceCount: Int64): Unit
```
Updates render statistics

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int64|Vertex/index countmode Draw mode (triangles, lines, points, etc.)instanceCount Instance count|
|mode|UInt64||
|instanceCount|Int64||

### var autoReset
```cj
public var autoReset: Bool
```
Whether to auto-reset statistics at frame start

### var memory
```cj
public var memory: BgfxMemoryInfo
```
Memory statistics

### var programs
```cj
public var programs: Option < ArrayList < String >>
```
Shader program list

### var render
```cj
public var render: BgfxRenderInfo
```
Render statistics

