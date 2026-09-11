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
 * @file[zh-cn] BgfxBlitQuad
 * @brief[zh-cn] 全屏四边形 vertex/index buffer + layout 资源管理
 * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.ensureBlitVB / getOrCreateBlitLayout*。用途：阴影 debug mode 6 的全屏 blit（shadowblit pass）用全屏四边形采样阴影贴图。四边形：vec3 a_position（NDC [-1,1]）+ vec2 a_texcoord0（V 翻转适配 D3D11）。
 *
 * @file[en] BgfxBlitQuad
 * @brief[en] Full-screen quad vertex/index buffer + layout resource management
 * @explain[en] Mirrors bgfx4cj-last ThreeRenderer.ensureBlitVB / getOrCreateBlitLayout*. Usage: shadow debug mode 6 full-screen blit (shadowblit pass) uses full-screen quad to sample shadow map. Quad: vec3 a_position (NDC [-1,1]) + vec2 a_texcoord0 (V flipped for D3D11).
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import std.collection.*

/**
 * @brief[zh-cn] 全屏四边形 blit 资源管理类
 * @explain[zh-cn] 持有 _blitVB / _blitIB / _blitLayout 缓存，ensureBlitVB 懒创建。BgfxBackend 在 blitShadowMap 时委托给本类。
 *
 * @brief[en] Full-screen quad blit resource manager
 * @explain[en] Holds _blitVB / _blitIB / _blitLayout caches, lazily created by ensureBlitVB. BgfxBackend delegates to this class during blitShadowMap.
 */
internal class BgfxBlitQuad {
    /**
     * @brief[zh-cn] 全屏四边形 vertex buffer 缓存（供 shadowblit pass 用）
     *
     * @brief[en] Full-screen quad vertex buffer cache (for shadowblit pass)
     */
    public var _blitVB: Option<VertexBufferHandle> = None
    /**
     * @brief[zh-cn] 全屏四边形 index buffer 缓存（6 索引构成 2 三角形）
     *
     * @brief[en] Full-screen quad index buffer cache (6 indices forming 2 triangles)
     */
    public var _blitIB: Option<IndexBufferHandle> = None
    /**
     * @brief[zh-cn] 全屏四边形 layout 缓存（vec3 a_position + vec2 a_texcoord0）
     *
     * @brief[en] Full-screen quad layout cache (vec3 a_position + vec2 a_texcoord0)
     */
    public var _blitLayout: Option<VertexLayoutHandle> = None

    /**
     * @brief[zh-cn] 全屏四边形 layout 指针缓存（供 _getOrCreateBlitLayoutPtr 复用）
     *
     * @brief[en] Full-screen quad layout pointer cache (reused by _getOrCreateBlitLayoutPtr)
     */
    private var _blitLayoutPtrCache: Option<CPointer<VertexLayout>> = None

    public init() {}

    /**
     * @brief[zh-cn] 确保全屏四边形 vertex/index buffer 已创建
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.ensureBlitVB：vec3 a_position + vec2 a_texcoord0，4 顶点 6 索引。全屏三角形覆盖：position 已是 NDC [-1,1] 坐标，uv 在 [0,1]。
     *
     * @brief[en] Ensure full-screen quad vertex/index buffer is created
     * @explain[en] Mirrors bgfx4cj-last ThreeRenderer.ensureBlitVB: vec3 a_position + vec2 a_texcoord0, 4 vertices 6 indices. Full-screen triangle cover: position in NDC [-1,1], uv in [0,1].
     */
    public func ensureBlitVB(): Unit {
        match (this._blitVB) {
            case Some(_) => return
            case None => ()
        }
        let vertsF64: Array<Float64> = [
            -1.0, -1.0, 0.0,  0.0, 1.0,   // 左下（V=1）
             1.0, -1.0, 0.0,  1.0, 1.0,   // 右下（V=1）
             1.0,  1.0, 0.0,  1.0, 0.0,   // 右上（V=0）
            -1.0,  1.0, 0.0,  0.0, 0.0    // 左上（V=0）
        ]
        let mem = BgfxMemory(UInt32(vertsF64.size * 4))
        mem.writeFloats(vertsF64, Int64(vertsF64.size))
        this._blitLayout = Some(this.getOrCreateBlitLayoutHandle())
        this._blitVB = Some(bgfx_create_vertex_buffer_cj(mem.get(), this.getOrCreateBlitLayoutPtr(), 0u16))

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
        this._blitIB = Some(bgfx_create_index_buffer_cj(idxBgfxMem.get(), 0u16))
        idxPtrHolder.dispose()
        Logger.debug(["blit", "created blitVB + blitIB"])
    }

    /**
     * @brief[zh-cn] 获取/创建全屏四边形顶点布局指针（vec3 a_position + vec2 a_texcoord0）
     * @explain[zh-cn] 对照 _getOrCreateLayoutPtr 但 layout 不同（阴影 blit 用 5 floats stride，主渲染用 12 floats）。仅类内部使用。
     * @return[zh-cn] 顶点布局指针
     *
     * @brief[en] Get or create full-screen quad vertex layout pointer (vec3 a_position + vec2 a_texcoord0)
     * @explain[en] Mirrors _getOrCreateLayoutPtr but with different layout (shadow blit uses 5 floats stride, main render uses 12 floats). Internal use only.
     * @return[en] Vertex layout pointer
     */
    private func getOrCreateBlitLayoutPtr(): CPointer<VertexLayout> {
        match (this._blitLayoutPtrCache) {
            case Some(p) => return p
            case None => ()
        }
        let layoutPtrHolder = AutoFreePtr<VertexLayout>(unsafe { LibC.malloc<VertexLayout>() })
        let layoutPtr = layoutPtrHolder.get()
        unsafe { layoutPtr.write(VertexLayout()) }
        bgfx_vertex_layout_begin_cj(layoutPtr, 0u32)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Position.value(), 3u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.TexCoord0.value(), 2u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_end_cj(layoutPtr)
        this._blitLayoutPtrCache = Some(layoutPtr)
        return layoutPtr
    }

    /**
     * @brief[zh-cn] 获取/创建全屏四边形顶点布局句柄
     * @return[zh-cn] 顶点布局句柄
     *
     * @brief[en] Get or create full-screen quad vertex layout handle
     * @return[en] Vertex layout handle
     */
    public func getOrCreateBlitLayoutHandle(): VertexLayoutHandle {
        match (this._blitLayout) {
            case Some(lh) => return lh
            case None => ()
        }
        let lh = bgfx_create_vertex_layout_cj(this.getOrCreateBlitLayoutPtr())
        this._blitLayout = Some(lh)
        return lh
    }

    /**
     * @brief[zh-cn] 销毁全屏四边形资源（供 BgfxBackend.dispose 调用）
     *
     * @brief[en] Dispose full-screen quad resources (called by BgfxBackend.dispose)
     */
    public func dispose(): Unit {
        match (this._blitVB) {
            case Some(vb) =>
                bgfx_destroy_vertex_buffer_cj(vb)
                this._blitVB = None
            case None => ()
        }
        match (this._blitIB) {
            case Some(ib) =>
                bgfx_destroy_index_buffer_cj(ib)
                this._blitIB = None
            case None => ()
        }
        match (this._blitLayout) {
            case Some(lh) =>
                bgfx_destroy_vertex_layout_cj(lh)
                this._blitLayout = None
            case None => ()
        }
    }
}
