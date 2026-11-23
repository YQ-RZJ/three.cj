# Class
## class LUTPass
```cj
public class LUTPass <: ShaderPass & IReleasable
```
Color grading (LUT) post-processing pass

### func bindExtraUniforms\(Renderer,IUniformRegistry\)
```cj
public override func bindExtraUniforms(renderer: Renderer, uniforms: IUniformRegistry): Unit
```
Subclass extension hook: binds the LUT-related uniforms before submit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer|
|uniforms|IUniformRegistry|The uniform registry where the tDiffuse sampler has been created (LUT uniforms are added here)|

### func init\(EngineDataTexture,Int64,Float64\)
```cj
public init(lut: EngineDataTexture, lutSize!: Int64 = 0, intensity!: Float64 = 1.0)
```
Constructs LUTPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lut|EngineDataTexture|The 3D LUT texture handle (default invalid → pass skipped)|
|lutSize|Int64|LUT edge length (default 0, paired with an invalid texture; must be > 0 for a valid texture)|
|intensity|Float64|Mix intensity (default 1.0)|

### func release\(\)
```cj
public override func release(): Bool
```
Releases the GPU resources held by LUTPass

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
Executes the LUT pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|GfxFrameBufferHandle|Write buffer (output target of this pass)|
|readBuffer|GfxFrameBufferHandle|Read buffer (previous pass result, bound to tDiffuse)|
|deltaTime|Float64|Frame delta time|

### var intensity
```cj
public var intensity: Float64
```
Mix intensity [0,1]: 0=original image, 1=fully LUT-mapped

### var lutSize
```cj
public var lutSize: Int64
```
LUT edge length (pixels, e.g. 16/32; all three edges of the 3D texture are equal)

### var lut
```cj
public var lut: EngineDataTexture
```
3D LUT texture (bgfx GfxTextureHandle, RGBA8, size lutSize×lutSize×lutSize)

