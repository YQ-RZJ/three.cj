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
 * @file[zh-cn] BgfxOutputPass 输出 pass
 * @brief[zh-cn] 输出 pass —— 色调映射 + sRGB 色彩空间转换，pass 链最后一个上屏 pass
 * @explain[zh-cn] 用 OutputShader（含 7 种 ToneMapping + SRGB_TRANSFER）做色调映射 + sRGB 转换。
 *         toneMapping/exposure/sRGB 三个参数由用户显式传（ThreeRenderer 未暴露这些字段）。
 *         needsSwap=true（默认，作为最后一个 pass 时 composer 自动 renderToScreen=true）；
 *         renderToScreen=true 时调 bgfx_frame 上屏。
 *         渲染差异：material.defines 由 compileBgfxWithDefines 传 #define 字符串实现；
 *         OutputShader 内联 7 种 ToneMapping 函数体 + sqrt 近似 sRGB OETF（pow(x, 1/2.2)）。
 *
 * @file[en] BgfxOutputPass output pass
 * @brief[en] Output pass - tone mapping + sRGB color space conversion, the final on-screen pass of the chain
 * @explain[en] Uses OutputShader (with 7 ToneMapping variants + SRGB_TRANSFER) for tone mapping + sRGB conversion.
 *         The toneMapping/exposure/sRGB parameters are passed explicitly by the user (ThreeRenderer does not expose these fields).
 *         needsSwap=true (default; as the last pass the composer automatically sets renderToScreen=true);
 *         when renderToScreen=true, bgfx_frame is called to present.
 *         Rendering differences: material.defines is implemented via compileBgfxWithDefines with #define strings;
 *         OutputShader inlines 7 ToneMapping function bodies plus a sqrt approximation of the sRGB OETF (pow(x, 1/2.2)).
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.utils.constants.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import std.collection.*
import three.rendering.types.*

/**
 * @brief[zh-cn] 输出 pass
 * @brief[en] Output pass
 * @explain[zh-cn] 色调映射 + sRGB 色彩空间转换，通常放 pass 链尾部。
 * @explain[en] Tone mapping + sRGB color space conversion, usually placed at the end of the pass chain.
 */
public class OutputPass <: Pass {
    /**
     * @brief[zh-cn] 色调映射模式（对照 constants.cj：NoToneMapping=0 ... NeutralToneMapping=7），默认 ACESFilmicToneMapping（=4）
     * @brief[en] Tone mapping mode (see constants.cj: NoToneMapping=0 ... NeutralToneMapping=7), default ACESFilmicToneMapping (=4)
     */
    public var toneMapping: Int64 = ACESFilmicToneMapping

    /**
     * @brief[zh-cn] 色调映射曝光，默认 1.0
     * @brief[en] Tone mapping exposure, default 1.0
     */
    public var exposure: Float64 = 1.0

    /**
     * @brief[zh-cn] 是否做 sRGB OETF 转换（线性 → sRGB），默认 true（上屏前转 sRGB）
     * @brief[en] Whether to perform sRGB OETF conversion (linear → sRGB), default true (convert to sRGB before presenting)
     */
    public var sRGB: Bool = true

    /**
     * view id（212，避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209/SavePass 210/TexturePass 211）。
     */
    private static let _viewId: UInt16 = 212u16

    /**
     * 已编译 program handle 缓存。
     */
    private var _prog: Option<ProgramHandle> = None

    /**
     * 上次编译用的参数（参数变需重编译）。
     */
    private var _lastToneMapping: Int64 = -1
    private var _lastSRGB: Bool = false

    /**
     * uniform 注册表缓存（避免每帧创建新 BgfxUniforms 泄漏 bgfx handle）。
     */
    private var _uniforms: Option<BgfxUniforms> = None

    /**
     * @brief[zh-cn] 构造 OutputPass
     * @brief[en] Constructs OutputPass
     * @param[zh-cn] toneMapping 色调映射模式（默认 ACESFilmicToneMapping=4）
     * @param[zh-cn] exposure 曝光（默认 1.0）
     * @param[zh-cn] sRGB 是否做 sRGB 转换（默认 true）
     * @param[en] toneMapping Tone mapping mode (default ACESFilmicToneMapping=4)
     * @param[en] exposure Exposure (default 1.0)
     * @param[en] sRGB Whether to perform sRGB conversion (default true)
     * @explain[zh-cn] 全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     * @explain[en] The full-screen quad is held as a singleton by EffectComposer and injected via setQuad (base class quad field).
     */
    public init(toneMapping!: Int64 = ACESFilmicToneMapping, exposure!: Float64 = 1.0, sRGB!: Bool = true) {
        super()
        this.toneMapping = toneMapping
        this.exposure = exposure
        this.sRGB = sRGB
        // OutputPass 默认 needsSwap=true（作为链尾 pass 时 composer 设 renderToScreen=true）
        this.needsSwap = true
    }

    /**
     * 按 toneMapping/sRGB 编译 OutputShader（带 #define）。
     */
    private func _compile(): Option<ProgramHandle> {
        // 后处理 shader 已迁移到 postprocessing 内部注册表 PostProcessingShaders
        match (PostProcessingShaders.get("output")) {
            case Some(sp) =>
                // 选 ToneMapping #define 名（对照 OutputShader 的 #ifdef 链）
                let toneDefine: String = match (this.toneMapping) {
                    case LinearToneMapping => "TONE_LINEAR"
                    case ReinhardToneMapping => "TONE_REINHARD"
                    case CineonToneMapping => "TONE_CINEON"
                    case ACESFilmicToneMapping => "TONE_ACES_FILMIC"
                    case AgXToneMapping => "TONE_AGX"
                    case NeutralToneMapping => "TONE_NEUTRAL"
                    case CustomToneMapping => "TONE_CUSTOM"   // OutputShader 未实现 Custom，占位
                    case NoToneMapping => ""                   // 无色调映射
                    case _ => ""
                }
                // 收集 #define 列表
                let defineStrs = ArrayList<String>()
                if (toneDefine.size > 0) {
                    defineStrs.add(toneDefine)
                }
                if (this.sRGB) {
                    defineStrs.add("SRGB_TRANSFER")
                }
                if (defineStrs.size == 0) {
                    // 无 #define：直接编译（NoToneMapping + 非 sRGB）
                    sp.compileBgfx()
                } else {
                    sp.compileBgfx(extraDefines: defineStrs.toArray())
                }
                this._lastToneMapping = this.toneMapping
                this._lastSRGB = this.sRGB
                return Some(Box(sp.programHandle))
            case None => return None
        }
    }

    /**
     * 执行输出 pass：色调映射 + sRGB 转换上屏。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（renderToScreen=false 时写这里）
     * @param readBuffer 读 buffer（待转换的线性 HDR 颜色）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 参数变则重编译
        if (this._prog.isNone() || this.toneMapping != this._lastToneMapping || this.sRGB != this._lastSRGB) {
            this._prog = this._compile()
        }
        match (this._prog) {
            case Some(prog) =>
                if (!isValidHandle(prog)) { return }
                let viewId = OutputPass._viewId
                let w = UInt16(renderer.width)
                let h = UInt16(renderer.height)
                let rt = this.renderToScreen
                let exp = this.exposure
                // 视口
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                // renderToScreen=true 时写 swap chain，否则写 writeBuffer
                let targetFB = if (rt) { INVALID_FRAME_BUFFER_HANDLE } else { writeBuffer }
                this.setRenderTarget(renderer, viewId, targetFB)
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

                // 绑 readBuffer color 0 到 tDiffuse sampler（stage 0）
                // 使用缓存的 uniform 注册表，避免每帧创建新 BgfxUniforms 泄漏 bgfx handle
                let uniforms = match (this._uniforms) {
                    case Some(u) => u
                    case None =>
                        let u = BgfxUniforms()
                        this._uniforms = Some(u)
                        u
                }
                let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let readTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uTex, readTex, 0u32)

                // toneMappingExposure uniform
                let uExp = uniforms.createUniform("u_toneMappingExposure", UniformType.Vec4.value())
                let expMem = BgfxMemory(16u32)
                expMem.writeFloats([exp, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uExp, expMem, num: 1u16)

                this.submitQuad(viewId, prog)
                // 不在此调 present：frame 统一由 EffectComposer.render 末尾触发
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 释放 OutputPass 占用的 GPU 资源
     * @brief[en] Releases the GPU resources held by OutputPass
     * @explain[zh-cn] shader 为全局缓存不 dispose；quad 由 caller 管理。
     * @explain[en] Shaders are globally cached and not disposed; the quad is managed by the caller.
     */
    public override func dispose(): Unit {
        this._prog = None
        match (this._uniforms) {
            case Some(u) => u.dispose()
            case None => ()
        }
        this._uniforms = None
    }
}
