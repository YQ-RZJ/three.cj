# 类
## class TorusKnotGeometry
```cj
public class TorusKnotGeometry <: BufferGeometry
```
环面纽结几何体类

### func init\(Float64,Float64,Int64,Int64,Int64,Int64\)
```cj
public init(radius!: Float64 = 1.0, tube!: Float64 = 0.4, tubularSegments!: Int64 = 64, radialSegments!: Int64 = 8, p!: Int64 = 2, q!: Int64 = 3)
```
构造环面纽结几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|环面纽结半径，默认 1.0tube 管半径，默认 0.4tubularSegments 管状分段数，默认 64radialSegments 径向分段数，默认 8p 缠绕次数 p，默认 2q 缠绕次数 q，默认 3|
|tube|Float64||
|tubularSegments|Int64||
|radialSegments|Int64||
|p|Int64||
|q|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

