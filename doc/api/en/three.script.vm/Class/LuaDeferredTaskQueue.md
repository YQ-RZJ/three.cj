# Class
## class LuaDeferredTaskQueue
```cj
public class LuaDeferredTaskQueue
```
Cross-thread deferred task queue

### func clear\(\)
```cj
public func clear(): Int64
```
Clears the queue (Lua thread): discards every task without executing it

Return: 

- The number of discarded tasks

### func drain\(\)
```cj
public func drain(): Int64
```
Executes all pending tasks on the Lua thread

Return: 

- The number of tasks that completed successfully (failing ones excluded)

### func init\(\)
```cj
public init()
```


### func post\(\(\)\->Unit\)
```cj
public func post(task:() -> Unit): Unit
```
Posts a task (any thread; enqueue only, never executes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|task|()->Unit|The task (its body may safely touch Lua)|

### prop size: Int64
```cj
public prop size: Int64
```
The number of pending tasks (readable from any thread)

