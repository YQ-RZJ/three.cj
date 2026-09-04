# 类
## class FrameTaskContext
```cj
public class FrameTaskContext
```
帧任务执行上下文

### func init\(FrameTask,Float64,Int64,Array<Any>\)
```cj
public init(task: FrameTask, deltaTime: Float64, idx: Int64, args: Array < Any >)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|task|FrameTask|当前任务deltaTime 帧间隔时间（毫秒）idx 执行次数计数args 本次执行参数|
|deltaTime|Float64||
|idx|Int64||
|args|Array<Any>||

### let args
```cj
public let args: Array < Any >
```
本次执行参数

### let deltaTime
```cj
public let deltaTime: Float64
```
帧间隔时间（毫秒）

### let idx
```cj
public let idx: Int64
```
执行次数计数

### let task
```cj
public let task: FrameTask
```
当前任务

