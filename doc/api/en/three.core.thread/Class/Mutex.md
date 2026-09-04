# Class
## class Mutex
```cj
public class Mutex
```
Mutex

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroy the mutex

### func init\(\)
```cj
public init()
```
Constructor: create a mutex

### func lock\(\)
```cj
public func lock(): Unit
```
Lock (blocking)

### func tryLock\(\)
```cj
public func tryLock(): Bool
```
Try to lock (non-blocking)

Return: 

- true if successful

### func unlock\(\)
```cj
public func unlock(): Unit
```
Unlock

