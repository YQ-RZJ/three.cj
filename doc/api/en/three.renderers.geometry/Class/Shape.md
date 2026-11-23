# Class
## class Shape
```cj
public class Shape <: Path
```
Shape class, defining a 2D shape plane with optional holes

### func copy\(Curve\)
```cj
public open override func copy(source: Curve): Curve
```
Copies settings from the source shape to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve|Source curve|

Return: 

- Reference to this instance

### func extractPoints\(Int64\)
```cj
public func extractPoints(divisions: Int64): HashMap < String, Any >
```
Returns contour data of the shape and its holes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Result precision|

Return: 

- HashMap containing shape (outer contour points) and holes (hole contour points)

### func fromJSON\(HashMap<String,Any>\)
```cj
public override func fromJSON(json: HashMap < String, Any >): Curve
```
Deserializes the shape from JSON

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|HashMap containing shape data|

Return: 

- Reference to this instance

### func getPointsHoles\(Int64\)
```cj
public func getPointsHoles(divisions: Int64): Array < Array < Vector3 >>
```
Returns 2D point arrays for each hole contour

Parameter: 

|Name|Type|Describe|
|---|---|---|
|divisions|Int64|Result precision|

Return: 

- Array of 2D point arrays for each hole

### func init\(\)
```cj
public init()
```
Constructs a new empty shape

### func init\(Array<Vector3>\)
```cj
public init(points: Array < Vector3 >)
```
Constructs a shape from an array of points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector3>|Array of 2D points defining the shape|

### var holes
```cj
public var holes: ArrayList < Path >
```
Holes in the shape; hole definitions must use opposite winding order from the outer shape

### var uuid
```cj
public var uuid: String
```
Shape UUID

