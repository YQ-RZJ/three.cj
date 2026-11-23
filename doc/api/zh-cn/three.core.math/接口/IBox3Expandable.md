# 接口
## interface IBox3Expandable
```cj
public interface IBox3Expandable
```
包围盒展开只读接口：供 Box3.setFromObject / expandByObject 遍历使用

### func getChildAt\(Int64\)
```cj
func getChildAt(i: Int64): IBox3Expandable
```
获取第 i 个子对象

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|子对象索引|

返回: 

- 子对象（同样实现 IBox3Expandable）

### func getChildCount\(\)
```cj
func getChildCount(): Int64
```
获取子对象数量

返回: 

- 子对象数量

### func getPreciseVertexCount\(\)
```cj
func getPreciseVertexCount(): Int64
```
获取精确模式逐顶点遍历的顶点数

返回: 

- 顶点数（0 表示不支持精确遍历，调用方应回退保守路径）

### func getPreciseVertexPosition\(Int64\)
```cj
func getPreciseVertexPosition(i: Int64): Array < Float64 >
```
获取第 i 个顶点的世界空间位置

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|顶点索引|

返回: 

- 世界空间坐标 [x, y, z]

### func getWorldBoundingBox\(\)
```cj
func getWorldBoundingBox(): Option <(Array < Float64 >, Array < Float64 >) >
```
计算对象自身（不含子对象）的世界空间包围盒

返回: 

- Some(([minX,minY,minZ], [maxX,maxY,maxZ])) 或 None（无几何体）

### func updateWorldMatrix\(Bool,Bool,Bool\)
```cj
func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit
```
更新对象的世界矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|updateParents|Bool|是否更新父级updateChildren 是否更新子级force 是否强制更新|
|updateChildren|Bool||
|force|Bool||

