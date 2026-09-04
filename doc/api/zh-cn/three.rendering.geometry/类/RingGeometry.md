# 类
## class RingGeometry
```cj
public class RingGeometry <: BufferGeometry
```
环形几何体类

### func init\(Float64,Float64,Int64,Int64,Float64,Float64\)
```cj
public init(innerRadius!: Float64 = 0.5, outerRadius!: Float64 = 1.0, thetaSegments!: Int64 = 32, phiSegments!: Int64 = 1, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
构造环形几何体

参数: 

|名称|类型|描述|
|---|---|---|
|innerRadius|Float64|内半径，默认 0.5outerRadius 外半径，默认 1.0thetaSegments 圆周分段数，默认 32phiSegments 径向分段数，默认 1thetaStart 起始角（弧度），默认 0thetaLength 圆弧长度（弧度），默认 2π|
|outerRadius|Float64||
|thetaSegments|Int64||
|phiSegments|Int64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

