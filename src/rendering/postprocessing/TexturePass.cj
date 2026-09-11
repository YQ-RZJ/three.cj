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
 * @file[zh-cn] BgfxTexturePass 纹理 pass
 * @brief[zh-cn] 纹理 pass —— 把一张纹理渲满屏（带 opacity）
 * @explain[zh-cn] 持 map: TextureHandle（待渲纹理）+ opacity: Float64。
 *         用 CopyShader 把 map 按 opacity 渲到 readBuffer 或屏幕。
 *         needsSwap=false（本 pass 是"贴图覆盖"，不交换主链）。
 *         本 pass 直接喂 bgfx TextureHandle（caller 用 bgfx_create_texture_2d 或从 BgfxTextures 取）。
 *         透明度在 shader 内 texel * opacity（alpha 由 COPY shader 乘），
 *         与 EffectComposer 双 RT ping-pong 一致（RT 颜色非预乘）。
 *
 * @file[en] BgfxTexturePass texture pass
 * @brief[en] Texture pass - renders a texture full-screen (with opacity)
 * @explain[en] Holds map: TextureHandle (texture to render) + opacity: Float64.
 *         Uses CopyShader to render the map to readBuffer or the screen, multiplied by opacity.
 *         needsSwap=false (this pass is a "texture overlay" and does not swap the main chain).
 *         This pass feeds a bgfx TextureHandle directly (caller uses bgfx_create_texture_2d
 *         or fetches from BgfxTextures). Opacity is applied in the shader as texel * opacity
 *         (alpha is multiplied by the COPY shader), consistent with EffectComposer's two-RT
 *         ping-pong (RT colors are not premultiplied).
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] 贴纹理 pass
 * @brief[en] Texture overlay pass
 * @explain[zh-cn] 把一张纹理渲满屏（带 opacity）。
 * @explain[en] Renders a texture full-screen (with opacity).
 */
public class TexturePass <: Pass {
    /**
     * @brief[zh-cn] 待渲纹理（bgfx TextureHandle）
     * @brief[en] Texture to render (bgfx TextureHandle)
     */
    public var map: TextureHandle

    /**
     * @brief[zh-cn] 不透明度 [0,1]，默认 1.0（完全不透明）
     * @brief[en] Opacity [0,1], default 1.0 (fully opaque)
     */
    public var opacity: Float64 = 1.0

    /**
     * view id（211，避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209/SavePass 210）。
     */
    private static let _viewId: UInt16 = 211u16

    /**
     * 已编译 program handle 缓存。
     */
    private var _prog: Option<ProgramHandle> = None

    /**
     * @brief[zh-cn] 构造 TexturePass
     * @brief[en] Constructs TexturePass
     * @param[zh-cn] map 待渲纹理（bgfx TextureHandle）
     * @param[zh-cn] opacity 不透明度（默认 1.0）
     * @param[en] map Texture to render (bgfx TextureHandle)
     * @param[en] opacity Opacity (default 1.0)
     * @explain[zh-cn] 全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     * @explain[en] The full-screen quad is held as a singleton by EffectComposer and injected via setQuad (base class quad field).
     */
    public init(map: TextureHandle, opacity!: Float64 = 1.0) {
        super()
        this.map = map
        this.opacity = opacity
        // 本 pass 是"贴图覆盖"，不交换主链
        this.needsSwap = false
    }

    /**
     * @brief[zh-cn] 执行纹理 pass：把 map 渲到 readBuffer 或屏幕
     * @brief[en] Executes the texture pass: renders the map to readBuffer or the screen
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 不用，结果写 readBuffer 或屏幕）
     * @param[zh-cn] readBuffer 读 buffer（renderToScreen=false 时写这里）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (unused by this pass; result goes to readBuffer or screen)
     * @param[en] readBuffer Read buffer (written here when renderToScreen=false)
     * @param[en] deltaTime Frame delta time
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 取 CopyShader + 编译（仅首次）
        // 后处理 shader 已迁移到 postprocessing 内部注册表 PostProcessingShaders
        match (this._prog) {
            case None =>
                match (PostProcessingShaders.get("copy")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._prog = Some(Box(sp.programHandle))
                    case None => return
                }
            case Some(_) => ()
        }
        match (this._prog) {
            case Some(prog) =>
                if (!isValidHandle(prog)) { return }
                let viewId = TexturePass._viewId
                let w = UInt16(renderer.width)
                let h = UInt16(renderer.height)
                let rt = this.renderToScreen
                let op = this.opacity
                let texHandle = this.map
                // 视口
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                // renderToScreen=true 时写 swap chain，否则写 readBuffer
                let targetFB = if (rt) { INVALID_FRAME_BUFFER_HANDLE } else { readBuffer }
                this.setRenderTarget(renderer, viewId, targetFB)
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

                // 绑 map 到 tDiffuse sampler（stage 0）
                let uniforms = BgfxUniforms()
                let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uTex, texHandle, 0u32)

                // opacity uniform
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let opacityMem = BgfxMemory(16u32)
                opacityMem.writeFloats([op, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

                this.submitQuad(viewId, prog)
                // 不在此调 present：frame 统一由 EffectComposer.render 末尾触发
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 释放 TexturePass 占用的 GPU 资源
     * @brief[en] Releases the GPU resources held by TexturePass
     * @explain[zh-cn] shader 为全局缓存不 dispose；纹理由 caller 管理。
     * @explain[en] Shaders are globally cached and not disposed; textures are managed by the caller.
     */
    public override func dispose(): Unit {
        this._prog = None
    }
}
