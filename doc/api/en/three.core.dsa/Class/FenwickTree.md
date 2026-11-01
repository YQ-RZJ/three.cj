# Class
## class FenwickTree
```cj
public class FenwickTree
```
Fenwick tree

### func add\(Int64,Int64\)
```cj
public func add(index: Int64, delta: Int64): Unit
```
Point increment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index (1..n)delta Delta|
|delta|Int64||

### func init\(\)
```cj
public init()
```
Constructs an empty tree

### func init\(Int64\)
```cj
public init(size: Int64)
```
Constructs a tree with the given number of elements (all zero)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Int64|Number of elements|

### func lowerBound\(Int64\)
```cj
public func lowerBound(target: Int64): Int64
```
Binary-searches the smallest index whose prefix sum is at least target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Int64|Target prefix sum|

Return: 

- The smallest index whose prefix sum is >= target; n+1 if the total is insufficient

### func prefixSum\(Int64\)
```cj
public func prefixSum(index: Int64): Int64
```
Prefix sum over [1, index]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Upper bound (1..n)|

Return: 

- The prefix sum

### func query\(Int64\)
```cj
public func query(index: Int64): Int64
```
Queries the value at a single position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index (1..n)|

Return: 

- The current value at that position

### func rangeSum\(Int64,Int64\)
```cj
public func rangeSum(left: Int64, right: Int64): Int64
```
Range sum over [left, right]

Parameter: 

|Name|Type|Describe|
|---|---|---|
|left|Int64|Left bound (1..n)right Right bound (1..n)|
|right|Int64||

Return: 

- The range sum

### func reset\(Int64\)
```cj
public func reset(size: Int64): Unit
```
Resets to the given number of elements (all zero)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Int64|Number of elements|

### prop size: Int64
```cj
public prop size: Int64
```
Number of elements

