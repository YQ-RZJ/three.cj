# 类
## class ObjectLoader
```cj
public open class ObjectLoader <: Loader
```
对象加载器，加载 JSON 格式的完整场景层级结构

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

