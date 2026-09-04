# Class
## class TextureLoader
```cj
public class TextureLoader <: Loader
```
Texture loader, loads images and creates Texture objects

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
Start loading texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Image file pathonLoad Load complete callback, parameter is TextureonProgress Progress callbackonError Error callback|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

