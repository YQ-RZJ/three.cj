# Class
## class EventFactory
```cj
public class EventFactory
```
Event object pool

### func allocate\(\)
```cj
public func allocate(): EventRecord
```
Allocate an EventRecord instance

Return: 

- EventRecord with assigned ID; caller should immediately set name/target/once/callback

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the object pool

### func init\(\)
```cj
public init()
```
Default constructor

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
Constructor with initial pre-allocation capacity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Number of objects to pre-create, warm up before hot-path calls|

### func recycle\(EventRecord\)
```cj
public func recycle(record: EventRecord): Unit
```
Recycle an EventRecord instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|record|EventRecord|Instance to recycle|

### prop allocatedCount: Int64
```cj
public prop allocatedCount: Int64
```


### prop freeCount: Int64
```cj
public prop freeCount: Int64
```


