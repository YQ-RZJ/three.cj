/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] IRenderBackend 渲染后端抽象接口
 * @brief[zh-cn] 引擎渲染管线的后端无关 GPU 能力契约（九大能力域）
 * @explain[zh-cn] 本接口是渲染抽象层的主契约，按能力域分组：
 * 生命周期与设备 / 视图治理 / 纹理与采样 / 帧缓冲 / 缓冲与布局 /
 * 着色器程序 uniform / 主线程提交 / 查询 / 调试，另含 encoder 受控获取口。
 * 约定：
 * - 线程模型：除注明外，所有方法可在任意线程调用——实现内部负责把调用路由/
 *   串行化到后端要求的线程（渲染线程或 API 线程）；"渲染线程"语义的编排责任
 *   由 Renderer 层与 runOnRenderThread 逃生舱承担；
 * - 资源创建失败返回对应句柄的 INVALID 值（不抛异常），调用方以 isValid 判断；
 * - 句柄仅在引擎树内传递比较，有效值仅由后端实现与抽象层资源对象构造；
 * - 本接口 internal：引擎全部子包可见、模块外不可见（可见性实验见 change
 *   tasks 0.1，工具链行为与官方文档一致）。
 *
 * @file[en] IRenderBackend render backend abstraction interface
 * @brief[en] The backend-agnostic GPU capability contract of the engine render pipeline (nine capability domains)
 * @explain[en] This interface is the primary contract of the render abstraction layer,
 * grouped by capability domain: lifecycle & device / view governance / textures &
 * sampling / frame buffers / buffers & layouts / shaders-programs-uniforms /
 * main-thread submission / queries / debugging, plus the controlled encoder access.
 * Conventions:
 * - Threading: unless noted, every method may be called from any thread — the
 *   implementation routes/serializes calls onto the threads the backend requires
 *   (render thread or API thread); "render-thread" orchestration duty belongs to
 *   the Renderer layer and the runOnRenderThread escape hatch;
 * - Resource creation failures return the INVALID value of the corresponding
 *   handle (no exceptions); callers check with isValid;
 * - Handles are only compared and passed within the engine tree; valid values are
 *   constructed only by the backend implementation and abstraction-layer
 *   resource objects;
 * - This interface is internal: visible to all engine subpackages and invisible
 *   outside the module (see the visibility experiment in change tasks 0.1; the
 *   toolchain matches the official documentation).
 *
 * @package three
 */
protected package three.renderers._interfaces

import three.renderers._gfx.*
import three.utils.memory.PtrArray
import three.utils.memory.VoidPtr
import three.utils.safe.IReleasable

public interface IRenderBackend <: IReleasable {
    // ========================================================================
    // ===== 域 1：生命周期与设备 =====
    // ========================================================================

    /**
     * 初始化后端设备并绑定平台窗口。
     * hwnd 平台窗口句柄；width/height 逻辑尺寸；vsync 垂直同步；
     * msaa/maxAnisotropy 呈现质量标志；numBackBuffers/maxFrameLatency 交换链配置。
     * 返回 false 表示失败（含自动降级重试后仍失败），不抛异常。
     */
    func initialize(hwnd: UIntNative, width: Int32, height: Int32, vsync!: Bool, msaa!: UInt32, maxAnisotropy!: UInt32,
        numBackBuffers!: UInt8, maxFrameLatency!: UInt8): Bool

    /** 关闭后端并释放全部设备资源。 */
    func shutdown(): Unit

    /** 重置后备缓冲（分辨率/标志/格式）。 */
    func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit

    /** 设置全局调试标志位。 */
    func setDebug(debug: UInt32): Unit

    /** 手动驱动一次渲染帧（阻塞等待模式由 msecs 决定），返回后端状态码。 */
    func renderFrame(msecs: Int32): UInt32

    /** 请求截屏到文件。 */
    func requestScreenShot(fb: GfxFrameBufferHandle, filePath: String): Unit

    /** 触发一次双缓冲交换上屏；capture 为 true 时同时捕获截图。 */
    func present(capture!: Bool): Unit

    // ========================================================================
    // ===== 域 2：视图治理 =====
    // ========================================================================

    /** 设置视图渲染目标帧缓冲；传无效句柄表示写交换链（屏幕）。 */
    func setViewFrameBuffer(viewId: UInt16, fb: GfxFrameBufferHandle): Unit

    /** 设置视图视口矩形（像素）。 */
    func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit

    /** 设置视图清屏（颜色 + 深度 + 模板）。 */
    func setViewClear(viewId: UInt16, flags: UInt16, rgba: UInt32, depth!: Float32, stencil!: UInt8): Unit

    /** 设置视图 MRT 清屏（调色板色索引 c0-c7 + 深度 + 模板）。 */
    func setViewClearMrt(viewId: UInt16, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8, c2: UInt8,
        c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit

    /** 设置视图 view/proj 变换矩阵（各 16 元素 Float32，列主序）。 */
    func setViewTransform(viewId: UInt16, view: PtrArray<Float32>, proj: PtrArray<Float32>): Unit

    /** 设置视图渲染排序模式。 */
    func setViewMode(viewId: UInt16, mode: GfxViewMode): Unit

    /** 设置视图名称（调试用）。 */
    func setViewName(viewId: UInt16, name: String): Unit

    /** 设置视图执行顺序（按提交的顺序数组重排）。 */
    func setViewOrder(viewId: UInt16, order: Array<UInt16>): Unit

    /** 设置视图裁剪矩形（像素）。 */
    func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit

    /** 按后缓冲比例设置视图视口矩形。 */
    func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: GfxBackbufferRatio): Unit

    /** 复位视图状态为默认。 */
    func resetView(viewId: UInt16): Unit

    /** 设置调色板颜色（RGBA float）。 */
    func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit

    /** 触发视图空提交（推进清屏/序号，不绘制）。 */
    func touchView(viewId: UInt16): Unit

    // ========================================================================
    // ===== 域 3：纹理与采样 =====
    // ========================================================================

    /** 创建 2D 纹理；data 为 None 表示空渲染目标纹理。 */
    func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16,
        format: GfxTextureFormat, flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle

    /** 创建与后缓冲成比例的 2D 纹理。 */
    func createTexture2DScaled(ratio: GfxBackbufferRatio, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat,
        flags: UInt64): GfxTextureHandle

    /** 创建 3D 纹理。 */
    func createTexture3D(w: UInt16, h: UInt16, depth: UInt16, hasMips: Bool,
        format: GfxTextureFormat, flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle

    /** 创建立方体纹理（6 面连续数据）。 */
    func createTextureCube(side: UInt16, hasMips: Bool, numLayers: UInt16,
        format: GfxTextureFormat, flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle

    /** 更新 2D 纹理子区域。 */
    func updateTexture2D(tex: GfxTextureHandle, layer: UInt16, mip: UInt8,
        x: UInt16, y: UInt16, width: UInt16, height: UInt16,
        data: PtrArray<UInt8>, pitch: UInt16): Unit

    /** 更新 3D 纹理子区域。 */
    func updateTexture3D(tex: GfxTextureHandle, mip: UInt8,
        x: UInt16, y: UInt16, z: UInt16,
        width: UInt16, height: UInt16, depth: UInt16,
        data: PtrArray<UInt8>): Unit

    /** 更新立方体纹理面子区域。 */
    func updateTextureCube(tex: GfxTextureHandle, layer: UInt16, side: UInt8, mip: UInt8,
        x: UInt16, y: UInt16, width: UInt16, height: UInt16,
        data: PtrArray<UInt8>, pitch: UInt16): Unit

    /** 销毁纹理。 */
    func destroyTexture(tex: GfxTextureHandle): Unit

    /** 纹理拷贝（整图区域）。 */
    func blitTexture(viewId: UInt16, dst: GfxTextureHandle, src: GfxTextureHandle, width: UInt16, height: UInt16): Unit

    /** 异步回读纹理到 CPU 缓冲；返回数据就绪的帧序号。 */
    func readTexture(tex: GfxTextureHandle, out: PtrArray<UInt8>, mip!: UInt8): UInt32

    /** 查询纹理参数组合是否有效（创建前预检）。 */
    func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64): Bool

    /** 计算纹理存储信息；返回 (storageSize, width, height, depth, numMips)。 */
    func calcTextureSize(width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool, numLayers: UInt16,
        format: GfxTextureFormat): (UInt32, UInt32, UInt32, UInt32, UInt32)

    /** 取帧缓冲某附着位的纹理句柄。 */
    func getTextureFromFrameBuffer(fb: GfxFrameBufferHandle, attachment: UInt8): GfxTextureHandle

    /** 设置纹理调试名称。 */
    func setTextureName(tex: GfxTextureHandle, name: String): Unit

    // ========================================================================
    // ===== 域 4：帧缓冲 =====
    // ========================================================================

    /** 由宽高与格式创建帧缓冲（含深度附着）。 */
    func createFrameBuffer(w: UInt16, h: UInt16, format: GfxTextureFormat, depthFlags: UInt64): GfxFrameBufferHandle

    /** 由既有纹理句柄列表创建帧缓冲；destroyHandles 决定销毁时是否级联销毁纹理。 */
    func createFrameBufferFromHandles(handles: Array<GfxTextureHandle>, destroyHandles: Bool): GfxFrameBufferHandle

    /** 创建与后缓冲成比例的帧缓冲。 */
    func createFrameBufferScaled(ratio: GfxBackbufferRatio, format: GfxTextureFormat, textureFlags: UInt64): GfxFrameBufferHandle

    /** 由平台窗口句柄创建帧缓冲（多窗口/离屏交换链）；depthFormat 为深度附着格式。 */
    func createFrameBufferFromNwh(nwh: VoidPtr, w: UInt16, h: UInt16, format: GfxTextureFormat,
        depthFormat: GfxTextureFormat): GfxFrameBufferHandle

    /** 销毁帧缓冲。 */
    func destroyFrameBuffer(fb: GfxFrameBufferHandle): Unit

    /** 查询附着组合是否有效。 */
    func isFrameBufferValid(attachments: Array<GfxAttachmentDesc>): Bool

    /** 设置帧缓冲调试名称。 */
    func setFrameBufferName(fb: GfxFrameBufferHandle, name: String): Unit

    // ========================================================================
    // ===== 域 5：缓冲与布局 =====
    // ========================================================================

    /** 由属性描述列表创建声明式顶点布局。 */
    func createVertexLayout(attributes: Array<GfxAttributeDesc>): GfxVertexLayoutHandle

    /** 销毁顶点布局。 */
    func destroyVertexLayout(layout: GfxVertexLayoutHandle): Unit

    /** 创建静态顶点缓冲。 */
    func createVertexBuffer(layout: GfxVertexLayoutHandle, data: PtrArray<UInt8>,
        flags: UInt16): GfxVertexBufferHandle

    /** 创建静态索引缓冲。 */
    func createIndexBuffer(data: PtrArray<UInt8>, flags: UInt16): GfxIndexBufferHandle

    /** 销毁静态顶点缓冲。 */
    func destroyVertexBuffer(vb: GfxVertexBufferHandle): Unit

    /** 销毁静态索引缓冲。 */
    func destroyIndexBuffer(ib: GfxIndexBufferHandle): Unit

    /** 创建动态顶点缓冲（容量按顶点数，数据由 update 填充）。 */
    func createDynamicVertexBuffer(num: UInt32, layout: GfxVertexLayoutHandle, flags: UInt16): GfxDynamicVertexBufferHandle

    /** 更新动态顶点缓冲（自 startVertex 起）。 */
    func updateDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle, startVertex: UInt32,
        data: PtrArray<UInt8>): Unit

    /** 销毁动态顶点缓冲。 */
    func destroyDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle): Unit

    /** 创建动态索引缓冲（容量按索引数）。 */
    func createDynamicIndexBuffer(num: UInt32, flags: UInt16): GfxDynamicIndexBufferHandle

    /** 更新动态索引缓冲（自 startIndex 起）。 */
    func updateDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle, startIndex: UInt32,
        data: PtrArray<UInt8>): Unit

    /** 销毁动态索引缓冲。 */
    func destroyDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle): Unit

    /** 创建间接绘制缓冲。 */
    func createIndirectBuffer(num: UInt32): GfxIndirectBufferHandle

    /** 销毁间接绘制缓冲。 */
    func destroyIndirectBuffer(h: GfxIndirectBufferHandle): Unit

    // ========================================================================
    // ===== 域 6：着色器 / 程序 / uniform =====
    // ========================================================================

    /** 创建着色器（后端二进制格式数据）。 */
    func createShader(data: PtrArray<UInt8>): GfxShaderHandle

    /** 销毁着色器。 */
    func destroyShader(h: GfxShaderHandle): Unit

    /** 设置着色器调试名称。 */
    func setShaderName(h: GfxShaderHandle, name: String): Unit

    /** 反射查询着色器 uniform 列表；返回 (句柄数组, 实际数量)。 */
    func getShaderUniforms(h: GfxShaderHandle, max: UInt16): (Array<GfxUniformHandle>, UInt16)

    /** 链接顶点+片段着色器为程序；destroyShaders 决定销毁时是否级联销毁着色器。 */
    func createProgram(vsh: GfxShaderHandle, fsh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle

    /** 创建计算程序。 */
    func createComputeProgram(csh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle

    /** 销毁程序。 */
    func destroyProgram(h: GfxProgramHandle): Unit

    /** 按名称与类型创建全局 uniform。 */
    func createUniform(name: String, uniformType: GfxUniformType, num!: UInt16): GfxUniformHandle

    /** 销毁 uniform。 */
    func destroyUniform(h: GfxUniformHandle): Unit

    /** 反射查询 uniform 信息（名称/类型/数量/大小）；无信息返回 None。 */
    func getUniformInfo(h: GfxUniformHandle): Option<GfxUniformDesc>

    // ========================================================================
    // ===== 域 7：主线程提交（encoder0 语义路径） =====
    // ========================================================================

    /** 设置 per-draw 渲染状态位域（每次 submit 前需重设）。 */
    func setState(state: UInt64, rgba!: UInt32): Unit

    /** 设置 per-draw 模板状态（前/后面位域）。 */
    func setStencil(fstencil: UInt32, bstencil: UInt32): Unit

    /** 设置 per-draw 裁剪矩形；返回可复用的缓存序号。 */
    func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16

    /** 复用缓存的裁剪矩形。 */
    func setScissorCached(cache: UInt16): Unit

    /** 设置 per-draw 模型变换矩阵（列主序 16 元素 Float32；num>1 为实例化批量）。 */
    func setTransform(matrix: PtrArray<Float32>, num!: UInt16): Unit

    /** 复用缓存的变换矩阵。 */
    func setTransformCached(cache: UInt32, num!: UInt16): Unit

    /** 设置 per-draw uniform 数据（Float32 数组；按 uniform 类型解释）。 */
    func setUniform(h: GfxUniformHandle, data: PtrArray<Float32>, num!: UInt16): Unit

    /** 设置 per-draw 调试标记。 */
    func setMarker(name: String): Unit

    /** 绑定纹理到采样器槽（flags 为 0 沿用纹理自身采样设置）。 */
    func setTexture(stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit

    /** 绑定图像（计算着色器读写）。 */
    func setImage(stage: UInt8, tex: GfxTextureHandle, mip: UInt8, access: GfxAccess, format: GfxTextureFormat): Unit

    /** 绑定静态顶点缓冲（无布局，布局需已绑定）。 */
    func setVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit

    /** 绑定静态顶点缓冲（带布局）。 */
    func setVertexBufferWithLayout(stage: UInt8, vb: GfxVertexBufferHandle, layout: GfxVertexLayoutHandle,
        startVertex!: UInt32, numVertices!: UInt32): Unit

    /** 绑定静态索引缓冲。 */
    func setIndexBuffer(ib: GfxIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit

    /** 绑定动态顶点缓冲。 */
    func setDynamicVertexBuffer(stage: UInt8, vb: GfxDynamicVertexBufferHandle, startVertex!: UInt32,
        numVertices!: UInt32): Unit

    /** 绑定动态索引缓冲。 */
    func setDynamicIndexBuffer(ib: GfxDynamicIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit

    /** 设置 per-draw 实例计数。 */
    func setInstanceCount(numInstances: UInt32): Unit

    /** 设置顶点计数（无顶点缓冲模式）。 */
    func setVertexCount(numVertices: UInt32): Unit

    /** 提交当前 draw 到视图（depth 供排序，0xFF 的 blend 表示用程序默认）。 */
    func submit(viewId: UInt16, program: GfxProgramHandle, depth!: UInt32, blend!: UInt8): Unit

    /** 提交间接绘制（GPU 侧生成 draw 参数）。 */
    func submitIndirect(viewId: UInt16, program: GfxProgramHandle, indirect: GfxIndirectBufferHandle, start: UInt32,
        num: UInt32, depth!: UInt32, blend!: UInt8): Unit

    /** 提交带遮挡查询的 draw。 */
    func submitOcclusionQuery(viewId: UInt16, program: GfxProgramHandle, query: GfxOcclusionQueryHandle, depth!: UInt32,
        blend!: UInt8): Unit

    /** 提交计算调度。 */
    func dispatch(viewId: UInt16, program: GfxProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags!: UInt8): Unit

    /** 丢弃当前 draw 的指定状态组（性能提示）。 */
    func discard(flags: UInt8): Unit

    /** 设置遮挡查询条件（visible 决定后续 draw 是否执行）。 */
    func setCondition(query: GfxOcclusionQueryHandle, visible: Bool): Unit

    /** 创建遮挡查询。 */
    func createOcclusionQuery(): GfxOcclusionQueryHandle

    /** 获取遮挡查询结果（out 承载可见像素数）；返回后端状态码。 */
    func getOcclusionQueryResult(h: GfxOcclusionQueryHandle, out: PtrArray<Int32>): UInt32

    /** 销毁遮挡查询。 */
    func destroyOcclusionQuery(h: GfxOcclusionQueryHandle): Unit

    // ========================================================================
    // ===== 域 8：查询 =====
    // ========================================================================

    /** 获取当前渲染后端类型。 */
    func getRendererType(): GfxRendererType

    /** 获取指定类型的渲染后端名称。 */
    func getRendererName(`type`: GfxRendererType): String

    /** 获取当前平台支持的后端类型列表。 */
    func getSupportedRenderers(): Array<GfxRendererType>

    /** 获取设备能力摘要（值拷贝）。 */
    func getCapsSummary(): GfxCapsSummary

    /** 获取帧统计摘要（值拷贝；数据在下一帧前有效）。 */
    func getStatsSummary(): GfxStatsSummary

    // ========================================================================
    // ===== 域 9：调试 =====
    // ========================================================================

    /** 清空调试文本覆盖层。 */
    func dbgTextClear(attr: UInt8, small: Bool): Unit

    /** 在调试文本覆盖层打印。 */
    func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit

    /** 在调试文本覆盖层绘制图像（8bit 每像素）。 */
    func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16,
        data: PtrArray<UInt8>, pitch: UInt16): Unit

    // ========================================================================
    // ===== encoder 受控获取口（多线程提交逃生舱的内部形态） =====
    // ========================================================================

    /** 获取一个 encoder（forThread=true 时绑定当前线程）；同一时刻一个 encoder 仅可被一个线程使用。 */
    func acquireEncoder(forThread!: Bool): IGfxEncoder

    /** 归还 encoder（结束其提交序列）。 */
    func releaseEncoder(encoder: IGfxEncoder): Unit
}
