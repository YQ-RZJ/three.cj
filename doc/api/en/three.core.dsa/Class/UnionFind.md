# Class
## class UnionFind
```cj
public class UnionFind
```
Union-Find

### func connected\(Int64,Int64\)
```cj
public func connected(a: Int64, b: Int64): Bool
```
Whether two elements belong to the same set

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Int64|Element indexb Element index|
|b|Int64||

Return: 

- Whether they are in the same set

### func find\(Int64\)
```cj
public func find(x: Int64): Int64
```
Finds the representative of the set containing an element (path compression)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Int64|Element index|

Return: 

- Representative index

### func init\(\)
```cj
public init()
```
Constructs an empty union-find

### func init\(Int64\)
```cj
public init(size: Int64)
```
Constructs a union-find with the given number of elements

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Int64|Number of elements (indices 0..size-1)|

### func makeSet\(\)
```cj
public func makeSet(): Int64
```
Adds an element (as its own set) and returns its index

Return: 

- Index of the new element

### func reset\(Int64\)
```cj
public func reset(size: Int64): Unit
```
Resets to the given number of elements (each in its own set)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Int64|Number of elements|

### func union\(Int64,Int64\)
```cj
public func union(a: Int64, b: Int64): Bool
```
Merges the sets containing two elements (union by rank)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|a|Int64|Element indexb Element index|
|b|Int64||

Return: 

- True when the merge joined two distinct sets

### prop componentCount: Int64
```cj
public prop componentCount: Int64
```
Number of connected components

### prop size: Int64
```cj
public prop size: Int64
```
Number of elements

