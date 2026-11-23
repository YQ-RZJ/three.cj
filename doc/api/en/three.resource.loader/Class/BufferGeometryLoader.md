# Class
## class BufferGeometryLoader
```cj
public class BufferGeometryLoader <: Loader
```
Buffer geometry loader, loads JSON-format BufferGeometry data

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
|url|String|Geometry file URL|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is BufferGeometry|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载几何体仓颉侧：使用 cjfast_json 将加载到的 JSON 文本解析为 HashMap<String, Any>，再解析为 BufferGeometry 后回调|

### func parseJsonToHashMap\(String\)
```cj
public func parseJsonToHashMap(jsonStr: String): HashMap < String, Any >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonStr|String|JSON string|

Return: 

- Parsed HashMap<String, Any>使用 cjfast_json 将 JSON 字符串解析为 HashMap<String, Any>

### func parse\(HashMap<String,Any>\)
```cj
public func parse(json: HashMap < String, Any >): BufferGeometry
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|JSON data|

Return: 

- BufferGeometry解析 JSON 对象为 BufferGeometry解析 JSON 几何体数据依次解析：index → attributes（含 InterleavedBufferAttribute/InstancedBufferAttribute）→ morphAttributes → morphTargetsRelative → groups → boundingSphere → name/userData

