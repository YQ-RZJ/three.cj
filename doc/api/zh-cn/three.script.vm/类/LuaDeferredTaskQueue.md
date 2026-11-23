# 类
## class LuaDeferredTaskQueue
```cj
public class LuaDeferredTaskQueue
```
跨线程延迟任务队列

### func clear\(\)
```cj
public func clear(): Int64
```
清空队列（Lua 线程调用）：丢弃全部任务但不执行

返回: 

- 被丢弃的条数

### func drain\(\)
```cj
public func drain(): Int64
```
在 Lua 线程执行全部待处理任务

返回: 

- 实际成功执行的条数（失败条目不计入）

### func init\(\)
```cj
public init()
```


### func post\(\(\)\->Unit\)
```cj
public func post(task:() -> Unit): Unit
```
投递一个任务（任意线程，只入队不执行）

参数: 

|名称|类型|描述|
|---|---|---|
|task|()->Unit|目标任务（闭包体内可安全触碰 Lua）|

### prop size: Int64
```cj
public prop size: Int64
```
当前待执行任务数量（任意线程可读）

