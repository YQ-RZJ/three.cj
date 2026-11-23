# Class
## class DirectionalLightHelper
```cj
public class DirectionalLightHelper <: Object3D & IReleasable
```
Directional light helper for visualizing directional light effects

### func init\(\)
```cj
public init()
```
Construct a directional light helper

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, size!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light||
|size|Float64||
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
Update helper to match light position and direction

### var color
```cj
public var color: Option < Color >
```
Color (optional, uses light color when not set)

### var lightPlane
```cj
public var lightPlane: Line
```
Light plane line

### var light
```cj
public var light: Light
```
The light being visualized

### var size
```cj
public var size: Float64
```
Plane size

### var targetLine
```cj
public var targetLine: Line
```
Target direction line

