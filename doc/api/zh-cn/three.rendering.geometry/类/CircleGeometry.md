# 类
## class CircleGeometry
```cj
public class CircleGeometry <: BufferGeometry
```
圆形几何体类

### func init\(Float64,Int64,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, segments!: Int64 = 32, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
构造圆形几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径，默认为 1segments 分段数，默认为 32thetaStart 起始角，默认为 0thetaLength 角度范围，默认为 2π|
|segments|Int64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
几何体生成参数

