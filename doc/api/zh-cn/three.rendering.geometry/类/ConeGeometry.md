# 类
## class ConeGeometry
```cj
public class ConeGeometry <: CylinderGeometry
```
圆锥体几何体类，是 CylinderGeometry 的特例（radiusTop = 0）

### func init\(Float64,Float64,Int64,Int64,Bool,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, height!: Float64 = 1.0, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1, openEnded!: Bool = false, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
构造圆锥体几何体

参数: 

|名称|类型|描述|
|---|---|---|
|radius|Float64|底面半径，默认为 1height 高度，默认为 1radialSegments 径向段数，默认为 8heightSegments 高度段数，默认为 1openEnded 是否开放底面，默认为 falsethetaStart 起始角，默认为 0thetaLength 角度范围，默认为 2π|
|height|Float64||
|radialSegments|Int64||
|heightSegments|Int64||
|openEnded|Bool||
|thetaStart|Float64||
|thetaLength|Float64||

