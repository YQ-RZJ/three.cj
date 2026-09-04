/**
 * @file[zh-cn] BgfxDotScreenPass 点阵屏后处理 pass
 * @brief[zh-cn] 点阵屏后处理 pass —— 把画面转换为旋转点阵网点效果（halftone-like）
 * @explain[zh-cn] 算法（逐行移植，非简化）：
 *         1. pattern() 旋转点阵生成：
 *            s = sin(angle); c = cos(angle)
 *            tex = vUv * tSize - center
 *            point = vec2(c * tex.x - s * tex.y, s * tex.x + c * tex.y) * scale
 *            return (sin(point.x) * sin(point.y)) * 4.0
 *         2. color = texture2D(tDiffuse, vUv)
 *         3. average = (color.r + color.g + color.b) / 3.0   // 亮度平均
 *         4. gl_FragColor = vec4(vec3(average * 10.0 - 5.0 + pattern()), color.a)
 *            ↑ average*10-5 把 [0,1] 亮度映射到 [-5,5]，
 *              pattern() 返回 [-4,4]，二者之和落在 [-9,9]，
 *              vec3(scalar) 构造灰度 → 最终 RT clamping 到 [0,1]
 *         流程：单遍全屏 pass：readBuffer.color0 → tDiffuse → 点阵处理 → writeBuffer（或屏幕）；
 *         uniforms.center/angle/scale 可运行时修改；u_tSize 每帧设为 readBuffer 尺寸。
 *         渲染差异：复用 PostProcessingShaders.get("dot_screen") shader program + 共享 FullScreenQuad submit；
 *         bgfx uniform 最小单位 vec4，故用 u_center/u_tSize(vec4: xy=值)、u_angle/u_scale(vec4: x=值)；
 *         view id 用 DOTSCREEN_VIEW_ID_BASE=226（避开既有硬编码段）。
 *
 * @file[en] BgfxDotScreenPass dot screen post-processing pass
 * @brief[en] Dot screen post-processing pass - converts the image into a rotated dot-screen halftone effect
 * @explain[en] Algorithm (line-by-line port, not simplified):
 *         1. pattern() rotated dot grid generation:
 *            s = sin(angle); c = cos(angle)
 *            tex = vUv * tSize - center
 *            point = vec2(c * tex.x - s * tex.y, s * tex.x + c * tex.y) * scale
 *            return (sin(point.x) * sin(point.y)) * 4.0
 *         2. color = texture2D(tDiffuse, vUv)
 *         3. average = (color.r + color.g + color.b) / 3.0   // luminance average
 *         4. gl_FragColor = vec4(vec3(average * 10.0 - 5.0 + pattern()), color.a)
 *            ↑ average*10-5 maps [0,1] luminance to [-5,5],
 *              pattern() returns [-4,4], their sum lies in [-9,9],
 *              vec3(scalar) builds grayscale → final RT clamps to [0,1]
 *         Flow: a single-pass full-screen pass: readBuffer.color0 → tDiffuse → dot processing → writeBuffer
 *         (or screen); the center/angle/scale uniforms can be changed at runtime; u_tSize is set to the
 *         readBuffer size each frame.
 *         Rendering differences: reuses the PostProcessingShaders.get("dot_screen") shader program with the
 *         shared FullScreenQuad submit; bgfx uniforms have a minimum unit of vec4, so u_center/u_tSize
 *         (vec4: xy=value), u_angle/u_scale (vec4: x=value) are used; the view id uses
 *         DOTSCREEN_VIEW_ID_BASE=226 (avoids existing hardcoded ranges).
 *
 * @package three.rendering.postprocessing
 */

package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.core.math.Vector2
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.types.*

/**
 * @brief[zh-cn] 点阵屏后处理 pass
 * @brief[en] Dot screen post-processing pass
 * @explain[zh-cn] 单遍全屏 pass，无内部 ping-pong RT（纯像素处理）。
 * @explain[en] A single-pass full-screen pass with no internal ping-pong RT (pure pixel processing).
 */
public class DotScreenPass <: Pass {
    /**
     * @brief[zh-cn] 点阵中心（UV 空间，0~1），默认 (0.5, 0.5)
     * @brief[en] Dot grid center (UV space, 0~1), default (0.5, 0.5)
     */
    public var center: Vector2

    /**
     * @brief[zh-cn] 点阵旋转角度（弧度），默认 1.57 ≈ π/2
     * @brief[en] Dot grid rotation angle (radians), default 1.57 ≈ π/2
     */
    public var angle: Float64

    /**
     * @brief[zh-cn] 点阵密度系数（值越大点越小），默认 1.0
     * @brief[en] Dot grid density factor (larger value = smaller dots), default 1.0
     */
    public var scale: Float64

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: dot_screen pass（点阵网点处理）
     * 取 226 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
     * TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
     * TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225。
     */
    public static let DOTSCREEN_VIEW_ID_BASE: UInt16 = 226u16

    /**
     * dot_screen shader 是否已编译。
     */
    private var _dotScreenCompiled: Bool = false

    /**
     * dot_screen program handle 缓存。
     */
    private var _dotScreenProg: Option<ProgramHandle> = None

    /**
     * @brief[zh-cn] 构造 DotScreenPass
     * @brief[en] Constructs DotScreenPass
     * @param[zh-cn] center 点阵中心（默认 (0.5, 0.5)）
     * @param[zh-cn] angle 点阵旋转角度（默认 1.57 ≈ π/2）
     * @param[zh-cn] scale 点阵密度（默认 1.0）
     * @param[en] center Dot grid center (default (0.5, 0.5))
     * @param[en] angle Dot grid rotation angle (default 1.57 ≈ π/2)
     * @param[en] scale Dot grid density (default 1.0)
     * @explain[zh-cn] 中心默认取画面中央 (0.5, 0.5) 更直观。
     * @explain[en] The center defaults to the middle of the screen (0.5, 0.5) for a more intuitive result.
     */
    public init(center!: Vector2 = Vector2(0.5, 0.5), angle!: Float64 = 1.57, scale!: Float64 = 1.0) {
        super()
        this.center = center
        this.angle = angle
        this.scale = scale
        // needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
        Logger.trace(["dotscreen", "DotScreenPass constructed: center=(" +
                      center.x.toString() + "," + center.y.toString() +
                      ") angle=" + angle.toString() +
                      " scale=" + scale.toString()])
    }

    /**
     * @brief[zh-cn] 设置 pass 尺寸
     * @brief[en] Sets the pass size
     * @explain[zh-cn] DotScreenPass 无内部 RT，尺寸仅用于视口记录。
     * @explain[en] DotScreenPass has no internal RT; the size is only used for viewport recording.
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        // DotScreenPass 无内部 RT，无需重建资源
        Logger.trace(["dotscreen", "setSize: " + width.toString() + "x" + height.toString() +
                      " (no internal RT)"])
    }

    /**
     * 编译 dot_screen shader。
     */
    private func _compileDotScreen(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("dot_screen")) {
            case Some(sp) =>
                if (!this._dotScreenCompiled) {
                    sp.compileBgfx()
                    this._dotScreenProg = Some(Box(sp.programHandle))
                    this._dotScreenCompiled = true
                    Logger.trace(["dotscreen", "dot_screen shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._dotScreenProg
            case None =>
                Logger.trace(["dotscreen", "dot_screen shader not registered"])
                return None
        }
    }

    /**
     * @brief[zh-cn] 执行 dot screen pass
     * @brief[en] Executes the dot screen pass
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 的输出目标）
     * @param[zh-cn] readBuffer 读 buffer（上一 pass 结果，绑到 tDiffuse）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (output target of this pass)
     * @param[en] readBuffer Read buffer (previous pass result, bound to tDiffuse)
     * @param[en] deltaTime Frame delta time
     * @explain[zh-cn] 流程：1. 绑定 tDiffuse = readBuffer.color0（stage 0）；
     *         2. 设置 u_center / u_angle / u_scale / u_tSize uniforms
     *            （u_tSize = readBuffer.width, readBuffer.height）；
     *         3. 全屏 quad submit（覆盖写 state）。
     * @explain[en] Flow: 1. binds tDiffuse = readBuffer.color0 (stage 0);
     *         2. sets the u_center / u_angle / u_scale / u_tSize uniforms
     *            (u_tSize = readBuffer.width, readBuffer.height);
     *         3. submits the full-screen quad (overwrite state).
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        let viewId = UInt16(DotScreenPass.DOTSCREEN_VIEW_ID_BASE + 0u16)

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

        match (this._compileDotScreen()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) {
                    Logger.trace(["dotscreen", "dot_screen prog invalid, skip"])
                    return
                }

                let uniforms = BgfxUniforms()

                // stage 0 = tDiffuse（readBuffer 的 color 0）
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let diffuseTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uDiffuse, diffuseTex, 0u32)

                // u_center（vec4: xy=center）
                let uCenter = uniforms.createUniform("u_center", UniformType.Vec4.value())
                let centerMem = BgfxMemory(16u32)
                centerMem.writeFloats([this.center.x, this.center.y, 0.0, 0.0], 4)
                this.setUniform(renderer, uCenter, centerMem, num: 1u16)

                // u_angle（vec4: x=angle）
                let uAngle = uniforms.createUniform("u_angle", UniformType.Vec4.value())
                let angleMem = BgfxMemory(16u32)
                angleMem.writeFloats([this.angle, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uAngle, angleMem, num: 1u16)

                // u_scale（vec4: x=scale）
                let uScale = uniforms.createUniform("u_scale", UniformType.Vec4.value())
                let scaleMem = BgfxMemory(16u32)
                scaleMem.writeFloats([this.scale, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uScale, scaleMem, num: 1u16)

                // u_tSize（vec4: xy=readBuffer 尺寸）
                let uTSize = uniforms.createUniform("u_tSize", UniformType.Vec4.value())
                let tSizeMem = BgfxMemory(16u32)
                tSizeMem.writeFloats([Float64(renderer.width), Float64(renderer.height), 0.0, 0.0], 4)
                this.setUniform(renderer, uTSize, tSizeMem, num: 1u16)

                // 全屏 quad submit（覆盖写 state）
                this.submitQuad(viewId, prog)

                Logger.trace(["dotscreen", "pass: view=" + viewId.toString() +
                              " center=(" + this.center.x.toString() + "," +
                              this.center.y.toString() + ")" +
                              " angle=" + this.angle.toString() +
                              " scale=" + this.scale.toString() +
                              " tSize=" + renderer.width.toString() + "x" +
                              renderer.height.toString()])
            case None =>
                Logger.trace(["dotscreen", "dot_screen shader compile failed, skip pass"])
        }
    }

    /**
     * @brief[zh-cn] 释放 dot screen pass 占用的所有 GPU 资源
     * @brief[en] Releases all GPU resources held by the dot screen pass
     * @explain[zh-cn] dot_screen shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
     *         全屏 quad 由 EffectComposer 持单例统一管理。
     * @explain[en] The dot_screen shader program is managed globally by PostProcessingShaders and is not disposed
     *         here; the full-screen quad is managed as a singleton by EffectComposer.
     */
    public override func dispose(): Unit {
        Logger.trace(["dotscreen", "disposed"])
    }
}
