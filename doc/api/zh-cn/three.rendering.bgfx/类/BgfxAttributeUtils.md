# 类
## class BgfxAttributeUtils
```cj
public class BgfxAttributeUtils
```
bgfx 顶点属性工具

### func computeStride\(Array<BgfxAttributeDesc>\)
```cj
public func computeStride(attributes: Array < BgfxAttributeDesc >): UInt16
```
计算顶点步长

参数: 

|名称|类型|描述|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|属性描述列表|

返回: 

- 顶点步长（字节）

### func createVertexLayout\(Array<BgfxAttributeDesc>\)
```cj
public func createVertexLayout(attributes: Array < BgfxAttributeDesc >): VertexLayoutHandle
```
创建顶点布局

参数: 

|名称|类型|描述|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|属性描述列表|

返回: 

- 顶点布局句柄

### func init\(\)
```cj
public init()
```


### func topologyConvert\(UInt32,PtrArray<UInt8>,UInt32,PtrArray<UInt8>,UInt32,Bool\)
```cj
public func topologyConvert(conversion: UInt32, dst: PtrArray < UInt8 >, dstSize: UInt32, indices: PtrArray < UInt8 >, numIndices: UInt32, index32: Bool): UInt32
```
拓扑转换（返回转换后索引数）

参数: 

|名称|类型|描述|
|---|---|---|
|conversion|UInt32|转换类型dst 目标索引缓冲dstSize 目标缓冲大小indices 源索引数据numIndices 索引数index32 是否使用 32 位索引|
|dst|PtrArray<UInt8>||
|dstSize|UInt32||
|indices|PtrArray<UInt8>||
|numIndices|UInt32||
|index32|Bool||

返回: 

- 转换后索引数

### func topologySortTriList\(UInt32,PtrArray<UInt8>,UInt32,PtrArray<Float32>,PtrArray<Float32>,PtrArray<UInt8>,UInt32,PtrArray<UInt8>,UInt32,Bool\)
```cj
public func topologySortTriList(sort: UInt32, dst: PtrArray < UInt8 >, dstSize: UInt32, dir: PtrArray < Float32 >, pos: PtrArray < Float32 >, vertices: PtrArray < UInt8 >, stride: UInt32, indices: PtrArray < UInt8 >, numIndices: UInt32, index32: Bool): Unit
```
三角形列表排序（透明物体排序）

参数: 

|名称|类型|描述|
|---|---|---|
|sort|UInt32|排序类型dst 目标索引缓冲dstSize 目标缓冲大小dir 排序方向pos 排序位置vertices 顶点数据stride 顶点步长indices 索引数据numIndices 索引数index32 是否使用 32 位索引|
|dst|PtrArray<UInt8>||
|dstSize|UInt32||
|dir|PtrArray<Float32>||
|pos|PtrArray<Float32>||
|vertices|PtrArray<UInt8>||
|stride|UInt32||
|indices|PtrArray<UInt8>||
|numIndices|UInt32||
|index32|Bool||

### func vertexConvert\(VertexLayoutPtr,PtrArray<UInt8>,VertexLayoutPtr,PtrArray<UInt8>,UInt32\)
```cj
public func vertexConvert(dstLayout: VertexLayoutPtr, dstData: PtrArray < UInt8 >, srcLayout: VertexLayoutPtr, srcData: PtrArray < UInt8 >, num: UInt32): Unit
```
顶点数据格式转换（layout A → layout B）

参数: 

|名称|类型|描述|
|---|---|---|
|dstLayout|VertexLayoutPtr|目标顶点布局指针dstData 目标数据缓冲srcLayout 源顶点布局指针srcData 源数据缓冲num 顶点数|
|dstData|PtrArray<UInt8>||
|srcLayout|VertexLayoutPtr||
|srcData|PtrArray<UInt8>||
|num|UInt32||

### func vertexLayoutDecode\(VertexLayoutPtr,UInt32,PtrArray<UInt8>,PtrArray<UInt32>,PtrArray<Bool>,PtrArray<Bool>\)
```cj
public func vertexLayoutDecode(layout: VertexLayoutPtr, attrib: UInt32, num: PtrArray < UInt8 >, `type`: PtrArray < UInt32 >, normalized: PtrArray < Bool >, asInt: PtrArray < Bool >): Unit
```
解码顶点布局的属性信息

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutPtr|顶点布局指针（VertexLayoutPtr 包装）attrib 属性语义（Attrib.value()）num 输出分量数（PtrArray 输出）type 输出数据类型（PtrArray 输出）normalized 输出是否归一化（PtrArray 输出）asInt 输出是否整数（PtrArray 输出）|
|attrib|UInt32||
|num|PtrArray<UInt8>||
|`type`|PtrArray<UInt32>||
|normalized|PtrArray<Bool>||
|asInt|PtrArray<Bool>||

### func vertexLayoutGetOffset\(VertexLayoutPtr,UInt32\)
```cj
public func vertexLayoutGetOffset(layout: VertexLayoutPtr, attrib: UInt32): UInt16
```
获取属性偏移（字节）

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutPtr|顶点布局指针attrib 属性语义|
|attrib|UInt32||

返回: 

- 属性偏移（字节）

### func vertexLayoutGetSize\(VertexLayoutPtr,UInt32\)
```cj
public func vertexLayoutGetSize(layout: VertexLayoutPtr, num: UInt32): UInt32
```
获取属性分量大小（字节）

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutPtr|顶点布局指针num 分量数|
|num|UInt32||

返回: 

- 属性分量大小（字节）

### func vertexLayoutGetStride\(VertexLayoutPtr\)
```cj
public func vertexLayoutGetStride(layout: VertexLayoutPtr): UInt16
```
获取布局步长（字节）

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutPtr|顶点布局指针|

返回: 

- 布局步长（字节）

### func vertexLayoutHas\(VertexLayoutPtr,UInt32\)
```cj
public func vertexLayoutHas(layout: VertexLayoutPtr, attrib: UInt32): Bool
```
查询布局是否包含某属性

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutPtr|顶点布局指针attrib 属性语义|
|attrib|UInt32||

返回: 

- 是否包含该属性

### func vertexLayoutSkip\(VertexLayoutPtr,UInt8\)
```cj
public func vertexLayoutSkip(layout: VertexLayoutPtr, num: UInt8): VertexLayoutPtr
```
跳过 num 个属性分量（布局构建游标推进）

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutPtr|顶点布局指针num 跳过的分量数|
|num|UInt8||

返回: 

- 更新后的顶点布局指针

### func vertexPack\(PtrArray<Float32>,Bool,UInt32,VertexLayoutPtr,PtrArray<UInt8>,UInt32\)
```cj
public func vertexPack(input: PtrArray < Float32 >, inputNormalized: Bool, attr: UInt32, layout: VertexLayoutPtr, data: PtrArray < UInt8 >, index: UInt32): Unit
```
打包顶点数据到缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|input|PtrArray<Float32>|输入浮点数据inputNormalized 输入是否归一化attr 属性语义layout 顶点布局指针data 目标数据缓冲index 顶点索引|
|inputNormalized|Bool||
|attr|UInt32||
|layout|VertexLayoutPtr||
|data|PtrArray<UInt8>||
|index|UInt32||

### func vertexUnpack\(PtrArray<Float32>,UInt32,VertexLayoutPtr,PtrArray<UInt8>,UInt32\)
```cj
public func vertexUnpack(output: PtrArray < Float32 >, attr: UInt32, layout: VertexLayoutPtr, data: PtrArray < UInt8 >, index: UInt32): Unit
```
从缓冲解包顶点数据

参数: 

|名称|类型|描述|
|---|---|---|
|output|PtrArray<Float32>|输出浮点数据attr 属性语义layout 顶点布局指针data 源数据缓冲index 顶点索引|
|attr|UInt32||
|layout|VertexLayoutPtr||
|data|PtrArray<UInt8>||
|index|UInt32||

### func weldVertices\(PtrArray<UInt8>,VertexLayoutPtr,PtrArray<UInt8>,UInt32,Bool,Float32\)
```cj
public func weldVertices(output: PtrArray < UInt8 >, layout: VertexLayoutPtr, data: PtrArray < UInt8 >, num: UInt32, index32: Bool, epsilon: Float32): UInt32
```
顶点焊接（按 epsilon 去重，返回焊接后顶点数）

参数: 

|名称|类型|描述|
|---|---|---|
|output|PtrArray<UInt8>|输出焊接后数据layout 顶点布局指针data 源数据缓冲num 顶点数index32 是否使用 32 位索引epsilon 焊接阈值|
|layout|VertexLayoutPtr||
|data|PtrArray<UInt8>||
|num|UInt32||
|index32|Bool||
|epsilon|Float32||

返回: 

- 焊接后顶点数

