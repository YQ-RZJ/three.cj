# Class
## class LineSegments
```cj
public open class LineSegments <: Line
```
Line segments rendering object, pairing vertices into independent line segments

### func computeLineDistances\(\)
```cj
public override func computeLineDistances(): Line
```
Compute and write lineDistance attribute to geometry (per segment distance, not cumulative)

Return: 

- Returns this for method chaining

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial())
```
Construct a new line segments group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry|Vertex/index geometry, default empty BufferGeometrymaterial Line material, default empty LineBasicMaterial|
|material|Material||

