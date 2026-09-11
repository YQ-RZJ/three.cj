# 类
## class ObjectPool < T > where T <: Object
```cj
public class ObjectPool < T > where T <: Object
```
通用对象池

### func allocate\(\)
```cj
public func allocate(): T
```
获取对象（池空则调用工厂新建）

返回: 

- 新建或复用的对象

### func clear\(\)
```cj
public func clear(): Unit
```
清理缓存

### func init\(Int64,\(\)\->T\)
```cj
public init(capacity: Int64, factory:() -> T)
```
构造对象池（不带回调）

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|最大缓存容量（<= 0 表示不限制）factory 对象工厂，返回新创建的实例|
|factory|()->T||

### func init\(Int64,\(\)\->T,?\(T\)\->Unit,?\(T\)\->Unit\)
```cj
public init(capacity: Int64, factory:() -> T, onRecycle:?(T) -> Unit, onReuse:?(T) -> Unit)
```
构造对象池（带回收/复用回调）

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|最大缓存容量（<= 0 表示不限制）factory 对象工厂，返回新创建的实例onRecycle 回收时回调（可选，用于重置状态）onReuse 复用时回调（可选，用于初始化状态）|
|factory|()->T||
|onRecycle|?(T)->Unit||
|onReuse|?(T)->Unit||

### func recycle\(T\)
```cj
public func recycle(obj: T): Bool
```
回收对象

参数: 

|名称|类型|描述|
|---|---|---|
|obj|T|待回收对象|

返回: 

- 是否回收成功（容量已满返回 false）

### func size\(\)
```cj
public func size(): Int64
```
当前池内缓存数量

返回: 

- 缓存数量

