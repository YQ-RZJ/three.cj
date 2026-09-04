# 类
## class AutoFreePtr < T > where T <: CType
```cj
public class AutoFreePtr < T > where T <: CType
```
自动释放指针包装

### func dispose\(\)
```cj
public func dispose(): Unit
```
自动调用 LibC.free 释放指针

### func get\(\)
```cj
public func get(): CPointer < T >
```
获取原始指针

返回: 

- CPointer<T>

### func init\(\)
```cj
public init()
```
构造空 AutoFreePtr

### func init\(CPointer<T>\)
```cj
public init(p: CPointer < T >)
```
构造 AutoFreePtr 包装一个指针

参数: 

|名称|类型|描述|
|---|---|---|
|p|CPointer<T>|要管理的指针|

### func isValid\(\)
```cj
public func isValid(): Bool
```
检查是否持有有效指针

返回: 

- true 表示非空

### func release\(\)
```cj
public func release(): CPointer < T >
```
释放所有权，返回原始指针（不再管理）

返回: 

- 原始 CPointer<T>

