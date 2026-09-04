# 类
## class BgfxMaterials
```cj
public class BgfxMaterials
```
bgfx 材质管理

### func disposeAll\(\)
```cj
public func disposeAll(): Unit
```
释放所有材质状态

### func dispose\(Int64\)
```cj
public func dispose(materialId: Int64): Unit
```
释放材质状态

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 ID|

### func getMaterialState\(Int64\)
```cj
public func getMaterialState(materialId: Int64): MaterialState
```
获取或创建材质状态

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 ID|

返回: 

- 材质状态

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func markNeedsUpdate\(Int64\)
```cj
public func markNeedsUpdate(materialId: Int64): Unit
```
标记材质需要更新

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 ID|

### func markUpdated\(Int64\)
```cj
public func markUpdated(materialId: Int64): Unit
```
标记材质已更新

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 ID|

### func needsUpdate\(Int64\)
```cj
public func needsUpdate(materialId: Int64): Bool
```
检查材质是否需要更新

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 ID|

返回: 

- 是否需要更新

