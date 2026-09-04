# Class
## class Semaphore
```cj
public class Semaphore
```
Semaphore

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroy the semaphore

### func init\(UInt32\)
```cj
public init(initialValue!: UInt32 = 0)
```
Constructor: create a semaphore

Parameter: 

|Name|Type|Describe|
|---|---|---|
|initialValue|UInt32|Initial count value|

### func signal\(\)
```cj
public func signal(): Unit
```
Signal the semaphore (increments count)

### func tryWait\(\)
```cj
public func tryWait(): Bool
```
Try to wait for semaphore (non-blocking)

Return: 

- true if successful

### func wait\(\)
```cj
public func wait(): Unit
```
Wait for semaphore (blocking, decrements count)

### func wait\(Int32\)
```cj
public func wait(timeoutMS: Int32): Bool
```
Wait for semaphore with timeout

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeoutMS|Int32|Timeout in milliseconds|

Return: 

- true if successful; false if timed out

