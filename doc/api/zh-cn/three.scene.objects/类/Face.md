# 类
## class Face
```cj
public class Face
```
相交面信息

### func init\(Int64,Int64,Int64,Vector3,Int64\)
```cj
public init(a!: Int64 = - 1, b!: Int64 = - 1, c!: Int64 = - 1, normal!: Vector3 = Vector3(), materialIndex!: Int64 = 0)
```
构造相交面信息

参数: 

|名称|类型|描述|
|---|---|---|
|a|Int64|第一个顶点索引，默认 -1b 第二个顶点索引，默认 -1c 第三个顶点索引，默认 -1normal 面法向量，默认零向量materialIndex 材质索引，默认 0|
|b|Int64||
|c|Int64||
|normal|Vector3||
|materialIndex|Int64||

### var a
```cj
public var a: Int64
```
相交面第一个顶点索引

### var b
```cj
public var b: Int64
```
相交面第二个顶点索引

### var c
```cj
public var c: Int64
```
相交面第三个顶点索引

### var materialIndex
```cj
public var materialIndex: Int64
```
所属材质索引（多材质几何用）

### var normal
```cj
public var normal: Vector3
```
面法向量

