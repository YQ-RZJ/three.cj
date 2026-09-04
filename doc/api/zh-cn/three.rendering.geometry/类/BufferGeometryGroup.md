# 类
## class BufferGeometryGroup
```cj
public class BufferGeometryGroup
```
绘制组结构，定义几何体的绘制分组

### func init\(Int64,Int64,Int64\)
```cj
public init(start: Int64, count: Int64, materialIndex!: Int64 = 0)
```
构造绘制组

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int64|起始位置count 元素数量materialIndex 材质索引，默认为 0|
|count|Int64||
|materialIndex|Int64||

### var count
```cj
public var count: Int64
```
此组包含多少顶点（或索引）

### var materialIndex
```cj
public var materialIndex: Int64
```
使用的材质数组索引，默认 0

### var start
```cj
public var start: Int64
```
此绘制调用中的第一个元素（非索引几何体为第一个顶点，否则为第一个三角形索引）

