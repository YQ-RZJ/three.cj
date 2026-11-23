# Class
## class ShaderPass
```cj
public open class ShaderPass <: Pass & IReleasable
```
Generic shader pass

### func bindExtraUniforms\(Renderer,IUniformRegistry\)
```cj
public open func bindExtraUniforms(renderer: Renderer, uniforms: IUniformRegistry): Unit
```
Subclass extension hook: binds extra uniforms before submit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|uniforms|IUniformRegistry|The uniform registry where the tDiffuse sampler has been created (extra uniforms can be added)|

### func init\(String,String\)
```cj
public init(shaderName: String, textureID!: String = "tDiffuse")
```
Constructs ShaderPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shaderName|String|The registered full-screen shader name in ShaderLibs|
|textureID|String|The sampler name bound to readBuffer (default tDiffuse)|

### func release\(\)
```cj
public open override func release(): Bool
```
Releases the GPU resources held by ShaderPass

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public open override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
Executes the shader pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|GfxFrameBufferHandle|Write buffer (written here when renderToScreen=false)|
|readBuffer|GfxFrameBufferHandle|Read buffer (bound to the textureID sampler)|
|deltaTime|Float64|Frame delta time|

### var clearView
```cj
public var clearView: Bool = true
```
Whether to clear the view before renderers, default true

### let shaderName
```cj
public let shaderName: String
```
Registered shader name (fetched via PostProcessingShaders.get(name))

### var stencilTestRef
```cj
public var stencilTestRef: Option < UInt32 >= None
```
Optional stencil test reference value; when Some(ref), only renders where stencil==ref

### var textureID
```cj
public var textureID: String = "tDiffuse"
```
Texture uniform name (sampler bound to readBuffer), default tDiffuse

