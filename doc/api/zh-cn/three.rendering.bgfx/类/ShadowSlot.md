# 类
## class ShadowSlot
```cj
public class ShadowSlot
```
单个阴影光源的全部 GPU 资源（按光源 ID 分桶）

### func init\(\)
```cj
public init()
```


### var baseViewId
```cj
public var baseViewId: UInt16 = 0u16
```
该阴影光源占用的起始 view ID（cube 占 6 个连续 view ID）

### var bias
```cj
public var bias: Float64 = 0.0
```
per-light 深度 bias（来自 light.shadow.bias，主 pass 绑 u_xxxShadowParams[i].x 用）

### var faceFrameBuffers
```cj
public var faceFrameBuffers: ArrayList < FrameBufferHandle >= ArrayList < FrameBufferHandle >()
```
cube 阴影的 6 个 face 独立 framebuffer（仅 isCube=true 时使用）

### var far
```cj
public var far: Float64 = 100.0
```
阴影相机 far（主 pass 绑 u_pointShadowNearFar[i].y 用）

### var frameBuffer
```cj
public var frameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
```
阴影 framebuffer（cube 时为 face 0 的 fb 占位）

### var isCube
```cj
public var isCube: Bool = false
```
是否为 cube 阴影（PointLight）

### var lightPos
```cj
public var lightPos: Vector3 = Vector3()
```
光源世界坐标（cube 阴影 vertex 端算 worldPos - lightPos[i] 用）

### var near
```cj
public var near: Float64 = 0.1
```
阴影相机 near（主 pass 绑 u_pointShadowNearFar[i].x 用）

### var normalBias
```cj
public var normalBias: Float64 = 0.0
```
per-light 法线 bias（来自 light.shadow.normalBias，vertex 端法线偏移 u_xxxShadowParams[i].y 用）

### var shadowMatrix
```cj
public var shadowMatrix: Matrix4 = Matrix4()
```
bias × lightViewProj 矩阵（主 pass 绑 directionalShadowMatrix[i] / spotLightMatrix[i]）

### var size
```cj
public var size: Int64 = 0
```
阴影 framebuffer 尺寸

### var texture
```cj
public var texture: TextureHandle = TextureHandle(65535u16)
```
阴影深度纹理句柄（2D 或 cube）

### var vsmDepthTexture
```cj
public var vsmDepthTexture: TextureHandle = TextureHandle(65535u16)
```
VSM 深度纹理（D32，原生深度，深度 pass 写入）

### var vsmFinalFrameBuffer
```cj
public var vsmFinalFrameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
```
VSM 水平 blur 输出 framebuffer（写入 texture=RG16F 最终结果，主 pass 采样）

### var vsmPassFrameBuffer
```cj
public var vsmPassFrameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
```
VSM 垂直 blur 输出 framebuffer（写入 vsmPassTexture）

### var vsmPassTexture
```cj
public var vsmPassTexture: TextureHandle = TextureHandle(65535u16)
```
VSM 垂直 blur 输出 / 水平 blur 输入（RG16F 中间结果）

