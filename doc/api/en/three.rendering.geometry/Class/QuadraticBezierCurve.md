# Class
## class QuadraticBezierCurve
```cj
public class QuadraticBezierCurve <: Curve
```
2D quadratic Bezier curve class

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Source curve to copy from|

Return: 

- Reference to the current instanceCopy the settings of the given quadratic Bezier curve to this instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|HashMap containing v0, v1, v2 arrays|

Return: 

- Reference to the current instanceDeserialize the quadratic Bezier curve from JSON

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the curve (z=0)Return the point on the curve at the given interpolation factor tInterpolate x and y components using quadratic Bezier basis functions respectively.

### func init\(Vector3,Vector3,Vector3\)
```cj
public init(v0!: Vector3 = Vector3(), v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v0|Vector3|Start point, default zero vector|
|v1|Vector3|Control point, default zero vector|
|v2|Vector3|End point, default zero vectorConstruct a new 2D quadratic Bezier curve|

### var v0
```cj
public var v0: Vector3
```
Start point

### var v1
```cj
public var v1: Vector3
```
Control point

### var v2
```cj
public var v2: Vector3
```
End point

