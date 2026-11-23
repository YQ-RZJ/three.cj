# Class
## class SceneCullIndex
```cj
public class SceneCullIndex
```
Scene spatial index

### func needsRebuild\(\)
```cj
public func needsRebuild(): Bool
```
Whether the index needs rebuilding (scene structure changed)

### func queryArrayFrustum\(FrustumArray\)
```cj
public func queryArrayFrustum(frustumArray: FrustumArray): Unit
```
Refresh bounds and run a multi-eye frustum query (visible in any eye)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustumArray|FrustumArray|Multi-eye frustum|

### func query\(Frustum\)
```cj
public func query(frustum: Frustum): Unit
```
Refresh bounds and run a frustum query, writing the result into each
object's cullVisible flag

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frustum|Frustum|Frustum|

### func rebuild\(Object3D\)
```cj
public func rebuild(scene: Object3D): Unit
```
Rebuild the index: walk the scene collecting cullable objects and build the BVH

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Object3D|Scene root|

### prop alwaysVisibleCount: Int64
```cj
public prop alwaysVisibleCount: Int64
```
Number of always-visible objects

### prop indexedCount: Int64
```cj
public prop indexedCount: Int64
```
Number of objects participating in the spatial index

