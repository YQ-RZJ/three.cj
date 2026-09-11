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
EWMA average execution time (milliseconds), used for the dispatcher's budget check

### prop executionCount: Int64
```cj
public prop executionCount: Int64
```
Execution count

### prop finished: Bool
```cj
public prop finished: Bool
```
Whether the task is finished

### prop index: Int64
```cj
public mut prop index: Int64
```
Index in the heap (-1 means not in the heap)

### prop lastTimeConsume: Float64
```cj
public prop lastTimeConsume: Float64
```
Time consumed by the most recent execution (milliseconds)

### let callback
```cj
public let callback:(FrameTaskContext) -> Bool
```
Callback function: returning true means continue this frame; false means stop this frame

### var id
```cj
public var id: Int64
```
Unique ID (assigned by the dispatcher; callers should not modify it directly)

### let mode
```cj
public let mode: FrameTaskMode
```
Task mode

### let params
```cj
public let params: ICircularQueue < Array < Any >>
```
Parameter queue

### var paused
```cj
public var paused: Bool
```
Whether paused (paused tasks are excluded from scheduling but keep their state)

### var priority
```cj
public var priority: Int64
```
Priority: 0=forced queue; >0 enters the BinaryHeap priority queue, lower value means higher priority

### var shareValue
```cj
public var shareValue:?Any
```
Shared value, can share data among multiple callbacks

