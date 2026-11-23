# Class
## class SplineCurve
```cj
public class SplineCurve <: Curve
```
2D spline curve class

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve||

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>||

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the curve (z=0)Return the point on the spline curve at the given interpolation factor tInterpolate x and y components using CatmullRom basis functions.

### func init\(Array<Vector3>\)
```cj
public init(points!: Array < Vector3 >= Array < Vector3 >(0, { _ =>
    Vector3()
}))
```
Constructs a new 2D spline curve

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of 2D points defining the curve, default empty|

### var points
```cj
public var points: Array < Vector3 >
```
Array of 2D points defining the curve (using Vector3 with z=0 in Cangjie)

