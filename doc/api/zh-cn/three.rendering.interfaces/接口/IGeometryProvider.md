# 接口
## interface IGeometryProvider
```cj
public interface IGeometryProvider
```
几何体能力接口：供裁剪/包围盒/精确遍历访问几何体数据

### func computeBoundingBox\(\)
```cj
func computeBoundingBox(): Unit
```
计算包围盒（实现方更新自身 boundingBox）

### func computeBoundingSphere\(\)
```cj
func computeBoundingSphere(): Unit
```
计算包围球（实现方更新自身 boundingSphere）

### func getAttributeReader\(String\)
```cj
func getAttributeReader(name: String): Option < AttributeReader >
```
按名称获取顶点属性（AttributeReader 只读接口，position/normal/uv 等）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func getBoundingBox\(\)
```cj
func getBoundingBox(): Option < Box3 >
```
获取包围盒（None 表示无几何体数据）

### func getBoundingSphere\(\)
```cj
func getBoundingSphere(): Option < Sphere >
```
获取包围球（None 表示无几何体数据）

