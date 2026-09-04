# Class
## class GltfLoader
```cj
public class GltfLoader <: Loader
```
glTF loader, loads .gltf / .glb format 3D models

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
|url|String|Model file URL|
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is Scene|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载 glTF 模型|

### func parseGlb\(Array<UInt8>\)
```cj
public func parseGlb(data: Array < UInt8 >):(HashMap < String, Any >, Array < UInt8 >)
```
=========================================================================

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>||

### func parseJsonToHashMap\(String\)
```cj
public func parseJsonToHashMap(jsonStr: String): HashMap < String, Any >
```
=========================================================================

Parameter: 

|Name|Type|Describe|
|---|---|---|
|jsonStr|String||

### func parse\(HashMap<String,Any>,Array<UInt8>,String\)
```cj
public func parse(json: HashMap < String, Any >, binData: Array < UInt8 >, basePath: String): Group
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|json|HashMap<String,Any>|glTF JSON data|
|binData|Array<UInt8>|GLB file binary chunk data|
|basePath|String|Base path|

Return: 

- Group containing loaded meshes解析 glTF JSON 为 Group（包含所有网格和材质）

