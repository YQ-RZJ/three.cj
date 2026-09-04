# 类
## class FrameDispatch
```cj
public class FrameDispatch
```
帧调度器

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有任务

### func frameEvent\(Float64\)
```cj
public func frameEvent(deltaTime!: Float64 = 0.0): Unit
```
帧调度

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float64|当前帧间隔时间（毫秒，默认 0）|

### func init\(Float64\)
```cj
public init(maximum!: Float64 = 5.0)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|maximum|Float64|帧调度函数总执行时间上限（毫秒，默认 5.0）|

### func pause\(Int64\)
```cj
public func pause(id: Int64): Unit
```
暂停任务（不参与调度，保留状态）

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|任务 ID|

### func registerTask\(FrameTaskMode,Int64,\(FrameTaskContext\)\->Bool,ICircularQueue<Array<Any>>,?Any\)
```cj
public func registerTask(mode: FrameTaskMode, priority: Int64, callback:(FrameTaskContext) -> Bool, params: ICircularQueue < Array < Any >>, shareValue!:?Any = None): Int64
```
创建并注册帧任务（便捷方法）

参数: 

|名称|类型|描述|
|---|---|---|
|mode|FrameTaskMode|任务模式priority 优先级（0=强制队列；>0=优先级队列，值越小优先级越高）callback 回调函数params 参数队列shareValue 共享值（可选）|
|priority|Int64||
|callback|(FrameTaskContext)->Bool||
|params|ICircularQueue<Array<Any>>||
|shareValue|?Any||

返回: 

- 任务 ID，可用于 unregister/pause/resume

### func register\(FrameTask\)
```cj
public func register(task: FrameTask): Unit
```
注册帧任务

参数: 

|名称|类型|描述|
|---|---|---|
|task|FrameTask|帧任务|

### func resume\(Int64\)
```cj
public func resume(id: Int64): Unit
```
恢复任务

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|任务 ID|

### func unregister\(Int64\)
```cj
public func unregister(id: Int64): Unit
```
取消注册

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|任务 ID|

### prop activeTaskCount: Int64
```cj
public prop activeTaskCount: Int64
```
当前活跃任务数量（不含暂停）

### prop frameElapsed: Float64
```cj
public prop frameElapsed: Float64
```
当前轮次帧已消耗时间（毫秒）

### prop pausedTaskCount: Int64
```cj
public prop pausedTaskCount: Int64
```
暂停任务数量

### var maximum
```cj
public var maximum: Float64
```
时间预算上限（毫秒），优先级队列的总执行时间上限

