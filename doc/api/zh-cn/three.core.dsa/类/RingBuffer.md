# 类
## class RingBuffer < T >
```cj
public class RingBuffer < T >
```
环形队列（固定容量）

### func add\(T\)
```cj
public func add(element: T): Bool
```
入队

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

返回: 

- true 入队成功；false 队列已满且不覆盖

### func clear\(\)
```cj
public func clear(): Unit
```
清空

### func get\(Int64\)
```cj
public func get(index: Int64):?T
```
按索引获取元素（0=队首，size-1=队尾）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|索引|

返回: 

- 元素，索引越界时返回 None

### func init\(Int64,Bool\)
```cj
public init(capacity: Int64, overwrite!: Bool = true)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|固定容量（<=0 时默认 16）overwrite 队列满时是否覆盖最旧元素（默认 true）|
|overwrite|Bool||

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空

返回: 

- 是否为空

### func isFull\(\)
```cj
public func isFull(): Bool
```
是否已满

返回: 

- 是否已满

### func iterator\(\)
```cj
public func iterator(): Iterator < T >
```
迭代器

返回: 

- 迭代器

### func peekLast\(\)
```cj
public func peekLast():?T
```
查看队尾元素（不出队）

返回: 

- 队尾元素，队列为空时返回 None

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
转为数组（队首到队尾顺序）

返回: 

- 包含所有元素的数组

### prop capacity: Int64
```cj
public prop capacity: Int64
```
固定容量

### prop size: Int64
```cj
public prop size: Int64
```
当前元素数量

