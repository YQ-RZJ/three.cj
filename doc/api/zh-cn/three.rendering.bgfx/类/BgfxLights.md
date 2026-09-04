# 类
## class BgfxLights
```cj
public class BgfxLights
```
bgfx 光照管理

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有光照缓存

### func getCache\(\)
```cj
public func getCache(): LightUniformsCache
```
获取光照 uniform 缓存

返回: 

- 光照 uniform 缓存

### func getUniformContainer\(\)
```cj
public func getUniformContainer(): LightUniformContainer
```
获取多光源 uniform 容器

返回: 

- 多光源 uniform 容器

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func reset\(\)
```cj
public func reset(): Unit
```
重置 uniform 容器

