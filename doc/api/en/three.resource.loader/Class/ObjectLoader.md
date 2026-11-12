# Class
## class ObjectLoader
```cj
public open class ObjectLoader <: Loader
```
Object loader, loads JSON format complete scene hierarchy

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
Start loading scene object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Scene file pathonLoad Load complete callbackonProgress Progress callbackonError Error callback|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parseAnimations\(Option<Any>\)
```cj
public func parseAnimations(jsonOpt: Option < Any >): HashMap < String, AnimationClip >
```
Parse animations

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Animation data in JSON|

Return: 

- UUID to AnimationClip mapping

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

### func parseMaterials\(Option<Any>,HashMap<String,Texture>\)
```cj
public open func parseMaterials(jsonOpt: Option < Any >, textures: HashMap < String, Texture >): HashMap < String, Material >
```
Parse materials

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Material data in JSONtextures Texture mapping|
|textures|HashMap<String,Texture>||

Return: 

- UUID to Material mapping

### func parseTextures\(Option<Any>,HashMap<String,Source>\)
```cj
public func parseTextures(jsonOpt: Option < Any >, images: HashMap < String, Source >): HashMap < String, Texture >
```
Parse textures

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Texture data in JSONimages Image mapping|
|images|HashMap<String,Source>||

Return: 

- UUID to Texture mapping

### func parse\(HashMap<String,Any>,\(ILoadResult\)\->Unit\)
```cj
public open func parse(json: HashMap < String, Any >, onLoad:(ILoadResult) -> Unit): Unit
```
Parse JSON object into scene object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|JSON dataonLoad Load complete callback|
|onLoad|(ILoadResult)->Unit||

### func setTextures\(HashMap<String,Texture>\)
```cj
public func setTextures(textures: HashMap < String, Texture >): ObjectLoader
```
Set texture mapping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textures|HashMap<String,Texture>|Texture mapping table|

Return: 

- Self reference

