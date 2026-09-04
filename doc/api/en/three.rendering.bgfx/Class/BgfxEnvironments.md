# Class
## class BgfxEnvironments
```cj
public class BgfxEnvironments
```
bgfx environment map management

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
Disposes all environment maps

### func dispose\(Int64\)
```cj
public func dispose(textureId: Int64): Unit
```
Disposes an environment map

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureId|Int64|Texture ID|

### func get\(Int64,Bool\)
```cj
public func get(textureId: Int64, usePMREM: Bool): EnvironmentInfo
```
Gets an environment map

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureId|Int64|Texture IDusePMREM Whether to use PMREM|
|usePMREM|Bool||

Return: 

- Environment map info

### func init\(\)
```cj
public init()
```


