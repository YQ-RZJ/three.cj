# Class
## class FontLoader
```cj
public class FontLoader <: Loader
```
Font loader, loads JSON-format font files

### func init\(LoadingManager\)
```cj
public init(manager!: LoadingManager = LoadingManager())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|manager|LoadingManager||

### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Font file path|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is JSON string|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载字体使用 std.fs.File.readFrom 读取字体 JSON 文件|

