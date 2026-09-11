# Class
## class EventManager
```cj
public class EventManager
```
Event manager (global event bus)

### func addEventOnce\(String,\(Array<Object>\)\->Unit,?Object\)
```cj
public func addEventOnce(name: String, callback:(Array < Object >) -> Unit, target!:?Object = None): EventRecord
```
Add a one-time event listener

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Event namecallback Callback functiontarget Target object, None means no target binding|
|callback|(Array<Object>)->Unit||
|target|?Object||

Return: 

- EventRecord handle

### func addEvent\(String,\(Array<Object>\)\->Unit,?Object\)
```cj
public func addEvent(name: String, callback:(Array < Object >) -> Unit, target!:?Object = None): EventRecord
```
Add an event listener

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Event namecallback Callback function, parameter array passed in by sendtarget Target object (for send filtering), None means no target binding|
|callback|(Array<Object>)->Unit||
|target|?Object||

Return: 

- EventRecord handle, for precise removal

### func clear\(\)
```cj
public func clear(): Unit
```
Clear all listeners

### func countByName\(String\)
```cj
public func countByName(name: String): Int64
```
Number of listeners for the specified name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Event name|

Return: 

- Number of listeners under this name; returns 0 if not found

### func init\(\)
```cj
public init()
```
Default constructor, uses default object pool capacity

### func init\(Int64\)
```cj
public init(poolCapacity: Int64)
```
Constructor with initial object pool capacity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|poolCapacity|Int64|Object pool warm-up capacity; warming up before hot-path calls reduces first allocation overhead|

### func removeByNameAndTarget\(String,Object\)
```cj
public func removeByNameAndTarget(name: String, target: Object): Unit
```
Remove all matching listeners by name and target object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Event nametarget Target object (reference equality matching)|
|target|Object||

### func removeList\(Object\)
```cj
public func removeList(target: Object): Unit
```
Remove all listeners associated with the specified target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Object|Target object (reference equality matching)|

### func remove\(EventRecord\)
```cj
public func remove(listener: EventRecord): Unit
```
Precisely remove by EventRecord handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|EventRecord|Handle returned by addEvent/addEventOnce|

### func send\(String,Array<Object>,?Object\)
```cj
public func send(name: String, data!: Array < Object >= Array < Object >(), target!:?Object = None): Unit
```
Dispatch an event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Event namedata Parameter array passed to callbacks, default empty arraytarget Target object filter, None means no filtering|
|data|Array<Object>||
|target|?Object||

### prop listenerCount: Int64
```cj
public prop listenerCount: Int64
```
Number of currently registered listeners

