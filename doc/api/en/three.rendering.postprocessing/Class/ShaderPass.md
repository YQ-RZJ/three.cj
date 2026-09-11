# Class
## class ShaderPass
```cj
public open class ShaderPass <: Pass
```
Generic shader pass

### func bindExtraUniforms\(ThreeRenderer,BgfxUniforms\)
```cj
public open func bindExtraUniforms(renderer: ThreeRenderer, uniforms: BgfxUniforms): Unit
```
Subclass extension hook: binds extra uniforms before submit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|uniforms|BgfxUniforms|The uniform registry where the tDiffuse sampler has been created (extra uniforms can be added)|

### func dispose\(\)
```cj
public open override func dispose(): Unit
```
Releases the GPU resources held by ShaderPass

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

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public open override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the shader pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (written here when renderToScreen=false)|
|readBuffer|FrameBufferHandle|Read buffer (bound to the textureID sampler)|
|deltaTime|Float64|Frame delta time|

### var clearView
```cj
public var clearView: Bool = true
```
Whether to clear the view before rendering, default true

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

