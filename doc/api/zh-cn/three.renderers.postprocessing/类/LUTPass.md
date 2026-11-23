# 类
## class LUTPass
```cj
public class LUTPass <: ShaderPass & IReleasable
```
颜色分级（LUT）后处理 pass

### func bindExtraUniforms\(Renderer,IUniformRegistry\)
```cj
public override func bindExtraUniforms(renderer: Renderer, uniforms: IUniformRegistry): Unit
```
子类扩展钩子：submit 前绑定 LUT 相关 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|uniforms|IUniformRegistry|已创建 tDiffuse sampler 的 uniform 注册表（继续创建 LUT uniforms）|

### func init\(EngineDataTexture,Int64,Float64\)
```cj
public init(lut: EngineDataTexture, lutSize!: Int64 = 0, intensity!: Float64 = 1.0)
```
构造 LUTPass

参数: 

|名称|类型|描述|
|---|---|---|
|lut|EngineDataTexture|3D LUT 纹理句柄（默认无效 → pass 跳过）|
|lutSize|Int64|LUT 边长（默认 0，与无效纹理配套；有效纹理时必须 > 0）|
|intensity|Float64|混合强度（默认 1.0）|

### func release\(\)
```cj
public override func release(): Bool
```
释放 LUTPass 占用的 GPU 资源

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
执行 LUT pass

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|GfxFrameBufferHandle|写 buffer（本 pass 的输出目标）|
|readBuffer|GfxFrameBufferHandle|读 buffer（上一 pass 结果，绑到 tDiffuse）|
|deltaTime|Float64|帧间隔|

### var intensity
```cj
public var intensity: Float64
```
混合强度 [0,1]：0=原图，1=完全 LUT 映射

### var lutSize
```cj
public var lutSize: Int64
```
LUT 边长（像素，如 16/32，3D 纹理三边等长）

### var lut
```cj
public var lut: EngineDataTexture
```
3D LUT 纹理（bgfx GfxTextureHandle，RGBA8，尺寸 lutSize×lutSize×lutSize）

