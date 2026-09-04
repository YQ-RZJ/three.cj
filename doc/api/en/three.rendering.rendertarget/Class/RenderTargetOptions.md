# Class
## class RenderTargetOptions
```cj
public class RenderTargetOptions
```
Render target options

### func init\(\)
```cj
public init()
```
Construct render target options with default values

### var \`type\`
```cj
public var `type`: Int64
```
Texture data type

### var anisotropy
```cj
public var anisotropy: Int64
```
Anisotropy filtering value

### var colorSpace
```cj
public var colorSpace: String
```
Color space

### var count
```cj
public var count: Int64
```
Color attachment count

### var depthBuffer
```cj
public var depthBuffer: Bool
```
Whether to allocate a depth buffer

### var depthTexture
```cj
public var depthTexture:?IRenderTargetTexture
```
Depth texture reference (optional)

### var depth
```cj
public var depth: Int64
```
Texture depth

### var format
```cj
public var format: Int64
```
Texture format

### var generateMipmaps
```cj
public var generateMipmaps: Bool
```
Whether to generate mipmaps

### var internalFormat
```cj
public var internalFormat:?String
```
Internal format (optional)

### var magFilter
```cj
public var magFilter: Int64
```
Magnification filter mode

### var minFilter
```cj
public var minFilter: Int64
```
Minification filter mode

### var multiview
```cj
public var multiview: Bool
```
Whether to use for multiview rendering

### var resolveColorBuffer
```cj
public var resolveColorBuffer: Bool
```
Whether to resolve the color buffer

### var resolveDepthBuffer
```cj
public var resolveDepthBuffer: Bool
```
Whether to resolve the depth buffer

### var resolveStencilBuffer
```cj
public var resolveStencilBuffer: Bool
```
Whether to resolve the stencil buffer

### var samples
```cj
public var samples: Int64
```
MSAA sample count, 0 means disabled

### var stencilBuffer
```cj
public var stencilBuffer: Bool
```
Whether to allocate a stencil buffer

### var storeMultisampledColorBuffer
```cj
public var storeMultisampledColorBuffer: Bool
```
Whether to store multisampled color buffer

### var storeMultisampledDepthBuffer
```cj
public var storeMultisampledDepthBuffer: Bool
```
Whether to store multisampled depth buffer

### var storeMultisampledStencilBuffer
```cj
public var storeMultisampledStencilBuffer: Bool
```
Whether to store multisampled stencil buffer

### var useArrayDepthTexture
```cj
public var useArrayDepthTexture: Bool
```
Whether to create as array depth texture

### var wrapR
```cj
public var wrapR: Int64
```
R-axis wrapping mode

### var wrapS
```cj
public var wrapS: Int64
```
S-axis wrapping mode

### var wrapT
```cj
public var wrapT: Int64
```
T-axis wrapping mode

