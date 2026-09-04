# 类
## class MaterialLoader
```cj
public open class MaterialLoader <: Loader
```
材质加载器，加载 JSON 格式的材质数据

### func createMaterialFromType\(String\)
```cj
public open func createMaterialFromType(`type`: String): Material
```
根据类型名创建材质实例

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||

返回: 

- 创建的材质实例

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
开始加载材质

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|材质文件 URLonLoad 加载完成回调onProgress 进度回调onError 错误回调|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

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

### func parse\(HashMap<String,Any>\)
```cj
public open func parse(json: HashMap < String, Any >): Material
```
解析 JSON 对象为 Material

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|JSON 数据|

返回: 

- 材质对象

### func setTextures\(HashMap<String,Texture>\)
```cj
public func setTextures(textures: HashMap < String, Texture >): MaterialLoader
```
设置纹理映射

参数: 

|名称|类型|描述|
|---|---|---|
|textures|HashMap<String,Texture>|纹理映射表|

返回: 

- 自身引用

