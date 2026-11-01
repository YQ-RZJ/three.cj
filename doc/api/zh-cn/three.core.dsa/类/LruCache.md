# 类
## class LruCache < K, V > where K <: Hashable & Equatable < K >
```cj
public class LruCache < K, V > where K <: Hashable & Equatable < K >
```
定容量 LRU 缓存

### func clear\(\)
```cj
public func clear(): Unit
```
清空缓存

### func contains\(K\)
```cj
public func contains(key: K): Bool
```
是否包含键（不改变使用顺序）

参数: 

|名称|类型|描述|
|---|---|---|
|key|K|键|

返回: 

- 是否包含

### func get\(K\)
```cj
public func get(key: K):?V
```
查询键对应的值（命中时把该条目移到"最近使用"端）

参数: 

|名称|类型|描述|
|---|---|---|
|key|K|键|

返回: 

- 命中返回 Some(值)，未命中返回 None

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
构造 LRU 缓存

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|容量上限（<= 0 表示不限制）|

### func init\(\)
```cj
public init()
```
构造不限容量的 LRU 缓存

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
是否为空

### func peek\(K\)
```cj
public func peek(key: K):?V
```
查询键对应的值但不改变使用顺序

参数: 

|名称|类型|描述|
|---|---|---|
|key|K|键|

返回: 

- 命中返回 Some(值)，未命中返回 None

### func put\(K,V\)
```cj
public func put(key: K, value: V): Unit
```
写入键值对（已存在则更新值并移到"最近使用"端）

参数: 

|名称|类型|描述|
|---|---|---|
|key|K|键value 值|
|value|V||

### func remove\(K\)
```cj
public func remove(key: K):?V
```
移除指定键

参数: 

|名称|类型|描述|
|---|---|---|
|key|K|键|

返回: 

- 被移除的值（不存在则 None）

### func resetStats\(\)
```cj
public func resetStats(): Unit
```
重置统计计数（命中/未命中/淘汰）

### func setCapacity\(Int64\)
```cj
public func setCapacity(value: Int64): Unit
```
设置容量上限

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|新容量（<= 0 表示不限制）|

### prop capacity: Int64
```cj
public prop capacity: Int64
```
容量上限

### prop evictions: Int64
```cj
public prop evictions: Int64
```
累计淘汰次数

### prop hits: Int64
```cj
public prop hits: Int64
```
命中次数

### prop misses: Int64
```cj
public prop misses: Int64
```
未命中次数

### prop size: Int64
```cj
public prop size: Int64
```
当前条目数

