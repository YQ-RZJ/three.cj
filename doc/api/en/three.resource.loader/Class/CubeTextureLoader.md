# Class
## class CubeTextureLoader
```cj
public class CubeTextureLoader <: Loader
```
Cube texture loader, loads 6 images to form a cube texture

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


### func load\(Array<String>,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public func load(urls: Array < String >, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): CubeTexture
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|urls|Array<String>|Array of 6 face file paths (order: pos-x, neg-x, pos-y, neg-y, pos-z, neg-z)|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is CubeTexture|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback|

Return: 

- CubeTexture object开始加载立方体贴图使用 std.fs.File.readFrom 读取 6 面图片文件，全部 6 面加载完成后以 images 数组构造 CubeTexture。

