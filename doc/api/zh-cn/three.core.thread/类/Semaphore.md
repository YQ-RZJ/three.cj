# 类
## class Semaphore
```cj
public class Semaphore
```
信号量

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁信号量

### func init\(UInt32\)
```cj
public init(initialValue!: UInt32 = 0)
```
构造器：创建信号量

参数: 

|名称|类型|描述|
|---|---|---|
|initialValue|UInt32|初始计数值|

### func signal\(\)
```cj
public func signal(): Unit
```
发送信号量（计数值加一）

### func tryWait\(\)
```cj
public func tryWait(): Bool
```
尝试等待信号量（非阻塞）

返回: 

- 成功返回 true

### func wait\(\)
```cj
public func wait(): Unit
```
等待信号量（阻塞，计数值减一）

### func wait\(Int32\)
```cj
public func wait(timeoutMS: Int32): Bool
```
带超时等待信号量

参数: 

|名称|类型|描述|
|---|---|---|
|timeoutMS|Int32|超时毫秒数|

返回: 

- 成功返回 true；超时返回 false

