# Class
## class Loader
```cj
public open class Loader
```
Abstract base class for loaders

### func abort\(\)
```cj
public open func abort(): Loader
```


Return: 

- Self reference中止进行中的请求仓颉侧本地文件系统读取为同步操作，无可中止的异步请求，保持默认行为。

### func init\(LoadingManager\)
```cj
public init(manager!: LoadingManager)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|manager|LoadingManager||

### func init\(\)
```cj
public init()
```


### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public open func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Resource URL|
|onLoad|(ILoadResult)->Unit|Load complete callback|
|onProgress|(Int64)->Unit|Load progress callback|
|onError|(String)->Unit|Load error callback加载资源（抽象方法，子类实现）|

### func setCrossOrigin\(String\)
```cj
public func setCrossOrigin(crossOrigin: String): Loader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|crossOrigin|String|Cross-origin value|

Return: 

- Self reference设置跨域设置

### func setPath\(String\)
```cj
public func setPath(path: String): Loader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|Path|

Return: 

- Self reference (for chaining)设置基础路径

### func setRequestHeader\(HashMap<String,Any>\)
```cj
public func setRequestHeader(requestHeader: HashMap < String, Any >): Loader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|requestHeader|HashMap<String,Any>|Request header object|

Return: 

- Self reference设置请求头

### func setResourcePath\(String\)
```cj
public func setResourcePath(resourcePath: String): Loader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|resourcePath|String|Resource path|

Return: 

- Self reference设置资源路径

### func setWithCredentials\(Bool\)
```cj
public func setWithCredentials(withCredentials: Bool): Loader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|withCredentials|Bool|Whether to include credentials|

Return: 

- Self reference设置是否带凭据

### var crossOrigin
```cj
public var crossOrigin: String
```
跨域设置

### var manager
```cj
public var manager: LoadingManager
```
加载管理器

### var path
```cj
public var path: String
```
基础路径

### var requestHeader
```cj
public var requestHeader: HashMap < String, Any >
```
请求头

### var resourcePath
```cj
public var resourcePath: String
```
资源路径

### var withCredentials
```cj
public var withCredentials: Bool
```
是否带凭据

