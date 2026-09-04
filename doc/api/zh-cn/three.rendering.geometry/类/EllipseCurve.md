# 类
## class EllipseCurve
```cj
public open class EllipseCurve <: Curve
```
椭圆曲线类

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```
将给定椭圆曲线的设置复制到此实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Curve||

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Curve
```
从 JSON 反序列化椭圆曲线

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>||

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|t|Float64|插值因子，0 到 1 之间|

返回: 

- 椭圆上的点（Vector3，z=0）返回椭圆上给定插值因子 t 处的点算法与 JS 侧一致：处理 deltaAngle 在 [0, 2π] 内、aClockwise 反向、aRotation 旋转。

### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public init(aX!: Float64 = 0.0, aY!: Float64 = 0.0, xRadius!: Float64 = 1.0, yRadius!: Float64 = 1.0, aStartAngle!: Float64 = 0.0, aEndAngle!: Float64 = 2.0 * PI, aClockwise!: Bool = false, aRotation!: Float64 = 0.0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|aX|Float64|椭圆中心 X 坐标，默认为 0|
|aY|Float64|椭圆中心 Y 坐标，默认为 0|
|xRadius|Float64|X 方向半径，默认为 1|
|yRadius|Float64|Y 方向半径，默认为 1|
|aStartAngle|Float64|起始角，默认为 0|
|aEndAngle|Float64|止止角，默认为 Math.PI*2|
|aClockwise|Bool|是否顺时针，默认为 false|
|aRotation|Float64|旋转角，默认为 0构造新的椭圆曲线|

### var aClockwise
```cj
public var aClockwise: Bool
```
是否顺时针绘制

### var aEndAngle
```cj
public var aEndAngle: Float64
```
终止角（弧度，从正 X 轴起）

### var aRotation
```cj
public var aRotation: Float64
```
椭圆的旋转角（弧度，从正 X 轴逆时针）

### var aStartAngle
```cj
public var aStartAngle: Float64
```
起始角（弧度，从正 X 轴起）

### var aX
```cj
public var aX: Float64
```
椭圆中心的 X 坐标

### var aY
```cj
public var aY: Float64
```
椭圆中心的 Y 坐标

### var xRadius
```cj
public var xRadius: Float64
```
X 方向半径。设为与 yRadius 相同可得圆

### var yRadius
```cj
public var yRadius: Float64
```
Y 方向半径。设为与 xRadius 相同可得圆

