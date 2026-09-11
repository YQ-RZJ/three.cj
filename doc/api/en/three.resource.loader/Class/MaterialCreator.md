# Class
## class MaterialCreator
```cj
public class MaterialCreator <: ILoadResult
```
Material creator: holds material info parsed from MTL, lazily creates materials by name

### func create\(String\)
```cj
public func create(name: String): Option < Material >
```
Create material by name (cached)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Material name|

Return: 

- Option<Material>, returns None if not found

### func init\(String\)
```cj
public init(baseUrl: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|baseUrl|String||

### func setCrossOrigin\(String\)
```cj
public func setCrossOrigin(value: String): MaterialCreator
```
Set cross-origin

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|String|Cross-origin value|

Return: 

- Self reference

### func setManager\(LoadingManager\)
```cj
public func setManager(value: LoadingManager): MaterialCreator
```
Set loading manager

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|LoadingManager|Loading manager|

Return: 

- Self reference

### func setMaterials\(HashMap<String,Any>\)
```cj
public func setMaterials(materialsInfo: HashMap < String, Any >): MaterialCreator
```
Set material info dictionary

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialsInfo|HashMap<String,Any>|Material info dictionary|

Return: 

- Self reference

### var baseUrl
```cj
public var baseUrl: String
```
Base URL of the resources

### var crossOrigin
```cj
public var crossOrigin: String
```
Cross-origin setting

### var manager
```cj
public var manager: LoadingManager
```
Loading manager

### var materialsInfo
```cj
public var materialsInfo: HashMap < String, Any >
```
Material info dictionary (name -> info HashMap)

### var materials
```cj
public var materials: HashMap < String, Material >
```
Cache of created materials (name -> Material)

