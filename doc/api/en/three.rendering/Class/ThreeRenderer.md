# Class
## class ThreeRenderer
```cj
public class ThreeRenderer <: Renderer & IRenderer
```
bgfx renderer — thin Renderer implementation

### func attachmentInit\(CPointer<bgfx\.Attachment>,TextureHandle,UInt32,UInt16,UInt16,UInt16,UInt8\)
```cj
public func attachmentInit(attachment: CPointer < bgfx.Attachment >, tex: TextureHandle, access: UInt32, layer: UInt16, numLayers: UInt16, mip: UInt16, resolve: UInt8): Unit
```
Initialize Attachment structure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attachment|CPointer<bgfx.Attachment>||
|tex|TextureHandle||
|access|UInt32||
|layer|UInt16||
|numLayers|UInt16||
|mip|UInt16||
|resolve|UInt8||

### func bindTexture\(UInt8,UniformHandle,TextureHandle,UInt32\)
```cj
public func bindTexture(stage: UInt8, sampler: UniformHandle, tex: TextureHandle, flags: UInt32): Unit
```
Bind texture to specified stage sampler

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8|Texture stage (0..MAX_TEXTURE_SAMPLERS-1)sampler Sampler uniform handletex Texture handle to bindflags Sampler flags (e.g. SAMPLER_U_CLAMP|SAMPLER_V_CLAMP, 0 for texture default)|
|sampler|UniformHandle||
|tex|TextureHandle||
|flags|UInt32||

### func blitTexture\(UInt16,TextureHandle,TextureHandle,UInt16,UInt16\)
```cj
public func blitTexture(viewId: UInt16, dst: TextureHandle, src: TextureHandle, width: UInt16, height: UInt16): Unit
```
Blit copy: copy src texture region to dst texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view iddst Destination texture (Box-wrapped handle)src Source texture (Box-wrapped handle)width Copy width (pixels)height Copy height (pixels)|
|dst|TextureHandle||
|src|TextureHandle||
|width|UInt16||
|height|UInt16||

### func calcTextureSize\(CPointer<bgfx\.TextureInfo>,UInt16,UInt16,UInt16,Bool,Bool,UInt16,UInt32\)
```cj
public func calcTextureSize(info: CPointer < bgfx.TextureInfo >, width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool, numLayers: UInt16, format: UInt32): Unit
```
Calculate texture storage size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|CPointer<bgfx.TextureInfo>|output TextureInfo pointerwidth widthheight heightdepth depthcubeMap whether it is a cubemaphasMips whether mipmappednumLayers layer countformat texture format|
|width|UInt16||
|height|UInt16||
|depth|UInt16||
|cubeMap|Bool||
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||

### func createComputeProgram\(ShaderHandle,Bool\)
```cj
public func createComputeProgram(csh: ShaderHandle, destroyShaders: Bool): ProgramHandle
```
Create program from compute shader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|csh|ShaderHandle||
|destroyShaders|Bool||

### func createDynamicIndexBufferMem\(Option<BgfxMemory>,UInt16\)
```cj
public func createDynamicIndexBufferMem(mem: Option < BgfxMemory >, flags: UInt16): DynamicIndexBufferHandle
```
Create dynamic index buffer from memory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|Option<BgfxMemory>||
|flags|UInt16||

### func createDynamicIndexBuffer\(UInt32,UInt16\)
```cj
public func createDynamicIndexBuffer(num: UInt32, flags: UInt16): DynamicIndexBufferHandle
```
Create dynamic index buffer (size only)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32||
|flags|UInt16||

### func createDynamicVertexBufferMem\(Option<BgfxMemory>,VertexLayoutPtr,UInt16\)
```cj
public func createDynamicVertexBufferMem(mem: Option < BgfxMemory >, layout: VertexLayoutPtr, flags: UInt16): DynamicVertexBufferHandle
```
Create dynamic vertex buffer from memory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|Option<BgfxMemory>|vertex data memory (Some=data; None=empty)layout vertex layout pointerflags 缓冲 flags|
|layout|VertexLayoutPtr||
|flags|UInt16||

Return: 

- 动态vertex buffer handle

### func createDynamicVertexBuffer\(UInt32,VertexLayoutPtr,UInt16\)
```cj
public func createDynamicVertexBuffer(num: UInt32, layout: VertexLayoutPtr, flags: UInt16): DynamicVertexBufferHandle
```
Create dynamic vertex buffer (size only, data filled by subsequent update)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32|vertex countlayout vertex layout pointer (CPointer<bgfx.VertexLayout>)flags buffer flags (BUFFER_* combination)|
|layout|VertexLayoutPtr||
|flags|UInt16||

Return: 

- 动态vertex buffer handle

### func createFrameBufferFromAttachment\(Array<Attachment>,Bool\)
```cj
public func createFrameBufferFromAttachment(attachments: Array < Attachment >, destroyTexture: Bool): FrameBufferHandle
```
Create Frame buffer from attachment list

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attachments|Array<Attachment>|attachment array (Box-wrapped Attachment)destroyTexture whether to auto-destroy attachment textures when FB is destroyed|
|destroyTexture|Bool||

Return: 

- Frame buffer handle

### func createFrameBufferFromNwh\(CPointer<Unit>,UInt16,UInt16,UInt32,UInt32\)
```cj
public func createFrameBufferFromNwh(nwh: CPointer < Unit >, width: UInt16, height: UInt16, format: UInt32, depthFormat: UInt32): FrameBufferHandle
```
Create Frame buffer from native window handle (offscreen window rendering)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|nwh|CPointer<Unit>||
|width|UInt16||
|height|UInt16||
|format|UInt32||
|depthFormat|UInt32||

### func createFrameBufferScaled\(UInt32,UInt32,UInt64\)
```cj
public func createFrameBufferScaled(ratio: UInt32, format: UInt32, textureFlags: UInt64): FrameBufferHandle
```
Create Frame buffer (scaled by backbuffer ratio)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ratio|UInt32||
|format|UInt32||
|textureFlags|UInt64||

### func createFrameBuffer\(UInt16,UInt16,UInt32,UInt64\)
```cj
public func createFrameBuffer(w: UInt16, h: UInt16, format: UInt32, depthFlags: UInt64): FrameBufferHandle
```
Create empty Frame buffer by width and height

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|UInt16|Width (pixels)h Height (pixels)format Texture formatdepthFlags Depth attachment flags|
|h|UInt16||
|format|UInt32||
|depthFlags|UInt64||

Return: 

- Frame buffer handle

### func createFrameBuffer\(UInt8,Array<TextureHandle>,Bool\)
```cj
public func createFrameBuffer(numAttachments: UInt8, handles: Array < TextureHandle >, destroyHandles: Bool): FrameBufferHandle
```
Create Frame buffer from multiple texture handles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numAttachments|UInt8|Number of attachmentshandles Attachment texture handle arraydestroyHandles Whether bgfx auto-destroys these texture handles when FB is destroyed|
|handles|Array<TextureHandle>||
|destroyHandles|Bool||

Return: 

- Frame buffer handle

### func createIndexBuffer\(BgfxMemory,UInt16\)
```cj
public func createIndexBuffer(mem: BgfxMemory, flags!: UInt16 = 0u16): IndexBufferHandle
```
Create index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|BgfxMemory|index data memoryflags buffer flags (default 0)|
|flags|UInt16||

Return: 

- index buffer handle

### func createIndirectBuffer\(UInt32\)
```cj
public func createIndirectBuffer(num: UInt32): IndirectBufferHandle
```
Create indirect draw buffer (GPU-generated draw parameters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt32||

### func createOcclusionQuery\(\)
```cj
public func createOcclusionQuery(): OcclusionQueryHandle
```
Create occlusion query

### func createProgram\(ShaderHandle,ShaderHandle,Bool\)
```cj
public func createProgram(vsh: ShaderHandle, fsh: ShaderHandle, destroyShaders: Bool): ProgramHandle
```
Link program from vertex + fragment shader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vsh|ShaderHandle|Vertex shader handlefsh Fragment shader handledestroyShaders whether to destroy input shaders after linking|
|fsh|ShaderHandle||
|destroyShaders|Bool||

Return: 

- program handle

### func createShader\(BgfxMemory\)
```cj
public func createShader(mem: BgfxMemory): ShaderHandle
```
Create shader from binary source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|BgfxMemory|shader binary data (BgfxMemory)|

Return: 

- shader handle

### func createTexture2DScaled\(UInt32,Bool,UInt16,UInt32,UInt64\)
```cj
public func createTexture2DScaled(ratio: UInt32, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): TextureHandle
```
Create 2D texture (scaled by backbuffer ratio)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ratio|UInt32|BackbufferRatio.value() (Half/Quarter/Eighth/Sixteenth/Double)hasMips whether to generate mipmapsnumLayers layer count (default 1)format texture format（TextureFormat.value()）flags texture flags (TEXTURE_RT | SAMPLER_* combination)|
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||

Return: 

- texture handle

### func createTexture2D\(UInt16,UInt16,Bool,UInt16,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
Create 2D texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|UInt16|Texture width (pixels)h Texture height (pixels)hasMips Whether to generate mipmapsnumLayers Number of layers (1=plain 2D texture)format Texture formatflags Texture flagsmem Texture data memory (null for empty RT)|
|h|UInt16||
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

Return: 

- Texture handle

### func createTexture3D\(UInt16,UInt16,UInt16,Bool,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture3D(w: UInt16, h: UInt16, d: UInt16, hasMips: Bool, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
Create 3D texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|UInt16|Texture width (pixels)h Texture height (pixels)d Texture depth (layers)hasMips Whether to generate mipmapsformat Texture formatflags Texture flagsmem Texture data memory (Some=data; None=empty 3D RT)|
|h|UInt16||
|d|UInt16||
|hasMips|Bool||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

Return: 

- 3D texture handle

### func createTextureCube\(UInt16,Bool,UInt16,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTextureCube(side: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
Create cube texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|side|UInt16|Cube face side length (pixels)hasMips Whether to generate mipmapsnumLayers Number of layersformat Texture formatflags Texture flagsmem 6-face continuous pixel data (null for empty cube RT)|
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

Return: 

- Cube texture handle

### func createTexture\(Option<BgfxMemory>,UInt64,UInt8,TextureInfoPtr\)
```cj
public func createTexture(mem: Option < BgfxMemory >, flags: UInt64, skip: UInt8, info: TextureInfoPtr): TextureHandle
```
Create texture from TextureInfo (generic entry)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|Option<BgfxMemory>|texture data memory (Some=data; None=empty RT)flags texture flagsskip number of mips to skipinfo texture info pointer (TextureInfo)|
|flags|UInt64||
|skip|UInt8||
|info|TextureInfoPtr||

Return: 

- texture handle

### func createUniform\(String,UInt32,UInt16\)
```cj
public func createUniform(name: String, uniformType: UInt32, num!: UInt16 = 1u16): UniformHandle
```
Create uniform handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|uniform nameuniformType UniformType.value()（Sampler/Vec4/Mat3/Mat4 等）num array length (default 1)|
|uniformType|UInt32||
|num|UInt16||

Return: 

- uniform handle

### func createVertexBufferFromLayout\(BgfxMemory,VertexLayoutHandle,UInt16\)
```cj
public func createVertexBufferFromLayout(mem: BgfxMemory, layout: VertexLayoutHandle, flags!: UInt16 = 0u16): VertexBufferHandle
```
Create vertex buffer using layout handle (safe wrapper, no layout pointer management needed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|BgfxMemory|vertex data memory (wrapped by bgfx_make_ref_cj)layout layout handle created by renderer.createVertexLayoutflags buffer flags (default 0)|
|layout|VertexLayoutHandle||
|flags|UInt16||

Return: 

- vertex buffer handle（Invalid handle if layout does not exist）

### func createVertexBuffer\(BgfxMemory,VertexLayoutHandle,UInt16\)
```cj
public func createVertexBuffer(mem: BgfxMemory, layout: VertexLayoutHandle, flags!: UInt16 = 0u16): VertexBufferHandle
```
Create vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mem|BgfxMemory|vertex data memory (wrapped by bgfx_make_ref_cj)layout Vertex layout memory pointer (CPointer<VertexLayout>)flags buffer flags (default 0)|
|layout|VertexLayoutHandle||
|flags|UInt16||

Return: 

- vertex buffer handle

### func createVertexLayout\(Array<BgfxAttributeDesc>\)
```cj
public func createVertexLayout(attributes: Array < BgfxAttributeDesc >): VertexLayoutHandle
```
Create vertex layout from attribute description list

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|attribute description list (BgfxAttributeDesc)|

Return: 

- vertex layout handle (invalid if idx=65535)

### func dbgTextClear\(UInt8,Bool\)
```cj
public func dbgTextClear(attr: UInt8, small: Bool): Unit
```
Clear debug text

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attr|UInt8||
|small|Bool||

### func dbgTextImage\(UInt16,UInt16,UInt16,UInt16,UnitPtr,UInt16\)
```cj
public func dbgTextImage(x: UInt16, y: UInt16, width: UInt16, height: UInt16, data: UnitPtr, pitch: UInt16): Unit
```
Draw debug text image (8bit per pixel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|data|UnitPtr||
|pitch|UInt16||

### func dbgTextPrintf\(UInt16,UInt16,UInt8,String\)
```cj
public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit
```
Output formatted debug text (C-style format string)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|UInt16||
|y|UInt16||
|attr|UInt8||
|format|String||

### func dbgTextVprintf\(UInt16,UInt16,UInt8,String,UnitPtr\)
```cj
public func dbgTextVprintf(x: UInt16, y: UInt16, attr: UInt8, format: String, argList: UnitPtr): Unit
```
Output formatted debug text (va_list version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|UInt16||
|y|UInt16||
|attr|UInt8||
|format|String||
|argList|UnitPtr||

### func destroyDynamicIndexBuffer\(DynamicIndexBufferHandle\)
```cj
public func destroyDynamicIndexBuffer(handle: DynamicIndexBufferHandle): Unit
```
Destroy dynamic index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicIndexBufferHandle||

### func destroyDynamicVertexBuffer\(DynamicVertexBufferHandle\)
```cj
public func destroyDynamicVertexBuffer(handle: DynamicVertexBufferHandle): Unit
```
Destroy dynamic vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicVertexBufferHandle||

### func destroyFrameBuffer\(FrameBufferHandle\)
```cj
public func destroyFrameBuffer(fb: FrameBufferHandle): Unit
```
Destroy Frame buffer handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fb|FrameBufferHandle|待销毁 Frame buffer handle|

### func destroyIndexBuffer\(IndexBufferHandle\)
```cj
public func destroyIndexBuffer(ib: IndexBufferHandle): Unit
```
Destroy index buffer handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ib|IndexBufferHandle|index buffer handle to destroy|

### func destroyIndirectBuffer\(IndirectBufferHandle\)
```cj
public func destroyIndirectBuffer(handle: IndirectBufferHandle): Unit
```
Destroy indirect draw buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|IndirectBufferHandle||

### func destroyOcclusionQuery\(OcclusionQueryHandle\)
```cj
public func destroyOcclusionQuery(handle: OcclusionQueryHandle): Unit
```
Destroy occlusion query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|OcclusionQueryHandle||

### func destroyProgram\(ProgramHandle\)
```cj
public func destroyProgram(handle: ProgramHandle): Unit
```
Destroy program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ProgramHandle||

### func destroyShader\(ShaderHandle\)
```cj
public func destroyShader(handle: ShaderHandle): Unit
```
Destroy shader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ShaderHandle||

### func destroyTexture\(TextureHandle\)
```cj
public func destroyTexture(tex: TextureHandle): Unit
```
Destroy texture handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle|Texture handle to destroy|

### func destroyUniform\(UniformHandle\)
```cj
public func destroyUniform(handle: UniformHandle): Unit
```
Destroy uniform handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|UniformHandle||

### func destroyVertexBuffer\(VertexBufferHandle\)
```cj
public func destroyVertexBuffer(vb: VertexBufferHandle): Unit
```
Destroy vertex buffer handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vb|VertexBufferHandle|待销毁vertex buffer handle|

### func destroyVertexLayout\(VertexLayoutHandle\)
```cj
public func destroyVertexLayout(layout: VertexLayoutHandle): Unit
```
Destroy vertex layout handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layout|VertexLayoutHandle|vertex layout handle to destroy|

### func discard\(UInt8\)
```cj
public func discard(flags: UInt8): Unit
```
Discard specified state groups for current draw (optimization hint to bgfx)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|UInt8||

### func dispatchIndirect\(UInt16,ProgramHandle,IndirectBufferHandle,UInt32,UInt32,UInt8\)
```cj
public func dispatchIndirect(viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle, start: UInt32, num: UInt32, flags!: UInt8 = 0xFFu8): Unit
```
Submit indirect compute dispatch

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16||
|program|ProgramHandle||
|indirect|IndirectBufferHandle||
|start|UInt32||
|num|UInt32||
|flags|UInt8||

### func dispatch\(UInt16,ProgramHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func dispatch(viewId: UInt16, program: ProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags!: UInt8 = 0xFFu8): Unit
```
Submit compute dispatch

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16||
|program|ProgramHandle||
|numX|UInt32||
|numY|UInt32||
|numZ|UInt32||
|flags|UInt8||

### func encoderAllocTransform\(EncoderPtr,TransformPtr,UInt16\)
```cj
public func encoderAllocTransform(encoder: EncoderPtr, transform: TransformPtr, num: UInt16): UInt32
```
Allocate transform matrix in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|transform|TransformPtr||
|num|UInt16||

### func encoderBegin\(Bool\)
```cj
public func encoderBegin(forThread: Bool): EncoderPtr
```
Get encoder instance (for multi-threaded rendering)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|forThread|Bool||

### func encoderBlit\(EncoderPtr,UInt16,TextureHandle,UInt8,UInt16,UInt16,UInt16,TextureHandle,UInt8,UInt16,UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func encoderBlit(encoder: EncoderPtr, id: UInt16, dst: TextureHandle, dstMip: UInt8, dstX: UInt16, dstY: UInt16, dstZ: UInt16, src: TextureHandle, srcMip: UInt8, srcX: UInt16, srcY: UInt16, srcZ: UInt16, width: UInt16, height: UInt16, depth: UInt16): Unit
```
Blit texture region in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|dst|TextureHandle||
|dstMip|UInt8||
|dstX|UInt16||
|dstY|UInt16||
|dstZ|UInt16||
|src|TextureHandle||
|srcMip|UInt8||
|srcX|UInt16||
|srcY|UInt16||
|srcZ|UInt16||
|width|UInt16||
|height|UInt16||
|depth|UInt16||

### func encoderDiscard\(EncoderPtr,UInt8\)
```cj
public func encoderDiscard(encoder: EncoderPtr, flags: UInt8): Unit
```
Discard state groups in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|flags|UInt8||

### func encoderDispatchIndirect\(EncoderPtr,UInt16,ProgramHandle,IndirectBufferHandle,UInt32,UInt32,UInt8\)
```cj
public func encoderDispatchIndirect(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, flags: UInt8): Unit
```
Submit indirect compute dispatch in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|program|ProgramHandle||
|indirectHandle|IndirectBufferHandle||
|start|UInt32||
|num|UInt32||
|flags|UInt8||

### func encoderDispatch\(EncoderPtr,UInt16,ProgramHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func encoderDispatch(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags: UInt8): Unit
```
Submit compute dispatch in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|program|ProgramHandle||
|numX|UInt32||
|numY|UInt32||
|numZ|UInt32||
|flags|UInt8||

### func encoderEnd\(EncoderPtr\)
```cj
public func encoderEnd(encoder: EncoderPtr): Unit
```
End and submit encoder commands

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||

### func encoderSetComputeDynamicIndexBuffer\(EncoderPtr,UInt8,DynamicIndexBufferHandle,UInt32\)
```cj
public func encoderSetComputeDynamicIndexBuffer(encoder: EncoderPtr, stage: UInt8, handle: DynamicIndexBufferHandle, access: UInt32): Unit
```
Bind compute dynamic index buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|DynamicIndexBufferHandle||
|access|UInt32||

### func encoderSetComputeDynamicVertexBuffer\(EncoderPtr,UInt8,DynamicVertexBufferHandle,UInt32\)
```cj
public func encoderSetComputeDynamicVertexBuffer(encoder: EncoderPtr, stage: UInt8, handle: DynamicVertexBufferHandle, access: UInt32): Unit
```
Bind compute dynamic vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|DynamicVertexBufferHandle||
|access|UInt32||

### func encoderSetComputeIndexBuffer\(EncoderPtr,UInt8,IndexBufferHandle,UInt32\)
```cj
public func encoderSetComputeIndexBuffer(encoder: EncoderPtr, stage: UInt8, handle: IndexBufferHandle, access: UInt32): Unit
```
Bind compute index buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|IndexBufferHandle||
|access|UInt32||

### func encoderSetComputeIndirectBuffer\(EncoderPtr,UInt8,IndirectBufferHandle,UInt32\)
```cj
public func encoderSetComputeIndirectBuffer(encoder: EncoderPtr, stage: UInt8, handle: IndirectBufferHandle, access: UInt32): Unit
```
Bind compute indirect buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|IndirectBufferHandle||
|access|UInt32||

### func encoderSetComputeVertexBuffer\(EncoderPtr,UInt8,VertexBufferHandle,UInt32\)
```cj
public func encoderSetComputeVertexBuffer(encoder: EncoderPtr, stage: UInt8, handle: VertexBufferHandle, access: UInt32): Unit
```
Bind compute vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|VertexBufferHandle||
|access|UInt32||

### func encoderSetCondition\(EncoderPtr,OcclusionQueryHandle,Bool\)
```cj
public func encoderSetCondition(encoder: EncoderPtr, handle: OcclusionQueryHandle, visible: Bool): Unit
```
Set occlusion query condition in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|handle|OcclusionQueryHandle||
|visible|Bool||

### func encoderSetDynamicIndexBuffer\(EncoderPtr,DynamicIndexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetDynamicIndexBuffer(encoder: EncoderPtr, handle: DynamicIndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit
```
Set dynamic index buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|handle|DynamicIndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func encoderSetDynamicVertexBufferWithLayout\(EncoderPtr,UInt8,DynamicVertexBufferHandle,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func encoderSetDynamicVertexBufferWithLayout(encoder: EncoderPtr, stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
Set dynamic vertex buffer with layout in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stream|UInt8||
|handle|DynamicVertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||
|layoutHandle|VertexLayoutHandle||

### func encoderSetDynamicVertexBuffer\(EncoderPtr,UInt8,DynamicVertexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetDynamicVertexBuffer(encoder: EncoderPtr, stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit
```
Set dynamic vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stream|UInt8||
|handle|DynamicVertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func encoderSetImage\(EncoderPtr,UInt8,TextureHandle,UInt8,UInt32,UInt32\)
```cj
public func encoderSetImage(encoder: EncoderPtr, stage: UInt8, handle: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit
```
Bind image in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|TextureHandle||
|mip|UInt8||
|access|UInt32||
|format|UInt32||

### func encoderSetIndexBuffer\(EncoderPtr,IndexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetIndexBuffer(encoder: EncoderPtr, handle: IndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit
```
Set index buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|handle|IndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func encoderSetInstanceCount\(EncoderPtr,UInt32\)
```cj
public func encoderSetInstanceCount(encoder: EncoderPtr, numInstances: UInt32): Unit
```
Set instance count in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|numInstances|UInt32||

### func encoderSetInstanceDataBuffer\(EncoderPtr,InstanceDataBufferPtr,UInt32,UInt32\)
```cj
public func encoderSetInstanceDataBuffer(encoder: EncoderPtr, idb: InstanceDataBufferPtr, start: UInt32, num: UInt32): Unit
```
Set instance data buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|idb|InstanceDataBufferPtr||
|start|UInt32||
|num|UInt32||

### func encoderSetInstanceDataFromDynamicVertexBuffer\(EncoderPtr,DynamicVertexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetInstanceDataFromDynamicVertexBuffer(encoder: EncoderPtr, handle: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
Set instance data from dynamic vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|handle|DynamicVertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func encoderSetInstanceDataFromVertexBuffer\(EncoderPtr,VertexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetInstanceDataFromVertexBuffer(encoder: EncoderPtr, handle: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
Set instance data from vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|handle|VertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func encoderSetMarker\(EncoderPtr,String\)
```cj
public func encoderSetMarker(encoder: EncoderPtr, name: String): Unit
```
Set debug marker in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|name|String||

### func encoderSetScissorCached\(EncoderPtr,UInt16\)
```cj
public func encoderSetScissorCached(encoder: EncoderPtr, cache: UInt16): Unit
```
Reuse cached scissor rectangle in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|cache|UInt16||

### func encoderSetScissor\(EncoderPtr,UInt16,UInt16,UInt16,UInt16\)
```cj
public func encoderSetScissor(encoder: EncoderPtr, x: UInt16, y: UInt16, width: UInt16, height: UInt16): UInt16
```
Set scissor rectangle in encoder (returns cache index)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||

### func encoderSetState\(EncoderPtr,UInt64,UInt32\)
```cj
public func encoderSetState(encoder: EncoderPtr, state: UInt64, rgba: UInt32): Unit
```
Set render state in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|state|UInt64||
|rgba|UInt32||

### func encoderSetStencil\(EncoderPtr,UInt32,UInt32\)
```cj
public func encoderSetStencil(encoder: EncoderPtr, fstencil: UInt32, bstencil: UInt32): Unit
```
Set stencil state in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|fstencil|UInt32||
|bstencil|UInt32||

### func encoderSetTexture\(EncoderPtr,UInt8,UniformHandle,TextureHandle,UInt32\)
```cj
public func encoderSetTexture(encoder: EncoderPtr, stage: UInt8, sampler: UniformHandle, handle: TextureHandle, flags: UInt32): Unit
```
Bind texture in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|sampler|UniformHandle||
|handle|TextureHandle||
|flags|UInt32||

### func encoderSetTransformCached\(EncoderPtr,UInt32,UInt16\)
```cj
public func encoderSetTransformCached(encoder: EncoderPtr, cache: UInt32, num: UInt16): Unit
```
Reuse cached transform in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|cache|UInt32||
|num|UInt16||

### func encoderSetTransform\(EncoderPtr,BgfxMemory,UInt16\)
```cj
public func encoderSetTransform(encoder: EncoderPtr, mtx: BgfxMemory, num: UInt16): UInt32
```
Set transform matrix in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|mtx|BgfxMemory||
|num|UInt16||

### func encoderSetTransientIndexBuffer\(EncoderPtr,TransientIndexBufferPtr,UInt32,UInt32\)
```cj
public func encoderSetTransientIndexBuffer(encoder: EncoderPtr, tib: TransientIndexBufferPtr, firstIndex: UInt32, numIndices: UInt32): Unit
```
Set transient index buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|tib|TransientIndexBufferPtr||
|firstIndex|UInt32||
|numIndices|UInt32||

### func encoderSetTransientVertexBufferWithLayout\(EncoderPtr,UInt8,TransientVertexBufferPtr,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func encoderSetTransientVertexBufferWithLayout(encoder: EncoderPtr, stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
Set transient vertex buffer with layout in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stream|UInt8||
|tvb|TransientVertexBufferPtr||
|startVertex|UInt32||
|numVertices|UInt32||
|layoutHandle|VertexLayoutHandle||

### func encoderSetTransientVertexBuffer\(EncoderPtr,UInt8,TransientVertexBufferPtr,UInt32,UInt32\)
```cj
public func encoderSetTransientVertexBuffer(encoder: EncoderPtr, stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32): Unit
```
Set transient vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stream|UInt8||
|tvb|TransientVertexBufferPtr||
|startVertex|UInt32||
|numVertices|UInt32||

### func encoderSetUniform\(EncoderPtr,UniformHandle,BgfxMemory,UInt16\)
```cj
public func encoderSetUniform(encoder: EncoderPtr, handle: UniformHandle, value: BgfxMemory, num: UInt16): Unit
```
Set uniform in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|handle|UniformHandle||
|value|BgfxMemory||
|num|UInt16||

### func encoderSetVertexBufferWithLayout\(EncoderPtr,UInt8,VertexBufferHandle,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func encoderSetVertexBufferWithLayout(encoder: EncoderPtr, stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
Set vertex buffer with layout in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stream|UInt8||
|handle|VertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||
|layoutHandle|VertexLayoutHandle||

### func encoderSetVertexBuffer\(EncoderPtr,UInt8,VertexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetVertexBuffer(encoder: EncoderPtr, stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit
```
Set vertex buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|stream|UInt8||
|handle|VertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func encoderSetVertexCount\(EncoderPtr,UInt32\)
```cj
public func encoderSetVertexCount(encoder: EncoderPtr, numVertices: UInt32): Unit
```
Set vertex count in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|numVertices|UInt32||

### func encoderSubmitIndirectCount\(EncoderPtr,UInt16,ProgramHandle,IndirectBufferHandle,UInt32,IndexBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func encoderSubmitIndirectCount(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32, depth: UInt32, flags: UInt8): Unit
```
Submit indirect draw with count buffer in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|program|ProgramHandle||
|indirectHandle|IndirectBufferHandle||
|start|UInt32||
|numHandle|IndexBufferHandle||
|numIndex|UInt32||
|numMax|UInt32||
|depth|UInt32||
|flags|UInt8||

### func encoderSubmitIndirect\(EncoderPtr,UInt16,ProgramHandle,IndirectBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func encoderSubmitIndirect(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, depth: UInt32, flags: UInt8): Unit
```
Submit indirect draw in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|program|ProgramHandle||
|indirectHandle|IndirectBufferHandle||
|start|UInt32||
|num|UInt32||
|depth|UInt32||
|flags|UInt8||

### func encoderSubmitOcclusionQuery\(EncoderPtr,UInt16,ProgramHandle,OcclusionQueryHandle,UInt32,UInt8\)
```cj
public func encoderSubmitOcclusionQuery(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, occlusionQuery: OcclusionQueryHandle, depth: UInt32, flags: UInt8): Unit
```
Submit draw with occlusion query in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|program|ProgramHandle||
|occlusionQuery|OcclusionQueryHandle||
|depth|UInt32||
|flags|UInt8||

### func encoderSubmit\(EncoderPtr,UInt16,ProgramHandle,UInt32,UInt8\)
```cj
public func encoderSubmit(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, depth: UInt32, flags: UInt8): Unit
```
Submit draw in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||
|program|ProgramHandle||
|depth|UInt32||
|flags|UInt8||

### func encoderTouch\(EncoderPtr,UInt16\)
```cj
public func encoderTouch(encoder: EncoderPtr, id: UInt16): Unit
```
Touch view in encoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||

### func execBgfx\(\(\)\->Unit\)
```cj
public func execBgfx(cmd:() -> Unit): Unit
```
Public thread serialization entry: external modules' bgfx API calls queued to render thread

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cmd|()->Unit|bgfx call closure to execute|

### func getCaps\(\)
```cj
public func getCaps(): CapsPtr
```
Get renderer capabilities (CPointer, caller responsible for reading fields)

### func getDirectAccessPtr\(TextureHandle\)
```cj
public func getDirectAccessPtr(tex: TextureHandle): UnitPtr
```
Get texture direct access pointer (zero-copy texture read)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle||

### func getInterface\(UInt32\)
```cj
public func getInterface(version: UInt32): UnitPtr
```
Get bgfx extension interface (returns interface pointer if version matches)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|version|UInt32||

### func getInternalData\(\)
```cj
public func getInternalData(): InternalDataPtr
```
Get bgfx internal data (caps/context pointer)

### func getOcclusionQueryResult\(OcclusionQueryHandle,PtrArray<Int32>\)
```cj
public func getOcclusionQueryResult(handle: OcclusionQueryHandle, result: PtrArray < Int32 >): UInt32
```
Get occlusion query result

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|OcclusionQueryHandle|occlusion query handleresult output result pointer (Int32: visible pixel count or 0)|
|result|PtrArray<Int32>||

Return: 

- Result status (0=not ready, 1=ready, OcclusionQueryResult.value())

### func getRenderTarget\(\)
```cj
public func getRenderTarget(): Option < IRenderTarget >
```
Get current render target

Return: 

- Current render target (None for default framebuffer)

### func getRenderViewId\(\)
```cj
public override func getRenderViewId(): UInt16
```
Get current render view id (override base class hook)

Return: 

- Current view id

### func getRendererName\(UInt32\)
```cj
public func getRendererName(`type`: UInt32): String
```
Get renderer backend name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|UInt32||

### func getRendererType\(\)
```cj
public func getRendererType(): UInt32
```
Get current renderer backend type

Return: 

- RendererType.value()

### func getShaderUniforms\(ShaderHandle,UInt16\)
```cj
public func getShaderUniforms(handle: ShaderHandle, max: UInt16):(Array < UniformHandle >, UInt16)
```
Get list of uniform handles referenced by shader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ShaderHandle|shader handlemax maximum query count|
|max|UInt16||

Return: 

- (uniform handle array and actual count

### func getStats\(\)
```cj
public func getStats(): StatsPtr
```
Get renderer statistics (CPointer, valid until next frame)

### func getSupportedRenderers\(UInt8,PtrArray<UInt32>\)
```cj
public func getSupportedRenderers(max: UInt8, `enum`: PtrArray < UInt32 >): UInt8
```
Get supported backend list

Parameter: 

|Name|Type|Describe|
|---|---|---|
|max|UInt8||
|`enum`|PtrArray<UInt32>||

### func getTexture\(FrameBufferHandle,UInt8\)
```cj
public func getTexture(fb: FrameBufferHandle, attachment: UInt8): TextureHandle
```
Get texture handle of a Frame buffer attachment

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fb|FrameBufferHandle|Source Frame bufferattachment Attachment index (0=main color, 1=depth etc.)|
|attachment|UInt8||

Return: 

- TextureHandle for the attachment

### func getUniformInfo\(UniformHandle,UniformInfoPtr\)
```cj
public func getUniformInfo(handle: UniformHandle, info: UniformInfoPtr): Unit
```
Get uniform info (name/type/count)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|UniformHandle|uniform handleinfo output UniformInfo pointer|
|info|UniformInfoPtr||

### func initBgfx\(UIntNative,Int32,Int32\)
```cj
public func initBgfx(hwnd: UIntNative, width: Int32, height: Int32): Bool
```
Initialize bgfx renderer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hwnd|UIntNative|Native window handlewidth Window logical widthheight Window logical height|
|width|Int32||
|height|Int32||

Return: 

- Whether initialization succeeded

### func init\(\)
```cj
public init()
```


### func isFrameBufferValid\(UInt8,AttachmentPtr\)
```cj
public func isFrameBufferValid(num: UInt8, attachment: AttachmentPtr): Bool
```
Check if Frame buffer configuration is valid

Parameter: 

|Name|Type|Describe|
|---|---|---|
|num|UInt8||
|attachment|AttachmentPtr||

### func isTextureValid\(UInt16,Bool,UInt16,UInt32,UInt64\)
```cj
public func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): Bool
```
Check if texture parameters are valid

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depth|UInt16|depth (1 for 2D textures)cubeMap whether it is a cubemapnumLayers layer countformat texture formatflags texture flags|
|cubeMap|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||

Return: 

- whether valid

### func makeRef\(PtrArray<UInt8>\)
```cj
public func makeRef(data: PtrArray < UInt8 >): BgfxMemory
```
Wrap raw pixel data as bgfx Memory reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|PtrArray<UInt8>|pixel data pointersize data byte count|

Return: 

- bgfx Memory reference pointer

### func present\(Bool\)
```cj
public func present(capture!: Bool = false): Unit
```
Trigger a bgfx frame double-buffer swap to screen

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capture|Bool|Whether to capture screenshot (default false)|

### func readTexture\(TextureHandle,PtrArray<UInt8>,UInt8\)
```cj
public func readTexture(tex: TextureHandle, data: PtrArray < UInt8 >, mip!: UInt8 = 0u8): UInt32
```
Read texture back to CPU memory (asynchronous)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle|Source texture (Box-wrapped handle)data Readback target buffer (PtrArray<UInt8>, internal pointer held internally)mip Mip level (default 0)|
|data|PtrArray<UInt8>||
|mip|UInt8||

Return: 

- Frame number when data is ready (safe to read data after this frame)

### func renderFrame\(Int32\)
```cj
public func renderFrame(msecs: Int32): UInt32
```
Manually drive render frame

Parameter: 

|Name|Type|Describe|
|---|---|---|
|msecs|Int32|wait timeout in milliseconds (-1 to block)|

Return: 

- RenderFrame.value()

### func render\(Scene,Camera\)
```cj
public func render(scene: Scene, camera: Camera): Unit
```
Render scene (delegated to render thread via _execBgfx)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scene to rendercamera Render camera|
|camera|Camera||

### func requestScreenShot\(FrameBufferHandle,String\)
```cj
public func requestScreenShot(fb: FrameBufferHandle, filePath: String): Unit
```
Request screenshot saved to file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fb|FrameBufferHandle||
|filePath|String||

### func resetView\(UInt16\)
```cj
public func resetView(viewId: UInt16): Unit
```
Reset all states of a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view id|

### func reset\(UInt32,UInt32,UInt32,UInt32\)
```cj
public func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit
```
Reset backbuffer (resolution/flags/format)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|UInt32||
|height|UInt32||
|flags|UInt32||
|format|UInt32||

### func setClearColor\(Color,Float64\)
```cj
public func setClearColor(color: Color, alpha!: Float64 = 1.0): Unit
```
Set clear color — Three.js alignment: renderer.setClearColor(color, alpha)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Clear coloralpha Alpha value, default 1.0|
|alpha|Float64||

### func setComputeDynamicIndexBuffer\(UInt8,DynamicIndexBufferHandle,UInt32\)
```cj
public func setComputeDynamicIndexBuffer(stage: UInt8, ib: DynamicIndexBufferHandle, access: UInt32): Unit
```
Bind compute dynamic index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|ib|DynamicIndexBufferHandle||
|access|UInt32||

### func setComputeDynamicVertexBuffer\(UInt8,DynamicVertexBufferHandle,UInt32\)
```cj
public func setComputeDynamicVertexBuffer(stage: UInt8, vb: DynamicVertexBufferHandle, access: UInt32): Unit
```
Bind compute dynamic vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|vb|DynamicVertexBufferHandle||
|access|UInt32||

### func setComputeIndexBuffer\(UInt8,IndexBufferHandle,UInt32\)
```cj
public func setComputeIndexBuffer(stage: UInt8, ib: IndexBufferHandle, access: UInt32): Unit
```
Bind compute index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|ib|IndexBufferHandle||
|access|UInt32||

### func setComputeIndirectBuffer\(UInt8,IndirectBufferHandle,UInt32\)
```cj
public func setComputeIndirectBuffer(stage: UInt8, ib: IndirectBufferHandle, access: UInt32): Unit
```
Bind compute indirect buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|ib|IndirectBufferHandle||
|access|UInt32||

### func setComputeVertexBuffer\(UInt8,VertexBufferHandle,UInt32\)
```cj
public func setComputeVertexBuffer(stage: UInt8, vb: VertexBufferHandle, access: UInt32): Unit
```
Bind compute vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|vb|VertexBufferHandle||
|access|UInt32||

### func setCondition\(OcclusionQueryHandle,Bool\)
```cj
public func setCondition(query: OcclusionQueryHandle, visible: Bool): Unit
```
Set occlusion query condition (visible determines if subsequent draw executes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|OcclusionQueryHandle||
|visible|Bool||

### func setDebug\(UInt32\)
```cj
public func setDebug(debug: UInt32): Unit
```
Set bgfx global debug flags

Parameter: 

|Name|Type|Describe|
|---|---|---|
|debug|UInt32|bgfx debug flag bits|

### func setDynamicIndexBuffer\(DynamicIndexBufferHandle,UInt32,UInt32\)
```cj
public func setDynamicIndexBuffer(ib: DynamicIndexBufferHandle, firstIndex!: UInt32 = 0u32, numIndices!: UInt32 = 0xFFFFFFFFu32): Unit
```
Set per-draw dynamic index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ib|DynamicIndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func setDynamicVertexBufferWithLayout\(UInt8,DynamicVertexBufferHandle,VertexLayoutHandle,UInt32,UInt32\)
```cj
public func setDynamicVertexBufferWithLayout(stage: UInt8, vb: DynamicVertexBufferHandle, layout: VertexLayoutHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
Set per-draw dynamic vertex buffer (with layout)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|vb|DynamicVertexBufferHandle||
|layout|VertexLayoutHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setDynamicVertexBuffer\(UInt8,DynamicVertexBufferHandle,UInt32,UInt32\)
```cj
public func setDynamicVertexBuffer(stage: UInt8, vb: DynamicVertexBufferHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
Set per-draw dynamic vertex buffer (no layout)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|vb|DynamicVertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setFrameBufferName\(FrameBufferHandle,String\)
```cj
public func setFrameBufferName(fb: FrameBufferHandle, name: String): Unit
```
Set Frame buffer debug name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fb|FrameBufferHandle||
|name|String||

### func setImage\(UInt8,TextureHandle,UInt8,UInt32,UInt32\)
```cj
public func setImage(stage: UInt8, tex: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit
```
Bind image (compute shader image unit)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|tex|TextureHandle||
|mip|UInt8||
|access|UInt32||
|format|UInt32||

### func setIndexBufferName\(IndexBufferHandle,String\)
```cj
public func setIndexBufferName(ib: IndexBufferHandle, name: String): Unit
```
Set index buffer debug name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ib|IndexBufferHandle||
|name|String||

### func setIndexBuffer\(IndexBufferHandle,UInt32,UInt32\)
```cj
public func setIndexBuffer(ib: IndexBufferHandle, firstIndex!: UInt32 = 0u32, numIndices!: UInt32 = 0xFFFFFFFFu32): Unit
```
Set per-draw index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ib|IndexBufferHandle|Index buffer handlefirstIndex Start index (default 0)numIndices Index count (0xFFFFFFFF means all)|
|firstIndex|UInt32||
|numIndices|UInt32||

### func setInstanceCount\(UInt32\)
```cj
public func setInstanceCount(numInstances: UInt32): Unit
```
Set per-draw instance count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numInstances|UInt32||

### func setInstanceDataBuffer\(InstanceDataBufferPtr,UInt32,UInt32\)
```cj
public func setInstanceDataBuffer(idb: InstanceDataBufferPtr, start: UInt32, num: UInt32): Unit
```
Set per-draw instance data buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idb|InstanceDataBufferPtr||
|start|UInt32||
|num|UInt32||

### func setInstanceDataFromDynamicVertexBuffer\(DynamicVertexBufferHandle,UInt32,UInt32\)
```cj
public func setInstanceDataFromDynamicVertexBuffer(vb: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
Set per-draw instance data from dynamic vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vb|DynamicVertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func setInstanceDataFromVertexBuffer\(VertexBufferHandle,UInt32,UInt32\)
```cj
public func setInstanceDataFromVertexBuffer(vb: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
Set per-draw instance data from vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vb|VertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func setMarker\(String\)
```cj
public func setMarker(name: String): Unit
```
Set per-draw debug marker (visible in render thread, for debug tools)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func setPaletteColorRgba32f\(UInt8,Float32,Float32,Float32,Float32\)
```cj
public func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit
```
Set palette color (4-component float version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|UInt8|Palette index (0..15)r Red (0.0~1.0)g Green (0.0~1.0)b Blue (0.0~1.0)a Alpha (0.0~1.0)|
|r|Float32||
|g|Float32||
|b|Float32||
|a|Float32||

### func setPaletteColorRgba8\(UInt8,UInt32\)
```cj
public func setPaletteColorRgba8(index: UInt8, rgba: UInt32): Unit
```
Set palette color (8bit packed version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|UInt8|Palette index (0..15)rgba Packed color (0xRRGGBBAA)|
|rgba|UInt32||

### func setPaletteColor\(UInt8,PtrArray<Float32>\)
```cj
public func setPaletteColor(index: UInt8, rgba: PtrArray < Float32 >): Unit
```
Set palette color (rgba 4 floats)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|UInt8|Palette index (0..15)rgba 4 float pointer (r,g,b,a)|
|rgba|PtrArray<Float32>||

### func setRenderTarget\(IRenderTarget,Int64,Int64\)
```cj
public func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit
```
Set render target (IRenderer interface implementation, CubeCamera 6-face render target switching)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderTarget|IRenderTarget|Render targetcubeFace Cube face index (0~5)mipLevel Mipmap level|
|cubeFace|Int64||
|mipLevel|Int64||

### func setScissorCached\(UInt16\)
```cj
public func setScissorCached(cache: UInt16): Unit
```
Reuse cached scissor rectangle (cache index returned by setScissor)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cache|UInt16||

### func setScissor\(UInt16,UInt16,UInt16,UInt16\)
```cj
public func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16
```
Set per-draw scissor rectangle (per-draw transient, not view-level)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|UInt16|Scissor top-left x (pixels)y Scissor top-left y (pixels)w Scissor width (pixels)h Scissor height (pixels)|
|y|UInt16||
|w|UInt16||
|h|UInt16||

Return: 

- Scissor cache index (can be reused with setScissorCached)

### func setShaderName\(ShaderHandle,String\)
```cj
public func setShaderName(handle: ShaderHandle, name: String): Unit
```
Set shader debug name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ShaderHandle||
|name|String||

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
Set shadow type (delegates to BgfxBackend.shadowMap)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Shadow type value|

### func setSize\(Int32,Int32\)
```cj
public func setSize(width: Int32, height: Int32): Unit
```
Set renderer size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int32|Logical width in pixelsheight Logical height in pixels|
|height|Int32||

### func setState\(UInt64,UInt32\)
```cj
public func setState(state: UInt64, rgba!: UInt32 = 0u32): Unit
```
Set per-draw render state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|state|UInt64|Complete render state bitfield (BGFX_STATE_* combination)rgba Color blend factor (default 0, means use program default)|
|rgba|UInt32||

### func setStencil\(UInt32,UInt32\)
```cj
public func setStencil(fstencil: UInt32, bstencil: UInt32): Unit
```
Set stencil state (per-draw transient)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fstencil|UInt32|Front stencil bitfieldbstencil Back stencil bitfield|
|bstencil|UInt32||

### func setTextureName\(TextureHandle,String\)
```cj
public func setTextureName(tex: TextureHandle, name: String): Unit
```
Set texture debug name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle||
|name|String||

### func setTransformCached\(UInt32,UInt16\)
```cj
public func setTransformCached(cache: UInt32, num: UInt16): Unit
```
Reuse cached transform matrix (cache index returned by setTransform)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cache|UInt32||
|num|UInt16||

### func setTransform\(BgfxMemory,UInt16\)
```cj
public func setTransform(matrix: BgfxMemory, num!: UInt16 = 1u16): Unit
```
Set per-draw model transform matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|BgfxMemory|4×4 model matrix pointer (16 float32, column-major)num Number of matrices (default 1, >1 for instancing)|
|num|UInt16||

### func setTransientIndexBuffer\(TransientIndexBufferPtr,UInt32,UInt32\)
```cj
public func setTransientIndexBuffer(tib: TransientIndexBufferPtr, firstIndex: UInt32, numIndices: UInt32): Unit
```
Set per-draw transient index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tib|TransientIndexBufferPtr||
|firstIndex|UInt32||
|numIndices|UInt32||

### func setTransientVertexBufferWithLayout\(UInt8,TransientVertexBufferPtr,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func setTransientVertexBufferWithLayout(stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
Set per-draw transient vertex buffer (with layout)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stream|UInt8||
|tvb|TransientVertexBufferPtr||
|startVertex|UInt32||
|numVertices|UInt32||
|layoutHandle|VertexLayoutHandle||

### func setTransientVertexBuffer\(UInt8,TransientVertexBufferPtr,UInt32,UInt32\)
```cj
public func setTransientVertexBuffer(stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32): Unit
```
Set per-draw transient vertex buffer (no layout)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stream|UInt8||
|tvb|TransientVertexBufferPtr||
|startVertex|UInt32||
|numVertices|UInt32||

### func setUniform\(UniformHandle,BgfxMemory,UInt16\)
```cj
public func setUniform(handle: UniformHandle, data: BgfxMemory, num!: UInt16 = 1u16): Unit
```
Set uniform data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|UniformHandle|Uniform handledata Uniform data pointer (float32 array)num Array length (default 1)|
|data|BgfxMemory||
|num|UInt16||

### func setVertexBufferName\(VertexBufferHandle,String\)
```cj
public func setVertexBufferName(vb: VertexBufferHandle, name: String): Unit
```
Set vertex buffer debug name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vb|VertexBufferHandle||
|name|String||

### func setVertexBufferWithLayout\(UInt8,VertexBufferHandle,VertexLayoutHandle,UInt32,UInt32\)
```cj
public func setVertexBufferWithLayout(stage: UInt8, vb: VertexBufferHandle, layout: VertexLayoutHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
Set per-draw vertex buffer with layout

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8|Vertex buffer stage (typically 0 for bgfx, single stream)vb vertex buffer handlestartVertex Start vertex index (default 0)numVertices Vertex count (0xFFFFFFFF means all)layout Vertex layout handle|
|vb|VertexBufferHandle||
|layout|VertexLayoutHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setVertexBuffer\(UInt8,VertexBufferHandle,UInt32,UInt32\)
```cj
public func setVertexBuffer(stage: UInt8, vb: VertexBufferHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
Set per-draw vertex buffer (no layout, layout must be bound already)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stage|UInt8||
|vb|VertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setVertexCount\(UInt32\)
```cj
public func setVertexCount(numVertices: UInt32): Unit
```
Set vertex count (no vertex buffer mode, vertices generated by shader)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numVertices|UInt32||

### func setViewClearMRT\(UInt16,UInt16,Float32,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8\)
```cj
public func setViewClearMRT(viewId: UInt16, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8, c2: UInt8, c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit
```
Set MRT clear for a view (per-attachment independent colors)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idflags Clear flag bits (CLEAR_* combination)depth Clear depthstencil Clear stencil value|
|flags|UInt16||
|depth|Float32||
|stencil|UInt8||
|c0|UInt8||
|c1|UInt8||
|c2|UInt8||
|c3|UInt8||
|c4|UInt8||
|c5|UInt8||
|c6|UInt8||
|c7|UInt8||

### func setViewClear\(UInt16,UInt16,UInt32,Float32,UInt8\)
```cj
public func setViewClear(viewId: UInt16, flags: UInt16, color: UInt32, depth!: Float32 = 1.0f32, stencil!: UInt8 = 0u8): Unit
```
Set clear for a view (color + depth + stencil)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idflags Clear flag bits (CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004)color Clear color (UInt32)depth Clear depth (0.0~1.0, default 1.0)stencil Clear stencil value (default 0)|
|flags|UInt16||
|color|UInt32||
|depth|Float32||
|stencil|UInt8||

### func setViewFrameBuffer\(UInt16,FrameBufferHandle\)
```cj
public func setViewFrameBuffer(viewId: UInt16, fb: FrameBufferHandle): Unit
```
Set render target Frame buffer for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view id (held by pass, allocated by EffectComposer.allocViewId)fb Target Frame buffer; pass invalid handle (idx=65535) to write to swap chain (screen)|
|fb|FrameBufferHandle||

### func setViewMode\(UInt16,UInt32\)
```cj
public func setViewMode(viewId: UInt16, mode: UInt32): Unit
```
Set render mode for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idmode ViewMode.value() (Default/Sequential/DepthAscending/DepthDescending)|
|mode|UInt32||

### func setViewName\(UInt16,String\)
```cj
public func setViewName(viewId: UInt16, name: String): Unit
```
Set name for a view (for debugging)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idname View name (UTF-8)|
|name|String||

### func setViewOrder\(UInt16,PtrArray<UInt16>\)
```cj
public func setViewOrder(viewId: UInt16, order: PtrArray < UInt16 >): Unit
```
Set execution order for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idorder View id array|
|order|PtrArray<UInt16>||

### func setViewRectRatio\(UInt16,UInt16,UInt16,UInt32\)
```cj
public func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: UInt32): Unit
```
Set viewport rectangle for a view by backbuffer ratio

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idx Viewport top-left x ratio basey Viewport top-left y ratio baseratio BackbufferRatio.value() (Half/Quarter/Eighth/Sixteenth/Double)|
|x|UInt16||
|y|UInt16||
|ratio|UInt32||

### func setViewRect\(UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
Set viewport rectangle for a view (in pixels)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idx Viewport top-left x (pixels)y Viewport top-left y (pixels)w Viewport width (pixels)h Viewport height (pixels)|
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setViewScissor\(UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
Set scissor rectangle for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idx Scissor top-left x (pixels)y Scissor top-left y (pixels)w Scissor width (pixels)h Scissor height (pixels)|
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setViewTransform\(UInt16,BgfxMemory,BgfxMemory\)
```cj
public func setViewTransform(viewId: UInt16, view: BgfxMemory, proj: BgfxMemory): Unit
```
Set view/proj transform matrices for a view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idview 4×4 view matrix dataproj 4×4 projection matrix data|
|view|BgfxMemory||
|proj|BgfxMemory||

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
Shutdown bgfx renderer and release resources

### func submitIndirectCount\(UInt16,ProgramHandle,IndirectBufferHandle,UInt32,IndexBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func submitIndirectCount(viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit
```
Submit indirect draw with count buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16||
|program|ProgramHandle||
|indirect|IndirectBufferHandle||
|start|UInt32||
|numHandle|IndexBufferHandle||
|numIndex|UInt32||
|numMax|UInt32||
|depth|UInt32||
|blend|UInt8||

### func submitIndirect\(UInt16,ProgramHandle,IndirectBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func submitIndirect(viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle, start: UInt32, num: UInt32, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit
```
Submit indirect draw (GPU-generated draw parameters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16||
|program|ProgramHandle||
|indirect|IndirectBufferHandle||
|start|UInt32||
|num|UInt32||
|depth|UInt32||
|blend|UInt8||

### func submitOcclusionQuery\(UInt16,ProgramHandle,OcclusionQueryHandle,UInt32,UInt8\)
```cj
public func submitOcclusionQuery(viewId: UInt16, program: ProgramHandle, query: OcclusionQueryHandle, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit
```
Submit draw with occlusion query

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16||
|program|ProgramHandle||
|query|OcclusionQueryHandle||
|depth|UInt32||
|blend|UInt8||

### func submit\(UInt16,ProgramHandle,UInt32,UInt8\)
```cj
public func submit(viewId: UInt16, program: ProgramHandle, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit
```
Submit current draw to specified view

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view idprogram Compiled program handledepth Depth value (default 0, for sorting)blend Blend flags (0xFF means use program default)|
|program|ProgramHandle||
|depth|UInt32||
|blend|UInt8||

### func touchView\(UInt16\)
```cj
public func touchView(viewId: UInt16): Unit
```
Trigger empty submit for a view (only advances clear / view sequence, no drawing)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view id|

### func touch\(UInt16\)
```cj
public func touch(viewId: UInt16): Unit
```
Touch view (empty submit, advances clear/view sequence without drawing)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|bgfx view id|

### func updateDynamicIndexBuffer\(DynamicIndexBufferHandle,UInt32,BgfxMemory\)
```cj
public func updateDynamicIndexBuffer(handle: DynamicIndexBufferHandle, startIndex: UInt32, mem: BgfxMemory): Unit
```
Update dynamic index buffer data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicIndexBufferHandle||
|startIndex|UInt32||
|mem|BgfxMemory||

### func updateDynamicVertexBuffer\(DynamicVertexBufferHandle,UInt32,BgfxMemory\)
```cj
public func updateDynamicVertexBuffer(handle: DynamicVertexBufferHandle, startVertex: UInt32, mem: BgfxMemory): Unit
```
Update dynamic vertex buffer data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|DynamicVertexBufferHandle||
|startVertex|UInt32||
|mem|BgfxMemory||

### func updateTexture2D\(TextureHandle,UInt16,UInt8,UInt16,UInt16,UInt16,UInt16,BgfxMemory,UInt16\)
```cj
public func updateTexture2D(tex: TextureHandle, layer: UInt16, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: BgfxMemory, pitch: UInt16): Unit
```
Update 2D texture sub-region data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle|目标texture handlelayer layer indexmip mip levelx sub-region x offsety sub-region y offsetwidth sub-region widthheight sub-region heightmem pixel data (BgfxMemory)pitch row pitch (bytes)|
|layer|UInt16||
|mip|UInt8||
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|mem|BgfxMemory||
|pitch|UInt16||

### func updateTexture3D\(TextureHandle,UInt8,UInt16,UInt16,UInt16,UInt16,UInt16,UInt16,BgfxMemory\)
```cj
public func updateTexture3D(tex: TextureHandle, mip: UInt8, x: UInt16, y: UInt16, z: UInt16, width: UInt16, height: UInt16, depth: UInt16, mem: BgfxMemory): Unit
```
Update 3D texture sub-region data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle||
|mip|UInt8||
|x|UInt16||
|y|UInt16||
|z|UInt16||
|width|UInt16||
|height|UInt16||
|depth|UInt16||
|mem|BgfxMemory||

### func updateTextureCube\(TextureHandle,UInt16,UInt8,UInt8,UInt16,UInt16,UInt16,UInt16,BgfxMemory,UInt16\)
```cj
public func updateTextureCube(tex: TextureHandle, layer: UInt16, side: UInt8, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: BgfxMemory, pitch: UInt16): Unit
```
Update cube texture face sub-region data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle||
|layer|UInt16||
|side|UInt8||
|mip|UInt8||
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|mem|BgfxMemory||
|pitch|UInt16||

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
Clear color (RGBA32)

### var viewId
```cj
public var viewId: UInt16 = 0u16
```
Current render view id

