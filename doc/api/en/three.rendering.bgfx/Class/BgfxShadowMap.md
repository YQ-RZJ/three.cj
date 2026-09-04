# Class
## class BgfxShadowMap
```cj
public class BgfxShadowMap
```
bgfx shadow map management

### func destroyShadowMap\(Int64\)
```cj
public func destroyShadowMap(lightId: Int64): Unit
```
Destroy shadow map (including VSM auxiliary textures and frame buffers)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lightId|Int64|Light ID|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose all shadow maps

### func getShadowMap\(Int64,Int64,Int64,Bool\)
```cj
public func getShadowMap(lightId: Int64, width: Int64, height: Int64, isCube!: Bool = false): ShadowMapInfo
```
Get or create shadow map

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lightId|Int64|Light IDwidth Shadow map widthheight Shadow map heightisCube Whether this is a cube map (point light)|
|width|Int64||
|height|Int64||
|isCube|Bool||

Return: 

- Shadow map information

### func getShadowType\(\)
```cj
public func getShadowType(): Int64
```
Get shadow type

Return: 

- Shadow type

### func hasTypeChanged\(\)
```cj
public func hasTypeChanged(): Bool
```
Check if shadow type changed between the previous frame and current frame

Return: 

- Whether changed

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

### func isEnabled\(\)
```cj
public func isEnabled(): Bool
```
Whether shadow is enabled

Return: 

- Whether enabled

### func setEnabled\(Bool\)
```cj
public func setEnabled(value: Bool): Unit
```
Set shadow enabled state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Bool|Whether to enable|

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
Set shadow type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Shadow type|

