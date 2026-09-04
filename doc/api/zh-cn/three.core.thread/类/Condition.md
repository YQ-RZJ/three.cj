# 类
## class Condition
```cj
public class Condition
```
条件变量

### func broadcast\(\)
```cj
public func broadcast(): Unit
```
唤醒所有等待线程

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁条件变量

### func init\(\)
```cj
public init()
```
构造器：创建条件变量

### func signal\(\)
```cj
public func signal(): Unit
```
唤醒一个等待线程

### func wait\(Mutex\)
```cj
public func wait(mutex: Mutex): Bool
```
等待条件（阻塞，需先持有 mutex；等待期间自动释放 mutex，唤醒后重新持有）

参数: 

|名称|类型|描述|
|---|---|---|
|mutex|Mutex|关联的互斥锁|

返回: 

- 是否成功

### func wait\(Mutex,Int32\)
```cj
public func wait(mutex: Mutex, timeoutMS: Int32): Bool
```
带超时等待条件

参数: 

|名称|类型|描述|
|---|---|---|
|mutex|Mutex|关联的互斥锁timeoutMS 超时毫秒数|
|timeoutMS|Int32||

返回: 

- 成功（被唤醒）返回 true；超时返回 false

