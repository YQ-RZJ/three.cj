# Class
## class ProfGpuZone
```cj
public class ProfGpuZone <: Resource
```
GPU zone scope — wraps GPU command recording

### func close\(\)
```cj
public func close(): Unit
```
Emit gpuZoneEnd (idempotent; auto-called by try-with-resources)

### func init\(String,UInt8,String,UInt32\)
```cj
public init(name: String, context: UInt8, file: String, line: UInt32)
```
Begin a GPU zone (name is the display label, context the GPU
context id)

Parameter: 

|Name|Type|Describe|
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
GPU context id this zone belongs to

### prop query: UInt16
```cj
public prop query: UInt16
```
Query id of this zone (pass to Gpu.time after fence readback)

