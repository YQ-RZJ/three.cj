# Class
## class BgfxBufferRenderer
```cj
public class BgfxBufferRenderer
```
bgfx non-indexed buffer renderer

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

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

### func renderMultiDraw\(ViewId,ProgramHandle,Array<Int64>,Array<Int64>,Int64,UInt32\)
```cj
public func renderMultiDraw(viewId: ViewId, program: ProgramHandle, starts: Array < Int64 >, counts: Array < Int64 >, drawCount: Int64, depth: UInt32): Unit
```
Multi-draw (indirect draw)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|ViewId|View IDprogram Shader program handlestarts Start indices arraycounts Vertex count arraydrawCount Number of draw callsdepth Depth value|
|program|ProgramHandle||
|starts|Array<Int64>||
|counts|Array<Int64>||
|drawCount|Int64||
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

