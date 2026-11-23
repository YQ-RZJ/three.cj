# Class
## class ShapeUtils
```cj
public class ShapeUtils
```
Shape utility class, provides 2D polygon area calculation, winding direction and triangulation

### func area\(Array<Vector2>\)
```cj
public static func area(contour: Array < Vector2 >): Float64
```
Calculate the area of a 2D contour polygon

Parameter: 

|Name|Type|Describe|
|---|---|---|
|contour|Array<Vector2>|Vertex array defining polygon boundary in order|

Return: 

- Signed area, positive for counterclockwise, negative for clockwise

### func isClockWise\(Array<Vector2>\)
```cj
public static func isClockWise(pts: Array < Vector2 >): Bool
```
Determine whether the contour has clockwise winding

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pts|Array<Vector2>|Vertex array|

Return: 

- true for clockwise, false for counterclockwise

### func triangulateShape\(ArrayList<Vector2>,ArrayList<ArrayList<Vector2>>\)
```cj
public static func triangulateShape(contour: ArrayList < Vector2 >, holes: ArrayList < ArrayList < Vector2 >>): Array < Array < UInt32 >>
```
Triangulate a compound shape with holes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|contour|ArrayList<Vector2>|Outer contour vertex array (modified in-place: removes trailing duplicate of first point)holes List of hole vertex arrays (also modified in-place)|
|holes|ArrayList<ArrayList<Vector2>>||

Return: 

- Triangle face array, each element is a length-3 index array (corresponding to combined contour+holes vertex indices)

