# 类
## class BoxGeometry
```cj
public class BoxGeometry <: BufferGeometry
```
长方体几何体类

### func init\(Float64,Float64,Float64,Int64,Int64,Int64\)
```cj
public init(width!: Float64 = 1.0, height!: Float64 = 1.0, depth!: Float64 = 1.0, widthSegments!: Int64 = 1, heightSegments!: Int64 = 1, depthSegments!: Int64 = 1)
```
构造长方体几何体

参数: 

|名称|类型|描述|
|---|---|---|
|width|Float64|宽度，默认为 1height 高度，默认为 1depth 深度，默认为 1widthSegments 宽度方向分段数，默认为 1heightSegments 高度方向分段数，默认为 1depthSegments 深度方向分段数，默认为 1|
|height|Float64||
|depth|Float64||
|widthSegments|Int64||
|heightSegments|Int64||
|depthSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
几何体生成参数

