# Class
## class HemisphereLightHelper
```cj
public class HemisphereLightHelper <: Object3D
```
Hemisphere light helper visualized with an octahedron mesh

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Light,Float64,Option<Color>\)
```cj
public init(light: Light, size!: Float64 = 1.0, color!: Option < Color >= None < Color >)
```
Construct a hemisphere light helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The hemisphere light to visualizesize Size, default 1color Color, uses light color when not set|
|size|Float64||
|color|Option<Color>||

### func update\(\)
```cj
public func update(): Unit
```
Update helper to match light position and color

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

### var material
```cj
public var material: Material
```
Material reference

