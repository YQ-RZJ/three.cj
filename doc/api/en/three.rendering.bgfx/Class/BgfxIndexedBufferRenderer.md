# Class
## class BgfxIndexedBufferRenderer
```cj
public class BgfxIndexedBufferRenderer
```
bgfx indexed buffer renderer

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
Instanced indexed draw call

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|ViewId|View IDprogram Shader program handlestart Start indexcount Index countprimcount Instance countdepth Depth value|
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|primcount|Int64||
|depth|UInt32||

### func renderMultiDraw\(ViewId,ProgramHandle,Array<Int64>,Array<Int64>,Int64,UInt32\)
```cj
public func renderMultiDraw(viewId: ViewId, program: ProgramHandle, starts: Array < Int64 >, counts: Array < Int64 >, drawCount: Int64, depth: UInt32): Unit
```
Multi-draw indexed rendering

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|ViewId|View IDprogram Shader program handlestarts Start indices arraycounts Index counts arraydrawCount Draw countdepth Depth value|
|program|ProgramHandle||
|starts|Array<Int64>||
|counts|Array<Int64>||
|drawCount|Int64||
|depth|UInt32||

### func render\(ViewId,ProgramHandle,Int64,Int64,UInt32\)
```cj
public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit
```
索引绘制
对照 WebGLIndexedBufferRenderer.render()

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|ViewId||
|program|ProgramHandle||
|start|Int64||
|count|Int64||
|depth|UInt32||

### func setIndex\(UInt32,Int64\)
```cj
public func setIndex(indexType: UInt32, bytesPerElement: Int64): Unit
```
Sets index type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|indexType|UInt32|Index type (0 = UInt16, 1 = UInt32)bytesPerElement Bytes per index element|
|bytesPerElement|Int64||

### func setMode\(UInt64\)
```cj
public func setMode(value: UInt64): Unit
```
Sets draw mode

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|UInt64|Draw mode value|

