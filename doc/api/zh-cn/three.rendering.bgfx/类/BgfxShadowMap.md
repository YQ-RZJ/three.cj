# 类
## class BgfxShadowMap
```cj
public class BgfxShadowMap
```
bgfx 阴影贴图管理

### func destroyShadowMap\(Int64\)
```cj
public func destroyShadowMap(lightId: Int64): Unit
```
销毁阴影贴图（包括 VSM 的辅助纹理和帧缓冲）

参数: 

|名称|类型|描述|
|---|---|---|
|lightId|Int64|光源 ID|

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有阴影贴图

### func getShadowMap\(Int64,Int64,Int64,Bool\)
```cj
public func getShadowMap(lightId: Int64, width: Int64, height: Int64, isCube!: Bool = false): ShadowMapInfo
```
获取或创建阴影贴图

参数: 

|名称|类型|描述|
|---|---|---|
|lightId|Int64|光源 IDwidth 阴影贴图宽度height 阴影贴图高度isCube 是否为立方体贴图（点光源）|
|width|Int64||
|height|Int64||
|isCube|Bool||

返回: 

- 阴影贴图信息

### func getShadowType\(\)
```cj
public func getShadowType(): Int64
```
获取阴影类型

返回: 

- 阴影类型

### func hasTypeChanged\(\)
```cj
public func hasTypeChanged(): Bool
```
检查阴影类型是否在上一帧到当前帧之间发生了变化

返回: 

- 是否发生变化

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


参数: 

|名称|类型|描述|
|---|---|---|
|info|BgfxInfo||

### func isEnabled\(\)
```cj
public func isEnabled(): Bool
```
是否启用阴影

返回: 

- 是否启用

### func setEnabled\(Bool\)
```cj
public func setEnabled(value: Bool): Unit
```
设置阴影启用状态

参数: 

|名称|类型|描述|
|---|---|---|
|value|Bool|是否启用|

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
设置阴影类型

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|阴影类型|

