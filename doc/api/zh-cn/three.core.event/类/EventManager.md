# 类
## class EventManager
```cj
public class EventManager
```
事件管理器（全局事件总线）

### func addEventOnce\(String,\(Array<Object>\)\->Unit,?Object\)
```cj
public func addEventOnce(name: String, callback:(Array < Object >) -> Unit, target!:?Object = None): EventRecord
```
添加一次性事件监听器

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|事件名称callback 回调函数target 目标对象，None 表示不绑定目标|
|callback|(Array<Object>)->Unit||
|target|?Object||

返回: 

- EventRecord 句柄

### func addEvent\(String,\(Array<Object>\)\->Unit,?Object\)
```cj
public func addEvent(name: String, callback:(Array < Object >) -> Unit, target!:?Object = None): EventRecord
```
添加事件监听器

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|事件名称callback 回调函数，参数数组由 send 时传入target 目标对象（用于 send 时过滤），None 表示不绑定目标|
|callback|(Array<Object>)->Unit||
|target|?Object||

返回: 

- EventRecord 句柄，用于精确 remove

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有监听器

### func countByName\(String\)
```cj
public func countByName(name: String): Int64
```
指定名称的监听器数量

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|事件名称|

返回: 

- 该名称下的监听器数量；不存在时返回 0

### func init\(\)
```cj
public init()
```
默认构造器，使用默认对象池容量

### func init\(Int64\)
```cj
public init(poolCapacity: Int64)
```
指定对象池初始容量的构造器

参数: 

|名称|类型|描述|
|---|---|---|
|poolCapacity|Int64|对象池预热容量，热路径调用前预热可减少首次分配开销|

### func removeByNameAndTarget\(String,Object\)
```cj
public func removeByNameAndTarget(name: String, target: Object): Unit
```
按名称与目标对象移除所有匹配的监听器

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|事件名称target 目标对象（引用相等匹配）|
|target|Object||

### func removeList\(Object\)
```cj
public func removeList(target: Object): Unit
```
移除与指定目标关联的所有监听器

参数: 

|名称|类型|描述|
|---|---|---|
|target|Object|目标对象（引用相等匹配）|

### func remove\(EventRecord\)
```cj
public func remove(listener: EventRecord): Unit
```
按 EventRecord 句柄精确移除

参数: 

|名称|类型|描述|
|---|---|---|
|listener|EventRecord|addEvent/addEventOnce 返回的句柄|

### func send\(String,Array<Object>,?Object\)
```cj
public func send(name: String, data!: Array < Object >= Array < Object >(), target!:?Object = None): Unit
```
分发事件

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|事件名称data 传递给回调的参数数组，默认空数组target 目标对象过滤，None 表示不过滤|
|data|Array<Object>||
|target|?Object||

### prop listenerCount: Int64
```cj
public prop listenerCount: Int64
```
当前注册的监听器数量

