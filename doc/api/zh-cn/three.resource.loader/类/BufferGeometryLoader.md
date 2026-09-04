# 类
## class BufferGeometryLoader
```cj
public class BufferGeometryLoader <: Loader
```
几何体加载器，加载 JSON 格式的 BufferGeometry 数据

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
|url|String|几何体文件 URL|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 BufferGeometry|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

### func parseJsonToHashMap\(String\)
```cj
public func parseJsonToHashMap(jsonStr: String): HashMap < String, Any >
```


参数: 

|名称|类型|描述|
|---|---|---|
|jsonStr|String|JSON 字符串|

返回: 

- 解析后的 HashMap<String, Any>

### func parse\(HashMap<String,Any>\)
```cj
public func parse(json: HashMap < String, Any >): BufferGeometry
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|JSON 数据|

返回: 

- BufferGeometry

