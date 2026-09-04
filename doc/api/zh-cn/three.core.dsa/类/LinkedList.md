# 类
## class LinkedList < T >
```cj
public class LinkedList < T >
```
双向链表

### func addAfter\(LinkedListNode<T>,T\)
```cj
public func addAfter(node: LinkedListNode < T >, element: T): LinkedListNode < T >
```
在指定节点后插入

参数: 

|名称|类型|描述|
|---|---|---|
|node|LinkedListNode<T>|目标节点element 元素|
|element|T||

返回: 

- 新节点

### func addBefore\(LinkedListNode<T>,T\)
```cj
public func addBefore(node: LinkedListNode < T >, element: T): LinkedListNode < T >
```
在指定节点前插入

参数: 

|名称|类型|描述|
|---|---|---|
|node|LinkedListNode<T>|目标节点element 元素|
|element|T||

返回: 

- 新节点

### func addFirst\(T\)
```cj
public func addFirst(element: T): LinkedListNode < T >
```
头部插入

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

返回: 

- 新节点

### func addLast\(T\)
```cj
public func addLast(element: T): LinkedListNode < T >
```
尾部插入

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

返回: 

- 新节点

### func clear\(\)
```cj
public func clear(): Unit
```
清空链表

### func init\(\)
```cj
public init()
```
默认构造器

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空

### func iterator\(\)
```cj
public func iterator(): Iterator < T >
```
迭代器

### func removeFirst\(\)
```cj
public func removeFirst():?T
```
删除头部节点

返回: 

- 头部值，链表为空时返回 None

### func removeLast\(\)
```cj
public func removeLast():?T
```
删除尾部节点

返回: 

- 尾部值，链表为空时返回 None

### func remove\(LinkedListNode<T>\)
```cj
public func remove(node: LinkedListNode < T >): Unit
```
删除指定节点

参数: 

|名称|类型|描述|
|---|---|---|
|node|LinkedListNode<T>|要删除的节点|

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
转为数组（从头到尾）

### prop firstNode:?LinkedListNode < T >
```cj
public prop firstNode:?LinkedListNode < T >
```
链首节点

### prop first:?T
```cj
public prop first:?T
```
链首元素

### prop lastNode:?LinkedListNode < T >
```cj
public prop lastNode:?LinkedListNode < T >
```
链尾节点

### prop last:?T
```cj
public prop last:?T
```
链尾元素

### prop size: Int64
```cj
public prop size: Int64
```
元素数量

