# 类
## class SpatialHashGrid
```cj
public class SpatialHashGrid
```
空间哈希网格

### func clear\(\)
```cj
public func clear(): Unit
```
清空网格

### func init\(Float64\)
```cj
public init(cellSize: Float64)
```
构造空间哈希网格

参数: 

|名称|类型|描述|
|---|---|---|
|cellSize|Float64|格子边长（应接近查询半径的量级；<= 0 时按 1.0 处理）|

### func init\(\)
```cj
public init()
```
构造默认格子边长（1.0）的空间哈希网格

### func insert\(Int64,Float64,Float64,Float64,Float64\)
```cj
public func insert(index: Int64, x: Float64, y: Float64, z: Float64, radius: Float64): Unit
```
登记一个元素（按包围球覆盖到的所有格子登记）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|元素下标（必须为 0 起始的连续编号，与调用顺序一致）x 中心 Xy 中心 Yz 中心 Zradius 包围球半径|
|x|Float64||
|y|Float64||
|z|Float64||
|radius|Float64||

### func queryAabb\(Float64,Float64,Float64,Float64,Float64,Float64,ArrayList<Int64>\)
```cj
public func queryAabb(minX: Float64, minY: Float64, minZ: Float64, maxX: Float64, maxY: Float64, maxZ: Float64, out: ArrayList < Int64 >): Unit
```
轴对齐盒邻域查询

参数: 

|名称|类型|描述|
|---|---|---|
|minX|Float64|查询盒最小 XminY 查询盒最小 YminZ 查询盒最小 ZmaxX 查询盒最大 XmaxY 查询盒最大 YmaxZ 查询盒最大 Zout 命中元素下标|
|minY|Float64||
|minZ|Float64||
|maxX|Float64||
|maxY|Float64||
|maxZ|Float64||
|out|ArrayList<Int64>||

### func querySphere\(Float64,Float64,Float64,Float64,ArrayList<Int64>\)
```cj
public func querySphere(cx: Float64, cy: Float64, cz: Float64, radius: Float64, out: ArrayList < Int64 >): Unit
```
球邻域查询

参数: 

|名称|类型|描述|
|---|---|---|
|cx|Float64|查询球中心 Xcy 查询球中心 Ycz 查询球中心 Zradius 查询球半径out 命中元素下标（调用方提供以复用缓冲）|
|cy|Float64||
|cz|Float64||
|radius|Float64||
|out|ArrayList<Int64>||

### prop cellCount: Int64
```cj
public prop cellCount: Int64
```
非空格子数

### prop cellSize: Float64
```cj
public prop cellSize: Float64
```
格子边长

### prop elementCount: Int64
```cj
public prop elementCount: Int64
```
元素总数

