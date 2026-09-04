# Class
## class ImageLoader
```cj
public class ImageLoader <: Loader
```
Image loader, for loading image resources

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
|url|String|Image file path|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is Source (data=RGBA8 pixels, width/height dimensions)|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载图片使用 std.fs.File.readFrom 读取图片文件，并用 bimg 解码为 RGBA8|

