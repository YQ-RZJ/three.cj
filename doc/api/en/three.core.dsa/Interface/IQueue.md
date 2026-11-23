# Interface
## interface IQueue < T >
```cj
public interface IQueue < T >
```
Queue interface

### func add\(T\)
```cj
func add(element: T): Unit
```
Enqueue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

### func clear\(\)
```cj
func clear(): Unit
```
Clear the queue

### func isEmpty\(\)
```cj
func isEmpty(): Bool
```
Whether the queue is empty

Return: 

- true if empty

### func peek\(\)
```cj
func peek():?T
```
Peek at the front element (without consuming)

Return: 

- Front element; None if empty

### func remove\(\)
```cj
func remove():?T
```
Dequeue (consume one element)

Return: 

- Front element; None if empty

### prop size: Int64
```cj
prop size: Int64
```
Current element count

