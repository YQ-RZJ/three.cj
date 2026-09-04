# 类
## class UniquePtr < T > where T <: CType
```cj
public class UniquePtr < T > where T <: CType
```
独占所有权智能指针

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放管理的指针（手动调用，~init 作为兜底）

### func get\(\)
```cj
public func get(): CPointer < T >
```
获取原始指针（不转移所有权）

返回: 

- 原始 CPointer<T>

### func init\(\)
```cj
public init()
```
构造一个空 UniquePtr

### func init\(CPointer<T>\)
```cj
public init(p: CPointer < T >)
```
构造 UniquePtr 包装一个指针（使用默认 LibC.free 释放）

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|要管理的指针|

### func init\(CPointer<T>,\(CPointer<T>\)\->Unit\)
```cj
public init(p: CPointer < T >, deleter:(CPointer < T >) -> Unit)
```
构造 UniquePtr 包装一个指针（使用自定义释放函数）

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|要管理的指针deleter 自定义释放函数|
|deleter|(CPointer<T>)->Unit||

### func isValid\(\)
```cj
public func isValid(): Bool
```
检查是否持有有效指针

返回: 

- true 表示持有有效指针

### func move\(\)
```cj
public func move(): UniquePtr < T >
```
转移所有权到新的 UniquePtr

返回: 

- 新的 UniquePtr 持有原所有权

### func release\(\)
```cj
public func release(): CPointer < T >
```
释放所有权，返回原始指针（不再管理其生命周期）

返回: 

- 原始 CPointer<T>

### func reset\(CPointer<T>\)
```cj
public func reset(p: CPointer < T >): Unit
```
重置为管理新的指针（旧指针会被释放）

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

