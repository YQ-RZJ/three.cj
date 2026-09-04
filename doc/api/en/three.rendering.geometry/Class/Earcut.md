# Class
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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<Float64>|Flat coordinate array, e.g. [x0, y0, x1, y1, ...]|
|holeIndices|Array<Int64>|Index array of hole starting points (each element indicates the starting vertex index of a hole in data)|
|dim|Int64|Number of coordinate components per vertex, default 2 (i.e. x, y)|

Return: 

- Array of triangle vertex indices, every 3 consecutive numbers represent a triangleTriangulate the given 2D point array

