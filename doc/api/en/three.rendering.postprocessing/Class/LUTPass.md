# Class
## class LUTPass
```cj
public class LUTPass <: ShaderPass
```
Color grading (LUT) post-processing pass

### func bindExtraUniforms\(BgfxRenderer,BgfxUniforms\)
```cj
public override func bindExtraUniforms(renderer: BgfxRenderer, uniforms: BgfxUniforms): Unit
```
Subclass extension hook: binds the LUT-related uniforms before submit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|
|uniforms|BgfxUniforms|The uniform registry where the tDiffuse sampler has been created (LUT uniforms are added here)|

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Releases the GPU resources held by LUTPass

### func init\(TextureHandle,Int64,Float64\)
```cj
public init(lut!: TextureHandle = INVALID_TEXTURE_HANDLE, lutSize!: Int64 = 0, intensity!: Float64 = 1.0)
```
Constructs LUTPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lut|TextureHandle|The 3D LUT texture handle (default invalid → pass skipped)|
|lutSize|Int64|LUT edge length (default 0, paired with an invalid texture; must be > 0 for a valid texture)|
|intensity|Float64|Mix intensity (default 1.0)|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the LUT pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (output target of this pass)|
|readBuffer|FrameBufferHandle|Read buffer (previous pass result, bound to tDiffuse)|
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
public var lut: TextureHandle
```
3D LUT texture (bgfx TextureHandle, RGBA8, size lutSize×lutSize×lutSize)

