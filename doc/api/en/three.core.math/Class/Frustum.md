# Class
## class Frustum
```cj
public class Frustum
```
Frustum class, defined by 6 planes

### func clone\(\)
```cj
public func clone(): Frustum
```
Clone the current frustum

Return: 

- New frustum instance

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
Check if a point is inside the frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Point to test|

Return: 

- Whether the point is contained

### func copy\(Frustum\)
```cj
public func copy(f: Frustum): Frustum
```
Copy values from another frustum to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|f|Frustum|Source frustum|

Return: 

- This instance

### func equals\(Frustum\)
```cj
public func equals(f: Frustum): Bool
```
Check if this frustum equals another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|f|Frustum|Another frustum|

Return: 

- Whether they are equal

### func init\(\)
```cj
public init()
```


### func intersectsBoxComponents\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func intersectsBoxComponents(minX: Float64, minY: Float64, minZ: Float64, maxX: Float64, maxY: Float64, maxZ: Float64): Bool
```
Check if bounding-box components intersect the frustum (zero-allocation overload)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minX|Float64|Box min XminY Box min YminZ Box min ZmaxX Box max XmaxY Box max YmaxZ Box max Z|
|minY|Float64||
|minZ|Float64||
|maxX|Float64||
|maxY|Float64||
|maxZ|Float64||

Return: 

- Whether they intersect

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
Check if a bounding box intersects the frustum

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
Check if a 3D object intersects the frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|IFrustumCullable|Object implementing IFrustumCullable (Object3D and subclasses)|

Return: 

- Whether they intersect

### func intersectsSphereArray\(Array<Float64>\)
```cj
public func intersectsSphereArray(sphere: Array < Float64 >): Bool
```
Check if a sphere ([cx,cy,cz,radius]) intersects the frustum, with zero allocation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sphere|Array<Float64>|Sphere as [centerX, centerY, centerZ, radius]|

Return: 

- Whether they intersect

### func intersectsSphereComponents\(Float64,Float64,Float64,Float64\)
```cj
public func intersectsSphereComponents(cx: Float64, cy: Float64, cz: Float64, radius: Float64): Bool
```
Check if sphere components intersect the frustum (zero-allocation overload)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cx|Float64||
|cy|Float64||
|cz|Float64||
|radius|Float64||

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
Check if a sphere intersects the frustum

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
Check if a sprite intersects the frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sprite|IFrustumCullable|Sprite (Sprite <: Object3D <: IFrustumCullable)|

Return: 

- Whether they intersect

### func setFromProjectionMatrix\(Matrix4,Int64,Bool\)
```cj
public func setFromProjectionMatrix(m: Matrix4, coordinateSystem!: Int64 = WebGPUCoordinateSystem, reversedDepth!: Bool = false): Frustum
```
Set the frustum from a projection matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4|Projection matrix (or projScreen = projectionMatrix × matrixWorldInverse)coordinateSystem Coordinate system (WebGL 2000 / WebGPU 2001), default WebGPU (left-handed)reversedDepth Whether reversed depth (WebGPU reverse Z [1,0]), default false|
|coordinateSystem|Int64||
|reversedDepth|Bool||

Return: 

- This instance

### func set\(Plane,Plane,Plane,Plane,Plane,Plane\)
```cj
public func set(p0: Plane, p1: Plane, p2: Plane, p3: Plane, p4: Plane, p5: Plane): Frustum
```
Set the 6 planes of the frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p0|Plane|The 0th planep1 The 1st planep2 The 2nd planep3 The 3rd planep4 The 4th planep5 The 5th plane|
|p1|Plane||
|p2|Plane||
|p3|Plane||
|p4|Plane||
|p5|Plane||

Return: 

- This instance

### let isFrustum
```cj
public let isFrustum: Bool = true
```
Type marker (is+ClassName redundant member, not serialized)

### var planes
```cj
public var planes: Array < Plane >
```
The 6 clipping planes of the frustum

