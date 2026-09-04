# Class
## class MaterialLoader
```cj
public open class MaterialLoader <: Loader
```
Material loader, loads JSON format materials

### func createMaterialFromType\(String\)
```cj
public open func createMaterialFromType(`type`: String): Material
```
Create material instance by type name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String||

Return: 

- Created material instance

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
Start loading material

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Material file URLonLoad Load complete callbackonProgress Progress callbackonError Error callback|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parseJsonToHashMap\(String\)
```cj
public func parseJsonToHashMap(jsonStr: String): HashMap < String, Any >
```
Parse JSON string into HashMap using cjfast_json

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonStr|String|JSON string|

Return: 

- Parsed HashMap

### func parse\(HashMap<String,Any>\)
```cj
public open func parse(json: HashMap < String, Any >): Material
```
Parse JSON object into Material

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|JSON data|

Return: 

- Material object

### func setTextures\(HashMap<String,Texture>\)
```cj
public func setTextures(textures: HashMap < String, Texture >): MaterialLoader
```
Set texture mapping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textures|HashMap<String,Texture>|Texture mapping table|

Return: 

- Self reference

