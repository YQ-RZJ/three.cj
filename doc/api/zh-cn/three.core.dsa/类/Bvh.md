# 类
## class Bvh
```cj
public class Bvh
```
包围体层次结构（BVH）

### func build\(Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>\)
```cj
public func build(centerX: Array < Float64 >, centerY: Array < Float64 >, centerZ: Array < Float64 >, halfX: Array < Float64 >, halfY: Array < Float64 >, halfZ: Array < Float64 >): Unit
```
用元素中心与半尺寸构建 BVH

参数: 

|名称|类型|描述|
|---|---|---|
|centerX|Array<Float64>|元素中心 X 分量|
|centerY|Array<Float64>|元素中心 Y 分量|
|centerZ|Array<Float64>|元素中心 Z 分量|
|halfX|Array<Float64>|元素包围盒半尺寸 X 分量|
|halfY|Array<Float64>|元素包围盒半尺寸 Y 分量|
|halfZ|Array<Float64>|元素包围盒半尺寸 Z 分量|

### func getElementBounds\(Int64,Array<Float64>,Array<Float64>\)
```cj
public func getElementBounds(element: Int64, outCenter: Array < Float64 >, outHalf: Array < Float64 >): Unit
```
读取元素的包围盒（中心 + 半尺寸）

参数: 

|名称|类型|描述|
|---|---|---|
|element|Int64|元素下标|
|outCenter|Array<Float64>|输出中心（写入 cx, cy, cz）|
|outHalf|Array<Float64>|输出半尺寸（写入 hx, hy, hz）|

### func getRootBounds\(Vector3,Vector3\)
```cj
public func getRootBounds(outMin: Vector3, outMax: Vector3): Bool
```
取根节点包围盒（最小点写入 outMin，最大点写入 outMax）

参数: 

|名称|类型|描述|
|---|---|---|
|outMin|Vector3|输出最小点|
|outMax|Vector3|输出最大点|

返回: 

- 是否存在根节点

### func init\(\)
```cj
public init()
```
构造空的 BVH

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空（无元素）

### func queryFrustum\(Frustum,ArrayList<Int64>\)
```cj
public func queryFrustum(frustum: Frustum, out: ArrayList < Int64 >): Unit
```
视锥查询：收集包围盒与视锥相交的叶子元素下标

参数: 

|名称|类型|描述|
|---|---|---|
|frustum|Frustum|视锥|
|out|ArrayList<Int64>|输出数组（追加命中下标）|

### func queryRay\(Vector3,Vector3,Float64,ArrayList<Int64>\)
```cj
public func queryRay(origin: Vector3, direction: Vector3, maxDistance: Float64, out: ArrayList < Int64 >): Unit
```
射线查询：收集包围盒与射线相交的叶子元素下标

参数: 

|名称|类型|描述|
|---|---|---|
|origin|Vector3|射线起点|
|direction|Vector3|射线方向（不必归一化）|
|maxDistance|Float64|最远距离|
|out|ArrayList<Int64>|输出数组（追加命中下标）|

### func refit\(\)
```cj
public func refit(): Unit
```
元素移动后重算各级包围盒（自底向上）

### func updateBounds\(Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>,Array<Float64>\)
```cj
public func updateBounds(centerX: Array < Float64 >, centerY: Array < Float64 >, centerZ: Array < Float64 >, halfX: Array < Float64 >, halfY: Array < Float64 >, halfZ: Array < Float64 >): Unit
```
整体替换元素包围盒数据（中心 + 半尺寸）并 refit

参数: 

|名称|类型|描述|
|---|---|---|
|centerX|Array<Float64>|新的中心 X 分量|
|centerY|Array<Float64>|新的中心 Y 分量|
|centerZ|Array<Float64>|新的中心 Z 分量|
|halfX|Array<Float64>|新的半尺寸 X 分量|
|halfY|Array<Float64>|新的半尺寸 Y 分量|
|halfZ|Array<Float64>|新的半尺寸 Z 分量|

### func updateCenters\(Array<Float64>,Array<Float64>,Array<Float64>\)
```cj
public func updateCenters(centerX: Array < Float64 >, centerY: Array < Float64 >, centerZ: Array < Float64 >): Unit
```
元素中心更新后调用 refit 的便捷入口

参数: 

|名称|类型|描述|
|---|---|---|
|centerX|Array<Float64>|新的中心 X 分量|
|centerY|Array<Float64>|新的中心 Y 分量|
|centerZ|Array<Float64>|新的中心 Z 分量|

### prop elementCount: Int64
```cj
public prop elementCount: Int64
```
元素总数

### prop nodeCount: Int64
```cj
public prop nodeCount: Int64
```
节点总数

