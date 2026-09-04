# 类
## class ObjectLoader
```cj
public open class ObjectLoader <: Loader
```
对象加载器，加载 JSON 格式的完整场景层级结构

### func bindLightTargets\(Object3D\)
```cj
public func bindLightTargets(object: Object3D): Unit
```
绑定光源目标

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|场景根对象|

### func bindSkeletons\(Object3D,HashMap<String,Skeleton>\)
```cj
public func bindSkeletons(object: Object3D, skeletons: HashMap < String, Skeleton >): Unit
```
绑定骨骼到蒙皮网格

参数: 

|名称|类型|描述|
|---|---|---|
|object|Object3D|场景根对象skeletons 骨骼映射|
|skeletons|HashMap<String,Skeleton>||

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
开始加载场景对象

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|场景文件路径onLoad 加载完成回调onProgress 进度回调onError 错误回调|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parseAnimations\(Option<Any>\)
```cj
public func parseAnimations(jsonOpt: Option < Any >): HashMap < String, AnimationClip >
```
解析动画

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的动画数据|

返回: 

- UUID 到 AnimationClip 的映射

### func parseGeometries\(Option<Any>,HashMap<String,Shape>\)
```cj
public func parseGeometries(jsonOpt: Option < Any >, shapes: HashMap < String, Shape >): HashMap < String, BufferGeometry >
```
解析几何体

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的几何体数据shapes 形状映射|
|shapes|HashMap<String,Shape>||

返回: 

- UUID 到 BufferGeometry 的映射

### func parseImages\(Option<Any>\)
```cj
public func parseImages(jsonOpt: Option < Any >): HashMap < String, Source >
```
解析图片

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的图片数据|

返回: 

- UUID 到 Source 的映射

### func parseJsonToHashMap\(String\)
```cj
public func parseJsonToHashMap(jsonStr: String): HashMap < String, Any >
```
使用 cjfast_json 将 JSON 字符串解析为 HashMap

参数: 

|名称|类型|描述|
|---|---|---|
|jsonStr|String|JSON 字符串|

返回: 

- 解析后的 HashMap

### func parseMaterials\(Option<Any>,HashMap<String,Texture>\)
```cj
public open func parseMaterials(jsonOpt: Option < Any >, textures: HashMap < String, Texture >): HashMap < String, Material >
```
解析材质

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的材质数据textures 纹理映射|
|textures|HashMap<String,Texture>||

返回: 

- UUID 到 Material 的映射

### func parseObject\(Option<Any>,HashMap<String,BufferGeometry>,HashMap<String,Material>,HashMap<String,Texture>,HashMap<String,AnimationClip>\)
```cj
public func parseObject(dataOpt: Option < Any >, geometries: HashMap < String, BufferGeometry >, materials: HashMap < String, Material >, textures: HashMap < String, Texture >, animations: HashMap < String, AnimationClip >): Object3D
```
解析对象

参数: 

|名称|类型|描述|
|---|---|---|
|dataOpt|Option<Any>|JSON 中的对象数据geometries 几何体映射materials 材质映射textures 纹理映射animations 动画映射|
|geometries|HashMap<String,BufferGeometry>||
|materials|HashMap<String,Material>||
|textures|HashMap<String,Texture>||
|animations|HashMap<String,AnimationClip>||

返回: 

- 解析后的 3D 对象

### func parseShapes\(Option<Any>\)
```cj
public func parseShapes(jsonOpt: Option < Any >): HashMap < String, Shape >
```
解析形状

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的形状数据|

返回: 

- UUID 到 Shape 的映射

### func parseSkeletons\(Option<Any>,Object3D\)
```cj
public func parseSkeletons(jsonOpt: Option < Any >, object: Object3D): HashMap < String, Skeleton >
```
解析骨骼

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的骨骼数据object 场景根对象（用于查找骨骼节点）|
|object|Object3D||

返回: 

- UUID 到 Skeleton 的映射

### func parseTextures\(Option<Any>,HashMap<String,Source>\)
```cj
public func parseTextures(jsonOpt: Option < Any >, images: HashMap < String, Source >): HashMap < String, Texture >
```
解析纹理

参数: 

|名称|类型|描述|
|---|---|---|
|jsonOpt|Option<Any>|JSON 中的纹理数据images 图片映射|
|images|HashMap<String,Source>||

返回: 

- UUID 到 Texture 的映射

### func parse\(HashMap<String,Any>,\(ILoadResult\)\->Unit\)
```cj
public open func parse(json: HashMap < String, Any >, onLoad:(ILoadResult) -> Unit): Unit
```
解析 JSON 对象为场景对象

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|JSON 数据onLoad 加载完成回调|
|onLoad|(ILoadResult)->Unit||

### func setTextures\(HashMap<String,Texture>\)
```cj
public func setTextures(textures: HashMap < String, Texture >): ObjectLoader
```
设置纹理映射

参数: 

|名称|类型|描述|
|---|---|---|
|textures|HashMap<String,Texture>|纹理映射表|

返回: 

- 自身引用

