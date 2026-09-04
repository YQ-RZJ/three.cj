/**
 * @file[zh-cn] BgfxFullScreenQuad 全屏四边形共享资源
 * @brief[zh-cn] 全屏四边形共享资源（VB/IB/layout + submit）
 * @explain[zh-cn] 提供：
 *         1. 4 顶点（position xyz + texcoord0 uv）+ 6 索引（两个三角形）
 *         2. 全屏 NDC：x∈[-1,1], y∈[-1,1]，z=0，w=1
 *         3. UV 与 NDC 同向（bgfx/V 与纹理 V 同向，quad 顶点布局对齐 BgfxUnrealBloomPass 范式）
 *         4. submitFullScreenQuad(viewId, prog)：绑 VB/IB/layout + WRITE_RGB|WRITE_A|FRONT_CCW + submit
 *         渲染差异：
 *         - 现代后端用 BufferGeometry + ShaderMaterial + renderer.render；
 *           bgfx 用 view 级 submit：bgfx_set_vertex_buffer + bgfx_set_index_buffer + bgfx_submit。
 *         - quad 用 NDC xy + uv，gl_Position = vec4(a_position.xy, 0.0, 1.0)（已在 shader 硬编码，
 *           无需 projection/uniform），故 VB 只存 position + texcoord0。
 *
 * @file[en] BgfxFullScreenQuad full-screen quad shared resource
 * @brief[en] Full-screen quad shared resource (VB/IB/layout + submit)
 * @explain[en] Provides:
 *         1. 4 vertices (position xyz + texcoord0 uv) + 6 indices (two triangles)
 *         2. Full-screen NDC: x∈[-1,1], y∈[-1,1], z=0, w=1
 *         3. UV and NDC have the same orientation (bgfx/V and texture V are aligned; the quad vertex layout
 *            follows the BgfxUnrealBloomPass convention)
 *         4. submitFullScreenQuad(viewId, prog): binds VB/IB/layout + WRITE_RGB|WRITE_A|FRONT_CCW + submit
 *         Rendering differences:
 *         - Backends use BufferGeometry + ShaderMaterial + renderer.render;
 *           bgfx uses view-level submit: bgfx_set_vertex_buffer + bgfx_set_index_buffer + bgfx_submit.
 *         - The quad uses NDC xy + uv; gl_Position = vec4(a_position.xy, 0.0, 1.0) (hardcoded in the shader,
 *           no projection/uniform needed), so the VB only stores position + texcoord0.
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.rendering.bgfx.BgfxConstants
import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.types.*
import std.collection.*

/**
 * @brief[zh-cn] 全屏四边形共享资源
 * @brief[en] Full-screen quad shared resources
 * @explain[zh-cn] 持 VB/IB/layout，懒创建，多 pass 共享单例。
 * @explain[en] Holds VB/IB/layout, lazily created, shared as a singleton across passes.
 */
public class FullScreenQuad {
    /**
     * 全屏四边形顶点缓冲（4 顶点 × 5 floats = 20 floats）。
     */
    private var _quadVB: Option<VertexBufferHandle> = None

    /**
     * 全屏四边形索引缓冲（6 索引）。
     */
    private var _quadIB: Option<IndexBufferHandle> = None

    /**
     * 顶点 layout handle（bgfx 编译后句柄）。
     */
    private var _quadLayout: Option<VertexLayoutHandle> = None

    /**
     * 渲染器引用（submit/dispose 经其高阶 API 序列化；Pass.submitQuad 调用本类
     * submit/submitWithState 时无 renderer 参数，故由 Pass.render 经 setRenderer 缓存）。
     */
    private var _renderer: Option<BgfxRenderer> = None

    public init() {}

    /**
     * @brief[zh-cn] 注入渲染器
     * @brief[en] Injects the renderer
     * @param[zh-cn] renderer 渲染器
     * @param[en] renderer Renderer
     * @explain[zh-cn] 由各 Pass.render 在渲染共享 quad 前调用；EffectComposer 持单例无 renderer 参数。
     * @explain[en] Called by each Pass.render before rendering the shared quad; EffectComposer holds the singleton without a renderer parameter.
     */
    public func setRenderer(renderer: BgfxRenderer): Unit {
        this._renderer = Some(renderer)
    }

    /**
     * @brief[zh-cn] 确保全屏四边形缓存资源已创建（懒创建）
     * @brief[en] Ensures the full-screen quad cached resources are created (lazily)
     * @param[zh-cn] renderer 渲染器（bgfx 资源创建经其高阶 API 序列化到渲染线程）
     * @param[en] renderer Renderer (bgfx resource creation is serialized to the render thread via its high-level API)
     */
    public func ensureResources(renderer: BgfxRenderer): Unit {
        match (this._quadVB) {
            case Some(_) => return
            case None => ()
        }
        // 4 顶点：position(xyz) + texcoord0(uv) = 5 floats × 4 = 20 floats
        // 全屏四边形 NDC 坐标，V 与纹理 V 同向（bgfx 纹理 v=0 顶 + quad 顶点布布自洽）
        let vertsF64: Array<Float64> = [
            -1.0, -1.0, 0.0,  0.0, 1.0,
             1.0, -1.0, 0.0,  1.0, 1.0,
             1.0,  1.0, 0.0,  1.0, 0.0,
            -1.0,  1.0, 0.0,  0.0, 0.0
        ]
        let mem = BgfxMemory(UInt32(vertsF64.size * 4))
        mem.writeFloats(vertsF64, Int64(vertsF64.size))

        // layout：position(3) + texcoord0(2)，经 renderer.createVertexLayout 高阶 API 创建句柄
        let layout = renderer.createVertexLayout(this._getQuadLayoutAttrs())
        this._quadLayout = Some(layout)

        this._quadVB = Some(renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16))

        // 6 索引：两个三角形 (0,1,2) 和 (0,2,3)
        let indices: Array<UInt16> = [0u16, 1u16, 2u16, 0u16, 2u16, 3u16]
        let idxBytes = ArrayList<UInt8>()
        for (i in 0..indices.size) {
            idxBytes.add(UInt8(indices[i] & 0xFFu16))
            idxBytes.add(UInt8((indices[i] >> 8) & 0xFFu16))
        }
        let idxPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(idxBytes.size + 1)) })
        let idxPtr = idxPtrHolder.get()
        unsafe {
            for (i in 0..idxBytes.size) { (idxPtr + Int64(i)).write(idxBytes[i]) }
            (idxPtr + Int64(idxBytes.size)).write(0u8)
        }
        let idxBgfxMem = BgfxMemory(CPointer<Unit>(idxPtr), UInt32(idxBytes.size))
        this._quadIB = Some(renderer.createIndexBuffer(idxBgfxMem, flags: 0u16))
        idxPtrHolder.dispose()
    }

    /**
     * 构建全屏 quad 顶点布局属性描述（对齐 begin/add/end 序列：position(3) + texcoord0(2)）。
     * 对照 GTAOPass._getLayoutAttrs 范式：layout handle 经 renderer.createVertexLayout 创建，
     * createVertexBuffer 经 renderer.createVertexBufferFromLayout 用 handle 创建（renderer 内部查回 layout 指针）。
     */
    private func _getQuadLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
        let uv = BgfxAttributeDesc()
        uv.attrib = Attrib.TexCoord0.value()
        uv.num = 2u8
        uv.attribType = AttribType.Float.value()
        uv.normalized = false
        uv.asInt = false
        list.add(uv)
        return list.toArray()
    }

    /**
     * @brief[zh-cn] 提交全屏四边形（用缓存的 VB/IB/layout）
     * @brief[en] Submits the full-screen quad (using the cached VB/IB/layout)
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译的 program handle
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     */
    public func submit(viewId: UInt16, prog: ProgramHandle): Unit {
        this.submitWithState(viewId, prog, BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW)
    }

    /**
     * @brief[zh-cn] 提交全屏四边形，使用自定义 render state（如加性混合）
     * @brief[en] Submits the full-screen quad with a custom render state (e.g. additive blending)
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译的 program handle
     * @param[zh-cn] state 完整 render state（bgfx_set_state_cj 第 1 参）
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     * @param[en] state The full render state (first argument of bgfx_set_state_cj)
     * @explain[zh-cn] 关键：SSAA/TAA 累加需要 BLEND_ADD 混合状态，但 submit(viewId, prog)
     *         内部会强制覆盖 state 为 WRITE_RGB|WRITE_A|FRONT_CCW（覆盖写），
     *         导致累加变成覆盖写 → 每样本仅 1/N 亮度 → 画面极暗近黑。
     *         故提供本方法，由 caller 传入完整 state（含混合）。
     * @explain[en] Key point: SSAA/TAA accumulation needs the BLEND_ADD blend state, but submit(viewId, prog)
     *         internally forces the state to WRITE_RGB|WRITE_A|FRONT_CCW (overwrite), which turns accumulation
     *         into overwrite writes → each sample only gets 1/N brightness → the image becomes very dark/near black.
     *         This method is provided so the caller can pass the full state (including blending).
     */
    public func submitWithState(viewId: UInt16, prog: ProgramHandle, state: UInt64): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                this.ensureResources(renderer)
                match (this._quadVB) {
                    case Some(vb) =>
                        match (this._quadIB) {
                            case Some(ib) =>
                                match (this._quadLayout) {
                                    case Some(layout) =>
                                        renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                                        renderer.setState(state, rgba: 0x00000000u32)
                                        renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                                    case None => ()
                                }
                            case None => ()
                        }
                    case None => ()
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 释放全屏四边形占用的 GPU 资源
     * @brief[en] Releases the GPU resources held by the full-screen quad
     */
    public func dispose(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                match (this._quadVB) {
                    case Some(vb) =>
                        renderer.destroyVertexBuffer(vb)
                        this._quadVB = None
                    case None => ()
                }
                match (this._quadIB) {
                    case Some(ib) =>
                        renderer.destroyIndexBuffer(ib)
                        this._quadIB = None
                    case None => ()
                }
                match (this._quadLayout) {
                    case Some(layout) =>
                        renderer.destroyVertexLayout(layout)
                        this._quadLayout = None
                    case None => ()
                }
            case None => ()
        }
    }
}
