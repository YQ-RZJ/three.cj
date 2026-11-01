# Class
## class Bvh
```cj
public class Bvh
```
Bounding Volume Hierarchy (BVH)

### func build\(Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>\)
```cj
public func build(centerX: Array < Float64 >, centerY: Array < Float64 >, centerZ: Array < Float64 >, halfX: Array < Float64 >, halfY: Array < Float64 >, halfZ: Array < Float64 >): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|centerX|Array<Float64>|Element center X components|
|centerY|Array<Float64>|Element center Y components|
|centerZ|Array<Float64>|Element center Z components|
|halfX|Array<Float64>|Element bounds half-extent X components|
|halfY|Array<Float64>|Element bounds half-extent Y components|
|halfZ|Array<Float64>|Element bounds half-extent Z components|

### func getElementBounds\(Int64,Array<Float64>,Array<Float64>\)
```cj
public func getElementBounds(element: Int64, outCenter: Array < Float64 >, outHalf: Array < Float64 >): Unit
```
Read an element's bounds (center + half extents)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|Int64|Element index|
|outCenter|Array<Float64>|Output center (cx, cy, cz written)|
|outHalf|Array<Float64>|Output half extents (hx, hy, hz written)|

### func getRootBounds\(Vector3,Vector3\)
```cj
public func getRootBounds(outMin: Vector3, outMax: Vector3): Bool
```
Get the root node bounds (min into outMin, max into outMax)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|outMin|Vector3|Output min corner|
|outMax|Vector3|Output max corner|

Return: 

- 

### func init\(\)
```cj
public init()
```
Constructs an empty BVH

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Whether the BVH is empty (no elements)

### func queryFrustum\(Frustum,ArrayList<Int64>\)
```cj
public func queryFrustum(frustum: Frustum, out: ArrayList < Int64 >): Unit
```
Frustum query: collect leaf element indices whose bounds intersect the frustum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustum|Frustum|Frustum|
|out|ArrayList<Int64>|Output array (hit indices are appended)|

### func queryRay\(Vector3,Vector3,Float64,ArrayList<Int64>\)
```cj
public func queryRay(origin: Vector3, direction: Vector3, maxDistance: Float64, out: ArrayList < Int64 >): Unit
```
Ray query: collect leaf element indices whose bounds intersect the ray

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|Ray origin|
|direction|Vector3|Ray direction (need not be normalized)|
|maxDistance|Float64|Maximum distance|
|out|ArrayList<Int64>|Output array (hit indices are appended)|

### func refit\(\)
```cj
public func refit(): Unit
```
Recompute bounds after elements moved (bottom-up)

### func updateBounds\(Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>\)
```cj
public func updateBounds(centerX: Array < Float64 >, centerY: Array < Float64 >, centerZ: Array < Float64 >, halfX: Array < Float64 >, halfY: Array < Float64 >, halfZ: Array < Float64 >): Unit
```
Replace all element bounds (center + half extents) wholesale and refit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|centerX|Array<Float64>|New center X components|
|centerY|Array<Float64>|New center Y components|
|centerZ|Array<Float64>|New center Z components|
|halfX|Array<Float64>|New half-extent X components|
|halfY|Array<Float64>|New half-extent Y components|
|halfZ|Array<Float64>|New half-extent Z components|

### func updateCenters\(Array<Float64>,Array<Float64>,Array<Float64>\)
```cj
public func updateCenters(centerX: Array < Float64 >, centerY: Array < Float64 >, centerZ: Array < Float64 >): Unit
```
Convenience entry: update element centers then refit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|centerX|Array<Float64>|New center X components|
|centerY|Array<Float64>|New center Y components|
|centerZ|Array<Float64>|New center Z components|

### prop elementCount: Int64
```cj
public prop elementCount: Int64
```
Total element count

### prop nodeCount: Int64
```cj
public prop nodeCount: Int64
```
Total node count

