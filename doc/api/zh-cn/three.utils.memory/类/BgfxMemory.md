# 类
## class BgfxMemory
```cj
public class BgfxMemory
```
安全包装 bgfx Memory 分配

### func allocInstanceDataBuffer\(UInt32,UInt16\)
```cj
public static func allocInstanceDataBuffer(num: UInt32, stride: UInt16): Box < InstanceDataBuffer >
```
bgfx_alloc_instance_data_buffer：分配实例数据缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|实例数量stride 每实例步长（字节）|
|stride|UInt16||

返回: 

- 实例数据缓冲（Box 包装）

### func allocTransform\(UInt16\)
```cj
public static func allocTransform(num: UInt16):(Box < Transform >, UInt32)
```
bgfx_alloc_transform：分配变换矩阵内存

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt16|矩阵数量|

返回: 

- (Transform Box 包装, cache 序号)

### func allocTransientBuffers\(CPointer<VertexLayout>,UInt32,UInt32,Bool\)
```cj
public static func allocTransientBuffers(layout: CPointer < VertexLayout >, numVertices: UInt32, numIndices: UInt32, index32: Bool):(Box < TransientVertexBuffer >, Box < TransientIndexBuffer >, Bool)
```
bgfx_alloc_transient_buffers：同时分配瞬态顶点+索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|layout|CPointer<VertexLayout>|顶点布局指针numVertices 顶点数量numIndices 索引数量index32 是否 32bit 索引|
|numVertices|UInt32||
|numIndices|UInt32||
|index32|Bool||

返回: 

- (TransientVertexBuffer, TransientIndexBuffer, 是否成功)

### func allocTransientIndexBuffer\(UInt32,Bool\)
```cj
public static func allocTransientIndexBuffer(num: UInt32, index32: Bool): Box < TransientIndexBuffer >
```
bgfx_alloc_transient_index_buffer：分配瞬态索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|索引数量index32 是否 32bit 索引|
|index32|Bool||

返回: 

- 瞬态索引缓冲（Box 包装）

### func allocTransientVertexBuffer\(UInt32,VertexLayoutPtr\)
```cj
public static func allocTransientVertexBuffer(num: UInt32, layout: VertexLayoutPtr): Box < TransientVertexBuffer >
```
bgfx_alloc_transient_vertex_buffer：分配瞬态顶点缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|顶点数量layout 顶点布局指针（由调用方 malloc）|
|layout|VertexLayoutPtr||

返回: 

- 瞬态顶点缓冲（Box 包装）

### func data\(\)
```cj
public func data(): CPointer < UInt8 >
```
获取数据指针（用于 bgfx_set_uniform 等 API）

返回: 

- CPointer<UInt8>

### func getAvailInstanceDataBuffer\(UInt32,UInt16\)
```cj
public static func getAvailInstanceDataBuffer(num: UInt32, stride: UInt16): UInt32
```
查询可用实例数据缓冲量（bgfx_get_avail_instance_data_buffer）

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|请求数量stride 每实例步长（字节）|
|stride|UInt16||

返回: 

- 可用数量

### func getAvailTransientIndexBuffer\(UInt32,Bool\)
```cj
public static func getAvailTransientIndexBuffer(num: UInt32, index32: Bool): UInt32
```
查询可用瞬态索引缓冲量（bgfx_get_avail_transient_index_buffer）

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|请求数量index32 是否 32bit 索引|
|index32|Bool||

返回: 

- 可用数量

### func getAvailTransientVertexBuffer\(UInt32,VertexLayoutPtr\)
```cj
public static func getAvailTransientVertexBuffer(num: UInt32, layout: VertexLayoutPtr): UInt32
```
查询可用瞬态顶点缓冲量（bgfx_get_avail_transient_vertex_buffer）

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|请求数量layout 顶点布局指针|
|layout|VertexLayoutPtr||

返回: 

- 可用数量

### func get\(\)
```cj
public func get(): CPointer < Memory >
```
获取原始 CPointer<Memory>（给 bgfx_create_vertex_buffer 等 API 使用）

返回: 

- CPointer<Memory>

### func init\(CPointer<Unit>,UInt32\)
```cj
public init(data: CPointer < Unit >, size: UInt32)
```
通过 bgfx_copy 分配并拷贝数据

参数: 

|名称|类型|描述|
|---|---|---|
|data|CPointer<Unit>|源数据指针size 数据大小（字节）|
|size|UInt32||

### func init\(UInt32\)
```cj
public init(size: UInt32)
```
通过 bgfx_alloc 分配内存

参数: 

|名称|类型|描述|
|---|---|---|
|size|UInt32|分配大小（字节）|

### func readFloat\(Int64\)
```cj
public func readFloat(index: Int64): Float32
```
读取指定偏移的 Float32 值

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|元素索引|

返回: 

- Float32

### func refRelease\(CPointer<Unit>,UInt32,ReleaseFn,CPointer<Unit>\)
```cj
public static func refRelease(data: CPointer < Unit >, size: UInt32, releaseFn: ReleaseFn, userData: CPointer < Unit >): CPointer < Memory >
```
通过 bgfx_make_ref_release 包装已有内存（释放时回调）

参数: 

|名称|类型|描述|
|---|---|---|
|data|CPointer<Unit>|数据指针size 数据大小（字节）releaseFn 释放回调userData 回调用户数据|
|size|UInt32||
|releaseFn|ReleaseFn||
|userData|CPointer<Unit>||

返回: 

- bgfx Memory 指针（CPointer，释放回调由 bgfx 在帧末调用）

### func ref\(CPointer<Unit>,UInt32\)
```cj
public static func ref(data: CPointer < Unit >, size: UInt32): BgfxMemory
```
静态工厂：通过 bgfx_make_ref 包装已有内存

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>不拷贝，不管理生命周期。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|data|CPointer<Unit>|数据指针size 数据大小（字节）|
|size|UInt32||

返回: 

- BgfxMemory 实例

### func writeFloat\(Int64,Float32\)
```cj
public func writeFloat(index: Int64, value: Float32): Unit
```
写入单个 Float32 值到指定偏移（float 数，非字节）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|元素索引value Float32 值|
|value|Float32||

### func writeFloats\(Array<Float64>,Int64\)
```cj
public func writeFloats(values: Array < Float64 >, count: Int64): Unit
```
写入 Float64 数组（转为 Float32，按 count 个元素写入）

参数: 

|名称|类型|描述|
|---|---|---|
|values|Array<Float64>|Float64 数组count 写入元素数量|
|count|Int64||

### func writeUInt16\(Array<UInt16>,Int64\)
```cj
public func writeUInt16(values: Array < UInt16 >, count: Int64): Unit
```
写入 UInt16 数组（用于索引缓冲区）

参数: 

|名称|类型|描述|
|---|---|---|
|values|Array<UInt16>|UInt16 数组count 写入元素数量|
|count|Int64||

### func writeUInt8\(Array<UInt8>,Int64\)
```cj
public func writeUInt8(values: Array < UInt8 >, count: Int64): Unit
```
写入 UInt8 数组

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>用于顶点缓冲区。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|values|Array<UInt8>|UInt8 数组count 写入元素数量|
|count|Int64||

