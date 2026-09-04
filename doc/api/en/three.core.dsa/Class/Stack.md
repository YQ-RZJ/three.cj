# Class
## class Stack < T > where T <: Equatable < T >
```cj
public class Stack < T > where T <: Equatable < T >
```
Dynamic stack (last-in-first-out)

### func add\(T\)
```cj
public func add(element: T): Unit
```
Push element onto stack

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the stack

### func contains\(T\)
```cj
public func contains(element: T): Bool
```
Check if the stack contains the specified element

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element to find|

Return: 

- Whether the element is contained

### func init\(\)
```cj
public init()
```
Default constructor

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
Constructor with specified initial capacity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Initial capacity|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Check if the stack is empty

Return: 

- Whether the stack is empty

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
Peek at the top element without popping

Return: 

- Top element, or None if the stack is empty

### func remove\(\)
```cj
public func remove():?T
```
Pop element from stack

Return: 

- Top element, or None if the stack is empty

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
Convert to array (bottom to top order)

Return: 

- Array containing all elements

### prop size: Int64
```cj
public prop size: Int64
```
元素数量

