# 类
## class PoolManager
```cj
public class PoolManager
```
多类型对象池管理

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>各类型对象池的最大缓存容量在构造时统一指定。</p>

### func clear\(\)
```cj
public func clear(): Unit
```
清理所有缓存

### func get\(Int64\)
```cj
public func get(id: Int64): Object
```
尝试从池里获取指定对象实例

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象类型 ID|

返回: 

- 新建或复用的对象

异常: 

- IllegalStateException 当该 ID 未注册时

### func init\(\)
```cj
public init()
```
构造管理器（默认容量 128）

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
构造管理器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|各类型对象池最大缓存容量|

### func isRegister\(Int64\)
```cj
public func isRegister(id: Int64): Bool
```
是否注册了指定类型

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象类型 ID|

返回: 

- 已注册返回 true，否则返回 false

### func recycle\(Int64,Object\)
```cj
public func recycle(id: Int64, obj: Object): Unit
```
回收对象

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象类型 IDobj 待回收对象|
|obj|Object||

异常: 

- IllegalStateException 当该 ID 未注册时

### func register\(Int64,\(\)\->Object\)
```cj
public func register(id: Int64, factory:() -> Object): Unit
```
注册指定 ID 的对象池

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象类型 IDfactory 对象工厂|
|factory|()->Object||

异常: 

- IllegalStateException 当该 ID 已注册时

### func register\(Int64,\(\)\->Object,?\(Object\)\->Unit,?\(Object\)\->Unit\)
```cj
public func register(id: Int64, factory:() -> Object, onRecycle:?(Object) -> Unit, onReuse:?(Object) -> Unit): Unit
```
注册带回调的对象池

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象类型 IDfactory 对象工厂onRecycle 回收回调onReuse 复用回调|
|factory|()->Object||
|onRecycle|?(Object)->Unit||
|onReuse|?(Object)->Unit||

异常: 

- IllegalStateException 当该 ID 已注册时

### func unregister\(Int64\)
```cj
public func unregister(id: Int64): Unit
```
注销指定类型

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象类型 ID|

