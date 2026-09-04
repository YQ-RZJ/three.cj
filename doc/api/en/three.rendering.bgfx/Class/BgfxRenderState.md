# Class
## class BgfxRenderState
```cj
public class BgfxRenderState
```
Render state

### func getLightCount\(\)
```cj
public func getLightCount(): Int64
```
Get light count

Return: 

- Light count

### func getLights\(\)
```cj
public func getLights(): ArrayList < Light >
```
Get light list

Return: 

- Light list

### func getShadowCount\(\)
```cj
public func getShadowCount(): Int64
```
Get shadow count

Return: 

- Shadow count

### func getShadows\(\)
```cj
public func getShadows(): ArrayList < LightShadow >
```
Get shadow list

Return: 

- Shadow list

### func init\(\)
```cj
public init()
```


### func pushLight\(Light\)
```cj
public func pushLight(light: Light): Unit
```
Add a light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|Light object|

### func pushShadow\(LightShadow\)
```cj
public func pushShadow(shadow: LightShadow): Unit
```
Add a shadow

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shadow|LightShadow|Shadow object|

### func reset\(Int64\)
```cj
public func reset(sceneId: Int64): Unit
```
Initialize render state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sceneId|Int64|Scene ID|

