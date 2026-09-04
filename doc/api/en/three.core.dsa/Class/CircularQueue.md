# Class
## class CircularQueue < T >
```cj
public class CircularQueue < T > <: ICircularQueue < T >
```
Circular queue

### func add\(T\)
```cj
public func add(element: T): Unit
```
Enqueue (tail)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

### func clear\(\)
```cj
public func clear(): Unit
```


### func init\(\)
```cj
public init()
```
Default constructor

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
Constructor with initial capacity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Initial capacity|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```


### func next\(\)
```cj
public func next():?T
```
Circularly get the next element (without consuming)

Return: 

- Next element; None if empty

### func peek\(\)
```cj
public func peek():?T
```
Peek at the current next-pointed element (no consumption)

Return: 

- Element; None if empty

### func remove\(\)
```cj
public func remove():?T
```
Dequeue (tail, LIFO consumption)

Return: 

- Tail element; None if empty

### func toArray\(\)
```cj
public func toArray(): Array < T >
```


### prop size: Int64
```cj
public prop size: Int64
```


