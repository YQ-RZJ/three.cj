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
 * @file[zh-cn] BgfxShaderPass 通用 shader pass
 * @brief[zh-cn] 通用 shader pass —— 喂任意已注册全屏 shader 做后处理
 * @explain[zh-cn] 持 shader 名（从 PostProcessingShaders.get 取已注册全屏 shader）+ textureID（绑 readBuffer 的 sampler 名）。
 *         render(renderer, writeBuffer, readBuffer, deltaTime)：编译 shader → 绑 readBuffer 到 textureID
 *         sampler → 全屏 quad submit。
 *         needsSwap=true（pass 后 composer 交换 buffer，下一 pass 从此读）。
 *         渲染差异：本类喂 shader 名（shader 已在 PostProcessingShaders.cj 注册全屏 quad 约定，复用
 *         bgfx 编译缓存），用户自定义特效需先在 PostProcessingShaders 注册；
 *         绑定用 bgfx_get_texture(readBuffer, 0) 纹理句柄 + bgfx_set_texture 绑到 sampler；
 *         renderToScreen 用无效 FrameBufferHandle 表示 swap chain。
 *
 * @file[en] BgfxShaderPass generic shader pass
 * @brief[en] Generic shader pass - feeds any registered full-screen shader for post-processing
 * @explain[en] Holds a shader name (fetched via PostProcessingShaders.get) plus a textureID (the sampler name
 *         bound to readBuffer).
 *         render(renderer, writeBuffer, readBuffer, deltaTime): compiles the shader → binds readBuffer to the
 *         textureID sampler → submits the full-screen quad.
 *         needsSwap=true (after the pass the composer swaps buffers; the next pass reads from here).
 *         Rendering differences: this class feeds a shader name (shaders are registered in PostProcessingShaders.cj
 *         under the full-screen-quad convention, reusing the bgfx compile cache); custom effects must be registered
 *         in PostProcessingShaders first; binding uses the bgfx_get_texture(readBuffer, 0) handle + bgfx_set_texture;
 *         renderToScreen uses an invalid FrameBufferHandle to denote the swap chain.
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*

/**
 * @brief[zh-cn] 通用 shader pass
 * @brief[en] Generic shader pass
 * @explain[zh-cn] 喂已注册全屏 shader 做后处理。
 * @explain[en] Feeds a registered full-screen shader for post-processing.
 */
public open class ShaderPass <: Pass {
    /**
     * @brief[zh-cn] 已注册 shader 名（PostProcessingShaders.get(name) 取）
     * @brief[en] Registered shader name (fetched via PostProcessingShaders.get(name))
     */
    public let shaderName: String

    /**
     * @brief[zh-cn] 纹理 uniform 名（绑 readBuffer 的 sampler），默认 tDiffuse
     * @brief[en] Texture uniform name (sampler bound to readBuffer), default tDiffuse
     */
    public var textureID: String = "tDiffuse"

    /**
     * @brief[zh-cn] 可选的 stencil 测试参考值，Some(ref) 时仅在 stencil==ref 区域渲染
     * @brief[en] Optional stencil test reference value; when Some(ref), only renders where stencil==ref
     * @explain[zh-cn] Some(ref) 时：本 pass submit 前设 stencil 测试 FUNC_EQUAL + REF=ref + op KEEP，
     *         只在 stencil==ref 的区域渲染（配合 MaskPass 标记的遮罩区域使用）。
     *         None（默认）时不设 stencil 测试（全屏渲染）。
     * @explain[en] When Some(ref): sets stencil test FUNC_EQUAL + REF=ref + op KEEP before submit, rendering
     *         only where stencil==ref (used with the mask regions marked by MaskPass).
     *         None (default): no stencil test (full-screen rendering).
     */
    public var stencilTestRef: Option<UInt32> = None

    /**
     * @brief[zh-cn] 渲染前是否清 view，默认 true
     * @brief[en] Whether to clear the view before rendering, default true
     * @explain[zh-cn] 配合 MaskPass 遮罩场景：染色 pass 设 false，保留 writeBuffer 已有内容
     *         （非遮罩区域场景），仅在遮罩区域（stencil 测试通过）叠加染色。
     * @explain[en] With the MaskPass masked scene: a tinting pass sets false to keep the existing writeBuffer
     *         content (non-mask areas) and only tints within the mask (where the stencil test passes).
     */
    public var clearView: Bool = true

    /**
     * view id 基址（200~209 区段，避开 SSAO 160/Bloom/shadow 50~127）。
     * 每个 ShaderPass 实例用 base + index，避免多实例冲突。
     */
    private static var _viewIdPool: UInt16 = 200u16

    /**
     * 本实例的 view id（从 _viewIdPool 递增分配）。
     */
    private let _viewId: UInt16

    /**
     * 是否已编译（避免每帧重编译）。
     */
    private var _compiled: Bool = false

    /**
     * 编译后 program handle 缓存。
     */
    private var _prog: Option<ProgramHandle> = None

    /**
继续     * uniform 注册表缓存（避免每帧创建新 BgfxUniforms 泄漏 bgfx handle）。
     */
    private var _uniforms: Option<BgfxUniforms> = None

    /**
     * @brief[zh-cn] 构造 ShaderPass
     * @brief[en] Constructs ShaderPass
     * @param[zh-cn] shaderName ShaderLibs 已注册的全屏 shader 名
     * @param[zh-cn] textureID 绑 readBuffer 的 sampler 名（默认 tDiffuse）
     * @param[en] shaderName The registered full-screen shader name in ShaderLibs
     * @param[en] textureID The sampler name bound to readBuffer (default tDiffuse)
     * @explain[zh-cn] 全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段），构造不再传 quad。
     * @explain[en] The full-screen quad is held as a singleton by EffectComposer and injected via setQuad (base class quad field); no quad is passed at construction.
     */
    public init(shaderName: String, textureID!: String = "tDiffuse") {
        super()
        this.shaderName = shaderName
        this.textureID = textureID
        // 分配 view id（简单递增，单 composer 链内实例数 < 10）
        this._viewId = ShaderPass._viewIdPool
        ShaderPass._viewIdPool = UInt16(UInt16(ShaderPass._viewIdPool) + 1u16)
        // 默认 needsSwap=true
        this.needsSwap = true
    }

    /**
     * @brief[zh-cn] 执行 shader pass
     * @brief[en] Executes the shader pass
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（renderToScreen=false 时写这里）
     * @param[zh-cn] readBuffer 读 buffer（绑到 textureID sampler）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (written here when renderToScreen=false)
     * @param[en] readBuffer Read buffer (bound to the textureID sampler)
     * @param[en] deltaTime Frame delta time
     */
    public open override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 取 shader + 编译（仅首次）
        // 后处理 shader 已迁移到 postprocessing 内部注册表 PostProcessingShaders
        match (PostProcessingShaders.get(this.shaderName)) {
            case Some(sp) =>
                if (!this._compiled) {
                    sp.compileBgfx()
                    this._prog = Some(Box(sp.programHandle))
                    this._compiled = true
                }
            case None => return
        }
        match (this._prog) {
            case Some(prog) =>
                if (!isValidHandle(prog)) { return }
                let viewId = this._viewId
                let rt = this.renderToScreen
                let w = UInt16(renderer.width)
                let h = UInt16(renderer.height)
                let texId = this.textureID
                // 视口
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                // renderToScreen=true 时写 swap chain（无效 FB handle），否则写 writeBuffer
                let targetFB = if (rt) { INVALID_FRAME_BUFFER_HANDLE } else { writeBuffer }
                this.setRenderTarget(renderer, viewId, targetFB)
                // 默认清 view；clearView=false 时保留 writeBuffer 已有内容
                // （配合 MaskPass 遮罩：非遮罩区域场景保留，仅遮罩区域叠加染色）
                if (this.clearView) {
                    this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
                }

                // 绑 readBuffer 的 color attachment 0 到 textureID sampler（stage 0）
                // 使用缓存的 uniform 注册表，避免每帧创建新 BgfxUniforms 泄漏 bgfx handle
                let uniforms = match (this._uniforms) {
                    case Some(u) => u
                    case None =>
                        let u = BgfxUniforms()
                        this._uniforms = Some(u)
                        u
                }
                let uTex = uniforms.createUniform(texId, UniformType.Sampler.value())
                let readTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uTex, readTex, 0u32)

                // 子类扩展钩子：submit 前绑定额外 uniform（如 FXAAPass 的 u_resolution）
                this.bindExtraUniforms(renderer, uniforms)

                // 可选 stencil 测试（配合 MaskPass 遮罩语义）：
                // Some(ref) 时仅在 stencil==ref 区域渲染（TEST_EQUAL + op KEEP）。
                match (this.stencilTestRef) {
                    case Some(ref) =>
                        let stencilState: UInt32 = ((ref & 0xFFu32) << 0) |    // REF
                                                   (0xFFu32 << 8) |              // RMASK=0xFF
                                                   BgfxConstants.STENCIL_TEST_EQUAL |   // TEST_EQUAL
                                                   BgfxConstants.STENCIL_OP_FAIL_S_KEEP | // OP_FAIL_S_KEEP
                                                   BgfxConstants.STENCIL_OP_FAIL_Z_KEEP | // OP_FAIL_Z_KEEP
                                                   BgfxConstants.STENCIL_OP_PASS_Z_KEEP   // OP_PASS_Z_KEEP
                        this.setStencil(renderer, stencilState, stencilState)
                    case None => ()
                }

                this.submitQuad(viewId, prog)
                // 不在此调 present：frame 统一由 EffectComposer.render 末尾触发
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 子类扩展钩子：在 submit 前绑定额外 uniform
     * @brief[en] Subclass extension hook: binds extra uniforms before submit
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] uniforms 已创建 tDiffuse sampler 的 uniform 注册表（可继续创建额外 uniform）
     * @param[en] renderer Renderer
     * @param[en] uniforms The uniform registry where the tDiffuse sampler has been created (extra uniforms can be added)
     * @explain[zh-cn] 基类默认 no-op；FXAAPass override 本方法设置 u_resolution。
     *         bgfx 需在 submit 前经 uniforms 注册表 createUniform + bgfx_set_uniform_cj 绑定。
     * @explain[en] Base class defaults to no-op; FXAAPass overrides this method to set u_resolution.
     *         In bgfx, uniforms must be bound via the uniform registry createUniform + bgfx_set_uniform_cj before submit.
     */
    public open func bindExtraUniforms(renderer: ThreeRenderer, uniforms: BgfxUniforms): Unit {}

    /**
     * @brief[zh-cn] 释放 ShaderPass 占用的 GPU 资源
     * @brief[en] Releases the GPU resources held by ShaderPass
     * @explain[zh-cn] shader 由 ShaderLibs 全局缓存，不 dispose；quad 由 composer 管理。
     * @explain[en] Shaders are globally cached by ShaderLibs and not disposed; the quad is managed by the composer.
     */
    public open override func dispose(): Unit {
        this._compiled = false
        this._prog = None
        match (this._uniforms) {
            case Some(u) => u.dispose()
            case None => ()
        }
        this._uniforms = None
    }
}
