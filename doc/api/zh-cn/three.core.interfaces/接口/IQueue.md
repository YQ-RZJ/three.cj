# 接口
## interface IQueue < T >
```cj
public interface IQueue < T >
```
队列接口

### func add\(T\)
```cj
func add(element: T): Unit
```
入队

参数: 

|名称|类型|描述|
|---|---|---|
|element|T|元素|

### func clear\(\)
```cj
func clear(): Unit
```
清空队列

### func isEmpty\(\)
```cj
func isEmpty(): Bool
```
是否为空

返回: 

- 为空返回 true

### func peek\(\)
```cj
func peek():?T
```
查看队首元素（不消耗）

返回: 

- 队首元素；空时返回 None

### func remove\(\)
```cj
func remove():?T
```
出队（消耗一个元素）

返回: 

- 队首元素；空时返回 None

### prop size: Int64
```cj
prop size: Int64
```
当前元素数量

