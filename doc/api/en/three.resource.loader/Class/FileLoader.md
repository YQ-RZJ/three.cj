# Class
## class FileLoader
```cj
public class FileLoader <: Loader
```
File loader for loading files via the local file system

### func init\(LoadingManager\)
```cj
public init(manager: LoadingManager)
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
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|File path (relative or absolute)|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter type determined by responseType|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载文件使用 std.fs.File.readFrom 读取本地文件内容支持特性：Cache 缓存、manager.resolveURL、path 拼接、responseType 转换不支持的特性：fetch/AbortController/ReadableStream/ProgressEvent（浏览器专用）|

### func setMimeType\(String\)
```cj
public func setMimeType(mimeType: String): FileLoader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|mimeType|String|MIME type string|

Return: 

- Self reference设置 MIME 类型

### func setResponseType\(String\)
```cj
public func setResponseType(responseType: String): FileLoader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|responseType|String|Response type string|

Return: 

- Self reference设置响应类型

### var mimeType
```cj
public var mimeType: String
```
MIME 类型（用于 document 响应类型）

### var responseType
```cj
public var responseType: String
```
响应类型（如 "arraybuffer"、"text"、"json"、"blob"、"document"）

