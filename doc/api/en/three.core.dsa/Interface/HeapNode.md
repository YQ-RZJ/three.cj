# Interface
## interface HeapNode
```cj
public interface HeapNode
```
Heap node interface

### func lessThan\(HeapNode\)
```cj
func lessThan(other: HeapNode): Bool
```
Comparison function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|HeapNode|Another node|

Return: 

- true means this has higher priority than other (should be placed ahead)

### prop index: Int64
```cj
mut prop index: Int64
```
Index in the heap, -1 means not in the heap

