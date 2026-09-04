# Class
## class Intersection
```cj
public class Intersection
```
Raycaster intersection result

### func init\(Float64,Vector3\)
```cj
public init(distance!: Float64 = 0.0, point!: Vector3 = Vector3())
```
Construct intersection result

Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64|Distance from ray origin to intersection point, default 0.0point Intersection point, default zero vector|
|point|Vector3||

### var barycoord
```cj
public var barycoord:?Vector3
```
Barycentric coordinate at intersection point (used by Mesh hits)

### var distanceToRay
```cj
public var distanceToRay: Float64
```
Distance from intersection point to ray (used by Points hits)

### var distance
```cj
public var distance: Float64
```
Distance from ray origin to intersection point

### var faceIndex
```cj
public var faceIndex: Int64
```
Index of the intersected face

### var face
```cj
public var face:?Face
```
Intersection face information (used by Mesh hits)

### var index
```cj
public var index: Int64
```
Intersected vertex/segment index (used by Points/Line hits)

### var instanceId
```cj
public var instanceId: Int64
```
Intersected InstancedMesh instance index

### var normal
```cj
public var normal:?Vector3
```
Interpolated normal at the intersection point

### var obj
```cj
public var obj:?Object3D
```
The intersected 3D object

### var point
```cj
public var point: Vector3
```
Intersection point (world coordinates)

### var uv1
```cj
public var uv1:?Vector2
```
Second set UV coordinate at the intersection point

### var uv
```cj
public var uv:?Vector2
```
UV coordinate at the intersection point

