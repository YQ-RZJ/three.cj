# 类
## class Earcut
```cj
public class Earcut
```
Earcut 多边形三角剖分工具类

提供 earcut 算法的静态接口，将一个 2D 多边形（可能含孔洞）
剖分为若干三角形，返回三角形顶点索引数组。

注意：本文件同时包含底层算法实现（earcut/deviation）与
Earcut 封装类（Windows 文件系统大小写不敏感，Earcut.cj 与
earcut.cj 实为同一文件，故合并于此）。

参见：https://github.com/mapbox/earcut

### func triangulate\(Array<Float64>,Array<Int64>,Int64\)
```cj
public static func triangulate(data: Array < Float64 >, holeIndices: Array < Int64 >, dim!: Int64 = 2): Array < UInt32 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<Float64>|平面坐标数组，形如 [x0, y0, x1, y1, ...]|
|holeIndices|Array<Int64>|孔洞起点的索引数组（每个元素表示一个孔洞在 data 中的起始顶点序号）|
|dim|Int64|每个顶点的坐标分量数，默认 2（即 x、y）|

返回: 

- 三角面顶点索引数组，每 3 个连续数字表示一个三角形对给定的 2D 点数组进行三角剖分

