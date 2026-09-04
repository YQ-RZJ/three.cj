# Class
## class Line3
```cj
public class Line3
```
3D line segment class, defined by start and end points

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Line3
```
Apply a 4x4 transformation matrix to the line segment (start and end points transformed separately)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Matrix4|Transformation matrix|

Return: 

- This instance

### func at\(Float64,Vector3\)
```cj
public func at(t: Float64, target: Vector3): Vector3
```
Get the point at a specified parameter position on the line segment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Parameter value, 0 for start, 1 for endtarget Target vector|
|target|Vector3||

Return: 

- Point on the line segment

### func at\(Float64\)
```cj
public func at(t: Float64): Vector3
```
Get the point at a specified parameter position on the line segment (creates a new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Parameter value, 0 for start, 1 for end|

Return: 

- Point on the line segment

### func clone\(\)
```cj
public func clone(): Line3
```
Clone the current line segment

Return: 

- New line segment instance

### func closestPointToPointParameter\(Vector3,Bool\)
```cj
public func closestPointToPointParameter(point: Vector3, clampToLine!: Bool = true): Float64
```
Compute the closest point parameter on the line segment to a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|PointclampToLine Whether to clamp to the line segment range, default true|
|clampToLine|Bool||

Return: 

- Parameter value

### func closestPointToPoint\(Vector3,Vector3,Bool\)
```cj
public func closestPointToPoint(point: Vector3, target: Vector3, clampToLine!: Bool = true): Vector3
```
Compute the closest point on the line segment to a given point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Pointtarget Target vectorclampToLine Whether to clamp to the line segment range, default true|
|target|Vector3||
|clampToLine|Bool||

Return: 

- Closest point

### func closestPointToPoint\(Vector3,Bool\)
```cj
public func closestPointToPoint(point: Vector3, clampToLine!: Bool = true): Vector3
```
Compute the closest point on the line segment to a given point (creates a new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|PointclampToLine Whether to clamp to the line segment range, default true|
|clampToLine|Bool||

Return: 

- Closest point

### func copy\(Line3\)
```cj
public func copy(l: Line3): Line3
```
Copy values from another line segment to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|l|Line3|Source line segment|

Return: 

- This instance

### func delta\(Vector3\)
```cj
public func delta(target: Vector3): Vector3
```
Compute the direction vector of the line segment (end - start)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector|

Return: 

- Direction vector

### func delta\(\)
```cj
public func delta(): Vector3
```
Compute the direction vector of the line segment (creates a new vector)

Return: 

- Direction vector

### func distanceSqToLine3\(Line3,Vector3,Vector3\)
```cj
public func distanceSqToLine3(line: Line3, c1: Vector3, c2: Vector3): Float64
```
Compute the squared closest distance between two line segments

Parameter: 

|Name|Type|Describe|
|---|---|---|
|line|Line3|Another line segmentc1 Closest point on this line segment (output)c2 Closest point on the other line segment (output)|
|c1|Vector3||
|c2|Vector3||

Return: 

- Squared closest distance

### func distanceSq\(\)
```cj
public func distanceSq(): Float64
```
Compute the squared length of the line segment

Return: 

- Squared length

### func distance\(\)
```cj
public func distance(): Float64
```
Compute the length of the line segment

Return: 

- Length

### func equals\(Line3\)
```cj
public func equals(l: Line3): Bool
```
Check if this line segment equals another

Parameter: 

|Name|Type|Describe|
|---|---|---|
|l|Line3|Another line segment|

Return: 

- Whether they are equal

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): Line3
```
Set line segment components from an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array containing component valuesoffset Starting index, default 0|
|offset|Int64||

Return: 

- This instance

### func getCenter\(\)
```cj
public func getCenter(): Vector3
```
Get the center point of the line segment (creates a new vector)

Return: 

- Center point

### func getCenter\(Vector3\)
```cj
public func getCenter(target: Vector3): Vector3
```
Get the center point of the line segment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3|Target vector|

Return: 

- Center point

### func init\(\)
```cj
public init()
```


### func init\(Vector3,Vector3\)
```cj
public init(start: Vector3, end: Vector3)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Vector3||
|end|Vector3||

### func set\(Vector3,Vector3\)
```cj
public func set(start: Vector3, end: Vector3): Line3
```
Set the start and end points of the line segment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Vector3|Start pointend End point|
|end|Vector3||

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Write line segment components to an array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Starting index, default 0|
|offset|Int64||

Return: 

- Array containing component values

### var end
```cj
public var end: Vector3
```
End point of the line segment

### var start
```cj
public var start: Vector3
```
Start point of the line segment

