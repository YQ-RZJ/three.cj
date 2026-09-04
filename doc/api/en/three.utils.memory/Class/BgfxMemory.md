# Class
## class BgfxMemory
```cj
public class BgfxMemory
```
Safe wrapper around bgfx Memory allocation

### func allocInstanceDataBuffer\(UInt32,UInt16\)
```cj
public static func allocInstanceDataBuffer(num: UInt32, stride: UInt16): Box < InstanceDataBuffer >
```
bgfx_alloc_instance_data_buffer: allocates an instance data buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|Number of instancesstride Per-instance stride in bytes|
|stride|UInt16||

Return: 

- The instance data buffer (Box-wrapped)

### func allocTransform\(UInt16\)
```cj
public static func allocTransform(num: UInt16):(Box < Transform >, UInt32)
```
bgfx_alloc_transform: allocates transform matrix memory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt16|Number of matrices|

Return: 

- (Box<Transform> wrapper, cache sequence number)

### func allocTransientBuffers\(CPointer<VertexLayout>,UInt32,UInt32,Bool\)
```cj
public static func allocTransientBuffers(layout: CPointer < VertexLayout >, numVertices: UInt32, numIndices: UInt32, index32: Bool):(Box < TransientVertexBuffer >, Box < TransientIndexBuffer >, Bool)
```
bgfx_alloc_transient_buffers: allocates both transient vertex and index buffers

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|CPointer<VertexLayout>|Vertex layout pointernumVertices Number of verticesnumIndices Number of indicesindex32 Whether to use 32-bit indices|
|numVertices|UInt32||
|numIndices|UInt32||
|index32|Bool||

Return: 

- (TransientVertexBuffer, TransientIndexBuffer, whether successful)

### func allocTransientIndexBuffer\(UInt32,Bool\)
```cj
public static func allocTransientIndexBuffer(num: UInt32, index32: Bool): Box < TransientIndexBuffer >
```
bgfx_alloc_transient_index_buffer: allocates a transient index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|Number of indicesindex32 Whether to use 32-bit indices|
|index32|Bool||

Return: 

- The transient index buffer (Box-wrapped)

### func allocTransientVertexBuffer\(UInt32,VertexLayoutPtr\)
```cj
public static func allocTransientVertexBuffer(num: UInt32, layout: VertexLayoutPtr): Box < TransientVertexBuffer >
```
bgfx_alloc_transient_vertex_buffer: allocates a transient vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|Number of verticeslayout Vertex layout pointer (malloced by the caller)|
|layout|VertexLayoutPtr||

Return: 

- The transient vertex buffer (Box-wrapped)

### func data\(\)
```cj
public func data(): CPointer < UInt8 >
```
Returns the data pointer (for bgfx_set_uniform etc.)

Return: 

- CPointer<UInt8>

### func getAvailInstanceDataBuffer\(UInt32,UInt16\)
```cj
public static func getAvailInstanceDataBuffer(num: UInt32, stride: UInt16): UInt32
```
Queries the available instance data buffer space (bgfx_get_avail_instance_data_buffer)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|Requested countstride Per-instance stride in bytes|
|stride|UInt16||

Return: 

- The available count

### func getAvailTransientIndexBuffer\(UInt32,Bool\)
```cj
public static func getAvailTransientIndexBuffer(num: UInt32, index32: Bool): UInt32
```
Queries the available transient index buffer space (bgfx_get_avail_transient_index_buffer)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|Requested countindex32 Whether to use 32-bit indices|
|index32|Bool||

Return: 

- The available count

### func getAvailTransientVertexBuffer\(UInt32,VertexLayoutPtr\)
```cj
public static func getAvailTransientVertexBuffer(num: UInt32, layout: VertexLayoutPtr): UInt32
```
Queries the available transient vertex buffer space (bgfx_get_avail_transient_vertex_buffer)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|Requested countlayout Vertex layout pointer|
|layout|VertexLayoutPtr||

Return: 

- The available count

### func get\(\)
```cj
public func get(): CPointer < Memory >
```
Returns the raw CPointer<Memory> (for bgfx_create_vertex_buffer etc.)

Return: 

- CPointer<Memory>

### func init\(UInt32\)
```cj
public init(size: UInt32)
```
Allocates memory via bgfx_alloc

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|UInt32|Allocation size in bytes|

### func init\(CPointer<Unit>,UInt32\)
```cj
public init(data: CPointer < Unit >, size: UInt32)
```
Allocates and copies data via bgfx_copy

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|CPointer<Unit>|Source data pointersize Data size in bytes|
|size|UInt32||

### func readFloat\(Int64\)
```cj
public func readFloat(index: Int64): Float32
```
Reads the Float32 value at the given offset

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Element index|

Return: 

- Float32

### func refRelease\(CPointer<Unit>,UInt32,ReleaseFn,CPointer<Unit>\)
```cj
public static func refRelease(data: CPointer < Unit >, size: UInt32, releaseFn: ReleaseFn, userData: CPointer < Unit >): CPointer < Memory >
```
Wraps existing memory via bgfx_make_ref_release (with release callback)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|CPointer<Unit>|Data pointersize Data size in bytesreleaseFn Release callbackuserData Callback user data|
|size|UInt32||
|releaseFn|ReleaseFn||
|userData|CPointer<Unit>||

Return: 

- bgfx Memory pointer (CPointer; the release callback is invoked by bgfx at frame end)

### func ref\(CPointer<Unit>,UInt32\)
```cj
public static func ref(data: CPointer < Unit >, size: UInt32): BgfxMemory
```
Static factory: wraps existing memory via bgfx_make_ref

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Does not copy and does not manage the lifetime.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|CPointer<Unit>|Data pointersize Data size in bytes|
|size|UInt32||

Return: 

- A BgfxMemory instance

### func writeFloat\(Int64,Float32\)
```cj
public func writeFloat(index: Int64, value: Float32): Unit
```
Writes a single Float32 value at the given offset (element index, not bytes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Element indexvalue The Float32 value|
|value|Float32||

### func writeFloats\(Array<Float64>,Int64\)
```cj
public func writeFloats(values: Array < Float64 >, count: Int64): Unit
```
Writes a Float64 array (converted to Float32, up to count elements)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|Array<Float64>|The Float64 arraycount Number of elements to write|
|count|Int64||

### func writeUInt16\(Array<UInt16>,Int64\)
```cj
public func writeUInt16(values: Array < UInt16 >, count: Int64): Unit
```
Writes a UInt16 array (for index buffers)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|Array<UInt16>|The UInt16 arraycount Number of elements to write|
|count|Int64||

### func writeUInt8\(Array<UInt8>,Int64\)
```cj
public func writeUInt8(values: Array < UInt8 >, count: Int64): Unit
```
Writes a UInt8 array

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>For vertex buffers.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|Array<UInt8>|The UInt8 arraycount Number of elements to write|
|count|Int64||

