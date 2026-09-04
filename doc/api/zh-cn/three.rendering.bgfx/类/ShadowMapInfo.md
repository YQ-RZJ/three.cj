# 类
## class ShadowMapInfo
```cj
public class ShadowMapInfo
```
阴影贴图信息

### func init\(\)
```cj
public init()
```


### var blockerFrameBuffer
```cj
public var blockerFrameBuffer: FrameBufferHandle = FrameBufferHandle()
```
PCSS blocker search 专用 framebuffer（仅 PCSS 模式需要）

### var blockerTexture
```cj
public var blockerTexture: TextureHandle = TextureHandle()
```
PCSS blocker search 专用纹理（仅 PCSS 模式需要）

### var cascadeCount
```cj
public var cascadeCount: Int64 = 0
```
CSM 级联数量（0 表示非 CSM）

### var cascadeFrameBuffers
```cj
public var cascadeFrameBuffers: ArrayList < FrameBufferHandle >= ArrayList < FrameBufferHandle >()
```
CSM atlas 子 framebuffer 数组（每级一个子 FB，atlas 模式下按 quadrant 切分）

### var cascadeTextures
```cj
public var cascadeTextures: ArrayList < TextureHandle >= ArrayList < TextureHandle >()
```
CSM atlas 子纹理数组（每级一个子纹理句柄，atlas 模式下复用 texture）

### var depthImpl
```cj
public var depthImpl: Int64 = DEPTH_IMPL_INVZ
```
深度计算方式（DepthImpl: InvZ/Linear）

### var depthTexture
```cj
public var depthTexture: TextureHandle = TextureHandle()
```
VSM/ESM 深度纹理句柄（仅 VSM/ESM 模式需要：原生深度 -> blur -> 颜色）

### var faceFrameBuffers
```cj
public var faceFrameBuffers: ArrayList < FrameBufferHandle >= ArrayList < FrameBufferHandle >()
```
立方体贴图阴影各 face 的独立 framebuffer（仅 isCube=true 时使用，6 个 face 各一个）

### var finalFrameBuffer
```cj
public var finalFrameBuffer: FrameBufferHandle = FrameBufferHandle()
```
VSM/ESM 最终颜色纹理的帧缓冲（水平 blur 写入目标，仅 VSM/ESM 模式）

### var frameBuffer
```cj
public var frameBuffer: FrameBufferHandle = FrameBufferHandle()
```
bgfx 帧缓冲句柄

### var height
```cj
public var height: Int64 = 512
```
阴影贴图高度

### var initialized
```cj
public var initialized: Bool = false
```
是否已初始化

### var isCube
```cj
public var isCube: Bool = false
```
是否为立方体贴图（PointLight）

### var packDepth
```cj
public var packDepth: Int64 = PACK_DEPTH_RGBA
```
深度打包方式（PackDepth: RGBA/VSM）

### var passFrameBuffer
```cj
public var passFrameBuffer: FrameBufferHandle = FrameBufferHandle()
```
VSM/ESM pass 的临时帧缓冲（仅 VSM/ESM 模式需要）

### var passTexture
```cj
public var passTexture: TextureHandle = TextureHandle()
```
VSM/ESM pass 的临时纹理（仅 VSM/ESM 模式需要）

### var shadowType
```cj
public var shadowType: Int64 = PCF_SHADOW_MAP
```
阴影类型（创建时确定的 SmImpl 类型）

### var smType
```cj
public var smType: Int64 = SM_TYPE_SINGLE
```
阴影贴图分布类型（SmType: Single/Omni/Cascade）

### var texture
```cj
public var texture: TextureHandle = TextureHandle()
```
阴影贴图纹理句柄（深度纹理，或 VSM/ESM 的颜色纹理）

### var width
```cj
public var width: Int64 = 512
```
阴影贴图宽度

