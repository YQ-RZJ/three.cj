# 类
## class FenwickTree
```cj
public class FenwickTree
```
树状数组

### func add\(Int64,Int64\)
```cj
public func add(index: Int64, delta: Int64): Unit
```
单点增量

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|下标（1..n）delta 增量|
|delta|Int64||

### func init\(\)
```cj
public init()
```
构造空树

### func init\(Int64\)
```cj
public init(size: Int64)
```
构造指定元素个数的树（初值全 0）

参数: 

|名称|类型|描述|
|---|---|---|
|size|Int64|元素个数|

### func lowerBound\(Int64\)
```cj
public func lowerBound(target: Int64): Int64
```
二分查找最小的、其前缀和不小于 target 的下标

参数: 

|名称|类型|描述|
|---|---|---|
|target|Int64|目标前缀和|

返回: 

- 满足前缀和 >= target 的最小下标；总和不足时返回 n+1

### func prefixSum\(Int64\)
```cj
public func prefixSum(index: Int64): Int64
```
前缀和 [1, index]

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|上界（1..n）|

返回: 

- 前缀和

### func query\(Int64\)
```cj
public func query(index: Int64): Int64
```
查询单点的值

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|下标（1..n）|

返回: 

- 该位置当前的值

### func rangeSum\(Int64,Int64\)
```cj
public func rangeSum(left: Int64, right: Int64): Int64
```
区间和 [left, right]

参数: 

|名称|类型|描述|
|---|---|---|
|left|Int64|左界（1..n）right 右界（1..n）|
|right|Int64||

返回: 

- 区间和

### func reset\(Int64\)
```cj
public func reset(size: Int64): Unit
```
重置为指定元素个数（初值全 0）

参数: 

|名称|类型|描述|
|---|---|---|
|size|Int64|元素个数|

### prop size: Int64
```cj
public prop size: Int64
```
元素个数

