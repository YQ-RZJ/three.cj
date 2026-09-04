# 类
## class CircularQueue < T >
```cj
public class CircularQueue < T > <: ICircularQueue < T >
```
循环队列

### func add\(T\)
```cj
public func add(element: T): Unit
```
入队（尾部）

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

### func clear\(\)
```cj
public func clear(): Unit
```
清空

### func init\(\)
```cj
public init()
```
默认构造器

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
指定初始容量的构造器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|初始容量|

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空

### func next\(\)
```cj
public func next():?T
```
循环获取下一个元素（不消耗）

返回: 

- 下一个元素；空时返回 None

### func peek\(\)
```cj
public func peek():?T
```
查看当前 next 指向的元素（不消耗）

返回: 

- 元素；空时返回 None

### func remove\(\)
```cj
public func remove():?T
```
出队（尾部，LIFO 消耗）

返回: 

- 队尾元素；空时返回 None

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
转为数组（入队顺序）

### prop size: Int64
```cj
public prop size: Int64
```
当前元素数量

