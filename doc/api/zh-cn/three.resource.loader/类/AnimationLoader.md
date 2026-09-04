# 类
## class AnimationLoader
```cj
public class AnimationLoader <: Loader
```
动画加载器，加载 JSON 格式的动画剪辑文件

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


参数: 

|名称|类型|描述|
|---|---|---|
|url|String|动画文件 URL|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 Array<AnimationClip>|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

### func parseJsonToArray\(String\)
```cj
public func parseJsonToArray(jsonStr: String): Array < HashMap < String, Any >>
```


参数: 

|名称|类型|描述|
|---|---|---|
|jsonStr|String|JSON 字符串|

返回: 

- 解析后的 Array<HashMap<String, Any>>

### func parse\(Array<HashMap<String,Any>>\)
```cj
public func parse(json: Array < HashMap < String, Any >>): ArrayList < AnimationClip >
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|Array<HashMap<String,Any>>|JSON 数据|

返回: 

- 动画剪辑数组

