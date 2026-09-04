# 类
## class PtrArray < T > where T <: CType
```cj
public class PtrArray < T > where T <: CType
```
指针底层数组

### func data\(\)
```cj
public func data(): CPointer < T >
```
获取底层连续内存指针（供 bgfx FFI 使用；调用方不接管所有权）

返回: 

- CPointer<T>

### func dispose\(\)
```cj
public func dispose(): Unit
```
手动释放底层内存（GC 回收时也会自动释放，此方法用于及时回收）

### func get\(Int64\)
```cj
public func get(index: Int64): T
```
读取指定下标元素

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|下标|

返回: 

- 元素值

### func init\(Int64\)
```cj
public init(size: Int64)
```
构造指定长度的空数组（内存清零）

参数: 

|名称|类型|描述|
|---|---|---|
|size|Int64|元素个数|

### func init\(Array<T>\)
```cj
public init(values: Array < T >)
```
从仓颉 Array 拷贝构造（一次性把数据上传到连续内存）

参数: 

|名称|类型|描述|
|---|---|---|
|values|Array<T>|源数据|

### func set\(Int64,T\)
```cj
public func set(index: Int64, value: T): Unit
```
写入指定下标元素

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|下标value 元素值|
|value|T||

### func size\(\)
```cj
public func size(): Int64
```
元素个数

返回: 

- 元素个数

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
把 C 内存数据读回仓颉 Array

返回: 

- 拷贝出的 Array<T>

