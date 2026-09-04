# Class
## class Box2
```cj
public class Box2
```
2D axis-aligned bounding box class, defined by min and max points

### func clampPoint\(Vector2,Vector2\)
```cj
public func clampPoint(point: Vector2, target: Vector2): Vector2
```
Clamp a point within the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector2|Point to clamptarget Target vector|
|target|Vector2||

Return: 

- Clamped point

### func clone\(\)
```cj
public func clone(): Box2
```
Clone the current bounding box

Return: 

- New bounding box instance

### func containsBox\(Box2\)
```cj
public func containsBox(b: Box2): Bool
```
Check if this bounding box fully contains another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box2|Another bounding box|

Return: 

- Whether the box is fully contained

### func containsPoint\(Vector2\)
```cj
public func containsPoint(point: Vector2): Bool
```
Check if a point is inside the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector2|Point to test|

Return: 

- Whether the point is contained

### func copy\(Box2\)
```cj
public func copy(b: Box2): Box2
```
Copy values from another bounding box to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box2|Source bounding box|

Return: 

- This instance

### func distanceToPoint\(Vector2\)
```cj
public func distanceToPoint(point: Vector2): Float64
```
Compute the Euclidean distance from a point to the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector2|Point to compute distance to|

Return: 

- Distance

### func equals\(Box2\)
```cj
public func equals(b: Box2): Bool
```
Check if this bounding box equals another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box2|Another bounding box|

Return: 

- Whether the boxes are equal

### func expandByPoint\(Vector2\)
```cj
public func expandByPoint(point: Vector2): Box2
```
Expand the bounding box to include a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector2|Point to include|

Return: 

- This instance

### func expandByScalar\(Float64\)
```cj
public func expandByScalar(s: Float64): Box2
```
Expand the bounding box by a scalar

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Expansion scalar|

Return: 

- This instance

### func expandByVector\(Vector2\)
```cj
public func expandByVector(v: Vector2): Box2
```
Expand the bounding box by a vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector2|Expansion vector|

Return: 

- This instance

### func getCenter\(Vector2\)
```cj
public func getCenter(target: Vector2): Vector2
```
Get the center point of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector2|Target vector for storing the result|

Return: 

- Center point

### func getParameter\(Vector2,Vector2\)
```cj
public func getParameter(point: Vector2, target: Vector2): Vector2
```
Get the parameterized position of a point within the bounding box (0-1 range)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector2|Point to testtarget Target vector|
|target|Vector2||

Return: 

- Parameterized position

### func getSize\(Vector2\)
```cj
public func getSize(target: Vector2): Vector2
```
Get the size of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector2|Target vector for storing the result|

Return: 

- Size vector

### func init\(\)
```cj
public init()
```
Construct an empty bounding box (min=+Inf, max=-Inf)

### func init\(Vector2,Vector2\)
```cj
public init(min: Vector2, max: Vector2)
```
Construct a bounding box with specified min and max points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Minimum pointmax Maximum point|
|max|Vector2||

### func intersect\(Box2\)
```cj
public func intersect(b: Box2): Box2
```
Compute the intersection with another bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box2|Another bounding box|

Return: 

- This instance

### func intersectsBox\(Box2\)
```cj
public func intersectsBox(b: Box2): Bool
```
Check if this bounding box intersects another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box2|Another bounding box|

Return: 

- Whether the boxes intersect

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Check if the bounding box is empty

Return: 

- Whether the box is empty

### func makeEmpty\(\)
```cj
public func makeEmpty(): Box2
```
Make the bounding box empty (containing no points)

Return: 

- This instance

### func setFromCenterAndSize\(Vector2,Vector2\)
```cj
public func setFromCenterAndSize(center: Vector2, size: Vector2): Box2
```
Set the bounding box from center and size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Center pointsize Size|
|size|Vector2||

Return: 

- This instance

### func setFromPoints\(ArrayList<Vector2>\)
```cj
public func setFromPoints(points: ArrayList < Vector2 >): Box2
```
Set the bounding box from a set of points

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|ArrayList<Vector2>|Point collection|

Return: 

- This instance

### func set\(Vector2,Vector2\)
```cj
public func set(min: Vector2, max: Vector2): Box2
```
Set the min and max bounds of the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|Vector2|Minimum pointmax Maximum point|
|max|Vector2||

Return: 

- This instance

### func translate\(Vector2\)
```cj
public func translate(offset: Vector2): Box2
```
Translate the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Vector2|Translation offset|

Return: 

- This instance

### func union\(Box2\)
```cj
public func union(b: Box2): Box2
```
Compute the union with another bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Box2|Another bounding box|

Return: 

- This instance

### var max
```cj
public var max: Vector2
```
Upper bound of the bounding box

### var min
```cj
public var min: Vector2
```
Lower bound of the bounding box

