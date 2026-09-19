# 类
## class Gpu
```cj
public class Gpu
```
GPU 时间域 — GPU 上下文注册与 zone 时间戳上报

### func calibration\(Int64,Int64,UInt8\)
```cj
public static func calibration(gpuTime: Int64, cpuDelta: Int64, context: UInt8): Unit
```
时钟校准（CPU/GPU 时钟域漂移修正）

参数: 

|名称|类型|描述|
|---|---|---|
|gpuTime|Int64||
|cpuDelta|Int64||
|context|UInt8||

### func contextName\(UInt8,String\)
```cj
public static func contextName(context: UInt8, name: String): Unit
```
命名 GPU 上下文（Tracy GPU 面板显示）

参数: 

|名称|类型|描述|
|---|---|---|
|context|UInt8||
|name|String||

### func newContext\(Int64,Float32,UInt8,UInt8,UInt8\)
```cj
public static func newContext(gpuTime: Int64, period: Float32, context: UInt8, flags: UInt8, kind: UInt8): Unit
```
注册 GPU 上下文（context 即上下文 id，0-255）

参数: 

|名称|类型|描述|
|---|---|---|
|gpuTime|Int64||
|period|Float32||
|context|UInt8||
|flags|UInt8||
|kind|UInt8||

### func timeSync\(Int64,UInt8\)
```cj
public static func timeSync(gpuTime: Int64, context: UInt8): Unit
```
GPU 时间同步点

参数: 

|名称|类型|描述|
|---|---|---|
|gpuTime|Int64||
|context|UInt8||

### func time\(Int64,UInt16,UInt8\)
```cj
public static func time(gpuTime: Int64, queryId: UInt16, context: UInt8): Unit
```
上报 GPU 时间戳（fence/查询回读后）

参数: 

|名称|类型|描述|
|---|---|---|
|gpuTime|Int64||
|queryId|UInt16||
|context|UInt8||

### func zoneBegin\(UInt64,UInt16,UInt8\)
```cj
public static func zoneBegin(srcloc: UInt64, queryId: UInt16, context: UInt8): Unit
```
GPU zone 开始（queryId 与 zoneEnd/time 配对）

参数: 

|名称|类型|描述|
|---|---|---|
|srcloc|UInt64||
|queryId|UInt16||
|context|UInt8||

### func zoneEnd\(UInt16,UInt8\)
```cj
public static func zoneEnd(queryId: UInt16, context: UInt8): Unit
```
GPU zone 结束（queryId 与 zoneBegin 配对）

参数: 

|名称|类型|描述|
|---|---|---|
|queryId|UInt16||
|context|UInt8||

