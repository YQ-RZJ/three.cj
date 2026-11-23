# Class
## class PointLightHelper
```cj
public class PointLightHelper <: Mesh & IReleasable
```
Point light helper visualizing point light position with a spherical wireframe mesh

### func init\(\)
```cj
public init()
```
Construct a point light helper

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, sphereSize!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light||
|sphereSize|Float64||
|color|Option<Color>||

### func release\(\)
```cj
public func release(): Bool
```
Release GPU resources

### func update\(\)
```cj
public func update(): Unit
```
Update helper to match light position

### var color
```cj
public var color: Option < Color >
```
Color (optional, uses light color when not set)

### var light
```cj
public var light: Light
```
The light being visualized

