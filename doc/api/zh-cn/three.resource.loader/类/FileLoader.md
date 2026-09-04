# 类
## class FileLoader
```cj
public class FileLoader <: Loader
```
文件加载器，用于通过本地文件系统加载文件

### func init\(LoadingManager\)
```cj
public init(manager: LoadingManager)
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
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|url|String|文件路径（相对或绝对路径）|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数类型根据 responseType 决定|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

### func setMimeType\(String\)
```cj
public func setMimeType(mimeType: String): FileLoader
```


参数: 

|名称|类型|描述|
|---|---|---|
|mimeType|String|MIME 类型字符串|

返回: 

- 自身引用

### func setResponseType\(String\)
```cj
public func setResponseType(responseType: String): FileLoader
```


参数: 

|名称|类型|描述|
|---|---|---|
|responseType|String|响应类型字符串|

返回: 

- 自身引用

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

