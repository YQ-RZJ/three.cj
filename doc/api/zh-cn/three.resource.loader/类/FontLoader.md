# 类
## class FontLoader
```cj
public class FontLoader <: Loader
```
字体加载器，加载 JSON 格式的字体文件

### func init\(LoadingManager\)
```cj
public init(manager!: LoadingManager = LoadingManager())
```


参数: 

|名称|类型|描述|
|---|---|---|
|manager|LoadingManager||

### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|url|String|字体文件路径|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 JSON 字符串|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

