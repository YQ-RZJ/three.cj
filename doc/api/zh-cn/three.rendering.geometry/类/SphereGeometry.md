# 类
## class SphereGeometry
```cj
public class SphereGeometry <: BufferGeometry
```
球体几何体类

### func init\(Float64,Int64,Int64,Float64,Float64,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, widthSegments!: Int64 = 32, heightSegments!: Int64 = 16, phiStart!: Float64 = 0.0, phiLength!: Float64 = PI * 2.0, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI)
```
构造球体几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|球体半径，默认 1.0widthSegments 水平分段数，默认 32heightSegments 垂直分段数，默认 16phiStart 水平起始角，默认 0phiLength 水平弧长，默认 2πthetaStart 垂直起始角，默认 0thetaLength 垂直弧长，默认 π|
|widthSegments|Int64||
|heightSegments|Int64||
|phiStart|Float64||
|phiLength|Float64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

