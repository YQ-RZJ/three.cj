# Class
## class Handle
```cj
public class Handle
```
bgfx type factory - unified construction entry for Box-wrapped types

### func attachment\(TextureHandle,UInt32,UInt16,UInt16,UInt16,UInt8\)
```cj
public static func attachment(handle: TextureHandle, access: UInt32, layer: UInt16, numLayers: UInt16, mip: UInt16, flags: UInt8): Attachment
```
Build and init an Attachment (bgfx_attachment_init inside)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|TextureHandle||
|access|UInt32||
|layer|UInt16||
|numLayers|UInt16||
|mip|UInt16||
|flags|UInt8||

### func dynamicIndexBuffer\(UInt16\)
```cj
public static func dynamicIndexBuffer(idx: UInt16): DynamicIndexBufferHandle
```
Construct a dynamic index buffer handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func dynamicVertexBuffer\(UInt16\)
```cj
public static func dynamicVertexBuffer(idx: UInt16): DynamicVertexBufferHandle
```
Construct a dynamic vertex buffer handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func framebuffer\(UInt16\)
```cj
public static func framebuffer(idx: UInt16): FrameBufferHandle
```
Construct a frame buffer handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func idx\(FrameBufferHandle\)
```cj
public static func idx(handle: FrameBufferHandle): UInt16
```
Get FrameBufferHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|FrameBufferHandle||

### func idx\(TextureHandle\)
```cj
public static func idx(handle: TextureHandle): UInt16
```
Get TextureHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|TextureHandle||

### func idx\(ProgramHandle\)
```cj
public static func idx(handle: ProgramHandle): UInt16
```
Get ProgramHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ProgramHandle||

### func idx\(UniformHandle\)
```cj
public static func idx(handle: UniformHandle): UInt16
```
Get UniformHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|UniformHandle||

### func idx\(VertexBufferHandle\)
```cj
public static func idx(handle: VertexBufferHandle): UInt16
```
Get VertexBufferHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|VertexBufferHandle||

### func idx\(IndexBufferHandle\)
```cj
public static func idx(handle: IndexBufferHandle): UInt16
```
Get IndexBufferHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|IndexBufferHandle||

### func idx\(VertexLayoutHandle\)
```cj
public static func idx(handle: VertexLayoutHandle): UInt16
```
Get VertexLayoutHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|VertexLayoutHandle||

### func idx\(DynamicVertexBufferHandle\)
```cj
public static func idx(handle: DynamicVertexBufferHandle): UInt16
```
Get DynamicVertexBufferHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicVertexBufferHandle||

### func idx\(DynamicIndexBufferHandle\)
```cj
public static func idx(handle: DynamicIndexBufferHandle): UInt16
```
Get DynamicIndexBufferHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicIndexBufferHandle||

### func idx\(ShaderHandle\)
```cj
public static func idx(handle: ShaderHandle): UInt16
```
Get ShaderHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ShaderHandle||

### func idx\(IndirectBufferHandle\)
```cj
public static func idx(handle: IndirectBufferHandle): UInt16
```
Get IndirectBufferHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|IndirectBufferHandle||

### func idx\(OcclusionQueryHandle\)
```cj
public static func idx(handle: OcclusionQueryHandle): UInt16
```
Get OcclusionQueryHandle internal idx (for debug logging only; use isValid for validity check)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|OcclusionQueryHandle||

### func indexBuffer\(UInt16\)
```cj
public static func indexBuffer(idx: UInt16): IndexBufferHandle
```
Construct an index buffer handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func initParams\(\)
```cj
public static func initParams(): Init
```
Build an Init value snapshot filled by bgfx_init_ctor (no pointer exposure)

### func isValid\(FrameBufferHandle\)
```cj
public static func isValid(handle: FrameBufferHandle): Bool
```
Check if FrameBufferHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|FrameBufferHandle||

### func isValid\(TextureHandle\)
```cj
public static func isValid(handle: TextureHandle): Bool
```
Check if TextureHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|TextureHandle||

### func isValid\(ProgramHandle\)
```cj
public static func isValid(handle: ProgramHandle): Bool
```
Check if ProgramHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ProgramHandle||

### func isValid\(UniformHandle\)
```cj
public static func isValid(handle: UniformHandle): Bool
```
Check if UniformHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|UniformHandle||

### func isValid\(VertexBufferHandle\)
```cj
public static func isValid(handle: VertexBufferHandle): Bool
```
Check if VertexBufferHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|VertexBufferHandle||

### func isValid\(IndexBufferHandle\)
```cj
public static func isValid(handle: IndexBufferHandle): Bool
```
Check if IndexBufferHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|IndexBufferHandle||

### func isValid\(VertexLayoutHandle\)
```cj
public static func isValid(handle: VertexLayoutHandle): Bool
```
Check if VertexLayoutHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|VertexLayoutHandle||

### func isValid\(DynamicVertexBufferHandle\)
```cj
public static func isValid(handle: DynamicVertexBufferHandle): Bool
```
Check if DynamicVertexBufferHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicVertexBufferHandle||

### func isValid\(DynamicIndexBufferHandle\)
```cj
public static func isValid(handle: DynamicIndexBufferHandle): Bool
```
Check if DynamicIndexBufferHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicIndexBufferHandle||

### func isValid\(ShaderHandle\)
```cj
public static func isValid(handle: ShaderHandle): Bool
```
Check if ShaderHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ShaderHandle||

### func isValid\(IndirectBufferHandle\)
```cj
public static func isValid(handle: IndirectBufferHandle): Bool
```
Check if IndirectBufferHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|IndirectBufferHandle||

### func isValid\(OcclusionQueryHandle\)
```cj
public static func isValid(handle: OcclusionQueryHandle): Bool
```
Check if OcclusionQueryHandle is valid (idx != 0xFFFF)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|OcclusionQueryHandle||

### func program\(UInt16\)
```cj
public static func program(idx: UInt16): ProgramHandle
```
Construct a program handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func shader\(UInt16\)
```cj
public static func shader(idx: UInt16): ShaderHandle
```
Construct a shader handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func swapChain\(CPointer<Unit>,UInt32,UInt32,UInt32,UInt32\)
```cj
public static func swapChain(nwh: CPointer < Unit >, width: UInt32, height: UInt32, formatColor: UInt32, formatDepthStencil: UInt32): SwapChain
```
Build a SwapChain value snapshot (no pointer exposure)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|nwh|CPointer<Unit>||
|width|UInt32||
|height|UInt32||
|formatColor|UInt32||
|formatDepthStencil|UInt32||

### func textureRegion\(TextureHandle,UInt16,UInt16,UInt16,UInt16,UInt8\)
```cj
public static func textureRegion(handle: TextureHandle, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mip: UInt8): TextureRegion
```
Build a TextureRegion value snapshot (bgfx_texture_region_init inside)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|TextureHandle||
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|mip|UInt8||

### func texture\(UInt16\)
```cj
public static func texture(idx: UInt16): TextureHandle
```
Construct a texture handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func uniform\(UInt16\)
```cj
public static func uniform(idx: UInt16): UniformHandle
```
Construct a uniform handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func vertexBuffer\(UInt16\)
```cj
public static func vertexBuffer(idx: UInt16): VertexBufferHandle
```
Construct a vertex buffer handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

### func vertexLayout\(UInt16\)
```cj
public static func vertexLayout(idx: UInt16): VertexLayoutHandle
```
Construct a vertex layout handle from idx (Box-wrapped)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|UInt16||

