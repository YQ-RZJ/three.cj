# 类
## class Handle
```cj
public class Handle
```
bgfx 类型工厂 —— 统一的 Box 包装类型构建入口

### func attachment\(TextureHandle,UInt32,UInt16,UInt16,UInt16,UInt8\)
```cj
public static func attachment(handle: TextureHandle, access: UInt32, layer: UInt16, numLayers: UInt16, mip: UInt16, flags: UInt8): Attachment
```
构建并初始化 Attachment（内部 bgfx_attachment_init）

参数: 

|名称|类型|描述|
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
以 idx 构造动态索引缓冲句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func dynamicVertexBuffer\(UInt16\)
```cj
public static func dynamicVertexBuffer(idx: UInt16): DynamicVertexBufferHandle
```
以 idx 构造动态顶点缓冲句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func framebuffer\(UInt16\)
```cj
public static func framebuffer(idx: UInt16): FrameBufferHandle
```
以 idx 构造帧缓冲句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func idx\(FrameBufferHandle\)
```cj
public static func idx(handle: FrameBufferHandle): UInt16
```
取FrameBufferHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|FrameBufferHandle||

### func idx\(TextureHandle\)
```cj
public static func idx(handle: TextureHandle): UInt16
```
取TextureHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|TextureHandle||

### func idx\(ProgramHandle\)
```cj
public static func idx(handle: ProgramHandle): UInt16
```
取ProgramHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ProgramHandle||

### func idx\(UniformHandle\)
```cj
public static func idx(handle: UniformHandle): UInt16
```
取UniformHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|UniformHandle||

### func idx\(VertexBufferHandle\)
```cj
public static func idx(handle: VertexBufferHandle): UInt16
```
取VertexBufferHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|VertexBufferHandle||

### func idx\(IndexBufferHandle\)
```cj
public static func idx(handle: IndexBufferHandle): UInt16
```
取IndexBufferHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|IndexBufferHandle||

### func idx\(VertexLayoutHandle\)
```cj
public static func idx(handle: VertexLayoutHandle): UInt16
```
取VertexLayoutHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|VertexLayoutHandle||

### func idx\(DynamicVertexBufferHandle\)
```cj
public static func idx(handle: DynamicVertexBufferHandle): UInt16
```
取DynamicVertexBufferHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicVertexBufferHandle||

### func idx\(DynamicIndexBufferHandle\)
```cj
public static func idx(handle: DynamicIndexBufferHandle): UInt16
```
取DynamicIndexBufferHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicIndexBufferHandle||

### func idx\(ShaderHandle\)
```cj
public static func idx(handle: ShaderHandle): UInt16
```
取ShaderHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ShaderHandle||

### func idx\(IndirectBufferHandle\)
```cj
public static func idx(handle: IndirectBufferHandle): UInt16
```
取IndirectBufferHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|IndirectBufferHandle||

### func idx\(OcclusionQueryHandle\)
```cj
public static func idx(handle: OcclusionQueryHandle): UInt16
```
取OcclusionQueryHandle内部 idx（仅用于日志调试输出；有效性判断请用 isValid）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|OcclusionQueryHandle||

### func indexBuffer\(UInt16\)
```cj
public static func indexBuffer(idx: UInt16): IndexBufferHandle
```
以 idx 构造静态索引缓冲句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func initParams\(\)
```cj
public static func initParams(): Init
```
构建经 bgfx_init_ctor 填充默认值的 Init 值快照（无指针暴露）

### func isValid\(FrameBufferHandle\)
```cj
public static func isValid(handle: FrameBufferHandle): Bool
```
判断FrameBufferHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|FrameBufferHandle||

### func isValid\(TextureHandle\)
```cj
public static func isValid(handle: TextureHandle): Bool
```
判断TextureHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|TextureHandle||

### func isValid\(ProgramHandle\)
```cj
public static func isValid(handle: ProgramHandle): Bool
```
判断ProgramHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ProgramHandle||

### func isValid\(UniformHandle\)
```cj
public static func isValid(handle: UniformHandle): Bool
```
判断UniformHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|UniformHandle||

### func isValid\(VertexBufferHandle\)
```cj
public static func isValid(handle: VertexBufferHandle): Bool
```
判断VertexBufferHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|VertexBufferHandle||

### func isValid\(IndexBufferHandle\)
```cj
public static func isValid(handle: IndexBufferHandle): Bool
```
判断IndexBufferHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|IndexBufferHandle||

### func isValid\(VertexLayoutHandle\)
```cj
public static func isValid(handle: VertexLayoutHandle): Bool
```
判断VertexLayoutHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|VertexLayoutHandle||

### func isValid\(DynamicVertexBufferHandle\)
```cj
public static func isValid(handle: DynamicVertexBufferHandle): Bool
```
判断DynamicVertexBufferHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicVertexBufferHandle||

### func isValid\(DynamicIndexBufferHandle\)
```cj
public static func isValid(handle: DynamicIndexBufferHandle): Bool
```
判断DynamicIndexBufferHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|DynamicIndexBufferHandle||

### func isValid\(ShaderHandle\)
```cj
public static func isValid(handle: ShaderHandle): Bool
```
判断ShaderHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|ShaderHandle||

### func isValid\(IndirectBufferHandle\)
```cj
public static func isValid(handle: IndirectBufferHandle): Bool
```
判断IndirectBufferHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|IndirectBufferHandle||

### func isValid\(OcclusionQueryHandle\)
```cj
public static func isValid(handle: OcclusionQueryHandle): Bool
```
判断OcclusionQueryHandle是否有效（idx != 0xFFFF）

参数: 

|名称|类型|描述|
|---|---|---|
|handle|OcclusionQueryHandle||

### func program\(UInt16\)
```cj
public static func program(idx: UInt16): ProgramHandle
```
以 idx 构造程序句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func shader\(UInt16\)
```cj
public static func shader(idx: UInt16): ShaderHandle
```
以 idx 构造着色器句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func swapChain\(CPointer<Unit>,UInt32,UInt32,UInt32,UInt32\)
```cj
public static func swapChain(nwh: CPointer < Unit >, width: UInt32, height: UInt32, formatColor: UInt32, formatDepthStencil: UInt32): SwapChain
```
构建 SwapChain 值快照（无指针暴露）

参数: 

|名称|类型|描述|
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
构建 TextureRegion 值快照（内部 bgfx_texture_region_init）

参数: 

|名称|类型|描述|
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
以 idx 构造纹理句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func uniform\(UInt16\)
```cj
public static func uniform(idx: UInt16): UniformHandle
```
以 idx 构造 uniform 句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func vertexBuffer\(UInt16\)
```cj
public static func vertexBuffer(idx: UInt16): VertexBufferHandle
```
以 idx 构造静态顶点缓冲句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

### func vertexLayout\(UInt16\)
```cj
public static func vertexLayout(idx: UInt16): VertexLayoutHandle
```
以 idx 构造顶点布局句柄

参数: 

|名称|类型|描述|
|---|---|---|
|idx|UInt16||

