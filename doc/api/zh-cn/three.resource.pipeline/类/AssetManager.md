# 类
## class AssetManager
```cj
public class AssetManager
```
资源管理器

### func init\(\)
```cj
public init()
```


### func loadBytes\(String,\(ILoadResult\)\->Unit,\(String\)\->Unit,Bool\)
```cj
public func loadBytes(url: String, onLoad:(ILoadResult) -> Unit, onError!:(String) -> Unit = { _ =>
    ()
}, storeCache!: Bool = false): Unit
```
异步加载文件字节

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|文件路径（相对或绝对）onLoad 成功回调，参数为字节数组（主循环线程执行）onError 失败回调，参数为错误信息（主循环线程执行）storeCache 是否把结果写入 cache（默认 false；true 时可配合 retain/release 管理）|
|onLoad|(ILoadResult)->Unit||
|onError|(String)->Unit||
|storeCache|Bool||

### func loadFromBundle\(AssetBundle,String,\(ILoadResult\)\->Unit,\(String\)\->Unit\)
```cj
public func loadFromBundle(bundle: AssetBundle, name: String, onLoad:(ILoadResult) -> Unit, onError!:(String) -> Unit = { _ =>
    ()
}): Unit
```
从资源包内分发一个条目（内存操作，但仍走分帧回调路径）

参数: 

|名称|类型|描述|
|---|---|---|
|bundle|AssetBundle|资源包name 包内资源名onLoad 成功回调（主循环线程执行）onError 失败回调（主循环线程执行）|
|name|String||
|onLoad|(ILoadResult)->Unit||
|onError|(String)->Unit||

### func loadText\(String,\(String\)\->Unit,\(String\)\->Unit\)
```cj
public func loadText(url: String, onLoad:(String) -> Unit, onError!:(String) -> Unit = { _ =>
    ()
}): Unit
```
异步加载文本文件（UTF-8）

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|文件路径onLoad 成功回调（主循环线程执行）onError 失败回调（主循环线程执行）|
|onLoad|(String)->Unit||
|onError|(String)->Unit||

### func pumpShared\(\)
```cj
public static func pumpShared(): Unit
```
泵全局共享实例（引擎主循环每帧调用）

### func update\(Int64,Float64\)
```cj
public func update(maxPerFrame!: Int64 = 4, budgetMs!: Float64 = 2.0): Int64
```
每帧派发：在时间预算内分帧消费完成队列

参数: 

|名称|类型|描述|
|---|---|---|
|maxPerFrame|Int64|单帧最大派发条目数（默认 4）budgetMs 单帧派发时间预算（毫秒，0 = 不限制，默认 2.0）|
|budgetMs|Float64||

返回: 

- 本帧派发的条目数

### prop pendingCount: Int64
```cj
public prop pendingCount: Int64
```
待派发的完成条目数量

### let cache
```cj
public let cache: AssetCache
```
引用计数缓存（加载结果生命周期管理）

### let shared
```cj
public static let shared: AssetManager = AssetManager()
```
全局共享实例（引擎主循环自动泵该实例）

