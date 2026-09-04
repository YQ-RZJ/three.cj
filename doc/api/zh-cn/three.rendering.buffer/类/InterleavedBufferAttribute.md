# 类
## class InterleavedBufferAttribute
```cj
public class InterleavedBufferAttribute
```
交错缓冲区属性

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(m: Matrix4): InterleavedBufferAttribute
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
public func applyNormalMatrix(m: Matrix3): InterleavedBufferAttribute
```
将给定的 3x3 法线矩阵应用到当前属性，仅适用于 itemSize 为 3 的情况

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix3|要应用的 3x3 法线矩阵|

返回: 

- 当前实例的引用

### func array\(\)
```cj
public func array(): Array < Float64 >
```
获取持有交错数据的数组

返回: 

- 底层数据数组

### func clone\(\)
```cj
public func clone(): InterleavedBufferAttribute
```
克隆当前交错缓冲区属性

返回: 

- 新的 InterleavedBufferAttribute 实例

### func count\(\)
```cj
public func count(): Int64
```
此缓冲区属性的数据项数量

返回: 

- 数据项数量

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

### func init\(InterleavedBuffer,Int64,Int64\)
```cj
public init(interleavedBuffer: InterleavedBuffer, itemSize: Int64, offset: Int64)
```
兼容重载：3 参数形式（normalized 默认 false）

参数: 

|名称|类型|描述|
|---|---|---|
|interleavedBuffer|InterleavedBuffer|持有交错数据的缓冲区itemSize 数据项大小offset 属性在缓冲区中的偏移量|
|itemSize|Int64||
|offset|Int64||

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### func init\(InterleavedBuffer,Int64,Int64,Bool\)
```cj
public init(interleavedBuffer: InterleavedBuffer, itemSize: Int64, offset: Int64, normalized!: Bool = false)
```
构造一个新的交错缓冲区属性

参数: 

|名称|类型|描述|
|---|---|---|
|interleavedBuffer|InterleavedBuffer|持有交错数据的缓冲区itemSize 数据项大小offset 属性在缓冲区中的偏移量normalized 是否归一化，默认为 false|
|itemSize|Int64||
|offset|Int64||
|normalized|Bool||

### func setComponent\(Int64,Int64,Float64\)
```cj
public func setComponent(index: Int64, component: Int64, value: Float64): InterleavedBufferAttribute
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

### func setNeedsUpdate\(Bool\)
```cj
public func setNeedsUpdate(value: Bool): Unit
```
标记属性需要更新到 GPU

参数: 

|名称|类型|描述|
|---|---|---|
|value|Bool|是否需要更新|

### func setW\(Int64,Float64\)
```cj
public func setW(index: Int64, w: Float64): InterleavedBufferAttribute
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
public func setXYZW(index: Int64, x: Float64, y: Float64, z: Float64, w: Float64): InterleavedBufferAttribute
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
public func setXYZ(index: Int64, x: Float64, y: Float64, z: Float64): InterleavedBufferAttribute
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
public func setXY(index: Int64, x: Float64, y: Float64): InterleavedBufferAttribute
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
public func setX(index: Int64, x: Float64): InterleavedBufferAttribute
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
public func setY(index: Int64, y: Float64): InterleavedBufferAttribute
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
public func setZ(index: Int64, z: Float64): InterleavedBufferAttribute
```
设置指定索引处向量的 z 分量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|缓冲区属性中的索引z 要设置的 z 值|
|z|Float64||

返回: 

- 当前实例的引用

### func transformDirection\(Matrix4\)
```cj
public func transformDirection(m: Matrix4): InterleavedBufferAttribute
```
将给定的 4x4 矩阵应用到当前属性（仅适用于方向向量），仅适用于 itemSize 为 3 的情况

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|要应用的 4x4 矩阵|

返回: 

- 当前实例的引用

### var data
```cj
public var data: InterleavedBuffer
```
持有交错数据的缓冲区

### var itemSize
```cj
public var itemSize: Int64
```
数据项大小，参见 BufferAttribute.itemSize

### var name
```cj
public var name: String
```
缓冲区属性名称

### var normalized
```cj
public var normalized: Bool
```
是否对整数数据进行归一化，参见 BufferAttribute.normalized

### var offset
```cj
public var offset: Int64
```
属性在缓冲区中的偏移量

