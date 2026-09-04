# 类
## class GroundReflector
```cj
public class GroundReflector <: Mesh
```
地面反射器（SSRPass 专用平面反射组件）

### func computeVirtualCamera\(Camera\)
```cj
public func computeVirtualCamera(camera: Camera): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|camera|Camera|主相机|

返回: 

- true=可渲染（朝向正确），false=反射面背向相机（跳过）镜像相机数学核心。

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
取反射 RT frame buffer（渲染目标，由 BgfxSSRPass 设到 view）。

### func getRenderTarget\(\)
```cj
public func getRenderTarget(): TextureHandle
```
取反射器内部 RT 的 color 纹理句柄。

### func getTextureSize\(\)
```cj
public func getTextureSize():(Int64, Int64)
```


返回: 

- (宽, 高)取反射 RT 尺寸。

### func init\(BufferGeometry,Int64,Int64,Color,Float64,Bool\)
```cj
public init(geometry: BufferGeometry, textureWidth!: Int64 = 512, textureHeight!: Int64 = 512, color!: Color = Color(0x7f, 0x7f, 0x7f), clipBias!: Float64 = 0.0, useDepthTexture!: Bool = false)
```


参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|地面平面几何（PlaneGeometry/BoxGeometry）|
|textureWidth|Int64|反射纹理宽（默认 512）|
|textureHeight|Int64|反射纹理高（默认 512）|
|color|Color|反射贴图混合色（默认 0x7F7F7F）|
|clipBias|Float64|裁剪偏置（默认 0；bgfx 无全局裁剪平面，预留）|
|useDepthTexture|Bool|是否用深度纹理（默认 false；true 时启用距离衰减/菲涅尔）构造 GroundReflector。|

### let REFLECTOR\_VIEW\_ID\_BASE
```cj
public static let REFLECTOR_VIEW_ID_BASE: UInt16 = 237u16
```
分配给本组件的 bgfx view ID 段。
+0: 反射场景渲染（用 view 0 语义 + renderer.render，见 BgfxSSRPass._renderGroundReflector）
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

