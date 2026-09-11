# Class
## class XRDepthSensing
```cj
public class XRDepthSensing
```
XR depth sensing

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose resources

### func getMesh\(\)
```cj
public func getMesh(): Option < Mesh >
```
Get depth mesh

Return: 

- Depth visualization mesh (lazily created on first call, cached subsequently)

### func getTexture\(\)
```cj
public func getTexture(): TextureHandle
```
Get depth texture

Return: 

- Depth texture handle

### func init\(\)
```cj
public init()
```


### func isAvailable\(\)
```cj
public func isAvailable(): Bool
```
Whether depth sensing is available

Return: 

- Whether available

### func reset\(\)
```cj
public func reset(): Unit
```
Reset depth data

### func setTexture\(TextureHandle\)
```cj
public func setTexture(texture: TextureHandle): Unit
```
Set depth texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|TextureHandle|Depth texture handle|

### func update\(Float64,Float64,Int64,Int64\)
```cj
public func update(depthNear: Float64, depthFar: Float64, width: Int64, height: Int64): Unit
```
Update depth data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depthNear|Float64|Depth near valuedepthFar Depth far valuewidth Depth widthheight Depth height|
|depthFar|Float64||
|width|Int64||
|height|Int64||

