# 接口
## interface IHeapNode
```cj
public interface IHeapNode
```
堆节点接口

### func lessThan\(IHeapNode\)
```cj
func lessThan(other: IHeapNode): Bool
```
比较函数

参数: 

|名称|类型|描述|
|---|---|---|
|other|IHeapNode|另一个节点|

返回: 

- true 表示 this 比 other 更优先（应排在更前面）

### prop index: Int64
```cj
mut prop index: Int64
```
在堆中的索引，-1 表示不在堆中

