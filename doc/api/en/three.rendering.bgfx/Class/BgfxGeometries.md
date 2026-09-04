# Class
## class BgfxGeometries
```cj
public class BgfxGeometries
```
bgfx geometry management

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
Disposes all geometries

### func dispose\(Int64,Option<Int64>,ArrayList<Int64>\)
```cj
public func dispose(geometryId: Int64, indexAttributeId: Option < Int64 >, attributeIds: ArrayList < Int64 >): Unit
```
Disposes geometry resources

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry IDindexAttributeId Index attribute IDattributeIds Vertex attribute ID list|
|indexAttributeId|Option<Int64>||
|attributeIds|ArrayList<Int64>||

### func getIndexBuffer\(Int64\)
```cj
public func getIndexBuffer(attributeId: Int64): Option < IndexBufferInfo >
```
Gets index buffer info

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute ID|

Return: 

- Index buffer info (containing IndexBufferHandle)

### func getLayoutHandle\(Int64\)
```cj
public func getLayoutHandle(attributeId: Int64): Option < VertexLayoutHandle >
```
Gets vertex layout handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute ID|

Return: 

- Vertex layout handle

### func getVertexBuffer\(Int64\)
```cj
public func getVertexBuffer(attributeId: Int64): Option < VertexBufferInfo >
```
Gets vertex buffer info

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributeId|Int64|Attribute ID|

Return: 

- Vertex buffer info (containing VertexBufferHandle)

### func getWireframeAttribute\(Int64\)
```cj
public func getWireframeAttribute(geometryId: Int64): Option < Int64 >
```
Gets wireframe attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry ID|

Return: 

- Wireframe attribute ID

### func get\(Int64\)
```cj
public func get(geometryId: Int64): Bool
```
Gets or registers a geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry ID|

Return: 

- Whether the geometry is newly registered

### func init\(BgfxAttributes,BgfxInfo,BgfxBindingStates\)
```cj
public init(attributes!: BgfxAttributes, info!: BgfxInfo, bindingStates!: BgfxBindingStates)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributes|BgfxAttributes||
|info|BgfxInfo||
|bindingStates|BgfxBindingStates||

### func updateWireframeAttribute\(Int64,Int64\)
```cj
public func updateWireframeAttribute(geometryId: Int64, wireframeAttrId: Int64): Unit
```
Updates wireframe attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry IDwireframeAttrId Wireframe attribute ID|
|wireframeAttrId|Int64||

### func update\(Int64\)
```cj
public func update(geometryId: Int64): Unit
```
Updates all attribute buffers of a geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometryId|Int64|Geometry ID|

