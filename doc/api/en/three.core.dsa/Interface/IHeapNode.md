# Interface
## interface IHeapNode
```cj
public interface IHeapNode
```
Heap node interface

### func lessThan\(IHeapNode\)
```cj
func lessThan(other: IHeapNode): Bool
```
Comparison function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|IHeapNode|Another node|

Return: 

- true means this has higher priority than other (should be placed ahead)

### prop index: Int64
```cj
mut prop index: Int64
```
Index in the heap, -1 means not in the heap

