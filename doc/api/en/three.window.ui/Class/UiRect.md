# Class
## class UiRect
```cj
public class UiRect
```
Rectangle math helper class

### func addPoint\(Float32,Float32\)
```cj
public func addPoint(x: Float32, y: Float32): UiRect
```
Adds a point (expands rectangle to contain it)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|Point X coordinate|
|y|Float32|Point Y coordinate|

Return: 

- New rectangle containing the point

### func clipWith\(UiRect\)
```cj
public func clipWith(other: UiRect): UiRect
```
Clips (intersects with another rectangle)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|UiRect|Another rectangle|

Return: 

- New rectangle of the intersection

### func containsRect\(UiRect\)
```cj
public func containsRect(other: UiRect): Bool
```
Whether another rectangle is fully contained

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|UiRect|Another rectangle|

Return: 

- true if fully contained

### func contains\(Float32,Float32\)
```cj
public func contains(x: Float32, y: Float32): Bool
```
Whether a point is inside the rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|Point X coordinate|
|y|Float32|Point Y coordinate|

Return: 

- true if the point is inside

### func expandVec\(Float32,Float32\)
```cj
public func expandVec(dx: Float32, dy: Float32): UiRect
```
Expands the rectangle with separate X/Y amounts

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dx|Float32|X expansion amount|
|dy|Float32|Y expansion amount|

Return: 

- The expanded rectangle

### func expand\(Float32\)
```cj
public func expand(amount: Float32): UiRect
```
Expands the rectangle by the given amount in all directions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|amount|Float32|Expansion amount in all directions|

Return: 

- The expanded rectangle

### func fromPosSize\(Float32,Float32,Float32,Float32\)
```cj
public static func fromPosSize(x: Float32, y: Float32, w: Float32, h: Float32): UiRect
```
Constructs from position and size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|Top-left X|
|y|Float32|Top-left Y|
|w|Float32|Width|
|h|Float32|Height|

Return: 

- The rectangle object

### func getArea\(\)
```cj
public func getArea(): Float32
```
Area

Return: 

- Rectangle area

### func getBL\(\)
```cj
public func getBL(): ImVec2
```
Bottom-left corner

Return: 

- Bottom-left coordinates

### func getBR\(\)
```cj
public func getBR(): ImVec2
```
Bottom-right corner

Return: 

- Bottom-right coordinates

### func getCenter\(\)
```cj
public func getCenter(): ImVec2
```
Rectangle center point

Return: 

- Center point coordinates

### func getHeight\(\)
```cj
public func getHeight(): Float32
```
Height

Return: 

- Rectangle height

### func getSize\(\)
```cj
public func getSize(): ImVec2
```
Rectangle size

Return: 

- Width/height

### func getTL\(\)
```cj
public func getTL(): ImVec2
```
Top-left corner

Return: 

- Top-left coordinates

### func getTR\(\)
```cj
public func getTR(): ImVec2
```
Top-right corner

Return: 

- Top-right coordinates

### func getWidth\(\)
```cj
public func getWidth(): Float32
```
Width

Return: 

- Rectangle width

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32)
```
Constructs a rectangle from min/max coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minX|Float32|Top-left X|
|minY|Float32|Top-left Y|
|maxX|Float32|Bottom-right X|
|maxY|Float32|Bottom-right Y|

### func init\(ImVec2,ImVec2\)
```cj
public init(min: ImVec2, max: ImVec2)
```
Constructs a rectangle from ImVec2 endpoints

Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|ImVec2|Top-left point|
|max|ImVec2|Bottom-right point|

### func isInverted\(\)
```cj
public func isInverted(): Bool
```
Whether the rectangle is inverted (min > max)

Return: 

- true if inverted

### func overlaps\(UiRect\)
```cj
public func overlaps(other: UiRect): Bool
```
Whether two rectangles overlap

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|UiRect|Another rectangle|

Return: 

- true if overlapping

### func toVec4\(\)
```cj
public func toVec4(): ImVec4
```
Converts to ImVec4 (x=minX, y=minY, z=maxX, w=maxY)

Return: 

- ImVec4 representation

### func translate\(Float32,Float32\)
```cj
public func translate(dx: Float32, dy: Float32): UiRect
```
Translates the rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dx|Float32|X offset|
|dy|Float32|Y offset|

Return: 

- The translated rectangle

