# Class
## class AssetManager
```cj
public class AssetManager
```
Asset manager

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
Loads file bytes asynchronously

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|File path (relative or absolute)onLoad Success callback with the byte array (runs on main loop thread)onError Failure callback with the error message (runs on main loop thread)storeCache Whether to store the result into cache (default false; combine withretain/release when true)|
|onLoad|(ILoadResult)->Unit||
|onError|(String)->Unit||
|storeCache|Bool||

### func loadFromBundle\(AssetBundle,String,\(ILoadResult\)\->Unit,\(String\)\->Unit\)
```cj
public func loadFromBundle(bundle: AssetBundle, name: String, onLoad:(ILoadResult) -> Unit, onError!:(String) -> Unit = { _ =>
    ()
}): Unit
```
Dispatches one entry from a bundle (in-memory, still via the frame-spread path)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bundle|AssetBundle|The bundlename Bundle entry nameonLoad Success callback (main loop thread)onError Failure callback (main loop thread)|
|name|String||
|onLoad|(ILoadResult)->Unit||
|onError|(String)->Unit||

### func loadText\(String,\(String\)\->Unit,\(String\)\->Unit\)
```cj
public func loadText(url: String, onLoad:(String) -> Unit, onError!:(String) -> Unit = { _ =>
    ()
}): Unit
```
Loads a text file asynchronously (UTF-8)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|File pathonLoad Success callback (main loop thread)onError Failure callback (main loop thread)|
|onLoad|(String)->Unit||
|onError|(String)->Unit||

### func pumpShared\(\)
```cj
public static func pumpShared(): Unit
```
Pumps the global shared instance (called by the engine main loop every frame)

### func update\(Int64,Float64\)
```cj
public func update(maxPerFrame!: Int64 = 4, budgetMs!: Float64 = 2.0): Int64
```
Per-frame dispatch: consumes the completion queue within the time budget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxPerFrame|Int64|Max entries dispatched per frame (default 4)budgetMs Per-frame dispatch time budget in milliseconds (0 = unlimited, default 2.0)|
|budgetMs|Float64||

Return: 

- Entries dispatched this frame

### prop pendingCount: Int64
```cj
public prop pendingCount: Int64
```
Number of completions pending dispatch

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

