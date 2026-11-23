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
 * @file[zh-cn] SSAOPass 屏幕空间环境光遮蔽（SSAO）后处理 pass
 * @brief[zh-cn] 屏幕空间环境光遮蔽（SSAO）后处理 pass
 * @explain[zh-cn] 以 EffectComposer Pass 链方式注入（对齐 bloom 的 BgfxUnrealBloomPass）：
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(SSAOPass(scene, camera))
 *         composer.render()
 *         render() 内部（每帧经 renderer.execBgfx 序列化到渲染线程）：
 *         1. 法线 pass（view SSAO_VIEW_ID_BASE+0）：normal shader 渲场景法线到法线 RT
 *         2. 深度 pass（view +1）：depth shader 渲场景深度到深度 RT
 *         3. SSAO 计算 pass（view +2）：全屏四边形采样法线/深度/噪声 + kernel，输出遮蔽
 *         4. blur pass（view +3）：5x5 平均模糊遮蔽
 *         5. apply pass（view +4）：采样 readBuffer（场景）与 blur 遮蔽图，输出 sceneColor × ao
 *            写 writeBuffer；renderToScreen=true（composer 链最后一个 enabled pass）时写屏幕。
 *         自包含：uniforms（uniform 注册表实例）、全屏四边形（VB/IB/layout）、
 *         场景几何体 VB/IB/layout 均在 pass 内懒创建并缓存，不依赖 BgfxBackend 内部资源
 *         （避免 bgfx_backend ↔ postprocessing 包循环依赖，对齐 UnrealBloomPass 自包含模式）。
 *
 * @file[en] SSAOPass screen-space ambient occlusion (SSAO) post-processing pass
 * @brief[en] Screen-space ambient occlusion (SSAO) post-processing pass
 * @explain[en] Injected via the EffectComposer Pass chain (aligned with the UnrealBloomPass bloom style):
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(SSAOPass(scene, camera))
 *         composer.render()
 *         Inside render() (each frame serialized to the render thread via renderer.execBgfx):
 *         1. Normal pass (view SSAO_VIEW_ID_BASE+0): normal shader renders scene normals to a normal RT
 *         2. Depth pass (view +1): depth shader renders scene depth to a depth RT
 *         3. SSAO compute pass (view +2): full-screen quad samples normal/depth/noise + kernel, outputs occlusion
 *         4. blur pass (view +3): 5x5 average blur of the occlusion
 *         5. apply pass (view +4): samples readBuffer (scene) and the blur occlusion map, outputs sceneColor × ao
 *            to writeBuffer; writes to screen when renderToScreen=true (last enabled pass in the composer chain).
 *         Self-contained: uniforms (uniform registry instance), full-screen quad (VB/IB/layout),
 *         and scene geometry VB/IB/layout are lazily created and cached inside the pass, not depending on BgfxBackend internals
 *         (avoiding a bgfx_backend ↔ postprocessing package cycle, aligned with the UnrealBloomPass self-contained pattern).
 */
package three.renderers.postprocessing

import three.renderers._gfx.*
import three.utils.safe.IReleasable
import three.renderers.common.*
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
import std.random.*
import three.profiler.*
import three.profiler.macros.*

public class SSAOPass <: Pass & IReleasable {
    /** SSAO pass 用的 view ID 段约定：主渲染 view 0，阴影 view 64+，SSAO 从 160 起 */
    public static let SSAO_VIEW_ID_BASE: UInt16 = 160u16

    /** 场景/相机（法线/深度 pass 渲场景用） */
    private var _scene: Option<Scene> = None
    private var _camera: Option<Camera> = None

    // ===== RT 句柄（懒创建，setSize 或首帧时初始化） =====
    /** 法线 RT（RGBA16F，法线编码 0.5+0.5 视图空间） */
    private var _normalFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _normalTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 法线 RT 的 depth attachment（D24，normal pass 深度测试用） */
    private var _normalDepthTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 深度 RT（RGBA16F，depth shader 写 gl_FragCoord.z 到颜色） */
    private var _depthFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _depthTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 深度 RT 的 depth attachment（D24，depth pass 深度测试用） */
    private var _depthDepthTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** SSAO 遮蔽 RT（RGBA8，1-occlusion） */
    private var _ssaoFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _ssaoTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** blur 结果 RT（RGBA8） */
    private var _blurFB: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID
    private var _blurTex: GfxTextureHandle = GfxTextureHandle.INVALID
    /** 4x4 随机旋转噪声纹理（RGBA8） */
    private var _noiseTex: GfxTextureHandle = GfxTextureHandle.INVALID

    /** SSAO 采样半径（默认 8） */
    public var kernelRadius: Float64 = 8.0
    /** 最小遮蔽距离（避免近邻片元微小深度差伪影） */
    public var minDistance: Float64 = 0.005
    /** 最大遮蔽距离 */
    public var maxDistance: Float64 = 0.1

    /** 半球采样 kernel（32 个 vec4，xyz=向量 w=padding；bgfx vec3 数组需用 vec4+padding） */
    private var _kernel: Array<Float64> = Array<Float64>(128, { _ => 0.0 })
    /** RT 尺寸 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    // ===== 复用暂存（逐帧避免新建原生内存/堆数组） =====
    /** view 空间 3x3 法线矩阵暂存（normal pass 逐对象写入，写入后立即消费） */
    private let _nmScratch: Array<Float64> = Array<Float64>(12, { _ => 0.0 })
    /** view/proj 矩阵暂存（_setViewTransformFor 用，写入后立即消费） */
    private let _viewScratch: Array<Float64> = Array<Float64>(16, { _ => 0.0 })
    private let _projScratch: Array<Float64> = Array<Float64>(16, { _ => 0.0 })

    /** 最近一次 render 注入的渲染器（setSize/dispose 销毁 GPU 资源时经 renderer 高阶 API 序列化） */
    private var _renderer: Option<ThreeRenderer> = None

    // ===== 场景几何体缓存（对齐 BgfxBackend._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, GfxVertexBufferHandle> = HashMap<Int64, GfxVertexBufferHandle>()
    private var _ibCache: HashMap<Int64, GfxIndexBufferHandle> = HashMap<Int64, GfxIndexBufferHandle>()
    private var _layoutHandleCache: Option<GfxVertexLayoutHandle> = None

    /**
     * 构造：`new SSAOPass(scene, camera)`。
     */
    public init(scene: Scene, camera: Camera) {
        super()
        this._scene = Some(scene)
        this._camera = Some(camera)
        // 默认 needsSwap=true（Pass 基类默认），
        // 输出到 writeBuffer 后由 composer 交换，供后续 pass / 屏幕使用。
        this.needsSwap = true
        this._generateKernel()
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /** 设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用） */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height) {
            this._destroyRTs()
            this._width = width
            this._height = height
            @LogTrace(["ssao", "setSize=${width}x${height}"])
        }
    }

    // ===== kernel 生成 =====

    private func _generateKernel(): Unit {
        // 半球采样（z 正方向）+ 归一化 + 距离加权（近密远疏）
        for (i in 0..32) {
            var vx = 2.0 * this._rand() - 1.0
            var vy = 2.0 * this._rand() - 1.0
            var vz = this._rand()
            let len = sqrt(vx * vx + vy * vy + vz * vz)
            if (len > 0.000001) {
                vx = vx / len
                vy = vy / len
                vz = vz / len
            }
            let r = this._rand()
            vx = vx * r
            vy = vy * r
            vz = vz * r
            let scale = Float64(i) / 32.0
            let weight = 0.1 + 0.9 * (scale * scale)
            this._kernel[i * 4 + 0] = vx * weight
            this._kernel[i * 4 + 1] = vy * weight
            this._kernel[i * 4 + 2] = vz * weight
            this._kernel[i * 4 + 3] = 0.0
        }
        // 噪声旋转矩阵（4x4，由 _rand 在 _ensureRTs 中生成）
    }

    private func _rand(): Float64 {
        // 简单 LCG 伪随机（确定性，避免 std.random 状态问题）
        this._seed = (this._seed * 1103515245 + 12345) % 2147483648
        return Float64(this._seed) / 2147483648.0
    }
    private var _seed: Int64 = 123456789

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

        // 深度 RT：RGBA32F（存线性深度 viewZToOrthographicDepth，供 SSAO 直接采样；
        // 用全精度浮点避免 D24 硬件深度普通采样精度不足 + far 端非线性放大成条带）
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

        // SSAO 遮蔽 RT：RGBA16F（遮蔽值 0~1 连续，避免 RGBA8 仅 256 级量化 → 淡条纹 banding）
        let ssaoTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.RGBA16F,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._ssaoTex = ssaoTex
        this._ssaoFB = this._createFB(renderer, ssaoTex)

        // blur RT：RGBA16F（与遮蔽 RT 同精度，避免 banding）
        let blurTex = renderer.backend.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            GfxTextureFormat.RGBA16F,
            GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP,
            None)
        this._blurTex = blurTex
        this._blurFB = this._createFB(renderer, blurTex)

        // 噪声纹理：4x4 RGBA8 随机旋转向量
        let noiseData = Array<UInt8>(4 * 4 * 4, { _ => 0u8 })
        for (i in 0..16) {
            noiseData[i * 4 + 0] = UInt8(this._rand() * 255.0)
            noiseData[i * 4 + 1] = UInt8(this._rand() * 255.0)
            noiseData[i * 4 + 2] = UInt8((this._rand() * 2.0 - 1.0) * 127.5 + 127.5)
            noiseData[i * 4 + 3] = 255u8
        }
        let noiseMem = PtrArray<UInt8>(4 * 4 * 4)
        _writeUInt8Bytes(noiseMem, noiseData, Int64(noiseData.size))
        this._noiseTex = renderer.backend.createTexture2D(
            4u16, 4u16, false, 1u16,
            GfxTextureFormat.RGBA8,
            0u64,
            Some(noiseMem))

        @LogTrace(["ssao", "_ensureRTs done ${this._width}x${this._height}"])
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
            let ssaoFB = this._ssaoFB; let blurFB = this._blurFB
            let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
            let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
            let ssaoTex = this._ssaoTex; let blurTex = this._blurTex
            let noiseTex = this._noiseTex
            if (normalFB.isValid) { renderer.backend.destroyFrameBuffer(normalFB) }
            if (depthFB.isValid) { renderer.backend.destroyFrameBuffer(depthFB) }
            if (ssaoFB.isValid) { renderer.backend.destroyFrameBuffer(ssaoFB) }
            if (blurFB.isValid) { renderer.backend.destroyFrameBuffer(blurFB) }
            if (normalTex.isValid) { renderer.backend.destroyTexture(normalTex) }
            if (normalDepthTex.isValid) { renderer.backend.destroyTexture(normalDepthTex) }
            if (depthTex.isValid) { renderer.backend.destroyTexture(depthTex) }
            if (depthDepthTex.isValid) { renderer.backend.destroyTexture(depthDepthTex) }
            if (ssaoTex.isValid) { renderer.backend.destroyTexture(ssaoTex) }
            if (blurTex.isValid) { renderer.backend.destroyTexture(blurTex) }
            if (noiseTex.isValid) { renderer.backend.destroyTexture(noiseTex) }
            this._normalFB = GfxFrameBufferHandle.INVALID
            this._normalTex = GfxTextureHandle.INVALID
            this._normalDepthTex = GfxTextureHandle.INVALID
            this._depthFB = GfxFrameBufferHandle.INVALID
            this._depthTex = GfxTextureHandle.INVALID
            this._depthDepthTex = GfxTextureHandle.INVALID
            this._ssaoFB = GfxFrameBufferHandle.INVALID
            this._ssaoTex = GfxTextureHandle.INVALID
            this._blurFB = GfxFrameBufferHandle.INVALID
            this._blurTex = GfxTextureHandle.INVALID
            this._noiseTex = GfxTextureHandle.INVALID
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
                } else {
                    data[base + 5] = 1.0
                }
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
        } else {
            return GfxVertexBufferHandle.INVALID
        }
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
        } else {
            return GfxIndexBufferHandle.INVALID
        }
    }

    // ===== Pass.render 入口 =====

    /**
     * Pass.render 入口：执行 SSAO 链并输出遮蔽应用到场景。
     *
     * 流程：
     *   1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SSAO 计算（view+2）→ 4. blur（view+3）
     *   5. apply pass（view+4）：采样 readBuffer（场景）与 blur 遮蔽图，输出 sceneColor × ao
     *      写 writeBuffer；renderToScreen=true（composer 链最后一个 enabled pass）时写屏幕。
     *
     * 所有 bgfx 调用经 renderer.execBgfx 序列化到渲染线程（对齐 UnrealBloomPass.render）。
     * writeBuffer/readBuffer 是 @C struct，lambda 不能直接捕获，用 Box 包一层引用类型。
     */
    @Zone[three.renderers.postprocessing.SSAOPass.render, name=sSAOPass]
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
            // 各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
            // clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
            // 调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
            // 故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。
            this._ensureRTs(renderer)
            if (!this._normalFB.isValid) { @LogTrace(["ssao", "render: _ensureRTs failed, normalFB invalid"]); return }

            let baseView = SSAOPass.SSAO_VIEW_ID_BASE

            // ===== 1. 法线 pass（view+0）：normal shader 渲场景到法线 RT =====
            this._renderNormals(renderer, scene, camera, baseView)
            // ===== 2. 深度 pass（view+1）：depth shader 渲场景到深度 RT =====
            this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
            // ===== 3. SSAO 计算 pass（view+2）：全屏四边形采样法线/深度/噪声 =====
            this._renderSSAOCalc(renderer, camera, baseView)
            // ===== 4. blur pass（view+3）：5x5 平均模糊遮蔽 =====
            this._renderBlur(renderer, camera, baseView)
            // ===== 5. apply pass（view+4）：sceneColor × ao 写 writeBuffer/屏幕 =====
            this._renderApply(renderer, readBuffer, writeBuffer)
            @LogTrace(["ssao", "render: 5-pass chain done"])
        }
    }

    /**
     * apply pass：采样 readBuffer（场景颜色）与 blur 遮蔽图（ao），输出 sceneColor × ao。
     * 对应输出阶段（copyMaterial：blur 遮蔽图混入 readBuffer 场景）。
     *
     * renderToScreen=true（最后一个 enabled pass）时目标为 swap chain（无效 FB handle），
     * 并显式 bgfx_frame 上屏（SSAO 链自身不调 renderer.render，不会经 finishRender 触发 frame）。
     */
    private func _renderApply(renderer: ThreeRenderer, readBuffer: GfxFrameBufferHandle, writeBuffer: GfxFrameBufferHandle): Unit {
        let viewId = UInt16(UInt16(SSAOPass.SSAO_VIEW_ID_BASE) + 4u16)
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, GfxFrameBufferHandle.INVALID)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR, 0x00000000u32)

        let applyProgOpt = PostProcessingShaders.get("ssaoapply")
        if (let Some(applySp) <- applyProgOpt) {
            if (!applySp.gfxProgramHandle.isValid) {
                applySp.compile()
            }
            let applyProg = applySp.gfxProgramHandle
            if (!applyProg.isValid) { @LogTrace(["ssao", "apply: ssaaoapply program compile FAILED"]); return }
            @LogTrace(["ssao", "apply: prog idx=${applyProg.idx} renderToScreen=${this.renderToScreen}"])

            // 场景颜色 = readBuffer 的 color attachment 0（composer 的 RGBA16F/8 RT）
            let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
            @LogTrace(["ssao", "apply: readBuffer=${readBuffer.idx} sceneTex=${sceneTex.idx} blurTex=${this._blurTex.idx}"])
            let uScene = this._cachedUniform("tDiffuse", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
            let uAO = this._cachedUniform("tAO", GfxUniformType.Sampler)
            this.bindTexture(renderer, 1u8, uAO, this._blurTex, 0u32)

            this.submitQuad(viewId, applyProg)
            // 不在此调 bgfx_frame：frame 统一由 EffectComposer.render 末尾触发
            // （bgfx_frame 是双缓冲交换，每帧仅一次；pass 只负责 submit）
        } else {
            @LogTrace(["ssao", "apply: ssaaoapply shader NOT REGISTERED in PostProcessingShaders"])
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
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR | GfxClearFlag.DEPTH, 0x8080FFu32)

        let normalProgOpt = PostProcessingShaders.get("normal")
        if (let Some(normalSp) <- normalProgOpt) {
            if (!normalSp.gfxProgramHandle.isValid) {
                normalSp.compile()
            }
            let normalProg = normalSp.gfxProgramHandle
            if (!normalProg.isValid) { @LogTrace(["ssao", "normal prog compile failed"]); return }

            let layout = this._getOrCreateLayout(renderer)
            let renderObjects = renderer.getSceneMeshes(scene)
            // view 矩阵 3x3（SSAO 需要 view space 法线，u_normalMatrix = mat3(view) × mat3(model)）
            let viewMtx = camera.matrixWorldInverse.elements
            // 复用的 bgfx 变换内存（setTransform 经 execBgfx 同步消费，可安全复用）
            let mtxMem = this._uploadMem(0, 64u32)
            let nmMem = this._uploadMem(1, 48u32)
            let nmScratch = this._nmScratch
            var submitCnt: Int64 = 0
            for (ro in renderObjects) {
                let vb = this._createVB(renderer, ro.geometry)
                if (!vb.isValid) { continue }
                let posAttrOpt = ro.geometry.getAttribute("position")
                if (let Some(_) <- posAttrOpt) {
                    let mtxArr = ro.worldMatrix.elements
                    _writeFloats(mtxMem, mtxArr, 16)
                    renderer.backend.setTransform(mtxMem, num: 1u16)

                    // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序，9 floats 紧凑布局）
                    // 还原 c*3+r：用户 SSR 实验验证 c*4+r (pad to vec4) 导致法线错误 →
                    //   地板/天花板视图空间法线错乱 → SSAO 遮蔽错误 / 倒影消失
                    for (c in 0..3) {
                        for (r in 0..3) {
                            var acc = 0.0
                            for (k in 0..3) {
                                acc += viewMtx[k * 4 + r] * mtxArr[c * 4 + k]
                            }
                            nmScratch[c * 3 + r] = acc
                        }
                    }
                    let uNormalMat = this._cachedUniform("u_normalMatrix", GfxUniformType.Mat3)
                    _writeFloats(nmMem, nmScratch, 12)
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
            @LogTrace(["ssao", "normal pass submitCnt=${submitCnt}"])
        } else {
            @LogTrace(["ssao", "normal shader not registered"])
        }
    }

    /**
     * 深度 pass：depth shader 渲场景到深度 RT（写 gl_FragCoord.z 到颜色）。
     */
    private func _renderDepth(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为白色（线性深度=1.0）：背景无片元时颜色保持 1.0，SSAO shader 用 depth>=0.999 跳过背景
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR | GfxClearFlag.DEPTH, 0xFFFFFFFFu32)

        // 用 SSAO 专用线性深度 shader（ssaodepth）：渲 viewZToOrthographicDepth 到 RGBA32F，
        // 避免 D24 硬件深度普通采样精度不足 + getViewZ far 端放大成条带。
        let depthProgOpt = PostProcessingShaders.get("ssaodepth")
        if (let Some(depthSp) <- depthProgOpt) {
            if (!depthSp.gfxProgramHandle.isValid) {
                depthSp.compile()
            }
            let depthProg = depthSp.gfxProgramHandle
            if (!depthProg.isValid) { @LogTrace(["ssao", "depth: ssaodepth program compile FAILED"]); return }
            @LogTrace(["ssao", "depth: ssaodepth prog idx=${depthProg.idx}"])

            // u_cameraNearFar uniform（线性深度反投影需要 near/far）
            let uNearFar = this._cachedUniform("u_cameraNearFar", GfxUniformType.Vec4)
            let nfMem = this._uploadMem(2, 16u32)
            _writeFloats(nfMem, [camera.near, camera.far, 0.0, 0.0], 4)
            this.setUniform(renderer, uNearFar, nfMem)

            let layout = this._getOrCreateLayout(renderer)
            let renderObjects = renderer.getSceneMeshes(scene)
            // 复用的矩阵暂存与 bgfx 变换内存（避免每个对象一次分配）
            let mtxScratch = Array<Float64>(16, { _ => 0.0 })
            let mtxMem = this._uploadMem(3, 64u32)
            for (ro in renderObjects) {
                let vb = this._createVB(renderer, ro.geometry)
                if (!vb.isValid) { continue }
                ro.worldMatrix.toArray(mtxScratch)
                _writeFloats(mtxMem, mtxScratch, 16)
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
            @LogTrace(["ssao", "depth: submitted renderObjects=${renderObjects.size}"])
        } else {
            @LogTrace(["ssao", "depth: ssaodepth shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * SSAO 计算 pass：全屏四边形采样法线/深度/噪声纹理，输出 1-occlusion。
     */
    private func _renderSSAOCalc(renderer: ThreeRenderer, camera: Camera, baseView: UInt16): Unit {
        let viewId = UInt16(UInt16(baseView) + 2u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._ssaoFB)
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR, 0x00000000u32)

        let ssaoProgOpt = PostProcessingShaders.get("ssao")
        if (let Some(ssaoSp) <- ssaoProgOpt) {
            if (!ssaoSp.gfxProgramHandle.isValid) {
                ssaoSp.compile()
            }
            let ssaoProg = ssaoSp.gfxProgramHandle
            if (!ssaoProg.isValid) { @LogTrace(["ssao", "ssao prog compile failed"]); return }
            @LogTrace(["ssao", "ssaoCalc: prog idx=${ssaoProg.idx} normalTex=${this._normalTex.idx} depthTex=${this._depthTex.idx} noiseTex=${this._noiseTex.idx}"])

            // 采样器：stage 0=法线, 1=深度, 2=噪声
            let uNormal = this._cachedUniform("tNormal", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uNormal, this._normalTex, 0u32)
            let uDepth = this._cachedUniform("tDepth", GfxUniformType.Sampler)
            this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)
            let uNoise = this._cachedUniform("tNoise", GfxUniformType.Sampler)
            this.bindTexture(renderer, 2u8, uNoise, this._noiseTex, 0u32)

            // kernel 数组 uniform（32 个 vec4）
            let uKernel = this._cachedUniform("u_kernel", GfxUniformType.Vec4, num: 32u16)
            let kernelMem = this._uploadMem(4, UInt32(128 * 4))
            _writeFloats(kernelMem, this._kernel, 128)
            this.setUniform(renderer, uKernel, kernelMem, num: 32u16)

            // resolution
            let uRes = this._cachedUniform("u_resolution", GfxUniformType.Vec4)
            let resMem = this._uploadMem(5, 16u32)
            _writeFloats(resMem, [Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
            this.setUniform(renderer, uRes, resMem)

            // cameraNear/Far
            let uNearFarC = this._cachedUniform("u_cameraNearFar", GfxUniformType.Vec4)
            let nfMemC = this._uploadMem(6, 16u32)
            _writeFloats(nfMemC, [camera.near, camera.far, 0.0, 0.0], 4)
            this.setUniform(renderer, uNearFarC, nfMemC)

            // projection / inverse projection
            let uProj = this._cachedUniform("u_projMatrix", GfxUniformType.Mat4)
            let projMem = this._uploadMem(7, 64u32)
            _writeFloats(projMem, camera.projectionMatrix.elements, 16)
            this.setUniform(renderer, uProj, projMem)

            let invProj = camera.projectionMatrix.clone().invert()
            let uInvProj = this._cachedUniform("u_invProjMatrix", GfxUniformType.Mat4)
            let invMem = this._uploadMem(8, 64u32)
            _writeFloats(invMem, invProj.elements, 16)
            this.setUniform(renderer, uInvProj, invMem)

            // ssaoParams: x=kernelRadius, y=minDistance, z=maxDistance
            let uParams = this._cachedUniform("u_ssaoParams", GfxUniformType.Vec4)
            let pMem = this._uploadMem(9, 16u32)
            _writeFloats(pMem, [this.kernelRadius, this.minDistance, this.maxDistance, 0.0], 4)
            this.setUniform(renderer, uParams, pMem)

            // 全屏四边形 submit
            this.submitQuad(viewId, ssaoProg)
        } else {
            @LogTrace(["ssao", "ssao shader not registered"])
        }
    }

    /**
     * blur pass：SSAOBlurShader 5x5 平均模糊遮蔽。
     */
    private func _renderBlur(renderer: ThreeRenderer, camera: Camera, baseView: UInt16): Unit {
        let viewId = UInt16(UInt16(baseView) + 3u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._blurFB)
        this.clearRenderTarget(renderer, viewId, GfxClearFlag.COLOR, 0x00000000u32)

        let blurProgOpt = PostProcessingShaders.get("ssaoblur")
        if (let Some(blurSp) <- blurProgOpt) {
            if (!blurSp.gfxProgramHandle.isValid) {
                blurSp.compile()
            }
            let blurProg = blurSp.gfxProgramHandle
            if (!blurProg.isValid) { @LogTrace(["ssao", "blur: ssaoblur program compile FAILED"]); return }
            @LogTrace(["ssao", "blur: prog idx=${blurProg.idx} ssaoTex=${this._ssaoTex.idx}"])

            let uDiff = this._cachedUniform("tDiffuse", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uDiff, this._ssaoTex, 0u32)

            let uRes = this._cachedUniform("u_resolution", GfxUniformType.Vec4)
            let resMem = this._uploadMem(10, 16u32)
            _writeFloats(resMem, [Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
            this.setUniform(renderer, uRes, resMem)

            this.submitQuad(viewId, blurProg)
        } else {
            @LogTrace(["ssao", "blur: ssaoblur shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（通过 renderer.setViewTransform 高阶 API）。
     */
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
        // 复用上传缓冲：bgfx_set_view_transform 两矩阵同时提交且各自独立，需两块缓冲，
        // 但均为瞬时 memcpy，可跨帧复用（写入下一批数据前已被消费）。
        let viewMem = this._uploadMem(11, 64u32)
        let projMem = this._uploadMem(12, 64u32)
        let viewScratch = this._viewScratch
        let projScratch = this._projScratch
        camera.matrixWorldInverse.toArray(viewScratch)
        camera.projectionMatrix.toArray(projScratch)
        _writeFloats(viewMem, viewScratch, 16)
        _writeFloats(projMem, projScratch, 16)
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
            for ((_, ib) in this._ibCache) {
                renderer.backend.destroyIndexBuffer(ib)
            }
            if (let Some(lh) <- this._layoutHandleCache) {
                renderer.backend.destroyVertexLayout(lh)
                this._layoutHandleCache = None
            }
        }
        this._vbCache.clear()
        this._ibCache.clear()
        // 必须经 _disposePassUniforms() 释放，否则 composer 重建/切换后句柄泄漏（同 SMAA 修复点①）。
        this._disposePassUniforms()
        return true
    }
}
