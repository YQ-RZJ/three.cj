# 类
## class BinaryHeap < T > where T <: HeapNode
```cj
public class BinaryHeap < T > where T <: HeapNode
```
二叉堆（默认最小堆）

### func clear\(\)
```cj
public func clear(): Unit
```
清空堆

### func contains\(T\)
```cj
public func contains(node: T): Bool
```
是否包含节点

参数: 

|名称|类型|描述|
|---|---|---|
|node|T|节点|

返回: 

- 是否包含

### func get\(Int64\)
```cj
public func get(index: Int64): T
```
获取节点

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|节点索引|

返回: 

- 节点

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|初始容量（<=0 时默认 4）|

### func init\(\)
```cj
public init()
```
默认构造器，容量 4

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空

### func pop\(\)
```cj
public func pop():?T
```
Pop 堆顶节点

返回: 

- 堆顶节点，堆为空时返回 None

### func push\(T\)
```cj
public func push(node: T): Unit
```
Push 节点到堆中

参数: 

|名称|类型|描述|
|---|---|---|
|node|T|节点|

### func remove\(T\)
```cj
public func remove(node: T): Unit
```
移除指定节点

参数: 

|名称|类型|描述|
|---|---|---|
|node|T|要移除的节点|

### func top\(\)
```cj
public func top(): T
```
获取顶部节点（堆顶）

返回: 

- 堆顶节点

### func update\(T\)
```cj
public func update(node: T): Bool
```
更新节点位置（节点优先级变化后调用）

参数: 

|名称|类型|描述|
|---|---|---|
|node|T|要更新的节点|

返回: 

- true 表示更新成功

### prop size: Int64
```cj
public prop size: Int64
```
当前元素数量

