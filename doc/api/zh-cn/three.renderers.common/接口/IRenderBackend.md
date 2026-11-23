# 接口
## interface IRenderBackend
```cj
public interface IRenderBackend <: IReleasable
```


### func acquireEncoder\(Bool\)
```cj
func acquireEncoder(forThread!: Bool): IGfxEncoder
```
获取一个 encoder（forThread=true 时绑定当前线程）；同一时刻一个 encoder 仅可被一个线程使用。

参数: 

|名称|类型|描述|
|---|---|---|
|forThread|Bool||

### func blitTexture\(UInt16,GfxTextureHandle,GfxTextureHandle,UInt16,UInt16\)
```cj
func blitTexture(viewId: UInt16, dst: GfxTextureHandle, src: GfxTextureHandle, width: UInt16, height: UInt16): Unit
```
纹理拷贝（整图区域）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|dst|GfxTextureHandle||
|src|GfxTextureHandle||
|width|UInt16||
|height|UInt16||

### func calcTextureSize\(UInt16,UInt16,UInt16,Bool,Bool,UInt16,GfxTextureFormat\)
```cj
func calcTextureSize(width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat):(UInt32, UInt32, UInt32, UInt32, UInt32)
```
计算纹理存储信息；返回 (storageSize, width, height, depth, numMips)。

参数: 

|名称|类型|描述|
|---|---|---|
|width|UInt16||
|height|UInt16||
|depth|UInt16||
|cubeMap|Bool||
|hasMips|Bool||
|numLayers|UInt16||
|format|GfxTextureFormat||

### func createComputeProgram\(GfxShaderHandle,Bool\)
```cj
func createComputeProgram(csh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle
```
创建计算程序。

参数: 

|名称|类型|描述|
|---|---|---|
|csh|GfxShaderHandle||
|destroyShaders|Bool||

### func createDynamicIndexBuffer\(UInt32,UInt16\)
```cj
func createDynamicIndexBuffer(num: UInt32, flags: UInt16): GfxDynamicIndexBufferHandle
```
创建动态索引缓冲（容量按索引数）。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32||
|flags|UInt16||

### func createDynamicVertexBuffer\(UInt32,GfxVertexLayoutHandle,UInt16\)
```cj
func createDynamicVertexBuffer(num: UInt32, layout: GfxVertexLayoutHandle, flags: UInt16): GfxDynamicVertexBufferHandle
```
创建动态顶点缓冲（容量按顶点数，数据由 update 填充）。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32||
|layout|GfxVertexLayoutHandle||
|flags|UInt16||

### func createFrameBufferFromHandles\(Array<GfxTextureHandle>,Bool\)
```cj
func createFrameBufferFromHandles(handles: Array < GfxTextureHandle >, destroyHandles: Bool): GfxFrameBufferHandle
```
由既有纹理句柄列表创建帧缓冲；destroyHandles 决定销毁时是否级联销毁纹理。

参数: 

|名称|类型|描述|
|---|---|---|
|handles|Array<GfxTextureHandle>||
|destroyHandles|Bool||

### func createFrameBufferFromNwh\(VoidPtr,UInt16,UInt16,GfxTextureFormat,GfxTextureFormat\)
```cj
func createFrameBufferFromNwh(nwh: VoidPtr, w: UInt16, h: UInt16, format: GfxTextureFormat, depthFormat: GfxTextureFormat): GfxFrameBufferHandle
```
由平台窗口句柄创建帧缓冲（多窗口/离屏交换链）；depthFormat 为深度附着格式。

参数: 

|名称|类型|描述|
|---|---|---|
|nwh|VoidPtr||
|w|UInt16||
|h|UInt16||
|format|GfxTextureFormat||
|depthFormat|GfxTextureFormat||

### func createFrameBufferScaled\(GfxBackbufferRatio,GfxTextureFormat,UInt64\)
```cj
func createFrameBufferScaled(ratio: GfxBackbufferRatio, format: GfxTextureFormat, textureFlags: UInt64): GfxFrameBufferHandle
```
创建与后缓冲成比例的帧缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|ratio|GfxBackbufferRatio||
|format|GfxTextureFormat||
|textureFlags|UInt64||

### func createFrameBuffer\(UInt16,UInt16,GfxTextureFormat,UInt64\)
```cj
func createFrameBuffer(w: UInt16, h: UInt16, format: GfxTextureFormat, depthFlags: UInt64): GfxFrameBufferHandle
```
由宽高与格式创建帧缓冲（含深度附着）。

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16||
|h|UInt16||
|format|GfxTextureFormat||
|depthFlags|UInt64||

### func createIndexBuffer\(PtrArray<UInt8>,UInt16\)
```cj
func createIndexBuffer(data: PtrArray < UInt8 >, flags: UInt16): GfxIndexBufferHandle
```
创建静态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|data|PtrArray<UInt8>||
|flags|UInt16||

### func createIndirectBuffer\(UInt32\)
```cj
func createIndirectBuffer(num: UInt32): GfxIndirectBufferHandle
```
创建间接绘制缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|num|UInt32||

### func createOcclusionQuery\(\)
```cj
func createOcclusionQuery(): GfxOcclusionQueryHandle
```
创建遮挡查询。

### func createProgram\(GfxShaderHandle,GfxShaderHandle,Bool\)
```cj
func createProgram(vsh: GfxShaderHandle, fsh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle
```
链接顶点+片段着色器为程序；destroyShaders 决定销毁时是否级联销毁着色器。

参数: 

|名称|类型|描述|
|---|---|---|
|vsh|GfxShaderHandle||
|fsh|GfxShaderHandle||
|destroyShaders|Bool||

### func createShader\(PtrArray<UInt8>\)
```cj
func createShader(data: PtrArray < UInt8 >): GfxShaderHandle
```
创建着色器（后端二进制格式数据）。

参数: 

|名称|类型|描述|
|---|---|---|
|data|PtrArray<UInt8>||

### func createTexture2DScaled\(GfxBackbufferRatio,Bool,UInt16,GfxTextureFormat,UInt64\)
```cj
func createTexture2DScaled(ratio: GfxBackbufferRatio, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64): GfxTextureHandle
```
创建与后缓冲成比例的 2D 纹理。

参数: 

|名称|类型|描述|
|---|---|---|
|ratio|GfxBackbufferRatio||
|hasMips|Bool||
|numLayers|UInt16||
|format|GfxTextureFormat||
|flags|UInt64||

### func createTexture2D\(UInt16,UInt16,Bool,UInt16,GfxTextureFormat,UInt64,Option<PtrArray<UInt8>>\)
```cj
func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64, data: Option < PtrArray < UInt8 >>): GfxTextureHandle
```
创建 2D 纹理；data 为 None 表示空渲染目标纹理。

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16||
|h|UInt16||
|hasMips|Bool||
|numLayers|UInt16||
|format|GfxTextureFormat||
|flags|UInt64||
|data|Option<PtrArray<UInt8>>||

### func createTexture3D\(UInt16,UInt16,UInt16,Bool,GfxTextureFormat,UInt64,Option<PtrArray<UInt8>>\)
```cj
func createTexture3D(w: UInt16, h: UInt16, depth: UInt16, hasMips: Bool, format: GfxTextureFormat, flags: UInt64, data: Option < PtrArray < UInt8 >>): GfxTextureHandle
```
创建 3D 纹理。

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16||
|h|UInt16||
|depth|UInt16||
|hasMips|Bool||
|format|GfxTextureFormat||
|flags|UInt64||
|data|Option<PtrArray<UInt8>>||

### func createTextureCube\(UInt16,Bool,UInt16,GfxTextureFormat,UInt64,Option<PtrArray<UInt8>>\)
```cj
func createTextureCube(side: UInt16, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64, data: Option < PtrArray < UInt8 >>): GfxTextureHandle
```
创建立方体纹理（6 面连续数据）。

参数: 

|名称|类型|描述|
|---|---|---|
|side|UInt16||
|hasMips|Bool||
|numLayers|UInt16||
|format|GfxTextureFormat||
|flags|UInt64||
|data|Option<PtrArray<UInt8>>||

### func createUniform\(String,GfxUniformType,UInt16\)
```cj
func createUniform(name: String, uniformType: GfxUniformType, num!: UInt16): GfxUniformHandle
```
按名称与类型创建全局 uniform。

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|uniformType|GfxUniformType||
|num|UInt16||

### func createVertexBuffer\(GfxVertexLayoutHandle,PtrArray<UInt8>,UInt16\)
```cj
func createVertexBuffer(layout: GfxVertexLayoutHandle, data: PtrArray < UInt8 >, flags: UInt16): GfxVertexBufferHandle
```
创建静态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|layout|GfxVertexLayoutHandle||
|data|PtrArray<UInt8>||
|flags|UInt16||

### func createVertexLayout\(Array<GfxAttributeDesc>\)
```cj
func createVertexLayout(attributes: Array < GfxAttributeDesc >): GfxVertexLayoutHandle
```
由属性描述列表创建声明式顶点布局。

参数: 

|名称|类型|描述|
|---|---|---|
|attributes|Array<GfxAttributeDesc>||

### func dbgTextClear\(UInt8,Bool\)
```cj
func dbgTextClear(attr: UInt8, small: Bool): Unit
```
清空调试文本覆盖层。

参数: 

|名称|类型|描述|
|---|---|---|
|attr|UInt8||
|small|Bool||

### func dbgTextImage\(UInt16,UInt16,UInt16,UInt16,PtrArray<UInt8>,UInt16\)
```cj
func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16, data: PtrArray < UInt8 >, pitch: UInt16): Unit
```
在调试文本覆盖层绘制图像（8bit 每像素）。

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||
|data|PtrArray<UInt8>||
|pitch|UInt16||

### func dbgTextPrintf\(UInt16,UInt16,UInt8,String\)
```cj
func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit
```
在调试文本覆盖层打印。

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16||
|y|UInt16||
|attr|UInt8||
|format|String||

### func destroyDynamicIndexBuffer\(GfxDynamicIndexBufferHandle\)
```cj
func destroyDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle): Unit
```
销毁动态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxDynamicIndexBufferHandle||

### func destroyDynamicVertexBuffer\(GfxDynamicVertexBufferHandle\)
```cj
func destroyDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle): Unit
```
销毁动态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxDynamicVertexBufferHandle||

### func destroyFrameBuffer\(GfxFrameBufferHandle\)
```cj
func destroyFrameBuffer(fb: GfxFrameBufferHandle): Unit
```
销毁帧缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|GfxFrameBufferHandle||

### func destroyIndexBuffer\(GfxIndexBufferHandle\)
```cj
func destroyIndexBuffer(ib: GfxIndexBufferHandle): Unit
```
销毁静态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|GfxIndexBufferHandle||

### func destroyIndirectBuffer\(GfxIndirectBufferHandle\)
```cj
func destroyIndirectBuffer(h: GfxIndirectBufferHandle): Unit
```
销毁间接绘制缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxIndirectBufferHandle||

### func destroyOcclusionQuery\(GfxOcclusionQueryHandle\)
```cj
func destroyOcclusionQuery(h: GfxOcclusionQueryHandle): Unit
```
销毁遮挡查询。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxOcclusionQueryHandle||

### func destroyProgram\(GfxProgramHandle\)
```cj
func destroyProgram(h: GfxProgramHandle): Unit
```
销毁程序。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxProgramHandle||

### func destroyShader\(GfxShaderHandle\)
```cj
func destroyShader(h: GfxShaderHandle): Unit
```
销毁着色器。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxShaderHandle||

### func destroyTexture\(GfxTextureHandle\)
```cj
func destroyTexture(tex: GfxTextureHandle): Unit
```
销毁纹理。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|GfxTextureHandle||

### func destroyUniform\(GfxUniformHandle\)
```cj
func destroyUniform(h: GfxUniformHandle): Unit
```
销毁 uniform。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxUniformHandle||

### func destroyVertexBuffer\(GfxVertexBufferHandle\)
```cj
func destroyVertexBuffer(vb: GfxVertexBufferHandle): Unit
```
销毁静态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|vb|GfxVertexBufferHandle||

### func destroyVertexLayout\(GfxVertexLayoutHandle\)
```cj
func destroyVertexLayout(layout: GfxVertexLayoutHandle): Unit
```
销毁顶点布局。

参数: 

|名称|类型|描述|
|---|---|---|
|layout|GfxVertexLayoutHandle||

### func discard\(UInt8\)
```cj
func discard(flags: UInt8): Unit
```
丢弃当前 draw 的指定状态组（性能提示）。

参数: 

|名称|类型|描述|
|---|---|---|
|flags|UInt8||

### func dispatch\(UInt16,GfxProgramHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
func dispatch(viewId: UInt16, program: GfxProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags!: UInt8): Unit
```
提交计算调度。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|program|GfxProgramHandle||
|numX|UInt32||
|numY|UInt32||
|numZ|UInt32||
|flags|UInt8||

### func getCapsSummary\(\)
```cj
func getCapsSummary(): GfxCapsSummary
```
获取设备能力摘要（值拷贝）。

### func getOcclusionQueryResult\(GfxOcclusionQueryHandle,PtrArray<Int32>\)
```cj
func getOcclusionQueryResult(h: GfxOcclusionQueryHandle, out: PtrArray < Int32 >): UInt32
```
获取遮挡查询结果（out 承载可见像素数）；返回后端状态码。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxOcclusionQueryHandle||
|out|PtrArray<Int32>||

### func getRendererName\(GfxRendererType\)
```cj
func getRendererName(`type`: GfxRendererType): String
```
获取指定类型的渲染后端名称。

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|GfxRendererType||

### func getRendererType\(\)
```cj
func getRendererType(): GfxRendererType
```
获取当前渲染后端类型。

### func getShaderUniforms\(GfxShaderHandle,UInt16\)
```cj
func getShaderUniforms(h: GfxShaderHandle, max: UInt16):(Array < GfxUniformHandle >, UInt16)
```
反射查询着色器 uniform 列表；返回 (句柄数组, 实际数量)。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxShaderHandle||
|max|UInt16||

### func getStatsSummary\(\)
```cj
func getStatsSummary(): GfxStatsSummary
```
获取帧统计摘要（值拷贝；数据在下一帧前有效）。

### func getSupportedRenderers\(\)
```cj
func getSupportedRenderers(): Array < GfxRendererType >
```
获取当前平台支持的后端类型列表。

### func getTextureFromFrameBuffer\(GfxFrameBufferHandle,UInt8\)
```cj
func getTextureFromFrameBuffer(fb: GfxFrameBufferHandle, attachment: UInt8): GfxTextureHandle
```
取帧缓冲某附着位的纹理句柄。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|GfxFrameBufferHandle||
|attachment|UInt8||

### func getUniformInfo\(GfxUniformHandle\)
```cj
func getUniformInfo(h: GfxUniformHandle): Option < GfxUniformDesc >
```
反射查询 uniform 信息（名称/类型/数量/大小）；无信息返回 None。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxUniformHandle||

### func initialize\(UIntNative,Int32,Int32,Bool,UInt32,UInt32,UInt8,UInt8\)
```cj
func initialize(hwnd: UIntNative, width: Int32, height: Int32, vsync!: Bool, msaa!: UInt32, maxAnisotropy!: UInt32, numBackBuffers!: UInt8, maxFrameLatency!: UInt8): Bool
```
初始化后端设备并绑定平台窗口。
hwnd 平台窗口句柄；width/height 逻辑尺寸；vsync 垂直同步；
msaa/maxAnisotropy 呈现质量标志；numBackBuffers/maxFrameLatency 交换链配置。
返回 false 表示失败（含自动降级重试后仍失败），不抛异常。

参数: 

|名称|类型|描述|
|---|---|---|
|hwnd|UIntNative||
|width|Int32||
|height|Int32||
|vsync|Bool||
|msaa|UInt32||
|maxAnisotropy|UInt32||
|numBackBuffers|UInt8||
|maxFrameLatency|UInt8||

### func isFrameBufferValid\(Array<GfxAttachmentDesc>\)
```cj
func isFrameBufferValid(attachments: Array < GfxAttachmentDesc >): Bool
```
查询附着组合是否有效。

参数: 

|名称|类型|描述|
|---|---|---|
|attachments|Array<GfxAttachmentDesc>||

### func isTextureValid\(UInt16,Bool,UInt16,GfxTextureFormat,UInt64\)
```cj
func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64): Bool
```
查询纹理参数组合是否有效（创建前预检）。

参数: 

|名称|类型|描述|
|---|---|---|
|depth|UInt16||
|cubeMap|Bool||
|numLayers|UInt16||
|format|GfxTextureFormat||
|flags|UInt64||

### func present\(Bool\)
```cj
func present(capture!: Bool): Unit
```
触发一次双缓冲交换上屏；capture 为 true 时同时捕获截图。

参数: 

|名称|类型|描述|
|---|---|---|
|capture|Bool||

### func readTexture\(GfxTextureHandle,PtrArray<UInt8>,UInt8\)
```cj
func readTexture(tex: GfxTextureHandle, out: PtrArray < UInt8 >, mip!: UInt8): UInt32
```
异步回读纹理到 CPU 缓冲；返回数据就绪的帧序号。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|GfxTextureHandle||
|out|PtrArray<UInt8>||
|mip|UInt8||

### func releaseEncoder\(IGfxEncoder\)
```cj
func releaseEncoder(encoder: IGfxEncoder): Unit
```
归还 encoder（结束其提交序列）。

参数: 

|名称|类型|描述|
|---|---|---|
|encoder|IGfxEncoder||

### func renderFrame\(Int32\)
```cj
func renderFrame(msecs: Int32): UInt32
```
手动驱动一次渲染帧（阻塞等待模式由 msecs 决定），返回后端状态码。

参数: 

|名称|类型|描述|
|---|---|---|
|msecs|Int32||

### func requestScreenShot\(GfxFrameBufferHandle,String\)
```cj
func requestScreenShot(fb: GfxFrameBufferHandle, filePath: String): Unit
```
请求截屏到文件。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|GfxFrameBufferHandle||
|filePath|String||

### func resetView\(UInt16\)
```cj
func resetView(viewId: UInt16): Unit
```
复位视图状态为默认。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||

### func reset\(UInt32,UInt32,UInt32,UInt32\)
```cj
func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit
```
重置后备缓冲（分辨率/标志/格式）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|UInt32||
|height|UInt32||
|flags|UInt32||
|format|UInt32||

### func setCondition\(GfxOcclusionQueryHandle,Bool\)
```cj
func setCondition(query: GfxOcclusionQueryHandle, visible: Bool): Unit
```
设置遮挡查询条件（visible 决定后续 draw 是否执行）。

参数: 

|名称|类型|描述|
|---|---|---|
|query|GfxOcclusionQueryHandle||
|visible|Bool||

### func setDebug\(UInt32\)
```cj
func setDebug(debug: UInt32): Unit
```
设置全局调试标志位。

参数: 

|名称|类型|描述|
|---|---|---|
|debug|UInt32||

### func setDynamicIndexBuffer\(GfxDynamicIndexBufferHandle,UInt32,UInt32\)
```cj
func setDynamicIndexBuffer(ib: GfxDynamicIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit
```
绑定动态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|GfxDynamicIndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func setDynamicVertexBuffer\(UInt8,GfxDynamicVertexBufferHandle,UInt32,UInt32\)
```cj
func setDynamicVertexBuffer(stage: UInt8, vb: GfxDynamicVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit
```
绑定动态顶点缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|GfxDynamicVertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setFrameBufferName\(GfxFrameBufferHandle,String\)
```cj
func setFrameBufferName(fb: GfxFrameBufferHandle, name: String): Unit
```
设置帧缓冲调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|fb|GfxFrameBufferHandle||
|name|String||

### func setImage\(UInt8,GfxTextureHandle,UInt8,GfxAccess,GfxTextureFormat\)
```cj
func setImage(stage: UInt8, tex: GfxTextureHandle, mip: UInt8, access: GfxAccess, format: GfxTextureFormat): Unit
```
绑定图像（计算着色器读写）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|tex|GfxTextureHandle||
|mip|UInt8||
|access|GfxAccess||
|format|GfxTextureFormat||

### func setIndexBuffer\(GfxIndexBufferHandle,UInt32,UInt32\)
```cj
func setIndexBuffer(ib: GfxIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit
```
绑定静态索引缓冲。

参数: 

|名称|类型|描述|
|---|---|---|
|ib|GfxIndexBufferHandle||
|firstIndex|UInt32||
|numIndices|UInt32||

### func setInstanceCount\(UInt32\)
```cj
func setInstanceCount(numInstances: UInt32): Unit
```
设置 per-draw 实例计数。

参数: 

|名称|类型|描述|
|---|---|---|
|numInstances|UInt32||

### func setMarker\(String\)
```cj
func setMarker(name: String): Unit
```
设置 per-draw 调试标记。

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func setPaletteColorRgba32f\(UInt8,Float32,Float32,Float32,Float32\)
```cj
func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit
```
设置调色板颜色（RGBA float）。

参数: 

|名称|类型|描述|
|---|---|---|
|index|UInt8||
|r|Float32||
|g|Float32||
|b|Float32||
|a|Float32||

### func setScissorCached\(UInt16\)
```cj
func setScissorCached(cache: UInt16): Unit
```
复用缓存的裁剪矩形。

参数: 

|名称|类型|描述|
|---|---|---|
|cache|UInt16||

### func setScissor\(UInt16,UInt16,UInt16,UInt16\)
```cj
func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16
```
设置 per-draw 裁剪矩形；返回可复用的缓存序号。

参数: 

|名称|类型|描述|
|---|---|---|
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setShaderName\(GfxShaderHandle,String\)
```cj
func setShaderName(h: GfxShaderHandle, name: String): Unit
```
设置着色器调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxShaderHandle||
|name|String||

### func setState\(UInt64,UInt32\)
```cj
func setState(state: UInt64, rgba!: UInt32): Unit
```
设置 per-draw 渲染状态位域（每次 submit 前需重设）。

参数: 

|名称|类型|描述|
|---|---|---|
|state|UInt64||
|rgba|UInt32||

### func setStencil\(UInt32,UInt32\)
```cj
func setStencil(fstencil: UInt32, bstencil: UInt32): Unit
```
设置 per-draw 模板状态（前/后面位域）。

参数: 

|名称|类型|描述|
|---|---|---|
|fstencil|UInt32||
|bstencil|UInt32||

### func setTextureName\(GfxTextureHandle,String\)
```cj
func setTextureName(tex: GfxTextureHandle, name: String): Unit
```
设置纹理调试名称。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|GfxTextureHandle||
|name|String||

### func setTexture\(UInt8,GfxUniformHandle,GfxTextureHandle,UInt32\)
```cj
func setTexture(stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit
```
绑定纹理到采样器槽（flags 为 0 沿用纹理自身采样设置）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|sampler|GfxUniformHandle||
|tex|GfxTextureHandle||
|flags|UInt32||

### func setTransformCached\(UInt32,UInt16\)
```cj
func setTransformCached(cache: UInt32, num!: UInt16): Unit
```
复用缓存的变换矩阵。

参数: 

|名称|类型|描述|
|---|---|---|
|cache|UInt32||
|num|UInt16||

### func setTransform\(PtrArray<Float32>,UInt16\)
```cj
func setTransform(matrix: PtrArray < Float32 >, num!: UInt16): Unit
```
设置 per-draw 模型变换矩阵（列主序 16 元素 Float32；num>1 为实例化批量）。

参数: 

|名称|类型|描述|
|---|---|---|
|matrix|PtrArray<Float32>||
|num|UInt16||

### func setUniform\(GfxUniformHandle,PtrArray<Float32>,UInt16\)
```cj
func setUniform(h: GfxUniformHandle, data: PtrArray < Float32 >, num!: UInt16): Unit
```
设置 per-draw uniform 数据（Float32 数组；按 uniform 类型解释）。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxUniformHandle||
|data|PtrArray<Float32>||
|num|UInt16||

### func setVertexBufferWithLayout\(UInt8,GfxVertexBufferHandle,GfxVertexLayoutHandle,UInt32,UInt32\)
```cj
func setVertexBufferWithLayout(stage: UInt8, vb: GfxVertexBufferHandle, layout: GfxVertexLayoutHandle, startVertex!: UInt32, numVertices!: UInt32): Unit
```
绑定静态顶点缓冲（带布局）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|GfxVertexBufferHandle||
|layout|GfxVertexLayoutHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setVertexBuffer\(UInt8,GfxVertexBufferHandle,UInt32,UInt32\)
```cj
func setVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit
```
绑定静态顶点缓冲（无布局，布局需已绑定）。

参数: 

|名称|类型|描述|
|---|---|---|
|stage|UInt8||
|vb|GfxVertexBufferHandle||
|startVertex|UInt32||
|numVertices|UInt32||

### func setVertexCount\(UInt32\)
```cj
func setVertexCount(numVertices: UInt32): Unit
```
设置顶点计数（无顶点缓冲模式）。

参数: 

|名称|类型|描述|
|---|---|---|
|numVertices|UInt32||

### func setViewClearMrt\(UInt16,UInt16,Float32,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8\)
```cj
func setViewClearMrt(viewId: UInt16, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8, c2: UInt8, c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit
```
设置视图 MRT 清屏（调色板色索引 c0-c7 + 深度 + 模板）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
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
func setViewClear(viewId: UInt16, flags: UInt16, rgba: UInt32, depth!: Float32, stencil!: UInt8): Unit
```
设置视图清屏（颜色 + 深度 + 模板）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|flags|UInt16||
|rgba|UInt32||
|depth|Float32||
|stencil|UInt8||

### func setViewFrameBuffer\(UInt16,GfxFrameBufferHandle\)
```cj
func setViewFrameBuffer(viewId: UInt16, fb: GfxFrameBufferHandle): Unit
```
设置视图渲染目标帧缓冲；传无效句柄表示写交换链（屏幕）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|fb|GfxFrameBufferHandle||

### func setViewMode\(UInt16,GfxViewMode\)
```cj
func setViewMode(viewId: UInt16, mode: GfxViewMode): Unit
```
设置视图渲染排序模式。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|mode|GfxViewMode||

### func setViewName\(UInt16,String\)
```cj
func setViewName(viewId: UInt16, name: String): Unit
```
设置视图名称（调试用）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|name|String||

### func setViewOrder\(UInt16,Array<UInt16>\)
```cj
func setViewOrder(viewId: UInt16, order: Array < UInt16 >): Unit
```
设置视图执行顺序（按提交的顺序数组重排）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|order|Array<UInt16>||

### func setViewRectRatio\(UInt16,UInt16,UInt16,GfxBackbufferRatio\)
```cj
func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: GfxBackbufferRatio): Unit
```
按后缓冲比例设置视图视口矩形。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|x|UInt16||
|y|UInt16||
|ratio|GfxBackbufferRatio||

### func setViewRect\(UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
设置视图视口矩形（像素）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setViewScissor\(UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
设置视图裁剪矩形（像素）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|x|UInt16||
|y|UInt16||
|w|UInt16||
|h|UInt16||

### func setViewTransform\(UInt16,PtrArray<Float32>,PtrArray<Float32>\)
```cj
func setViewTransform(viewId: UInt16, view: PtrArray < Float32 >, proj: PtrArray < Float32 >): Unit
```
设置视图 view/proj 变换矩阵（各 16 元素 Float32，列主序）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|view|PtrArray<Float32>||
|proj|PtrArray<Float32>||

### func shutdown\(\)
```cj
func shutdown(): Unit
```
关闭后端并释放全部设备资源。

### func submitIndirect\(UInt16,GfxProgramHandle,GfxIndirectBufferHandle,UInt32,UInt32,UInt32,UInt8\)
```cj
func submitIndirect(viewId: UInt16, program: GfxProgramHandle, indirect: GfxIndirectBufferHandle, start: UInt32, num: UInt32, depth!: UInt32, blend!: UInt8): Unit
```
提交间接绘制（GPU 侧生成 draw 参数）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|program|GfxProgramHandle||
|indirect|GfxIndirectBufferHandle||
|start|UInt32||
|num|UInt32||
|depth|UInt32||
|blend|UInt8||

### func submitOcclusionQuery\(UInt16,GfxProgramHandle,GfxOcclusionQueryHandle,UInt32,UInt8\)
```cj
func submitOcclusionQuery(viewId: UInt16, program: GfxProgramHandle, query: GfxOcclusionQueryHandle, depth!: UInt32, blend!: UInt8): Unit
```
提交带遮挡查询的 draw。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|program|GfxProgramHandle||
|query|GfxOcclusionQueryHandle||
|depth|UInt32||
|blend|UInt8||

### func submit\(UInt16,GfxProgramHandle,UInt32,UInt8\)
```cj
func submit(viewId: UInt16, program: GfxProgramHandle, depth!: UInt32, blend!: UInt8): Unit
```
提交当前 draw 到视图（depth 供排序，0xFF 的 blend 表示用程序默认）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||
|program|GfxProgramHandle||
|depth|UInt32||
|blend|UInt8||

### func touchView\(UInt16\)
```cj
func touchView(viewId: UInt16): Unit
```
触发视图空提交（推进清屏/序号，不绘制）。

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16||

### func updateDynamicIndexBuffer\(GfxDynamicIndexBufferHandle,UInt32,PtrArray<UInt8>\)
```cj
func updateDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle, startIndex: UInt32, data: PtrArray < UInt8 >): Unit
```
更新动态索引缓冲（自 startIndex 起）。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxDynamicIndexBufferHandle||
|startIndex|UInt32||
|data|PtrArray<UInt8>||

### func updateDynamicVertexBuffer\(GfxDynamicVertexBufferHandle,UInt32,PtrArray<UInt8>\)
```cj
func updateDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle, startVertex: UInt32, data: PtrArray < UInt8 >): Unit
```
更新动态顶点缓冲（自 startVertex 起）。

参数: 

|名称|类型|描述|
|---|---|---|
|h|GfxDynamicVertexBufferHandle||
|startVertex|UInt32||
|data|PtrArray<UInt8>||

### func updateTexture2D\(GfxTextureHandle,UInt16,UInt8,UInt16,UInt16,UInt16,UInt16,PtrArray<UInt8>,UInt16\)
```cj
func updateTexture2D(tex: GfxTextureHandle, layer: UInt16, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, data: PtrArray < UInt8 >, pitch: UInt16): Unit
```
更新 2D 纹理子区域。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|GfxTextureHandle||
|layer|UInt16||
|mip|UInt8||
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|data|PtrArray<UInt8>||
|pitch|UInt16||

### func updateTexture3D\(GfxTextureHandle,UInt8,UInt16,UInt16,UInt16,UInt16,UInt16,UInt16,PtrArray<UInt8>\)
```cj
func updateTexture3D(tex: GfxTextureHandle, mip: UInt8, x: UInt16, y: UInt16, z: UInt16, width: UInt16, height: UInt16, depth: UInt16, data: PtrArray < UInt8 >): Unit
```
更新 3D 纹理子区域。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|GfxTextureHandle||
|mip|UInt8||
|x|UInt16||
|y|UInt16||
|z|UInt16||
|width|UInt16||
|height|UInt16||
|depth|UInt16||
|data|PtrArray<UInt8>||

### func updateTextureCube\(GfxTextureHandle,UInt16,UInt8,UInt8,UInt16,UInt16,UInt16,UInt16,PtrArray<UInt8>,UInt16\)
```cj
func updateTextureCube(tex: GfxTextureHandle, layer: UInt16, side: UInt8, mip: UInt8, x: UInt16, y: UInt16, width: UInt16, height: UInt16, data: PtrArray < UInt8 >, pitch: UInt16): Unit
```
更新立方体纹理面子区域。

参数: 

|名称|类型|描述|
|---|---|---|
|tex|GfxTextureHandle||
|layer|UInt16||
|side|UInt8||
|mip|UInt8||
|x|UInt16||
|y|UInt16||
|width|UInt16||
|height|UInt16||
|data|PtrArray<UInt8>||
|pitch|UInt16||

