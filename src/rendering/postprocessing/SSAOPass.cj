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
 *         自包含：uniforms（BgfxUniforms 实例）、全屏四边形（VB/IB/layout）、
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
 *         Self-contained: uniforms (BgfxUniforms instance), full-screen quad (VB/IB/layout),
 *         and scene geometry VB/IB/layout are lazily created and cached inside the pass, not depending on BgfxBackend internals
 *         (avoiding a bgfx_backend ↔ postprocessing package cycle, aligned with the UnrealBloomPass self-contained pattern).
 */
package three.rendering.postprocessing

import three.rendering.common.*
import three.rendering.bgfx.*
import three.rendering.shaders.ShaderLibs
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.Mesh
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.*
import three.utils.log.macros.*
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.types.*
import std.collection.*
import std.math.*
import std.random.*

public class SSAOPass <: Pass {
    /** SSAO pass 用的 view ID 段约定：主渲染 view 0，阴影 view 64+，SSAO 从 160 起 */
    public static let SSAO_VIEW_ID_BASE: UInt16 = 160u16

    /** 场景/相机（法线/深度 pass 渲场景用） */
    private var _scene: Option<Scene> = None
    private var _camera: Option<Camera> = None

    // ===== RT 句柄（懒创建，setSize 或首帧时初始化） =====
    /** 法线 RT（RGBA16F，法线编码 0.5+0.5 视图空间） */
    private var _normalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _normalTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 法线 RT 的 depth attachment（D24，normal pass 深度测试用） */
    private var _normalDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT（RGBA16F，depth shader 写 gl_FragCoord.z 到颜色） */
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT 的 depth attachment（D24，depth pass 深度测试用） */
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** SSAO 遮蔽 RT（RGBA8，1-occlusion） */
    private var _ssaoFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _ssaoTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** blur 结果 RT（RGBA8） */
    private var _blurFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _blurTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 4x4 随机旋转噪声纹理（RGBA8） */
    private var _noiseTex: TextureHandle = INVALID_TEXTURE_HANDLE

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

    /** 本 pass 自有的 uniform 注册表（对齐 UnrealBloomPass 自包含模式） */
    private var _uniforms: BgfxUniforms = BgfxUniforms()

    /** 最近一次 render 注入的渲染器（setSize/dispose 销毁 GPU 资源时经 renderer 高阶 API 序列化） */
    private var _renderer: Option<ThreeRenderer> = None

    // ===== 场景几何体缓存（对齐 BgfxBackend._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

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
        if (Handle.isValid(this._normalTex)) { return }

        // 法线 RT：RGBA16F + D24 depth attachment
        let normalTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._normalTex = normalTex
        let normalDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24S8.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._normalDepthTex = normalDepthTex
        this._normalFB = this._createFBWithDepth(renderer, normalTex, normalDepthTex)

        // 深度 RT：RGBA32F（存线性深度 viewZToOrthographicDepth，供 SSAO 直接采样；
        // 用全精度浮点避免 D24 硬件深度普通采样精度不足 + far 端非线性放大成条带）
        let depthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA32F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._depthTex = depthTex
        let depthDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24S8.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._depthDepthTex = depthDepthTex
        this._depthFB = this._createFBWithDepth(renderer, depthTex, depthDepthTex)

        // SSAO 遮蔽 RT：RGBA16F（遮蔽值 0~1 连续，避免 RGBA8 仅 256 级量化 → 淡条纹 banding）
        let ssaoTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._ssaoTex = ssaoTex
        this._ssaoFB = this._createFB(renderer, ssaoTex)

        // blur RT：RGBA16F（与遮蔽 RT 同精度，避免 banding）
        let blurTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
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
        let noiseMem = BgfxMemory(UInt32(4 * 4 * 4))
        noiseMem.writeUInt8(noiseData, Int64(noiseData.size))
        this._noiseTex = renderer.createTexture2D(
            4u16, 4u16, false, 1u16,
            TextureFormat.RGBA8.value(),
            0u64,
            Some(noiseMem))

        @LogTrace(["ssao", "_ensureRTs done ${this._width}x${this._height}"])
    }

    private func _createFB(renderer: ThreeRenderer, tex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => tex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: ThreeRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                let normalFB = this._normalFB; let depthFB = this._depthFB
                let ssaoFB = this._ssaoFB; let blurFB = this._blurFB
                let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
                let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
                let ssaoTex = this._ssaoTex; let blurTex = this._blurTex
                let noiseTex = this._noiseTex
                if (Handle.isValid(normalFB)) { renderer.destroyFrameBuffer(normalFB) }
                if (Handle.isValid(depthFB)) { renderer.destroyFrameBuffer(depthFB) }
                if (Handle.isValid(ssaoFB)) { renderer.destroyFrameBuffer(ssaoFB) }
                if (Handle.isValid(blurFB)) { renderer.destroyFrameBuffer(blurFB) }
                if (Handle.isValid(normalTex)) { renderer.destroyTexture(normalTex) }
                if (Handle.isValid(normalDepthTex)) { renderer.destroyTexture(normalDepthTex) }
                if (Handle.isValid(depthTex)) { renderer.destroyTexture(depthTex) }
                if (Handle.isValid(depthDepthTex)) { renderer.destroyTexture(depthDepthTex) }
                if (Handle.isValid(ssaoTex)) { renderer.destroyTexture(ssaoTex) }
                if (Handle.isValid(blurTex)) { renderer.destroyTexture(blurTex) }
                if (Handle.isValid(noiseTex)) { renderer.destroyTexture(noiseTex) }
                this._normalFB = INVALID_FRAME_BUFFER_HANDLE
                this._normalTex = INVALID_TEXTURE_HANDLE
                this._normalDepthTex = INVALID_TEXTURE_HANDLE
                this._depthFB = INVALID_FRAME_BUFFER_HANDLE
                this._depthTex = INVALID_TEXTURE_HANDLE
                this._depthDepthTex = INVALID_TEXTURE_HANDLE
                this._ssaoFB = INVALID_FRAME_BUFFER_HANDLE
                this._ssaoTex = INVALID_TEXTURE_HANDLE
                this._blurFB = INVALID_FRAME_BUFFER_HANDLE
                this._blurTex = INVALID_TEXTURE_HANDLE
                this._noiseTex = INVALID_TEXTURE_HANDLE
            case None => ()
        }
    }

    // ===== 自建场景几何体 VB/IB/layout（对齐 BgfxBackend._createVB/_createIB 模式） =====

    private func _getOrCreateLayout(renderer: ThreeRenderer): VertexLayoutHandle {
        match (this._layoutHandleCache) {
            case Some(lh) => return lh
            case None => ()
        }
        // 经 renderer.createVertexLayout(attrs) 高阶 API 创建布局句柄（封装 begin/add/end/create 序列）。
        // _createVB 经 renderer.createVertexBufferFromLayout(handle) 创建顶点缓冲
        // （renderer 内部从 handle 查回 layout 内存指针，无须接触 CPointer<VertexLayout>）。
        let handle = renderer.createVertexLayout(this._getLayoutAttrs())
        this._layoutHandleCache = Some(handle)
        return handle
    }

    /** 构建顶点布局属性描述（对齐旧 begin/add/end 序列：position(3) + normal(3) + color(4) + uv(2)） */
    private func _getLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
        let normal = BgfxAttributeDesc()
        normal.attrib = Attrib.Normal.value()
        normal.num = 3u8
        normal.attribType = AttribType.Float.value()
        normal.normalized = true
        normal.asInt = false
        list.add(normal)
        let color = BgfxAttributeDesc()
        color.attrib = Attrib.Color0.value()
        color.num = 4u8
        color.attribType = AttribType.Float.value()
        color.normalized = false
        color.asInt = false
        list.add(color)
        let uv = BgfxAttributeDesc()
        uv.attrib = Attrib.TexCoord0.value()
        uv.num = 2u8
        uv.attribType = AttribType.Float.value()
        uv.normalized = false
        uv.asInt = false
        list.add(uv)
        return list.toArray()
    }

    private func _createVB(renderer: ThreeRenderer, geom: BufferGeometry): VertexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._vbCache.get(geomId)) {
            case Some(vb) => return vb
            case None => ()
        }
        let posAttrOpt = geom.getAttribute("position")
        match (posAttrOpt) {
            case Some(pos) =>
                let vc = pos.count
                if (vc == 0) { return INVALID_VERTEX_BUFFER_HANDLE }
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
                    match (normAttrOpt) {
                        case Some(na) =>
                            data[base + 3] = na.getX(vi)
                            data[base + 4] = na.getY(vi)
                            data[base + 5] = na.getZ(vi)
                        case None => data[base + 5] = 1.0
                    }
                    match (colAttrOpt) {
                        case Some(ca) =>
                            data[base + 6] = ca.getX(vi)
                            data[base + 7] = ca.getY(vi)
                            data[base + 8] = ca.getZ(vi)
                            data[base + 9] = if (ca.itemSize > 3) { ca.getW(vi) } else { 1.0 }
                        case None =>
                            for (j in 0..4) { data[base + 6 + j] = 1.0 }
                    }
                    match (uvAttrOpt) {
                        case Some(ua) =>
                            data[base + 10] = ua.getX(vi)
                            data[base + 11] = ua.getY(vi)
                        case None => ()
                    }
                }
                let mem = BgfxMemory(UInt32(totalFloats * 4))
                mem.writeFloats(data, totalFloats)
                let layout = this._getOrCreateLayout(renderer)
                let handle = renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16)
                this._vbCache.add(geomId, handle)
                return handle
            case None => return INVALID_VERTEX_BUFFER_HANDLE
        }
    }

    private func _createIB(renderer: ThreeRenderer, geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._ibCache.get(geomId)) {
            case Some(ib) => return ib
            case None => ()
        }
        match (geom.index) {
            case Some(idxAttr) =>
                let count = idxAttr.count
                if (count == 0) { return INVALID_INDEX_BUFFER_HANDLE }
                let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
                let mem = BgfxMemory(UInt32(count * 2))
                mem.writeUInt16(idxData, count)
                let handle = renderer.createIndexBuffer(mem, flags: 0u16)
                this._ibCache.add(geomId, handle)
                return handle
            case None => return INVALID_INDEX_BUFFER_HANDLE
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
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
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
        match (sceneOpt) {
            case Some(scene) => match (camOpt) {
                case Some(camera) =>
                    // 各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
                    // clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
                    // 调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
                    // 故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。
                    this._ensureRTs(renderer)
                    if (!Handle.isValid(this._normalFB)) { @LogTrace(["ssao", "render: _ensureRTs failed, normalFB invalid"]); return }

                    let baseView = SSAOPass.SSAO_VIEW_ID_BASE
                    let uniforms = this._uniforms

                    // ===== 1. 法线 pass（view+0）：normal shader 渲场景到法线 RT =====
                    this._renderNormals(renderer, scene, camera, baseView)
                    // ===== 2. 深度 pass（view+1）：depth shader 渲场景到深度 RT =====
                    this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
                    // ===== 3. SSAO 计算 pass（view+2）：全屏四边形采样法线/深度/噪声 =====
                    this._renderSSAOCalc(renderer, camera, baseView, uniforms)
                    // ===== 4. blur pass（view+3）：5x5 平均模糊遮蔽 =====
                    this._renderBlur(renderer, camera, baseView, uniforms)
                    // ===== 5. apply pass（view+4）：sceneColor × ao 写 writeBuffer/屏幕 =====
                    this._renderApply(renderer, readBuffer, writeBuffer)
                    @LogTrace(["ssao", "render: 5-pass chain done"])
                case None => ()
            }
            case None => ()
        }
    }

    /**
     * apply pass：采样 readBuffer（场景颜色）与 blur 遮蔽图（ao），输出 sceneColor × ao。
     * 对应输出阶段（copyMaterial：blur 遮蔽图混入 readBuffer 场景）。
     *
     * renderToScreen=true（最后一个 enabled pass）时目标为 swap chain（无效 FB handle），
     * 并显式 bgfx_frame 上屏（SSAO 链自身不调 renderer.render，不会经 finishRender 触发 frame）。
     */
    private func _renderApply(renderer: ThreeRenderer, readBuffer: FrameBufferHandle, writeBuffer: FrameBufferHandle): Unit {
        let viewId = UInt16(UInt16(SSAOPass.SSAO_VIEW_ID_BASE) + 4u16)
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let applyProgOpt = PostProcessingShaders.get("ssaoapply")
        match (applyProgOpt) {
            case Some(applySp) =>
                if (!Handle.isValid(Box(applySp.programHandle))) {
                    applySp.compileBgfx()
                }
                let applyProg = Box(applySp.programHandle)
                if (!Handle.isValid(applyProg)) { @LogTrace(["ssao", "apply: ssaaoapply program compile FAILED"]); return }
                @LogTrace(["ssao", "apply: prog idx=${Handle.idx(applyProg)} renderToScreen=${this.renderToScreen}"])

                let uniforms = this._uniforms
                // 场景颜色 = readBuffer 的 color attachment 0（composer 的 RGBA16F/8 RT）
                let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                @LogTrace(["ssao", "apply: readBuffer=${Handle.idx(readBuffer)} sceneTex=${Handle.idx(sceneTex)} blurTex=${Handle.idx(this._blurTex)}"])
                let uScene = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
                let uAO = uniforms.createUniform("tAO", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uAO, this._blurTex, 0u32)

                this.submitQuad(viewId, applyProg)
                // 不在此调 bgfx_frame：frame 统一由 EffectComposer.render 末尾触发
                // （bgfx_frame 是双缓冲交换，每帧仅一次；pass 只负责 submit）
            case None => @LogTrace(["ssao", "apply: ssaaoapply shader NOT REGISTERED in ShaderLibs"])
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
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x8080FFu32)

        let normalProgOpt = ShaderLibs.get("normal")
        match (normalProgOpt) {
            case Some(normalSp) =>
                if (!Handle.isValid(Box(normalSp.programHandle))) {
                    normalSp.compileBgfx()
                }
                let normalProg = Box(normalSp.programHandle)
                if (!Handle.isValid(normalProg)) { @LogTrace(["ssao", "normal prog compile failed"]); return }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                // view 矩阵 3x3（SSAO 需要 view space 法线，u_normalMatrix = mat3(view) × mat3(model)）
                let viewMtx = camera.matrixWorldInverse.elements
                let uniforms = this._uniforms
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(_) =>
                            let mtxArr = ro.worldMatrix.elements
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            renderer.setTransform(mtxMem, num: 1u16)

                            // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序，9 floats 紧凑布局）
                            // 还原 c*3+r：用户 SSR 实验验证 c*4+r (pad to vec4) 导致法线错误 →
                            //   地板/天花板视图空间法线错乱 → SSAO 遮蔽错误 / 倒影消失
                            let nmData = Array<Float64>(12, { i => 0.0 })
                            for (c in 0..3) {
                                for (r in 0..3) {
                                    var acc = 0.0
                                    for (k in 0..3) {
                                        acc += viewMtx[k * 4 + r] * mtxArr[c * 4 + k]
                                    }
                                    nmData[c * 3 + r] = acc
                                }
                            }
                            let uNormalMat = uniforms.createUniform("u_normalMatrix", UniformType.Mat3.value())
                            let nmMem = BgfxMemory(48u32)
                            nmMem.writeFloats(nmData, 12)
                            this.setUniform(renderer, uNormalMat, nmMem, num: 1u16)

                            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                            let ib = this._createIB(renderer, ro.geometry)
                            if (Handle.isValid(ib)) {
                                renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                            }
                            let normalState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                              BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                              BgfxConstants.FRONT_CCW
                            renderer.setState(normalState, rgba: 0x00000000u32)
                            renderer.submit(viewId, normalProg, depth: 0u32, blend: 0xFFu8)
                            submitCnt += 1
                        case None => ()
                    }
                }
                @LogTrace(["ssao", "normal pass submitCnt=${submitCnt}"])
            case None => @LogTrace(["ssao", "normal shader not registered"])
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
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32)

        // 用 SSAO 专用线性深度 shader（ssaodepth）：渲 viewZToOrthographicDepth 到 RGBA32F，
        // 避免 D24 硬件深度普通采样精度不足 + getViewZ far 端放大成条带。
        let depthProgOpt = PostProcessingShaders.get("ssaodepth")
        match (depthProgOpt) {
            case Some(depthSp) =>
                if (!Handle.isValid(Box(depthSp.programHandle))) {
                    depthSp.compileBgfx()
                }
                let depthProg = Box(depthSp.programHandle)
                if (!Handle.isValid(depthProg)) { @LogTrace(["ssao", "depth: ssaodepth program compile FAILED"]); return }
                @LogTrace(["ssao", "depth: ssaodepth prog idx=${Handle.idx(depthProg)}"])

                // u_cameraNearFar uniform（线性深度反投影需要 near/far）
                let uNearFar = this._uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                let nfMem = BgfxMemory(16u32)
                nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                this.setUniform(renderer, uNearFar, nfMem)

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (Handle.isValid(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let depthRenderState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                           BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                           BgfxConstants.FRONT_CCW
                    renderer.setState(depthRenderState, rgba: 0x00000000u32)
                    renderer.submit(viewId, depthProg, depth: 0u32, blend: 0xFFu8)
                }
                @LogTrace(["ssao", "depth: submitted renderObjects=${renderObjects.size}"])
            case None => @LogTrace(["ssao", "depth: ssaodepth shader NOT REGISTERED in ShaderLibs"])
        }
    }

    /**
     * SSAO 计算 pass：全屏四边形采样法线/深度/噪声纹理，输出 1-occlusion。
     */
    private func _renderSSAOCalc(renderer: ThreeRenderer, camera: Camera, baseView: UInt16, uniforms: BgfxUniforms): Unit {
        let viewId = UInt16(UInt16(baseView) + 2u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._ssaoFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let ssaoProgOpt = PostProcessingShaders.get("ssao")
        match (ssaoProgOpt) {
            case Some(ssaoSp) =>
                if (!Handle.isValid(Box(ssaoSp.programHandle))) {
                    ssaoSp.compileBgfx()
                }
                let ssaoProg = Box(ssaoSp.programHandle)
                if (!Handle.isValid(ssaoProg)) { @LogTrace(["ssao", "ssao prog compile failed"]); return }
                @LogTrace(["ssao", "ssaoCalc: prog idx=${Handle.idx(ssaoProg)} normalTex=${Handle.idx(this._normalTex)} depthTex=${Handle.idx(this._depthTex)} noiseTex=${Handle.idx(this._noiseTex)}"])

                // 采样器：stage 0=法线, 1=深度, 2=噪声
                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uNormal, this._normalTex, 0u32)
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)
                let uNoise = uniforms.createUniform("tNoise", UniformType.Sampler.value())
                this.bindTexture(renderer, 2u8, uNoise, this._noiseTex, 0u32)

                // kernel 数组 uniform（32 个 vec4）
                let uKernel = uniforms.createUniform("u_kernel", UniformType.Vec4.value(), 32u16)
                let kernelMem = BgfxMemory(UInt32(128 * 4))
                kernelMem.writeFloats(this._kernel, 128)
                this.setUniform(renderer, uKernel, kernelMem, num: 32u16)

                // resolution
                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                // cameraNear/Far
                let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                let nfMem = BgfxMemory(16u32)
                nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                this.setUniform(renderer, uNearFar, nfMem)

                // projection / inverse projection
                let uProj = uniforms.createUniform("u_projMatrix", UniformType.Mat4.value())
                let projMem = BgfxMemory(64u32)
                projMem.writeFloats(camera.projectionMatrix.elements, 16)
                this.setUniform(renderer, uProj, projMem)

                let invProj = camera.projectionMatrix.clone().invert()
                let uInvProj = uniforms.createUniform("u_invProjMatrix", UniformType.Mat4.value())
                let invMem = BgfxMemory(64u32)
                invMem.writeFloats(invProj.elements, 16)
                this.setUniform(renderer, uInvProj, invMem)

                // ssaoParams: x=kernelRadius, y=minDistance, z=maxDistance
                let uParams = uniforms.createUniform("u_ssaoParams", UniformType.Vec4.value())
                let pMem = BgfxMemory(16u32)
                pMem.writeFloats([this.kernelRadius, this.minDistance, this.maxDistance, 0.0], 4)
                this.setUniform(renderer, uParams, pMem)

                // 全屏四边形 submit
                this.submitQuad(viewId, ssaoProg)
            case None => @LogTrace(["ssao", "ssao shader not registered"])
        }
    }

    /**
     * blur pass：SSAOBlurShader 5x5 平均模糊遮蔽。
     */
    private func _renderBlur(renderer: ThreeRenderer, camera: Camera, baseView: UInt16, uniforms: BgfxUniforms): Unit {
        let viewId = UInt16(UInt16(baseView) + 3u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._blurFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let blurProgOpt = PostProcessingShaders.get("ssaoblur")
        match (blurProgOpt) {
            case Some(blurSp) =>
                if (!Handle.isValid(Box(blurSp.programHandle))) {
                    blurSp.compileBgfx()
                }
                let blurProg = Box(blurSp.programHandle)
                if (!Handle.isValid(blurProg)) { @LogTrace(["ssao", "blur: ssaoblur program compile FAILED"]); return }
                @LogTrace(["ssao", "blur: prog idx=${Handle.idx(blurProg)} ssaoTex=${Handle.idx(this._ssaoTex)}"])

                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, this._ssaoTex, 0u32)

                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                this.submitQuad(viewId, blurProg)
            case None => @LogTrace(["ssao", "blur: ssaoblur shader NOT REGISTERED in ShaderLibs"])
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（通过 renderer.setViewTransform 高阶 API）。
     */
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
        let viewArr = camera.matrixWorldInverse.toArray(Array<Float64>(16, { _ => 0.0 }))
        let projArr = camera.projectionMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
        let viewMem = BgfxMemory(64u32)
        let projMem = BgfxMemory(64u32)
        viewMem.writeFloats(viewArr, 16)
        projMem.writeFloats(projArr, 16)
        renderer.setViewTransform(viewId, viewMem, projMem)
    }

    private func _collectMeshes(obj: Object3D, renderObjects: ArrayList<RenderObject>): Unit {
        for (child in obj.children) {
            if (child.children.size > 0) {
                this._collectMeshes(child, renderObjects)
            }
            if (child.kind == "Mesh") {
                match (child as Mesh) {
                    case Some(mesh) =>
                        let ro = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                        renderObjects.add(ro)
                    case None => ()
                }
            }
        }
    }

    /** 销毁全部 GPU 资源（composer.dispose 或 renderer.shutdown 调用） */
    public override func dispose(): Unit {
        this._destroyRTs()
        // 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose
        // 释放场景几何体缓存
        match (this._renderer) {
            case Some(renderer) =>
                for ((_, vb) in this._vbCache) {
                    renderer.destroyVertexBuffer(vb)
                }
                for ((_, ib) in this._ibCache) {
                    renderer.destroyIndexBuffer(ib)
                }
                match (this._layoutHandleCache) {
                    case Some(lh) =>
                        renderer.destroyVertexLayout(lh)
                        this._layoutHandleCache = None
                    case None => ()
                }
            case None => ()
        }
        this._vbCache.clear()
        this._ibCache.clear()
    }
}
