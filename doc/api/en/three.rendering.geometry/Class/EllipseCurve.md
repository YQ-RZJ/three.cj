# Class
## class EllipseCurve
```cj
public open class EllipseCurve <: Curve
```
Ellipse curve class

### func copy\(Curve\)
```cj
public override func copy(source: Curve): Curve
```
将给定椭圆曲线的设置复制到此实例

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Curve||

### func fromJSON\(HashMap<String,Any>\)
```cj
public func fromJSON(json: HashMap < String, Any >): Curve
```
从 JSON 反序列化椭圆曲线

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>||

### func getPoint\(Float64\)
```cj
public override func getPoint(t: Float64): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|t|Float64|Interpolation factor, between 0 and 1|

Return: 

- Point on the ellipse (Vector3, z=0)Return the point on the ellipse at the given interpolation factor tAlgorithm consistent with JS side: handles deltaAngle within [0, 2π], aClockwise reversal, aRotation rotation.

### func init\(Float64,Float64,Float64,Float64,Float64,Float64,Bool,Float64\)
```cj
public init(aX!: Float64 = 0.0, aY!: Float64 = 0.0, xRadius!: Float64 = 1.0, yRadius!: Float64 = 1.0, aStartAngle!: Float64 = 0.0, aEndAngle!: Float64 = 2.0 * PI, aClockwise!: Bool = false, aRotation!: Float64 = 0.0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|aX|Float64|X coordinate of ellipse center, default 0|
|aY|Float64|Y coordinate of ellipse center, default 0|
|xRadius|Float64|X-direction radius, default 1|
|yRadius|Float64|Y-direction radius, default 1|
|aStartAngle|Float64|Start angle, default 0|
|aEndAngle|Float64|End angle, default Math.PI*2|
|aClockwise|Bool|Whether clockwise, default false|
|aRotation|Float64|Rotation angle, default 0Construct a new ellipse curve|

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

