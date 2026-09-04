# Class
## class TouchEvent
```cj
public class TouchEvent
```
Touch event

### func init\(Int64,Float32,Float32,Float32,Float32,Float32\)
```cj
public init(fingerID!: Int64, x!: Float32, y!: Float32, dx!: Float32, dy!: Float32, pressure!: Float32)
```
Constructs a touch event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fingerID|Int64|Touch finger instance IDx Normalized X position (0~1, relative to the window)y Normalized Y position (0~1, relative to the window)dx Normalized X deltady Normalized Y deltapressure Pressure (0~1)|
|x|Float32||
|y|Float32||
|dx|Float32||
|dy|Float32||
|pressure|Float32||

### var dx
```cj
public var dx: Float32 = 0.0
```
Normalized X delta

### var dy
```cj
public var dy: Float32 = 0.0
```
Normalized Y delta

### var fingerID
```cj
public var fingerID: Int64 = 0
```
Touch finger instance ID

### var pressure
```cj
public var pressure: Float32 = 0.0
```
Pressure (0~1)

### var x
```cj
public var x: Float32 = 0.0
```
Normalized X position (0~1, relative to the window)

### var y
```cj
public var y: Float32 = 0.0
```
Normalized Y position (0~1, relative to the window)

