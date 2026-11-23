# 类
## class LuaDeferredCallbackQueue
```cj
public class LuaDeferredCallbackQueue
```
跨线程 Lua 回调队列

### func clear\(\)
```cj
public func clear(): Int64
```
清空队列（Lua 线程调用）：释放全部回调引用但不执行

返回: 

- 被丢弃的条数

### func drain\(\)
```cj
public func drain(): Int64
```
在 Lua 线程执行全部待处理回调

返回: 

- 实际成功执行的条数（失败条目不计入）

### func init\(\)
```cj
public init()
```


### func postValue\(LuaVM,LuaValue\)
```cj
public func postValue(vm: LuaVM, v: LuaValue): Bool
```
从 LuaValue 构造并投递回调（任意线程）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|所属虚拟机|
|v|LuaValue|目标值（须为 LuaValue.Function(ref)）|

返回: 

- true = 已入队；false = 不是函数引用或 VM 已关闭

### func post\(LuaCallback\)
```cj
public func post(cb: LuaCallback): Unit
```
投递一个回调（任意线程，只入队不执行）

参数: 

|名称|类型|描述|
|---|---|---|
|cb|LuaCallback|目标回调（所有权转移给队列，由 drain/clear 负责 release）|

### prop size: Int64
```cj
public prop size: Int64
```
当前待执行回调数量（任意线程可读）

