# 类
## class SThread < T >
```cj
public open class SThread < T >
```
系统线程类

### func detach\(\)
```cj
public open func detach(): Unit
```
分离线程（自动回收资源）

### func getId\(\)
```cj
public open func getId(): UInt64
```
获取线程 ID（线程 ID）

返回: 

- 线程 ID

### func get\(\)
```cj
public open func get(): T
```
阻塞获取线程执行结果

返回: 

- 线程执行结果

### func get\(Int32\)
```cj
public open func get(timeoutMS: Int32): T
```
带超时获取线程执行结果

参数: 

|名称|类型|描述|
|---|---|---|
|timeoutMS|Int32|最大等待毫秒数|

返回: 

- 线程结果；超时抛 TimeoutException

### func init\(\(\)\->T\)
```cj
public init(callback:() -> T)
```
构造器：创建一条系统线程

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->T|线程回调函数|

### func init\(\(\)\->T,String,Int64\)
```cj
public init(callback:() -> T, name: String, stackSizeBytes: Int64)
```
构造器（指定线程名与栈大小）

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->T|线程回调函数|
|name|String|线程名|
|stackSizeBytes|Int64|线程栈大小（字节）|

### func init\(\(\)\->T,String,Int64,ThreadPriority\)
```cj
public init(callback:() -> T, name: String, stackSizeBytes: Int64, priority: ThreadPriority)
```
构造器（指定线程名、栈大小与优先级）

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->T|线程回调函数|
|name|String|线程名|
|stackSizeBytes|Int64|线程栈大小（字节）|
|priority|ThreadPriority|线程优先级|

### func join\(\)
```cj
public open func join(): Unit
```
等待线程结束（阻塞）

### func tryGet\(\)
```cj
public open func tryGet(): Option < T >
```
尝试获取线程执行结果（线程未结束返回 None）

返回: 

- 线程结果，或 None

