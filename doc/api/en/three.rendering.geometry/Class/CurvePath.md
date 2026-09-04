# Class
## class CurvePath
```cj
public open class CurvePath <: Curve
```
Curve path class, a composite path of multiple curves connected in sequence

### func add\(Curve\)
```cj
public func add(curve: Curve): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|curve|Curve|Sub-curve to addAdd a sub-curve to this curve path|

### func closePath\(\)
```cj
public func closePath(): CurvePath
```


Return: 

- Reference to the current instanceAdd a LineCurve to close this pathOnly added when the start and end points do not coincide.

### func copy\(Curve\)
```cj
public open override func copy(source: Curve): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Curve path to copy from|

Return: 

- Reference to the current instanceCopy the settings of the given curve path to this instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public open override func fromJSON(json: HashMap < String, Any >): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>||

Return: 

- HashMap containing autoClose and curves arraySerialize the curve path to JSON

### func getCurveLengths\(\)
```cj
public func getCurveLengths(): Array < Float64 >
```


Return: 

- Array of sub-curve cumulative lengthsReturn the cumulative length array of all sub-curvesCannot override getLengths(): UtoT mapping uses it. Uses cacheLengths for caching here.

### func getLength\(\)
```cj
public override func getLength(): Float64
```


Return: 

- Total length of the curve pathReturn the total length of the curve pathOverride Curve.getLength: because Curve.getLength depends on getPoint,and CurvePath.getPoint depends on getLength, so use the last value of getCurveLengths instead.

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the curve path; returns zero vector if out of rangeReturn the curve point at the given interpolation factor t (along the entire path)Algorithm: t * total length → locate via sub-curve cumulative lengths → sub-curve parameter u → sub-curve getPointAt(u)

### func getPoints\(Int64\)
```cj
public override func getPoints(divisions: Int64): Array < Vector3 >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Number of divisions, default 12|

Return: 

- Array of pointsReturn an array of points along the curve path evenly divided by t (with adjacent duplicate points removed)The sub-curve type determines its resolution: EllipseCurve uses divisions*2,LineCurve/LineCurve3 uses 1, SplineCurve uses divisions*point count, others use divisions.

### func getSpacedPoints\(Int64\)
```cj
public override func getSpacedPoints(divisions: Int64): Array < Vector3 >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Number of divisions, default 40|

Return: 

- Array of points, length is divisions + 1 (when autoClose is true, the first point is repeated at the end)Return an array of evenly arc-length distributed points along the curve path

### func init\(\)
```cj
public init()
```
构造新的曲线路径

### func updateArcLengths\(\)
```cj
public func updateArcLengths(): Unit
```
标记 cacheLengths 失效并立即重新计算

### var autoClose
```cj
public var autoClose: Bool
```
是否自动用一条 LineCurve 闭合此路径

### var curves
```cj
public var curves: ArrayList < Curve >
```
持有此路径的所有子曲线

