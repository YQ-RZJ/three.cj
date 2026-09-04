# Class
## class EcsObject
```cj
public open class EcsObject <: IPoolObject
```
ECS object lifecycle base class, interfacing with object pool

### func construct\(\)
```cj
public func construct(): Unit
```
Construct (pool reuse entry); only executes onConstruct when not constructed, ensuring idempotency

### func destruct\(\)
```cj
public func destruct(): Unit
```
Destruct (recycle/delete entry); only executes onDestruct when constructed, ensuring idempotency

### func restruct\(\)
```cj
public func restruct(): Unit
```
Restruct (force rebuild); Cangjie relies on super calls in the onConstruct override chain

### prop constructed: Bool
```cj
public prop constructed: Bool
```
Whether constructed

