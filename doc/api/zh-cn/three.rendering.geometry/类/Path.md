# 类
## class Path
```cj
public open class Path <: CurvePath
```
2D 路径类

### func absarc\(Float64,Float64,Float64,Float64,Float64,Bool\)
```cj
public func absarc(aX: Float64, aY: Float64, aRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool): Unit
```
添加绝对圆弧

参数: 

|名称|类型|描述|
|---|---|---|
|aX|Float64|圆心 X 坐标aY 圆心 Y 坐标aRadius 半径aStartAngle 起始角aEndAngle 终止角aClockwise 是否顺时针|
|aY|Float64||
|aRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||

### func absellipse\(Float64,Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public func absellipse(aX: Float64, aY: Float64, xRadius: Float64, yRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit
```
添加绝对椭圆弧

参数: 

|名称|类型|描述|
|---|---|---|
|aX|Float64|圆心 X 坐标aY 圆心 Y 坐标xRadius X 方向半径yRadius Y 方向半径aStartAngle 起始角aEndAngle 终止角aClockwise 是否顺时针aRotation 旋转角|
|aY|Float64||
|xRadius|Float64||
|yRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||
|aRotation|Float64||

### func arc\(Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public func arc(aX: Float64, aY: Float64, aRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit
```
添加相对圆弧

参数: 

|名称|类型|描述|
|---|---|---|
|aX|Float64|圆心 X 偏移aY 圆心 Y 偏移aRadius 半径aStartAngle 起始角aEndAngle 终止角aClockwise 是否顺时针aRotation 旋转角|
|aY|Float64||
|aRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||
|aRotation|Float64||

### func bezierCurveTo\(Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public func bezierCurveTo(cp1x: Float64, cp1y: Float64, cp2x: Float64, cp2y: Float64, x: Float64, y: Float64): Unit
```
从当前点画三次贝塞尔曲线到指定位置

参数: 

|名称|类型|描述|
|---|---|---|
|cp1x|Float64|第一个控制点 X 坐标cp1y 第一个控制点 Y 坐标cp2x 第二个控制点 X 坐标cp2y 第二个控制点 Y 坐标x 目标 X 坐标y 目标 Y 坐标|
|cp1y|Float64||
|cp2x|Float64||
|cp2y|Float64||
|x|Float64||
|y|Float64||

### func copy\(Curve\)
```cj
public open override func copy(source: Curve): Curve
```
复制源路径的设置到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve|源曲线|

返回: 

- 当前实例的引用

### func ellipse\(Float64,Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public func ellipse(aX: Float64, aY: Float64, xRadius: Float64, yRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|aX|Float64||
|aY|Float64||
|xRadius|Float64||
|yRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||
|aRotation|Float64||

### func fromJSON\(HashMap<String,Any>\)
```cj
public open override func fromJSON(json: HashMap < String, Any >): Curve
```
从 JSON 反序列化路径

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|包含路径数据的 HashMap|

返回: 

- 当前实例的引用

### func fromPoints\(Array<Vector3>\)
```cj
public func fromPoints(points: Array < Vector3 >): Unit
```
从点数组创建路径

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|点数组|

### func init\(\)
```cj
public init()
```
构造空路径

### func init\(Array<Vector3>\)
```cj
public init(points: Array < Vector3 >)
```
从点数组构造路径

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|定义路径的 2D 点数组|

### func lineTo\(Float64,Float64\)
```cj
public func lineTo(x: Float64, y: Float64): Unit
```
从当前点画直线到指定位置

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|目标 X 坐标y 目标 Y 坐标|
|y|Float64||

### func moveTo\(Float64,Float64\)
```cj
public func moveTo(x: Float64, y: Float64): Unit
```
移动当前绘制点到指定位置

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float64|X 坐标y Y 坐标|
|y|Float64||

### func quadraticCurveTo\(Float64,Float64,Float64,Float64\)
```cj
public func quadraticCurveTo(cpx: Float64, cpy: Float64, x: Float64, y: Float64): Unit
```
从当前点画二次贝塞尔曲线到指定位置

参数: 

|名称|类型|描述|
|---|---|---|
|cpx|Float64|控制点 X 坐标cpy 控制点 Y 坐标x 目标 X 坐标y 目标 Y 坐标|
|cpy|Float64||
|x|Float64||
|y|Float64||

### func splineThru\(Array<Vector3>\)
```cj
public func splineThru(points: Array < Vector3 >): Unit
```
添加样条曲线通过指定点

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector3>|样条曲线通过的点数组|

### var currentPoint
```cj
public var currentPoint: Vector3
```
当前绘制点

