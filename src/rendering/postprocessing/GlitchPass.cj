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
 * @file[zh-cn] GlitchPass 数字故障后处理 pass
 * @brief[zh-cn] 数字故障后处理 pass —— 行/列块扭曲 + RGB 通道偏移 + snow 噪声
 * @explain[zh-cn] 算法（DigitalGlitch 逐行对齐非简化移植）：
 *         1. disp = texture2D(tDisp, p*seed*seed).r       // 数字方块位移贴图（DataTexture）
 *         2. 行块扭曲：if(p.y<distortion_x+col_s && p.y>distortion_x-col_s*seed)
 *           → 按 seed_x 正负决定 p.y = 1-(p.y+distortion_y) 或 p.y = distortion_y
 *         3. 列块扭曲：if(p.x<distortion_y+col_s && p.x>distortion_y-col_s*seed)
 *           → 按 seed_y 正负决定 p.x = distortion_x 或 p.x = 1-(p.x+distortion_x)
 *         4. 位移叠加：p.x += disp*seed_x*(seed/5.); p.y += disp*seed_y*(seed/5.)
 *         5. RGB shift：offset = amount * vec2(cos(angle), sin(angle))
 *           cr = texture2D(tDiffuse, p + offset); cb = texture2D(tDiffuse, p - offset)
 *           gl_FragColor = vec4(cr.r, cga.g, cb.b, cga.a)
 *         6. snow 噪声：gl_FragColor += 200.*amount*vec4(rand(xs*seed, ys*seed*50.)*0.2)
 *         7. byp>=1 时直接 texture2D(tDiffuse, vUv) 透传（无 glitch）
 *         流程：
 *         - 每帧 seed = random()（驱动 disp 采样位置 + snow 噪声动态变化）
 *         - 触发器机制：_curF 帧计数器 % _randX（120~240 帧间隔）
 *           + 触发帧：重新随机 amount/angle/seed_x/seed_y/distortion_x/distortion_y，
 *             重置 _curF=0，_generateTrigger() 生成下一个 _randX
 *           + 触发后 1/5 周期内（_curF % _randX < _randX/5）：
 *             amount=random()/90（弱 glitch），持续刷新扭曲参数
 *           + 其余帧：若 goWild=false 设 byp=1（透传），goWild=true 持续触发
 *         - 单遍全屏 pass：readBuffer.color0 → tDiffuse → glitch 处理 → writeBuffer（或屏幕）
 *         渲染差异：
 *         - 用一个 ShaderMaterial + FullScreenQuad；bgfx 复用 PostProcessingShaders.get("glitch")
 *           shader program，经共享 FullScreenQuad submit。
 *         - uniform 是 float/int；bgfx uniform 最小单位 vec4，故用 u_xxx(vec4: x=value)
 *           byp 是 int → 用 vec4.x 表示（shader 内 u_byp.x >= 0.5 视为 byp=1）
 *         - tDiffuse/tDisp 是 sampler2D；bgfx 用 SAMPLER2D 宏声明，
 *           tDiffuse 绑 stage 0（readBuffer.color0），tDisp 绑 stage 1（_heightMap 纹理）。
 *         - DataTexture 用 Float32Array + RedFormat + FloatType；bgfx 用 R8 纹理
 *           （单通道 8 位，足够 0~1 位移值），bgfx_create_texture_2d_cj 上传 RGBA8 数据
 *           （仅 r 通道有意义）。
 *         - bgfx view id 全局稀缺，本 pass 用 GLITCH_VIEW_ID_BASE=225（避开既有硬编码段：
 *           SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
 *           SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224）。
 *         用法：
 *         let glitchPass = GlitchPass(dt_size: 64)
 *         composer.addPass(glitchPass)
 *
 * @file[en] GlitchPass digital glitch post-processing pass
 * @brief[en] Digital glitch post-processing pass - row/column block distortion + RGB channel
 *         shift + snow noise
 * @explain[en] Algorithm (line-by-line non-simplified port of the DigitalGlitch fragment shader):
 *         1. disp = texture2D(tDisp, p*seed*seed).r       // digital block displacement map (DataTexture)
 *         2. Row block distortion: if(p.y<distortion_x+col_s && p.y>distortion_x-col_s*seed)
 *           → p.y = 1-(p.y+distortion_y) or p.y = distortion_y depending on the sign of seed_x
 *         3. Column block distortion: if(p.x<distortion_y+col_s && p.x>distortion_y-col_s*seed)
 *           → p.x = distortion_x or p.x = 1-(p.x+distortion_x) depending on the sign of seed_y
 *         4. Displacement accumulation: p.x += disp*seed_x*(seed/5.); p.y += disp*seed_y*(seed/5.)
 *         5. RGB shift: offset = amount * vec2(cos(angle), sin(angle))
 *           cr = texture2D(tDiffuse, p + offset); cb = texture2D(tDiffuse, p - offset)
 *           gl_FragColor = vec4(cr.r, cga.g, cb.b, cga.a)
 *         6. Snow noise: gl_FragColor += 200.*amount*vec4(rand(xs*seed, ys*seed*50.)*0.2)
 *         7. If byp>=1 directly pass through texture2D(tDiffuse, vUv) (no glitch)
 *         Flow:
 *         - Every frame seed = random() (drives the disp sample position + snow noise dynamics)
 *         - Trigger mechanism: _curF frame counter % _randX (120-240 frame interval)
 *           + On trigger frame: re-randomize amount/angle/seed_x/seed_y/distortion_x/distortion_y,
 *             reset _curF=0, call _generateTrigger() for the next _randX
 *           + Within the 1/5 period after trigger (_curF % _randX < _randX/5):
 *             amount=random()/90 (weak glitch), keep refreshing distortion params
 *           + Otherwise: if goWild=false set byp=1 (pass through), goWild=true keeps triggering
 *         - Single full-screen pass: readBuffer.color0 → tDiffuse → glitch → writeBuffer (or screen)
 *         Rendering differences:
 *         - One ShaderMaterial + FullScreenQuad; bgfx reuses the PostProcessingShaders.get("glitch")
 *           shader program submitted through the shared FullScreenQuad.
 *         - uniforms are float/int; bgfx uniforms have a minimum vec4 unit, so u_xxx (vec4: x=value)
 *           is used; byp is an int → represented by vec4.x (in the shader u_byp.x >= 0.5 means byp=1)
 *         - tDiffuse/tDisp are sampler2D; bgfx declares them with the SAMPLER2D macro,
 *           tDiffuse bound to stage 0 (readBuffer.color0), tDisp bound to stage 1 (_heightMap texture).
 *         - DataTexture uses Float32Array + RedFormat + FloatType; bgfx uses an R8 texture
 *           (single 8-bit channel, sufficient for 0~1 displacement), bgfx_create_texture_2d_cj uploads
 *           RGBA8 data (only the r channel is meaningful).
 *         - bgfx view ids are globally scarce; this pass uses GLITCH_VIEW_ID_BASE=225 (avoiding existing
 *           hardcoded ranges: SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 / TAA 219~220 /
 *           Afterimage 221~223 / FilmPass 224).
 *         Usage:
 *         let glitchPass = GlitchPass(dt_size: 64)
 *         composer.addPass(glitchPass)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.types.*
import std.math.*

/**
 * @brief[zh-cn] 数字故障后处理 pass
 * @brief[en] Digital glitch post-processing pass
 * @explain[zh-cn] 单遍全屏 pass，无内部 ping-pong RT（纯像素处理 + 位移贴图采样）。
 * @explain[en] Single full-screen pass with no internal ping-pong RT (pure pixel processing +
 *         displacement map sampling).
 */
public class GlitchPass <: Pass {
    /**
     * @brief[zh-cn] 位移贴图尺寸（像素，正方形）
     * @brief[en] Displacement map size (pixels, square)
     * @explain[zh-cn] 默认 64。
     * @explain[en] Default 64.
     */
    public let dtSize: Int64

    /**
     * @brief[zh-cn] 是否显著增强 glitch 效果
     * @brief[en] Whether to significantly intensify the glitch effect
     * @explain[zh-cn] false = 周期性弱 glitch，true = 持续强 glitch。
     * @explain[en] false = periodic weak glitch, true = sustained strong glitch.
     */
    public var goWild: Bool = false

    /**
     * LCG 伪随机种子（确定性，避免 std.random 状态问题，对照 SSAOPass._rand 范式）。
     */
    private var _seed: Int64 = 12345

    /**
     * 当前帧计数器（驱动触发器机制）。
     */
    private var _curF: Int64 = 0

    /**
     * 下一次 glitch 触发的帧间隔（120~240 帧随机）。
     */
    private var _randX: Int64 = 0

    /**
     * 位移贴图纹理句柄（DataTexture，dtSize×dtSize，单通道 0~1 随机值）。
     */
    private var _heightMap: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 位移贴图是否已创建（避免重复创建/泄漏）。
     */
    private var _heightMapCreated: Bool = false

    /**
     * glitch shader 是否已编译。
     */
    private var _glitchCompiled: Bool = false

    /**
     * glitch program handle 缓存。
     */
    private var _glitchProg: Option<ProgramHandle> = None

    /**
     * 渲染器引用（onAttach/render 时缓存，dispose 经其高阶 API 序列化）。
     */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: glitch pass（扭曲 + RGB shift + snow）
     * 取 225 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
     * TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
     * TAA 219~220 / Afterimage 221~223 / FilmPass 224。
     */
    public static let GLITCH_VIEW_ID_BASE: UInt16 = 225u16

    /**
     * 构造 GlitchPass。
     *
     * @param dtSize 位移贴图尺寸（默认 64）
     */
    public init(dt_size!: Int64 = 64) {
        super()
        this.dtSize = dt_size
        // needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
        // 初始化触发器（生成首个 _randX）
        this._generateTrigger()
        Logger.trace(["glitch", "GlitchPass constructed: dtSize=" + dtSize.toString() +
                      " randX=" + _randX.toString()])
    }

    /**
     * 挂载到 composer 时的钩子。
     * 在此创建位移贴图（bgfx 调用须在渲染线程，onAttach 由 addPass 触发）。
     *
     * @param composer 挂载的 EffectComposer
     */
    public override func onAttach(composer: EffectComposer): Unit {
        if (this._heightMapCreated) {
            return
        }
        // 在渲染线程创建位移贴图（renderer 高阶 API 自身经 execBgfx 序列化）
        this._renderer = Some(composer.renderer)
        this._heightMap = this._generateHeightmap(composer.renderer, this.dtSize)
        this._heightMapCreated = true
        Logger.trace(["glitch", "heightMap created: handle.idx=" +
                      handleIdx(this._heightMap).toString() +
                      " size=" + this.dtSize.toString()])
    }

    /**
     * 设置 pass 尺寸。
     * GlitchPass 无内部 RT，尺寸仅用于视口记录。
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        // GlitchPass 无内部 RT，无需重建资源
        Logger.trace(["glitch", "setSize: " + width.toString() + "x" + height.toString() +
                      " (no internal RT)"])
    }

    /**
     * 编译 glitch shader。
     */
    private func _compileGlitch(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("glitch")) {
            case Some(sp) =>
                if (!this._glitchCompiled) {
                    sp.compileBgfx()
                    this._glitchProg = Some(Box(sp.programHandle))
                    this._glitchCompiled = true
                    Logger.trace(["glitch", "glitch shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._glitchProg
            case None =>
                Logger.trace(["glitch", "glitch shader not registered"])
                return None
        }
    }

    /**
     * 生成下一次 glitch 触发的帧间隔（120~240 帧）。
     */
    private func _generateTrigger(): Unit {
        // randInt(120, 240)：[120, 240] 闭区间随机整数
        let range = 240 - 120 + 1
        this._randX = 120 + Int64(this._rand() * Float64(range))
        Logger.trace(["glitch", "_generateTrigger: next glitch at frame +" +
                      this._randX.toString()])
    }

    /**
     * 生成位移贴图（dtSize×dtSize 单通道 0~1 随机值）。
     *   数据：每元素 0~1 随机数，构造 DataTexture（单通道 + FloatType），needsUpdate=true
     *
     * bgfx 适配：
     *   - 用 R8 纹理（单通道 8 位，足够 0~1 位移值；FloatType 在 bgfx 中需 R32F 支持，
     *     R8 更通用且节省内存）
     *   - 数据用 RGBA8 打包（仅 r 通道有意义，g/b/a=0），shader 内 texture2D(...).r 取值
     *   - 采样器用 POINT 过滤（位移贴图无需插值），U/V CLAMP 避免边缘缠绕
     *
     * @param dtSize 位移贴图尺寸（像素，正方形）
     * @return 位移贴图纹理句柄
     */
    private func _generateHeightmap(renderer: ThreeRenderer, dtSize: Int64): TextureHandle {
        let size = UInt16(dtSize)
        let totalPixels = Int64(dtSize) * Int64(dtSize)

        // 生成 RGBA8 数据（每像素 4 字节，r=随机 0~255，g/b/a=0）
        let dataSize = UInt32(totalPixels * 4)
        let dataMem = BgfxMemory(dataSize)
        let dataPtr = dataMem.data()
        unsafe {
            for (i in 0..totalPixels) {
                let offset = i * 4
                // randFloat(0, 1) → 0~255 uint8
                let val = UInt8(this._rand() * 255.0)
                (dataPtr + offset).write(val)      // r
                (dataPtr + offset + 1).write(0u8)  // g
                (dataPtr + offset + 2).write(0u8)  // b
                (dataPtr + offset + 3).write(255u8) // a（不透明）
            }
        }

        // 创建 R8 纹理（bgfx TextureFormat.R8 = 单通道 8 位）
        // flags: POINT 过滤 + U/V CLAMP（位移贴图无需插值，避免边缘缠绕）
        let texFlags: UInt64 = UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) |
                               UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT)
        // 用 renderer.createTexture2D 上传（数据已在 dataMem 中，直接传 Some 包装）
        let tex = renderer.createTexture2D(size, size, false, 1u16,
                                             TextureFormat.RGBA8.value(),
                                             texFlags, Some(dataMem))
        Logger.trace(["glitch", "_generateHeightmap: " + dtSize.toString() + "x" +
                      dtSize.toString() + " tex.idx=" + handleIdx(tex).toString()])
        return tex
    }

    /**
     * 执行 glitch pass。
     *
     * 流程：
     *   1. seed = random()（每帧新种子）
     *   2. byp = 0（默认应用 glitch）
     *   3. 触发器机制：
     *      - 触发帧（_curF % _randX == 0）或 goWild：
     *        amount = random/30, angle = randFloat(-π, π),
     *        seed_x = randFloat(-1,1), seed_y = randFloat(-1,1),
     *        distortion_x = randFloat(0,1), distortion_y = randFloat(0,1)
     *        _curF = 0, _generateTrigger()
     *      - 触发后 1/5 周期（_curF % _randX < _randX/5）：
     *        amount = random/90（弱 glitch），刷新扭曲参数
     *      - 其余帧 + goWild=false：byp = 1（透传）
     *   4. 绑定 tDiffuse = readBuffer.color0（stage 0）
     *   5. 绑定 tDisp = _heightMap（stage 1）
     *   6. 设置 9 个 uniforms（byp/amount/angle/seed/seed_x/seed_y/distortion_x/distortion_y/col_s）
     *   7. 全屏 quad submit（覆盖写 state）
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 的输出目标）
     * @param readBuffer 读 buffer（上一 pass 结果，绑到 tDiffuse）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        let viewId = UInt16(GlitchPass.GLITCH_VIEW_ID_BASE + 0u16)

        // 视口 = 渲染器尺寸（全屏 pass）
        let w = UInt16(renderer.width)
        let h = UInt16(renderer.height)
        this.setViewport(renderer, viewId, 0u16, 0u16, w, h)

        // renderToScreen=true 时写 swap chain（无效 FB handle），否则写 writeBuffer
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        match (this._compileGlitch()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) {
                    Logger.trace(["glitch", "glitch prog invalid, skip"])
                    return
                }

                // ========================================
                // 触发器机制
                // ========================================
                let seed: Float64 = this._rand()  // 每帧新种子
                var byp: Float64 = 0.0             // 默认应用 glitch
                // glitch 参数（本帧用）
                var amount: Float64 = 0.08
                var angle: Float64 = 0.02
                var seedX: Float64 = 0.02
                var seedY: Float64 = 0.02
                var distortionX: Float64 = 0.5
                var distortionY: Float64 = 0.6
                let colS: Float64 = 0.05           // 块宽阈值（DigitalGlitch 默认 0.05）

                // 触发帧：_curF % _randX == 0 或 goWild=true
                if (this._randX > 0 && this._curF % this._randX == 0 || this.goWild) {
                    amount = this._rand() / 30.0
                    angle = randFloat(-3.141592653589793, 3.141592653589793)
                    seedX = randFloat(-1.0, 1.0)
                    seedY = randFloat(-1.0, 1.0)
                    distortionX = randFloat(0.0, 1.0)
                    distortionY = randFloat(0.0, 1.0)
                    this._curF = 0
                    this._generateTrigger()
                    Logger.trace(["glitch", "TRIGGER frame: amount=" + amount.toString() +
                                  " angle=" + angle.toString() +
                                  " seedX=" + seedX.toString() +
                                  " seedY=" + seedY.toString() +
                                  " distX=" + distortionX.toString() +
                                  " distY=" + distortionY.toString()])
                } else if (this._randX > 0 && this._curF % this._randX < this._randX / 5) {
                    // 触发后 1/5 周期：弱 glitch
                    amount = this._rand() / 90.0
                    angle = randFloat(-3.141592653589793, 3.141592653589793)
                    distortionX = randFloat(0.0, 1.0)
                    distortionY = randFloat(0.0, 1.0)
                    seedX = randFloat(-0.3, 0.3)
                    seedY = randFloat(-0.3, 0.3)
                    Logger.trace(["glitch", "weak glitch: amount=" + amount.toString() +
                                  " curF=" + this._curF.toString() +
                                  " randX=" + this._randX.toString()])
                } else if (!this.goWild) {
                    // 其余帧 + goWild=false：透传
                    byp = 1.0
                    Logger.trace(["glitch", "bypass frame: curF=" + this._curF.toString() +
                                  " randX=" + this._randX.toString()])
                }

                this._curF++

                // ========================================
                // 绑定纹理 + 设置 uniforms
                // ========================================
                let uniforms = BgfxUniforms()

                // stage 0 = tDiffuse（readBuffer 的 color 0）
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let diffuseTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uDiffuse, diffuseTex, 0u32)

                // stage 1 = tDisp（位移贴图 _heightMap）
                let uDisp = uniforms.createUniform("tDisp", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDisp, this._heightMap, 0u32)

                // 设置 9 个 uniforms（bgfx 最小单位 vec4，x=value）
                this.setUniformVec4(renderer, uniforms, "u_byp", byp)
                this.setUniformVec4(renderer, uniforms, "u_amount", amount)
                this.setUniformVec4(renderer, uniforms, "u_angle", angle)
                this.setUniformVec4(renderer, uniforms, "u_seed", seed)
                this.setUniformVec4(renderer, uniforms, "u_seed_x", seedX)
                this.setUniformVec4(renderer, uniforms, "u_seed_y", seedY)
                this.setUniformVec4(renderer, uniforms, "u_distortion_x", distortionX)
                this.setUniformVec4(renderer, uniforms, "u_distortion_y", distortionY)
                this.setUniformVec4(renderer, uniforms, "u_col_s", colS)

                // 全屏 quad submit（覆盖写 state）
                this.submitQuad(viewId, prog)

                Logger.trace(["glitch", "pass: view=" + viewId.toString() +
                              " byp=" + byp.toString() +
                              " amount=" + amount.toString() +
                              " seed=" + seed.toString() +
                              " goWild=" + this.goWild.toString() +
                              " curF=" + this._curF.toString()])
            case None =>
                Logger.trace(["glitch", "glitch shader compile failed, skip pass"])
        }
    }

    /**
     * 设置单个 vec4 uniform（x=value, y/z/w=0）。
     * 辅助方法，简化 9 个 uniforms 的设置代码。
     *
     * @param renderer 渲染器
     * @param uniforms uniform 管理器
     * @param name uniform 名称
     * @param value uniform 值（写入 vec4.x）
     */
    private func setUniformVec4(
        renderer: ThreeRenderer,
        uniforms: BgfxUniforms,
        name: String,
        value: Float64
    ): Unit {
        let handle = uniforms.createUniform(name, UniformType.Vec4.value())
        let mem = BgfxMemory(16u32)
        mem.writeFloats([value, 0.0, 0.0, 0.0], 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    /**
     * 生成 [min, max] 闭区间内的随机浮点数。
     *
     * @param min 最小值
     * @param max 最大值
     * @return [min, max] 内的随机浮点数
     */
    private func randFloat(min: Float64, max: Float64): Float64 {
        return min + this._rand() * (max - min)
    }

    /**
     * LCG 伪随机数生成器，返回 [0, 1) 内的 Float64。
     * 对照 SSAOPass._rand 范式（确定性 LCG，避免 std.random 状态问题）。
     * 算法：seed = (seed * 1103515245 + 12345) % 2^31；返回 seed / 2^31。
     */
    private func _rand(): Float64 {
        this._seed = (this._seed * 1103515245 + 12345) % 2147483648
        return Float64(this._seed) / 2147483648.0
    }

    /**
     * 释放 glitch pass 占用的所有 GPU 资源。
     * 释放位移贴图纹理；glitch shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
     * 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。
     */
    public override func dispose(): Unit {
        if (this._heightMapCreated) {
            match (this._renderer) {
                case Some(renderer) => renderer.destroyTexture(this._heightMap)
                case None => ()
            }
            this._heightMapCreated = false
            Logger.trace(["glitch", "heightMap texture destroyed"])
        }
        Logger.trace(["glitch", "disposed"])
    }
}
