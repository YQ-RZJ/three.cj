# Class
## class Path
```cj
public open class Path <: CurvePath
```
2D path class

### func absarc\(Float64,Float64,Float64,Float64,Float64,Bool\)
```cj
public func absarc(aX: Float64, aY: Float64, aRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool): Unit
```
Adds an absolute arc

Parameter: 

|Name|Type|Describe|
|---|---|---|
|aX|Float64|Center X coordinateaY Center Y coordinateaRadius RadiusaStartAngle Start angleaEndAngle End angleaClockwise Whether clockwise|
|aY|Float64||
|aRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||

### func absellipse\(Float64,Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public func absellipse(aX: Float64, aY: Float64, xRadius: Float64, yRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit
```
Adds an absolute ellipse arc

Parameter: 

|Name|Type|Describe|
|---|---|---|
|aX|Float64|Center X coordinateaY Center Y coordinatexRadius X-direction radiusyRadius Y-direction radiusaStartAngle Start angleaEndAngle End angleaClockwise Whether clockwiseaRotation Rotation angle|
|aY|Float64||
|xRadius|Float64||
|yRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||
|aRotation|Float64||

### func arc\(Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public func arc(aX: Float64, aY: Float64, aRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit
```
Adds a relative arc

Parameter: 

|Name|Type|Describe|
|---|---|---|
|aX|Float64|Center X offsetaY Center Y offsetaRadius RadiusaStartAngle Start angleaEndAngle End angleaClockwise Whether clockwiseaRotation Rotation angle|
|aY|Float64||
|aRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||
|aRotation|Float64||

### func bezierCurveTo\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func bezierCurveTo(cp1x: Float64, cp1y: Float64, cp2x: Float64, cp2y: Float64, x: Float64, y: Float64): Unit
```
Draws a cubic Bezier curve from the current point to the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cp1x|Float64|First control point X coordinatecp1y First control point Y coordinatecp2x Second control point X coordinatecp2y Second control point Y coordinatex Target X coordinatey Target Y coordinate|
|cp1y|Float64||
|cp2x|Float64||
|cp2y|Float64||
|x|Float64||
|y|Float64||

### func copy\(Curve\)
```cj
public open override func copy(source: Curve): Curve
```
Copies settings from the source path to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Source curve|

Return: 

- Reference to this instance

### func ellipse\(Float64,Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public func ellipse(aX: Float64, aY: Float64, xRadius: Float64, yRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|aX|Float64||
|aY|Float64||
|xRadius|Float64||
|yRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||
|aRotation|Float64||

### func fromJSON\(HashMap<String,Any>\)
```cj
public open override func fromJSON(json: HashMap < String, Any >): Curve
```
Deserializes the path from JSON

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|HashMap containing path data|

Return: 

- Reference to this instance

### func fromPoints\(Array<Vector3>\)
```cj
public func fromPoints(points: Array < Vector3 >): Unit
```
Creates path from an array of points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of points|

### func init\(\)
```cj
public init()
```
Constructs an empty path

### func init\(Array<Vector3>\)
```cj
public init(points: Array < Vector3 >)
```
Constructs a path from an array of points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of 2D points defining the path|

### func lineTo\(Float64,Float64\)
```cj
public func lineTo(x: Float64, y: Float64): Unit
```
Draws a line from the current point to the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Target X coordinatey Target Y coordinate|
|y|Float64||

### func moveTo\(Float64,Float64\)
```cj
public func moveTo(x: Float64, y: Float64): Unit
```
Moves the current drawing point to the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|X coordinatey Y coordinate|
|y|Float64||

### func quadraticCurveTo\(Float64,Float64,Float64,Float64\)
```cj
public func quadraticCurveTo(cpx: Float64, cpy: Float64, x: Float64, y: Float64): Unit
```
Draws a quadratic Bezier curve from the current point to the specified position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cpx|Float64|Control point X coordinatecpy Control point Y coordinatex Target X coordinatey Target Y coordinate|
|cpy|Float64||
|x|Float64||
|y|Float64||

### func splineThru\(Array<Vector3>\)
```cj
public func splineThru(points: Array < Vector3 >): Unit
```
Adds a spline curve through the specified points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of points for the spline curve to pass through|

### var currentPoint
```cj
public var currentPoint: Vector3
```
Current drawing point

