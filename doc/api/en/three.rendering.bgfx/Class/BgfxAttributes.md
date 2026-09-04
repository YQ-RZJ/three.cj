# Class
## class BgfxAttributes
```cj
public class BgfxAttributes
```
bgfx vertex attribute buffer management

### func createVertexLayout\(Array<BgfxAttributeDesc>\)
```cj
public func createVertexLayout(attributes: Array < BgfxAttributeDesc >): VertexLayoutHandle
```
Create vertex layout and register memory pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|Attribute descriptor list (BgfxAttributeDesc)|

Return: 

- Vertex layout handle (invalid if idx=0xFFFF)

### func destroyVertexLayout\(VertexLayoutHandle\)
```cj
public func destroyVertexLayout(layout: VertexLayoutHandle): Unit
```
Destroy vertex layout and release registered memory pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutHandle|Vertex layout handle to destroy|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose all buffers

### func getIndexBuffer\(Int64\)
```cj
public func getIndexBuffer(attributeId: Int64): Option < IndexBufferInfo >
```
Get index buffer info

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute object ID|

Return: 

- Index buffer info, or None if not found

### func getVertexBuffer\(Int64\)
```cj
public func getVertexBuffer(attributeId: Int64): Option < VertexBufferInfo >
```
Get vertex buffer info

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute object ID|

Return: 

- Vertex buffer info, or None if not found

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

### func removeIndexBuffer\(Int64\)
```cj
public func removeIndexBuffer(attributeId: Int64): Unit
```
Remove index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute object ID|

### func removeVertexBuffer\(Int64\)
```cj
public func removeVertexBuffer(attributeId: Int64): Unit
```
Remove vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute object ID|

### func updateIndexBuffer\(Int64,BgfxMemory,Int64,Int64,Int64\)
```cj
public func updateIndexBuffer(attributeId: Int64, mem: BgfxMemory, size: Int64, bytesPerElement: Int64, version: Int64): Unit
```
Update or create index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute object IDmem Index data memorysize Data size in bytesbytesPerElement Bytes per elementversion Version number|
|mem|BgfxMemory||
|size|Int64||
|bytesPerElement|Int64||
|version|Int64||

### func updateVertexBuffer\(Int64,BgfxMemory,VertexLayoutHandle,Int64,Int64,Int64,Bool\)
```cj
public func updateVertexBuffer(attributeId: Int64, mem: BgfxMemory, layout: VertexLayoutHandle, size: Int64, bytesPerElement: Int64, version: Int64, dynamic: Bool): Unit
```
Update or create vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute object IDmem Vertex data memory (BgfxMemory, takes pointer internally)layout Vertex layout handle (created via createVertexLayout, internally looks up pointer)size Data size in bytesbytesPerElement Bytes per elementversion Version numberdynamic Whether the buffer is dynamic|
|mem|BgfxMemory||
|layout|VertexLayoutHandle||
|size|Int64||
|bytesPerElement|Int64||
|version|Int64||
|dynamic|Bool||

