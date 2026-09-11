# 类
## class UiRect
```cj
public class UiRect
```
矩形运算辅助类

### func addPoint\(Float32,Float32\)
```cj
public func addPoint(x: Float32, y: Float32): UiRect
```
添加点（扩展矩形以包含该点）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||
|y|Float32||

### func clipWith\(UiRect\)
```cj
public func clipWith(other: UiRect): UiRect
```
裁剪（与另一个矩形求交）

参数: 

|名称|类型|描述|
|---|---|---|
|other|UiRect||

### func containsRect\(UiRect\)
```cj
public func containsRect(other: UiRect): Bool
```
另一个矩形是否完全在本矩形内

参数: 

|名称|类型|描述|
|---|---|---|
|other|UiRect||

### func contains\(Float32,Float32\)
```cj
public func contains(x: Float32, y: Float32): Bool
```
点是否在矩形内

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||
|y|Float32||

### func expandVec\(Float32,Float32\)
```cj
public func expandVec(dx: Float32, dy: Float32): UiRect
```
扩展矩形（分别指定 X/Y 扩展量）

参数: 

|名称|类型|描述|
|---|---|---|
|dx|Float32||
|dy|Float32||

### func expand\(Float32\)
```cj
public func expand(amount: Float32): UiRect
```
扩展矩形（各方向扩大指定量）

参数: 

|名称|类型|描述|
|---|---|---|
|amount|Float32||

### func fromPosSize\(Float32,Float32,Float32,Float32\)
```cj
public static func fromPosSize(x: Float32, y: Float32, w: Float32, h: Float32): UiRect
```
从位置和尺寸构造

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32||
|y|Float32||
|w|Float32||
|h|Float32||

### func getArea\(\)
```cj
public func getArea(): Float32
```
面积

### func getBL\(\)
```cj
public func getBL(): ImVec2
```
左下角

### func getBR\(\)
```cj
public func getBR(): ImVec2
```
右下角

### func getCenter\(\)
```cj
public func getCenter(): ImVec2
```
矩形中心点

### func getHeight\(\)
```cj
public func getHeight(): Float32
```
高度

### func getSize\(\)
```cj
public func getSize(): ImVec2
```
矩形尺寸

### func getTL\(\)
```cj
public func getTL(): ImVec2
```
左上角

### func getTR\(\)
```cj
public func getTR(): ImVec2
```
右上角

### func getWidth\(\)
```cj
public func getWidth(): Float32
```
宽度

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32)
```


参数: 

|名称|类型|描述|
|---|---|---|
|minX|Float32||
|minY|Float32||
|maxX|Float32||
|maxY|Float32||

### func init\(ImVec2,ImVec2\)
```cj
public init(min: ImVec2, max: ImVec2)
```


参数: 

|名称|类型|描述|
|---|---|---|
|min|ImVec2||
|max|ImVec2||

### func isInverted\(\)
```cj
public func isInverted(): Bool
```
矩形是否反转（min > max）

### func overlaps\(UiRect\)
```cj
public func overlaps(other: UiRect): Bool
```
两个矩形是否重叠

参数: 

|名称|类型|描述|
|---|---|---|
|other|UiRect||

### func toVec4\(\)
```cj
public func toVec4(): ImVec4
```
转换为 ImVec4（x=minX, y=minY, z=maxX, w=maxY）

### func translate\(Float32,Float32\)
```cj
public func translate(dx: Float32, dy: Float32): UiRect
```
平移矩形

参数: 

|名称|类型|描述|
|---|---|---|
|dx|Float32||
|dy|Float32||

