# Class
## class ShadowMapInfo
```cj
public class ShadowMapInfo
```
Shadow map information

### func init\(\)
```cj
public init()
```


### var blockerFrameBuffer
```cj
public var blockerFrameBuffer: FrameBufferHandle = FrameBufferHandle()
```
PCSS blocker search dedicated framebuffer (only for PCSS mode)

### var blockerTexture
```cj
public var blockerTexture: TextureHandle = TextureHandle()
```
PCSS blocker search dedicated texture (only for PCSS mode)

### var cascadeCount
```cj
public var cascadeCount: Int64 = 0
```
CSM cascade count (0 means non-CSM)

### var cascadeFrameBuffers
```cj
public var cascadeFrameBuffers: ArrayList < FrameBufferHandle >= ArrayList < FrameBufferHandle >()
```
CSM atlas sub-framebuffer array (one sub-FB per level, split by quadrant in atlas mode)

### var cascadeTextures
```cj
public var cascadeTextures: ArrayList < TextureHandle >= ArrayList < TextureHandle >()
```
CSM atlas sub-texture array (one sub-texture handle per level, reuses texture in atlas mode)

### var depthImpl
```cj
public var depthImpl: Int64 = DEPTH_IMPL_INVZ
```
Depth implementation (DepthImpl: InvZ/Linear)

### var depthTexture
```cj
public var depthTexture: TextureHandle = TextureHandle()
```
VSM/ESM depth texture handle (only for VSM/ESM mode: native depth -> blur -> color)

### var faceFrameBuffers
```cj
public var faceFrameBuffers: ArrayList < FrameBufferHandle >= ArrayList < FrameBufferHandle >()
```
Per-face framebuffers for cube shadow maps (only when isCube=true, one per face)

### var finalFrameBuffer
```cj
public var finalFrameBuffer: FrameBufferHandle = FrameBufferHandle()
```
VSM/ESM final color texture frame buffer (horizontal blur target, only for VSM/ESM mode)

### var frameBuffer
```cj
public var frameBuffer: FrameBufferHandle = FrameBufferHandle()
```
bgfx frame buffer handle

### var height
```cj
public var height: Int64 = 512
```
Shadow map height

### var initialized
```cj
public var initialized: Bool = false
```
Whether initialized

### var isCube
```cj
public var isCube: Bool = false
```
Whether this is a cube map (PointLight)

### var packDepth
```cj
public var packDepth: Int64 = PACK_DEPTH_RGBA
```
Depth packing mode (PackDepth: RGBA/VSM)

### var passFrameBuffer
```cj
public var passFrameBuffer: FrameBufferHandle = FrameBufferHandle()
```
VSM/ESM pass temporary frame buffer (only for VSM/ESM mode)

### var passTexture
```cj
public var passTexture: TextureHandle = TextureHandle()
```
VSM/ESM pass temporary texture (only for VSM/ESM mode)

### var shadowType
```cj
public var shadowType: Int64 = PCF_SHADOW_MAP
```
Shadow type (SmImpl type determined at creation)

### var smType
```cj
public var smType: Int64 = SM_TYPE_SINGLE
```
Shadow map distribution type (SmType: Single/Omni/Cascade)

### var texture
```cj
public var texture: TextureHandle = TextureHandle()
```
Shadow map texture handle (depth texture, or color texture for VSM/ESM)

### var width
```cj
public var width: Int64 = 512
```
Shadow map width

