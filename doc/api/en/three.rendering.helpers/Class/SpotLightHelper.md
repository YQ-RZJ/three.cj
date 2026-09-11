# Class
## class SpotLightHelper
```cj
public class SpotLightHelper <: Object3D
```
Spot light helper visualizing illumination range with a cone wireframe

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Light,Option<Color>\)
```cj
public init(light: Light, color!: Option < Color >= None < Color >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light||
|color|Option<Color>||

### func init\(\)
```cj
public init()
```
Construct a spot light helper

### func update\(\)
```cj
public func update(): Unit
```
Update helper to match light position and angle

### var color
```cj
public var color: Option < Color >
```
Color (optional, uses light color when not set)

### var cone
```cj
public var cone: LineSegments
```
Cone wireframe

### var light
```cj
public var light: Light
```
The light being visualized

