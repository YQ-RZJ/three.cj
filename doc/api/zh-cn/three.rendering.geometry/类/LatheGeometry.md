# 类
## class LatheGeometry
```cj
public class LatheGeometry <: BufferGeometry
```
车削几何体类

### func init\(Array<Vector2>,Int64,Float64,Float64\)
```cj
public init(points: Array < Vector2 >, segments!: Int64 = 12, phiStart!: Float64 = 0.0, phiLength!: Float64 = PI * 2.0)
```
构造车削几何体

参数: 

|名称|类型|描述|
|---|---|---|
|points|Array<Vector2>|2D 轮廓点数组segments 圆周分段数，默认 12phiStart 起始角（弧度），默认 0phiLength 旋转弧度，默认 2π|
|segments|Int64||
|phiStart|Float64||
|phiLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

