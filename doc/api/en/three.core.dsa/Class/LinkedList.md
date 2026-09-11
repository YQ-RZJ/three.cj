# Class
## class LinkedList < T >
```cj
public class LinkedList < T >
```
Doubly linked list

### func addAfter\(LinkedListNode<T>,T\)
```cj
public func addAfter(node: LinkedListNode < T >, element: T): LinkedListNode < T >
```
Insert after the specified node

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|LinkedListNode<T>|Target nodeelement Element|
|element|T||

Return: 

- New node

### func addBefore\(LinkedListNode<T>,T\)
```cj
public func addBefore(node: LinkedListNode < T >, element: T): LinkedListNode < T >
```
Insert before the specified node

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|LinkedListNode<T>|Target nodeelement Element|
|element|T||

Return: 

- New node

### func addFirst\(T\)
```cj
public func addFirst(element: T): LinkedListNode < T >
```
Insert at the head

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

Return: 

- New node

### func addLast\(T\)
```cj
public func addLast(element: T): LinkedListNode < T >
```
Insert at the tail

Parameter: 

|Name|Type|Describe|
|---|---|---|
|element|T|Element|

Return: 

- New node

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the list

### func init\(\)
```cj
public init()
```
Default constructor

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Whether the list is empty

### func iterator\(\)
```cj
public func iterator(): Iterator < T >
```
迭代器

### func removeFirst\(\)
```cj
public func removeFirst():?T
```
Remove the head node

Return: 

- Head value, or None if the list is empty

### func removeLast\(\)
```cj
public func removeLast():?T
```
Remove the tail node

Return: 

- Tail value, or None if the list is empty

### func remove\(LinkedListNode<T>\)
```cj
public func remove(node: LinkedListNode < T >): Unit
```
Remove the specified node

Parameter: 

|Name|Type|Describe|
|---|---|---|
|node|LinkedListNode<T>|Node to remove|

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
Convert to an array (from head to tail)

### prop firstNode:?LinkedListNode < T >
```cj
public prop firstNode:?LinkedListNode < T >
```
Head node

### prop first:?T
```cj
public prop first:?T
```
Head element

### prop lastNode:?LinkedListNode < T >
```cj
public prop lastNode:?LinkedListNode < T >
```
Tail node

### prop last:?T
```cj
public prop last:?T
```
Tail element

### prop size: Int64
```cj
public prop size: Int64
```
Number of elements

