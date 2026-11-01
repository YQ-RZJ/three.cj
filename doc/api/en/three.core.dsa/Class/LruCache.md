# Class
## class LruCache < K, V > where K <: Hashable & Equatable < K >
```cj
public class LruCache < K, V > where K <: Hashable & Equatable < K >
```
Fixed-capacity LRU cache

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the cache

### func contains\(K\)
```cj
public func contains(key: K): Bool
```
Whether the key is present (without changing the recency order)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|K|Key|

Return: 

- Whether the key is present

### func get\(K\)
```cj
public func get(key: K):?V
```
Looks up the value for a key (on a hit the entry moves to the most-recently-used end)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|K|Key|

Return: 

- Some(value) on a hit, None on a miss

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
Constructs an LRU cache

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Capacity limit (<= 0 means unlimited)|

### func init\(\)
```cj
public init()
```
Constructs an LRU cache with unlimited capacity

### func isEmpty\(\)
```cj
public func isEmpty(): Bool
```
Whether the cache is empty

### func peek\(K\)
```cj
public func peek(key: K):?V
```
Looks up the value for a key without changing the recency order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|K|Key|

Return: 

- Some(value) on a hit, None on a miss

### func put\(K,V\)
```cj
public func put(key: K, value: V): Unit
```
Puts a key/value pair (an existing key is updated and moved to the most-recently-used end)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|K|Keyvalue Value|
|value|V||

### func remove\(K\)
```cj
public func remove(key: K):?V
```
Removes the given key

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|K|Key|

Return: 

- The removed value (None if the key was absent)

### func resetStats\(\)
```cj
public func resetStats(): Unit
```
Resets the statistics counters (hits/misses/evictions)

### func setCapacity\(Int64\)
```cj
public func setCapacity(value: Int64): Unit
```
Sets the capacity limit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|New capacity (<= 0 means unlimited)|

### prop capacity: Int64
```cj
public prop capacity: Int64
```
Capacity limit

### prop evictions: Int64
```cj
public prop evictions: Int64
```
Total number of evictions

### prop hits: Int64
```cj
public prop hits: Int64
```
Number of hits

### prop misses: Int64
```cj
public prop misses: Int64
```
Number of misses

### prop size: Int64
```cj
public prop size: Int64
```
Current number of entries

