# 类
## class InterleavedBuffer
```cj
public open class InterleavedBuffer
```
交错缓冲区类，将多个属性数据打包到单个数组中

### func addUpdateRange\(Int64,Int64\)
```cj
public func addUpdateRange(start: Int64, count: Int64): Unit
```
添加需要更新到 GPU 的数据范围

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int64|起始位置count 要更新的组件数量|
|count|Int64||

### func clearUpdateRanges\(\)
```cj
public func clearUpdateRanges(): Unit
```
清除所有更新范围

### func clone\(\)
```cj
public open func clone(): InterleavedBuffer
```
克隆当前交错缓冲区

返回: 

- 新的交错缓冲区实例

### func copyAt\(Int64,InterleavedBuffer,Int64\)
```cj
public func copyAt(index1: Int64, interleavedBuffer: InterleavedBuffer, index2: Int64): InterleavedBuffer
```
从另一个交错缓冲区复制一个向量到当前缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|index1|Int64|当前缓冲区中的目标索引interleavedBuffer 源交错缓冲区index2 源缓冲区中的源索引|
|interleavedBuffer|InterleavedBuffer||
|index2|Int64||

返回: 

- 当前实例

### func copy\(InterleavedBuffer\)
```cj
public func copy(source: InterleavedBuffer): InterleavedBuffer
```
从另一个交错缓冲区复制数据到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|InterleavedBuffer|源交错缓冲区|

返回: 

- 当前实例

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(Array<Float64>,Int64\)
```cj
public init(array: Array < Float64 >, stride: Int64)
```
构造交错缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|存储属性数据的数组stride 每个顶点的元素数量|
|stride|Int64||

### func markNeedsUpdate\(\)
```cj
public func markNeedsUpdate(): Unit
```
标记数据需要更新到 GPU

### func onUpload\(\(\)\->Unit\)
```cj
public func onUpload(callback:() -> Unit): InterleavedBuffer
```
设置上传回调函数

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|回调函数|

返回: 

- 当前实例

### func setUsage\(Int64\)
```cj
public func setUsage(value: Int64): InterleavedBuffer
```
设置此交错缓冲区的使用模式

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|使用模式（如 StaticDrawUsage, DynamicDrawUsage 等）|

返回: 

- 当前实例

### func set\(Array<Float64>,Int64\)
```cj
public func set(value: Array < Float64 >, offset!: Int64 = 0): InterleavedBuffer
```
设置交错缓冲区中的数组数据

参数: 

|名称|类型|描述|
|---|---|---|
|value|Array<Float64>|要设置的数据数组offset 偏移量，默认为 0|
|offset|Int64||

返回: 

- 当前实例

### var array
```cj
public var array: Array < Float64 >
```
存储属性数据的数组

### var count
```cj
public var count: Int64
```
数组中的元素总数

### var onUploadCallback
```cj
public var onUploadCallback:() -> Unit
```
上传回调函数，在渲染器将属性数组数据传输到 GPU 后执行（函数类型，不支持序列化）

### var stride
```cj
public var stride: Int64
```
每个顶点的类型化数组元素数量（步长）

### var updateRanges
```cj
public var updateRanges: ArrayList < UpdateRange >
```
更新范围列表，用于只更新存储向量的部分组件

### var usage
```cj
public var usage: Int64
```
数据存储的预期使用模式，用于优化目的

### let uuid
```cj
public let uuid: String
```
此交错缓冲区的唯一标识符（let 不可变，不参与序列化）

### var version
```cj
public var version: Int64
```
版本号，每次 needsUpdate 设为 true 时递增

