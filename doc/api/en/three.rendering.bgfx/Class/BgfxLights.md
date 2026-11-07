# Class
## class BgfxLights
```cj
public class BgfxLights <: IReleasable
```
bgfx light management

### func getCache\(\)
```cj
public func getCache(): LightUniformsCache
```
Gets light uniform cache

Return: 

- Light uniform cache

### func getUniformContainer\(\)
```cj
public func getUniformContainer(): LightUniformContainer
```
Gets multi-light uniform container

Return: 

- Multi-light uniform container

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

### func release\(\)
```cj
public func release(): Bool
```
dispose all light caches

### func reset\(\)
```cj
public func reset(): Unit
```
Resets uniform container

