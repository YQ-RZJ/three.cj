# Class
## class LuaDeferredCallbackQueue
```cj
public class LuaDeferredCallbackQueue
```
Cross-thread Lua callback queue

### func clear\(\)
```cj
public func clear(): Int64
```
Clears the queue (Lua thread): releases every callback without executing it

Return: 

- The number of discarded callbacks

### func drain\(\)
```cj
public func drain(): Int64
```
Executes all pending callbacks on the Lua thread

Return: 

- The number of callbacks that completed successfully (failing ones excluded)

### func init\(\)
```cj
public init()
```


### func postValue\(LuaVM,LuaValue\)
```cj
public func postValue(vm: LuaVM, v: LuaValue): Bool
```
Builds a callback from a LuaValue and posts it (any thread)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machine|
|v|LuaValue|The target value (must be LuaValue.Function(ref))|

Return: 

- true if enqueued; false if it is not a function reference or the VM is closed

### func post\(LuaCallback\)
```cj
public func post(cb: LuaCallback): Unit
```
Posts a callback (any thread; enqueue only, never executes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cb|LuaCallback|The callback (ownership transfers to the queue; drain/clear releases it)|

### prop size: Int64
```cj
public prop size: Int64
```
The number of pending callbacks (readable from any thread)

