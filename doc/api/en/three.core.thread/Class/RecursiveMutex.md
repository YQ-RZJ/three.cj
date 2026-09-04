# Class
## class RecursiveMutex
```cj
public class RecursiveMutex
```
Reentrant mutex

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroy the mutex (recommended only when uncontended)

### func init\(\)
```cj
public init()
```
Constructor

### func lock\(\)
```cj
public func lock(): Unit
```
Lock (blocking). The owning thread may call again; only depth increases.

### func tryLock\(\)
```cj
public func tryLock(): Bool
```
Try to lock (non-blocking). The owning thread may call again; only depth increases.

Return: 

- true if successful

### func unlock\(\)
```cj
public func unlock(): Unit
```
Unlock. Decrements depth; the underlying lock is released only at depth zero.

### func withLock\(\(\)\->T\)
```cj
public func withLock < T >(callback:() -> T): T
```
Execute callback function while holding the lock, return result. Unlock
automatically after callback returns.

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->T|Callback function|

Return: 

- Callback return value

