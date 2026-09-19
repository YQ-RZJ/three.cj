# Class
## class BgfxAttributeUtils
```cj
public class BgfxAttributeUtils
```
bgfx vertex attribute utilities

### func computeStride\(Array<BgfxAttributeDesc>\)
```cj
public func computeStride(attributes: Array < BgfxAttributeDesc >): UInt16
```
Compute vertex stride

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|Attribute descriptor list|

Return: 

- Vertex stride in bytes

### func createVertexLayout\(Array<BgfxAttributeDesc>\)
```cj
public func createVertexLayout(attributes: Array < BgfxAttributeDesc >): VertexLayoutHandle
```
Create a vertex layout

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|Attribute descriptor list|

Return: 

- Vertex layout handle

### func init\(\)
```cj
public init()
```


### func topologyConvert\(UInt32,PtrArray<UInt8>,UInt32,PtrArray<UInt8>,UInt32,Bool\)
```cj
public func topologyConvert(conversion: UInt32, dst: PtrArray < UInt8 >, dstSize: UInt32, indices: PtrArray < UInt8 >, numIndices: UInt32, index32: Bool): UInt32
```
Topology conversion (returns converted index count)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|conversion|UInt32|Conversion typedst Destination index bufferdstSize Destination buffer sizeindices Source index datanumIndices Number of indicesindex32 Whether to use 32-bit indices|
|dst|PtrArray<UInt8>||
|dstSize|UInt32||
|indices|PtrArray<UInt8>||
|numIndices|UInt32||
|index32|Bool||

Return: 

- Converted index count

### func topologySortTriList\(UInt32,PtrArray<UInt8>,UInt32,PtrArray<Float32>,PtrArray<Float32>,PtrArray<UInt8>,UInt32,PtrArray<UInt8>,UInt32,Bool\)
```cj
public func topologySortTriList(sort: UInt32, dst: PtrArray < UInt8 >, dstSize: UInt32, dir: PtrArray < Float32 >, pos: PtrArray < Float32 >, vertices: PtrArray < UInt8 >, stride: UInt32, indices: PtrArray < UInt8 >, numIndices: UInt32, index32: Bool): Unit
```
Sort triangle list (transparent object sorting)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sort|UInt32|Sort typedst Destination index bufferdstSize Destination buffer sizedir Sort directionpos Sort positionvertices Vertex datastride Vertex strideindices Index datanumIndices Number of indicesindex32 Whether to use 32-bit indices|
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
Convert vertex data format (layout A → layout B)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dstLayout|VertexLayoutPtr|Destination vertex layout pointerdstData Destination data buffersrcLayout Source vertex layout pointersrcData Source data buffernum Number of vertices|
|dstData|PtrArray<UInt8>||
|srcLayout|VertexLayoutPtr||
|srcData|PtrArray<UInt8>||
|num|UInt32||

### func vertexLayoutDecode\(VertexLayoutPtr,UInt32,PtrArray<UInt8>,PtrArray<UInt32>,PtrArray<Bool>,PtrArray<Bool>\)
```cj
public func vertexLayoutDecode(layout: VertexLayoutPtr, attrib: UInt32, num: PtrArray < UInt8 >, `type`: PtrArray < UInt32 >, normalized: PtrArray < Bool >, asInt: PtrArray < Bool >): Unit
```
Decode attribute info from a vertex layout

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutPtr|Vertex layout pointer (VertexLayoutPtr wrapper)attrib Attribute semantics (Attrib.value())num Output component count (PtrArray output)type Output data type (PtrArray output)normalized Output whether normalized (PtrArray output)asInt Output whether integer (PtrArray output)|
|attrib|UInt32||
|num|PtrArray<UInt8>||
|`type`|PtrArray<UInt32>||
|normalized|PtrArray<Bool>||
|asInt|PtrArray<Bool>||

### func vertexLayoutGetOffset\(VertexLayoutPtr,UInt32\)
```cj
public func vertexLayoutGetOffset(layout: VertexLayoutPtr, attrib: UInt32): UInt16
```
Get attribute offset in bytes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutPtr|Vertex layout pointerattrib Attribute semantics|
|attrib|UInt32||

Return: 

- Attribute offset in bytes

### func vertexLayoutGetSize\(VertexLayoutPtr,UInt32\)
```cj
public func vertexLayoutGetSize(layout: VertexLayoutPtr, num: UInt32): UInt32
```
Get attribute component size in bytes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutPtr|Vertex layout pointernum Number of components|
|num|UInt32||

Return: 

- Attribute component size in bytes

### func vertexLayoutGetStride\(VertexLayoutPtr\)
```cj
public func vertexLayoutGetStride(layout: VertexLayoutPtr): UInt16
```
Get layout stride in bytes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutPtr|Vertex layout pointer|

Return: 

- Layout stride in bytes

### func vertexLayoutHas\(VertexLayoutPtr,UInt32\)
```cj
public func vertexLayoutHas(layout: VertexLayoutPtr, attrib: UInt32): Bool
```
Check if layout contains an attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutPtr|Vertex layout pointerattrib Attribute semantics|
|attrib|UInt32||

Return: 

- Whether the attribute exists in the layout

### func vertexLayoutSkip\(VertexLayoutPtr,UInt8\)
```cj
public func vertexLayoutSkip(layout: VertexLayoutPtr, num: UInt8): VertexLayoutPtr
```
Skip num attribute components (advance layout build cursor)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutPtr|Vertex layout pointernum Number of components to skip|
|num|UInt8||

Return: 

- Updated vertex layout pointer

### func vertexPack\(PtrArray<Float32>,Bool,UInt32,VertexLayoutPtr,PtrArray<UInt8>,UInt32\)
```cj
public func vertexPack(input: PtrArray < Float32 >, inputNormalized: Bool, attr: UInt32, layout: VertexLayoutPtr, data: PtrArray < UInt8 >, index: UInt32): Unit
```
Pack vertex data into buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|input|PtrArray<Float32>|Input float datainputNormalized Whether input is normalizedattr Attribute semanticslayout Vertex layout pointerdata Destination data bufferindex Vertex index|
|inputNormalized|Bool||
|attr|UInt32||
|layout|VertexLayoutPtr||
|data|PtrArray<UInt8>||
|index|UInt32||

### func vertexUnpack\(PtrArray<Float32>,UInt32,VertexLayoutPtr,PtrArray<UInt8>,UInt32\)
```cj
public func vertexUnpack(output: PtrArray < Float32 >, attr: UInt32, layout: VertexLayoutPtr, data: PtrArray < UInt8 >, index: UInt32): Unit
```
Unpack vertex data from buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|output|PtrArray<Float32>|Output float dataattr Attribute semanticslayout Vertex layout pointerdata Source data bufferindex Vertex index|
|attr|UInt32||
|layout|VertexLayoutPtr||
|data|PtrArray<UInt8>||
|index|UInt32||

