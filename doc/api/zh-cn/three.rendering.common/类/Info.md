# 类
## class Info
```cj
public open class Info
```
渲染统计信息

### func init\(\)
```cj
public init()
```
构造默认渲染信息

### func reset\(\)
```cj
public func reset(): Unit
```
重置渲染统计

### func update\(Int64\)
```cj
public func update(frame: Int64): Unit
```
更新当前帧号

参数: 

|名称|类型|描述|
|---|---|---|
|frame|Int64|帧号|

### var autoReset
```cj
public var autoReset: Bool
```
是否每帧自动重置统计

### var calls
```cj
public var calls: Int64
```
总 draw call 数

### var compute
```cj
public var compute: ComputeInfo
```
计算子统计

### var frame
```cj
public var frame: Int64
```
当前帧号

### var memory
```cj
public var memory: MemoryInfo
```
内存子统计

### var render
```cj
public var render: RenderInfo
```
渲染子统计

### var triangles
```cj
public var triangles: Int64
```
总三角形数

### var vertices
```cj
public var vertices: Int64
```
总顶点数

