# Class
## class LineCurve3
```cj
public class LineCurve3 <: Curve
```
3D line curve class

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Source curve to copy from|

Return: 

- Reference to the current instanceCopy the settings of the given 3D line segment to this instance

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|HashMap containing v1 and v2 arrays|

Return: 

- Reference to the current instanceDeserialize the 3D line segment from JSON

### func getPointAt\(Float64\)
```cj
public override func getPointAt(u: Float64): Vector3
```
直线是线性的，可直接重写 getPointAt

Parameter: 

|Name|Type|Describe|
|---|---|---|
|u|Float64||

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the lineReturn the point on the line at the given interpolation factor t

### func getTangentAt\(Float64\)
```cj
public override func getTangentAt(u: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|u|Float64|Uniform arc length parameter between 0 and 1|

Return: 

- Normalized tangentLine tangent is independent of u, so getTangentAt can be directly overridden

### func getTangent\(Float64\)
```cj
public override func getTangent(t: Float64): Vector3
```
返回直线方向上的归一化切线

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64||

### func init\(Vector3,Vector3\)
```cj
public init(v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|v1|Vector3|Start point, default zero vector|
|v2|Vector3|End point, default zero vectorConstruct a new 3D line segment|

### var v1
```cj
public var v1: Vector3
```
起始点

### var v2
```cj
public var v2: Vector3
```
末点

