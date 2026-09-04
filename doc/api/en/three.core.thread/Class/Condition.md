# Class
## class Condition
```cj
public class Condition
```
Condition variable

### func broadcast\(\)
```cj
public func broadcast(): Unit
```
Broadcast to all waiting threads

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroy the condition variable

### func init\(\)
```cj
public init()
```
Constructor: create a condition variable

### func signal\(\)
```cj
public func signal(): Unit
```
Signal one waiting thread

### func wait\(Mutex\)
```cj
public func wait(mutex: Mutex): Bool
```
Wait for condition (blocking, must hold mutex first; mutex is automatically released during wait and re-acquired on wakeup)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mutex|Mutex|Associated mutex|

Return: 

- Whether successful

### func wait\(Mutex,Int32\)
```cj
public func wait(mutex: Mutex, timeoutMS: Int32): Bool
```
Wait for condition with timeout

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mutex|Mutex|Associated mutextimeoutMS Timeout in milliseconds|
|timeoutMS|Int32||

Return: 

- true if signaled (woken up); false if timed out

