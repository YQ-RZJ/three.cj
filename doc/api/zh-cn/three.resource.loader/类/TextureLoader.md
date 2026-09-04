# 类
## class TextureLoader
```cj
public class TextureLoader <: Loader
```
纹理加载器，用于加载图片并创建 Texture 对象

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
开始加载纹理

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|图片文件路径onLoad 加载完成回调，参数为 TextureonProgress 进度回调onError 错误回调|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

