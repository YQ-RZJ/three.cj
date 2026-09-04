# 类
## class LoadingManager
```cj
public class LoadingManager
```
加载管理器，跟踪已加载项目并提供回调

### func addHandler\(String,Loader\)
```cj
public func addHandler(regex: String, loader: Loader): LoadingManager
```
添加正则匹配的处理器

参数: 

|名称|类型|描述|
|---|---|---|
|regex|String|正则表达式模式loader 对应的加载器|
|loader|Loader||

返回: 

- 自身引用

### func getHandler\(String\)
```cj
public func getHandler(file: String): Option < Loader >
```
根据文件名查找匹配的处理加载器

参数: 

|名称|类型|描述|
|---|---|---|
|file|String|文件名|

返回: 

- 匹配的加载器（无匹配时返回 None）

### func init\(Option<\(\)\->Unit>,Option<\(String,Int64,Int64\)\->Unit>,Option<\(String\)\->Unit>\)
```cj
public init(onLoad!: Option <() -> Unit >= None, onProgress!: Option <(String, Int64, Int64) -> Unit >= None, onError!: Option <(String) -> Unit >= None)
```


参数: 

|名称|类型|描述|
|---|---|---|
|onLoad|Option<()->Unit>||
|onProgress|Option<(String,Int64,Int64)->Unit>||
|onError|Option<(String)->Unit>||

### func itemEnd\(String\)
```cj
public func itemEnd(url: String): Unit
```
标记一个项目加载完成

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|项目 URL|

### func itemError\(String\)
```cj
public func itemError(url: String): Unit
```
标记一个项目加载出错

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|项目 URL|

### func itemStart\(String\)
```cj
public func itemStart(url: String): Unit
```
标记一个项目开始加载

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|项目 URL|

### func resolveURL\(String\)
```cj
public func resolveURL(url: String): String
```
通过 URL 修改器解析 URL

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|原始 URL|

返回: 

- 修改后的 URL

### func setURLModifier\(\(String\)\->String\)
```cj
public func setURLModifier(transform:(String) -> String): LoadingManager
```
设置 URL 修改器

参数: 

|名称|类型|描述|
|---|---|---|
|transform|(String)->String|URL 修改函数|

返回: 

- 自身引用

### var onError
```cj
public var onError: Option <(String) -> Unit >
```
加载错误回调

### var onLoad
```cj
public var onLoad: Option <() -> Unit >
```
全部加载完成回调

### var onProgress
```cj
public var onProgress: Option <(String, Int64, Int64) -> Unit >
```
加载进度回调

### var onStart
```cj
public var onStart: Option <(String, Int64, Int64) -> Unit >
```
加载开始回调

