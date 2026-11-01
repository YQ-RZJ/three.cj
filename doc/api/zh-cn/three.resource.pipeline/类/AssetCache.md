# 类
## class AssetCache
```cj
public class AssetCache
```
引用计数资源缓存

### func acquire\(String\)
```cj
public func acquire(key: String): Option < ILoadResult >
```
获取资源并持有一次引用（不存在时返回 None）

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键|

返回: 

- 缓存的资源；同时引用计数 +1

### func add\(String,ILoadResult\)
```cj
public func add(key: String, resource: ILoadResult): Unit
```
向缓存添加资源（初始引用计数 0）

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键（通常为 URL 或包内资源名）resource 加载结果|
|resource|ILoadResult||

### func advanceFrame\(\)
```cj
public func advanceFrame(): Unit
```
每帧推进逻辑帧号（由 AssetManager.update 调用，也可手动调用）

### func clear\(\)
```cj
public func clear(): Unit
```
清空全部缓存（无视引用计数）

### func collectIfNeeded\(Int64\)
```cj
public func collectIfNeeded(interval!: Int64 = 60): Int64
```
惰性回收：距上次 collect 超过 interval 帧才执行一次

参数: 

|名称|类型|描述|
|---|---|---|
|interval|Int64|回收间隔（帧数，默认 60）|

返回: 

- 本次执行的回收数量（未触发返回 0）

### func collect\(\)
```cj
public func collect(): Int64
```
回收所有引用计数为 0 的条目

返回: 

- 本次回收的条目数量

### func get\(String\)
```cj
public func get(key: String): Option < ILoadResult >
```
从缓存获取资源（不改变引用计数）

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键|

返回: 

- 缓存的资源，不存在时返回 None

### func init\(\)
```cj
public init()
```


### func refCount\(String\)
```cj
public func refCount(key: String): Int64
```
查询引用计数

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键|

返回: 

- 引用计数；资源不存在返回 -1

### func release\(String\)
```cj
public func release(key: String): Bool
```
释放一次引用（计数归零的条目等待 collect 回收）

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键|

返回: 

- 资源存在并成功 -1 返回 true

### func remove\(String\)
```cj
public func remove(key: String): Unit
```
移除指定条目（无论引用计数）

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键|

### func retain\(String\)
```cj
public func retain(key: String): Bool
```
手动持有一次引用

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|资源键|

返回: 

- 资源存在并成功 +1 返回 true

### prop count: Int64
```cj
public prop count: Int64
```
缓存条目数量

### let shared
```cj
public static let shared: AssetCache = AssetCache()
```
全局共享实例（多数游戏直接使用）

