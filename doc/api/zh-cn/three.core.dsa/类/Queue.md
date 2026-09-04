# 类
## class Queue < T > where T <: Equatable < T >
```cj
public class Queue < T > where T <: Equatable < T >
```
动态队列（先进先出）

### func add\(T\)
```cj
public func add(element: T): Unit
```
入队

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

### func clear\(\)
```cj
public func clear(): Unit
```
清空队列

### func contains\(T\)
```cj
public func contains(element: T): Bool
```
是否包含元素

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|要查找的元素|

返回: 

- 是否包含

### func init\(Int64\)
```cj
public init(capacity!: Int64 = 16)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|初始容量（<=0 时默认 16）|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空

返回: 

- 是否为空

### func iterator\(\)
```cj
public func iterator(): Iterator < T >
```
迭代器

返回: 

- 迭代器

### func peek\(\)
```cj
public func peek():?T
```
查看队首元素（不出队）

返回: 

- 队首元素，队列为空时返回 None

### func remove\(\)
```cj
public func remove():?T
```
出队

返回: 

- 队首元素，队列为空时返回 None

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
转为数组

返回: 

- 包含所有元素的数组

### prop size: Int64
```cj
public prop size: Int64
```
元素数量

