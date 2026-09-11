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
 * @file[zh-cn] BgfxSavePass 保存 pass
 * @brief[zh-cn] 保存 pass —— 把当前 read buffer 内容拷贝到内部 RT（供后续 pass 取用）
 * @explain[zh-cn] 持内部 renderTarget（color RT，RGBA16F，无 depth）。
 *         用 CopyShader 把 readBuffer 拷到 renderTarget。
 *         needsSwap=false（pass 后不交换 buffer；本 pass 是"旁支保存"，主链 readBuffer 不变）。
 *         资源模型：bgfx 用 TextureHandle + FrameBufferHandle，setSize 时销毁重建；
 *         绑定用 bgfx_get_texture(readBuffer, 0) 取纹理句柄。
 *
 * @file[en] BgfxSavePass save pass
 * @brief[en] Save pass - copies the current read buffer into an internal RT (for later passes)
 * @explain[en] Holds an internal renderTarget (color RT, RGBA16F, no depth).
 *         Uses CopyShader to copy the readBuffer into the renderTarget.
 *         needsSwap=false (does not swap buffers after the pass; this pass is a "side-branch save"
 *         and the main chain readBuffer stays unchanged).
 *         Resource model: bgfx uses TextureHandle + FrameBufferHandle, destroyed and rebuilt on setSize;
 *         binding fetches the texture handle via bgfx_get_texture(readBuffer, 0).
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] 保存 pass
 * @brief[en] Save pass
 * @explain[zh-cn] 把 readBuffer 拷到内部 renderTarget。
 * @explain[en] Copies the readBuffer into the internal renderTarget.
 */
public class SavePass <: Pass {
    /**
     * @brief[zh-cn] 内部 render target（color RT，RGBA16F，无 depth）
     * @brief[en] Internal render target (color RT, RGBA16F, no depth)
     */
    public var renderTarget: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /**
     * 内部 RT 的 color 纹理句柄（dispose 用）。
     */
    private var _rtColor: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * view id（210，避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209）。
     */
    private static let _viewId: UInt16 = 210u16

    /**
     * RT 是否已创建（避免重复创建）。
     */
    private var _rtCreated: Bool = false

    /**
     * 已编译 program handle 缓存。
     */
    private var _prog: Option<ProgramHandle> = None

    /**
     * RT 尺寸（setSize 后更新）。
     */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    /**
     * 渲染器引用（render() 时缓存，setSize/dispose 经其高阶 API 序列化）。
     */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * @brief[zh-cn] 构造 SavePass
     * @brief[en] Constructs SavePass
     * @explain[zh-cn] 全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     * @explain[en] The full-screen quad is held as a singleton by EffectComposer and injected via setQuad (base class quad field).
     */
    public init() {
        super()
        // 保存后不交换 buffer
        this.needsSwap = false
    }

    /**
     * 创建内部 RT（RGBA16F color，无 depth）。
     * 参照 EffectComposer._createRTs 范式（但无 depth attachment，SavePass 仅存颜色）。
     */
    private func _createRT(renderer: ThreeRenderer, width: UInt16, height: UInt16): Unit {
        // 先销毁旧 RT
        if (this._rtCreated) {
            renderer.destroyFrameBuffer(this.renderTarget)
            renderer.destroyTexture(this._rtColor)
        }
        let colorFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
        this._rtColor = renderer.createTexture2D(width, height, false, 1u16, TextureFormat.RGBA16F.value(), colorFlags, None)
        // 单 color attachment 的 frame buffer（无 depth）：handles 数组只放 color
        let handles = Array<TextureHandle>(1, { _ => this._rtColor })
        this.renderTarget = renderer.createFrameBuffer(1u8, handles, true)
        this._rtCreated = true
    }

    /**
     * @brief[zh-cn] 设置内部 RT 尺寸（销毁重建）
     * @brief[en] Sets the internal RT size (destroy and rebuild)
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        this._width = width
        this._height = height
        match (this._renderer) {
            case Some(renderer) => this._createRT(renderer, UInt16(width), UInt16(height))
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 执行保存 pass：拷 readBuffer 到 renderTarget
     * @brief[en] Executes the save pass: copies the readBuffer into the renderTarget
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 不用，结果存 renderTarget）
     * @param[zh-cn] readBuffer 读 buffer（拷贝源）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (unused by this pass; result goes to renderTarget)
     * @param[en] readBuffer Read buffer (copy source)
     * @param[en] deltaTime Frame delta time
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // 若 setSize 早于首帧 render（composer.addPass 时 renderer 未缓存），此处懒创建 RT
        if (!this._rtCreated && this._width > 0 && this._height > 0) {
            this._createRT(renderer, UInt16(this._width), UInt16(this._height))
        }
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
        if(let Some(prog) <- this._prog){
            if (!isValidHandle(prog)) { return }
            let viewId = SavePass._viewId
            let w = UInt16(this._width)
            let h = UInt16(this._height)
            // 视口
            this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
            this.setRenderTarget(renderer, viewId, this.renderTarget)
            this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

            // 绑 readBuffer color 0 到 tDiffuse sampler（stage 0）
            let uniforms = BgfxUniforms()
            let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
            let readTex = this.getTexture(renderer, readBuffer, 0u8)
            this.bindTexture(renderer, 0u8, uTex, readTex, 0u32)

            // opacity uniform = 1.0
            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
            let opacityMem = BgfxMemory(16u32)
            opacityMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
            this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

            this.submitQuad(viewId, prog)
        }
    }

    /**
     * @brief[zh-cn] 释放 SavePass 占用的 GPU 资源（内部 RT）
     * @brief[en] Releases the GPU resources held by SavePass (internal RT)
     */
    public override func dispose(): Unit {
        if (this._rtCreated) {
            match (this._renderer) {
                case Some(renderer) =>
                    renderer.destroyFrameBuffer(this.renderTarget)
                    renderer.destroyTexture(this._rtColor)
                case None => ()
            }
            this._rtCreated = false
        }
        this._prog = None
    }
}
