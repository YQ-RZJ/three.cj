# Class
## class ShadowSlot
```cj
public class ShadowSlot
```
All GPU resources for a single shadow light (bucketed by light ID)

### func init\(\)
```cj
public init()
```


### var baseViewId
```cj
public var baseViewId: UInt16 = 0u16
```
Starting view ID for this shadow light (cube occupies 6 consecutive view IDs)

### var bias
```cj
public var bias: Float64 = 0.0
```
Per-light depth bias (from light.shadow.bias, bound as u_xxxShadowParams[i].x in main pass)

### var faceFrameBuffers
```cj
public var faceFrameBuffers: ArrayList < FrameBufferHandle >= ArrayList < FrameBufferHandle >()
```
Per-face framebuffers for cube shadow (only when isCube=true)

### var far
```cj
public var far: Float64 = 100.0
```
Shadow camera far (bound as u_pointShadowNearFar[i].y in main pass)

### var frameBuffer
```cj
public var frameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
```
Shadow framebuffer (placeholder for face 0 fb when cube)

### var isCube
```cj
public var isCube: Bool = false
```
Whether this is a cube shadow (PointLight)

### var lightPos
```cj
public var lightPos: Vector3 = Vector3()
```
Light world position (used for cube shadow vertex calculation worldPos - lightPos[i])

### var near
```cj
public var near: Float64 = 0.1
```
Shadow camera near (bound as u_pointShadowNearFar[i].x in main pass)

### var normalBias
```cj
public var normalBias: Float64 = 0.0
```
Per-light normal bias (from light.shadow.normalBias, used for vertex normal offset u_xxxShadowParams[i].y)

### var shadowMatrix
```cj
public var shadowMatrix: Matrix4 = Matrix4()
```
bias × lightViewProj matrix (bound as directionalShadowMatrix[i] / spotLightMatrix[i] in main pass)

### var size
```cj
public var size: Int64 = 0
```
Shadow framebuffer size

### var texture
```cj
public var texture: TextureHandle = TextureHandle(65535u16)
```
Shadow depth texture handle (2D or cube)

### var vsmDepthTexture
```cj
public var vsmDepthTexture: TextureHandle = TextureHandle(65535u16)
```
VSM depth texture (D32, native depth, written by depth pass)

### var vsmFinalFrameBuffer
```cj
public var vsmFinalFrameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
```
VSM horizontal blur output framebuffer (writes to texture=RG16F final result, sampled by main pass)

### var vsmPassFrameBuffer
```cj
public var vsmPassFrameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
```
VSM vertical blur output framebuffer (writes to vsmPassTexture)

### var vsmPassTexture
```cj
public var vsmPassTexture: TextureHandle = TextureHandle(65535u16)
```
VSM vertical blur output / horizontal blur input (RG16F intermediate result)

