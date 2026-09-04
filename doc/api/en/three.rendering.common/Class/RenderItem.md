# Class
## class RenderItem
```cj
public class RenderItem
```
A single render item in the render list

### func init\(Int64,Object3D,BufferGeometry,Material,Int64,Int64,Float64,Int64\)
```cj
public init(id: Int64, object: Object3D, geometry: BufferGeometry, material: Material, groupOrder: Int64, renderOrder: Int64, z: Float64, group: Int64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64||
|object|Object3D||
|geometry|BufferGeometry||
|material|Material||
|groupOrder|Int64||
|renderOrder|Int64||
|z|Float64||
|group|Int64||

### var \`object\`
```cj
public var `object`: Object3D
```
Render object

### var geometry
```cj
public var geometry: BufferGeometry
```
Geometry

### var groupOrder
```cj
public var groupOrder: Int64
```
Group order

### var group
```cj
public var group: Int64
```
Group index

### let id
```cj
public let id: Int64
```
Unique ID (auto-increment, for stable sorting)

### var material
```cj
public var material: Material
```
Material

### var renderOrder
```cj
public var renderOrder: Int64
```
Render order

### var z
```cj
public var z: Float64
```
Depth value (camera space z)

