# 类
## class InstancedBufferAttribute
```cj
public class InstancedBufferAttribute <: BufferAttribute
```
实例化缓冲属性，继承自 BufferAttribute

### func copy\(InstancedBufferAttribute\)
```cj
public func copy(source: InstancedBufferAttribute): InstancedBufferAttribute
```
从另一个实例化缓冲属性复制数据到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|InstancedBufferAttribute|源实例化缓冲属性|

返回: 

- 当前实例的引用

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(Array<Float64>,Int64,Bool,Int64\)
```cj
public init(array: Array < Float64 >, itemSize: Int64, normalized!: Bool = false, meshPerAttribute!: Int64 = 1)
```
构造新的实例化缓冲属性

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|存储属性数据的数组itemSize 每个顶点的数据项数量normalized 是否归一化，默认为 falsemeshPerAttribute 每个属性值的重复次数，默认为 1|
|itemSize|Int64||
|normalized|Bool||
|meshPerAttribute|Int64||

### var meshPerAttribute
```cj
public var meshPerAttribute: Int64
```
定义此缓冲区属性值在实例之间重复的次数

