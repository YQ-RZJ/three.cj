# 类
## class ArcCurve
```cj
public class ArcCurve <: EllipseCurve
```
弧曲线类，继承自 EllipseCurve

### func init\(Float64,Float64,Float64,Float64,Float64,Bool\)
```cj
public init(aX!: Float64 = 0.0, aY!: Float64 = 0.0, aRadius!: Float64 = 1.0, aStartAngle!: Float64 = 0.0, aEndAngle!: Float64 = 2.0 * PI, aClockwise!: Bool = false)
```
构造新的弧曲线

参数: 

|名称|类型|描述|
|---|---|---|
|aX|Float64|椭圆中心 X 坐标，默认为 0aY 椭圆中心 Y 坐标，默认为 0aRadius 半径，默认为 1aStartAngle 起始角，默认为 0aEndAngle 终止角，默认为 Math.PI*2aClockwise 是否顺时针，默认为 false|
|aY|Float64||
|aRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||

