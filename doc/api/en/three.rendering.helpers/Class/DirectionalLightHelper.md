# Class
## class DirectionalLightHelper
```cj
public class DirectionalLightHelper <: Object3D
```
Directional light helper for visualizing directional light effects

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, size!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```
Construct a directional light helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The directional light to visualizesize Plane size, default 1color Color, uses light color when not set|
|size|Float64||
|color|Option<Color>||

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

