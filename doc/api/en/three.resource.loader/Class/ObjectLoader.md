# Class
## class ObjectLoader
```cj
public open class ObjectLoader <: Loader
```
Object loader, loads JSON format complete scene hierarchy

### func bindLightTargets\(Object3D\)
```cj
public func bindLightTargets(object: Object3D): Unit
```
Bind light targets

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|Scene root object|

### func bindSkeletons\(Object3D,HashMap<String,Skeleton>\)
```cj
public func bindSkeletons(object: Object3D, skeletons: HashMap < String, Skeleton >): Unit
```
Bind skeletons to skinned meshes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|Scene root objectskeletons Skeleton mapping|
|skeletons|HashMap<String,Skeleton>||

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

### func parseGeometries\(Option<Any>,HashMap<String,Shape>\)
```cj
public func parseGeometries(jsonOpt: Option < Any >, shapes: HashMap < String, Shape >): HashMap < String, BufferGeometry >
```
Parse geometries

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Geometry data in JSONshapes Shape mapping|
|shapes|HashMap<String,Shape>||

Return: 

- UUID to BufferGeometry mapping

### func parseImages\(Option<Any>\)
```cj
public func parseImages(jsonOpt: Option < Any >): HashMap < String, Source >
```
Parse images

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Image data in JSON|

Return: 

- UUID to Source mapping

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

### func parseObject\(Option<Any>,HashMap<String,BufferGeometry>,HashMap<String,Material>,HashMap<String,Texture>,HashMap<String,AnimationClip>\)
```cj
public func parseObject(dataOpt: Option < Any >, geometries: HashMap < String, BufferGeometry >, materials: HashMap < String, Material >, textures: HashMap < String, Texture >, animations: HashMap < String, AnimationClip >): Object3D
```
Parse object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dataOpt|Option<Any>|Object data in JSONgeometries Geometry mappingmaterials Material mappingtextures Texture mappinganimations Animation mapping|
|geometries|HashMap<String,BufferGeometry>||
|materials|HashMap<String,Material>||
|textures|HashMap<String,Texture>||
|animations|HashMap<String,AnimationClip>||

Return: 

- Parsed 3D object

### func parseShapes\(Option<Any>\)
```cj
public func parseShapes(jsonOpt: Option < Any >): HashMap < String, Shape >
```
Parse shapes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Shape data in JSON|

Return: 

- UUID to Shape mapping

### func parseSkeletons\(Option<Any>,Object3D\)
```cj
public func parseSkeletons(jsonOpt: Option < Any >, object: Object3D): HashMap < String, Skeleton >
```
Parse skeletons

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonOpt|Option<Any>|Skeleton data in JSONobject Scene root object (for finding bone nodes)|
|object|Object3D||

Return: 

- UUID to Skeleton mapping

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

