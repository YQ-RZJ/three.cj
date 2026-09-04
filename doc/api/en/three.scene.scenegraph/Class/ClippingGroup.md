# Class
## class ClippingGroup
```cj
public class ClippingGroup <: Object3D
```
Clipping group, managing a set of sub-objects for frustum clipping

### func addObject\(Object3D\)
```cj
public func addObject(object: Object3D): Unit
```
Add a sub-object (treated as a clipping plane)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|Sub-object|

### func clone\(\)
```cj
public override func clone(): Object3D
```
Return a new clipping group instance with the same values as this instance

Return: 

- New clipping group instance

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from the given clipping group instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Returns this

### func init\(\)
```cj
public init()
```
Construct a new clipping group

### func removeObject\(Object3D\)
```cj
public func removeObject(object: Object3D): Unit
```
Remove a sub-object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|Sub-object to remove|

### var clipIntersection
```cj
public var clipIntersection: Bool
```
Whether to invert clipping (keep outside planes, clip inside)

### var clipShadows
```cj
public var clipShadows: Bool
```
Whether to apply clipping during shadow rendering (main render clipping only)

### var clippingPlanes
```cj
public var clippingPlanes: ArrayList < Plane >
```
Clipping planes array, each sub-object treated as a clipping plane

### var enabled
```cj
public var enabled: Bool
```
Whether clipping is enabled

