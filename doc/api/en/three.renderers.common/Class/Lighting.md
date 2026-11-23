# Class
## class Lighting
```cj
public open class Lighting
```
Lighting information aggregation class

### func init\(\)
```cj
public init()
```
Constructs default lighting information

### func reset\(\)
```cj
public func reset(): Unit
```
Resets lighting information, clearing all light lists

### var ambient
```cj
public var ambient: Vector3
```
Ambient light color

### var directional
```cj
public var directional: ArrayList < Vector3 >
```
Directional light list

### var point
```cj
public var point: ArrayList < Vector3 >
```
Point light list

### var spot
```cj
public var spot: ArrayList < Vector3 >
```
Spot light list

