# 类
## class BgfxInfo
```cj
public class BgfxInfo
```
bgfx 渲染统计

### func beginFrame\(\)
```cj
public func beginFrame(): Unit
```
帧开始时调用

### func init\(\)
```cj
public init()
```


### func reset\(\)
```cj
public func reset(): Unit
```
重置渲染统计

### func update\(Int64,UInt64,Int64\)
```cj
public func update(count: Int64, mode: UInt64, instanceCount: Int64): Unit
```
更新渲染统计

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int64|顶点/索引数量mode 绘制模式（三角形、线段、点等）instanceCount 实例数量|
|mode|UInt64||
|instanceCount|Int64||

### var autoReset
```cj
public var autoReset: Bool
```
是否自动重置统计（每帧开始时重置）

### var memory
```cj
public var memory: BgfxMemoryInfo
```
内存统计

### var programs
```cj
public var programs: Option < ArrayList < String >>
```
着色器程序列表

### var render
```cj
public var render: BgfxRenderInfo
```
渲染统计

