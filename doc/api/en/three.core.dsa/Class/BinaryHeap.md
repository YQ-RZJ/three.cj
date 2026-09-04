# Class
## class BinaryHeap < T > where T <: HeapNode
```cj
public class BinaryHeap < T > where T <: HeapNode
```
Binary heap (default min-heap)

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the heap

### func contains\(T\)
```cj
public func contains(node: T): Bool
```
Whether the heap contains the node

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|T|Node|

Return: 

- Whether contained

### func get\(Int64\)
```cj
public func get(index: Int64): T
```
Get a node

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Node index|

Return: 

- Node

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Initial capacity (defaults to 4 when <=0)|

### func init\(\)
```cj
public init()
```


### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```


### func pop\(\)
```cj
public func pop():?T
```
Pop the top node from the heap

Return: 

- Top node, or None if the heap is empty

### func push\(T\)
```cj
public func push(node: T): Unit
```
Push a node into the heap

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|T|Node|

### func remove\(T\)
```cj
public func remove(node: T): Unit
```
Remove a specified node

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|T|Node to remove|

### func top\(\)
```cj
public func top(): T
```
Get the top node (heap top)

Return: 

- Top node

### func update\(T\)
```cj
public func update(node: T): Bool
```
Update node position (call after node priority changes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|T|Node to update|

Return: 

- true if update succeeded

### prop size: Int64
```cj
public prop size: Int64
```


