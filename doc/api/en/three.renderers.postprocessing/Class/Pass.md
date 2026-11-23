# Class
## class Pass
```cj
public open class Pass <: IReleasable
```
Post-processing pass abstract base class

### func \_cachedUniform\(String,GfxUniformType,UInt16\)
```cj
public func _cachedUniform(name: String, uniformType: GfxUniformType, num!: UInt16 = 1u16): GfxUniformHandle
```
Gets a uniform handle by name (cached after first creation; per-pass)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|uniformType|GfxUniformType|Uniform type|
|num|UInt16|Array length (1 for non-array)|

Return: 

- Cached uniform handle

### func \_disposePassUniforms\(\)
```cj
public func _disposePassUniforms(): Unit
```
Releases this pass's private uniform cache and handle cache

### func \_passUniforms\(\)
```cj
public func _passUniforms(): IUniformRegistry
```
Returns this pass's private uniform cache (created on first use)

Return: 

- This pass's private uniform registry instance

### func \_setScalarUniform\(Renderer,GfxUniformHandle,Int64,Float64\)
```cj
public func _setScalarUniform(renderer: Renderer, handle: GfxUniformHandle, slot: Int64, value: Float64): Unit
```
Writes a single scalar into the vec4 buffer of slot `slot` and submits it

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|handle|GfxUniformHandle|Uniform handle|
|slot|Int64|Slot index|
|value|Float64|Scalar value (written to the x component)|

### func \_setVec2Uniform\(Renderer,GfxUniformHandle,Int64,Float64,Float64\)
```cj
public func _setVec2Uniform(renderer: Renderer, handle: GfxUniformHandle, slot: Int64, x: Float64, y: Float64): Unit
```
Writes two scalars into the vec4 buffer of slot `slot` and submits it

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|handle|GfxUniformHandle|Uniform handle|
|slot|Int64|Slot index|
|x|Float64|Value written to the x component|
|y|Float64|Value written to the y component|

### func \_setVec4Uniform\(Renderer,GfxUniformHandle,Int64,Float64,Float64,Float64,Float64\)
```cj
public func _setVec4Uniform(renderer: Renderer, handle: GfxUniformHandle, slot: Int64, x: Float64, y: Float64, z: Float64, w: Float64): Unit
```
Writes four scalars into the vec4 buffer of slot `slot` and submits it

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|handle|GfxUniformHandle|Uniform handle|
|slot|Int64|Slot index|
|x|Float64|Value written to the x component|
|y|Float64|Value written to the y component|
|z|Float64|Value written to the z component|
|w|Float64|Value written to the w component|

### func bindTexture\(Renderer,UInt8,GfxUniformHandle,GfxTextureHandle,UInt32\)
```cj
public func bindTexture(renderer: Renderer, stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit
```
Binds a texture to the sampler of the given stage

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|stage|UInt8|Texture stage (0..MAX_TEXTURE_SAMPLERS-1)|
|sampler|GfxUniformHandle|The sampler uniform handle|
|tex|GfxTextureHandle|The texture handle to bind|
|flags|UInt32|Sampler flags (e.g. GfxSamplerFlag.U_CLAMP|V_CLAMP; 0 uses the texture default)|

### func clearRenderTarget\(ThreeRenderer,UInt16,UInt16,UInt32,Float32,UInt8\)
```cj
public func clearRenderTarget(renderer: ThreeRenderer, viewId: UInt16, flags: UInt16, color: UInt32, depth!: Float32 = 1.0f32, stencil!: UInt8 = 0u8): Unit
```
Sets the clear for a view (color + depth + stencil)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|viewId|UInt16|The view id|
|flags|UInt16|Clear flags (GfxClearFlag.COLOR/DEPTH/STENCIL combination)|
|color|UInt32|Clear color (UInt32)|
|depth|Float32|Clear depth (0.0~1.0, default 1.0)|
|stencil|UInt8|Clear stencil value (default 0)|

### func getTexture\(ThreeRenderer,GfxFrameBufferHandle,UInt8\)
```cj
public func getTexture(renderer: ThreeRenderer, fb: GfxFrameBufferHandle, attachment: UInt8): GfxTextureHandle
```
Fetches the texture handle of a frame buffer attachment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|fb|GfxFrameBufferHandle|Source frame buffer|
|attachment|UInt8|Attachment index (0=main color, 1=depth, etc.)|

Return: 

- The texture handle for the attachment

### func init\(\)
```cj
public init()
```


### func onAttach\(EffectComposer\)
```cj
public open func onAttach(composer: EffectComposer): Unit
```
Hook called when attached to a composer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|composer|EffectComposer|The EffectComposer being attached to|

### func release\(\)
```cj
public open func release(): Bool
```
base default no-op; subclasses override to release their own GPU resources

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public open func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
Executes the pass render logic

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|GfxFrameBufferHandle|Write buffer|
|readBuffer|GfxFrameBufferHandle|Read buffer (previous pass result)|
|deltaTime|Float64|Frame delta time (seconds)|

### func setQuad\(FullScreenQuad\)
```cj
public func setQuad(quad: FullScreenQuad): Unit
```
Injects the shared full-screen quad

Parameter: 

|Name|Type|Describe|
|---|---|---|
|quad|FullScreenQuad|The shared full-screen quad held by the composer|

### func setRenderTarget\(ThreeRenderer,UInt16,GfxFrameBufferHandle\)
```cj
public func setRenderTarget(renderer: ThreeRenderer, viewId: UInt16, fb: GfxFrameBufferHandle): Unit
```
Sets the render target frame buffer for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|viewId|UInt16|The view id (held by the pass, allocated via EffectComposer.allocViewId)|
|fb|GfxFrameBufferHandle|Target frame buffer; pass an invalid handle to write to the swap chain (screen)|

### func setSize\(Int64,Int64\)
```cj
public open func setSize(width: Int64, height: Int64): Unit
```
Sets the pass's internal RT size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64||
|height|Int64||

### func setStencil\(ThreeRenderer,UInt32,UInt32\)
```cj
public func setStencil(renderer: ThreeRenderer, fstencil: UInt32, bstencil: UInt32): Unit
```
Sets stencil state (per-draw transient)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|fstencil|UInt32|Front stencil bitfield (GfxStencilFlag combination)|
|bstencil|UInt32|Back stencil bitfield (same)|

### func setUniformFloats\(Renderer,GfxUniformHandle,Array<Float64>,UInt16\)
```cj
public func setUniformFloats(renderer: Renderer, handle: GfxUniformHandle, values: Array < Float64 >, num!: UInt16 = 1u16): Unit
```
Sets uniform data (safe overload, no external pointer management)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|handle|GfxUniformHandle|The uniform handle|
|values|Array<Float64>|Uniform data (Float64 array, written as float32)|
|num|UInt16|Array length (default 1)|

### func setUniform\(Renderer,GfxUniformHandle,PtrArray<Float32>,UInt16\)
```cj
public func setUniform(renderer: Renderer, handle: GfxUniformHandle, data: PtrArray < Float32 >, num!: UInt16 = 1u16): Unit
```
Sets uniform data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|handle|GfxUniformHandle|The uniform handle|
|data|PtrArray<Float32>|Uniform data (float32 array)|
|num|UInt16|Array length (default 1)|

### func setViewport\(ThreeRenderer,UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func setViewport(renderer: ThreeRenderer, viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
Sets the viewport rectangle (pixels) for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|viewId|UInt16|The view id|
|x|UInt16|Viewport top-left x (pixels)|
|y|UInt16|Viewport top-left y (pixels)|
|w|UInt16|Viewport width (pixels)|
|h|UInt16|Viewport height (pixels)|

### func submitQuadWithState\(UInt16,GfxProgramHandle,UInt64\)
```cj
public func submitQuadWithState(viewId: UInt16, prog: GfxProgramHandle, state: UInt64): Unit
```
Submits the full-screen quad with a custom render state (e.g. additive blending)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|The view id|
|prog|GfxProgramHandle|The compiled program handle|
|state|UInt64|The full render state bitfield (first argument of setState)|

### func submitQuad\(UInt16,GfxProgramHandle\)
```cj
public func submitQuad(viewId: UInt16, prog: GfxProgramHandle): Unit
```
Submits the full-screen quad with the shared quad (default overwrite state)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|The view id|
|prog|GfxProgramHandle|The compiled program handle|

### func touchView\(ThreeRenderer,UInt16\)
```cj
public func touchView(renderer: ThreeRenderer, viewId: UInt16): Unit
```
Triggers an empty submit for a view (only advances clear / view sequence, draws nothing)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|viewId|UInt16|The view id|

### var clear
```cj
public var clear: Bool = false
```
If true, clears the buffer before renderers; default false

### var enabled
```cj
public var enabled: Bool = true
```
If false, the composer skips this pass; default true

### let isPass
```cj
public let isPass: Bool = true
```
Type flag used to identify a Pass at runtime

### var needsSwap
```cj
public var needsSwap: Bool = true
```
If true, the composer swaps the read/write buffers after renderers; default true

### var quad
```cj
public var quad: Option < FullScreenQuad >= None
```
Shared full-screen quad (held as a singleton by EffectComposer, injected via setQuad on addPass)

### var renderToScreen
```cj
public var renderToScreen: Bool = false
```
If true, the pass result renders directly to the screen; default false

