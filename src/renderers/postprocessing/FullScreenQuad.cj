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
 * @file[zh-cn] BgfxFullScreenQuad 全屏四边形共享资源
 * @brief[zh-cn] 全屏四边形共享资源（VB/IB/layout + submit）
 * @explain[zh-cn] 提供：
 *         1. 4 顶点（position xyz + texcoord0 uv）+ 6 索引（两个三角形）
 *         2. 全屏 NDC：x∈[-1,1], y∈[-1,1]，z=0，w=1
 *         3. UV 与 NDC 同向（bgfx/V 与纹理 V 同向，quad 顶点布局对齐 UnrealBloomPass 范式）
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
 *            follows the UnrealBloomPass convention)
 *         4. submitFullScreenQuad(viewId, prog): binds VB/IB/layout + WRITE_RGB|WRITE_A|FRONT_CCW + submit
 *         renderers differences:
 *         - Backends use BufferGeometry + ShaderMaterial + renderer.render;
 *           bgfx uses view-level submit: bgfx_set_vertex_buffer + bgfx_set_index_buffer + bgfx_submit.
 *         - The quad uses NDC xy + uv; gl_Position = vec4(a_position.xy, 0.0, 1.0) (hardcoded in the shader,
 *           no projection/uniform needed), so the VB only stores position + texcoord0.
 *
 * @package three.renderers.postprocessing
 */
package three.renderers.postprocessing

import three.utils.safe.IReleasable
import three.utils.memory.PtrArray
import three.renderers.ThreeRenderer
import three.renderers._gfx.*
import std.collection.*

/**
 * @brief[zh-cn] 全屏四边形共享资源
 * @explain[zh-cn] 持 VB/IB/layout，懒创建，多 pass 共享单例。
 *
 * @brief[en] Full-screen quad shared resources
 * @explain[en] Holds VB/IB/layout, lazily created, shared as a singleton across passes.
 */
public class FullScreenQuad <: IReleasable {
    /**
     * 全屏四边形顶点缓冲（4 顶点 × 5 floats = 20 floats）。
     */
    private var _quadVB: Option<GfxVertexBufferHandle> = None

    /**
     * 全屏四边形索引缓冲（6 索引）。
     */
    private var _quadIB: Option<GfxIndexBufferHandle> = None

    /**
     * 顶点 layout 句柄（后端编译后句柄）。
     */
    private var _quadLayout: Option<GfxVertexLayoutHandle> = None

    /**
     * 渲染器引用（submit/dispose 经其高阶 API 序列化；Pass.submitQuad 调用本类
     * submit/submitWithState 时无 renderer 参数，故由 Pass.render 经 setRenderer 缓存）。
     */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * @brief[zh-cn] GC 回收兜底释放回调（终结器专用）
     * @explain[zh-cn] 仓颉终结器内不能调用实例方法，故把释放动作包成函数值字段，
     *                 由终结器读取并执行（终结器调用函数值是允许的，见 utils.memory 先例）。
     *                 dispose() 已幂等（句柄置 None），用户主动调用后终结器再执行也安全。
     *                 setRenderer 注入渲染器时登记（此后 dispose 才有实际意义）。
     *
     * @brief[en] GC-collection fallback release callback (for finalizers only)
     * @explain[en] Instance methods cannot be called inside a Cangjie finalizer, so the release
     *               action is wrapped as a function-valued field executed by the finalizer
     *               (calling a function value from a finalizer is allowed, cf. utils.memory).
     *               dispose() is idempotent (handles set to None), so re-execution after an
     *               explicit call is safe. Registered when setRenderer injects the renderer
     *               (dispose is meaningful only from then on).
     */
    private var _finalizerFallback: Option<() -> Unit> = None

    public init() {}

    /**
     * @brief[zh-cn] 注入渲染器
     * @param[zh-cn] renderer 渲染器
     * @explain[zh-cn] 由各 Pass.render 在渲染共享 quad 前调用；EffectComposer 持单例无 renderer 参数。
     *
     * @brief[en] Injects the renderer
     * @param[en] renderer Renderer
     * @explain[en] Called by each Pass.render before renderers the shared quad; EffectComposer holds the singleton without a renderer parameter.
     */
    public func setRenderer(renderer: ThreeRenderer): Unit {
        this._renderer = Some(renderer)
        // 终结器兜底：GC 回收时自动执行 dispose()（经函数值字段间接调用）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /**
     * @brief[zh-cn] 确保全屏四边形缓存资源已创建（懒创建）
     * @param[zh-cn] renderer 渲染器（bgfx 资源创建经其高阶 API 序列化到渲染线程）
     *
     * @brief[en] Ensures the full-screen quad cached resources are created (lazily)
     * @param[en] renderer Renderer (bgfx resource creation is serialized to the render thread via its high-level API)
     */
    public func ensureResources(renderer: ThreeRenderer): Unit {
        if (let Some(_) <- this._quadVB) { return }
        // 4 顶点：position(xyz) + texcoord0(uv) = 5 floats × 4 = 20 floats
        // 全屏四边形 NDC 坐标，V 与纹理 V 同向（bgfx 纹理 v=0 顶 + quad 顶点布布自洽）
        let vertsF64: Array<Float64> = [
            -1.0, -1.0, 0.0,  0.0, 1.0,
             1.0, -1.0, 0.0,  1.0, 1.0,
             1.0,  1.0, 0.0,  1.0, 0.0,
            -1.0,  1.0, 0.0,  0.0, 0.0
        ]
        let mem = PtrArray<UInt8>(Int64(vertsF64.size * 4))
        _writeFloatsToBytes(mem, vertsF64, Int64(vertsF64.size))

        // layout：position(3) + texcoord0(2)，经后端声明式布局接口创建句柄
        let layout = renderer.backend.createVertexLayout(this._getQuadLayoutAttrs())
        this._quadLayout = Some(layout)

        this._quadVB = Some(renderer.backend.createVertexBuffer(layout, mem, 0u16))

        // 6 索引：两个三角形 (0,1,2) 和 (0,2,3)
        let indices: Array<UInt16> = [0u16, 1u16, 2u16, 0u16, 2u16, 3u16]
        let idxBuf = PtrArray<UInt8>(Int64(indices.size * 2))
        _writeUInt16Bytes(idxBuf, indices, Int64(indices.size))
        this._quadIB = Some(renderer.backend.createIndexBuffer(idxBuf, 0u16))
    }

    /**
     * 构建全屏 quad 顶点布局属性描述（position(3) + texcoord0(2)）。
     * layout 句柄经后端声明式布局接口创建，createVertexBuffer 用该句柄创建（后端内部查回布局内存）。
     */
    private func _getQuadLayoutAttrs(): Array<GfxAttributeDesc> {
        let list = ArrayList<GfxAttributeDesc>()
        list.add(GfxAttributeDesc(GfxAttrib.Position, 3u8, GfxAttribType.Float, normalized: false, asInt: false))
        list.add(GfxAttributeDesc(GfxAttrib.TexCoord0, 2u8, GfxAttribType.Float, normalized: false, asInt: false))
        return list.toArray()
    }

    /**
     * @brief[zh-cn] 提交全屏四边形（用缓存的 VB/IB/layout）
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译的 program handle
     *
     * @brief[en] Submits the full-screen quad (using the cached VB/IB/layout)
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     */
    public func submit(viewId: UInt16, prog: GfxProgramHandle): Unit {
        this.submitWithState(viewId, prog, GfxState.WRITE_RGB | GfxState.WRITE_A | GfxState.FRONT_CCW)
    }

    /**
     * @brief[zh-cn] 提交全屏四边形，使用自定义 render state（如加性混合）
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译的 program handle
     * @param[zh-cn] state 完整 render state（bgfx_set_state_cj 第 1 参）
     * @explain[zh-cn] 关键：SSAA/TAA 累加需要 BLEND_ADD 混合状态，但 submit(viewId, prog)
     *         内部会强制覆盖 state 为 WRITE_RGB|WRITE_A|FRONT_CCW（覆盖写），
     *         导致累加变成覆盖写 → 每样本仅 1/N 亮度 → 画面极暗近黑。
     *         故提供本方法，由 caller 传入完整 state（含混合）。
     *
     * @brief[en] Submits the full-screen quad with a custom render state (e.g. additive blending)
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     * @param[en] state The full render state (first argument of bgfx_set_state_cj)
     * @explain[en] Key point: SSAA/TAA accumulation needs the BLEND_ADD blend state, but submit(viewId, prog)
     *         internally forces the state to WRITE_RGB|WRITE_A|FRONT_CCW (overwrite), which turns accumulation
     *         into overwrite writes → each sample only gets 1/N brightness → the image becomes very dark/near black.
     *         This method is provided so the caller can pass the full state (including blending).
     */
    public func submitWithState(viewId: UInt16, prog: GfxProgramHandle, state: UInt64): Unit {
        if (let Some(renderer) <- this._renderer) {
            this.ensureResources(renderer)
            if (let Some(vb) <- this._quadVB && let Some(ib) <- this._quadIB && let Some(layout) <- this._quadLayout) {
                renderer.backend.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                renderer.backend.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                renderer.backend.setState(state, rgba: 0x00000000u32)
                renderer.backend.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
            }
        }
    }

    /**
     * @brief[zh-cn] 释放全屏四边形占用的 GPU 资源
     *
     * @brief[en] releases the GPU resources held by the full-screen quad
     */
    public func release(): Bool {
        if (let Some(renderer) <- this._renderer) {
            if (let Some(vb) <- this._quadVB) {
                renderer.backend.destroyVertexBuffer(vb)
                this._quadVB = None
            }
            if (let Some(ib) <- this._quadIB) {
                renderer.backend.destroyIndexBuffer(ib)
                this._quadIB = None
            }
            if (let Some(layout) <- this._quadLayout) {
                renderer.backend.destroyVertexLayout(layout)
                this._quadLayout = None
            }
        }
        return true
    }
}
