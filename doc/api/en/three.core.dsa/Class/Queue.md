# Class
## class Queue < T > where T <: Equatable < T >
```cj
public class Queue < T > where T <: Equatable < T >
```
Dynamic queue (first-in-first-out)

### func add\(T\)
```cj
public func add(element: T): Unit
```
Enqueue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the queue

### func contains\(T\)
```cj
public func contains(element: T): Bool
```
Check if the queue contains the specified element

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element to find|

Return: 

- Whether the element is contained

### func init\(Int64\)
```cj
public init(capacity!: Int64 = 16)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Initial capacity (defaults to 16 when <=0)|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Check if the queue is empty

Return: 

- Whether the queue is empty

### func iterator\(\)
```cj
public func iterator(): Iterator < T >
```
Iterator

Return: 

- Iterator

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
Convert to array

Return: 

- Array containing all elements

### prop size: Int64
```cj
public prop size: Int64
```
Number of elements

