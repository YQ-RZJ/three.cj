# 类
## class UnionFind
```cj
public class UnionFind
```
并查集

### func connected\(Int64,Int64\)
```cj
public func connected(a: Int64, b: Int64): Bool
```
判断两个元素是否属于同一集合

参数: 

|名称|类型|描述|
|---|---|---|
|a|Int64|元素下标b 元素下标|
|b|Int64||

返回: 

- 是否同属一个集合

### func find\(Int64\)
```cj
public func find(x: Int64): Int64
```
查找元素所属集合的代表元（路径压缩）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Int64|元素下标|

返回: 

- 代表元下标

### func init\(\)
```cj
public init()
```
构造空的并查集

### func init\(Int64\)
```cj
public init(size: Int64)
```
构造指定元素个数的并查集

参数: 

|名称|类型|描述|
|---|---|---|
|size|Int64|元素个数（下标 0..size-1）|

### func makeSet\(\)
```cj
public func makeSet(): Int64
```
新增一个元素（自成一个集合），返回其下标

返回: 

- 新元素下标

### func reset\(Int64\)
```cj
public func reset(size: Int64): Unit
```
重置为指定元素个数（全部自成一个集合）

参数: 

|名称|类型|描述|
|---|---|---|
|size|Int64|元素个数|

### func union\(Int64,Int64\)
```cj
public func union(a: Int64, b: Int64): Bool
```
合并两个元素所属的集合（按秩合并）

参数: 

|名称|类型|描述|
|---|---|---|
|a|Int64|元素下标b 元素下标|
|b|Int64||

返回: 

- 合并发生在不同集合时返回 true

### prop componentCount: Int64
```cj
public prop componentCount: Int64
```
连通分量数量

### prop size: Int64
```cj
public prop size: Int64
```
元素个数

