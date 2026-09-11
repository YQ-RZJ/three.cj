# Class
## class FrameDispatch
```cj
public class FrameDispatch
```
Frame dispatcher

### func clear\(\)
```cj
public func clear(): Unit
```
Clear all tasks

### func frameEvent\(Float64\)
```cj
public func frameEvent(deltaTime!: Float64 = 0.0): Unit
```
Frame dispatch

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float64|Current frame interval time (milliseconds, default 0)|

### func init\(Float64\)
```cj
public init(maximum!: Float64 = 5.0)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maximum|Float64|Total execution time limit for the frame dispatch function (milliseconds, default 5.0)|

### func pause\(Int64\)
```cj
public func pause(id: Int64): Unit
```
Pause a task (removed from scheduling, state preserved)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Task ID|

### func registerTask\(FrameTaskMode,Int64,\(FrameTaskContext\)\->Bool,ICircularQueue<Array<Any>>,?Any\)
```cj
public func registerTask(mode: FrameTaskMode, priority: Int64, callback:(FrameTaskContext) -> Bool, params: ICircularQueue < Array < Any >>, shareValue!:?Any = None): Int64
```
Create and register a frame task (convenience method)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mode|FrameTaskMode|Task modepriority Priority (0=forced queue; >0=priority queue, lower value means higher priority)callback Callback functionparams Parameter queueshareValue Shared value (optional)|
|priority|Int64||
|callback|(FrameTaskContext)->Bool||
|params|ICircularQueue<Array<Any>>||
|shareValue|?Any||

Return: 

- Task ID, can be used for unregister/pause/resume

### func register\(FrameTask\)
```cj
public func register(task: FrameTask): Unit
```
Register a frame task

Parameter: 

|Name|Type|Describe|
|---|---|---|
|task|FrameTask|Frame task|

### func resume\(Int64\)
```cj
public func resume(id: Int64): Unit
```
Resume a paused task

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Task ID|

### func unregister\(Int64\)
```cj
public func unregister(id: Int64): Unit
```
Unregister a task

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Task ID|

### prop activeTaskCount: Int64
```cj
public prop activeTaskCount: Int64
```
Number of currently active tasks (excluding paused ones)

### prop frameElapsed: Float64
```cj
public prop frameElapsed: Float64
```
Time consumed in the current frame round (milliseconds)

### prop pausedTaskCount: Int64
```cj
public prop pausedTaskCount: Int64
```
Number of paused tasks

### var maximum
```cj
public var maximum: Float64
```
Time budget limit (milliseconds), total execution time cap for the priority queue

