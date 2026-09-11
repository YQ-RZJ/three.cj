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
|x|Float32||
|y|Float32||

### func clipWith\(UiRect\)
```cj
public func clipWith(other: UiRect): UiRect
```
Clips (intersects with another rectangle)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|UiRect||

### func containsRect\(UiRect\)
```cj
public func containsRect(other: UiRect): Bool
```
Whether another rectangle is fully contained

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|UiRect||

### func contains\(Float32,Float32\)
```cj
public func contains(x: Float32, y: Float32): Bool
```
Whether a point is inside the rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||

### func expandVec\(Float32,Float32\)
```cj
public func expandVec(dx: Float32, dy: Float32): UiRect
```
Expands the rectangle with separate X/Y amounts

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dx|Float32||
|dy|Float32||

### func expand\(Float32\)
```cj
public func expand(amount: Float32): UiRect
```
Expands the rectangle by the given amount in all directions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|amount|Float32||

### func fromPosSize\(Float32,Float32,Float32,Float32\)
```cj
public static func fromPosSize(x: Float32, y: Float32, w: Float32, h: Float32): UiRect
```
Constructs from position and size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32||
|y|Float32||
|w|Float32||
|h|Float32||

### func getArea\(\)
```cj
public func getArea(): Float32
```
Area

### func getBL\(\)
```cj
public func getBL(): ImVec2
```
Bottom-left corner

### func getBR\(\)
```cj
public func getBR(): ImVec2
```
Bottom-right corner

### func getCenter\(\)
```cj
public func getCenter(): ImVec2
```
Rectangle center point

### func getHeight\(\)
```cj
public func getHeight(): Float32
```
Height

### func getSize\(\)
```cj
public func getSize(): ImVec2
```
Rectangle size

### func getTL\(\)
```cj
public func getTL(): ImVec2
```
Top-left corner

### func getTR\(\)
```cj
public func getTR(): ImVec2
```
Top-right corner

### func getWidth\(\)
```cj
public func getWidth(): Float32
```
Width

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|minX|Float32||
|minY|Float32||
|maxX|Float32||
|maxY|Float32||

### func init\(ImVec2,ImVec2\)
```cj
public init(min: ImVec2, max: ImVec2)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|min|ImVec2||
|max|ImVec2||

### func isInverted\(\)
```cj
public func isInverted(): Bool
```
Whether the rectangle is inverted (min > max)

### func overlaps\(UiRect\)
```cj
public func overlaps(other: UiRect): Bool
```
Whether two rectangles overlap

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|UiRect||

### func toVec4\(\)
```cj
public func toVec4(): ImVec4
```
Converts to ImVec4 (x=minX, y=minY, z=maxX, w=maxY)

### func translate\(Float32,Float32\)
```cj
public func translate(dx: Float32, dy: Float32): UiRect
```
Translates the rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dx|Float32||
|dy|Float32||

