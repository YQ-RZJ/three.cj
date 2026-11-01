# Class
## class AssetCache
```cj
public class AssetCache
```
Ref-counted asset cache

### func acquire\(String\)
```cj
public func acquire(key: String): Option < ILoadResult >
```
Gets a resource and acquires one reference (None when absent)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key|

Return: 

- Cached resource; ref count incremented by 1

### func add\(String,ILoadResult\)
```cj
public func add(key: String, resource: ILoadResult): Unit
```
Adds a resource to the cache (initial ref count 0)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key (usually a URL or bundle entry name)resource Load result|
|resource|ILoadResult||

### func advanceFrame\(\)
```cj
public func advanceFrame(): Unit
```
Advances the logical frame per frame (called by AssetManager.update, or manually)

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the whole cache (ignores ref counts)

### func collectIfNeeded\(Int64\)
```cj
public func collectIfNeeded(interval!: Int64 = 60): Int64
```
Lazy collect: runs once every interval frames

Parameter: 

|Name|Type|Describe|
|---|---|---|
|interval|Int64|Collect interval in frames (default 60)|

Return: 

- Evicted count this run (0 when not triggered)

### func collect\(\)
```cj
public func collect(): Int64
```
Evicts all entries with ref count 0

Return: 

- Number of evicted entries

### func get\(String\)
```cj
public func get(key: String): Option < ILoadResult >
```
Gets a cached resource without changing the ref count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key|

Return: 

- Cached resource, or None when absent

### func init\(\)
```cj
public init()
```


### func refCount\(String\)
```cj
public func refCount(key: String): Int64
```
Queries the ref count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key|

Return: 

- Ref count; -1 when absent

### func release\(String\)
```cj
public func release(key: String): Bool
```
Releases one reference (zero-count entries wait for collect)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key|

Return: 

- True when the entry exists and the count was decremented

### func remove\(String\)
```cj
public func remove(key: String): Unit
```
Removes the entry regardless of ref count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key|

### func retain\(String\)
```cj
public func retain(key: String): Bool
```
Manually acquires one reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Resource key|

Return: 

- True when the entry exists and the count was incremented

### prop count: Int64
```cj
public prop count: Int64
```
Number of cached entries

### let shared
```cj
public static let shared: AssetCache = AssetCache()
```
全局共享实例（多数游戏直接使用）

