# 类
## class CubeTextureLoader
```cj
public class CubeTextureLoader <: Loader
```
立方体贴图加载器，加载 6 张图片组成立方体贴图

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


### func load\(Array<String>,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public func load(urls: Array < String >, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): CubeTexture
```


参数: 

|名称|类型|描述|
|---|---|---|
|urls|Array<String>|6 个面的文件路径数组（顺序：pos-x, neg-x, pos-y, neg-y, pos-z, neg-z）|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 CubeTexture|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

返回: 

- CubeTexture 对象

