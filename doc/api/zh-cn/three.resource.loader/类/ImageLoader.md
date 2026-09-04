# 类
## class ImageLoader
```cj
public class ImageLoader <: Loader
```
图片加载器，用于加载图片资源

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
|url|String|图片文件路径|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 Source（data=RGBA8 像素、width/height 尺寸）|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

