# 类
## class ShapeUtils
```cj
public class ShapeUtils
```
形状工具类，提供 2D 多边形的面积计算、绕向判断与三角剖分功能

### func area\(Array<Vector2>\)
```cj
public static func area(contour: Array < Vector2 >): Float64
```
计算 2D 轮廓多边形的面积

参数: 

|名称|类型|描述|
|---|---|---|
|contour|Array<Vector2>|顶点数组，按顺序定义多边形边界|

返回: 

- 有符号面积，正值表示逆时针，负值表示顺时针

### func isClockWise\(Array<Vector2>\)
```cj
public static func isClockWise(pts: Array < Vector2 >): Bool
```
判断轮廓是否为顺时针绕向

参数: 

|名称|类型|描述|
|---|---|---|
|pts|Array<Vector2>|顶点数组|

返回: 

- true 表示顺时针，false 表示逆时针

### func triangulateShape\(ArrayList<Vector2>,ArrayList<ArrayList<Vector2>>\)
```cj
public static func triangulateShape(contour: ArrayList < Vector2 >, holes: ArrayList < ArrayList < Vector2 >>): Array < Array < UInt32 >>
```
对带孔洞的复合形状进行三角剖分

参数: 

|名称|类型|描述|
|---|---|---|
|contour|ArrayList<Vector2>|外轮廓顶点数组（会被就地修改：去除与首点重复的尾点）holes 各孔洞的顶点数组列表（同样会被就地修改）|
|holes|ArrayList<ArrayList<Vector2>>||

返回: 

- 三角面数组，每个元素为长度 3 的序号数组（对应 contour+holes 拼合后的顶点序号）

