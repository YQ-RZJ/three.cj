# Class
## class CatmullRomCurve3
```cj
public open class CatmullRomCurve3 <: Curve
```
3D Catmull-Rom spline curve class

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Source curve to copy from|

Return: 

- Reference to the current instanceCopy the settings of the given CatmullRomCurve3 to this instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>||

Return: 

- HashMap containing points, closed, curveType, tensionSerialize CatmullRomCurve3 to JSON

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the curveReturn the point on the curve at the given interpolation factor tSelects different interpolation methods based on curveType:- centripetal/chordal: uses non-uniform Catmull-Rom parameterization- catmullrom: uses classic Catmull-Rom (with tension parameter)

### func init\(Array<Vector3>,Bool,String,Float64\)
```cj
public init(points!: Array < Vector3 >= Array < Vector3 >(0, { _ =>
    Vector3()
}), closed!: Bool = false, curveType!: String = "centripetal", tension!: Float64 = 0.5)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of 3D points defining the curve, default empty|
|closed|Bool|Whether the curve is closed, default false|
|curveType|String|Curve type, default 'centripetal'|
|tension|Float64|Tension parameter, default 0.5Construct a new Catmull-Rom spline curve|

### var closed
```cj
public var closed: Bool
```
Whether the curve is closed

### var curveType
```cj
public var curveType: String
```
Curve type: centripetal | chordal | catmullrom

### var points
```cj
public var points: Array < Vector3 >
```
3D point array defining the curve

### var tension
```cj
public var tension: Float64
```
Curve tension (only used when curveType is catmullrom)

