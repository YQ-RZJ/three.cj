# 类
## class Loader
```cj
public open class Loader
```
加载器抽象基类

### func abort\(\)
```cj
public open func abort(): Loader
```


返回: 

- 自身引用

### func init\(LoadingManager\)
```cj
public init(manager!: LoadingManager)
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|url|String|资源 URL|
|onLoad|(ILoadResult)->Unit|加载完成回调|
|onProgress|(Int64)->Unit|加载进度回调|
|onError|(String)->Unit|加载错误回调|

### func setCrossOrigin\(String\)
```cj
public func setCrossOrigin(crossOrigin: String): Loader
```


参数: 

|名称|类型|描述|
|---|---|---|
|crossOrigin|String|跨域值|

返回: 

- 自身引用

### func setPath\(String\)
```cj
public func setPath(path: String): Loader
```


参数: 

|名称|类型|描述|
|---|---|---|
|path|String|路径|

返回: 

- 自身引用（链式调用）

### func setRequestHeader\(HashMap<String,Any>\)
```cj
public func setRequestHeader(requestHeader: HashMap < String, Any >): Loader
```


参数: 

|名称|类型|描述|
|---|---|---|
|requestHeader|HashMap<String,Any>|请求头对象|

返回: 

- 自身引用

### func setResourcePath\(String\)
```cj
public func setResourcePath(resourcePath: String): Loader
```


参数: 

|名称|类型|描述|
|---|---|---|
|resourcePath|String|资源路径|

返回: 

- 自身引用

### func setWithCredentials\(Bool\)
```cj
public func setWithCredentials(withCredentials: Bool): Loader
```


参数: 

|名称|类型|描述|
|---|---|---|
|withCredentials|Bool|是否带凭据|

返回: 

- 自身引用

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

