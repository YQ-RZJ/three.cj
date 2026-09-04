# Class
## class RingBuffer < T >
```cj
public class RingBuffer < T >
```
Ring buffer (fixed capacity)

### func add\(T\)
```cj
public func add(element: T): Bool
```
Enqueue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

Return: 

- true if enqueued successfully; false if the queue is full and overwrite is disabled

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the buffer

### func get\(Int64\)
```cj
public func get(index: Int64):?T
```
Get element by index (0=front, size-1=back)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index|

Return: 

- Element, or None if index is out of bounds

### func init\(Int64,Bool\)
```cj
public init(capacity: Int64, overwrite!: Bool = true)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Fixed capacity (defaults to 16 when <=0)overwrite Whether to overwrite the oldest element when the queue is full (default true)|
|overwrite|Bool||

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Check if the buffer is empty

Return: 

- Whether the buffer is empty

### func isFull\(\)
```cj
public func isFull(): Bool
```
Check if the buffer is full

Return: 

- Whether the buffer is full

### func iterator\(\)
```cj
public func iterator(): Iterator < T >
```
Iterator

Return: 

- Iterator

### func peekLast\(\)
```cj
public func peekLast():?T
```
Peek at the last element without dequeuing

Return: 

- Last element, or None if the queue is empty

### func peek\(\)
```cj
public func peek():?T
```
Peek at the front element without dequeuing

Return: 

- Front element, or None if the queue is empty

### func remove\(\)
```cj
public func remove():?T
```
Dequeue

Return: 

- Front element, or None if the queue is empty

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
Convert to array (front to back order)

Return: 

- Array containing all elements

### prop capacity: Int64
```cj
public prop capacity: Int64
```
Fixed capacity

### prop size: Int64
```cj
public prop size: Int64
```
Current number of elements

