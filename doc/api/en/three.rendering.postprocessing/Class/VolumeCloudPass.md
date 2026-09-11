# Class
## class VolumeCloudPass
```cj
public class VolumeCloudPass <: ShaderPass
```
Volume cloud post-processing pass (full-screen ray marching)

### func bindExtraUniforms\(ThreeRenderer,BgfxUniforms\)
```cj
public override func bindExtraUniforms(renderer: ThreeRenderer, uniforms: BgfxUniforms): Unit
```
子类扩展钩子：submit 前绑定体积云相关 uniform。
材质 uniforms 直接改值（cameraPos/threshold/opacity/range/steps/frame）；
bgfx 需在 submit 前经 uniforms 注册表 createUniform + setUniform 绑定。

绑定：
- stage 1：u_cloudMap（SAMPLER3D，3D 噪声纹理）
- u_cloudInvViewProj（mat4，每帧由 camera.projectionMatrix × matrixWorldInverse 求逆）
- u_cameraPos / u_boxCenter / u_boxHalfSize / u_base（vec4）
- u_threshold / u_range / u_opacity / u_steps / u_frame / u_texSize（vec4.x）

注：逆视图投影矩阵 uniform 名避开 bgfx_shader.sh 内置的 u_invViewProj
（BgfxShaderSource.cj 已声明，HLSL 下重名会报 X3003 redefinition）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|uniforms|BgfxUniforms|已创建 tDiffuse sampler 的 uniform 注册表（继续创建体积云 uniforms）|

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放体积云 pass 占用的 GPU 资源。
volumecloud shader program 由 PostProcessingShaders 全局管理，不在此 dispose。
3D 噪声纹理为本 pass 自建，须显式销毁；全屏 quad 由 EffectComposer 统一管理。

### func init\(Camera,Vector3,Vector3,Color,Float64,Float64,Float64,Float64,Int64\)
```cj
public init(camera: Camera, cloudCenter!: Vector3 = Vector3(0.0, 0.0, 0.0), cloudHalfSize!: Vector3 = Vector3(4.0, 2.0, 4.0), base!: Color = Color(0x798aa0), threshold!: Float64 = 0.25, range!: Float64 = 0.1, opacity!: Float64 = 0.25, steps!: Float64 = 100.0, texSize!: Int64 = 64)
```
构造 VolumeCloudPass。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|Camera|相机（重建射线必需）|
|cloudCenter|Vector3|云盒中心（默认原点）|
|cloudHalfSize|Vector3|云盒半尺寸（默认 (4,2,4)）|
|base|Color|云基准色（默认 0x798aa0）|
|threshold|Float64|密度阈值（默认 0.25）|
|range|Float64|smoothstep 宽度（默认 0.1）|
|opacity|Float64|不透明度（默认 0.25）|
|steps|Float64|步数（默认 100）|
|texSize|Int64|3D 噪声边长（默认 64）|

### func onAttach\(EffectComposer\)
```cj
public override func onAttach(composer: EffectComposer): Unit
```
挂载到 composer 时持有渲染器引用（dispose 销毁自建 3D 纹理需要 renderer）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|composer|EffectComposer|挂载的 EffectComposer（composer.renderer 即渲染器）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行体积云 pass：帧号自增后委托基类（绑定 tDiffuse + submit quad）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer||
|writeBuffer|FrameBufferHandle||
|readBuffer|FrameBufferHandle||
|deltaTime|Float64||

### var base
```cj
public var base: Color
```
云基准色（accumulate 起始色，默认 0x798aa0）。

### var camera
```cj
public var camera: Camera
```
相机（每帧取 projectionMatrix × matrixWorldInverse 的逆重建射线）。

### var cloudCenter
```cj
public var cloudCenter: Vector3
```
云盒中心（世界坐标）。

### var cloudHalfSize
```cj
public var cloudHalfSize: Vector3
```
云盒半尺寸（世界坐标，决定噪声纹理覆盖的世界范围）。

### var frame
```cj
public var frame: Int64
```
帧号（每帧自增，驱动抖动种子动画）。

### var opacity
```cj
public var opacity: Float64
```
云不透明度（默认 0.25）。

### var range
```cj
public var range: Float64
```
smoothstep 过渡宽度（默认 0.1）。

### var steps
```cj
public var steps: Float64
```
ray marching 步数（默认 100）。

### var texSize
```cj
public var texSize: Int64
```
3D 噪声纹理边长（默认 64 平衡内存/质量）。

### var threshold
```cj
public var threshold: Float64
```
密度阈值（默认 0.25）。

