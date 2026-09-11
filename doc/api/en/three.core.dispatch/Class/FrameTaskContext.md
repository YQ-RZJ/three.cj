# Class
## class FrameTaskContext
```cj
public class FrameTaskContext
```
Frame task execution context

### func init\(FrameTask,Float64,Int64,Array<Any>\)
```cj
public init(task: FrameTask, deltaTime: Float64, idx: Int64, args: Array < Any >)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|task|FrameTask|Current taskdeltaTime Frame interval time (milliseconds)idx Execution countargs Parameters for this execution|
|deltaTime|Float64||
|idx|Int64||
|args|Array<Any>||

### let args
```cj
public let args: Array < Any >
```
Parameters for this execution

### let deltaTime
```cj
public let deltaTime: Float64
```
Frame interval time (milliseconds)

### let idx
```cj
public let idx: Int64
```
Execution count

### let task
```cj
public let task: FrameTask
```
Current task

