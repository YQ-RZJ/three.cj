# 类
## class CylinderGeometry
```cj
public open class CylinderGeometry <: BufferGeometry
```
圆柱几何体类

### func init\(Float64,Float64,Float64,Int64,Int64,Bool,Float64,Float64\)
```cj
public init(radiusTop!: Float64 = 1.0, radiusBottom!: Float64 = 1.0, height!: Float64 = 1.0, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1, openEnded!: Bool = false, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```


参数: 

|名称|类型|描述|
|---|---|---|
|radiusTop|Float64||
|radiusBottom|Float64||
|height|Float64||
|radialSegments|Int64||
|heightSegments|Int64||
|openEnded|Bool||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```


