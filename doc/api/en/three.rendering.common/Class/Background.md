# Class
## class Background
```cj
public open class Background <: DataMap
```
Scene background rendering class

### func init\(\)
```cj
public init()
```
Constructs a default background instance

### func render\(Scene\)
```cj
public func render(scene: Scene): Unit
```
Renders the background, determining view0 clear color by Three.js semantics

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scene object|

### var color
```cj
public var color: Color
```
Background color

### var intensity
```cj
public var intensity: Float64
```
Background intensity

### var texture
```cj
public var texture: Texture
```
Background texture

