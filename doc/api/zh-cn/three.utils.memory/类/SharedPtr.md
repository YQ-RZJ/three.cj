# 类
## class SharedPtr < T > where T <: CType
```cj
public class SharedPtr < T > where T <: CType
```
引用计数共享智能指针

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放当前引用（手动调用，~init 作为兜底）

### func get\(\)
```cj
public func get(): CPointer < T >
```
获取原始指针（不增加引用计数）

返回: 

- 原始 CPointer<T>

### func init\(\)
```cj
public init()
```
构造一个空 SharedPtr

### func init\(CPointer<T>\)
```cj
public init(p: CPointer < T >)
```
构造 SharedPtr 包装一个指针（使用默认 LibC.free 释放）

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|要管理的指针|

### func init\(CPointer<T>,\(CPointer<T>\)\->Unit\)
```cj
public init(p: CPointer < T >, deleter:(CPointer < T >) -> Unit)
```
构造 SharedPtr 包装一个指针（使用自定义释放函数）

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|要管理的指针deleter 自定义释放函数|
|deleter|(CPointer<T>)->Unit||

### func init\(SharedPtr<T>\)
```cj
public init(other: SharedPtr < T >)
```
复制构造：共享所有权，引用计数 +1（线程安全）

参数: 

|名称|类型|描述|
|---|---|---|
|other|SharedPtr<T>|源 SharedPtr|

### func isValid\(\)
```cj
public func isValid(): Bool
```
检查是否持有有效指针

返回: 

- true 表示持有有效指针

### func reset\(CPointer<T>\)
```cj
public func reset(p: CPointer < T >): Unit
```
重置为管理新的指针（旧指针引用计数 -1）

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|新指针|

### func reset\(CPointer<T>,\(CPointer<T>\)\->Unit\)
```cj
public func reset(p: CPointer < T >, deleter:(CPointer < T >) -> Unit): Unit
```
重置为管理新的指针，使用自定义释放函数

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|新指针deleter 新释放函数|
|deleter|(CPointer<T>)->Unit||

### func useCount\(\)
```cj
public func useCount(): Int64
```
获取当前引用计数（线程安全）

返回: 

- 引用计数

