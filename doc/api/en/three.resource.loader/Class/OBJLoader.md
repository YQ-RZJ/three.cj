# Class
## class OBJLoader
```cj
public class OBJLoader <: Loader
```
OBJ model loader

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
Start loading OBJ file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Model file pathonLoad Load complete callback, parameter is GrouponProgress Progress callbackonError Error callback|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parse\(String\)
```cj
public func parse(text: String): Group
```
Parse OBJ text into Group

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|OBJ text content|

Return: 

- Group containing parsed Meshes

### func setMaterials\(MaterialCreator\)
```cj
public func setMaterials(materials: MaterialCreator): OBJLoader
```
Set material creator

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materials|MaterialCreator|Material creator|

Return: 

- Self reference

### var materials
```cj
public var materials: Option < MaterialCreator >
```


