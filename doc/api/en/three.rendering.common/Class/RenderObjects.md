# Class
## class RenderObjects
```cj
public open class RenderObjects
```
Render object cache manager

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all caches

### func get\(Object3D,BufferGeometry,Material,RenderContext,Camera,Scene\)
```cj
public func get(mesh: Object3D, geometry: BufferGeometry, material: Material, context: RenderContext, camera: Camera, scene: Scene): RenderObject
```
Gets or creates the RenderObject for the given (object, material, camera)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mesh|Object3D|Render objectgeometry Geometrymaterial Materialcontext Render contextcamera Camerascene Scene|
|geometry|BufferGeometry||
|material|Material||
|context|RenderContext||
|camera|Camera||
|scene|Scene||

Return: 

- RenderObject instance

### func init\(\)
```cj
public init()
```
Constructs a default render object cache

