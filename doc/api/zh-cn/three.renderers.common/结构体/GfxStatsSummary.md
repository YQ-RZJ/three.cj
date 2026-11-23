# 结构体
## struct GfxStatsSummary
```cj
public struct GfxStatsSummary
```
帧统计摘要

### func init\(Float64,Float64,UInt32,UInt32,UInt32,Int64\)
```cj
public init(cpuTimeFrame!: Float64 = 0.0, gpuTimeFrame!: Float64 = 0.0, drawCalls!: UInt32 = 0u32, computeCalls!: UInt32 = 0u32, blitCalls!: UInt32 = 0u32, textureMemoryUsed!: Int64 = 0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|cpuTimeFrame|Float64||
|gpuTimeFrame|Float64||
|drawCalls|UInt32||
|computeCalls|UInt32||
|blitCalls|UInt32||
|textureMemoryUsed|Int64||

### let blitCalls
```cj
public let blitCalls: UInt32
```
blit 调用数

### let computeCalls
```cj
public let computeCalls: UInt32
```
计算调用数

### let cpuTimeFrame
```cj
public let cpuTimeFrame: Float64
```
CPU 帧耗时（毫秒）

### let drawCalls
```cj
public let drawCalls: UInt32
```
绘制调用数

### let gpuTimeFrame
```cj
public let gpuTimeFrame: Float64
```
GPU 帧耗时（毫秒）

### let textureMemoryUsed
```cj
public let textureMemoryUsed: Int64
```
纹理显存占用（字节）

