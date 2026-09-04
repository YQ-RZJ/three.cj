# 类
## class Stack < T > where T <: Equatable < T >
```cj
public class Stack < T > where T <: Equatable < T >
```
动态栈（后进先出）

### func add\(T\)
```cj
public func add(element: T): Unit
```
入栈

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

### func clear\(\)
```cj
public func clear(): Unit
```
清空栈

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
查看栈顶元素（不出栈）

返回: 

- 栈顶元素，栈为空时返回 None

### func remove\(\)
```cj
public func remove():?T
```
出栈

返回: 

- 栈顶元素，栈为空时返回 None

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
转为数组（栈底到栈顶顺序）

返回: 

- 包含所有元素的数组

### prop size: Int64
```cj
public prop size: Int64
```
元素数量

