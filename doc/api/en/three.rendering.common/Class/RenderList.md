# Class
## class RenderList
```cj
public open class RenderList
```
Render list

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the render list

### func finish\(\)
```cj
public func finish(): ArrayList < RenderItem >
```
Finishes collection, returns sorted render item list

Return: 

- Sorted render item list

### func init\(\)
```cj
public init()
```
Constructs a default render list

### func push\(Object3D,BufferGeometry,Material,Int64,Int64,Float64,Int64\)
```cj
public func push(object: Object3D, geometry: BufferGeometry, material: Material, groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64): Unit
```
Adds a render object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|Render objectgeometry Geometrymaterial MaterialgroupOrder Group orderrenderOrder Render orderz Depth valuegroup Group index|
|geometry|BufferGeometry||
|material|Material||
|groupOrder|Int64||
|renderOrder|Int64||
|z|Float64||
|group|Int64||

### func sort\(\)
```cj
public func sort(): Unit
```
Three-level sorting

