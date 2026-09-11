# Class
## class GroundReflector
```cj
public class GroundReflector <: Mesh
```
Ground reflector (SSRPass dedicated planar reflection component)

### func computeVirtualCamera\(Camera\)
```cj
public func computeVirtualCamera(camera: Camera): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|camera|Camera|Main camera|

Return: 

- true = renderable (facing correct), false = reflector facing away from camera (skip)流程：1. fresnelCoe = (dot(normalize(camera.position), reflect(normalize(camera.position), yAxis)) + 1) / 22. 反射面朝向检测：view = reflectorWorldPosition - cameraWorldPosition；view.dot(normal) > 0 → 反射面背向相机 → 返回 false（跳过本次渲染）3. 镜像构造 virtualCamera（位置/up/看向 target 全部按 normal 镜像）4. textureMatrix = 0.5偏移 × proj × viewInv × matrixWorld

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放反射器 GPU 资源。

### func ensureRTs\(\)
```cj
public func ensureRTs(): Unit
```
创建反射 RT（RGBA16F + D24；useDepthTexture=true 时额外 RGBA32F 深度 RT）。

### func getReflectDepthFB\(\)
```cj
public func getReflectDepthFB(): FrameBufferHandle
```
取反射深度 RT frame buffer（useDepthTexture=true 时有效）。

### func getReflectDepthTex\(\)
```cj
public func getReflectDepthTex(): TextureHandle
```
取反射深度 RT 纹理句柄（useDepthTexture=true 时有效，RGBA32F 存 NDC 深度）。
供 capture 等调试工具回读验证。

### func getReflectFB\(\)
```cj
public func getReflectFB(): FrameBufferHandle
```
取反射 RT frame buffer（渲染目标，由 SSRPass 设到 view）。

### func getRenderTarget\(\)
```cj
public func getRenderTarget(): TextureHandle
```
取反射器内部 RT 的 color 纹理句柄。

### func getTextureSize\(\)
```cj
public func getTextureSize():(Int64, Int64)
```


Return: 

- (width, height)

### func init\(\)
```cj
public init()
```


### func init\(BufferGeometry,Int64,Int64,Color,Float64,Bool\)
```cj
public init(geometry: BufferGeometry, textureWidth!: Int64 = 512, textureHeight!: Int64 = 512, color!: Color = Color(0x7f, 0x7f, 0x7f), clipBias!: Float64 = 0.0, useDepthTexture!: Bool = false)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry||
|textureWidth|Int64||
|textureHeight|Int64||
|color|Color||
|clipBias|Float64||
|useDepthTexture|Bool||

### let REFLECTOR\_VIEW\_ID\_BASE
```cj
public static let REFLECTOR_VIEW_ID_BASE: UInt16 = 237u16
```
分配给本组件的 bgfx view ID 段。
+0: 反射场景渲染（用 view 0 语义 + renderer.render，见 SSRPass._renderGroundReflector）
+1: 反射深度渲染（useDepthTexture=true 时，aodepth → RGBA32F 深度 RT）
取 237 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229 /
RenderPixelatedPass 230~233 / RenderTransitionPass 234~236。

### var clipBias
```cj
public var clipBias: Float64 = 0.0
```
clipBias（预留字段：bgfx 无全局裁剪平面，默认 0 无影响）

### var fresnelCoe
```cj
public var fresnelCoe: Float64 = 1.0
```
菲涅尔系数（computeVirtualCamera 计算结果）。

### var textureMatrix
```cj
public var textureMatrix: Matrix4 = Matrix4()
```
纹理投影矩阵（computeVirtualCamera 计算结果）。

### var useDepthTexture
```cj
public var useDepthTexture: Bool = false
```
是否使用深度纹理（useDepthTexture define）

### var virtualCamera
```cj
public var virtualCamera: PerspectiveCamera = PerspectiveCamera()
```
镜像虚拟相机（computeVirtualCamera 计算结果）。

