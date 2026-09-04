# 类
## class MaterialCreator
```cj
public class MaterialCreator <: ILoadResult
```
材质创建器：持有 MTL 解析出的材质信息，按名称懒创建材质

### func create\(String\)
```cj
public func create(name: String): Option < Material >
```
按名称创建材质（缓存复用）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|材质名|

返回: 

- Option<Material>，未找到返回 None

### func init\(String\)
```cj
public init(baseUrl: String)
```


参数: 

|名称|类型|描述|
|---|---|---|
|baseUrl|String||

### func setCrossOrigin\(String\)
```cj
public func setCrossOrigin(value: String): MaterialCreator
```
设置跨域

参数: 

|名称|类型|描述|
|---|---|---|
|value|String|跨域值|

返回: 

- 自身引用

### func setManager\(LoadingManager\)
```cj
public func setManager(value: LoadingManager): MaterialCreator
```
设置加载管理器

参数: 

|名称|类型|描述|
|---|---|---|
|value|LoadingManager|加载管理器|

返回: 

- 自身引用

### func setMaterials\(HashMap<String,Any>\)
```cj
public func setMaterials(materialsInfo: HashMap < String, Any >): MaterialCreator
```
设置材质信息字典

参数: 

|名称|类型|描述|
|---|---|---|
|materialsInfo|HashMap<String,Any>|材质信息字典|

返回: 

- 自身引用

### var baseUrl
```cj
public var baseUrl: String
```
资源基础路径

### var crossOrigin
```cj
public var crossOrigin: String
```
跨域设置

### var manager
```cj
public var manager: LoadingManager
```
加载管理器

### var materialsInfo
```cj
public var materialsInfo: HashMap < String, Any >
```
材质信息字典（name → info HashMap）

### var materials
```cj
public var materials: HashMap < String, Material >
```
已创建材质缓存（name → Material）

