# 类
## class BgfxEnvironments
```cj
public class BgfxEnvironments
```
bgfx 环境贴图管理

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
释放所有环境贴图

### func dispose\(Int64\)
```cj
public func dispose(textureId: Int64): Unit
```
释放环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|textureId|Int64|纹理 ID|

### func get\(Int64,Bool\)
```cj
public func get(textureId: Int64, usePMREM: Bool): EnvironmentInfo
```
获取环境贴图

参数: 

|名称|类型|描述|
|---|---|---|
|textureId|Int64|纹理 IDusePMREM 是否使用 PMREM|
|usePMREM|Bool||

返回: 

- 环境贴图信息

### func init\(\)
```cj
public init()
```


