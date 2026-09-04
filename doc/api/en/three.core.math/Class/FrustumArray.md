# Class
## class FrustumArray
```cj
public class FrustumArray
```
Frustum array class for multi-layer rendering frustum culling

### func clone\(\)
```cj
public func clone(): FrustumArray
```
Clone the current frustum array

Return: 

- New frustum array instance

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
Check if a point is inside any frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point|

Return: 

- Whether the point is contained

### func copy\(FrustumArray\)
```cj
public func copy(source: FrustumArray): FrustumArray
```
Copy values from another frustum array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|FrustumArray|Source frustum array|

Return: 

- This instance

### func get\(Int64\)
```cj
public func get(index: Int64): Frustum
```
Get the frustum at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index|

Return: 

- Frustum

### func init\(Array<Frustum>\)
```cj
public init(frustums: Array < Frustum >)
```
Construct FrustumArray with specified frustum array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustums|Array<Frustum>|Frustum array|

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
Check if the bounding box intersects any frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3|Bounding box|

Return: 

- Whether they intersect

### func intersectsObject\(IFrustumCullable\)
```cj
public func intersectsObject(object: IFrustumCullable): Bool
```
Check if a 3D object intersects any frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|IFrustumCullable|Object implementing IFrustumCullable (Object3D and subclasses)|

Return: 

- Whether they intersect

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
Check if the sphere intersects any frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Sphere|Sphere|

Return: 

- Whether they intersect

### func intersectsSprite\(IFrustumCullable\)
```cj
public func intersectsSprite(sprite: IFrustumCullable): Bool
```
Check if a sprite intersects any frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sprite|IFrustumCullable|Sprite (Sprite <: Object3D <: IFrustumCullable)|

Return: 

- Whether they intersect

### func setFromArrayCamera\(IArrayCameraSource\)
```cj
public func setFromArrayCamera(cameraArray: IArrayCameraSource): FrustumArray
```
Set frustum array from an array camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cameraArray|IArrayCameraSource|Array camera implementing IArrayCameraSource|

Return: 

- This instance

### var frustums
```cj
public var frustums: Array < Frustum >
```
Frustum array

