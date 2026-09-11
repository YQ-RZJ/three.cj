# Class
## class XRRenderTarget
```cj
public class XRRenderTarget
```
XR render target

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
Construct XR render target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Widthheight Height|
|height|Int64||

### func setSize\(Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64): Unit
```
Set render target size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Widthheight Height|
|height|Int64||

### var colorTexture
```cj
public var colorTexture: Texture
```
Color texture

### var depthTexture
```cj
public var depthTexture: DepthTexture
```
Depth texture

### var height
```cj
public var height: Int64
```
Height

### var width
```cj
public var width: Int64
```
Width

