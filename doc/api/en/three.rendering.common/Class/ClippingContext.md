# Class
## class ClippingContext
```cj
public open class ClippingContext
```
Clipping plane context, managing a collection of local clipping planes

### func addPlane\(Plane\)
```cj
public func addPlane(plane: Plane): Unit
```
Adds a clipping plane

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|Clipping plane|

### func init\(\)
```cj
public init()
```
Constructs a default clipping context

### func intersectPlanes\(\)
```cj
public func intersectPlanes(): Unit
```
Computes plane intersections (placeholder method)

### var localClippingEnabled
```cj
public var localClippingEnabled: Bool
```
Whether local clipping is enabled

### var planes
```cj
public var planes: ArrayList < Plane >
```
List of clipping planes

