# 类
## class BitArray
```cj
public class BitArray <: Hashable & Equatable < BitArray >
```
动态二进制位管理器

### func \!=\(BitArray\)
```cj
public operator func !=(other: BitArray): Bool
```
不等比较

参数: 

|名称|类型|描述|
|---|---|---|
|other|BitArray|另一个 BitArray|

返回: 

- true 表示二者不相等

### func ==\(BitArray\)
```cj
public operator func ==(other: BitArray): Bool
```
相等比较

参数: 

|名称|类型|描述|
|---|---|---|
|other|BitArray|另一个 BitArray|

返回: 

- true 表示二者按位相等

### func and\(BitArray\)
```cj
public func and(operand: BitArray): Unit
```
按位与

参数: 

|名称|类型|描述|
|---|---|---|
|operand|BitArray|操作数|

### func assign\(BitArray\)
```cj
public func assign(operand: BitArray): Unit
```
赋值

参数: 

|名称|类型|描述|
|---|---|---|
|operand|BitArray|操作数|

### func clear\(\)
```cj
public func clear(): Unit
```
清理所有位为 0

### func copyInnerData\(\)
```cj
public func copyInnerData(): Array < UInt8 >
```
复制内部数据

返回: 

- 内部数据的副本

### func copy\(\)
```cj
public func copy(): BitArray
```
拷贝副本

返回: 

- 新的 BitArray 副本

### func cover\(BitArray\)
```cj
public func cover(operand: BitArray): Bool
```
是否覆盖所有值为 1 的比特位

参数: 

|名称|类型|描述|
|---|---|---|
|operand|BitArray|操作数|

返回: 

- true 表示覆盖

### func equal\(BitArray\)
```cj
public func equal(operand: BitArray): Bool
```
是否相等

参数: 

|名称|类型|描述|
|---|---|---|
|operand|BitArray|操作数|

返回: 

- true 表示按位相等

### func get\(Int64\)
```cj
public func get(index: Int64): Bool
```
获取指定位置上的 bit 值

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|比特索引|

返回: 

- true 表示该位为 1

### func hashCode\(\)
```cj
public func hashCode(): Int64
```
计算 Hash 值

返回: 

- 32 位无符号整数哈希值（用 Int64 容纳）

### func init\(Int64,Bool\)
```cj
public init(index: Int64, value!: Bool = true)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|初始比特索引（自动扩容到该索引+1）value 是否将指定位置 1（默认 true）|
|value|Bool||

### func not\(\)
```cj
public func not(): Unit
```
按位取反

### func or\(BitArray\)
```cj
public func or(operand: BitArray): Unit
```
按位或

参数: 

|名称|类型|描述|
|---|---|---|
|operand|BitArray|操作数|

### func setIdxs\(Array<Int64>,Bool\)
```cj
public func setIdxs(indexs: Array < Int64 >, value!: Bool = true): Unit
```
批量设置指定位置上的 bit 值

参数: 

|名称|类型|描述|
|---|---|---|
|indexs|Array<Int64>|比特索引数组value true 置 1，false 清 0|
|value|Bool||

### func set\(Int64,Bool\)
```cj
public func set(index: Int64, value!: Bool = true): Unit
```
设置指定位置上的 bit 值

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|比特索引value true 置 1，false 清 0|
|value|Bool||

### func toArray\(\)
```cj
public func toArray(): Array < UInt8 >
```
导出为字节数组

返回: 

- 字节数组副本

### func toBinaryString\(\)
```cj
public func toBinaryString(): String
```
转为二进制字符串输出

返回: 

- 二进制字符串

### prop innerData: Array < UInt8 >
```cj
public prop innerData: Array < UInt8 >
```
直接公开内部数据

### prop length: Int64
```cj
public prop length: Int64
```
获取比特长度

