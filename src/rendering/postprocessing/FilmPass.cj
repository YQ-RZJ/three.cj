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
 * @file[zh-cn] BgfxFilmPass 胶片颗粒后处理 pass
 * @brief[zh-cn] 胶片颗粒后处理 pass —— 给画面叠加动态噪声 + 可选灰度转换
 * @explain[zh-cn] 算法：
 *         1. base   = texture2D(tDiffuse, vUv)                       // 当前帧输入
 *         2. noise  = rand(fract(vUv + time))                        // 逐像素伪随机噪声
 *         3. color  = base.rgb + base.rgb * clamp(0.1 + noise, 0, 1) // 噪声叠加
 *         4. color  = mix(base.rgb, color, intensity)               // 按 intensity 混合
 *         5. if grayscale: color = vec3(luminance(color))           // 灰度转换
 *         流程：单遍全屏 pass：readBuffer.color0 → tDiffuse → 颗粒处理 → writeBuffer（或屏幕）；
 *         time uniform 每帧累加 deltaTime（驱动 rand 噪声动态变化）。
 *         渲染差异：复用 PostProcessingShaders.get("film") shader program + 共享 FullScreenQuad submit；
 *         bgfx uniform 最小单位 vec4，故用 u_intensity/u_grayscale/u_time(vec4: x=value)；
 *         view id 用 FILM_VIEW_ID_BASE=224（避开既有硬编码段）。
 *
 * @file[en] BgfxFilmPass film grain post-processing pass
 * @brief[en] Film grain post-processing pass - overlays dynamic noise plus optional grayscale conversion
 * @explain[en] Algorithm:
 *         1. base   = texture2D(tDiffuse, vUv)                       // current frame input
 *         2. noise  = rand(fract(vUv + time))                        // per-pixel pseudo-random noise
 *         3. color  = base.rgb + base.rgb * clamp(0.1 + noise, 0, 1) // noise overlay
 *         4. color  = mix(base.rgb, color, intensity)               // mix by intensity
 *         5. if grayscale: color = vec3(luminance(color))           // grayscale conversion
 *         Flow: a single-pass full-screen pass: readBuffer.color0 → tDiffuse → grain processing →
 *         writeBuffer (or screen); the time uniform accumulates deltaTime each frame (drives dynamic rand noise).
 *         Rendering differences: reuses the PostProcessingShaders.get("film") shader program with the shared
 *         FullScreenQuad submit; bgfx uniforms have a minimum unit of vec4, so u_intensity/u_grayscale/u_time
 *         (vec4: x=value) are used; the view id uses FILM_VIEW_ID_BASE=224 (avoids existing hardcoded ranges).
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

/**
 * @brief[zh-cn] 胶片颗粒后处理 pass
 * @brief[en] Film grain post-processing pass
 * @explain[zh-cn] 单遍全屏 pass，无内部 ping-pong RT（纯像素处理）。
 * @explain[en] A single-pass full-screen pass with no internal ping-pong RT (pure pixel processing).
 */
public class FilmPass <: Pass {
    /**
     * @brief[zh-cn] 颗粒强度（0~1）：0 = 无效果，1 = 全强度，默认 0.5
     * @brief[en] Grain intensity (0~1): 0 = no effect, 1 = full strength, default 0.5
     */
    public var intensity: Float64

    /**
     * @brief[zh-cn] 是否启用灰度转换，默认 false
     * @brief[en] Whether grayscale conversion is enabled, default false
     */
    public var grayscale: Bool

    /**
     * @brief[zh-cn] 动画时间累加器（秒），每帧 += deltaTime，驱动 rand 噪声动态变化
     * @brief[en] Animation time accumulator (seconds); += deltaTime each frame, drives dynamic rand noise
     */
    public var time: Float64 = 0.0

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: film pass（颗粒处理 + 可选灰度）
     * 取 224 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
     * TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
     * TAA 219~220 / Afterimage 221~223。
     */
    public static let FILM_VIEW_ID_BASE: UInt16 = 224u16

    /**
     * film shader 是否已编译。
     */
    private var _filmCompiled: Bool = false

    /**
     * film program handle 缓存。
     */
    private var _filmProg: Option<ProgramHandle> = None

    /**
     * @brief[zh-cn] 构造 FilmPass
     * @brief[en] Constructs FilmPass
     * @param[zh-cn] intensity 颗粒强度（默认 0.5）
     * @param[zh-cn] grayscale 是否灰度（默认 false）
     * @param[en] intensity Grain intensity (default 0.5)
     * @param[en] grayscale Whether to use grayscale (default false)
     */
    public init(intensity!: Float64 = 0.5, grayscale!: Bool = false) {
        super()
        this.intensity = intensity
        this.grayscale = grayscale
        // needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
    }

    /**
     * @brief[zh-cn] 设置 pass 尺寸
     * @brief[en] Sets the pass size
     * @explain[zh-cn] FilmPass 无内部 RT，尺寸仅用于视口记录。
     * @explain[en] FilmPass has no internal RT; the size is only used for viewport recording.
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        // FilmPass 无内部 RT，无需重建资源
        Logger.trace(["film", "setSize: " + width.toString() + "x" + height.toString() +
                      " (no internal RT)"])
    }

    /**
     * 编译 film shader。
     */
    private func _compileFilm(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("film")) {
            case Some(sp) =>
                if (!this._filmCompiled) {
                    sp.compileBgfx()
                    this._filmProg = Some(Box(sp.programHandle))
                    this._filmCompiled = true
                    Logger.trace(["film", "film shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._filmProg
            case None =>
                Logger.trace(["film", "film shader not registered"])
                return None
        }
    }

    /**
     * @brief[zh-cn] 执行 film pass
     * @brief[en] Executes the film pass
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 的输出目标）
     * @param[zh-cn] readBuffer 读 buffer（上一 pass 结果，绑到 tDiffuse）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (output target of this pass)
     * @param[en] readBuffer Read buffer (previous pass result, bound to tDiffuse)
     * @param[en] deltaTime Frame delta time
     * @explain[zh-cn] 流程：1. 绑定 tDiffuse = readBuffer.color0（stage 0）；
     *         2. 设置 u_intensity / u_grayscale / u_time uniforms；
     *         3. 全屏 quad submit（覆盖写 state）；
     *         4. time += deltaTime（驱动下一帧 rand 噪声变化）。
     * @explain[en] Flow: 1. binds tDiffuse = readBuffer.color0 (stage 0);
     *         2. sets the u_intensity / u_grayscale / u_time uniforms;
     *         3. submits the full-screen quad (overwrite state);
     *         4. time += deltaTime (drives the rand noise change next frame).
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        let viewId = UInt16(FilmPass.FILM_VIEW_ID_BASE + 0u16)

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

        match (this._compileFilm()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) { return }

                let uniforms = BgfxUniforms()

                // stage 0 = tDiffuse（readBuffer 的 color 0）
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let diffuseTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uDiffuse, diffuseTex, 0u32)

                // u_intensity（vec4: x=intensity）
                let uIntensity = uniforms.createUniform("u_intensity", UniformType.Vec4.value())
                let intMem = BgfxMemory(16u32)
                intMem.writeFloats([this.intensity, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uIntensity, intMem, num: 1u16)

                // u_grayscale（vec4: x=grayscale 0.0/1.0）
                let uGrayscale = uniforms.createUniform("u_grayscale", UniformType.Vec4.value())
                let gsMem = BgfxMemory(16u32)
                let gsVal: Float64 = if (this.grayscale) { 1.0 } else { 0.0 }
                gsMem.writeFloats([gsVal, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uGrayscale, gsMem, num: 1u16)

                // u_time（vec4: x=time）
                let uTime = uniforms.createUniform("u_time", UniformType.Vec4.value())
                let timeMem = BgfxMemory(16u32)
                timeMem.writeFloats([this.time, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uTime, timeMem, num: 1u16)

                // 全屏 quad submit（覆盖写 state）
                this.submitQuad(viewId, prog)

                // 时间累加（驱动下一帧 rand 噪声动态变化）
                this.time += deltaTime

                Logger.trace(["film", "pass: view=" + viewId.toString() +
                              " intensity=" + this.intensity.toString() +
                              " grayscale=" + this.grayscale.toString() +
                              " time=" + this.time.toString()])
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 释放 film pass 占用的所有 GPU 资源
     * @brief[en] Releases all GPU resources held by the film pass
     * @explain[zh-cn] film shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
     *         全屏 quad 由 EffectComposer 持单例统一管理。
     * @explain[en] The film shader program is managed globally by PostProcessingShaders and is not disposed here;
     *         the full-screen quad is managed as a singleton by EffectComposer.
     */
    public override func dispose(): Unit {
        Logger.trace(["film", "disposed"])
    }
}
