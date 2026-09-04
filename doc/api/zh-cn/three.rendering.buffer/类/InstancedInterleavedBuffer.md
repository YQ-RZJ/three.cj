# 类
## class InstancedInterleavedBuffer
```cj
public class InstancedInterleavedBuffer <: InterleavedBuffer
```
实例化交错缓冲区类，继承自 InterleavedBuffer

### func clone\(\)
```cj
public func clone(): InstancedInterleavedBuffer
```
克隆当前实例化交错缓冲区

返回: 

- 新的实例化交错缓冲区实例

### func copy\(InstancedInterleavedBuffer\)
```cj
public func copy(source: InstancedInterleavedBuffer): InstancedInterleavedBuffer
```


参数: 

|名称|类型|描述|
|---|---|---|
|source|InstancedInterleavedBuffer|源交错缓冲区|

返回: 

- 当前实例从另一个实例化交错缓冲区复制数据到当前实例

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(Array<Float64>,Int64,Int64\)
```cj
public init(array: Array < Float64 >, stride: Int64, meshPerAttribute!: Int64 = 1)
```
构造实例化交错缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|存储属性数据的数组stride 每个顶点的元素数量meshPerAttribute 每个属性值的重复次数，默认为 1|
|stride|Int64||
|meshPerAttribute|Int64||

### var meshPerAttribute
```cj
public var meshPerAttribute: Int64
```
定义此缓冲区属性值在每个实例间重复的次数，默认为 1

