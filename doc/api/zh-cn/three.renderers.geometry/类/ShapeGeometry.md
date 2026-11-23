# 类
## class ShapeGeometry
```cj
public class ShapeGeometry <: BufferGeometry
```
形状几何体类，从 Shape 三角化生成平面网格

### func init\(Shape,Int64\)
```cj
public init(shape: Shape, curveSegments!: Int64 = 12)
```
构造形状几何体

参数: 

|名称|类型|描述|
|---|---|---|
|shape|Shape|定义外形的 Shape 对象curveSegments 曲线分段数，默认 12|
|curveSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
构造参数

