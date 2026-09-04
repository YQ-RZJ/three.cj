# 类
## class EventDispatcher
```cj
public open class EventDispatcher
```
事件分发器，提供 addEventListener/removeEventListener/hasEventListener/dispatchEvent 事件 API

### func addEventListener\(String,\(Event\)\->Unit\)
```cj
public func addEventListener(`type`: String, listener:(Event) -> Unit): ListenerHandle
```
添加事件监听器

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||
|listener|(Event)->Unit||

返回: 

- 监听器句柄，用于 removeEventListener/hasEventListener

### func dispatchEvent\(Event\)
```cj
public func dispatchEvent(event: Event): Unit
```
分发事件

参数: 

|名称|类型|描述|
|---|---|---|
|event|Event|要分发的事件对象|

### func emit\(String,Event\)
```cj
public func emit(kind: String, event: Event): Unit
```
分发事件（兼容方法，创建 Event 对象并调用 dispatchEvent）

参数: 

|名称|类型|描述|
|---|---|---|
|kind|String|事件类型event 事件对象|
|event|Event||

### func hasEventListener\(String,ListenerHandle\)
```cj
public func hasEventListener(`type`: String, handle: ListenerHandle): Bool
```
检查是否已注册指定类型和监听器句柄

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||
|handle|ListenerHandle||

返回: 

- 如果已注册则返回 true

### func hasEventListener\(String\)
```cj
public func hasEventListener(`type`: String): Bool
```
检查是否已注册指定类型的事件监听器（仅检查类型）

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||

返回: 

- 如果该类型有监听器则返回 true

### func init\(\)
```cj
public init()
```
构造器

### func off\(String,ListenerHandle\)
```cj
public func off(kind: String, handle: ListenerHandle): Unit
```
移除事件监听器（兼容方法，等同于 removeEventListener）

参数: 

|名称|类型|描述|
|---|---|---|
|kind|String|事件类型handle 要移除的监听器句柄|
|handle|ListenerHandle||

### func on\(String,\(Event\)\->Unit\)
```cj
public func on(kind: String, listener:(Event) -> Unit): ListenerHandle
```
添加事件监听器（兼容方法，等同于 addEventListener）

参数: 

|名称|类型|描述|
|---|---|---|
|kind|String|事件类型listener 监听器函数|
|listener|(Event)->Unit||

返回: 

- 监听器句柄

### func removeEventListener\(String,ListenerHandle\)
```cj
public func removeEventListener(`type`: String, handle: ListenerHandle): Unit
```
移除事件监听器

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||
|handle|ListenerHandle||

### func removeEventListener\(String\)
```cj
public func removeEventListener(`type`: String): Unit
```
移除指定类型的所有事件监听器

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||

