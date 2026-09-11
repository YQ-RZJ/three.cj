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
 * @file[zh-cn] GTAOPass 地面真值环境光遮蔽（GTAO）后处理 pass
 * @brief[zh-cn] 地面真值环境光遮蔽（GTAO）后处理 pass
 * @explain[zh-cn] 以 EffectComposer Pass 链方式注入（对齐 bloom/ssao 的 Bgfx*Pass）：
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(GTAOPass(scene, camera))
 *         composer.render()
 *         render() 内部（各子方法经 Pass 基类高阶 API 调用 bgfx，高阶 API 自身走 renderer.execBgfx 序列化到渲染线程）：
 *         1. 法线 pass（view GTAO_VIEW_ID_BASE+0）：normal shader 渲场景法线到法线 RT（RGBA16F+D24）
 *         2. 深度 pass（view +1）：aodepth shader 渲场景 NDC 深度（gl_FragCoord.z）到深度 RT（RGBA32F+D24）
 *         3. GTAO 计算 pass（view +2）：全屏四边形采样法线/深度/噪声，输出 AO 到 gtao RT（RGBA16F）
 *         4. PoissonDenoise pass（view +3）：全屏四边形对 AO 图做保边降噪 → pd RT（RGBA16F）
 *         5. 输出 pass（view +4）：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）
 *         自包含：uniforms（BgfxUniforms 实例）、全屏四边形（composer 共享 quad）、
 *         场景几何体 VB/IB/layout 均在 pass 内懒创建并缓存，不依赖 BgfxBackend 内部资源
 *         （避免 bgfx_backend ↔ postprocessing 包循环依赖，对齐 UnrealBloomPass/SSAOPass 自包含模式）。
 *         噪声纹理：
 *         - gtaoNoiseTexture：magic square 噪声（generateMagicSquareNoise(5)，5x5 RGBA8，RepeatWrapping）
 *         - pdNoiseTexture：SimplexNoise 噪声（_generateNoise(64)，64x64 RGBA8，RepeatWrapping）
 *
 * @file[en] GTAOPass ground-truth ambient occlusion (GTAO) post-processing pass
 * @brief[en] Ground-truth ambient occlusion (GTAO) post-processing pass
 * @explain[en] Injected via the EffectComposer Pass chain (aligned with the Bgfx*Pass bloom/ssao style):
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(GTAOPass(scene, camera))
 *         composer.render()
 *         Inside render() (each sub-method calls bgfx via Pass base-class high-level APIs, which serialize to the render thread through renderer.execBgfx):
 *         1. Normal pass (view GTAO_VIEW_ID_BASE+0): normal shader renders scene normals to a normal RT (RGBA16F+D24)
 *         2. Depth pass (view +1): aodepth shader renders scene NDC depth (gl_FragCoord.z) to a depth RT (RGBA32F+D24)
 *         3. GTAO compute pass (view +2): full-screen quad samples normal/depth/noise, outputs AO to a gtao RT (RGBA16F)
 *         4. PoissonDenoise pass (view +3): full-screen quad edge-preserving denoise on the AO map → pd RT (RGBA16F)
 *         5. Output pass (view +4): outputs per output mode to writeBuffer (to screen when renderToScreen=true)
 *         Self-contained: uniforms (BgfxUniforms instance), full-screen quad (composer shared quad),
 *         and scene geometry VB/IB/layout are lazily created and cached inside the pass, not depending on BgfxBackend internals
 *         (avoiding a bgfx_backend ↔ postprocessing package cycle, aligned with the UnrealBloomPass/SSAOPass self-contained pattern).
 *         Noise textures:
 *         - gtaoNoiseTexture: magic square noise (generateMagicSquareNoise(5), 5x5 RGBA8, RepeatWrapping)
 *         - pdNoiseTexture: SimplexNoise noise (_generateNoise(64), 64x64 RGBA8, RepeatWrapping)
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
import three.utils.log.Logger
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.types.*
import std.collection.*
import std.math.*
import three.core.dsa.*



public class GTAOPass <: Pass {
    /** GTAO pass 用的 view ID 段约定：SSAO 160~164，GTAO 165~169，SAO 170~175，composer 分配 230+ */
    public static let GTAO_VIEW_ID_BASE: UInt16 = 165u16

    /** 输出模式（GTAOPass.OUTPUT） */
    public static let OUTPUT_OFF: Int64 = -1
    public static let OUTPUT_DEFAULT: Int64 = 0
    public static let OUTPUT_DIFFUSE: Int64 = 1
    public static let OUTPUT_DEPTH: Int64 = 2
    public static let OUTPUT_NORMAL: Int64 = 3
    public static let OUTPUT_AO: Int64 = 4
    public static let OUTPUT_DENOISE: Int64 = 5

    /** 场景/相机（法线/深度 pass 渲场景用） */
    private var _scene: Option<Scene> = None
    private var _camera: Option<Camera> = None

    // ===== RT 句柄（懒创建，setSize 或首帧时初始化） =====
    /** 法线 RT（RGBA16F，法线编码 0.5+0.5 视图空间） */
    private var _normalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _normalTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 法线 RT 的 depth attachment（D24，法线 pass 深度测试用） */
    private var _normalDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT（RGBA32F，存 NDC 深度 gl_FragCoord.z，GTAO shader 用 perspectiveDepthToViewZ 反算 viewZ） */
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT 的 depth attachment（D24，深度 pass 深度测试用） */
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** GTAO 遮蔽 RT（RGBA16F，存 ao ∈ [0,1]） */
    private var _gtaoFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _gtaoTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** PoissonDenoise 结果 RT（RGBA16F） */
    private var _pdFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _pdTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** GTAO 旋转噪声纹理（magic square，5x5 RGBA8） */
    private var _gtaoNoiseTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** PD 旋转噪声纹理（SimplexNoise，64x64 RGBA8） */
    private var _pdNoiseTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** RT 尺寸 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    // ===== 输出/参数 =====
    /** 输出模式（默认 Default=0，GTAO+Denoise 混合到场景） */
    public var output: Int64 = 0
    /** AO 混合强度（默认 1.0） */
    public var blendIntensity: Float64 = 1.0
    /** GTAO 采样半径（默认 0.25） */
    public var radius: Float64 = 0.25
    /** GTAO 距离指数（默认 1.0） */
    public var distanceExponent: Float64 = 1.0
    /** GTAO 厚度（默认 1.0） */
    public var thickness: Float64 = 1.0
    /** GTAO 距离衰减（默认 1.0） */
    public var distanceFallOff: Float64 = 1.0
    /** GTAO 遮蔽指数（默认 1.0） */
    public var scale: Float64 = 1.0
    /** PD 亮度阈值（默认 10） */
    public var lumaPhi: Float64 = 10.0
    /** PD 深度阈值（默认 2） */
    public var depthPhi: Float64 = 2.0
    /** PD 法线阈值（默认 3） */
    public var normalPhi: Float64 = 3.0
    /** PD 采样半径（默认 8） */
    public var pdRadius: Float64 = 8.0

    /** Poisson 降噪采样点（16 个 vec4，CPU 端生成） */
    private var _poissonDisk: Array<Float64> = Array<Float64>(64, { _ => 0.0 })

    /** 本 pass 自有的 uniform 注册表（对齐 UnrealBloomPass/SSAOPass 自包含模式） */
    private var _uniforms: BgfxUniforms = BgfxUniforms()

    /** 最近一次 render 注入的渲染器（setSize/dispose 销毁 GPU 资源时经 renderer 高阶 API 序列化） */
    private var _renderer: Option<ThreeRenderer> = None

    // ===== 场景几何体缓存（对齐 BgfxBackend._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /**
     * 构造：对齐 `new GTAOPass(scene, camera, width, height)`。
     * 默认输出 Default（0）；needsSwap=true（Pass 基类默认）。
     */
    public init(scene: Scene, camera: Camera) {
        super()
        this._scene = Some(scene)
        this._camera = Some(camera)
        this.needsSwap = true
        this._generatePoissonDisk()
    }

    /** 设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用） */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height) {
            this._destroyRTs()
            this._width = width
            this._height = height
            Logger.trace(["gtao", "setSize=${width}x${height}"])
        }
    }

    // ===== Poisson 采样点生成 =====

    private func _generatePoissonDisk(): Unit {
        // 默认配置：generatePdSamplePointInitializer(16,2,1)
        let samples: Int64 = 16
        let rings: Int64 = 2
        let radiusExponent: Float64 = 1.0
        for (i in 0..samples) {
            let angle = 2.0 * PI * Float64(rings) * Float64(i) / Float64(samples)
            let r = pow(Float64(i) / Float64(samples - 1), radiusExponent)
            this._poissonDisk[i * 4 + 0] = cos(angle)
            this._poissonDisk[i * 4 + 1] = sin(angle)
            this._poissonDisk[i * 4 + 2] = r
            this._poissonDisk[i * 4 + 3] = 0.0
        }
    }

    // ===== RT 创建/销毁 =====

    private func _ensureRTs(renderer: ThreeRenderer): Unit {
        if (this._width <= 0 || this._height <= 0) { return }
        if (isValidHandle(this._normalTex)) { return }

        // 法线 RT：RGBA16F + D24 depth attachment
        let normalTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._normalTex = normalTex
        let normalDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._normalDepthTex = normalDepthTex
        this._normalFB = this._createFBWithDepth(renderer, normalTex, normalDepthTex)

        // 深度 RT：RGBA32F（存 NDC 深度 gl_FragCoord.z，GTAO 用 perspectiveDepthToViewZ 反算 viewZ；
        // 全精度浮点避免 D24 硬件深度采样精度不足 + far 端非线性放大）
        let depthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA32F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._depthTex = depthTex
        let depthDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._depthDepthTex = depthDepthTex
        this._depthFB = this._createFBWithDepth(renderer, depthTex, depthDepthTex)

        // GTAO 遮蔽 RT：RGBA16F
        let gtaoTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._gtaoTex = gtaoTex
        this._gtaoFB = this._createFB(renderer, gtaoTex)

        // PD 结果 RT：RGBA16F
        let pdTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._pdTex = pdTex
        this._pdFB = this._createFB(renderer, pdTex)

        // GTAO 旋转噪声：magic square（5x5 RGBA8，RepeatWrapping）
        this._gtaoNoiseTex = this._createNoiseTexture(renderer, this._generateMagicSquareNoise(), 5u16, 5u16)
        // PD 旋转噪声：SimplexNoise（64x64 RGBA8，RepeatWrapping）
        this._pdNoiseTex = this._createNoiseTexture(renderer, this._generatePdNoiseData(), 64u16, 64u16)

        Logger.trace(["gtao", "_ensureRTs done ${this._width}x${this._height}"])
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
                let gtaoFB = this._gtaoFB; let pdFB = this._pdFB
                let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
                let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
                let gtaoTex = this._gtaoTex; let pdTex = this._pdTex
                let gtaoNoiseTex = this._gtaoNoiseTex; let pdNoiseTex = this._pdNoiseTex
                if (isValidHandle(normalFB)) { renderer.destroyFrameBuffer(normalFB) }
                if (isValidHandle(depthFB)) { renderer.destroyFrameBuffer(depthFB) }
                if (isValidHandle(gtaoFB)) { renderer.destroyFrameBuffer(gtaoFB) }
                if (isValidHandle(pdFB)) { renderer.destroyFrameBuffer(pdFB) }
                if (isValidHandle(normalTex)) { renderer.destroyTexture(normalTex) }
                if (isValidHandle(normalDepthTex)) { renderer.destroyTexture(normalDepthTex) }
                if (isValidHandle(depthTex)) { renderer.destroyTexture(depthTex) }
                if (isValidHandle(depthDepthTex)) { renderer.destroyTexture(depthDepthTex) }
                if (isValidHandle(gtaoTex)) { renderer.destroyTexture(gtaoTex) }
                if (isValidHandle(pdTex)) { renderer.destroyTexture(pdTex) }
                if (isValidHandle(gtaoNoiseTex)) { renderer.destroyTexture(gtaoNoiseTex) }
                if (isValidHandle(pdNoiseTex)) { renderer.destroyTexture(pdNoiseTex) }
                this._normalFB = INVALID_FRAME_BUFFER_HANDLE
                this._normalTex = INVALID_TEXTURE_HANDLE
                this._normalDepthTex = INVALID_TEXTURE_HANDLE
                this._depthFB = INVALID_FRAME_BUFFER_HANDLE
                this._depthTex = INVALID_TEXTURE_HANDLE
                this._depthDepthTex = INVALID_TEXTURE_HANDLE
                this._gtaoFB = INVALID_FRAME_BUFFER_HANDLE
                this._gtaoTex = INVALID_TEXTURE_HANDLE
                this._pdFB = INVALID_FRAME_BUFFER_HANDLE
                this._pdTex = INVALID_TEXTURE_HANDLE
                this._gtaoNoiseTex = INVALID_TEXTURE_HANDLE
                this._pdNoiseTex = INVALID_TEXTURE_HANDLE
            case None => ()
        }
    }

    /**
     * 创建 RGBA8 噪声纹理（RepeatWrapping）。
     * @param data RGBA8 字节数据（长度 = w*h*4）
     */
    private func _createNoiseTexture(renderer: ThreeRenderer, data: Array<UInt8>, w: UInt16, h: UInt16): TextureHandle {
        let mem = BgfxMemory(UInt32(data.size))
        mem.writeUInt8(data, Int64(data.size))
        return renderer.createTexture2D(
            w, h, false, 1u16,
            TextureFormat.RGBA8.value(),
            0u64,  // 默认 wrap = repeat
            Some(mem))
    }

    // ===== 噪声数据生成 =====

    /**
     * magic square 噪声数据（5x5 RGBA8）。
     * generateMagicSquareNoise(5) + generateMagicSquare(5)。
     */
    private func _generateMagicSquareNoise(): Array<UInt8> {
        let noiseSize: Int64 = 5
        let noiseSquareSize = noiseSize * noiseSize
        let magicSquare = this._generateMagicSquare(noiseSize)
        let data = Array<UInt8>(noiseSquareSize * 4, { _ => 0u8 })
        for (inx in 0..noiseSquareSize) {
            let iAng = magicSquare[inx]
            let angle = (2.0 * PI * Float64(iAng)) / Float64(noiseSquareSize)
            let randomVec = Vector3(cos(angle), sin(angle), 0.0).normalize()
            data[inx * 4 + 0] = UInt8((randomVec.x * 0.5 + 0.5) * 255.0)
            data[inx * 4 + 1] = UInt8((randomVec.y * 0.5 + 0.5) * 255.0)
            data[inx * 4 + 2] = 127u8
            data[inx * 4 + 3] = 255u8
        }
        return data
    }

    /** generateMagicSquare(size)：奇阶幻方生成（Siamese 方法）。 */
    private func _generateMagicSquare(size: Int64): Array<Int64> {
        let noiseSize = size
        let noiseSquareSize = noiseSize * noiseSize
        let magicSquare = Array<Int64>(noiseSquareSize, { _ => 0 })
        var i = noiseSize / 2
        var j = noiseSize - 1
        var num: Int64 = 1
        while (num <= noiseSquareSize) {
            if (i == -1 && j == noiseSize) {
                j = noiseSize - 2
                i = 0
            } else {
                if (j == noiseSize) { j = 0 }
                if (i < 0) { i = noiseSize - 1 }
            }
            if (magicSquare[i * noiseSize + j] != 0) {
                j -= 2
                i += 1
                continue
            } else {
                magicSquare[i * noiseSize + j] = num
                num += 1
            }
            j += 1
            i -= 1
        }
        return magicSquare
    }

    /**
     * PD 旋转噪声数据（64x64 RGBA8，SimplexNoise 四通道）。
     * simplex.noise(x, y)/(x+size, y)/(x, y+size)/(x+size, y+size)。
     */
    private func _generatePdNoiseData(): Array<UInt8> {
        let size: Int64 = 64
        let arraySize = size * size * 4
        let data = Array<UInt8>(arraySize, { _ => 0u8 })
        let simplex = SimplexNoise()
        for (i in 0..size) {
            for (j in 0..size) {
                let x = Float64(i)
                let y = Float64(j)
                data[(i * size + j) * 4 + 0] = UInt8((simplex.noise(x, y) * 0.5 + 0.5) * 255.0)
                data[(i * size + j) * 4 + 1] = UInt8((simplex.noise(x + Float64(size), y) * 0.5 + 0.5) * 255.0)
                data[(i * size + j) * 4 + 2] = UInt8((simplex.noise(x, y + Float64(size)) * 0.5 + 0.5) * 255.0)
                data[(i * size + j) * 4 + 3] = UInt8((simplex.noise(x + Float64(size), y + Float64(size)) * 0.5 + 0.5) * 255.0)
            }
        }
        return data
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
     * Pass.render 入口：执行 GTAO 链并输出遮蔽应用到场景。
     *
     * 流程：
     *   1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. GTAO 计算（view+2）→
     *   4. PoissonDenoise（view+3）→ 5. 输出（view+4）：按 output 模式写 writeBuffer/屏幕
     *
     * 各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
     * clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
     * 调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
     * 故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。
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
                    this._ensureRTs(renderer)
                    if (!isValidHandle(this._normalFB)) { Logger.trace(["gtao", "render: _ensureRTs failed, normalFB invalid"]); return }

                    let baseView = GTAOPass.GTAO_VIEW_ID_BASE
                    let uniforms = this._uniforms

                    // ===== 1. 法线 pass（view+0）：normal shader 渲场景到法线 RT =====
                    this._renderNormals(renderer, scene, camera, baseView)
                    // ===== 2. 深度 pass（view+1）：aodepth shader 渲 NDC 深度到深度 RT =====
                    this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
                    // ===== 3. GTAO 计算 pass（view+2）：全屏四边形采样法线/深度/噪声 =====
                    this._renderGTAOCalc(renderer, camera, UInt16(UInt16(baseView) + 2u16), uniforms)
                    // ===== 4. PoissonDenoise pass（view+3）：保边降噪 AO =====
                    this._renderPD(renderer, camera, UInt16(UInt16(baseView) + 3u16), uniforms)
                    // ===== 5. 输出 pass（view+4）：按 output 模式写 writeBuffer/屏幕 =====
                    this._renderOutput(renderer, readBuffer, writeBuffer, UInt16(UInt16(baseView) + 4u16))
                    Logger.trace(["gtao", "render: 5-pass chain done"])
                case None => ()
            }
            case None => ()
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
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x8080FFu32, depth: 1.0f32, stencil: 0u8)

        let normalProgOpt = ShaderLibs.get("normal")
        match (normalProgOpt) {
            case Some(normalSp) =>
                if (!isValidHandle(Box(normalSp.programHandle))) {
                    normalSp.compileBgfx()
                }
                let normalProg = Box(normalSp.programHandle)
                if (!isValidHandle(normalProg)) { Logger.trace(["gtao", "normal prog compile failed"]); return }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                // view 矩阵 3x3（法线 RT 需要 view space 法线，u_normalMatrix = mat3(view) × mat3(model)）
                let viewMtx = camera.matrixWorldInverse.elements
                let uniforms = this._uniforms
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(_) =>
                            let mtxArr = ro.worldMatrix.elements
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            renderer.setTransform(mtxMem, num: 1u16)

                            // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序 → 紧凑 9 floats）
                            // 用户仓颉 SSR 实验验证：PostProcessingShaders 自定义 shader 中
                            //   mat3 uniform 实际按紧凑 9 float 读取（每列不 pad 到 vec4），
                            //   故必须用 c*3+r 紧凑布局（主渲染器 BgfxBackend 的 vec4 pad 格式在这里会错位）。
                            // 仓颉 0..3 = 0,1,2（不包含 3），不会迭代第 4 列/行，无越界。
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
                            this.setUniform(renderer, uNormalMat, nmMem)

                            //  补：normalFS 用 u_opacity 写 alpha（vec4(u_opacity.rgb, u_opacity.x)），
                            //  未设置时 alpha=0；法线 RT 采样只用 rgb，但补齐保持材质语义（opacity=1）
                            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                            let oMem = BgfxMemory(16u32)
                            oMem.writeFloats([1.0, 1.0, 1.0, 1.0], 4)
                            this.setUniform(renderer, uOpacity, oMem)

                            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                            let ib = this._createIB(renderer, ro.geometry)
                            if (isValidHandle(ib)) {
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
                Logger.trace(["gtao", "normal pass submitCnt=${submitCnt}"])
            case None => Logger.trace(["gtao", "normal shader not registered"])
        }
    }

    /**
     * 深度 pass：aodepth shader 渲场景到深度 RT（写 gl_FragCoord.z = NDC 深度）。
     * 用 RGBA32F 深度 RT 存 gl_FragCoord.z，GTAO shader 经 perspectiveDepthToViewZ 反算 viewZ。
     */
    private func _renderDepth(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为白色（NDC 深度=1.0）：背景无片元时颜色保持 1.0，GTAO shader 用 depth>=1.0 跳过背景
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let depthProgOpt = PostProcessingShaders.get("aodepth")
        match (depthProgOpt) {
            case Some(depthSp) =>
                if (!isValidHandle(Box(depthSp.programHandle))) {
                    depthSp.compileBgfx()
                }
                let depthProg = Box(depthSp.programHandle)
                if (!isValidHandle(depthProg)) { Logger.trace(["gtao", "depth: aodepth program compile FAILED"]); return }
                Logger.trace(["gtao", "depth: aodepth prog idx=${handleIdx(depthProg)}"])

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (isValidHandle(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let depthRenderState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                           BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                           BgfxConstants.FRONT_CCW
                    renderer.setState(depthRenderState, rgba: 0x00000000u32)
                    renderer.submit(viewId, depthProg, depth: 0u32, blend: 0xFFu8)
                }
                Logger.trace(["gtao", "depth: submitted renderObjects=${renderObjects.size}"])
            case None => Logger.trace(["gtao", "depth: aodepth shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * GTAO 计算 pass：全屏四边形采样法线/深度/噪声纹理，输出 ao。
     * gtao shader（SAMPLES=16, DIRECTIONS=3, STEPS=6）。
     */
    private func _renderGTAOCalc(renderer: ThreeRenderer, camera: Camera, viewId: UInt16, uniforms: BgfxUniforms): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._gtaoFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let gtaoProgOpt = PostProcessingShaders.get("gtao")
        match (gtaoProgOpt) {
            case Some(gtaoSp) =>
                if (!isValidHandle(Box(gtaoSp.programHandle))) {
                    gtaoSp.compileBgfx()
                }
                let gtaoProg = Box(gtaoSp.programHandle)
                if (!isValidHandle(gtaoProg)) { Logger.trace(["gtao", "gtao prog compile failed"]); return }
                Logger.trace(["gtao", "gtaoCalc: prog idx=${handleIdx(gtaoProg)} normalTex=${handleIdx(this._normalTex)} depthTex=${handleIdx(this._depthTex)} noiseTex=${handleIdx(this._gtaoNoiseTex)}"])

                // 采样器：stage 0=法线, 1=深度, 2=噪声
                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uNormal, this._normalTex, 0u32)
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)
                let uNoise = uniforms.createUniform("tNoise", UniformType.Sampler.value())
                this.bindTexture(renderer, 2u8, uNoise, this._gtaoNoiseTex, 0u32)

                // resolution
                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                // noiseResolution（magic square 5x5）
                let uNoiseRes = uniforms.createUniform("u_noiseResolution", UniformType.Vec4.value())
                let nrMem = BgfxMemory(16u32)
                nrMem.writeFloats([5.0, 5.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uNoiseRes, nrMem)

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

                // gtaoParams: x=radius, y=distanceExponent, z=thickness, w=distanceFallOff
                let uParams = uniforms.createUniform("u_gtaoParams", UniformType.Vec4.value())
                let pMem = BgfxMemory(16u32)
                pMem.writeFloats([this.radius, this.distanceExponent, this.thickness, this.distanceFallOff], 4)
                this.setUniform(renderer, uParams, pMem)

                // scale
                let uScale = uniforms.createUniform("u_scale", UniformType.Vec4.value())
                let sMem = BgfxMemory(16u32)
                sMem.writeFloats([this.scale, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uScale, sMem)

                // 全屏四边形 submit
                this.submitQuad(viewId, gtaoProg)
            case None => Logger.trace(["gtao", "gtao shader not registered"])
        }
    }

    /**
     * PoissonDenoise pass：全屏四边形对 gtao AO 图做保边降噪。
     * gtaopd shader（SAMPLES=16, poisson disk 数组 uniform）。
     */
    private func _renderPD(renderer: ThreeRenderer, camera: Camera, viewId: UInt16, uniforms: BgfxUniforms): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._pdFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let pdProgOpt = PostProcessingShaders.get("gtaopd")
        match (pdProgOpt) {
            case Some(pdSp) =>
                if (!isValidHandle(Box(pdSp.programHandle))) {
                    pdSp.compileBgfx()
                }
                let pdProg = Box(pdSp.programHandle)
                if (!isValidHandle(pdProg)) { Logger.trace(["gtao", "pd: gtaopd program compile FAILED"]); return }
                Logger.trace(["gtao", "pd: prog idx=${handleIdx(pdProg)} gtaoTex=${handleIdx(this._gtaoTex)} pdNoiseTex=${handleIdx(this._pdNoiseTex)}"])

                // 采样器：stage 0=tDiffuse(gtao AO 图), 1=tNormal, 2=tDepth, 3=tNoise(pd 噪声)
                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, this._gtaoTex, 0u32)
                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uNormal, this._normalTex, 0u32)
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 2u8, uDepth, this._depthTex, 0u32)
                let uNoise = uniforms.createUniform("tNoise", UniformType.Sampler.value())
                this.bindTexture(renderer, 3u8, uNoise, this._pdNoiseTex, 0u32)

                // resolution
                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                // noiseResolution（pd 噪声 64x64）
                let uNoiseRes = uniforms.createUniform("u_noiseResolution", UniformType.Vec4.value())
                let nrMem = BgfxMemory(16u32)
                nrMem.writeFloats([64.0, 64.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uNoiseRes, nrMem)

                // inverse projection
                let invProj = camera.projectionMatrix.clone().invert()
                let uInvProj = uniforms.createUniform("u_invProjMatrix", UniformType.Mat4.value())
                let invMem = BgfxMemory(64u32)
                invMem.writeFloats(invProj.elements, 16)
                this.setUniform(renderer, uInvProj, invMem)

                // pdParams: x=lumaPhi, y=depthPhi, z=normalPhi, w=radius
                let uParams = uniforms.createUniform("u_pdParams", UniformType.Vec4.value())
                let pMem = BgfxMemory(16u32)
                pMem.writeFloats([this.lumaPhi, this.depthPhi, this.normalPhi, this.pdRadius], 4)
                this.setUniform(renderer, uParams, pMem)

                // poisson disk 数组 uniform（16 个 vec4）
                let uDisk = uniforms.createUniform("u_poissonDisk", UniformType.Vec4.value(), 16u16)
                let diskMem = BgfxMemory(UInt32(64 * 4))
                diskMem.writeFloats(this._poissonDisk, 64)
                this.setUniform(renderer, uDisk, diskMem, num: 16u16)

                // 全屏四边形 submit
                this.submitQuad(viewId, pdProg)
            case None => Logger.trace(["gtao", "pd: gtaopd shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * 输出 pass：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）。
     * 对应 output 的 switch 分支：
     *   - Default：gtaoapply（sceneColor × mix(1, ao, intensity)，合并 copy+blend 两步）
     *   - Diffuse/AO/Denoise/Normal：copy shader 直接透传对应纹理
     *   - Depth：gtaodepth shader（1.0 - 线性深度可视化）
     *   - Off：不输出（保持 readBuffer）
     */
    private func _renderOutput(renderer: ThreeRenderer, readBuffer: FrameBufferHandle, writeBuffer: FrameBufferHandle, viewId: UInt16): Unit {
        if (this.output == GTAOPass.OUTPUT_OFF) {
            return
        }
        // 目标：renderToScreen（最后一个 enabled pass）→ swap chain（无效 FB handle）；否则 writeBuffer
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let uniforms = this._uniforms

        // Depth 模式：gtaodepth shader（tDepth + cameraNearFar）
        if (this.output == GTAOPass.OUTPUT_DEPTH) {
            let depthProgOpt = PostProcessingShaders.get("gtaodepth")
            match (depthProgOpt) {
                case Some(depthSp) =>
                    if (!isValidHandle(Box(depthSp.programHandle))) {
                        depthSp.compileBgfx()
                    }
                    let depthProg = Box(depthSp.programHandle)
                    if (!isValidHandle(depthProg)) { Logger.trace(["gtao", "output depth: gtaodepth compile FAILED"]); return }
                    let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                    this.bindTexture(renderer, 0u8, uDepth, this._depthTex, 0u32)
                    match (this._camera) {
                        case Some(camera) =>
                            let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                            let nfMem = BgfxMemory(16u32)
                            nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                            this.setUniform(renderer, uNearFar, nfMem)
                        case None => ()
                    }
                    this.submitQuad(viewId, depthProg)
                case None => Logger.trace(["gtao", "output depth: gtaodepth shader NOT REGISTERED"])
            }
            return
        }

        // Default 模式：gtaoapply（sceneColor × mix(1, ao, intensity)）
        if (this.output == GTAOPass.OUTPUT_DEFAULT) {
            let applyProgOpt = PostProcessingShaders.get("gtaoapply")
            match (applyProgOpt) {
                case Some(applySp) =>
                    if (!isValidHandle(Box(applySp.programHandle))) {
                        applySp.compileBgfx()
                    }
                    let applyProg = Box(applySp.programHandle)
                    if (!isValidHandle(applyProg)) { Logger.trace(["gtao", "output default: gtaoapply compile FAILED"]); return }
                    let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                    let uScene = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                    this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
                    let uAO = uniforms.createUniform("tAO", UniformType.Sampler.value())
                    this.bindTexture(renderer, 1u8, uAO, this._pdTex, 0u32)
                    let uIntensity = uniforms.createUniform("u_intensity", UniformType.Vec4.value())
                    let iMem = BgfxMemory(16u32)
                    iMem.writeFloats([this.blendIntensity, 0.0, 0.0, 0.0], 4)
                    this.setUniform(renderer, uIntensity, iMem)
                    Logger.trace(["gtao", "output default: sceneTex=${handleIdx(sceneTex)} pdTex=${handleIdx(this._pdTex)}"])
                    this.submitQuad(viewId, applyProg)
                case None => Logger.trace(["gtao", "output default: gtaoapply shader NOT REGISTERED"])
            }
            return
        }

        // Diffuse/AO/Denoise/Normal：copy shader 透传对应纹理
        var srcTex: TextureHandle = this._pdTex
        if (this.output == GTAOPass.OUTPUT_DIFFUSE) {
            srcTex = this.getTexture(renderer, readBuffer, 0u8)
        } else if (this.output == GTAOPass.OUTPUT_AO) {
            srcTex = this._gtaoTex
        } else if (this.output == GTAOPass.OUTPUT_NORMAL) {
            srcTex = this._normalTex
        }
        let copyProgOpt = PostProcessingShaders.get("copy")
        match (copyProgOpt) {
            case Some(copySp) =>
                if (!isValidHandle(Box(copySp.programHandle))) {
                    copySp.compileBgfx()
                }
                let copyProg = Box(copySp.programHandle)
                if (!isValidHandle(copyProg)) { Logger.trace(["gtao", "output copy: copy compile FAILED"]); return }
                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, srcTex, 0u32)
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let oMem = BgfxMemory(16u32)
                oMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, oMem)
                Logger.trace(["gtao", "output copy: output=${this.output} srcTex=${handleIdx(srcTex)}"])
                this.submitQuad(viewId, copyProg)
            case None => Logger.trace(["gtao", "output copy: copy shader NOT REGISTERED"])
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（改用 renderer.setViewTransform 高阶 API）。
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
