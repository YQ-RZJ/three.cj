# 类
## class BinaryPatriciaTrie < V >
```cj
public class BinaryPatriciaTrie < V >
```
二进制 Patricia Trie（Radix/压缩前缀树）

### func bitLongestSubset\(Array<UInt8>\)
```cj
public func bitLongestSubset(query: Array < UInt8 >):?(Array < UInt8 >, V)
```
按位子集查询中的"最长匹配"

参数: 

|名称|类型|描述|
|---|---|---|
|query|Array<UInt8>|查询字节数组|

返回: 

- 最长匹配键值对，不存在返回 None

### func bitSubsetOf\(Array<UInt8>,Bool,Bool\)
```cj
public func bitSubsetOf(query: Array < UInt8 >, longestFirst!: Bool = true, includeEmpty!: Bool = false): Array <(Array < UInt8 >, V) >
```
按位（bit）子集查询

参数: 

|名称|类型|描述|
|---|---|---|
|query|Array<UInt8>|查询字节数组longestFirst 是否长的在前（默认 true）includeEmpty 是否包含空键（默认 false）|
|longestFirst|Bool||
|includeEmpty|Bool||

返回: 

- 匹配的键值对数组

### func clear\(\)
```cj
public func clear(): Unit
```
清空树

### func delete\(Array<UInt8>\)
```cj
public func delete(key: Array < UInt8 >): Bool
```
删除指定键

参数: 

|名称|类型|描述|
|---|---|---|
|key|Array<UInt8>||

返回: 

- true 删除成功

### func fBitLongestSubset\(Array<UInt8>\)
```cj
public func fBitLongestSubset(query: Array < UInt8 >):?(Array < UInt8 >, V)
```
按位子集最长匹配（高性能版）

参数: 

|名称|类型|描述|
|---|---|---|
|query|Array<UInt8>|查询字节数组|

返回: 

- 最长匹配键值对，不存在返回 None

### func fBitSubsetOf\(Array<UInt8>,Bool,Bool\)
```cj
public func fBitSubsetOf(query: Array < UInt8 >, longestFirst!: Bool = true, includeEmpty!: Bool = false): Array <(Array < UInt8 >, V) >
```
按位子集查询（高性能版，子掩码枚举 + 剪枝）

参数: 

|名称|类型|描述|
|---|---|---|
|query|Array<UInt8>|查询字节数组longestFirst 是否长的在前（默认 true）includeEmpty 是否包含空键（默认 false）|
|longestFirst|Bool||
|includeEmpty|Bool||

返回: 

- 匹配的键值对数组

### func get\(Array<UInt8>\)
```cj
public func get(key: Array < UInt8 >):?V
```
获取全匹配的值

参数: 

|名称|类型|描述|
|---|---|---|
|key|Array<UInt8>|键|

返回: 

- 值，不存在返回 None

### func has\(Array<UInt8>\)
```cj
public func has(key: Array < UInt8 >): Bool
```
是否存在指定键

参数: 

|名称|类型|描述|
|---|---|---|
|key|Array<UInt8>||

### func init\(\)
```cj
public init()
```


### func longestPrefix\(Array<UInt8>\)
```cj
public func longestPrefix(query: Array < UInt8 >):?(Array < UInt8 >, V)
```
最长前缀匹配：返回"键是 query 的前缀"中的最长者

参数: 

|名称|类型|描述|
|---|---|---|
|query|Array<UInt8>|查询字节|

返回: 

- 最长前缀匹配的键值对，不存在返回 None

### func prefixOf\(Array<UInt8>,Bool,Bool\)
```cj
public func prefixOf(query: Array < UInt8 >, longestFirst!: Bool = true, includeEmpty!: Bool = false): Array <(Array < UInt8 >, V) >
```
模糊搜索（前缀匹配）：返回"所有键是 query 的前缀"的项

参数: 

|名称|类型|描述|
|---|---|---|
|query|Array<UInt8>|查询字节longestFirst 是否长的在前（默认 true）includeEmpty 是否包含空键（默认 false）|
|longestFirst|Bool||
|includeEmpty|Bool||

返回: 

- 匹配的键值对数组

### func set\(Array<UInt8>,V\)
```cj
public func set(key: Array < UInt8 >, value: V): Unit
```
加入新值

参数: 

|名称|类型|描述|
|---|---|---|
|key|Array<UInt8>|键value 值|
|value|V||

### func startsWith\(Array<UInt8>\)
```cj
public func startsWith(prefix: Array < UInt8 >): Array <(Array < UInt8 >, V) >
```
前缀查询：返回所有"键以 prefix 开头"的项

参数: 

|名称|类型|描述|
|---|---|---|
|prefix|Array<UInt8>|前缀|

返回: 

- 匹配的键值对数组

### prop size: Int64
```cj
public prop size: Int64
```
成员数量

