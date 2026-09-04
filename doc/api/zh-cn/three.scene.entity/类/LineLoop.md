# 类
## class LineLoop
```cj
public class LineLoop <: Line
```
线环，首末顶点自动连接成环的闭合折线

### func init\(BufferGeometry,Material\)
```cj
public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial())
```
构造一个新的线环

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|顶点/索引几何，默认空 BufferGeometrymaterial 线材质，默认空 LineBasicMaterial|
|material|Material||

