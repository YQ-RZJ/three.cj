# 接口
## interface IRenderObject
```cj
public interface IRenderObject
```
渲染对象占位接口，提供矩阵/几何体/材质/对象 ID 等查询方法

### func getGeometryId\(\)
```cj
func getGeometryId(): Int64
```
返回几何体 ID

### func getGroupOrder\(\)
```cj
func getGroupOrder(): Float64
```
返回渲染组索引

### func getMaterialId\(\)
```cj
func getMaterialId(): Int64
```
返回材质 ID

### func getMatrix\(\)
```cj
func getMatrix(): Array < Float64 >
```
返回 world matrix（16 个 Float64 列主序）

### func getNodeChain\(\)
```cj
func getNodeChain(): ArrayList < Object3D >
```
返回节点链（用于变换矩阵）

### func getObjectId\(\)
```cj
func getObjectId(): Int64
```
返回对象 ID

### func getRenderOrder\(\)
```cj
func getRenderOrder(): Float64
```
返回渲染顺序

