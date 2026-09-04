# Class
## class EventDispatcher
```cj
public open class EventDispatcher
```
Event dispatcher providing addEventListener/removeEventListener/hasEventListener/dispatchEvent event API

### func addEventListener\(String,\(Event\)\->Unit\)
```cj
public func addEventListener(`type`: String, listener:(Event) -> Unit): ListenerHandle
```
Add an event listener

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||
|listener|(Event)->Unit||

Return: 

- Listener handle, for use with removeEventListener/hasEventListener

### func dispatchEvent\(Event\)
```cj
public func dispatchEvent(event: Event): Unit
```
Dispatch an event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|event|Event|Event object to dispatch|

### func emit\(String,Event\)
```cj
public func emit(kind: String, event: Event): Unit
```
Dispatch an event (compatibility method, creates an Event object and calls dispatchEvent)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|kind|String|Event typeevent Event object|
|event|Event||

### func hasEventListener\(String,ListenerHandle\)
```cj
public func hasEventListener(`type`: String, handle: ListenerHandle): Bool
```
Check if a specific type and listener handle are registered

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||
|handle|ListenerHandle||

Return: 

- Returns true if registered

### func hasEventListener\(String\)
```cj
public func hasEventListener(`type`: String): Bool
```
Check if event listeners are registered for the specified type (type-only check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||

Return: 

- Returns true if there are listeners for this type

### func init\(\)
```cj
public init()
```
Constructor

### func off\(String,ListenerHandle\)
```cj
public func off(kind: String, handle: ListenerHandle): Unit
```
Remove an event listener (compatibility method, equivalent to removeEventListener)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|kind|String|Event typehandle Listener handle to remove|
|handle|ListenerHandle||

### func on\(String,\(Event\)\->Unit\)
```cj
public func on(kind: String, listener:(Event) -> Unit): ListenerHandle
```
Add an event listener (compatibility method, equivalent to addEventListener)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|kind|String|Event typelistener Listener function|
|listener|(Event)->Unit||

Return: 

- Listener handle

### func removeEventListener\(String,ListenerHandle\)
```cj
public func removeEventListener(`type`: String, handle: ListenerHandle): Unit
```
Remove an event listener

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||
|handle|ListenerHandle||

### func removeEventListener\(String\)
```cj
public func removeEventListener(`type`: String): Unit
```
Remove all event listeners for the specified type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||

