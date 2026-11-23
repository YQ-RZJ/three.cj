# 类
## class PlaneGeometry
```cj
public class PlaneGeometry <: BufferGeometry
```
平面几何体类

### func init\(Float64,Float64,Int64,Int64\)
```cj
public init(width!: Float64 = 1.0, height!: Float64 = 1.0, widthSegments!: Int64 = 1, heightSegments!: Int64 = 1)
```
构造平面几何体

参数: 

|名称|类型|描述|
|---|---|---|
|width|Float64|平面宽度，默认 1.0height 平面高度，默认 1.0widthSegments 宽度方向分段数，默认 1heightSegments 高度方向分段数，默认 1|
|height|Float64||
|widthSegments|Int64||
|heightSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

