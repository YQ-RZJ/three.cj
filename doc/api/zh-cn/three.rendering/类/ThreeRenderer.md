# 类
## class ThreeRenderer
```cj
public class ThreeRenderer <: Renderer & IRenderer
```
bgfx 渲染器 — Renderer 薄实现

### func attachmentInit\(CPointer<bgfx\.Attachment>,TextureHandle,UInt32,UInt16,UInt16,UInt16,UInt8\)
```cj
public func attachmentInit(attachment: CPointer < bgfx.Attachment >, tex: TextureHandle, access: UInt32, layer: UInt16, numLayers: UInt16, mip: UInt16, resolve: UInt8): Unit
```
初始化 Attachment 结构。

参数: 

|名称|类型|描述|
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
绑定纹理到指定 stage 的 sampler

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8|纹理 stage（0..MAX_TEXTURE_SAMPLERS-1）sampler sampler uniform 句柄tex 待绑纹理句柄flags 采样器 flags（如 SAMPLER_U_CLAMP|SAMPLER_V_CLAMP，0 表示用纹理默认）|
|sampler|UniformHandle||
|tex|TextureHandle||
|flags|UInt32||

### func blitTexture\(UInt16,TextureHandle,TextureHandle,UInt16,UInt16\)
```cj
public func blitTexture(viewId: UInt16, dst: TextureHandle, src: TextureHandle, width: UInt16, height: UInt16): Unit
```
blit 拷贝：把 src 纹理区域拷贝到 dst 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view iddst 目标纹理（Box 包装句柄）src 源纹理（Box 包装句柄）width 拷贝宽度（像素）height 拷贝高度（像素）|
|dst|TextureHandle||
|src|TextureHandle||
|width|UInt16||
|height|UInt16||

### func calcTextureSize\(CPointer<bgfx\.TextureInfo>,UInt16,UInt16,UInt16,Bool,Bool,UInt16,UInt32\)
```cj
public func calcTextureSize(info: CPointer < bgfx.TextureInfo >, width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool, numLayers: UInt16, format: UInt32): Unit
```
计算纹理存储大小。

参数: 

|名称|类型|描述|
|---|---|---|
|info|CPointer<bgfx.TextureInfo>|输出 TextureInfo 指针width 宽height 高depth 深cubeMap 是否 cubehasMips 是否 mipmapnumLayers 图层数format 纹理格式|
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
由计算着色器创建程序。

参数: 

|名称|类型|描述|
|---|---|---|
|csh|ShaderHandle||
|destroyShaders|Bool||

### func createDynamicIndexBufferMem\(Option<BgfxMemory>,UInt16\)
```cj
public func createDynamicIndexBufferMem(mem: Option < BgfxMemory >, flags: UInt16): DynamicIndexBufferHandle
```
由内存创建动态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|Option<BgfxMemory>||
|flags|UInt16||

### func createDynamicIndexBuffer\(UInt32,UInt16\)
```cj
public func createDynamicIndexBuffer(num: UInt32, flags: UInt16): DynamicIndexBufferHandle
```
创建动态索引缓冲（仅指定数量）。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32||
|flags|UInt16||

### func createDynamicVertexBufferMem\(Option<BgfxMemory>,VertexLayoutPtr,UInt16\)
```cj
public func createDynamicVertexBufferMem(mem: Option < BgfxMemory >, layout: VertexLayoutPtr, flags: UInt16): DynamicVertexBufferHandle
```
由内存创建动态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|Option<BgfxMemory>|顶点数据内存（Some=有数据；None=空）layout 顶点布局指针flags 缓冲 flags|
|layout|VertexLayoutPtr||
|flags|UInt16||

返回: 

- 动态顶点缓冲句柄

### func createDynamicVertexBuffer\(UInt32,VertexLayoutPtr,UInt16\)
```cj
public func createDynamicVertexBuffer(num: UInt32, layout: VertexLayoutPtr, flags: UInt16): DynamicVertexBufferHandle
```
创建动态顶点缓冲（仅指定数量，数据后续 update 填充）。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32|顶点数量layout 顶点布局指针（CPointer<bgfx.VertexLayout>）flags 缓冲 flags（BUFFER_* 组合）|
|layout|VertexLayoutPtr||
|flags|UInt16||

返回: 

- 动态顶点缓冲句柄

### func createFrameBufferFromAttachment\(Array<Attachment>,Bool\)
```cj
public func createFrameBufferFromAttachment(attachments: Array < Attachment >, destroyTexture: Bool): FrameBufferHandle
```
由 Attachment 列表创建 frame buffer。

参数: 

|名称|类型|描述|
|---|---|---|
|attachments|Array<Attachment>|attachment 数组（Box 包装的 Attachment）destroyTexture 销毁 FB 时是否自动销毁 attachment 纹理|
|destroyTexture|Bool||

返回: 

- frame buffer 句柄

### func createFrameBufferFromNwh\(CPointer<Unit>,UInt16,UInt16,UInt32,UInt32\)
```cj
public func createFrameBufferFromNwh(nwh: CPointer < Unit >, width: UInt16, height: UInt16, format: UInt32, depthFormat: UInt32): FrameBufferHandle
```
由原生窗口句柄创建 frame buffer（离屏窗口渲染）。

参数: 

|名称|类型|描述|
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
创建 frame buffer（按后备缓冲比例）。

参数: 

|名称|类型|描述|
|---|---|---|
|ratio|UInt32||
|format|UInt32||
|textureFlags|UInt64||

### func createFrameBuffer\(UInt16,UInt16,UInt32,UInt64\)
```cj
public func createFrameBuffer(w: UInt16, h: UInt16, format: UInt32, depthFlags: UInt64): FrameBufferHandle
```
由宽高创建空 frame buffer

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16|宽（像素）h 高（像素）format 纹理格式depthFlags 深度 attachment flags|
|h|UInt16||
|format|UInt32||
|depthFlags|UInt64||

返回: 

- frame buffer 句柄

### func createFrameBuffer\(UInt8,Array<TextureHandle>,Bool\)
```cj
public func createFrameBuffer(numAttachments: UInt8, handles: Array < TextureHandle >, destroyHandles: Bool): FrameBufferHandle
```
由多个纹理句柄创建 frame buffer

参数: 

|名称|类型|描述|
|---|---|---|
|numAttachments|UInt8|attachment 数量handles attachments 纹理句柄数组destroyHandles bgfx 销毁 FB 时是否自动销毁这些 texture 句柄|
|handles|Array<TextureHandle>||
|destroyHandles|Bool||

返回: 

- frame buffer 句柄

### func createIndexBuffer\(BgfxMemory,UInt16\)
```cj
public func createIndexBuffer(mem: BgfxMemory, flags!: UInt16 = 0u16): IndexBufferHandle
```
创建索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|BgfxMemory|索引数据内存flags 缓冲 flags（默认 0）|
|flags|UInt16||

返回: 

- 索引缓冲句柄

### func createIndirectBuffer\(UInt32\)
```cj
public func createIndirectBuffer(num: UInt32): IndirectBufferHandle
```
创建间接绘制缓冲（GPU 侧生成 draw 参数）。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32||

### func createOcclusionQuery\(\)
```cj
public func createOcclusionQuery(): OcclusionQueryHandle
```
创建遮挡查询。

### func createProgram\(ShaderHandle,ShaderHandle,Bool\)
```cj
public func createProgram(vsh: ShaderHandle, fsh: ShaderHandle, destroyShaders: Bool): ProgramHandle
```
由 vs+fs 链接程序。

参数: 

|名称|类型|描述|
|---|---|---|
|vsh|ShaderHandle|顶点着色器句柄fsh 片元着色器句柄destroyShaders 链接后是否销毁输入着色器|
|fsh|ShaderHandle||
|destroyShaders|Bool||

返回: 

- 程序句柄

### func createShader\(BgfxMemory\)
```cj
public func createShader(mem: BgfxMemory): ShaderHandle
```
由二进制源码创建着色器。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|BgfxMemory|着色器二进制数据（BgfxMemory）|

返回: 

- 着色器句柄

### func createTexture2DScaled\(UInt32,Bool,UInt16,UInt32,UInt64\)
```cj
public func createTexture2DScaled(ratio: UInt32, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): TextureHandle
```
创建 2D 纹理（按后备缓冲比例）。

参数: 

|名称|类型|描述|
|---|---|---|
|ratio|UInt32|BackbufferRatio.value()（Half/Quarter/Eighth/Sixteenth/Double）hasMips 是否生成 mipmapnumLayers 图层数（默认 1）format 纹理格式（TextureFormat.value()）flags 纹理 flags（TEXTURE_RT | SAMPLER_* 组合）|
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||

返回: 

- 纹理句柄

### func createTexture2D\(UInt16,UInt16,Bool,UInt16,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
创建 2D 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16|纹理宽（像素）h 纹理高（像素）hasMips 是否生成 mipmapnumLayers 图层数（1=普通 2D 纹理）format 纹理格式flags 纹理 flagsmem 纹理数据内存（null 表示空 RT）|
|h|UInt16||
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

返回: 

- 纹理句柄

### func createTexture3D\(UInt16,UInt16,UInt16,Bool,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture3D(w: UInt16, h: UInt16, d: UInt16, hasMips: Bool, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
创建 3D 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16|纹理宽（像素）h 纹理高（像素）d 纹理深（层数）hasMips 是否生成 mipmapformat 纹理格式flags 纹理 flagsmem 纹理数据内存（Some=有数据；None=空 3D RT）|
|h|UInt16||
|d|UInt16||
|hasMips|Bool||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

返回: 

- 3D 纹理句柄

### func createTextureCube\(UInt16,Bool,UInt16,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTextureCube(side: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
创建 cube 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|side|UInt16|cube 面边长（像素）hasMips 是否生成 mipmapnumLayers 图层数format 纹理格式flags 纹理 flagsmem 6 面连续像素数据（null 表示空 cube RT）|
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

返回: 

- cube 纹理句柄

### func createTexture\(Option<BgfxMemory>,UInt64,UInt8,TextureInfoPtr\)
```cj
public func createTexture(mem: Option < BgfxMemory >, flags: UInt64, skip: UInt8, info: TextureInfoPtr): TextureHandle
```
按 TextureInfo 创建纹理（通用入口）。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|Option<BgfxMemory>|纹理数据内存（Some=有数据；None=空 RT）flags 纹理 flagsskip 跳过的 mip 数info 纹理信息指针（TextureInfo）|
|flags|UInt64||
|skip|UInt8||
|info|TextureInfoPtr||

返回: 

- 纹理句柄

### func createUniform\(String,UInt32,UInt16\)
```cj
public func createUniform(name: String, uniformType: UInt32, num!: UInt16 = 1u16): UniformHandle
```
创建 uniform 句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称uniformType UniformType.value()（Sampler/Vec4/Mat3/Mat4 等）num 数组长度（默认 1）|
|uniformType|UInt32||
|num|UInt16||

返回: 

- uniform 句柄

### func createVertexBufferFromLayout\(BgfxMemory,VertexLayoutHandle,UInt16\)
```cj
public func createVertexBufferFromLayout(mem: BgfxMemory, layout: VertexLayoutHandle, flags!: UInt16 = 0u16): VertexBufferHandle
```
用 layout handle 创建顶点缓冲（安全封装，外部无须管理 layout 指针）。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|BgfxMemory|顶点数据内存（bgfx_make_ref_cj 包装的像素数据）layout 经 renderer.createVertexLayout 创建的布局句柄flags 缓冲 flags（默认 0）|
|layout|VertexLayoutHandle||
|flags|UInt16||

返回: 

- 顶点缓冲句柄（layout 不存在时为无效句柄）

### func createVertexBuffer\(BgfxMemory,VertexLayoutHandle,UInt16\)
```cj
public func createVertexBuffer(mem: BgfxMemory, layout: VertexLayoutHandle, flags!: UInt16 = 0u16): VertexBufferHandle
```
创建顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|mem|BgfxMemory|顶点数据内存（bgfx_make_ref_cj 包装的像素数据）layout 顶点布局内存指针（CPointer<VertexLayout>）flags 缓冲 flags（默认 0）|
|layout|VertexLayoutHandle||
|flags|UInt16||

返回: 

- 顶点缓冲句柄

### func createVertexLayout\(Array<BgfxAttributeDesc>\)
```cj
public func createVertexLayout(attributes: Array < BgfxAttributeDesc >): VertexLayoutHandle
```
创建顶点布局（从属性描述列表）。

参数: 

|名称|类型|描述|
|---|---|---|
|attributes|Array<BgfxAttributeDesc>|属性描述列表（BgfxAttributeDesc）|

返回: 

- 顶点布局句柄（无效则 idx=65535）

### func dbgTextClear\(UInt8,Bool\)
```cj
public func dbgTextClear(attr: UInt8, small: Bool): Unit
```
清除调试文本

参数: 

|名称|类型|描述|
|---|---|---|
|attr|UInt8||
|small|Bool||

### func dbgTextImage\(UInt16,UInt16,UInt16,UInt16,UnitPtr,UInt16\)
```cj
public func dbgTextImage(x: UInt16, y: UInt16, width: UInt16, height: UInt16, data: UnitPtr, pitch: UInt16): Unit
```
绘制调试文本图像（8bit 每像素）

参数: 

|名称|类型|描述|
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
输出格式化调试文本（C 风格格式字符串）

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16||
|y|UInt16||
|attr|UInt8||
|format|String||

### func dbgTextVprintf\(UInt16,UInt16,UInt8,String,UnitPtr\)
```cj
public func dbgTextVprintf(x: UInt16, y: UInt16, attr: UInt8, format: String, argList: UnitPtr): Unit
```
输出格式化调试文本（va_list 版）

参数: 

|名称|类型|描述|
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
销毁动态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicIndexBufferHandle||

### func destroyDynamicVertexBuffer\(DynamicVertexBufferHandle\)
```cj
public func destroyDynamicVertexBuffer(handle: DynamicVertexBufferHandle): Unit
```
销毁动态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicVertexBufferHandle||

### func destroyFrameBuffer\(FrameBufferHandle\)
```cj
public func destroyFrameBuffer(fb: FrameBufferHandle): Unit
```
销毁 frame buffer 句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|FrameBufferHandle|待销毁 frame buffer 句柄|

### func destroyIndexBuffer\(IndexBufferHandle\)
```cj
public func destroyIndexBuffer(ib: IndexBufferHandle): Unit
```
销毁索引缓冲句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|IndexBufferHandle|待销毁索引缓冲句柄|

### func destroyIndirectBuffer\(IndirectBufferHandle\)
```cj
public func destroyIndirectBuffer(handle: IndirectBufferHandle): Unit
```
销毁间接绘制缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|IndirectBufferHandle||

### func destroyOcclusionQuery\(OcclusionQueryHandle\)
```cj
public func destroyOcclusionQuery(handle: OcclusionQueryHandle): Unit
```
销毁遮挡查询。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|OcclusionQueryHandle||

### func destroyProgram\(ProgramHandle\)
```cj
public func destroyProgram(handle: ProgramHandle): Unit
```
销毁程序。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ProgramHandle||

### func destroyShader\(ShaderHandle\)
```cj
public func destroyShader(handle: ShaderHandle): Unit
```
销毁着色器。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ShaderHandle||

### func destroyTexture\(TextureHandle\)
```cj
public func destroyTexture(tex: TextureHandle): Unit
```
销毁纹理句柄

参数: 

|名称|类型|描述|
|---|---|---|
|tex|TextureHandle|待销毁纹理句柄|

### func destroyUniform\(UniformHandle\)
```cj
public func destroyUniform(handle: UniformHandle): Unit
```
销毁 uniform 句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|UniformHandle||

### func destroyVertexBuffer\(VertexBufferHandle\)
```cj
public func destroyVertexBuffer(vb: VertexBufferHandle): Unit
```
销毁顶点缓冲句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|vb|VertexBufferHandle|待销毁顶点缓冲句柄|

### func destroyVertexLayout\(VertexLayoutHandle\)
```cj
public func destroyVertexLayout(layout: VertexLayoutHandle): Unit
```
销毁顶点布局句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|layout|VertexLayoutHandle|待销毁顶点布局句柄|

### func discard\(UInt8\)
```cj
public func discard(flags: UInt8): Unit
```
丢弃当前 draw 的指定状态组（优化：通知 bgfx 后续不再使用这些状态）。

参数: 

|名称|类型|描述|
|---|---|---|
|flags|UInt8||

### func dispatchIndirect\(UInt16,ProgramHandle,IndirectBufferHandle,UInt32,UInt32,UInt8\)
```cj
public func dispatchIndirect(viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle, start: UInt32, num: UInt32, flags!: UInt8 = 0xFFu8): Unit
```
提交间接计算调度。

参数: 

|名称|类型|描述|
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
提交计算调度。

参数: 

|名称|类型|描述|
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
编码器内分配变换矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|transform|TransformPtr||
|num|UInt16||

### func encoderBegin\(Bool\)
```cj
public func encoderBegin(forThread: Bool): EncoderPtr
```
获取编码器实例（多线程渲染用）

参数: 

|名称|类型|描述|
|---|---|---|
|forThread|Bool||

### func encoderBlit\(EncoderPtr,UInt16,TextureHandle,UInt8,UInt16,UInt16,UInt16,TextureHandle,UInt8,UInt16,UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func encoderBlit(encoder: EncoderPtr, id: UInt16, dst: TextureHandle, dstMip: UInt8, dstX: UInt16, dstY: UInt16, dstZ: UInt16, src: TextureHandle, srcMip: UInt8, srcX: UInt16, srcY: UInt16, srcZ: UInt16, width: UInt16, height: UInt16, depth: UInt16): Unit
```
编码器内纹理区域拷贝

参数: 

|名称|类型|描述|
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
编码器内丢弃状态组

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|flags|UInt8||

### func encoderDispatchIndirect\(EncoderPtr,UInt16,ProgramHandle,IndirectBufferHandle,UInt32,UInt32,UInt8\)
```cj
public func encoderDispatchIndirect(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, flags: UInt8): Unit
```
编码器内提交间接计算调度

参数: 

|名称|类型|描述|
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
编码器内提交计算调度

参数: 

|名称|类型|描述|
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
提交编码器中的命令

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||

### func encoderSetComputeDynamicIndexBuffer\(EncoderPtr,UInt8,DynamicIndexBufferHandle,UInt32\)
```cj
public func encoderSetComputeDynamicIndexBuffer(encoder: EncoderPtr, stage: UInt8, handle: DynamicIndexBufferHandle, access: UInt32): Unit
```
编码器内绑定计算动态索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|DynamicIndexBufferHandle||
|access|UInt32||

### func encoderSetComputeDynamicVertexBuffer\(EncoderPtr,UInt8,DynamicVertexBufferHandle,UInt32\)
```cj
public func encoderSetComputeDynamicVertexBuffer(encoder: EncoderPtr, stage: UInt8, handle: DynamicVertexBufferHandle, access: UInt32): Unit
```
编码器内绑定计算动态顶点缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|DynamicVertexBufferHandle||
|access|UInt32||

### func encoderSetComputeIndexBuffer\(EncoderPtr,UInt8,IndexBufferHandle,UInt32\)
```cj
public func encoderSetComputeIndexBuffer(encoder: EncoderPtr, stage: UInt8, handle: IndexBufferHandle, access: UInt32): Unit
```
编码器内绑定计算索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|IndexBufferHandle||
|access|UInt32||

### func encoderSetComputeIndirectBuffer\(EncoderPtr,UInt8,IndirectBufferHandle,UInt32\)
```cj
public func encoderSetComputeIndirectBuffer(encoder: EncoderPtr, stage: UInt8, handle: IndirectBufferHandle, access: UInt32): Unit
```
编码器内绑定计算间接缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|IndirectBufferHandle||
|access|UInt32||

### func encoderSetComputeVertexBuffer\(EncoderPtr,UInt8,VertexBufferHandle,UInt32\)
```cj
public func encoderSetComputeVertexBuffer(encoder: EncoderPtr, stage: UInt8, handle: VertexBufferHandle, access: UInt32): Unit
```
编码器内绑定计算顶点缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|stage|UInt8||
|handle|VertexBufferHandle||
|access|UInt32||

### func encoderSetCondition\(EncoderPtr,OcclusionQueryHandle,Bool\)
```cj
public func encoderSetCondition(encoder: EncoderPtr, handle: OcclusionQueryHandle, visible: Bool): Unit
```
编码器内设置遮挡查询条件

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|handle|OcclusionQueryHandle||
|visible|Bool||

### func encoderSetDynamicIndexBuffer\(EncoderPtr,DynamicIndexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetDynamicIndexBuffer(encoder: EncoderPtr, handle: DynamicIndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit
```
编码器内设置动态索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|handle|DynamicIndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func encoderSetDynamicVertexBufferWithLayout\(EncoderPtr,UInt8,DynamicVertexBufferHandle,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func encoderSetDynamicVertexBufferWithLayout(encoder: EncoderPtr, stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
编码器内设置动态顶点缓冲（带 layout）

参数: 

|名称|类型|描述|
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
编码器内设置动态顶点缓冲

参数: 

|名称|类型|描述|
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
编码器内绑定图像

参数: 

|名称|类型|描述|
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
编码器内设置索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|handle|IndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func encoderSetInstanceCount\(EncoderPtr,UInt32\)
```cj
public func encoderSetInstanceCount(encoder: EncoderPtr, numInstances: UInt32): Unit
```
编码器内设置实例计数

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|numInstances|UInt32||

### func encoderSetInstanceDataBuffer\(EncoderPtr,InstanceDataBufferPtr,UInt32,UInt32\)
```cj
public func encoderSetInstanceDataBuffer(encoder: EncoderPtr, idb: InstanceDataBufferPtr, start: UInt32, num: UInt32): Unit
```
编码器内设置实例数据缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|idb|InstanceDataBufferPtr||
|start|UInt32||
|num|UInt32||

### func encoderSetInstanceDataFromDynamicVertexBuffer\(EncoderPtr,DynamicVertexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetInstanceDataFromDynamicVertexBuffer(encoder: EncoderPtr, handle: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
编码器内从动态顶点缓冲设置实例数据

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|handle|DynamicVertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func encoderSetInstanceDataFromVertexBuffer\(EncoderPtr,VertexBufferHandle,UInt32,UInt32\)
```cj
public func encoderSetInstanceDataFromVertexBuffer(encoder: EncoderPtr, handle: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
编码器内从顶点缓冲设置实例数据

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|handle|VertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func encoderSetMarker\(EncoderPtr,String\)
```cj
public func encoderSetMarker(encoder: EncoderPtr, name: String): Unit
```
编码器内设置调试标记

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|name|String||

### func encoderSetScissorCached\(EncoderPtr,UInt16\)
```cj
public func encoderSetScissorCached(encoder: EncoderPtr, cache: UInt16): Unit
```
编码器内复用缓存裁剪矩形

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|cache|UInt16||

### func encoderSetScissor\(EncoderPtr,UInt16,UInt16,UInt16,UInt16\)
```cj
public func encoderSetScissor(encoder: EncoderPtr, x: UInt16, y: UInt16, width: UInt16, height: UInt16): UInt16
```
编码器内设置裁剪矩形（返回 cache 序号）

参数: 

|名称|类型|描述|
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
编码器内设置渲染状态

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|state|UInt64||
|rgba|UInt32||

### func encoderSetStencil\(EncoderPtr,UInt32,UInt32\)
```cj
public func encoderSetStencil(encoder: EncoderPtr, fstencil: UInt32, bstencil: UInt32): Unit
```
编码器内设置模板状态

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|fstencil|UInt32||
|bstencil|UInt32||

### func encoderSetTexture\(EncoderPtr,UInt8,UniformHandle,TextureHandle,UInt32\)
```cj
public func encoderSetTexture(encoder: EncoderPtr, stage: UInt8, sampler: UniformHandle, handle: TextureHandle, flags: UInt32): Unit
```
编码器内绑定纹理

参数: 

|名称|类型|描述|
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
编码器内复用缓存变换

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|cache|UInt32||
|num|UInt16||

### func encoderSetTransform\(EncoderPtr,BgfxMemory,UInt16\)
```cj
public func encoderSetTransform(encoder: EncoderPtr, mtx: BgfxMemory, num: UInt16): UInt32
```
编码器内设置变换矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|mtx|BgfxMemory||
|num|UInt16||

### func encoderSetTransientIndexBuffer\(EncoderPtr,TransientIndexBufferPtr,UInt32,UInt32\)
```cj
public func encoderSetTransientIndexBuffer(encoder: EncoderPtr, tib: TransientIndexBufferPtr, firstIndex: UInt32, numIndices: UInt32): Unit
```
编码器内设置瞬态索引缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|tib|TransientIndexBufferPtr||
|firstIndex|UInt32||
|numIndices|UInt32||

### func encoderSetTransientVertexBufferWithLayout\(EncoderPtr,UInt8,TransientVertexBufferPtr,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func encoderSetTransientVertexBufferWithLayout(encoder: EncoderPtr, stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
编码器内设置瞬态顶点缓冲（带 layout）

参数: 

|名称|类型|描述|
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
编码器内设置瞬态顶点缓冲

参数: 

|名称|类型|描述|
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
编码器内设置 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|handle|UniformHandle||
|value|BgfxMemory||
|num|UInt16||

### func encoderSetVertexBufferWithLayout\(EncoderPtr,UInt8,VertexBufferHandle,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func encoderSetVertexBufferWithLayout(encoder: EncoderPtr, stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
编码器内设置顶点缓冲（带 layout）

参数: 

|名称|类型|描述|
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
编码器内设置顶点缓冲

参数: 

|名称|类型|描述|
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
编码器内设置顶点计数

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|numVertices|UInt32||

### func encoderSubmitIndirectCount\(EncoderPtr,UInt16,ProgramHandle,IndirectBufferHandle,UInt32,IndexBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func encoderSubmitIndirectCount(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32, depth: UInt32, flags: UInt8): Unit
```
编码器内提交带计数间接绘制

参数: 

|名称|类型|描述|
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
编码器内提交间接绘制

参数: 

|名称|类型|描述|
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
编码器内提交遮挡查询 draw

参数: 

|名称|类型|描述|
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
编码器内提交 draw

参数: 

|名称|类型|描述|
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
编码器内触发 view

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|EncoderPtr||
|id|UInt16||

### func execBgfx\(\(\)\->Unit\)
```cj
public func execBgfx(cmd:() -> Unit): Unit
```
公开线程序列化入口：外部模块的 bgfx API 调用排队到渲染线程

参数: 

|名称|类型|描述|
|---|---|---|
|cmd|()->Unit|待执行的 bgfx 调用闭包|

### func getCaps\(\)
```cj
public func getCaps(): CapsPtr
```
获取渲染器能力（CPointer，读取字段由调用方负责）。

### func getDirectAccessPtr\(TextureHandle\)
```cj
public func getDirectAccessPtr(tex: TextureHandle): UnitPtr
```
获取纹理直接访问指针（零拷贝读纹理）。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|TextureHandle||

### func getInterface\(UInt32\)
```cj
public func getInterface(version: UInt32): UnitPtr
```
获取 bgfx 扩展接口（版本匹配时返回接口指针）。

参数: 

|名称|类型|描述|
|---|---|---|
|version|UInt32||

### func getInternalData\(\)
```cj
public func getInternalData(): InternalDataPtr
```
获取 bgfx 内部数据（caps/context 指针）。

### func getOcclusionQueryResult\(OcclusionQueryHandle,PtrArray<Int32>\)
```cj
public func getOcclusionQueryResult(handle: OcclusionQueryHandle, result: PtrArray < Int32 >): UInt32
```
查询遮挡查询结果。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|OcclusionQueryHandle|遮挡查询句柄result 输出结果指针（Int32：可见像素数或 0）|
|result|PtrArray<Int32>||

返回: 

- 结果状态（0=未就绪，1=已就绪，对应 OcclusionQueryResult.value()）

### func getRenderTarget\(\)
```cj
public func getRenderTarget(): Option < IRenderTarget >
```
获取当前渲染目标

返回: 

- 当前渲染目标（None 表示默认帧缓冲）

### func getRenderViewId\(\)
```cj
public override func getRenderViewId(): UInt16
```
获取当前渲染 view id（override 基类钩子）

返回: 

- 当前 view id

### func getRendererName\(UInt32\)
```cj
public func getRendererName(`type`: UInt32): String
```
获取渲染后端名称（C 字符串）。

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|UInt32||

### func getRendererType\(\)
```cj
public func getRendererType(): UInt32
```
获取当前渲染后端类型。

返回: 

- RendererType.value()

### func getShaderUniforms\(ShaderHandle,UInt16\)
```cj
public func getShaderUniforms(handle: ShaderHandle, max: UInt16):(Array < UniformHandle >, UInt16)
```
获取着色器引用的 uniform 句柄列表。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ShaderHandle|着色器句柄max 最大查询数量|
|max|UInt16||

返回: 

- (uniform 句柄数组, 实际数量)

### func getStats\(\)
```cj
public func getStats(): StatsPtr
```
获取渲染器统计（CPointer，指针在下一帧 frame 前有效）。

### func getSupportedRenderers\(UInt8,PtrArray<UInt32>\)
```cj
public func getSupportedRenderers(max: UInt8, `enum`: PtrArray < UInt32 >): UInt8
```
获取支持的后端列表。

参数: 

|名称|类型|描述|
|---|---|---|
|max|UInt8||
|`enum`|PtrArray<UInt32>||

### func getTexture\(FrameBufferHandle,UInt8\)
```cj
public func getTexture(fb: FrameBufferHandle, attachment: UInt8): TextureHandle
```
取 frame buffer 指定 attachment 的纹理句柄

参数: 

|名称|类型|描述|
|---|---|---|
|fb|FrameBufferHandle|源 frame bufferattachment attachment 索引（0=主 color，1=depth 等）|
|attachment|UInt8||

返回: 

- attachment 对应的 TextureHandle

### func getUniformInfo\(UniformHandle,UniformInfoPtr\)
```cj
public func getUniformInfo(handle: UniformHandle, info: UniformInfoPtr): Unit
```
获取 uniform 信息（名称/类型/数量）。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|UniformHandle|uniform 句柄info 输出 UniformInfo 指针|
|info|UniformInfoPtr||

### func initBgfx\(UIntNative,Int32,Int32\)
```cj
public func initBgfx(hwnd: UIntNative, width: Int32, height: Int32): Bool
```
初始化 bgfx 渲染器

参数: 

|名称|类型|描述|
|---|---|---|
|hwnd|UIntNative|原生窗口句柄width 窗口逻辑宽度height 窗口逻辑高度|
|width|Int32||
|height|Int32||

返回: 

- 初始化是否成功

### func init\(\)
```cj
public init()
```


### func isFrameBufferValid\(UInt8,AttachmentPtr\)
```cj
public func isFrameBufferValid(num: UInt8, attachment: AttachmentPtr): Bool
```
查询 frame buffer 配置是否有效。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt8||
|attachment|AttachmentPtr||

### func isTextureValid\(UInt16,Bool,UInt16,UInt32,UInt64\)
```cj
public func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): Bool
```
查询纹理参数是否有效。

参数: 

|名称|类型|描述|
|---|---|---|
|depth|UInt16|深度（2D 纹理=1）cubeMap 是否 cubenumLayers 图层数format 纹理格式flags 纹理 flags|
|cubeMap|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||

返回: 

- 是否有效

### func makeRef\(PtrArray<UInt8>\)
```cj
public func makeRef(data: PtrArray < UInt8 >): BgfxMemory
```
包装原始像素数据为 bgfx Memory 引用。

参数: 

|名称|类型|描述|
|---|---|---|
|data|PtrArray<UInt8>|像素数据指针size 数据字节数|

返回: 

- bgfx Memory 引用指针

### func present\(Bool\)
```cj
public func present(capture!: Bool = false): Unit
```
触发一次 bgfx frame 双缓冲交换上屏

参数: 

|名称|类型|描述|
|---|---|---|
|capture|Bool|是否截屏（默认 false）|

### func readTexture\(TextureHandle,PtrArray<UInt8>,UInt8\)
```cj
public func readTexture(tex: TextureHandle, data: PtrArray < UInt8 >, mip!: UInt8 = 0u8): UInt32
```
回读纹理到 CPU 内存（异步）

参数: 

|名称|类型|描述|
|---|---|---|
|tex|TextureHandle|源纹理（Box 包装句柄）data 回读目标缓冲（PtrArray<UInt8>，底层指针由内部持有）mip mip 层（默认 0）|
|data|PtrArray<UInt8>||
|mip|UInt8||

返回: 

- 数据就绪的 frame 序号（此后才可安全读 data）

### func renderFrame\(Int32\)
```cj
public func renderFrame(msecs: Int32): UInt32
```
手动驱动渲染帧。

参数: 

|名称|类型|描述|
|---|---|---|
|msecs|Int32|等待毫秒数（-1 阻塞等待）|

返回: 

- RenderFrame.value()

### func render\(Scene,Camera\)
```cj
public func render(scene: Scene, camera: Camera): Unit
```
渲染场景（经 _execBgfx 委托到渲染线程）

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|待渲染场景camera 渲染相机|
|camera|Camera||

### func requestScreenShot\(FrameBufferHandle,String\)
```cj
public func requestScreenShot(fb: FrameBufferHandle, filePath: String): Unit
```
请求截屏保存到文件。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|FrameBufferHandle||
|filePath|String||

### func resetView\(UInt16\)
```cj
public func resetView(viewId: UInt16): Unit
```
重置某 view 的全部状态

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view id|

### func reset\(UInt32,UInt32,UInt32,UInt32\)
```cj
public func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit
```
重置后备缓冲（分辨率/标志/格式）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|UInt32||
|height|UInt32||
|flags|UInt32||
|format|UInt32||

### func setClearColor\(Color,Float64\)
```cj
public func setClearColor(color: Color, alpha!: Float64 = 1.0): Unit
```
设置清除色 — Three.js 对齐：renderer.setClearColor(color, alpha)

参数: 

|名称|类型|描述|
|---|---|---|
|color|Color|清除颜色alpha 透明度，默认 1.0|
|alpha|Float64||

### func setComputeDynamicIndexBuffer\(UInt8,DynamicIndexBufferHandle,UInt32\)
```cj
public func setComputeDynamicIndexBuffer(stage: UInt8, ib: DynamicIndexBufferHandle, access: UInt32): Unit
```
绑定计算动态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|ib|DynamicIndexBufferHandle||
|access|UInt32||

### func setComputeDynamicVertexBuffer\(UInt8,DynamicVertexBufferHandle,UInt32\)
```cj
public func setComputeDynamicVertexBuffer(stage: UInt8, vb: DynamicVertexBufferHandle, access: UInt32): Unit
```
绑定计算动态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|DynamicVertexBufferHandle||
|access|UInt32||

### func setComputeIndexBuffer\(UInt8,IndexBufferHandle,UInt32\)
```cj
public func setComputeIndexBuffer(stage: UInt8, ib: IndexBufferHandle, access: UInt32): Unit
```
绑定计算索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|ib|IndexBufferHandle||
|access|UInt32||

### func setComputeIndirectBuffer\(UInt8,IndirectBufferHandle,UInt32\)
```cj
public func setComputeIndirectBuffer(stage: UInt8, ib: IndirectBufferHandle, access: UInt32): Unit
```
绑定计算间接缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|ib|IndirectBufferHandle||
|access|UInt32||

### func setComputeVertexBuffer\(UInt8,VertexBufferHandle,UInt32\)
```cj
public func setComputeVertexBuffer(stage: UInt8, vb: VertexBufferHandle, access: UInt32): Unit
```
绑定计算顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|VertexBufferHandle||
|access|UInt32||

### func setCondition\(OcclusionQueryHandle,Bool\)
```cj
public func setCondition(query: OcclusionQueryHandle, visible: Bool): Unit
```
设置遮挡查询条件（visible 决定后续 draw 是否执行）。

参数: 

|名称|类型|描述|
|---|---|---|
|query|OcclusionQueryHandle||
|visible|Bool||

### func setDebug\(UInt32\)
```cj
public func setDebug(debug: UInt32): Unit
```
设置 bgfx 全局调试标志

参数: 

|名称|类型|描述|
|---|---|---|
|debug|UInt32|bgfx 调试标志位|

### func setDynamicIndexBuffer\(DynamicIndexBufferHandle,UInt32,UInt32\)
```cj
public func setDynamicIndexBuffer(ib: DynamicIndexBufferHandle, firstIndex!: UInt32 = 0u32, numIndices!: UInt32 = 0xFFFFFFFFu32): Unit
```
设置 per-draw 动态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|DynamicIndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func setDynamicVertexBufferWithLayout\(UInt8,DynamicVertexBufferHandle,VertexLayoutHandle,UInt32,UInt32\)
```cj
public func setDynamicVertexBufferWithLayout(stage: UInt8, vb: DynamicVertexBufferHandle, layout: VertexLayoutHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
设置 per-draw 动态顶点缓冲（带 layout）。

参数: 

|名称|类型|描述|
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
设置 per-draw 动态顶点缓冲（无 layout）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|DynamicVertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setFrameBufferName\(FrameBufferHandle,String\)
```cj
public func setFrameBufferName(fb: FrameBufferHandle, name: String): Unit
```
设置 frame buffer 调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|FrameBufferHandle||
|name|String||

### func setImage\(UInt8,TextureHandle,UInt8,UInt32,UInt32\)
```cj
public func setImage(stage: UInt8, tex: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit
```
绑定图像（compute shader image unit）。

参数: 

|名称|类型|描述|
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
设置索引缓冲调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|IndexBufferHandle||
|name|String||

### func setIndexBuffer\(IndexBufferHandle,UInt32,UInt32\)
```cj
public func setIndexBuffer(ib: IndexBufferHandle, firstIndex!: UInt32 = 0u32, numIndices!: UInt32 = 0xFFFFFFFFu32): Unit
```
设置 per-draw 索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|IndexBufferHandle|索引缓冲句柄firstIndex 起始索引（默认 0）numIndices 索引数（0xFFFFFFFF 表示全部）|
|firstIndex|UInt32||
|numIndices|UInt32||

### func setInstanceCount\(UInt32\)
```cj
public func setInstanceCount(numInstances: UInt32): Unit
```
设置 per-draw 实例计数。

参数: 

|名称|类型|描述|
|---|---|---|
|numInstances|UInt32||

### func setInstanceDataBuffer\(InstanceDataBufferPtr,UInt32,UInt32\)
```cj
public func setInstanceDataBuffer(idb: InstanceDataBufferPtr, start: UInt32, num: UInt32): Unit
```
设置 per-draw 实例数据缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|idb|InstanceDataBufferPtr||
|start|UInt32||
|num|UInt32||

### func setInstanceDataFromDynamicVertexBuffer\(DynamicVertexBufferHandle,UInt32,UInt32\)
```cj
public func setInstanceDataFromDynamicVertexBuffer(vb: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
从动态顶点缓冲设置 per-draw 实例数据。

参数: 

|名称|类型|描述|
|---|---|---|
|vb|DynamicVertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func setInstanceDataFromVertexBuffer\(VertexBufferHandle,UInt32,UInt32\)
```cj
public func setInstanceDataFromVertexBuffer(vb: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit
```
从顶点缓冲设置 per-draw 实例数据。

参数: 

|名称|类型|描述|
|---|---|---|
|vb|VertexBufferHandle||
|startVertex|UInt32||
|num|UInt32||

### func setMarker\(String\)
```cj
public func setMarker(name: String): Unit
```
设置 per-draw 调试标记（渲染线程可见，用于调试工具）。

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func setPaletteColorRgba32f\(UInt8,Float32,Float32,Float32,Float32\)
```cj
public func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit
```
设置调色板颜色（4 分量 float 版本）

参数: 

|名称|类型|描述|
|---|---|---|
|index|UInt8|调色板索引（0..15）r 红（0.0~1.0）g 绿（0.0~1.0）b 蓝（0.0~1.0）a 透明度（0.0~1.0）|
|r|Float32||
|g|Float32||
|b|Float32||
|a|Float32||

### func setPaletteColorRgba8\(UInt8,UInt32\)
```cj
public func setPaletteColorRgba8(index: UInt8, rgba: UInt32): Unit
```
设置调色板颜色（8bit 打包版本）

参数: 

|名称|类型|描述|
|---|---|---|
|index|UInt8|调色板索引（0..15）rgba 打包颜色（0xRRGGBBAA）|
|rgba|UInt32||

### func setPaletteColor\(UInt8,PtrArray<Float32>\)
```cj
public func setPaletteColor(index: UInt8, rgba: PtrArray < Float32 >): Unit
```
设置调色板颜色（rgba 4 个 float）

参数: 

|名称|类型|描述|
|---|---|---|
|index|UInt8|调色板索引（0..15）rgba 4 个 float 指针（r,g,b,a）|
|rgba|PtrArray<Float32>||

### func setRenderTarget\(IRenderTarget,Int64,Int64\)
```cj
public func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit
```
设置渲染目标（IRenderer 接口实现，CubeCamera 6 面渲染的渲染目标切换）

参数: 

|名称|类型|描述|
|---|---|---|
|renderTarget|IRenderTarget|渲染目标cubeFace 立方体面索引（0~5）mipLevel mipmap 层级|
|cubeFace|Int64||
|mipLevel|Int64||

### func setScissorCached\(UInt16\)
```cj
public func setScissorCached(cache: UInt16): Unit
```
复用缓存的裁剪矩形（setScissor 返回的 cache 序号）。

参数: 

|名称|类型|描述|
|---|---|---|
|cache|UInt16||

### func setScissor\(UInt16,UInt16,UInt16,UInt16\)
```cj
public func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16
```
设置 per-draw 裁剪矩形（非 view 级，per-draw 瞬态）。

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16|裁剪区左上角 x（像素）y 裁剪区左上角 y（像素）w 裁剪区宽（像素）h 裁剪区高（像素）|
|y|UInt16||
|w|UInt16||
|h|UInt16||

返回: 

- 裁剪 cache 序号（可用 setScissorCached 复用）

### func setShaderName\(ShaderHandle,String\)
```cj
public func setShaderName(handle: ShaderHandle, name: String): Unit
```
设置着色器调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ShaderHandle||
|name|String||

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
设置阴影类型（转调 BgfxBackend.shadowMap）

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|阴影类型值|

### func setSize\(Int32,Int32\)
```cj
public func setSize(width: Int32, height: Int32): Unit
```
设置渲染器尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int32|逻辑宽度（像素）height 逻辑高度（像素）|
|height|Int32||

### func setState\(UInt64,UInt32\)
```cj
public func setState(state: UInt64, rgba!: UInt32 = 0u32): Unit
```
设置 per-draw 渲染状态

参数: 

|名称|类型|描述|
|---|---|---|
|state|UInt64|完整 render state 位域（BGFX_STATE_* 组合）rgba 颜色混合因子（默认 0，表示用 program 默认）|
|rgba|UInt32||

### func setStencil\(UInt32,UInt32\)
```cj
public func setStencil(fstencil: UInt32, bstencil: UInt32): Unit
```
设置模板状态（per-draw 瞬态）

参数: 

|名称|类型|描述|
|---|---|---|
|fstencil|UInt32|前面 stencil 位域bstencil 后面 stencil 位域|
|bstencil|UInt32||

### func setTextureName\(TextureHandle,String\)
```cj
public func setTextureName(tex: TextureHandle, name: String): Unit
```
设置纹理调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|TextureHandle||
|name|String||

### func setTransformCached\(UInt32,UInt16\)
```cj
public func setTransformCached(cache: UInt32, num: UInt16): Unit
```
复用缓存的变换矩阵（setTransform 返回的 cache 序号）。

参数: 

|名称|类型|描述|
|---|---|---|
|cache|UInt32||
|num|UInt16||

### func setTransform\(BgfxMemory,UInt16\)
```cj
public func setTransform(matrix: BgfxMemory, num!: UInt16 = 1u16): Unit
```
设置 per-draw 模型变换矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|BgfxMemory|4×4 模型矩阵指针（16 个 float32，列主序）num 矩阵数量（默认 1，实例化时 >1）|
|num|UInt16||

### func setTransientIndexBuffer\(TransientIndexBufferPtr,UInt32,UInt32\)
```cj
public func setTransientIndexBuffer(tib: TransientIndexBufferPtr, firstIndex: UInt32, numIndices: UInt32): Unit
```
设置 per-draw 瞬态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|tib|TransientIndexBufferPtr||
|firstIndex|UInt32||
|numIndices|UInt32||

### func setTransientVertexBufferWithLayout\(UInt8,TransientVertexBufferPtr,UInt32,UInt32,VertexLayoutHandle\)
```cj
public func setTransientVertexBufferWithLayout(stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle): Unit
```
设置 per-draw 瞬态顶点缓冲（带 layout）。

参数: 

|名称|类型|描述|
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
设置 per-draw 瞬态顶点缓冲（无 layout）。

参数: 

|名称|类型|描述|
|---|---|---|
|stream|UInt8||
|tvb|TransientVertexBufferPtr||
|startVertex|UInt32||
|numVertices|UInt32||

### func setUniform\(UniformHandle,BgfxMemory,UInt16\)
```cj
public func setUniform(handle: UniformHandle, data: BgfxMemory, num!: UInt16 = 1u16): Unit
```
设置 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|handle|UniformHandle|uniform 句柄data uniform 数据指针（float32 数组）num 数组长度（默认 1）|
|data|BgfxMemory||
|num|UInt16||

### func setVertexBufferName\(VertexBufferHandle,String\)
```cj
public func setVertexBufferName(vb: VertexBufferHandle, name: String): Unit
```
设置顶点缓冲调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|vb|VertexBufferHandle||
|name|String||

### func setVertexBufferWithLayout\(UInt8,VertexBufferHandle,VertexLayoutHandle,UInt32,UInt32\)
```cj
public func setVertexBufferWithLayout(stage: UInt8, vb: VertexBufferHandle, layout: VertexLayoutHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
设置 per-draw 顶点缓冲（带 layout）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8|顶点缓冲 stage（bgfx 通常 0，单流）vb 顶点缓冲句柄startVertex 起始顶点索引（默认 0）numVertices 顶点数（0xFFFFFFFF 表示全部）layout 顶点布局句柄|
|vb|VertexBufferHandle||
|layout|VertexLayoutHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setVertexBuffer\(UInt8,VertexBufferHandle,UInt32,UInt32\)
```cj
public func setVertexBuffer(stage: UInt8, vb: VertexBufferHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit
```
设置 per-draw 顶点缓冲（无 layout，layout 需已绑定）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|VertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setVertexCount\(UInt32\)
```cj
public func setVertexCount(numVertices: UInt32): Unit
```
设置顶点计数（无缓冲顶点模式，顶点由着色器生成）。

参数: 

|名称|类型|描述|
|---|---|---|
|numVertices|UInt32||

### func setViewClearMRT\(UInt16,UInt16,Float32,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8\)
```cj
public func setViewClearMRT(viewId: UInt16, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8, c2: UInt8, c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit
```
设置某 view 的多渲染目标清除（每附件独立颜色）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idflags clear 标志位（CLEAR_* 组合）depth clear 深度stencil clear 模板值|
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
设置某 view 的 clear（颜色 + 深度 + 模板）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idflags clear 标志位（CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004）color clear 颜色（UInt32）depth clear 深度（0.0~1.0，默认 1.0）stencil clear 模板值（默认 0）|
|flags|UInt16||
|color|UInt32||
|depth|Float32||
|stencil|UInt8||

### func setViewFrameBuffer\(UInt16,FrameBufferHandle\)
```cj
public func setViewFrameBuffer(viewId: UInt16, fb: FrameBufferHandle): Unit
```
设置某 view 的渲染目标 frame buffer

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view id（pass 持有，由 EffectComposer.allocViewId 分配）fb 目标 frame buffer；传无效 handle（idx=65535）表示写 swap chain（屏幕）|
|fb|FrameBufferHandle||

### func setViewMode\(UInt16,UInt32\)
```cj
public func setViewMode(viewId: UInt16, mode: UInt32): Unit
```
设置某 view 的渲染模式

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idmode ViewMode.value()（默认/顺序/深度升序/深度降序）|
|mode|UInt32||

### func setViewName\(UInt16,String\)
```cj
public func setViewName(viewId: UInt16, name: String): Unit
```
设置某 view 的名称（调试用）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idname view 名称（UTF-8）|
|name|String||

### func setViewOrder\(UInt16,PtrArray<UInt16>\)
```cj
public func setViewOrder(viewId: UInt16, order: PtrArray < UInt16 >): Unit
```
设置某 view 的执行顺序

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idorder view id 数组|
|order|PtrArray<UInt16>||

### func setViewRectRatio\(UInt16,UInt16,UInt16,UInt32\)
```cj
public func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: UInt32): Unit
```
按后备缓冲比例设置某 view 的视口矩形

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idx 视口左上角 x 比例基准y 视口左上角 y 比例基准ratio BackbufferRatio.value()（Half/Quarter/Eighth/Sixteenth/Double）|
|x|UInt16||
|y|UInt16||
|ratio|UInt32||

### func setViewRect\(UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
设置某 view 的视口矩形（像素）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idx 视口左上角 x（像素）y 视口左上角 y（像素）w 视口宽（像素）h 视口高（像素）|
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setViewScissor\(UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
设置某 view 的裁剪矩形

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idx 裁剪区左上角 x（像素）y 裁剪区左上角 y（像素）w 裁剪区宽（像素）h 裁剪区高（像素）|
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setViewTransform\(UInt16,BgfxMemory,BgfxMemory\)
```cj
public func setViewTransform(viewId: UInt16, view: BgfxMemory, proj: BgfxMemory): Unit
```
设置某 view 的 view/proj 变换矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idview 4×4 view 矩阵数据proj 4×4 projection 矩阵数据|
|view|BgfxMemory||
|proj|BgfxMemory||

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
关闭 bgfx 渲染器，释放资源

### func submitIndirectCount\(UInt16,ProgramHandle,IndirectBufferHandle,UInt32,IndexBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
public func submitIndirectCount(viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit
```
提交带计数缓冲的间接绘制。

参数: 

|名称|类型|描述|
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
提交间接绘制（GPU 侧生成 draw 参数）。

参数: 

|名称|类型|描述|
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
提交带遮挡查询的 draw。

参数: 

|名称|类型|描述|
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
提交当前 draw 到指定 view

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view idprogram 已编译的 program handledepth 深度值（默认 0，供排序用）blend 混合标志位（0xFF 表示用 program 默认）|
|program|ProgramHandle||
|depth|UInt32||
|blend|UInt8||

### func touchView\(UInt16\)
```cj
public func touchView(viewId: UInt16): Unit
```
触发某 view 的 empty submit（仅推进 clear / view 序号，不绘制）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view id|

### func touch\(UInt16\)
```cj
public func touch(viewId: UInt16): Unit
```
触发 view 的 empty submit（仅推进 clear / view 序号，不绘制）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|bgfx view id|

### func updateDynamicIndexBuffer\(DynamicIndexBufferHandle,UInt32,BgfxMemory\)
```cj
public func updateDynamicIndexBuffer(handle: DynamicIndexBufferHandle, startIndex: UInt32, mem: BgfxMemory): Unit
```
更新动态索引缓冲数据。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicIndexBufferHandle||
|startIndex|UInt32||
|mem|BgfxMemory||

### func updateDynamicVertexBuffer\(DynamicVertexBufferHandle,UInt32,BgfxMemory\)
```cj
public func updateDynamicVertexBuffer(handle: DynamicVertexBufferHandle, startVertex: UInt32, mem: BgfxMemory): Unit
```
更新动态顶点缓冲数据。

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicVertexBufferHandle||
|startVertex|UInt32||
|mem|BgfxMemory||

### func updateTexture2D\(TextureHandle,UInt16,UInt8,UInt16,UInt16,UInt16,UInt16,BgfxMemory,UInt16\)
```cj
public func updateTexture2D(tex: TextureHandle, layer: UInt16, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: BgfxMemory, pitch: UInt16): Unit
```
更新 2D 纹理子区域数据。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|TextureHandle|目标纹理句柄layer 图层索引mip mip 层x 子区域 x 偏移y 子区域 y 偏移width 子区域宽height 子区域高mem 像素数据（BgfxMemory）pitch 行步长（字节）|
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
更新 3D 纹理子区域数据。

参数: 

|名称|类型|描述|
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
更新 cube 纹理面子区域数据。

参数: 

|名称|类型|描述|
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
清除色（RGBA32）

### var viewId
```cj
public var viewId: UInt16 = 0u16
```
当前渲染 view id

