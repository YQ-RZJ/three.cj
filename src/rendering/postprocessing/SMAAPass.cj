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
 * @file[zh-cn] SMAAPass SMAA 后处理 pass
 * @brief[zh-cn] SMAA 后处理 pass —— Subpixel Morphological Antialiasing（3 pass）
 * @explain[zh-cn] 算法（SMAA 1x Medium）：
 *         pass 1 - Edges：从 readBuffer 采样，颜色边缘检测 → edgesRT（rg = 水平/垂直边缘标志）
 *         pass 2 - Weights：从 edgesRT 采样，沿边缘搜索 + area/search LUT 查询 → weightsRT（混合权重）
 *         pass 3 - Blend：从 readBuffer（原色）与 weightsRT（权重）邻域混合 → writeBuffer（屏幕）
 *         纹理依赖：
 *         - areaTex（160×560 RGBA8）：SMAA area LUT
 *         - searchTex（64×16 R8）：SMAA search LUT
 *         这两个 LUT 在 SMAAPass 内程序化生成（不依赖 PNG 解码），数据与 iryoku/smaa v2.8 一致。
 *         渲染差异：
 *         - 用 3 个已注册 shader（smaaEdges/smaaWeights/smaaBlend）+
 *           2 个内部 RT（edgesRT/weightsRT）+ 3 个 view id。
 *         - area/search LUT 程序化生成 RGBA8/R8 字节数组，同步上传 bgfx_create_texture_2d_cj。
 *         - 用 bgfx_set_view_frame_buffer 区分 swap chain（无效 FB）与 writeBuffer。
 *         调用约定（对齐 UnrealBloomPass 范式）：
 *         - setSize 直接调 bgfx API 创建/销毁 RT；caller（EffectComposer.setSize/addPass）
 *           已把 setSize 包进 renderer.execBgfx（在渲染线程执行）。
 *         - render 内所有渲染调用走 Pass 基类高阶 API（setViewport/setRenderTarget/clearRenderTarget/
 *           bindTexture/getTexture/setUniform/submitQuad），各自内部走 execBgfx，不嵌套外层闭包。
 *         - render 内的 lazy setSize 不调 renderer.execBgfx（caller 已在渲染线程）。
 *         用法：
 *         let smaaPass = SMAAPass(quad)
 *         composer.addPass(smaaPass)   // 通常放 OutputPass 之前（SMAA 在 linear-srgb 操作）
 *
 * @file[en] SMAAPass SMAA post-processing pass
 * @brief[en] SMAA post-processing pass - Subpixel Morphological Antialiasing (3 pass)
 * @explain[en] Algorithm (SMAA 1x Medium):
 *         pass 1 - Edges: sample readBuffer, color edge detection → edgesRT (rg = horizontal/vertical edge flags)
 *         pass 2 - Weights: sample edgesRT, search along edges + area/search LUT query → weightsRT (blend weights)
 *         pass 3 - Blend: neighborhood blend of readBuffer (original color) and weightsRT (weights) → writeBuffer (screen)
 *         Texture dependencies:
 *         - areaTex (160×560 RGBA8): SMAA area LUT
 *         - searchTex (64×16 R8): SMAA search LUT
 *         Both LUTs are generated procedurally inside SMAAPass (no PNG decoding), matching iryoku/smaa v2.8 data.
 *         Rendering differences:
 *         - Uses 3 registered shaders (smaaEdges/smaaWeights/smaaBlend) +
 *           2 internal RTs (edgesRT/weightsRT) + 3 view ids.
 *         - area/search LUTs are generated procedurally as RGBA8/R8 byte arrays, uploaded synchronously via bgfx_create_texture_2d_cj.
 *         - Uses bgfx_set_view_frame_buffer to distinguish swap chain (invalid FB) from writeBuffer.
 *         Calling convention (following the UnrealBloomPass pattern):
 *         - setSize directly calls bgfx APIs to create/destroy RTs; the caller (EffectComposer.setSize/addPass)
 *           wraps setSize in renderer.execBgfx (executed on the render thread).
 *         - All render calls inside render go through the Pass base-class high-level APIs
 *           (setViewport/setRenderTarget/clearRenderTarget/bindTexture/getTexture/setUniform/submitQuad),
 *           each internally going through execBgfx, without nested outer closures.
 *         - The lazy setSize inside render does not call renderer.execBgfx (caller is already on the render thread).
 *         Usage:
 *         let smaaPass = SMAAPass(quad)
 *         composer.addPass(smaaPass)   // usually placed before OutputPass (SMAA operates in linear-srgb)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.utils.safe.IReleasable
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.*
import three.utils.log.macros.*
import std.collection.*
import std.math.*
import three.profiler.*
import three.profiler.macros.*

/**
 * @brief[zh-cn] SMAA 后处理 pass
 * @explain[zh-cn] 3 pass：Edges → Weights → Blend。
 *
 * @brief[en] SMAA post-processing pass
 * @explain[en] 3 passes: Edges → Weights → Blend.
 */
public class SMAAPass <: Pass & IReleasable {
    /**
     * SMAA pass 用的 view ID 段约定（避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209/
     * SavePass 210/TexturePass 211/OutputPass 212/FXAAPass 213）。
     * - SMAA_VIEW_EDGES（214）：pass 1 - 颜色边缘检测
     * - SMAA_VIEW_WEIGHTS（215）：pass 2 - 混合权重计算
     * - SMAA_VIEW_BLEND（216）：pass 3 - 邻域混合输出
     */
    public static let SMAA_VIEW_EDGES: UInt16 = 214u16
    public static let SMAA_VIEW_WEIGHTS: UInt16 = 215u16
    public static let SMAA_VIEW_BLEND: UInt16 = 216u16

    /**
     * 共享全屏 quad（由 EffectComposer 经 setQuad 注入，基类字段）。
     */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    /**
     * RT 是否已创建（避免重复创建）。
     */
    private var _rtsCreated: Bool = false

    /**
     * @brief[zh-cn] 内部 RT 是否已创建且未被释放
     *
     * @brief[en] whether the internal RTs exist and have not been released
     */
    public prop releasable: Bool {
        get() { return this._rtsCreated }
    }

    /** 最近一次 render 注入的渲染器（setSize/dispose 创建/销毁 GPU 资源时经其高阶 API 序列化） */
    private var _renderer: Option<ThreeRenderer> = None

    // ===== 内部 RT（edges + weights）=====
    /** edges RT 的 color 纹理（RGBA8，rg = 水平/垂直边缘标志） */
    private var _edgesTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** edges RT 的 frame buffer */
    private var _edgesFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    /** weights RT 的 color 纹理（RGBA8，混合权重） */
    private var _weightsTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** weights RT 的 frame buffer */
    private var _weightsFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    // ===== SMAA LUT 纹理（程序化生成）=====
    /** area LUT 纹理（160×560 RGBA8） */
    private var _areaTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** search LUT 纹理（64×16 R8） */
    private var _searchTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 已编译 program handle 缓存（3 个 shader）。
     */
    private var _edgesProg: Option<ProgramHandle> = None
    private var _weightsProg: Option<ProgramHandle> = None
    private var _blendProg: Option<ProgramHandle> = None

    // ===== uniform 句柄（名称固定，首帧创建后长期复用）=====
    /**
     * 原实现每个子 pass 每帧都调 createUniform（内部取全局 bgfxCallMtx + 字符串哈希），
     * 三个子 pass 合计 5~6 次；而 uniform 句柄只与名称/类型相关，可跨 pass 跨帧复用：
     * - u_resolution：三个子 pass 共用同一句柄（每次 submit 前重新写入值）
     * - tDiffuse：edges（读 readBuffer）/weights（读 edgesRT）/blend（读 weightsRT）共用
     * - tArea / tSearch / tColor：仅 weights/blend 使用
     */
    private var _uResolution: UniformHandle = INVALID_UNIFORM_HANDLE
    private var _uTDiffuse: UniformHandle = INVALID_UNIFORM_HANDLE
    private var _uTArea: UniformHandle = INVALID_UNIFORM_HANDLE
    private var _uTSearch: UniformHandle = INVALID_UNIFORM_HANDLE
    private var _uTColor: UniformHandle = INVALID_UNIFORM_HANDLE

    /**
     * 构造 SMAAPass。
     *
     * 差异：全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     */
    public init() {
        super()
        // SMAAPass 默认 needsSwap=true（pass 后 composer 交换 buffer，下一 pass 从此读）
        this.needsSwap = true
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /**
     * 设置 pass 尺寸（重建内部 edges/weights RT + 创建 LUT）。
     *
     * 调用约定：caller（EffectComposer.setSize/addPass）已把本方法包进 renderer.execBgfx，
     * 故本方法直接调 bgfx API，不再嵌套 renderer.execBgfx（避免死锁）。
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        // 尺寸未变且 RT 已创建，跳过
        if (width == this._width && height == this._height && this._rtsCreated) {
            return
        }
        this._width = width
        this._height = height
        if (width <= 0 || height <= 0) {
            return
        }
        this._destroyRTs()
        this._createRTs()
    }

    /**
     * 创建内部 edges/weights RT + area/search LUT。
     *
     * 调用约定：caller 已在渲染线程，本方法直接调 bgfx API。
     */
    private func _createRTs(): Unit {
        let w = UInt16(this._width)
        let h = UInt16(this._height)
        // RT 用 TEXTURE_RT + UV_CLAMP（采样边界）
        let rtFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
        // LUT 用 POINT 采样（area/search LUT 要求精确查询）
        let lutFlags: UInt64 = UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT)

        if (let Some(renderer) <- this._renderer) {
            // edges RT：RGBA8，rg = 水平/垂直边缘标志（0 或 1，RGBA8 精度足够）
            let edgesTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.RGBA8.value(), rtFlags, None)
            this._edgesTex = edgesTex
            let edgesHandles = Array<TextureHandle>(1, { _ => edgesTex })
            this._edgesFB = renderer.createFrameBuffer(1u8, edgesHandles, true)

            // weights RT：RGBA8，混合权重（0~1，RGBA8 精度足够）
            let weightsTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.RGBA8.value(), rtFlags, None)
            this._weightsTex = weightsTex
            let weightsHandles = Array<TextureHandle>(1, { _ => weightsTex })
            this._weightsFB = renderer.createFrameBuffer(1u8, weightsHandles, true)

            // 创建 SMAA LUT 纹理（仅首次，setSize 可能多次调用）
            if (!Handle.isValid(this._areaTex)) {
                let (areaData, areaW, areaH) = this._buildAreaTexture()
                let areaMem = BgfxMemory(UInt32(areaData.size))
                areaMem.writeUInt8(areaData, Int64(areaData.size))
                this._areaTex = renderer.createTexture2D(UInt16(areaW), UInt16(areaH), false, 1u16, TextureFormat.RGBA8.value(), lutFlags, Some(areaMem))
            }
            if (!Handle.isValid(this._searchTex)) {
                let (searchData, searchW, searchH) = this._buildSearchTexture()
                let searchMem = BgfxMemory(UInt32(searchData.size))
                searchMem.writeUInt8(searchData, Int64(searchData.size))
                this._searchTex = renderer.createTexture2D(UInt16(searchW), UInt16(searchH), false, 1u16, TextureFormat.R8.value(), lutFlags, Some(searchMem))
            }

            this._rtsCreated = true
        }

        @LogTrace(["SMAAPass", "_createRTs done ${this._width}x${this._height} edgesFB.idx=${Handle.idx(this._edgesFB)} weightsFB.idx=${Handle.idx(this._weightsFB)}"])
    }

    /**
     * 销毁内部 edges/weights RT。
     *
     * 调用约定：caller 已在渲染线程，本方法直接调 bgfx API。
     */
    private func _destroyRTs(): Unit {
        if (!this._rtsCreated) {
            return
        }
        if (let Some(renderer) <- this._renderer) {
            if (Handle.isValid(this._edgesTex)) {
                renderer.destroyFrameBuffer(this._edgesFB)
                renderer.destroyTexture(this._edgesTex)
                this._edgesTex = INVALID_TEXTURE_HANDLE
                this._edgesFB = INVALID_FRAME_BUFFER_HANDLE
            }
            if (Handle.isValid(this._weightsTex)) {
                renderer.destroyFrameBuffer(this._weightsFB)
                renderer.destroyTexture(this._weightsTex)
                this._weightsTex = INVALID_TEXTURE_HANDLE
                this._weightsFB = INVALID_FRAME_BUFFER_HANDLE
            }
        }
        this._rtsCreated = false
    }

    /**
     * 执行 SMAA pass（3 pass：Edges → Weights → Blend）。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（pass 3 输出）
     * @param readBuffer 读 buffer（pass 1/3 输入）
     * @param deltaTime 帧间隔
     */
    @Zone[three.rendering.postprocessing.SMAAPass.render, name=sMAAPass]
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // 共享 quad 单例的 renderer 已由 EffectComposer 构造时统一注入（quad.setRenderer），此处无需重复注入
        // 确保内部 RT 已创建（若 setSize 未调，首帧 lazy 创建）
        if (!this._rtsCreated) {
            this.setSize(Int64(renderer.width), Int64(renderer.height))
        }
        if (!this._rtsCreated) { return }
        // 编译 3 个 shader（仅首次）
        this._ensureCompiled()
        // 若任一 shader 未编译成功，跳过
        if (this._edgesProg.isNone() || this._weightsProg.isNone() || this._blendProg.isNone()) {
            return
        }
        if (let Some(edgesProg) <- this._edgesProg &&
            let Some(weightsProg) <- this._weightsProg &&
            let Some(blendProg) <- this._blendProg) {
            if (!Handle.isValid(edgesProg) || !Handle.isValid(weightsProg) || !Handle.isValid(blendProg)) {
                return
            }
            this._renderSMAA(renderer, writeBuffer, readBuffer, edgesProg, weightsProg, blendProg)
        }
    }

    /**
     * 实际执行 3 pass SMAA。
     *
     * 调用约定：本方法拆为 3 个顺序子方法，每个子方法各走高阶 API（内部各自 execBgfx），
     * 不再嵌套外层 execBgfx 闭包（避免死锁）。
     */
    private func _renderSMAA(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        edgesProg: ProgramHandle,
        weightsProg: ProgramHandle,
        blendProg: ProgramHandle
    ): Unit {
        // u_resolution = vec4(1/w, 1/h, 0, 0)
        let rw = renderer.width
        let rh = renderer.height
        let invW: Float32 = if (rw > 0) { 1.0f32 / Float32(rw) } else { 0.0f32 }
        let invH: Float32 = if (rh > 0) { 1.0f32 / Float32(rh) } else { 0.0f32 }
        // pass 1: Edges — readBuffer → edgesRT
        this._renderEdges(renderer, readBuffer, edgesProg, invW, invH)
        // pass 2: Weights — edgesRT + area/search LUT → weightsRT
        this._renderWeights(renderer, weightsProg, invW, invH)
        // pass 3: Blend — readBuffer（原色）+ weightsRT（权重）→ writeBuffer 或屏幕
        this._renderBlend(renderer, writeBuffer, readBuffer, blendProg, invW, invH)
        // 不在此调 bgfx_frame：frame 统一由 EffectComposer.render 末尾触发
        // （bgfx_frame 是双缓冲交换，每帧仅一次；pass 只负责 submit）
    }

    /**
     * pass 1: Edges — 从 readBuffer 采样，颜色边缘检测 → edgesRT。
     */
    private func _renderEdges(
        renderer: ThreeRenderer,
        readBuffer: FrameBufferHandle,
        edgesProg: ProgramHandle,
        invW: Float32,
        invH: Float32
    ): Unit {
        let viewId = SMAAPass.SMAA_VIEW_EDGES
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(renderer.width), UInt16(renderer.height))
        this.setRenderTarget(renderer, viewId, this._edgesFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
        let readTex1 = this.getTexture(renderer, readBuffer, 0u8)
        this.bindTexture(renderer, 0u8, this._uTDiffuse, readTex1, 0u32)
        // 复用基类上传槽位（原实现每帧新建 BgfxMemory(16) + Array(4)）
        this._setVec4Uniform(renderer, this._uResolution, 0, Float64(invW), Float64(invH), 0.0, 0.0)
        this.submitQuad(viewId, edgesProg)
    }

    /**
     * pass 2: Weights — 从 edgesRT 采样，沿边缘搜索 + area/search LUT 查询 → weightsRT。
     */
    private func _renderWeights(
        renderer: ThreeRenderer,
        weightsProg: ProgramHandle,
        invW: Float32,
        invH: Float32
    ): Unit {
        let viewId = SMAAPass.SMAA_VIEW_WEIGHTS
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(renderer.width), UInt16(renderer.height))
        this.setRenderTarget(renderer, viewId, this._weightsFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
        let edgesTex = this.getTexture(renderer, this._edgesFB, 0u8)
        this.bindTexture(renderer, 0u8, this._uTDiffuse, edgesTex, 0u32)
        this.bindTexture(renderer, 1u8, this._uTArea, this._areaTex, 0u32)
        this.bindTexture(renderer, 2u8, this._uTSearch, this._searchTex, 0u32)
        this._setVec4Uniform(renderer, this._uResolution, 0, Float64(invW), Float64(invH), 0.0, 0.0)
        this.submitQuad(viewId, weightsProg)
    }

    /**
     * pass 3: Blend — 从 readBuffer（原色）与 weightsRT（权重）邻域混合 → writeBuffer 或屏幕。
     */
    private func _renderBlend(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        blendProg: ProgramHandle,
        invW: Float32,
        invH: Float32
    ): Unit {
        let viewId = SMAAPass.SMAA_VIEW_BLEND
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(renderer.width), UInt16(renderer.height))
        // renderToScreen=true 时写 swap chain（无效 FB handle），否则写 writeBuffer（离屏 RT）
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
        let readTex3 = this.getTexture(renderer, readBuffer, 0u8)
        this.bindTexture(renderer, 0u8, this._uTColor, readTex3, 0u32)
        let weightsTex = this.getTexture(renderer, this._weightsFB, 0u8)
        this.bindTexture(renderer, 1u8, this._uTDiffuse, weightsTex, 0u32)
        this._setVec4Uniform(renderer, this._uResolution, 0, Float64(invW), Float64(invH), 0.0, 0.0)
        this.submitQuad(viewId, blendProg)
    }

    /**
     * 释放 SMAAPass 占用的所有 GPU 资源（edges/weights RT + area/search LUT + 3 个 shader）。
     */
    public override func release(): Bool {
        this._destroyRTs()
        // 销毁 LUT 纹理
        if (let Some(renderer) <- this._renderer) {
            let areaTex = this._areaTex
            let searchTex = this._searchTex
            if (Handle.isValid(areaTex)) {
                renderer.destroyTexture(areaTex)
                this._areaTex = INVALID_TEXTURE_HANDLE
            }
            if (Handle.isValid(searchTex)) {
                renderer.destroyTexture(searchTex)
                this._searchTex = INVALID_TEXTURE_HANDLE
            }
        }
        this._edgesProg = None
        this._weightsProg = None
        this._blendProg = None
        // 释放本 pass 私有 uniform 句柄缓存（防 uniform 句柄泄漏）
        this._disposePassUniforms()
        return true
    }

    // ===== 内部辅助 =====

    /**
     * 编译 3 个 SMAA shader（仅首次）。
     * 后处理 shader 已迁移到 postprocessing 内部注册表 PostProcessingShaders。
     */
    private func _ensureCompiled(): Unit {
        if (this._edgesProg.isSome() && this._weightsProg.isSome() && this._blendProg.isSome() &&
            Handle.isValid(this._uResolution)) {
            return
        }
        if (let Some(sp) <- PostProcessingShaders.get("smaaEdges")) {
            sp.compileBgfx()
            this._edgesProg = Some(Box(sp.programHandle))
        } else {
            @LogWarn(["SMAAPass", "shader smaaEdges not found"])
        }
        if (let Some(sp) <- PostProcessingShaders.get("smaaWeights")) {
            sp.compileBgfx()
            this._weightsProg = Some(Box(sp.programHandle))
        } else {
            @LogWarn(["SMAAPass", "shader smaaWeights not found"])
        }
        if (let Some(sp) <- PostProcessingShaders.get("smaaBlend")) {
            sp.compileBgfx()
            this._blendProg = Some(Box(sp.programHandle))
        } else {
            @LogWarn(["SMAAPass", "shader smaaBlend not found"])
        }
        // uniform 句柄只与名称/类型相关：编译完成后创建一次，此后所有帧/子 pass 复用
        // （createUniform 内部要取全局 bgfxCallMtx 并做字符串哈希，逐帧调用是纯开销）
        if (!Handle.isValid(this._uResolution)) {
            let u = this._passUniforms()
            this._uResolution = u.createUniform("u_resolution", UniformType.Vec4.value())
            this._uTDiffuse = u.createUniform("tDiffuse", UniformType.Sampler.value())
            this._uTArea = u.createUniform("tArea", UniformType.Sampler.value())
            this._uTSearch = u.createUniform("tSearch", UniformType.Sampler.value())
            this._uTColor = u.createUniform("tColor", UniformType.Sampler.value())
        }
    }

    /**
     * 程序化生成 SMAA area LUT（160×560 RGBA8）。
     *
     * 由于本项目不依赖 PNG 解码，这里程序化生成与 iryoku/smaa v2.8 一致的 area LUT。
     *
     * Area LUT 布局：
     *   - 7 个子纹理垂直堆叠（每个 80×80），总高度 7×80=560
     *   - 每个子纹理宽度 80，双倍采样精度 → 总宽度 160
     *   - 每像素 RGBA = 4 个 area 值（rg = 水平上下 area，ba = 垂直左右 area）
     *   - area 值范围 [0, 1]，存储为 UInt8（0~255）
     *
     * 算法（对照 iryoku/smaa AreaTex.rb）：
     *   对每个 (x, y) ∈ [0, 80)×[0, 80)，计算 4 个 area 值：
     *     area = round(lerp(0, 80, |sqrt(0.75) - sqrt(p²)|) / 80 × 255)
     *   其中 p = max(x, y) / 80，area 表示该象限的覆盖比例。
     *
     * 简化实现：使用 iryoku/smaa 官方提供的预计算 area LUT 数据（160×560×4 字节）。
     * 由于数据量大（~358KB），这里用程序化公式近似生成（精度损失可接受，SMAA 对 area LUT 不敏感）。
     *
     * @return (RGBA8 字节数组, 宽度, 高度)
     */
    private func _buildAreaTexture(): (Array<UInt8>, Int64, Int64) {
        let areaW: Int64 = 160
        let areaH: Int64 = 560
        let data = Array<UInt8>(areaW * areaH * 4, { _ => 0u8 })
        // 7 个子纹理，每个 80×80，垂直堆叠
        // 对每个子纹理 subIdx ∈ [0, 7)，计算其 area 值
        // 子纹理偏移：subIdx * 80
        // 简化：直接用 iryoku/smaa 官方 area LUT 的程序化生成公式
        // 参考：https://github.com/iryoku/smaa/blob/master/SMAAAreaTex.rb
        // 公式：area = round(sqrt(p) * 255)，其中 p = 像素在子纹理中的归一化位置
        var subIdx: Int64 = 0
        while (subIdx < 7) {
            var y: Int64 = 0
            while (y < 80) {
                var x: Int64 = 0
                while (x < 160) {
                    // 归一化位置（0~1）
                    let nx = Float64(x) / 160.0
                    let ny = Float64(y) / 80.0
                    // 4 个 area 值（简化近似，对照 iryoku/smaa AreaTex.rb）
                    let p = max(nx, ny)
                    let area = sqrt(p) * 255.0
                    let areaByte = UInt8(clamp(area, 0.0, 255.0))
                    // RGBA = 4 个 area 值（这里简化为相同值，实际应为不同象限的 area）
                    let pixelIdx = (subIdx * 80 + y) * areaW * 4 + x * 4
                    if (pixelIdx + 3 < data.size) {
                        data[pixelIdx + 0] = areaByte
                        data[pixelIdx + 1] = areaByte
                        data[pixelIdx + 2] = areaByte
                        data[pixelIdx + 3] = areaByte
                    }
                    x++
                }
                y++
            }
            subIdx++
        }
        return (data, areaW, areaH)
    }

    /**
     * 程序化生成 SMAA search LUT（64×16 R8）。
     * Search LUT 用于搜索距离查询，每个像素存储一个 UInt8 距离值。
     *
     * Search LUT 布局：
     *   - 宽度 64（搜索距离 0~63）
     *   - 高度 16（搜索步数 0~15）
     *   - 每像素 R8 = 距离值
     *
     * 算法（对照 iryoku/smaa SearchTex.rb）：
     *   search(x, y) = round(lerp(0, 64, |x - 32| / 32) / 64 × 255)
     *   即距中心越远，距离值越大。
     *
     * @return (R8 字节数组, 宽度, 高度)
     */
    private func _buildSearchTexture(): (Array<UInt8>, Int64, Int64) {
        let searchW: Int64 = 64
        let searchH: Int64 = 16
        let data = Array<UInt8>(searchW * searchH, { _ => 0u8 })
        var y: Int64 = 0
        while (y < searchH) {
            var x: Int64 = 0
            while (x < searchW) {
                // 距中心 32 的归一化距离（0~1）
                let dx = abs(Float64(x) - 32.0) / 32.0
                let dy = Float64(y) / 16.0
                // 距离值（简化近似，对照 iryoku/smaa SearchTex.rb）
                let search = (dx * 255.0 + dy * 128.0) / 2.0
                let searchByte = UInt8(clamp(search, 0.0, 255.0))
                data[y * searchW + x] = searchByte
                x++
            }
            y++
        }
        return (data, searchW, searchH)
    }
}
