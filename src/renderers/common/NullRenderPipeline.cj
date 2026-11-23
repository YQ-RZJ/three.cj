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
 * @file[zh-cn] NullRenderPipeline 空渲染后端
 * @brief[zh-cn] IRenderPipeline 的全空实现（无 GPU 设备的占位后端）
 * @explain[zh-cn] 供渲染器默认构造与未接线子系统使用的占位后端：全部方法为
 * no-op（创建类返回 INVALID 句柄、查询类返回 false/空值），不触碰任何 GPU
 * API。真实渲染须注入具体后端实现（如 BgfxBackend）。仅为引擎内部可见。
 *
 * @file[en] NullRenderPipeline the null render backend
 * @brief[en] The all-no-op implementation of IRenderPipeline (a placeholder backend without a GPU device)
 * @explain[en] A placeholder backend for the renderer's default construction and
 * unwired subsystems: every method is a no-op (creations return INVALID handles,
 * queries return false/empty) and no GPU API is ever touched. Real renderers must
 * inject a concrete backend implementation (e.g. BgfxBackend). Engine-internal only.
 *
 * @package three.renderers.common
 */
package three.renderers.common

import three.renderers._gfx.*
import three.renderers._interfaces.IGfxEncoder
import three.renderers._interfaces.*
import three.scene.scenegraph.Scene
import three.utils.memory.PtrArray
import three.utils.memory.VoidPtr

internal class NullRenderPipeline <: IRenderPipeline {
    private static let invalidMsg = "NullRenderPipeline: no GPU backend bound"

    // ===== 编排（全部 no-op） =====

    public func beginRender(renderContext: IRenderContext): Unit {
    }

    public func beginRender(renderContext: RenderContext): Unit {
    }

    public func draw(renderObject: IRenderObject): Unit {
    }

    public func finishRender(renderContext: IRenderContext): Unit {
    }

    public func finishRender(renderContext: RenderContext): Unit {
    }

    public func finishRenderPass(renderContext: RenderContext): Unit {
    }

    public func prepareShadowMap(scene: Scene): Unit {
    }

    public func bindShadowUniforms(): Unit {
    }

    public func blitShadowMap(mainViewId: UInt16): Unit {
    }

    // ===== 生命周期与设备 =====

    public func initialize(hwnd: UIntNative, width: Int32, height: Int32, vsync!: Bool, msaa!: UInt32,
        maxAnisotropy!: UInt32, numBackBuffers!: UInt8, maxFrameLatency!: UInt8): Bool {
        false
    }

    public func shutdown(): Unit {
    }

    public func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit {
    }

    public func setDebug(debug: UInt32): Unit {
    }

    public func renderFrame(msecs: Int32): UInt32 {
        0u32
    }

    public func requestScreenShot(fb: GfxFrameBufferHandle, filePath: String): Unit {
    }

    public func present(capture!: Bool): Unit {
    }

    // ===== 视图治理 =====

    public func setViewFrameBuffer(viewId: UInt16, fb: GfxFrameBufferHandle): Unit {
    }

    public func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit {
    }

    public func setViewClear(viewId: UInt16, flags: UInt16, rgba: UInt32, depth!: Float32, stencil!: UInt8): Unit {
    }

    public func setViewClearMrt(viewId: UInt16, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8,
        c2: UInt8, c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit {
    }

    public func setViewTransform(viewId: UInt16, view: PtrArray<Float32>, proj: PtrArray<Float32>): Unit {
    }

    public func setViewMode(viewId: UInt16, mode: GfxViewMode): Unit {
    }

    public func setViewName(viewId: UInt16, name: String): Unit {
    }

    public func setViewOrder(viewId: UInt16, order: Array<UInt16>): Unit {
    }

    public func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit {
    }

    public func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: GfxBackbufferRatio): Unit {
    }

    public func resetView(viewId: UInt16): Unit {
    }

    public func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit {
    }

    public func touchView(viewId: UInt16): Unit {
    }

    // ===== 纹理与采样 =====

    public func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat,
        flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle {
        GfxTextureHandle.INVALID
    }

    public func createTexture2DScaled(ratio: GfxBackbufferRatio, hasMips: Bool, numLayers: UInt16,
        format: GfxTextureFormat, flags: UInt64): GfxTextureHandle {
        GfxTextureHandle.INVALID
    }

    public func createTexture3D(w: UInt16, h: UInt16, depth: UInt16, hasMips: Bool, format: GfxTextureFormat,
        flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle {
        GfxTextureHandle.INVALID
    }

    public func createTextureCube(side: UInt16, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat,
        flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle {
        GfxTextureHandle.INVALID
    }

    public func updateTexture2D(tex: GfxTextureHandle, layer: UInt16, mip: UInt8, x: UInt16, y: UInt16, width: UInt16,
        height: UInt16, data: PtrArray<UInt8>, pitch: UInt16): Unit {
    }

    public func updateTexture3D(tex: GfxTextureHandle, mip: UInt8, x: UInt16, y: UInt16, z: UInt16, width: UInt16,
        height: UInt16, depth: UInt16, data: PtrArray<UInt8>): Unit {
    }

    public func updateTextureCube(tex: GfxTextureHandle, layer: UInt16, side: UInt8, mip: UInt8, x: UInt16, y: UInt16,
        width: UInt16, height: UInt16, data: PtrArray<UInt8>, pitch: UInt16): Unit {
    }

    public func destroyTexture(tex: GfxTextureHandle): Unit {
    }

    public func blitTexture(viewId: UInt16, dst: GfxTextureHandle, src: GfxTextureHandle, width: UInt16, height: UInt16): Unit {
    }

    public func readTexture(tex: GfxTextureHandle, out: PtrArray<UInt8>, mip!: UInt8): UInt32 {
        0u32
    }

    public func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64): Bool {
        false
    }

    public func calcTextureSize(width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool,
        numLayers: UInt16, format: GfxTextureFormat): (UInt32, UInt32, UInt32, UInt32, UInt32) {
        (0u32, 0u32, 0u32, 0u32, 0u32)
    }

    public func getTextureFromFrameBuffer(fb: GfxFrameBufferHandle, attachment: UInt8): GfxTextureHandle {
        GfxTextureHandle.INVALID
    }

    public func setTextureName(tex: GfxTextureHandle, name: String): Unit {
    }

    // ===== 帧缓冲 =====

    public func createFrameBuffer(w: UInt16, h: UInt16, format: GfxTextureFormat, depthFlags: UInt64): GfxFrameBufferHandle {
        GfxFrameBufferHandle.INVALID
    }

    public func createFrameBufferFromHandles(handles: Array<GfxTextureHandle>, destroyHandles: Bool): GfxFrameBufferHandle {
        GfxFrameBufferHandle.INVALID
    }

    public func createFrameBufferScaled(ratio: GfxBackbufferRatio, format: GfxTextureFormat, textureFlags: UInt64): GfxFrameBufferHandle {
        GfxFrameBufferHandle.INVALID
    }

    public func createFrameBufferFromNwh(nwh: VoidPtr, w: UInt16, h: UInt16, format: GfxTextureFormat,
        depthFormat: GfxTextureFormat): GfxFrameBufferHandle {
        GfxFrameBufferHandle.INVALID
    }

    public func destroyFrameBuffer(fb: GfxFrameBufferHandle): Unit {
    }

    public func isFrameBufferValid(attachments: Array<GfxAttachmentDesc>): Bool {
        false
    }

    public func setFrameBufferName(fb: GfxFrameBufferHandle, name: String): Unit {
    }

    // ===== 缓冲与布局 =====

    public func createVertexLayout(attributes: Array<GfxAttributeDesc>): GfxVertexLayoutHandle {
        GfxVertexLayoutHandle.INVALID
    }

    public func destroyVertexLayout(layout: GfxVertexLayoutHandle): Unit {
    }

    public func createVertexBuffer(layout: GfxVertexLayoutHandle, data: PtrArray<UInt8>, flags: UInt16): GfxVertexBufferHandle {
        GfxVertexBufferHandle.INVALID
    }

    public func createIndexBuffer(data: PtrArray<UInt8>, flags: UInt16): GfxIndexBufferHandle {
        GfxIndexBufferHandle.INVALID
    }

    public func destroyVertexBuffer(vb: GfxVertexBufferHandle): Unit {
    }

    public func destroyIndexBuffer(ib: GfxIndexBufferHandle): Unit {
    }

    public func createDynamicVertexBuffer(num: UInt32, layout: GfxVertexLayoutHandle, flags: UInt16): GfxDynamicVertexBufferHandle {
        GfxDynamicVertexBufferHandle.INVALID
    }

    public func updateDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle, startVertex: UInt32, data: PtrArray<UInt8>): Unit {
    }

    public func destroyDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle): Unit {
    }

    public func createDynamicIndexBuffer(num: UInt32, flags: UInt16): GfxDynamicIndexBufferHandle {
        GfxDynamicIndexBufferHandle.INVALID
    }

    public func updateDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle, startIndex: UInt32, data: PtrArray<UInt8>): Unit {
    }

    public func destroyDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle): Unit {
    }

    public func createIndirectBuffer(num: UInt32): GfxIndirectBufferHandle {
        GfxIndirectBufferHandle.INVALID
    }

    public func destroyIndirectBuffer(h: GfxIndirectBufferHandle): Unit {
    }

    // ===== 着色器 / 程序 / uniform =====

    public func createShader(data: PtrArray<UInt8>): GfxShaderHandle {
        GfxShaderHandle.INVALID
    }

    public func destroyShader(h: GfxShaderHandle): Unit {
    }

    public func setShaderName(h: GfxShaderHandle, name: String): Unit {
    }

    public func getShaderUniforms(h: GfxShaderHandle, max: UInt16): (Array<GfxUniformHandle>, UInt16) {
        (Array<GfxUniformHandle>(), 0u16)
    }

    public func createProgram(vsh: GfxShaderHandle, fsh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle {
        GfxProgramHandle.INVALID
    }

    public func createComputeProgram(csh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle {
        GfxProgramHandle.INVALID
    }

    public func destroyProgram(h: GfxProgramHandle): Unit {
    }

    public func createUniform(name: String, uniformType: GfxUniformType, num!: UInt16): GfxUniformHandle {
        GfxUniformHandle.INVALID
    }

    public func destroyUniform(h: GfxUniformHandle): Unit {
    }

    public func getUniformInfo(h: GfxUniformHandle): Option<GfxUniformDesc> {
        None
    }

    // ===== 主线程提交 =====

    public func setState(state: UInt64, rgba!: UInt32): Unit {
    }

    public func setStencil(fstencil: UInt32, bstencil: UInt32): Unit {
    }

    public func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16 {
        0u16
    }

    public func setScissorCached(cache: UInt16): Unit {
    }

    public func setTransform(matrix: PtrArray<Float32>, num!: UInt16): Unit {
    }

    public func setTransformCached(cache: UInt32, num!: UInt16): Unit {
    }

    public func setUniform(h: GfxUniformHandle, data: PtrArray<Float32>, num!: UInt16): Unit {
    }

    public func setMarker(name: String): Unit {
    }

    public func setTexture(stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit {
    }

    public func setImage(stage: UInt8, tex: GfxTextureHandle, mip: UInt8, access: GfxAccess, format: GfxTextureFormat): Unit {
    }

    public func setVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit {
    }

    public func setVertexBufferWithLayout(stage: UInt8, vb: GfxVertexBufferHandle, layout: GfxVertexLayoutHandle,
        startVertex!: UInt32, numVertices!: UInt32): Unit {
    }

    public func setIndexBuffer(ib: GfxIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit {
    }

    public func setDynamicVertexBuffer(stage: UInt8, vb: GfxDynamicVertexBufferHandle, startVertex!: UInt32,
        numVertices!: UInt32): Unit {
    }

    public func setDynamicIndexBuffer(ib: GfxDynamicIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit {
    }

    public func setInstanceCount(numInstances: UInt32): Unit {
    }

    public func setVertexCount(numVertices: UInt32): Unit {
    }

    public func submit(viewId: UInt16, program: GfxProgramHandle, depth!: UInt32, blend!: UInt8): Unit {
    }

    public func submitIndirect(viewId: UInt16, program: GfxProgramHandle, indirect: GfxIndirectBufferHandle,
        start: UInt32, num: UInt32, depth!: UInt32, blend!: UInt8): Unit {
    }

    public func submitOcclusionQuery(viewId: UInt16, program: GfxProgramHandle, query: GfxOcclusionQueryHandle,
        depth!: UInt32, blend!: UInt8): Unit {
    }

    public func dispatch(viewId: UInt16, program: GfxProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32,
        flags!: UInt8): Unit {
    }

    public func discard(flags: UInt8): Unit {
    }

    public func setCondition(query: GfxOcclusionQueryHandle, visible: Bool): Unit {
    }

    public func createOcclusionQuery(): GfxOcclusionQueryHandle {
        GfxOcclusionQueryHandle.INVALID
    }

    public func getOcclusionQueryResult(h: GfxOcclusionQueryHandle, out: PtrArray<Int32>): UInt32 {
        0u32
    }

    public func destroyOcclusionQuery(h: GfxOcclusionQueryHandle): Unit {
    }

    // ===== 查询 =====

    public func getRendererType(): GfxRendererType {
        GfxRendererType.Noop
    }

    public func getRendererName(`type`: GfxRendererType): String {
        invalidMsg
    }

    public func getSupportedRenderers(): Array<GfxRendererType> {
        Array<GfxRendererType>()
    }

    public func getCapsSummary(): GfxCapsSummary {
        GfxCapsSummary(GfxRendererType.Noop)
    }

    public func getStatsSummary(): GfxStatsSummary {
        GfxStatsSummary()
    }

    // ===== 调试 =====

    public func dbgTextClear(attr: UInt8, small: Bool): Unit {
    }

    public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit {
    }

    public func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16, data: PtrArray<UInt8>, pitch: UInt16): Unit {
    }

    // ===== encoder 受控获取口 =====

    public func acquireEncoder(forThread!: Bool): IGfxEncoder {
        throw Exception(invalidMsg)
    }

    public func releaseEncoder(encoder: IGfxEncoder): Unit {
    }

    // ===== IReleasable =====

    public prop releasable: Bool {
        get() {
            false
        }
    }

    public func release(): Bool {
        false
    }
}
