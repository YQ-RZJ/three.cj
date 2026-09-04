# 类
## class OBJLoader
```cj
public class OBJLoader <: Loader
```
OBJ 加载器，加载 Wavefront OBJ 格式的 3D 模型

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
开始加载 OBJ 文件

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|模型文件路径onLoad 加载完成回调，参数为 GrouponProgress 进度回调onError 错误回调|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parse\(String\)
```cj
public func parse(text: String): Group
```
解析 OBJ 文本为 Group

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|OBJ 文本内容|

返回: 

- Group 包含解析出的 Mesh

### func setMaterials\(MaterialCreator\)
```cj
public func setMaterials(materials: MaterialCreator): OBJLoader
```
设置材质创建器

参数: 

|名称|类型|描述|
|---|---|---|
|materials|MaterialCreator|材质创建器|

返回: 

- 自身引用

### var materials
```cj
public var materials: Option < MaterialCreator >
```
材质创建器（由 MTLLoader 提供），None 时使用默认材质

