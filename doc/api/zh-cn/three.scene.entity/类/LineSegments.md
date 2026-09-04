# 类
## class LineSegments
```cj
public open class LineSegments <: Line
```
线段组渲染对象，从一组顶点两两配对为独立线段

### func computeLineDistances\(\)
```cj
public override func computeLineDistances(): Line
```
计算并写入几何的 lineDistance 属性（各顶点按所属线段距离，非累计）

返回: 

- 返回 this 以支持链式调用

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial())
```
构造一个新的线段组

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|顶点/索引几何，默认空 BufferGeometrymaterial 线材质，默认空 LineBasicMaterial|
|material|Material||

