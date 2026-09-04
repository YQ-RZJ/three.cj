# 接口
## interface HeapNode
```cj
public interface HeapNode
```
堆节点接口

### func lessThan\(HeapNode\)
```cj
func lessThan(other: HeapNode): Bool
```
比较函数

参数: 

|名称|类型|描述|
|---|---|---|
|other|HeapNode|另一个节点|

返回: 

- true 表示 this 比 other 更优先（应排在更前面）

### prop index: Int64
```cj
mut prop index: Int64
```
在堆中的索引，-1 表示不在堆中

