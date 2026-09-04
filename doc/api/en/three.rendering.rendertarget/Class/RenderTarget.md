# Class
## class RenderTarget
```cj
public open class RenderTarget <: EventDispatcher
```
Render target class, storing off-screen render buffer description

### func clone\(\)
```cj
public open func clone(): RenderTarget
```
Return a new render target with values copied from this instance

Return: 

- Clone of this instance

### func copy\(RenderTarget\)
```cj
public func copy(source: RenderTarget): RenderTarget
```
Copy settings from the given render target to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|RenderTarget|Render target to copy from|

Return: 

- Reference to this instance

### func dispose\(\)
```cj
public func dispose(): Unit
```
Release GPU-related resources allocated by this instance

### func getDepthTexture\(\)
```cj
public func getDepthTexture():?IRenderTargetTexture
```
Get the depth texture

Return: 

- Depth texture

### func getTexture\(\)
```cj
public func getTexture(): Option < IRenderTargetTexture >
```
Get the default color attachment texture

Return: 

- Default color attachment texture (textures[0])

### func init\(Int64,Int64,?RenderTargetOptions\)
```cj
public init(width!: Int64 = 1, height!: Int64 = 1, options!:?RenderTargetOptions = None)
```
Construct a new render target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Render target width, defaults to 1height Render target height, defaults to 1options Render target options, defaults to None (use default values)|
|height|Int64||
|options|?RenderTargetOptions||

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
Compatibility overload: 2-parameter form (options is None)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64||
|height|Int64||

### func setDepthTexture\(?IRenderTargetTexture\)
```cj
public func setDepthTexture(current:?IRenderTargetTexture): Unit
```
Set depth texture, unbinds old texture back reference and establishes new texture back reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|current|?IRenderTargetTexture|New depth texture|

### func setSize\(Int64,Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64, depth!: Int64 = 1): Unit
```
Set the size of this render target

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|New widthheight New heightdepth New depth, defaults to 1|
|height|Int64||
|depth|Int64||

### func setTexture\(Option<IRenderTargetTexture>\)
```cj
public func setTexture(value: Option < IRenderTargetTexture >): Unit
```
Set the default color attachment texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Option<IRenderTargetTexture>|Texture value|

### var depthBuffer
```cj
public var depthBuffer: Bool
```
Whether to allocate a depth buffer

### var depth
```cj
public var depth: Int64
```
Render target depth

### var height
```cj
public var height: Int64
```
Render target height

### var kind
```cj
public var kind: String
```
Geometry type string

### var multiview
```cj
public var multiview: Bool
```
Whether to use for multiview rendering (WebGL OVR_multiview2 extension)

### var resolveColorBuffer
```cj
public var resolveColorBuffer: Bool
```
Whether to resolve the color buffer (only for multisampled render targets), when false the color attachment does not receive resolve output

### var resolveDepthBuffer
```cj
public var resolveDepthBuffer: Bool
```
Whether to resolve the depth buffer (only for multisampled render targets), when false saves memory bandwidth

### var resolveStencilBuffer
```cj
public var resolveStencilBuffer: Bool
```
Whether to resolve the stencil buffer

### var samples
```cj
public var samples: Int64
```
MSAA sample count, 0 means MSAA disabled

### var scissorTest
```cj
public var scissorTest: Bool
```
Whether to enable scissor test when rendering to this target

### var scissor
```cj
public var scissor: Vector4
```
Scissor rectangle within the render target, fragments outside are discarded

### var stencilBuffer
```cj
public var stencilBuffer: Bool
```
Whether to allocate a stencil buffer

### var storeMultisampledColorBuffer
```cj
public var storeMultisampledColorBuffer: Bool
```
Whether to store multisampled color buffer, when false discards multisampled data after render pass

### var storeMultisampledDepthBuffer
```cj
public var storeMultisampledDepthBuffer: Bool
```
Whether to store multisampled depth buffer, when false saves bandwidth; must be true in WebGPU if sampling multisampled depth texture

### var storeMultisampledStencilBuffer
```cj
public var storeMultisampledStencilBuffer: Bool
```
Whether to store multisampled stencil buffer

### var textures
```cj
public var textures: ArrayList < Option < IRenderTargetTexture >>
```
Texture array, each color attachment represented by an independent texture, at least one default color attachment entry

### var useArrayDepthTexture
```cj
public var useArrayDepthTexture: Bool
```
Whether to create as array depth texture (independent of multiview)

### var userData
```cj
public var userData: HashMap < String, Any >
```
Custom data storage object

### var viewport
```cj
public var viewport: Vector4
```
Viewport rectangle of the render target

### var width
```cj
public var width: Int64
```
Render target width

