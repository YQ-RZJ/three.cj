/**
 * @file[zh-cn] BgfxHalftonePass RGB 半色调后处理 pass
 * @brief[zh-cn] RGB 半色调后处理 pass —— 把画面转换为旋转网点印刷风（halftone）
 * @explain[zh-cn] 算法（逐行移植，非简化）：
 *         1. setup: p = vec2(vUV.x*width, vUV.y*height); origin=(0,0);
 *            aa = (radius<2.5)? radius*0.5 : 1.25
 *         2. getReferenceCell(p, origin, rotateR/G/B, radius) → 3 个 Cell（R/G/B 各自旋转网格）
 *            - n=vec2(cos,sin) 旋转网格法向，mod 步进定位最近格点 p1 + 邻格点 p2/p3/p4
 *            - scatter!=0 时给 p1 叠加随机偏移（散点抖动）
 *         3. getDotColour(cell, p, channel, angle, aa) → 各通道网点亮度
 *            - getSample(pN) 取 8 抽头圆周平均采样（radius*0.66 半径）
 *            - distanceToDotRadius 按 shape(1=Dot/2=Ellipse/3=Line/4=Square/5=Diamond) 变换半径
 *            - 4 邻格点距离 → dot 半径，clamp 累加得 channel 亮度 [0,1]
 *         4. blendColour(r/g/b, colour.r/g/b, blending) 按 blendingMode
 *            (1=Linear/2=Multiply/3=Add/4=Lighter/5=Darker) 混合
 *         5. greyscale 时 r=g=b=(r+g+b)/3
 *         6. disable 时直接透传 texture2D(tDiffuse, vUV)
 *         流程：单遍全屏 pass：readBuffer.color0 → tDiffuse → halftone 处理 → writeBuffer（或屏幕）；
 *         setSize 时更新 width/height uniforms。
 *         渲染差异：复用 PostProcessingShaders.get("halftone") shader program + 共享 FullScreenQuad submit；
 *         bgfx uniform 最小单位 vec4，故用 u_xxx(vec4: x=值)；int/bool 用 vec4.x 表示
 *         （u_shape.x == 1.0 视为 shape=1）；tDiffuse 绑 stage 0（readBuffer.color0）；
 *         view id 用 HALFTONE_VIEW_ID_BASE=227（避开既有硬编码段）。
 *
 * @file[en] BgfxHalftonePass RGB halftone post-processing pass
 * @brief[en] RGB halftone post-processing pass - converts the image into a rotated dot-screen print style (halftone)
 * @explain[en] Algorithm (line-by-line port, not simplified):
 *         1. setup: p = vec2(vUV.x*width, vUV.y*height); origin=(0,0);
 *            aa = (radius<2.5)? radius*0.5 : 1.25
 *         2. getReferenceCell(p, origin, rotateR/G/B, radius) → 3 Cells (R/G/B each with its own rotated grid)
 *            - n=vec2(cos,sin) rotated grid normal; mod stepping locates nearest lattice point p1 + neighbors p2/p3/p4
 *            - scatter!=0 adds a random offset to p1 (scatter dithering)
 *         3. getDotColour(cell, p, channel, angle, aa) → per-channel dot brightness
 *            - getSample(pN) takes an 8-tap circular average sample (radius*0.66 radius)
 *            - distanceToDotRadius transforms the radius by shape(1=Dot/2=Ellipse/3=Line/4=Square/5=Diamond)
 *            - distances to the 4 neighbor lattice points → dot radius, clamp-accumulated into channel brightness [0,1]
 *         4. blendColour(r/g/b, colour.r/g/b, blending) mixes by blendingMode
 *            (1=Linear/2=Multiply/3=Add/4=Lighter/5=Darker)
 *         5. r=g=b=(r+g+b)/3 when greyscale
 *         6. pass-through texture2D(tDiffuse, vUV) directly when disabled
 *         Flow: a single-pass full-screen pass: readBuffer.color0 → tDiffuse → halftone processing → writeBuffer
 *         (or screen); setSize updates the width/height uniforms.
 *         Rendering differences: reuses the PostProcessingShaders.get("halftone") shader program with the shared
 *         FullScreenQuad submit; bgfx uniforms have a minimum unit of vec4, so u_xxx (vec4: x=value) is used;
 *         int/bool is represented by vec4.x (u_shape.x == 1.0 means shape=1); tDiffuse is bound to stage 0
 *         (readBuffer.color0); the view id uses HALFTONE_VIEW_ID_BASE=227 (avoids existing hardcoded ranges).
 *
 * @package three.rendering.postprocessing
 */

package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.types.*

/**
 * @brief[zh-cn] RGB 半色调后处理 pass
 * @brief[en] RGB halftone post-processing pass
 * @explain[zh-cn] 单遍全屏 pass，无内部 ping-pong RT（纯像素处理）。
 *         uniforms 全部以 public 字段暴露，运行时修改字段 → render() 内每帧同步到 bgfx uniform。
 * @explain[en] A single-pass full-screen pass with no internal ping-pong RT (pure pixel processing).
 *         All uniforms are exposed as public fields; changing a field at runtime is synced to the bgfx
 *         uniform each frame in render().
 */
public class HalftonePass <: Pass {
    /**
     * @brief[zh-cn] 网点形状（1=Dot 2=Ellipse 3=Line 4=Square 5=Diamond），默认 1
     * @brief[en] Dot shape (1=Dot 2=Ellipse 3=Line 4=Square 5=Diamond), default 1
     */
    public var shape: Int64

    /**
     * @brief[zh-cn] 网点半径（像素），默认 4
     * @brief[en] Dot radius (pixels), default 4
     */
    public var radius: Float64

    /**
     * @brief[zh-cn] R 通道网格旋转角（弧度），默认 PI/12
     * @brief[en] R channel grid rotation angle (radians), default PI/12
     */
    public var rotateR: Float64

    /**
     * @brief[zh-cn] G 通道网格旋转角（弧度），默认 PI/12*2
     * @brief[en] G channel grid rotation angle (radians), default PI/12*2
     */
    public var rotateG: Float64

    /**
     * @brief[zh-cn] B 通道网格旋转角（弧度），默认 PI/12*3
     * @brief[en] B channel grid rotation angle (radians), default PI/12*3
     */
    public var rotateB: Float64

    /**
     * @brief[zh-cn] 散点抖动量（0=无抖动），默认 0
     * @brief[en] Scatter dithering amount (0=no dithering), default 0
     */
    public var scatter: Float64

    /**
     * @brief[zh-cn] 混合强度（0=全原色 1=全 halftone），默认 1
     * @brief[en] Blending strength (0=full original 1=full halftone), default 1
     */
    public var blending: Float64

    /**
     * @brief[zh-cn] 混合模式（1=Linear 2=Multiply 3=Add 4=Lighter 5=Darker），默认 1
     * @brief[en] Blending mode (1=Linear 2=Multiply 3=Add 4=Lighter 5=Darker), default 1
     */
    public var blendingMode: Int64

    /**
     * @brief[zh-cn] 是否灰度输出，默认 false
     * @brief[en] Whether to output grayscale, default false
     */
    public var greyscale: Bool

    /**
     * @brief[zh-cn] 是否禁用（true=直接透传原图），默认 false
     * @brief[en] Whether to disable (true=pass the original image through), default false
     */
    public var disable: Bool

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: halftone pass（RGB 半色调网点处理）
     * 取 227 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
     * TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
     * TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
     * DotScreenPass 226。
     */
    public static let HALFTONE_VIEW_ID_BASE: UInt16 = 227u16

    /**
     * halftone shader 是否已编译。
     */
    private var _halftoneCompiled: Bool = false

    /**
     * halftone program handle 缓存。
     */
    private var _halftoneProg: Option<ProgramHandle> = None

    /**
     * uniform 管理器缓存（复用实例，避免 render() 内每帧新建 13 个 uniform 句柄导致泄漏）。
     */
    private var _uniforms = BgfxUniforms()

    /**
     * @brief[zh-cn] 构造 HalftonePass
     * @brief[en] Constructs HalftonePass
     * @param[zh-cn] shape 网点形状（默认 1=Dot）
     * @param[zh-cn] radius 网点半径（默认 4）
     * @param[zh-cn] rotateR R 通道旋转角（默认 PI/12）
     * @param[zh-cn] rotateG G 通道旋转角（默认 PI/12*2）
     * @param[zh-cn] rotateB B 通道旋转角（默认 PI/12*3）
     * @param[zh-cn] scatter 散点抖动（默认 0）
     * @param[zh-cn] blending 混合强度（默认 1）
     * @param[zh-cn] blendingMode 混合模式（默认 1=Linear）
     * @param[zh-cn] greyscale 灰度（默认 false）
     * @param[zh-cn] disable 禁用透传（默认 false）
     * @param[en] shape Dot shape (default 1=Dot)
     * @param[en] radius Dot radius (default 4)
     * @param[en] rotateR R channel rotation angle (default PI/12)
     * @param[en] rotateG G channel rotation angle (default PI/12*2)
     * @param[en] rotateB B channel rotation angle (default PI/12*3)
     * @param[en] scatter Scatter dithering (default 0)
     * @param[en] blending Blending strength (default 1)
     * @param[en] blendingMode Blending mode (default 1=Linear)
     * @param[en] greyscale Grayscale (default false)
     * @param[en] disable Disabled pass-through (default false)
     * @explain[zh-cn] 所有参数直接写入对应字段，render() 内再同步到 bgfx uniform。
     * @explain[en] All parameters are written directly to the corresponding fields, then synced to the bgfx
     *         uniforms in render().
     */
    public init(
        shape!: Int64 = 1,
        radius!: Float64 = 4.0,
        rotateR!: Float64 = 3.141592653589793 / 12.0,
        rotateG!: Float64 = 3.141592653589793 / 12.0 * 2.0,
        rotateB!: Float64 = 3.141592653589793 / 12.0 * 3.0,
        scatter!: Float64 = 0.0,
        blending!: Float64 = 1.0,
        blendingMode!: Int64 = 1,
        greyscale!: Bool = false,
        disable!: Bool = false
    ) {
        super()
        this.shape = shape
        this.radius = radius
        this.rotateR = rotateR
        this.rotateG = rotateG
        this.rotateB = rotateB
        this.scatter = scatter
        this.blending = blending
        this.blendingMode = blendingMode
        this.greyscale = greyscale
        this.disable = disable
        // needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
        Logger.trace(["halftone", "HalftonePass constructed: shape=" + shape.toString() +
                      " radius=" + radius.toString() +
                      " rotateR=" + rotateR.toString() +
                      " rotateG=" + rotateG.toString() +
                      " rotateB=" + rotateB.toString() +
                      " scatter=" + scatter.toString() +
                      " blending=" + blending.toString() +
                      " blendingMode=" + blendingMode.toString() +
                      " greyscale=" + greyscale.toString() +
                      " disable=" + disable.toString()])
    }

    /**
     * @brief[zh-cn] 设置 pass 尺寸
     * @brief[en] Sets the pass size
     * @explain[zh-cn] HalftonePass 无内部 RT，width/height 在 render() 时取自 renderer 尺寸同步到 uniform。
     * @explain[en] HalftonePass has no internal RT; width/height are taken from the renderer size and synced to
     *         the uniforms in render().
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        // HalftonePass 无内部 RT，width/height 在 render() 时取自 renderer 尺寸同步到 uniform
        Logger.trace(["halftone", "setSize: " + width.toString() + "x" + height.toString() +
                      " (width/height synced in render via renderer)"])
    }

    /**
     * 编译 halftone shader。
     */
    private func _compileHalftone(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("halftone")) {
            case Some(sp) =>
                if (!this._halftoneCompiled) {
                    sp.compileBgfx()
                    this._halftoneProg = Some(Box(sp.programHandle))
                    this._halftoneCompiled = true
                    Logger.trace(["halftone", "halftone shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._halftoneProg
            case None =>
                Logger.trace(["halftone", "halftone shader not registered"])
                return None
        }
    }

    /**
     * 设置单个 vec4 uniform（x=value, y/z/w=0）。
     * 辅助方法，简化 12 个 uniforms 的设置代码。
     *
     * @param renderer 渲染器
     * @param uniforms uniform 管理器
     * @param name uniform 名称
     * @param value uniform 值（写入 vec4.x）
     */
    private func setUniformVec4(
        renderer: BgfxRenderer,
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
     * @brief[zh-cn] 执行 halftone pass
     * @brief[en] Executes the halftone pass
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 的输出目标）
     * @param[zh-cn] readBuffer 读 buffer（上一 pass 结果，绑到 tDiffuse）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (output target of this pass)
     * @param[en] readBuffer Read buffer (previous pass result, bound to tDiffuse)
     * @param[en] deltaTime Frame delta time
     * @explain[zh-cn] 流程：1. 绑定 tDiffuse = readBuffer.color0（stage 0）；
     *         2. 设置 12 个 uniforms（width/height 取自 renderer 尺寸）；
     *         3. 全屏 quad submit（覆盖写 state）。
     * @explain[en] Flow: 1. binds tDiffuse = readBuffer.color0 (stage 0);
     *         2. sets the 12 uniforms (width/height taken from the renderer size);
     *         3. submits the full-screen quad (overwrite state).
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        let viewId = UInt16(HalftonePass.HALFTONE_VIEW_ID_BASE + 0u16)

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

        match (this._compileHalftone()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) {
                    Logger.trace(["halftone", "halftone prog invalid, skip"])
                    return
                }

                Logger.trace(["halftone", "render STEP-1: prog OK, about to create uniforms"])
                let uniforms = this._uniforms

                // stage 0 = tDiffuse（readBuffer 的 color 0）
                Logger.trace(["halftone", "render STEP-2: createUniform(tDiffuse)"])
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let diffuseTex = this.getTexture(renderer, readBuffer, 0u8)
                Logger.trace(["halftone", "render STEP-3: bindTexture tDiffuse"])
                this.bindTexture(renderer, 0u8, uDiffuse, diffuseTex, 0u32)

                // 12 个 uniforms（bgfx 最小单位 vec4，x=value）
                // int/bool 用 Float64 传入，shader 内 u_shape.x == 1.0 视为 shape=1
                Logger.trace(["halftone", "render STEP-4: 12x setUniformVec4"])
                this.setUniformVec4(renderer, uniforms, "u_shape",        Float64(this.shape))
                this.setUniformVec4(renderer, uniforms, "u_radius",       this.radius)
                this.setUniformVec4(renderer, uniforms, "u_rotateR",      this.rotateR)
                this.setUniformVec4(renderer, uniforms, "u_rotateG",      this.rotateG)
                this.setUniformVec4(renderer, uniforms, "u_rotateB",      this.rotateB)
                this.setUniformVec4(renderer, uniforms, "u_scatter",      this.scatter)
                // width/height 取自 renderer 尺寸（setSize 时同步更新）
                this.setUniformVec4(renderer, uniforms, "u_width",        Float64(renderer.width))
                this.setUniformVec4(renderer, uniforms, "u_height",       Float64(renderer.height))
                this.setUniformVec4(renderer, uniforms, "u_blending",     this.blending)
                this.setUniformVec4(renderer, uniforms, "u_blendingMode", Float64(this.blendingMode))
                this.setUniformVec4(renderer, uniforms, "u_greyscale",   if (this.greyscale) { 1.0 } else { 0.0 })
                this.setUniformVec4(renderer, uniforms, "u_disable",     if (this.disable) { 1.0 } else { 0.0 })

                // 全屏 quad submit（覆盖写 state）
                Logger.trace(["halftone", "render STEP-5: submitQuad"])
                this.submitQuad(viewId, prog)
                Logger.trace(["halftone", "render DONE"])

                Logger.trace(["halftone", "pass: view=" + viewId.toString() +
                              " shape=" + this.shape.toString() +
                              " radius=" + this.radius.toString() +
                              " rotateR=" + this.rotateR.toString() +
                              " rotateG=" + this.rotateG.toString() +
                              " rotateB=" + this.rotateB.toString() +
                              " scatter=" + this.scatter.toString() +
                              " blending=" + this.blending.toString() +
                              " blendingMode=" + this.blendingMode.toString() +
                              " greyscale=" + this.greyscale.toString() +
                              " disable=" + this.disable.toString() +
                              " tSize=" + renderer.width.toString() + "x" +
                              renderer.height.toString()])
            case None =>
                Logger.trace(["halftone", "halftone shader compile failed, skip pass"])
        }
    }

    /**
     * @brief[zh-cn] 释放 halftone pass 占用的所有 GPU 资源
     * @brief[en] Releases all GPU resources held by the halftone pass
     * @explain[zh-cn] halftone shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
     *         全屏 quad 由 EffectComposer 持单例统一管理。
     * @explain[en] The halftone shader program is managed globally by PostProcessingShaders and is not disposed
     *         here; the full-screen quad is managed as a singleton by EffectComposer.
     */
    public override func dispose(): Unit {
        Logger.trace(["halftone", "disposed"])
    }
}
