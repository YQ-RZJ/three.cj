# 类
## class TubeGeometry
```cj
public class TubeGeometry <: BufferGeometry
```
管道几何体类，沿 3D 曲线挤出管道

### func init\(Curve,Int64,Float64,Int64,Bool\)
```cj
public init(path: Curve, tubularSegments!: Int64 = 64, radius!: Float64 = 1.0, radialSegments!: Int64 = 8, closed!: Bool = false)
```
构造管道几何体

参数: 

|名称|类型|描述|
|---|---|---|
|path|Curve|管道沿着的 3D 曲线tubularSegments 管状分段数，默认 64radius 管道半径，默认 1.0radialSegments 径向分段数，默认 8closed 管道是否闭合，默认 false|
|tubularSegments|Int64||
|radius|Float64||
|radialSegments|Int64||
|closed|Bool||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

