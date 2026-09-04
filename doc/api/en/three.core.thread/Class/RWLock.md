# Class
## class RWLock
```cj
public class RWLock
```
Read-write lock (multiple readers, single writer)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroy the read-write lock

### func init\(\)
```cj
public init()
```
Constructor: create a read-write lock

### func lockRead\(\)
```cj
public func lockRead(): Unit
```
Lock for reading (blocking, multiple readers allowed)

### func lockWrite\(\)
```cj
public func lockWrite(): Unit
```
Lock for writing (blocking, exclusive)

### func tryLockRead\(\)
```cj
public func tryLockRead(): Bool
```
Try to lock for reading (non-blocking)

Return: 

- true if successful

### func tryLockWrite\(\)
```cj
public func tryLockWrite(): Bool
```
Try to lock for writing (non-blocking)

Return: 

- true if successful

### func unlock\(\)
```cj
public func unlock(): Unit
```
Unlock

