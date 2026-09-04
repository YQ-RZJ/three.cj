# Type Alias
## type Access
```cj
public type Access = bgfx.Access
```
Resource access type (Read / Write / ReadWrite)

## type AllocatorInterface
```cj
public type AllocatorInterface = Box < bgfx.AllocatorInterface >
```
Allocator interface (opaque)

## type AttachmentPtr
```cj
public type AttachmentPtr = Box < CPointer < bgfx.Attachment >>
```
Frame buffer attachment info pointer (passed to isFrameBufferValid)

## type Attachment
```cj
public type Attachment = Box < bgfx.Attachment >
```
Frame buffer texture attachment info

## type AttribType
```cj
public type AttribType = bgfx.AttribType
```
Vertex attribute data type (Float / Half / Int16 / Uint8 ...)

## type Attrib
```cj
public type Attrib = bgfx.Attrib
```
Vertex attribute semantic (Position / Normal / TexCoord0 / Color0 ...)

## type BackbufferRatio
```cj
public type BackbufferRatio = bgfx.BackbufferRatio
```
Backbuffer ratio (Full / Half / Quarter ...)

## type CallbackInterface
```cj
public type CallbackInterface = Box < bgfx.CallbackInterface >
```
Callback interface (opaque)

## type CapsGpu
```cj
public type CapsGpu = Box < bgfx.CapsGpu >
```
GPU information (PCI vendor/device ID)

## type CapsLimits
```cj
public type CapsLimits = Box < bgfx.CapsLimits >
```
Renderer runtime limits (resource caps)

## type CapsPtr
```cj
public type CapsPtr = Box < CPointer < bgfx.Caps >>
```
Renderer capabilities pointer (returned by getCaps)

## type Caps
```cj
public type Caps = Box < bgfx.Caps >
```
Renderer capabilities info (rendererType / supported / limits etc.)

## type DynamicIndexBufferHandle
```cj
public type DynamicIndexBufferHandle = Box < bgfx.DynamicIndexBufferHandle >
```
Dynamic index buffer handle

## type DynamicVertexBufferHandle
```cj
public type DynamicVertexBufferHandle = Box < bgfx.DynamicVertexBufferHandle >
```
Dynamic vertex buffer handle

## type EncoderPtr
```cj
public type EncoderPtr = Box < CPointer < bgfx.Encoder >>
```
Render encoder pointer (passed/returned by encoder* series)

## type EncoderStats
```cj
public type EncoderStats = Box < bgfx.EncoderStats >
```
Encoder statistics

## type Encoder
```cj
public type Encoder = Box < bgfx.Encoder >
```
Render encoder

## type Fatal
```cj
public type Fatal = bgfx.Fatal
```
Fatal error type (for callbacks)

## type FrameBufferHandle
```cj
public type FrameBufferHandle = Box < bgfx.FrameBufferHandle >
```
Frame buffer handle

## type IndexBufferHandle
```cj
public type IndexBufferHandle = Box < bgfx.IndexBufferHandle >
```
Static index buffer handle

## type IndirectBufferHandle
```cj
public type IndirectBufferHandle = Box < bgfx.IndirectBufferHandle >
```
Indirect buffer handle

## type InitLimits
```cj
public type InitLimits = Box < bgfx.InitLimits >
```
Configurable runtime limit parameters

## type Init
```cj
public type Init = Box < bgfx.Init >
```
bgfx initialization parameters

## type InstanceDataBufferPtr
```cj
public type InstanceDataBufferPtr = Box < CPointer < bgfx.InstanceDataBuffer >>
```
Instance data buffer pointer (passed to setInstanceDataBuffer)

## type InstanceDataBuffer
```cj
public type InstanceDataBuffer = Box < bgfx.InstanceDataBuffer >
```
Instance data buffer

## type InternalDataPtr
```cj
public type InternalDataPtr = Box < CPointer < bgfx.InternalData >>
```
bgfx internal data pointer (returned by getInternalData)

## type InternalData
```cj
public type InternalData = Box < bgfx.InternalData >
```
bgfx internal data (caps pointer and context pointer)

## type Memory
```cj
public type Memory = Box < bgfx.Memory >
```
bgfx memory block (placeholder for mem parameter of createTexture2D/createVertexBuffer)

## type NativeWindowHandleType
```cj
public type NativeWindowHandleType = bgfx.NativeWindowHandleType
```
Native window handle type (Default / Wayland)

## type OcclusionQueryHandle
```cj
public type OcclusionQueryHandle = Box < bgfx.OcclusionQueryHandle >
```
Occlusion query handle

## type OcclusionQueryResult
```cj
public type OcclusionQueryResult = bgfx.OcclusionQueryResult
```
Occlusion query result (Invisible / Visible / NoResult)

## type PlatformDataPtr
```cj
public type PlatformDataPtr = Box < CPointer < bgfx.PlatformData >>
```
Platform data pointer (passed to setPlatformData)

## type PlatformData
```cj
public type PlatformData = Box < bgfx.PlatformData >
```
Platform data (native window handle nwh etc.)

## type ProgramHandle
```cj
public type ProgramHandle = Box < bgfx.ProgramHandle >
```
Program handle (linked vertex + fragment shader)

## type RenderFrame
```cj
public type RenderFrame = bgfx.RenderFrame
```
Render frame type (Render / Submit)

## type RendererType
```cj
public type RendererType = bgfx.RendererType
```
Renderer type (Direct3D11 / Vulkan / OpenGLES / Metal / Noop ...)

## type Resolution
```cj
public type Resolution = Box < bgfx.Resolution >
```
Backbuffer resolution and reset parameters

## type ShaderHandle
```cj
public type ShaderHandle = Box < bgfx.ShaderHandle >
```
Shader handle

## type StatsPtr
```cj
public type StatsPtr = Box < CPointer < bgfx.Stats >>
```
Renderer statistics pointer (returned by getStats)

## type Stats
```cj
public type Stats = Box < bgfx.Stats >
```
Renderer statistics

## type TextureFormat
```cj
public type TextureFormat = bgfx.TextureFormat
```
Texture format (RGBA8 / RGBA16F / D24 / D24S8 ...)

## type TextureHandle
```cj
public type TextureHandle = Box < bgfx.TextureHandle >
```
Texture handle

## type TextureInfoPtr
```cj
public type TextureInfoPtr = Box < CPointer < bgfx.TextureInfo >>
```
Texture info pointer (passed to createTexture / calcTextureSize)

## type TextureInfo
```cj
public type TextureInfo = Box < bgfx.TextureInfo >
```
Texture info (format / width / height / numMips etc.)

## type TopologyConvert
```cj
public type TopologyConvert = bgfx.TopologyConvert
```
Topology convert type (TriListFlipWinding / TriStripToTriList ...)

## type TopologySort
```cj
public type TopologySort = bgfx.TopologySort
```
Topology sort type (DirectionFrontToBackMin / DistanceBackToFrontAvg ...)

## type Topology
```cj
public type Topology = bgfx.Topology
```
Backend capability enum (GPU model name)

## type TransformPtr
```cj
public type TransformPtr = Box < CPointer < bgfx.Transform >>
```
Transform data pointer (for allocTransform / encoderAllocTransform)

## type Transform
```cj
public type Transform = Box < bgfx.Transform >
```
Transform data (matrix pointer)

## type TransientIndexBufferPtr
```cj
public type TransientIndexBufferPtr = Box < CPointer < bgfx.TransientIndexBuffer >>
```
Transient index buffer pointer (passed to setTransientIndexBuffer)

## type TransientIndexBuffer
```cj
public type TransientIndexBuffer = Box < bgfx.TransientIndexBuffer >
```
Transient index buffer

## type TransientVertexBufferPtr
```cj
public type TransientVertexBufferPtr = Box < CPointer < bgfx.TransientVertexBuffer >>
```
Transient vertex buffer pointer (passed to setTransientVertexBuffer)

## type TransientVertexBuffer
```cj
public type TransientVertexBuffer = Box < bgfx.TransientVertexBuffer >
```
Transient vertex buffer

## type UniformHandle
```cj
public type UniformHandle = Box < bgfx.UniformHandle >
```
Uniform handle

## type UniformInfoPtr
```cj
public type UniformInfoPtr = Box < CPointer < bgfx.UniformInfo >>
```
Uniform info pointer (passed to getUniformInfo)

## type UniformInfo
```cj
public type UniformInfo = Box < bgfx.UniformInfo >
```
Uniform variable info (name / type / num)

## type UniformType
```cj
public type UniformType = bgfx.UniformType
```
Uniform type (Sampler / Vec4 / Mat4 / Int1 ...)

## type UnitPtr
```cj
public type UnitPtr = Box < CPointer < Unit >>
```
void* pointer wrapper (for getInterface / getDirectAccessPtr etc.)

## type VertexBufferHandle
```cj
public type VertexBufferHandle = Box < bgfx.VertexBufferHandle >
```
Static vertex buffer handle

## type VertexLayoutHandle
```cj
public type VertexLayoutHandle = Box < bgfx.VertexLayoutHandle >
```
Vertex layout handle

## type VertexLayoutPtr
```cj
public type VertexLayoutPtr = Box < CPointer < bgfx.VertexLayout >>
```
Vertex layout pointer (passed to createDynamicVertexBuffer etc.)

## type VertexLayout
```cj
public type VertexLayout = Box < bgfx.VertexLayout >
```
Vertex layout (hash / stride / offset)

## type ViewMode
```cj
public type ViewMode = bgfx.ViewMode
```
View mode (Default / Sequential / Depth Ascending / Depth Descending)

## type ViewStats
```cj
public type ViewStats = Box < bgfx.ViewStats >
```
View statistics

