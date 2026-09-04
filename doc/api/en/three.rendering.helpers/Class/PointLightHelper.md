# Class
## class PointLightHelper
```cj
public class PointLightHelper <: Mesh
```
Point light helper visualizing point light position with a spherical wireframe mesh

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, sphereSize!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```
Construct a point light helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The point light to visualizesphereSize Sphere size, default 1color Color, uses light color when not set|
|sphereSize|Float64||
|color|Option<Color>||

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

