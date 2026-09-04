# 类
## class FrameTask
```cj
public class FrameTask <: HeapNode
```
帧任务

### func init\(Int64,FrameTaskMode,Int64,\(FrameTaskContext\)\->Bool,ICircularQueue<Array<Any>>,?Any\)
```cj
public init(id: Int64, mode: FrameTaskMode, priority: Int64, callback:(FrameTaskContext) -> Bool, params: ICircularQueue < Array < Any >>, shareValue!:?Any = None)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|唯一 ID，由调度器分配mode 任务模式priority 优先级，0=强制队列；>0 优先级队列callback 回调函数params 参数队列shareValue 共享值（可选）|
|mode|FrameTaskMode||
|priority|Int64||
|callback|(FrameTaskContext)->Bool||
|params|ICircularQueue<Array<Any>>||
|shareValue|?Any||

### func lessThan\(HeapNode\)
```cj
public func lessThan(other: HeapNode): Bool
```
比较函数：priority 越小越优先（最小堆）

参数: 

|名称|类型|描述|
|---|---|---|
|other|HeapNode|另一个堆节点|

返回: 

- this.priority < other.priority 时返回 true

### func notEmpty\(\)
```cj
public func notEmpty(): Bool
```
是否还有参数可处理（未完成且参数队列非空）

### func reset\(\)
```cj
public func reset(): Unit
```
重置任务状态

### func run\(Float64\)
```cj
public func run(deltaTime: Float64): Bool
```
执行一次任务

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float64|当前帧间隔时间（毫秒）|

返回: 

- true 表示本帧可继续执行；false 表示本帧停止调度（参数空、callback 返回 false、ONCE 完成）

### prop averageTimeConsume: Float64
```cj
public prop averageTimeConsume: Float64
```
EWMA 平均耗时（毫秒），用于调度器预算判断

### prop executionCount: Int64
```cj
public prop executionCount: Int64
```
执行次数计数

### prop finished: Bool
```cj
public prop finished: Bool
```
是否已完成

### prop index: Int64
```cj
public mut prop index: Int64
```
在堆中的索引（-1 表示不在堆中）

### prop lastTimeConsume: Float64
```cj
public prop lastTimeConsume: Float64
```
最近一次执行耗时（毫秒）

### let callback
```cj
public let callback:(FrameTaskContext) -> Bool
```
回调函数，返回 true 表示本帧继续；false 表示本帧停止

### var id
```cj
public var id: Int64
```
唯一 ID（由调度器分配，调用方不应直接修改）

### let mode
```cj
public let mode: FrameTaskMode
```
任务模式

### let params
```cj
public let params: ICircularQueue < Array < Any >>
```
参数队列

### var paused
```cj
public var paused: Bool
```
是否暂停（暂停时不参与调度，但保留状态）

### var priority
```cj
public var priority: Int64
```
优先级，0=强制队列；>0 进入 BinaryHeap 优先级队列，值越小优先级越高

### var shareValue
```cj
public var shareValue:?Any
```
共享值，可在多个 callback 之间共享数据

