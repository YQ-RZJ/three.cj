# Class
## class FrameTask
```cj
public class FrameTask <: HeapNode
```
Frame task

### func init\(Int64,FrameTaskMode,Int64,\(FrameTaskContext\)\->Bool,ICircularQueue<Array<Any>>,?Any\)
```cj
public init(id: Int64, mode: FrameTaskMode, priority: Int64, callback:(FrameTaskContext) -> Bool, params: ICircularQueue < Array < Any >>, shareValue!:?Any = None)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Unique ID, assigned by the dispatchermode Task modepriority Priority, 0=forced queue; >0=priority queuecallback Callback functionparams Parameter queueshareValue Shared value (optional)|
|mode|FrameTaskMode||
|priority|Int64||
|callback|(FrameTaskContext)->Bool||
|params|ICircularQueue<Array<Any>>||
|shareValue|?Any||

### func lessThan\(HeapNode\)
```cj
public func lessThan(other: HeapNode): Bool
```
Comparison function: lower priority value means higher priority (min-heap)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|HeapNode|Another heap node|

Return: 

- Returns true when this.priority < other.priority

### func notEmpty\(\)
```cj
public func notEmpty(): Bool
```
Whether there are still parameters to process (not finished and parameter queue is non-empty)

### func reset\(\)
```cj
public func reset(): Unit
```
Reset task state

### func run\(Float64\)
```cj
public func run(deltaTime: Float64): Bool
```
Execute the task once

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float64|Current frame interval time (milliseconds)|

Return: 

- true means continue execution this frame; false means stop this frame's scheduling (empty params, callback returns false, or ONCE completed)

### prop averageTimeConsume: Float64
```cj
public prop averageTimeConsume: Float64
```


### prop executionCount: Int64
```cj
public prop executionCount: Int64
```


### prop finished: Bool
```cj
public prop finished: Bool
```


### prop index: Int64
```cj
public mut prop index: Int64
```


### prop lastTimeConsume: Float64
```cj
public prop lastTimeConsume: Float64
```


### let callback
```cj
public let callback:(FrameTaskContext) -> Bool
```


### var id
```cj
public var id: Int64
```


### let mode
```cj
public let mode: FrameTaskMode
```


### let params
```cj
public let params: ICircularQueue < Array < Any >>
```


### var paused
```cj
public var paused: Bool
```


### var priority
```cj
public var priority: Int64
```


### var shareValue
```cj
public var shareValue:?Any
```


