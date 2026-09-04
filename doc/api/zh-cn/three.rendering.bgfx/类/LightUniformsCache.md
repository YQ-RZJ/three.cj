# 类
## class LightUniformsCache
```cj
public class LightUniformsCache
```
光照 uniform 缓存

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放缓存

### func get\(Int64,String\)
```cj
public func get(lightId: Int64, lightType: String): LightUniformData
```
获取光照 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|lightId|Int64|光源 IDlightType 光源类型名称|
|lightType|String||

返回: 

- 光照 uniform 数据

### func init\(\)
```cj
public init()
```


