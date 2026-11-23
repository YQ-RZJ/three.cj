# Class
## class XRDepthSensing
```cj
public class XRDepthSensing <: IReleasable
```
XR depth sensing

### func bindRenderer\(ThreeRenderer\)
```cj
public func bindRenderer(renderer: ThreeRenderer): XRDepthSensing
```
Binds the renderer (depth texture destruction is issued to the backend through it)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer instance|

Return: 

- Self (for chaining)

### func getMesh\(\)
```cj
public func getMesh(): Option < Mesh >
```
Get depth mesh

Return: 

- Depth visualization mesh (lazily created on first call, cached subsequently)

### func getTextureIdx\(\)
```cj
public func getTextureIdx(): UInt16
```
Depth texture handle index (read-only plain value; for on-screen debug printing)

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

### func release\(\)
```cj
public func release(): Bool
```
Release resources

### func reset\(\)
```cj
public func reset(): Unit
```
Reset depth data

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

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Resource validity: true when the handle is valid and marked available

