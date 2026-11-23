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
 * @file[zh-cn] SAOPass 尺度敏感环境光遮蔽（SAO）后处理 pass
 * @brief[zh-cn] 尺度敏感环境光遮蔽（SAO）后处理 pass
 * @explain[zh-cn] 以 EffectComposer Pass 链方式注入（对齐 bloom/ssao/gtao 的 Bgfx*Pass）：
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(SAOPass(scene, camera))
 *         composer.render()
 *         render() 内部（每帧经 renderer.execBgfx 序列化到渲染线程）：
 *         1. 法线 pass（view SAO_VIEW_ID_BASE+0）：normal shader 渲场景法线到法线 RT（RGBA16F+D24）
 *         2. 深度 pass（view +1）：aodepth shader 渲场景 NDC 深度到深度 RT（RGBA32F+D24）
 *         3. SAO 计算 pass（view +2）：全屏四边形采样法线/深度，输出 1-occlusion 到 sao RT（RGBA16F）
 *         4. vBlur pass（view +3）：深度受限高斯模糊（方向 0,1）→ blur RT（RGBA16F）
 *         5. hBlur pass（view +4）：深度受限高斯模糊（方向 1,0）→ 写回 sao RT
 *         6. 输出 pass（view +5）：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）
 *            Default：sceneColor × ao（saoapply）；SAO/Normal：copy 透传对应纹理
 *         自包含：uniforms（uniform 注册表实例）、全屏四边形（composer 共享 quad）、
 *         场景几何体 VB/IB/layout 均在 pass 内懒创建并缓存，不依赖 BgfxBackend 内部资源
 *         （避免 bgfx_backend ↔ postprocessing 包循环依赖，对齐 SSAOPass/GTAOPass 自包含模式）。
 *         实现要点：
 *         - 噪声：bgfx 无内建 rand → SAO_FS 内联实现 rand()
 *         - blur：DepthLimitedBlurShader 的 sampleUvOffsets/sampleWeights 数组 → uniform vec4 数组
 *           u_sampleOffsets[9]/u_sampleWeights[9]，CPU 端按 configure 生成
 *           （gaussian 权重 + 方向偏移），KERNEL_RADIUS 固定 8（默认 saoBlurRadius=8）
 *         - 输出：materialCopy + CustomBlending(乘法) 两步 → saoapply shader 一步 sceneColor × ao
 *
 * @file[en] SAOPass scale-aware ambient occlusion (SAO) post-processing pass
 * @brief[en] Scale-aware ambient occlusion (SAO) post-processing pass
 * @explain[en] Injected via the EffectComposer Pass chain (aligned with the Bgfx*Pass bloom/ssao/gtao style):
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(SAOPass(scene, camera))
 *         composer.render()
 *         Inside render() (each frame serialized to the render thread via renderer.execBgfx):
 *         1. Normal pass (view SAO_VIEW_ID_BASE+0): normal shader renders scene normals to a normal RT (RGBA16F+D24)
 *         2. Depth pass (view +1): aodepth shader renders scene NDC depth to a depth RT (RGBA32F+D24)
 *         3. SAO compute pass (view +2): full-screen quad samples normals/depth, outputs 1-occlusion to the sao RT (RGBA16F)
 *         4. vBlur pass (view +3): depth-limited gaussian blur (direction 0,1) → blur RT (RGBA16F)
 *         5. hBlur pass (view +4): depth-limited gaussian blur (direction 1,0) → writes back to the sao RT
 *         6. Output pass (view +5): outputs to writeBuffer per output mode (writes to screen when renderToScreen=true)
 *            Default: sceneColor × ao (saoapply); SAO/Normal: copy pass-through of the corresponding texture
 *         Self-contained: uniforms (uniform registry instance), full-screen quad (composer shared quad),
 *         and scene geometry VB/IB/layout are lazily created and cached inside the pass, not depending on BgfxBackend internals
 *         (avoiding a bgfx_backend ↔ postprocessing package cycle, aligned with the SSAOPass/GTAOPass self-contained pattern).
 *         Porting notes:
 *         - Noise: the original SAO inlines rand(), bgfx has no rand → inlined in SAO_FS
 *         - blur: DepthLimitedBlurShader sampleUvOffsets/sampleWeights arrays → uniform vec4 arrays
 *           u_sampleOffsets[9]/u_sampleWeights[9], generated on CPU per configure
 *           (gaussian weights + direction offsets), KERNEL_RADIUS fixed at 8 (default saoBlurRadius=8)
 *         - Output: materialCopy + CustomBlending(multiply) two steps → saoapply shader one step sceneColor × ao
 */
package three.renderers.postprocessing

import three.renderers._gfx.*
import three.utils.safe.IReleasable
import three.renderers.common.*
import three.renderers._interfaces.IUniformRegistry
import three.renderers.buffer.*
import three.renderers.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.renderers.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.renderers.cameras.*
import three.scene.entity.Mesh
import three.utils.memory.PtrArray
import three.utils.log.*
import three.utils.log.macros.*
import three.renderers.ThreeRenderer
import std.collection.*
import std.math.*
import three.profiler.*
import three.profiler.macros.*

public class SAOPass <: Pass & IReleasable {
    /** SAO pass 用的 view ID 段约定：SSAO 160~164，GTAO 165~169，SAO 170~175，composer 分配 230+ */
    public static let SAO_VIEW_ID_BASE: UInt16 = 170u16

    /** 输出模式 */
    public static let OUTPUT_DEFAULT: Int64 = 0
    public static let OUTPUT_SAO: Int64 = 1
    public static let OUTPUT_NORMAL: Int64 = 2

    /** 场景/相机（法线/深度 pass 渲场景用） */
    private var _scene: Option<Scene> = None
    private var _camera: Option<Camera> = None

    // ===== RT 句柄（懒创建，setSize 或首帧时初始化） =====
    /** 法线 RT（RGBA16F，法线编码 0.5+0.5 视图空间） */
    private var _normalFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _normalTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 法线 RT 的 depth attachment（D24，法线 pass 深度测试用） */
    private var _normalDepthTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 深度 RT（RGBA32F，存 NDC 深度 gl_FragCoord.z，SAO shader 用 perspectiveDepthToViewZ 反算 viewZ） */
    private var _depthFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _depthTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 深度 RT 的 depth attachment（D24，深度 pass 深度测试用） */
    private var _depthDepthTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** SAO 遮蔽 RT（RGBA16F，存 1-occlusion） */
    private var _saoFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _saoTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** blur 中间 RT（RGBA16F，vBlur 中间结果） */
    private var _blurFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _blurTex: GfxTextureHandle = GfxTextureHandle.INVALID

    /** RT 尺寸 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    // ===== SAO 参数 =====
    /** 输出模式（默认 Default=0，AO 乘到场景色） */
    public var output: Int64 = 0
    /** 遮蔽偏置（默认 0.5） */
    public var saoBias: Float64 = 0.5
    /** 遮蔽强度（默认 0.18） */
    public var saoIntensity: Float64 = 0.18
    /** 遮蔽尺度（默认 1） */
    public var saoScale: Float64 = 1.0
    /** 采样核半径（视图空间距离，默认 100） */
    public var saoKernelRadius: Float64 = 100.0
    /** 最小分辨率（默认 0） */
    public var saoMinResolution: Float64 = 0.0
    /** 是否启用深度受限模糊（默认 true） */
    public var saoBlur: Bool = true
    /** 模糊半径（默认 8） */
    public var saoBlurRadius: Int64 = 8
    /** 模糊标准差（默认 4） */
    public var saoBlurStdDev: Float64 = 4.0
    /** 模糊深度截止（视图空间深度差阈值，默认 0.01） */
    public var saoBlurDepthCutoff: Float64 = 0.01

    /** 本 pass 自有的 uniform 注册表（对齐 SSAOPass/GTAOPass 自包含模式） */
    private var _uniforms: IUniformRegistry = ThreeRenderer.makeUniformRegistry()

    /** blur 偏移上传暂存（36 floats = 9×vec4），避免每帧每方向新建数组 */
    private let _blurOffsetsScratch: Array<Float64> = Array<Float64>(36, { _ => 0.0 })

    // ===== 场景几何体缓存（对齐 BgfxBackend._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, GfxVertexBufferHandle> = HashMap<Int64, GfxVertexBufferHandle>()
    private var _ibCache: HashMap<Int64, GfxIndexBufferHandle> = HashMap<Int64, GfxIndexBufferHandle>()
    private var _layoutHandleCache: Option<GfxVertexLayoutHandle> = None

    /** 渲染器引用（render() 时缓存，dispose/_destroyRTs 经其高阶 API 销毁资源） */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * 构造：`new SAOPass(scene, camera, resolution)`。
     * 默认输出 Default（0）；needsSwap=true（composer 链约定，写 writeBuffer 后交换）。
     */
    public init(scene: Scene, camera: Camera) {
        super()
        this._scene = Some(scene)
        this._camera = Some(camera)
        this.needsSwap = true
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /** 设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用） */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height) {
            this._destroyRTs()
            this._width = width
            this._height = height
            @LogTrace(["sao", "setSize=${width}x${height}"])
        }
    }

    // ===== RT 创建/销毁 =====

    private func _ensureRTs(renderer: ThreeRenderer): Unit {
        if (this._width <= 0 || this._height <= 0) { return }
        if (this._normalTex.isValid) { return }

        // 法线 RT：RGBA16F + D24 depth attachment
        let normalTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.RGBA16F,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._normalTex = normalTex
        let normalDepthTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.D24S8,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._normalDepthTex = normalDepthTex
        this._normalFB = this._createFBWithDepth(renderer, normalTex, normalDepthTex)

        // 深度 RT：RGBA32F（存 NDC 深度 gl_FragCoord.z）
        let depthTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.RGBA32F,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._depthTex = depthTex
        let depthDepthTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.D24S8,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._depthDepthTex = depthDepthTex
        this._depthFB = this._createFBWithDepth(renderer, depthTex, depthDepthTex)

        // SAO 遮蔽 RT：RGBA16F
        let saoTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.RGBA16F,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._saoTex = saoTex
        this._saoFB = this._createFB(renderer, saoTex)

        // blur 中间 RT：RGBA16F
        let blurTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.RGBA16F,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._blurTex = blurTex
        this._blurFB = this._createFB(renderer, blurTex)

        @LogTrace(["sao", "_ensureRTs done ${this._width}x${this._height}"])
    }

    private func _createFB(renderer: ThreeRenderer, tex: GfxTextureHandle): GfxFrameBufferHandle {
        let handles = Array<GfxTextureHandle>(1, { _ => tex })
        let fb = renderer.backend.createFrameBufferFromHandles(handles, true)
        return fb
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: ThreeRenderer, colorTex: GfxTextureHandle, depthTex: GfxTextureHandle): GfxFrameBufferHandle {
        let handles = Array<GfxTextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.backend.createFrameBufferFromHandles(handles, true)
        return fb
    }

    private func _destroyRTs(): Unit {
        if (let Some(renderer) <- this._renderer) {
            let normalFB = this._normalFB; let depthFB = this._depthFB
            let saoFB = this._saoFB; let blurFB = this._blurFB
            let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
            let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
            let saoTex = this._saoTex; let blurTex = this._blurTex
            if (normalFB.isValid) { renderer.backend.destroyFrameBuffer(normalFB) }
            if (depthFB.isValid) { renderer.backend.destroyFrameBuffer(depthFB) }
            if (saoFB.isValid) { renderer.backend.destroyFrameBuffer(saoFB) }
            if (blurFB.isValid) { renderer.backend.destroyFrameBuffer(blurFB) }
            if (normalTex.isValid) { renderer.backend.destroyTexture(normalTex) }
            if (normalDepthTex.isValid) { renderer.backend.destroyTexture(normalDepthTex) }
            if (depthTex.isValid) { renderer.backend.destroyTexture(depthTex) }
            if (depthDepthTex.isValid) { renderer.backend.destroyTexture(depthDepthTex) }
            if (saoTex.isValid) { renderer.backend.destroyTexture(saoTex) }
            if (blurTex.isValid) { renderer.backend.destroyTexture(blurTex) }
            this._normalFB = GfxFrameBufferHandle.INVALID
            this._normalTex = GfxTextureHandle.INVALID
            this._normalDepthTex = GfxTextureHandle.INVALID
            this._depthFB = GfxFrameBufferHandle.INVALID
            this._depthTex = GfxTextureHandle.INVALID
            this._depthDepthTex = GfxTextureHandle.INVALID
            this._saoFB = GfxFrameBufferHandle.INVALID
            this._saoTex = GfxTextureHandle.INVALID
            this._blurFB = GfxFrameBufferHandle.INVALID
            this._blurTex = GfxTextureHandle.INVALID
        }
    }

    // ===== 自建场景几何体 VB/IB/layout（对齐 BgfxBackend._createVB/_createIB 模式） =====

    private func _getOrCreateLayout(renderer: ThreeRenderer): GfxVertexLayoutHandle {
        if (let Some(lh) <- this._layoutHandleCache) {
            return lh
        }
        // 经 renderer.backend.createVertexLayout(attrs) 高阶 API 创建布局句柄（封装 begin/add/end/create 序列）。
        // _createVB 经 renderer.createVertexBufferFromLayout(handle) 创建顶点缓冲
        // （renderer 内部从 handle 查回 layout 内存指针，无须接触 CPointer<VertexLayout>）。
        let handle = renderer.backend.createVertexLayout(this._getLayoutAttrs())
        this._layoutHandleCache = Some(handle)
        return handle
    }

    /** 构建顶点布局属性描述（对齐旧 begin/add/end 序列：position(3) + normal(3) + color(4) + uv(2)） */
    private func _getLayoutAttrs(): Array<GfxAttributeDesc> {
        let list = ArrayList<GfxAttributeDesc>()
        let pos = GfxAttributeDesc(GfxAttrib.Position, 3u8, GfxAttribType.Float, normalized: false, asInt: false)
        list.add(pos)
        let normal = GfxAttributeDesc(GfxAttrib.Normal, 3u8, GfxAttribType.Float, normalized: true, asInt: false)
        list.add(normal)
        let color = GfxAttributeDesc(GfxAttrib.Color0, 4u8, GfxAttribType.Float, normalized: false, asInt: false)
        list.add(color)
        let uv = GfxAttributeDesc(GfxAttrib.TexCoord0, 2u8, GfxAttribType.Float, normalized: false, asInt: false)
        list.add(uv)
        return list.toArray()
    }

    private func _createVB(renderer: ThreeRenderer, geom: BufferGeometry): GfxVertexBufferHandle {
        let geomId = geom.id
        if (let Some(vb) <- this._vbCache.get(geomId)) {
            return vb
        }
        let posAttrOpt = geom.getAttribute("position")
        if (let Some(pos) <- posAttrOpt) {
            let vc = pos.count
            if (vc == 0) { return GfxVertexBufferHandle.INVALID }
            // position(3) + normal(3) + color(4) + uv(2) = 12 floats
            let vertStride: Int64 = 12
            let totalFloats = vc * vertStride
            let data = Array<Float64>(totalFloats, { i => 0.0 })
            let normAttrOpt = geom.getAttribute("normal")
            let colAttrOpt = geom.getAttribute("color")
            let uvAttrOpt = geom.getAttribute("uv")
            for (vi in 0..vc) {
                let base = vi * vertStride
                data[base] = pos.getX(vi)
                data[base + 1] = pos.getY(vi)
                data[base + 2] = pos.getZ(vi)
                if (let Some(na) <- normAttrOpt) {
                    data[base + 3] = na.getX(vi)
                    data[base + 4] = na.getY(vi)
                    data[base + 5] = na.getZ(vi)
                } else { data[base + 5] = 1.0 }
                if (let Some(ca) <- colAttrOpt) {
                    data[base + 6] = ca.getX(vi)
                    data[base + 7] = ca.getY(vi)
                    data[base + 8] = ca.getZ(vi)
                    data[base + 9] = if (ca.itemSize > 3) { ca.getW(vi) } else { 1.0 }
                } else {
                    for (j in 0..4) { data[base + 6 + j] = 1.0 }
                }
                if (let Some(ua) <- uvAttrOpt) {
                    data[base + 10] = ua.getX(vi)
                    data[base + 11] = ua.getY(vi)
                }
            }
            let mem = PtrArray<UInt8>(Int64(totalFloats * 4))
            _writeFloatsToBytes(mem, data, totalFloats)
            let layout = this._getOrCreateLayout(renderer)
            let handle = renderer.backend.createVertexBuffer(layout, mem, 0u16)
            this._vbCache.add(geomId, handle)
            return handle
        } else { return GfxVertexBufferHandle.INVALID }
    }

    private func _createIB(renderer: ThreeRenderer, geom: BufferGeometry): GfxIndexBufferHandle {
        let geomId = geom.id
        if (let Some(ib) <- this._ibCache.get(geomId)) {
            return ib
        }
        if (let Some(idxAttr) <- geom.index) {
            let count = idxAttr.count
            if (count == 0) { return GfxIndexBufferHandle.INVALID }
            let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
            let mem = PtrArray<UInt8>(Int64(count * 2))
            _writeUInt16Bytes(mem, idxData, count)
            let handle = renderer.backend.createIndexBuffer(mem, 0u16)
            this._ibCache.add(geomId, handle)
            return handle
        } else { return GfxIndexBufferHandle.INVALID }
    }

    // ===== Blur 权重/偏移生成 =====

    /**
     * 高斯权重：
     * exp(-x²/(2·stdDev²)) / (sqrt(2π)·stdDev)
     */
    private func _gaussian(x: Float64, stdDev: Float64): Float64 {
        return exp(-(x * x) / (2.0 * stdDev * stdDev)) / (sqrt(2.0 * PI) * stdDev)
    }

    /**
     * 生成 blur 偏移与权重。
     * @param dirX dirY 方向（vBlur=(0,1)，hBlur=(1,0)）
     * @return 两个 9 元素数组：offsets(像素单位，shader 内除以 size 转 uv)、weights(高斯权重)
     */
    private func _generateBlurData(dirX: Float64, dirY: Float64): (Array<Float64>, Array<Float64>) {
        let radius = this.saoBlurRadius
        let stdDev = this.saoBlurStdDev
        let offsets = Array<Float64>(9 * 2, { _ => 0.0 })
        let weights = Array<Float64>(9 * 4, { _ => 0.0 })
        for (i in 0..9) {
            if (i <= radius) {
                offsets[i * 2 + 0] = dirX * Float64(i)
                offsets[i * 2 + 1] = dirY * Float64(i)
                weights[i * 4 + 0] = this._gaussian(Float64(i), stdDev)
            } else {
                // 超出半径的项权重为 0（KERNEL_RADIUS 固定 8，shader 数组 9 项）
                offsets[i * 2 + 0] = 0.0
                offsets[i * 2 + 1] = 0.0
                weights[i * 4 + 0] = 0.0
            }
        }
        return (offsets, weights)
    }

    // ===== Pass.render 入口 =====

    /**
     * Pass.render 入口：执行 SAO 链并输出遮蔽应用到场景。
     *
     * 流程：
     *   1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SAO 计算（view+2）→
     *   4. vBlur（view+3）→ 5. hBlur（view+4）→ 6. 输出（view+5）
     *
     * 子渲染方法各自走 Pass 基类高阶 API（内部经 renderer.execBgfx 序列化到渲染线程），
     * 不再外层包 execBgfx 闭包（避免嵌套死锁）。对齐 SSAOPass.render。
     */
    @Zone[three.renderers.postprocessing.SAOPass.render, name=sAOPass]
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: GfxFrameBufferHandle,
        readBuffer: GfxFrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        if (!this.enabled) { return }
        this._renderer = Some(renderer)
        // 尺寸未设置时默认取渲染器尺寸（composer.setSize 会转发，但防御性兜底）
        if (this._width <= 0 || this._height <= 0) {
            this._width = Int64(renderer.width)
            this._height = Int64(renderer.height)
        }

        let sceneOpt = this._scene
        let camOpt = this._camera
        if (let Some(scene) <- sceneOpt && let Some(camera) <- camOpt) {
            this._ensureRTs(renderer)
            if (!this._normalFB.isValid) { @LogTrace(["sao", "render: _ensureRTs failed, normalFB invalid"]); return }

            let baseView = SAOPass.SAO_VIEW_ID_BASE
            let uniforms = this._uniforms

            // ===== 1. 法线 pass（view+0）：normal shader 渲场景到法线 RT =====
            this._renderNormals(renderer, scene, camera, baseView)
            // ===== 2. 深度 pass（view+1）：aodepth shader 渲 NDC 深度到深度 RT =====
            this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
            // ===== 3. SAO 计算 pass（view+2）：全屏四边形采样法线/深度 =====
            this._renderSAOCalc(renderer, camera, UInt16(UInt16(baseView) + 2u16), uniforms)
            // ===== 4. vBlur pass（view+3）=====
            this._renderBlur(renderer, camera, UInt16(UInt16(baseView) + 3u16), uniforms, 0.0, 1.0, this._saoTex, this._blurFB)
            // ===== 5. hBlur pass（view+4）：写回 sao RT =====
            this._renderBlur(renderer, camera, UInt16(UInt16(baseView) + 4u16), uniforms, 1.0, 0.0, this._blurTex, this._saoFB)
            // ===== 6. 输出 pass（view+5）：按 output 模式写 writeBuffer/屏幕 =====
            this._renderOutput(renderer, readBuffer, writeBuffer, UInt16(UInt16(baseView) + 5u16))
            @LogTrace(["sao", "render: 6-pass chain done"])
        }
    }

    /**
     * 法线 pass：normal shader 渲场景到法线 RT。
     */
    private func _renderNormals(renderer: ThreeRenderer, scene: Scene, camera: Camera, baseView: UInt16): Unit {
        let viewId = baseView
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._normalFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为中性法线编码（view space +Z = 0.5,0.5,1.0 → 0x8080FF），背景法线朝相机
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR | GfxClearFlag.DEPTH, 0x8080FFu32, depth: 1.0f32, stencil: 0u8)

        let normalProgOpt = PostProcessingShaders.get("normal")
        if (let Some(normalSp) <- normalProgOpt) {
            if (!normalSp.gfxProgramHandle.isValid) {
                normalSp.compile()
            }
            let normalProg = normalSp.gfxProgramHandle
            if (!normalProg.isValid) { @LogTrace(["sao", "normal prog compile failed"]); return }

            let layout = this._getOrCreateLayout(renderer)
            let renderObjects = renderer.getSceneMeshes(scene)
            let viewMtx = camera.matrixWorldInverse.elements
            let uniforms = this._uniforms
            // 复用基类上传槽位：4=模型矩阵、2=法线矩阵
            // （原实现逐对象新建原生上传缓冲 + Array(12)，且逐对象 createUniform 取全局 bgfx 锁）
            let mtxMem = this._uploadMem(4, 64u32)
            let nmMem = this._uploadMem(2, 48u32)
            let nmData = Array<Float64>(12, { _ => 0.0 })
            let uNormalMat = uniforms.createUniform("u_normalMatrix", GfxUniformType.Mat3)
            var submitCnt: Int64 = 0
            for (ro in renderObjects) {
                let vb = this._createVB(renderer, ro.geometry)
                if (!vb.isValid) { continue }
                let posAttrOpt = ro.geometry.getAttribute("position")
                if (let Some(_) <- posAttrOpt) {
                    let mtxArr = ro.worldMatrix.elements
                    _writeFloats(mtxMem, mtxArr, 16)
                    renderer.backend.setTransform(mtxMem, num: 1u16)

                    // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序 → 紧凑 9 floats）
                    // SSR 实验验证：PostProcessingShaders 自定义 shader 的 mat3 uniform
                    //   必须用紧凑 c*3+r 布局（主渲染器 vec4 pad 格式会 col1row0 等错位）
                    // 仓颉 0..3 = 0,1,2（不含 3），不会迭代第 4 列/行，无越界
                    for (c in 0..3) {
                        for (r in 0..3) {
                            var acc = 0.0
                            for (k in 0..3) {
                                acc += viewMtx[k * 4 + r] * mtxArr[c * 4 + k]
                            }
                            nmData[c * 3 + r] = acc
                        }
                    }
                    _writeFloats(nmMem, nmData, 12)
                    this.setUniform(renderer, uNormalMat, nmMem, num: 1u16)

                    renderer.backend.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (ib.isValid) {
                        renderer.backend.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let normalState = GfxState.WRITE_RGB | GfxState.WRITE_A |
                                      GfxState.WRITE_Z | GfxState.DEPTH_TEST_LESS |
                                      GfxState.FRONT_CCW
                    renderer.backend.setState(normalState, rgba: 0x00000000u32)
                    renderer.backend.submit(viewId, normalProg, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                }
            }
            @LogTrace(["sao", "normal pass submitCnt=${submitCnt}"])
        } else {
            @LogTrace(["sao", "normal shader not registered"])
        }
    }

    /**
     * 深度 pass：aodepth shader 渲场景到深度 RT（写 gl_FragCoord.z = NDC 深度）。
     */
    private func _renderDepth(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为白色（NDC 深度=1.0）：背景无片元时颜色保持 1.0，SAO shader 用 depth>=1.0-EPSILON 跳过
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR | GfxClearFlag.DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let depthProgOpt = PostProcessingShaders.get("aodepth")
        if (let Some(depthSp) <- depthProgOpt) {
            if (!depthSp.gfxProgramHandle.isValid) {
                depthSp.compile()
            }
            let depthProg = depthSp.gfxProgramHandle
            if (!depthProg.isValid) { @LogTrace(["sao", "depth: aodepth program compile FAILED"]); return }
            @LogTrace(["sao", "depth: aodepth prog idx=${depthProg.idx}"])

            let layout = this._getOrCreateLayout(renderer)
            let renderObjects = renderer.getSceneMeshes(scene)
            // 复用基类上传槽位（原实现每帧新建 1 个 Array(16) + 1 块原生上传缓冲）
            let mtxMem = this._uploadMem(4, 64u32)
            for (ro in renderObjects) {
                let vb = this._createVB(renderer, ro.geometry)
                if (!vb.isValid) { continue }
                _writeFloats(mtxMem, ro.worldMatrix.elements, 16)
                renderer.backend.setTransform(mtxMem, num: 1u16)
                renderer.backend.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                let ib = this._createIB(renderer, ro.geometry)
                if (ib.isValid) {
                    renderer.backend.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                }
                let depthRenderState = GfxState.WRITE_RGB | GfxState.WRITE_A |
                                       GfxState.WRITE_Z | GfxState.DEPTH_TEST_LESS |
                                       GfxState.FRONT_CCW
                renderer.backend.setState(depthRenderState, rgba: 0x00000000u32)
                renderer.backend.submit(viewId, depthProg, depth: 0u32, blend: 0xFFu8)
            }
            @LogTrace(["sao", "depth: submitted renderObjects=${renderObjects.size}"])
        } else {
            @LogTrace(["sao", "depth: aodepth shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * SAO 计算 pass：全屏四边形采样法线/深度纹理，输出 1-occlusion。
     * sao shader（NUM_SAMPLES=7, NUM_RINGS=4）。
     */
    private func _renderSAOCalc(renderer: ThreeRenderer, camera: Camera, viewId: UInt16, uniforms: IUniformRegistry): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._saoFB)
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let saoProgOpt = PostProcessingShaders.get("sao")
        if (let Some(saoSp) <- saoProgOpt) {
            if (!saoSp.gfxProgramHandle.isValid) {
                saoSp.compile()
            }
            let saoProg = saoSp.gfxProgramHandle
            if (!saoProg.isValid) { @LogTrace(["sao", "sao prog compile failed"]); return }
            @LogTrace(["sao", "saoCalc: prog idx=${saoProg.idx} normalTex=${this._normalTex.idx} depthTex=${this._depthTex.idx}"])

            // 采样器：stage 0=深度, 1=法线
            let uDepth = uniforms.createUniform("tDepth", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uDepth, this._depthTex, 0u32)
            let uNormal = uniforms.createUniform("tNormal", GfxUniformType.Sampler)
            this.bindTexture(renderer, 1u8, uNormal, this._normalTex, 0u32)

            // size
            // 复用基类上传槽位：0=size、1=nearFar、3=proj、5=invProj、6=saoParams、7=minResSeed
            // （原实现每帧新建 6 块原生上传缓冲 + 6 个数组字面量）
            let uSize = uniforms.createUniform("u_size", GfxUniformType.Vec4)
            this._setVec4Uniform(renderer, uSize, 0, Float64(this._width), Float64(this._height), 0.0, 0.0)

            // cameraNear/Far
            let uNearFar = uniforms.createUniform("u_cameraNearFar", GfxUniformType.Vec4)
            this._setVec4Uniform(renderer, uNearFar, 1, camera.near, camera.far, 0.0, 0.0)

            // projection / inverse projection（投影逆矩阵用相机维护的 projectionMatrixInverse，
            // 原实现每帧 clone+invert 一个 Matrix4）
            let uProj = uniforms.createUniform("u_projMatrix", GfxUniformType.Mat4)
            let projMem = this._uploadMem(3, 64u32)
            _writeFloats(projMem, camera.projectionMatrix.elements, 16)
            this.setUniform(renderer, uProj, projMem, num: 1u16)

            let uInvProj = uniforms.createUniform("u_invProjMatrix", GfxUniformType.Mat4)
            let invMem = this._uploadMem(5, 64u32)
            _writeFloats(invMem, camera.projectionMatrixInverse.elements, 16)
            this.setUniform(renderer, uInvProj, invMem, num: 1u16)

            // saoParams: x=scale, y=intensity, z=bias, w=kernelRadius
            let uParams = uniforms.createUniform("u_saoParams", GfxUniformType.Vec4)
            this._setVec4Uniform(renderer, uParams, 6, this.saoScale, this.saoIntensity,
                this.saoBias, this.saoKernelRadius)

            // minResSeed: x=minResolution, y=randomSeed（randomSeed 恒为 0）
            let uMinRes = uniforms.createUniform("u_minResSeed", GfxUniformType.Vec4)
            this._setVec4Uniform(renderer, uMinRes, 7, this.saoMinResolution, 0.0, 0.0, 0.0)

            // 全屏四边形 submit
            this.submitQuad(viewId, saoProg)
        } else {
            @LogTrace(["sao", "sao shader not registered"])
        }
    }

    /**
     * 深度受限高斯模糊 pass（DepthLimitedBlurShader + configure 数据）。
     * @param dirX dirY 方向（vBlur=(0,1)，hBlur=(1,0)）
     * @param srcTex 输入纹理（vBlur=saoTex，hBlur=blurTex）
     * @param dstFB 输出 frame buffer（vBlur=blurFB，hBlur=saoFB）
     */
    private func _renderBlur(renderer: ThreeRenderer, camera: Camera, viewId: UInt16, uniforms: IUniformRegistry, dirX: Float64, dirY: Float64, srcTex: GfxTextureHandle, dstFB: GfxFrameBufferHandle): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, dstFB)
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let blurProgOpt = PostProcessingShaders.get("saoblur")
        if (let Some(blurSp) <- blurProgOpt) {
            if (!blurSp.gfxProgramHandle.isValid) {
                blurSp.compile()
            }
            let blurProg = blurSp.gfxProgramHandle
            if (!blurProg.isValid) { @LogTrace(["sao", "blur: saoblur program compile FAILED"]); return }
            @LogTrace(["sao", "blur: prog idx=${blurProg.idx}srcTex=${srcTex.idx}}ir=(${dirX},${dirY})"])

            let uDiff = uniforms.createUniform("tDiffuse", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uDiff, srcTex, 0u32)
            let uDepth = uniforms.createUniform("tDepth", GfxUniformType.Sampler)
            this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)

            let uSize = uniforms.createUniform("u_size", GfxUniformType.Vec4)
            this._setVec4Uniform(renderer, uSize, 0, Float64(this._width), Float64(this._height), 0.0, 0.0)

            let uNearFar = uniforms.createUniform("u_cameraNearFar", GfxUniformType.Vec4)
            this._setVec4Uniform(renderer, uNearFar, 1, camera.near, camera.far, 0.0, 0.0)

            // depthCutoff = saoBlurDepthCutoff * (far - near)
            let depthCutoff = this.saoBlurDepthCutoff * (camera.far - camera.near)
            let uCutoff = uniforms.createUniform("u_depthCutoff", GfxUniformType.Vec4)
            this._setScalarUniform(renderer, uCutoff, 8, depthCutoff)

            // 偏移/权重数组（9 项）
            // ★修复：shader 声明 uniform vec4 u_sampleOffsets[9]（9×16=144 字节），
            //   原实现只上传 18 个 float（9 个 xy 对，72 字节）→ bgfx_set_uniform 按
            //   count=9 读取 144 字节 → 72 字节堆越界读 → 偏移为垃圾值 → 模糊采样随机
            //   → SAO 原始噪点无法平滑（稀疏小黑点）。现按 vec4(x,y,0,0) 补齐 36 个 float。
            let (offsets, weights) = this._generateBlurData(dirX, dirY)
            let uOffsets = uniforms.createUniform("u_sampleOffsets", GfxUniformType.Vec4, 9u16)
            // 复用字段暂存（原实现每帧每方向新建一个 Array(36)）
            let offData = this._blurOffsetsScratch
            for (i in 0..36) { offData[i] = 0.0 }
            for (i in 0..9) {
                offData[i * 4 + 0] = offsets[i * 2 + 0]
                offData[i * 4 + 1] = offsets[i * 2 + 1]
            }
            // 复用基类上传槽位：9=offsets、10=weights（各 9×vec4=144 字节）
            let offMem = this._uploadMem(9, UInt32(9 * 4 * 4))
            _writeFloats(offMem, offData, 36)
            this.setUniform(renderer, uOffsets, offMem, num: 9u16)

            let uWeights = uniforms.createUniform("u_sampleWeights", GfxUniformType.Vec4, 9u16)
            let wMem = this._uploadMem(10, UInt32(9 * 4 * 4))
            _writeFloats(wMem, weights, 36)
            this.setUniform(renderer, uWeights, wMem, num: 9u16)

            this.submitQuad(viewId, blurProg)
        } else {
            @LogTrace(["sao", "blur: saoblur shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * 输出 pass：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）。
     * 输出阶段的 switch 分支：
     *   - Default：saoapply（sceneColor × ao，合并 materialCopy + CustomBlending 乘法）
     *   - SAO：copy saoRT；Normal：copy normalRT
     */
    private func _renderOutput(renderer: ThreeRenderer, readBuffer: GfxFrameBufferHandle, writeBuffer: GfxFrameBufferHandle, viewId: UInt16): Unit {
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, GfxFrameBufferHandle.INVALID)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let uniforms = this._uniforms

        // Default 模式：saoapply（sceneColor × ao）
        if (this.output == SAOPass.OUTPUT_DEFAULT) {
            let applyProgOpt = PostProcessingShaders.get("saoapply")
            if (let Some(applySp) <- applyProgOpt) {
                if (!applySp.gfxProgramHandle.isValid) {
                    applySp.compile()
                }
                let applyProg = applySp.gfxProgramHandle
                if (!applyProg.isValid) { @LogTrace(["sao", "output default: saoapply compile FAILED"]); return }
                let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                let uScene = uniforms.createUniform("tDiffuse", GfxUniformType.Sampler)
                this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
                let uAO = uniforms.createUniform("tAO", GfxUniformType.Sampler)
                this.bindTexture(renderer, 1u8, uAO, this._saoTex, 0u32)
                @LogTrace(["sao", "output default: sceneTex=${sceneTex.idx} saoTex=${this._saoTex.idx}"])
                this.submitQuad(viewId, applyProg)
            } else {
                @LogTrace(["sao", "output default: saoapply shader NOT REGISTERED"])
            }
            return
        }

        // SAO/Normal：copy shader 透传对应纹理
        var srcTex: GfxTextureHandle = this._saoTex
        if (this.output == SAOPass.OUTPUT_NORMAL) {
            srcTex = this._normalTex
        }
        let copyProgOpt = PostProcessingShaders.get("copy")
        if (let Some(copySp) <- copyProgOpt) {
            if (!copySp.gfxProgramHandle.isValid) {
                copySp.compile()
            }
            let copyProg = copySp.gfxProgramHandle
            if (!copyProg.isValid) { @LogTrace(["sao", "output copy: copy compile FAILED"]); return }
            let uDiff = uniforms.createUniform("tDiffuse", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uDiff, srcTex, 0u32)
            let uOpacity = uniforms.createUniform("u_opacity", GfxUniformType.Vec4)
            // 复用基类上传槽位（原实现每帧新建 1 块原生上传缓冲 + 1 个数组字面量）
            this._setScalarUniform(renderer, uOpacity, 11, 1.0)
            @LogTrace(["sao", "output copy: output=${this.output} srcTex=${srcTex.idx}"])
            this.submitQuad(viewId, copyProg)
        } else {
            @LogTrace(["sao", "output copy: copy shader NOT REGISTERED"])
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（用 renderer.setViewTransform 高阶 API）。
     */
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
        // 复用基类上传缓冲槽位：原实现每帧 2 次调用各新建 2 个 Array(16) + 2 块原生上传缓冲。
        // 槽位隔离：12=view，13=proj。
        let viewMem = this._uploadMem(12, 64u32)
        let projMem = this._uploadMem(13, 64u32)
        _writeFloats(viewMem, camera.matrixWorldInverse.elements, 16)
        _writeFloats(projMem, camera.projectionMatrix.elements, 16)
        renderer.backend.setViewTransform(viewId, viewMem, projMem)
    }

    /** 销毁全部 GPU 资源（composer.dispose 或 renderer.shutdown 调用） */
    public override func release(): Bool {
        this._destroyRTs()
        // 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose
        // 释放场景几何体缓存
        if (let Some(renderer) <- this._renderer) {
            for ((_, vb) in this._vbCache) {
                renderer.backend.destroyVertexBuffer(vb)
            }
            this._vbCache.clear()
            for ((_, ib) in this._ibCache) {
                renderer.backend.destroyIndexBuffer(ib)
            }
            this._ibCache.clear()
            if (let Some(lh) <- this._layoutHandleCache) {
                renderer.backend.destroyVertexLayout(lh)
                this._layoutHandleCache = None
            }
        }
        // 本 Pass 使用私有 _uniforms 字段创建了约 21 个 uniform 句柄，
        // 必须显式 release，否则 composer 重建/切换后句柄泄漏（二型：私有 uniform 注册表字段）。
        this._uniforms.release()
        @LogTrace(["sao", "released"])
        return true
    }
}
