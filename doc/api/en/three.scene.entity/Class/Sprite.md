# Class
## class Sprite
```cj
public class Sprite <: Object3D
```
Sprite rendering object, a 2D plane always facing the camera

### func \_getUnitQuadGeometry\(\)
```cj
public static func _getUnitQuadGeometry(): BufferGeometry
```


### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new sprite instance with the same values as this instance

Return: 

- New sprite instance

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given sprite instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Returns this

### func getWorldBoundingSphere\(\)
```cj
public override func getWorldBoundingSphere(): Option < Array < Float64 >>
```
Compute sprite's world space bounding sphere (overrides Object3D)

Return: 

- Some([cx, cy, cz, radius]) or None

### func init\(Material\)
```cj
public init(material!: Material = SpriteMaterial())
```
Construct a new sprite

Parameter: 

|Name|Type|Describe|
|---|---|---|
|material|Material|Sprite material, default empty SpriteMaterial|

### func intersectsFrustum\(Frustum\)
```cj
public func intersectsFrustum(frustum: Frustum): Bool
```
Frustum culling test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustum|Frustum|The frustum|

Return: 

- Returns true if intersects with frustum

### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```
Ray intersection test

Parameter: 

|Name|Type|Describe|
|---|---|---|
|raycaster|Raycaster|The raycasterintersects Intersection result accumulator|
|intersects|ArrayList<Intersection>||

### var center
```cj
public var center: Vector2
```
Center offset (normalized UV coordinates, 0.0~1.0), default (0.5, 0.5) for center

### var material
```cj
public var material: Material
```
Sprite material (must be SpriteMaterial)

