# Class
## class SPSCQueue < T >
```cj
public class SPSCQueue < T >
```
Lock-free fixed-capacity single-producer single-consumer queue

### func init\(Int64\)
```cj
public init(capacity!: Int64 = 1024)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Number of slots (defaults to 1024 when <=0). Prefer >= peak per-frame traffic|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Whether the queue is empty (approximate: the two atomic reads may skew; diagnostics only)

Return: 

- Whether empty

### func pop\(\)
```cj
public func pop():?T
```
Dequeue

Return: 

- The front element, or null when empty

### func push\(T\)
```cj
public func push(v: T): Bool
```
Enqueue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|T|Element|

Return: 

- true on success; false when full (retry or decide by policy)

### func size\(\)
```cj
public func size(): Int64
```
Approximate number of elements (diagnostics only)

Return: 

- Approximate element count

### prop capacity: Int64
```cj
public prop capacity: Int64
```
Fixed capacity (number of slots)

