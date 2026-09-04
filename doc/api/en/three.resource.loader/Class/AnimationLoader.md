# Class
## class AnimationLoader
```cj
public class AnimationLoader <: Loader
```
Animation loader, loads JSON-format animation clip files

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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Animation file URL|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is Array<AnimationClip>|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载动画JS 内部使用 FileLoader 加载文本，然后调用 scope.parse(JSON.parse(text))|

### func parseJsonToArray\(String\)
```cj
public func parseJsonToArray(jsonStr: String): Array < HashMap < String, Any >>
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonStr|String|JSON string|

Return: 

- Parsed Array<HashMap<String, Any>>使用 cjfast_json 将 JSON 字符串解析为 Array<HashMap<String, Any>>对应 JS: JSON.parse(text)

### func parse\(Array<HashMap<String,Any>>\)
```cj
public func parse(json: Array < HashMap < String, Any >>): ArrayList < AnimationClip >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|Array<HashMap<String,Any>>|JSON data|

Return: 

- Animation clip array解析 JSON 对象为动画剪辑数组

