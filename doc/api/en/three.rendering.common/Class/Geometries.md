# Class
## class Geometries
```cj
public open class Geometries <: DataMap
```
Geometry backend data manager

### func destroy\(BufferGeometry\)
```cj
public func destroy(geometry: BufferGeometry): Unit
```
Destroys the backend resources for the given geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Geometry|

### func get\(BufferGeometry\)
```cj
public func get(geometry: BufferGeometry): Int64
```
Gets the backend handle for the given geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Geometry|

Return: 

- Backend handle

### func init\(Backend\)
```cj
public init(backend: Backend)
```
Constructs a geometries manager

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|Backend|Rendering backend instance|

### func updateForRender\(RenderObject\)
```cj
public func updateForRender(renderObject: RenderObject): Unit
```
Updates the geometry buffer based on the render object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderObject|RenderObject|Render object|

### func update\(BufferGeometry\)
```cj
public func update(geometry: BufferGeometry): Unit
```
Updates the geometry buffer data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Geometry|

### var backend
```cj
public var backend: Backend
```
Reference to the backend

