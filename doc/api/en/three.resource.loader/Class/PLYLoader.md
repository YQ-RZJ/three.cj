# Class
## class PLYLoader
```cj
public class PLYLoader <: Loader
```
PLY loader, loads Stanford PLY format point clouds/meshes

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
Start loading PLY file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Model file pathonLoad Load complete callback, parameter is BufferGeometryonProgress Progress callbackonError Error callback|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parse\(Array<UInt8>\)
```cj
public func parse(data: Array < UInt8 >): BufferGeometry
```
Parse PLY byte data into BufferGeometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|PLY file bytes|

Return: 

- BufferGeometry

