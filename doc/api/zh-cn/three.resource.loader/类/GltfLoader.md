# 类
## class GltfLoader
```cj
public class GltfLoader <: Loader
```
glTF 加载器，加载 .gltf / .glb 格式的 3D 模型

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
|url|String|模型文件 URL|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 Scene|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

### func parseGlb\(Array<UInt8>\)
```cj
public func parseGlb(data: Array < UInt8 >):(HashMap < String, Any >, Array < UInt8 >)
```
=========================================================================

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>||

### func parseJsonToHashMap\(String\)
```cj
public func parseJsonToHashMap(jsonStr: String): HashMap < String, Any >
```
=========================================================================

参数: 

|名称|类型|描述|
|---|---|---|
|jsonStr|String||

### func parse\(HashMap<String,Any>,Array<UInt8>,String\)
```cj
public func parse(json: HashMap < String, Any >, binData: Array < UInt8 >, basePath: String): Group
```


参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|glTF JSON 数据|
|binData|Array<UInt8>|GLB 文件的二进制块数据|
|basePath|String|基础路径|

返回: 

- Group 包含加载的网格

