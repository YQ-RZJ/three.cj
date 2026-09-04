# 类
## class TorusGeometry
```cj
public class TorusGeometry <: BufferGeometry
```
圆环几何体类

### func init\(Float64,Float64,Int64,Int64,Float64,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, tube!: Float64 = 0.4, radialSegments!: Int64 = 12, tubularSegments!: Int64 = 48, arc!: Float64 = PI * 2.0, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
构造圆环几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|环半径（中心到管中心），默认 1.0tube 管半径，默认 0.4radialSegments 径向分段数，默认 12tubularSegments 管状分段数，默认 48arc 弧长（弧度），默认 2πthetaStart 径向起始角，默认 0thetaLength 径向弧长，默认 2π|
|tube|Float64||
|radialSegments|Int64||
|tubularSegments|Int64||
|arc|Float64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

