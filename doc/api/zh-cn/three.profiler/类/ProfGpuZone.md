# 类
## class ProfGpuZone
```cj
public class ProfGpuZone <: Resource
```
GPU zone 作用域 — try/finally 或宏包裹 GPU 命令区间

### func close\(\)
```cj
public func close(): Unit
```
发射 gpuZoneEnd（幂等；try-with-resources 自动调用）

### func init\(String,UInt8,String,UInt32\)
```cj
public init(name: String, context: UInt8, file: String, line: UInt32)
```
开始一个 GPU zone（name 为显示名，context 为 GPU 上下文 id）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|context|UInt8||
|file|String||
|line|UInt32||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed

### prop ctx: UInt8
```cj
public prop ctx: UInt8
```
本 zone 所属 GPU 上下文 id

### prop query: UInt16
```cj
public prop query: UInt16
```
本 zone 的 queryId（渲染 backend fence 回读后传给 Gpu.time）

