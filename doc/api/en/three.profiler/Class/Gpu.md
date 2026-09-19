# Class
## class Gpu
```cj
public class Gpu
```
GPU timing domain — context registration and timestamp reporting

### func calibration\(Int64,Int64,UInt8\)
```cj
public static func calibration(gpuTime: Int64, cpuDelta: Int64, context: UInt8): Unit
```
Clock calibration (CPU/GPU clock-domain drift correction)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gpuTime|Int64||
|cpuDelta|Int64||
|context|UInt8||

### func contextName\(UInt8,String\)
```cj
public static func contextName(context: UInt8, name: String): Unit
```
Name a GPU context (shown in the Tracy GPU panel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|UInt8||
|name|String||

### func newContext\(Int64,Float32,UInt8,UInt8,UInt8\)
```cj
public static func newContext(gpuTime: Int64, period: Float32, context: UInt8, flags: UInt8, kind: UInt8): Unit
```
Register a GPU context (context is the context id, 0-255)

Parameter: 

|Name|Type|Describe|
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
GPU time sync point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gpuTime|Int64||
|context|UInt8||

### func time\(Int64,UInt16,UInt8\)
```cj
public static func time(gpuTime: Int64, queryId: UInt16, context: UInt8): Unit
```
Report a GPU timestamp (after fence/query readback)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gpuTime|Int64||
|queryId|UInt16||
|context|UInt8||

### func zoneBegin\(UInt64,UInt16,UInt8\)
```cj
public static func zoneBegin(srcloc: UInt64, queryId: UInt16, context: UInt8): Unit
```
Begin a GPU zone (queryId pairs with zoneEnd/time)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|srcloc|UInt64||
|queryId|UInt16||
|context|UInt8||

### func zoneEnd\(UInt16,UInt8\)
```cj
public static func zoneEnd(queryId: UInt16, context: UInt8): Unit
```
End a GPU zone (queryId pairs with zoneBegin)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|queryId|UInt16||
|context|UInt8||

