# 类
## class MTLLoader
```cj
public class MTLLoader <: Loader
```
MTL 加载器，加载 Wavefront MTL 格式的材质库

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
开始加载 MTL 文件

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|材质文件路径onLoad 加载完成回调，参数为 MaterialCreatoronProgress 进度回调onError 错误回调|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parse\(String,String\)
```cj
public func parse(text: String, path: String): MaterialCreator
```
解析 MTL 文本为 MaterialCreator

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|MTL 文本内容path 资源基础路径|
|path|String||

返回: 

- MaterialCreator

### var materialOptions
```cj
public var materialOptions: Option < HashMap < String, Any >>
```
材质选项（暂支持 None）

