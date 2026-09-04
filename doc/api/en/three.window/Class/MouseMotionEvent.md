# Class
## class MouseMotionEvent
```cj
public class MouseMotionEvent
```
Mouse motion event

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(x!: Float32, y!: Float32, dx!: Float32, dy!: Float32)
```
Constructs a mouse motion event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|X position relative to the windowy Y position relative to the windowdx X delta relative to the previous framedy Y delta relative to the previous frame|
|y|Float32||
|dx|Float32||
|dy|Float32||

### var dx
```cj
public var dx: Float32 = 0.0
```
X delta relative to the previous frame

### var dy
```cj
public var dy: Float32 = 0.0
```
Y delta relative to the previous frame

### var x
```cj
public var x: Float32 = 0.0
```
X position relative to the window

### var y
```cj
public var y: Float32 = 0.0
```
Y position relative to the window

