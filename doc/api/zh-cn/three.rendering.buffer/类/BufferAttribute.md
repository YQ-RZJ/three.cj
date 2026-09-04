# 类
## class BufferAttribute
```cj
public open class BufferAttribute <: AttributeReader
```
缓冲区属性类，存储顶点属性数据

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

### func applyMatrix3\(Matrix3\)
```cj
public func applyMatrix3(m: Matrix3): BufferAttribute
```
将给定的 3x3 矩阵应用到当前属性，仅适用于 itemSize 为 2 或 3 的情况

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|要应用的 3x3 矩阵|

返回: 

- 当前实例的引用

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): BufferAttribute
```
将给定的 4x4 矩阵应用到当前属性，仅适用于 itemSize 为 3 的情况

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|要应用的 4x4 矩阵|

返回: 

- 当前实例的引用

### func applyNormalMatrix\(Matrix3\)
```cj
public func applyNormalMatrix(m: Matrix3): BufferAttribute
```
将给定的 3x3 法线矩阵应用到当前属性，仅适用于 itemSize 为 3 的情况

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|要应用的 3x3 法线矩阵|

返回: 

- 当前实例的引用

### func clearUpdateRanges\(\)
```cj
public func clearUpdateRanges(): Unit
```
清除所有更新范围

### func clone\(\)
```cj
public func clone(): BufferAttribute
```
创建此缓冲区属性的副本

返回: 

- 新的 BufferAttribute 实例

### func copyArray\(Array<Float64>\)
```cj
public func copyArray(arr: Array < Float64 >): BufferAttribute
```
将给定数组数据复制到此缓冲区属性

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<Float64>|要复制的数组|

返回: 

- 当前实例的引用

### func copyAt\(Int64,BufferAttribute,Int64\)
```cj
public func copyAt(index1: Int64, attribute: BufferAttribute, index2: Int64): BufferAttribute
```
从另一个缓冲区属性复制一个向量到当前属性

参数: 

|名称|类型|描述|
|---|---|---|
|index1|Int64|当前属性中的目标索引attribute 源缓冲区属性index2 源属性中的源索引|
|attribute|BufferAttribute||
|index2|Int64||

返回: 

- 当前实例的引用

### func copy\(BufferAttribute\)
```cj
public func copy(source: BufferAttribute): BufferAttribute
```
从另一个缓冲区属性复制数据到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|BufferAttribute|源缓冲区属性|

返回: 

- 当前实例的引用

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放此缓冲区属性占用的资源

### func getArrayType\(\)
```cj
public open func getArrayType(): String
```
返回本属性在 JSON 序列化时对应的 JS TypedArray 名

返回: 

- JS TypedArray 子类名，如 `"Float32Array"`、`"Uint16Array"`

### func getComponent\(Int64,Int64\)
```cj
public func getComponent(index: Int64, component: Int64): Float64
```
返回指定索引处向量的指定分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引component 分量索引|
|component|Int64||

返回: 

- 该分量的值

### func getW\(Int64\)
```cj
public func getW(index: Int64): Float64
```
返回指定索引处向量的 w 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引|

返回: 

- w 分量的值

### func getX\(Int64\)
```cj
public func getX(index: Int64): Float64
```
返回指定索引处向量的 x 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引|

返回: 

- x 分量的值

### func getY\(Int64\)
```cj
public func getY(index: Int64): Float64
```
返回指定索引处向量的 y 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引|

返回: 

- y 分量的值

### func getZ\(Int64\)
```cj
public func getZ(index: Int64): Float64
```
返回指定索引处向量的 z 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引|

返回: 

- z 分量的值

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(Array<Float64>,Int64,Bool\)
```cj
public init(array: Array < Float64 >, itemSize: Int64, normalized!: Bool = false)
```
构造一个新的缓冲区属性

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|存储属性数据的数组itemSize 每个顶点的数据项数量normalized 是否归一化，默认为 false|
|itemSize|Int64||
|normalized|Bool||

### func markNeedsUpdate\(\)
```cj
public func markNeedsUpdate(): Unit
```
标记属性需要更新到 GPU

### func onUpload\(\(\)\->Unit\)
```cj
public func onUpload(callback:() -> Unit): BufferAttribute
```


参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|回调函数|

返回: 

- 当前实例的引用设置上传回调函数在渲染器将数组数据传输到 GPU 后执行，可用于在上传后执行清理操作（当 CPU 端不再需要数据时）。

### func setComponent\(Int64,Int64,Float64\)
```cj
public func setComponent(index: Int64, component: Int64, value: Float64): BufferAttribute
```
设置指定索引处向量指定分量的值

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引component 分量索引value 要设置的值|
|component|Int64||
|value|Float64||

返回: 

- 当前实例的引用

### func setUsage\(Int64\)
```cj
public func setUsage(value: Int64): BufferAttribute
```
设置此缓冲区属性的使用模式

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|使用模式（如 StaticDrawUsage、DynamicDrawUsage 等）|

返回: 

- 当前实例的引用

### func setW\(Int64,Float64\)
```cj
public func setW(index: Int64, w: Float64): BufferAttribute
```
设置指定索引处向量的 w 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引w 要设置的 w 值|
|w|Float64||

返回: 

- 当前实例的引用

### func setXYZW\(Int64,Float64,Float64,Float64,Float64\)
```cj
public func setXYZW(index: Int64, x: Float64, y: Float64, z: Float64, w: Float64): BufferAttribute
```
设置指定索引处向量的 x、y、z、w 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引x x 分量的值y y 分量的值z z 分量的值w w 分量的值|
|x|Float64||
|y|Float64||
|z|Float64||
|w|Float64||

返回: 

- 当前实例的引用

### func setXYZ\(Int64,Float64,Float64,Float64\)
```cj
public func setXYZ(index: Int64, x: Float64, y: Float64, z: Float64): BufferAttribute
```
设置指定索引处向量的 x、y、z 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引x x 分量的值y y 分量的值z z 分量的值|
|x|Float64||
|y|Float64||
|z|Float64||

返回: 

- 当前实例的引用

### func setXY\(Int64,Float64,Float64\)
```cj
public func setXY(index: Int64, x: Float64, y: Float64): BufferAttribute
```
设置指定索引处向量的 x 和 y 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引x x 分量的值y y 分量的值|
|x|Float64||
|y|Float64||

返回: 

- 当前实例的引用

### func setX\(Int64,Float64\)
```cj
public func setX(index: Int64, x: Float64): BufferAttribute
```
设置指定索引处向量的 x 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引x 要设置的 x 值|
|x|Float64||

返回: 

- 当前实例的引用

### func setY\(Int64,Float64\)
```cj
public func setY(index: Int64, y: Float64): BufferAttribute
```
设置指定索引处向量的 y 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引y 要设置的 y 值|
|y|Float64||

返回: 

- 当前实例的引用

### func setZ\(Int64,Float64\)
```cj
public func setZ(index: Int64, z: Float64): BufferAttribute
```
设置指定索引处向量的 z 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引z 要设置的 z 值|
|z|Float64||

返回: 

- 当前实例的引用

### func set\(Array<Float64>,Int64\)
```cj
public func set(value: Array < Float64 >, offset!: Int64 = 0): BufferAttribute
```
设置缓冲区属性中的数组数据

参数: 

|名称|类型|描述|
|---|---|---|
|value|Array<Float64>|要设置的数据数组offset 偏移量，默认为 0|
|offset|Int64||

返回: 

- 当前实例的引用

### func transformDirection\(Matrix4\)
```cj
public func transformDirection(m: Matrix4): BufferAttribute
```
将给定的 4x4 矩阵应用到当前属性（仅适用于方向向量），仅适用于 itemSize 为 3 的情况

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|要应用的 4x4 矩阵|

返回: 

- 当前实例的引用

### prop count: Int64
```cj
public mut prop count: Int64
```


### var array
```cj
public var array: Array < Float64 >
```
数据数组，存储顶点属性数据，应有 itemSize * count 个元素

### var gpuType
```cj
public var gpuType: Int64
```
配置在着色器中使用的 GPU 数据类型

### var itemSize
```cj
public var itemSize: Int64
```
数据分组大小：每个顶点关联的数组元素数量

### var kind
```cj
public var kind: String
```
类型字符串，用于多态判断

### var name
```cj
public var name: String
```
属性名称

### var normalized
```cj
public var normalized: Bool
```
是否对整数数据进行归一化

### var onUploadCallback
```cj
public var onUploadCallback:() -> Unit
```
上传回调，在渲染器将数据传输到 GPU 后执行

### var updateRanges
```cj
public var updateRanges: ArrayList <(Int64, Int64) >
```
更新范围列表，用于只更新存储向量的部分组件

### var usage
```cj
public var usage: Int64
```
数据存储的预期使用模式，用于 GPU 优化

### var version
```cj
public var version: Int64
```
版本号，每次 needsUpdate 设为 true 时递增

