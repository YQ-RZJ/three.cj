# Class
## class BgfxBackendBufferRenderer
```cj
public class BgfxBackendBufferRenderer
```
bgfx backend buffer renderer

### func init\(BgfxBufferRenderer\)
```cj
public init(renderer!: BgfxBufferRenderer = BgfxBufferRenderer())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxBufferRenderer||

### func renderInstances\(ViewId,ProgramHandle,Int64,Int64,Int64,UInt32\)
```cj
public func renderInstances(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, primcount: Int64, depth: UInt32): Unit
```
Instanced non-indexed draw

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|ViewId|View IDprogram Shader program handlestart Start vertex indexcount Number of vertices to drawprimcount Instance countdepth Depth value|
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|primcount|Int64||
|depth|UInt32||

### func render\(ViewId,ProgramHandle,Int64,Int64,UInt32\)
```cj
public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit
```
Non-indexed draw

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|ViewId|View IDprogram Shader program handlestart Start vertex indexcount Number of vertices to drawdepth Depth value|
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|depth|UInt32||

### func setMode\(UInt64\)
```cj
public func setMode(value: UInt64): Unit
```
Set draw mode

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|UInt64|Draw mode value|

