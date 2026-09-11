# Class
## class MTLLoader
```cj
public class MTLLoader <: Loader
```
MTL material definition loader

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
Start loading MTL file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Material file pathonLoad Load complete callback, parameter is MaterialCreatoronProgress Progress callbackonError Error callback|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parse\(String,String\)
```cj
public func parse(text: String, path: String): MaterialCreator
```
Parse MTL text into MaterialCreator

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|MTL text contentpath Resource base path|
|path|String||

Return: 

- MaterialCreator

### var materialOptions
```cj
public var materialOptions: Option < HashMap < String, Any >>
```
Material options (only None is currently supported)

