# 类
## class CapsuleGeometry
```cj
public class CapsuleGeometry <: BufferGeometry
```
胶囊体几何体类，由圆柱体中间段和两个半球帽组成

### func init\(Float64,Float64,Int64,Int64,Int64\)
```cj
public init(radius!: Float64 = 1.0, length!: Float64 = 1.0, capSegments!: Int64 = 4, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1)
```
构造胶囊体几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|半径，默认为 1length 圆柱段长度，默认为 1capSegments 帽段数，默认为 4radialSegments 径向段数，默认为 8heightSegments 高度段数，默认为 1|
|length|Float64||
|capSegments|Int64||
|radialSegments|Int64||
|heightSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
几何体生成参数

