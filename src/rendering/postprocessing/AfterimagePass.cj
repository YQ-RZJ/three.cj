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
 * @file[zh-cn] BgfxAfterimagePass 残影后处理 pass
 * @brief[zh-cn] 残影后处理 pass —— 当前帧与上一帧残影融合产生拖尾效果
 * @explain[zh-cn] 算法：
 *         result = max(tNew, tOld * damp * when_gt(tOld, 0.1))
 *         - tNew  当前帧输入（readBuffer 的 color 0）
 *         - tOld  上一帧残影纹理（本 pass 内部 ping-pong 的 _textureOld）
 *         - damp  阻尼系数（0~1），越大残影衰减越慢、拖尾越长
 *         - when_gt(x, y) 逐分量阈值门控，把亮度低于 0.1 的残影像素清零
 *         流程：
 *         1. comp pass：tOld=_textureOld, tNew=readBuffer → mix → _textureComp
 *         2. copy pass：把 _textureComp 复制到 writeBuffer（或 renderToScreen 时写屏幕）
 *         3. swap：_textureOld ↔ _textureComp（下一帧用新残影）
 *         渲染差异：bgfx 用两个 frame buffer（_compFB / _oldFB）+ 对应纹理句柄 ping-pong；
 *         bgfx uniform 最小单位 vec4，故用 u_damp(vec4: x=damp)；tOld/tNew 用 SAMPLER2D 宏，
 *         按固定 stage 0=tOld、1=tNew 绑定；copy pass 复用 PostProcessingShaders.get("copy")
 *         shader（tDiffuse + u_opacity），覆盖写 state submit；
 *         view id 用 AFTERIMAGE_VIEW_ID_BASE=221（避开既有硬编码段：SSAO 160 / Bloom 200~212 /
 *         ShaderPass 200~209 / SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 /
 *         SMAA 214~216 / SSAA 217 / TAA 219~220）。
 *
 * @file[en] BgfxAfterimagePass afterimage post-processing pass
 * @brief[en] Afterimage post-processing pass - blends the current frame with the previous frame's afterimage to
 *         produce a trailing effect
 * @explain[en] Algorithm:
 *         result = max(tNew, tOld * damp * when_gt(tOld, 0.1))
 *         - tNew  current frame input (readBuffer color 0)
 *         - tOld  previous frame's afterimage texture (this pass's internal ping-pong _textureOld)
 *         - damp  damping factor (0~1); larger = slower afterimage decay, longer trails
 *         - when_gt(x, y) per-component threshold gating, zeroing afterimage pixels below 0.1 brightness
 *         Flow:
 *         1. comp pass: tOld=_textureOld, tNew=readBuffer → mix → _textureComp
 *         2. copy pass: copies _textureComp to writeBuffer (or to the screen when renderToScreen)
 *         3. swap: _textureOld ↔ _textureComp (the new afterimage is used next frame)
 *         Rendering differences: bgfx uses two frame buffers (_compFB / _oldFB) with their texture handles for
 *         ping-pong; bgfx uniforms have a minimum unit of vec4, so u_damp (vec4: x=damp) is used; tOld/tNew use
 *         the SAMPLER2D macro, bound to fixed stage 0=tOld, 1=tNew; the copy pass reuses the
 *         PostProcessingShaders.get("copy") shader (tDiffuse + u_opacity) with an overwrite-state submit;
 *         the view id uses AFTERIMAGE_VIEW_ID_BASE=221 (avoids existing hardcoded ranges: SSAO 160 /
 *         Bloom 200~212 / ShaderPass 200~209 / SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 /
 *         SMAA 214~216 / SSAA 217 / TAA 219~220).
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.utils.memory.BgfxMemory
import three.utils.memory.AutoFreePtr
import three.utils.log.Logger
import three.rendering.types.*

/**
 * @brief[zh-cn] 残影后处理 pass
 * @brief[en] Afterimage post-processing pass
 * @explain[zh-cn] 持两个内部 RT（_compFB / _oldFB）做 ping-pong 残影累积。
 * @explain[en] Holds two internal RTs (_compFB / _oldFB) for ping-pong afterimage accumulation.
 */
public class AfterimagePass <: Pass {
    /**
     * @brief[zh-cn] 阻尼系数（0~1），越大残影衰减越慢、拖尾越长，默认 0.96
     * @brief[en] Damping factor (0~1); larger = slower afterimage decay, longer trails, default 0.96
     */
    public var damp: Float64

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: comp pass（残影融合）
     *   +1: copy pass（结果输出）
     * 取 221 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
     * TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 / TAA 219~220。
     */
    public static let AFTERIMAGE_VIEW_ID_BASE: UInt16 = 221u16

    /**
     * RT 宽度（全分辨率）。
     */
    private var _width: Int64 = 0

    /**
     * RT 高度（全分辨率）。
     */
    private var _height: Int64 = 0

    /**
     * comp RT（残影融合结果，RGBA16F 半浮点）。
     */
    private var _compFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _compTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * old RT（上一帧残影，RGBA16F 半浮点）。
     */
    private var _oldFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _oldTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * RT 是否已创建。
     */
    private var _rtsCreated: Bool = false

    /**
     * 渲染器引用（render() 时缓存，setSize/dispose 经其高阶 API 序列化）。
     */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * afterimage shader 是否已编译。
     */
    private var _afterimageCompiled: Bool = false

    /**
     * afterimage program handle 缓存。
     */
    private var _afterimageProg: Option<ProgramHandle> = None

    /**
     * copy shader 是否已编译。
     */
    private var _copyCompiled: Bool = false

    /**
     * copy program handle 缓存。
     */
    private var _copyProg: Option<ProgramHandle> = None

    /**
     * 调试标志：是否已清过 old RT（首次渲染前 old RT 应为黑色）。
     * bgfx create_texture_2d_cj 默认不清，首帧 tOld 是垃圾数据 → 残影异常。
     * 故首帧渲染前主动 clear 一次 old RT。
     */
    private var _oldCleared: Bool = false

    /**
     * @brief[zh-cn] 构造 AfterimagePass
     * @brief[en] Constructs AfterimagePass
     * @param[zh-cn] damp 阻尼系数（默认 0.96）
     * @param[en] damp Damping factor (default 0.96)
     */
    public init(damp!: Float64 = 0.96) {
        super()
        this.damp = damp
        // needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
    }

    /**
     * @brief[zh-cn] 设置 pass 尺寸，创建/重建内部双 RT
     * @brief[en] Sets the pass size, creating/rebuilding the internal dual RTs
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width == this._width && height == this._height && this._rtsCreated) {
            return
        }
        this._width = width
        this._height = height
        this._createRTs()
    }

    /**
     * 创建内部双 RT（comp + old），RGBA16F 半浮点。
     *
     * 关键：RT 不需要 depth attachment（afterimage 是纯颜色融合），
     * 故用单纹理 frame buffer（无 depth），节省显存。
     */
    private func _createRTs(): Unit {
        // 先销毁旧 RT
        this._destroyRTs()

        if (this._width <= 0 || this._height <= 0) {
            return
        }

        let w = UInt16(this._width)
        let h = UInt16(this._height)
        let colorFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)

        Logger.trace(["afterimage", "createRTs: " + w.toString() + "x" + h.toString()])

        // comp RT
        match (this._renderer) {
            case Some(renderer) =>
                this._compTex = renderer.createTexture2D(
                    w, h, false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    colorFlags,
                    None)
                this._compFB = this._createFB(renderer, this._compTex)

                // old RT
                this._oldTex = renderer.createTexture2D(
                    w, h, false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    colorFlags,
                    None)
                this._oldFB = this._createFB(renderer, this._oldTex)

                this._rtsCreated = true
                this._oldCleared = false
            case None => ()
        }
        Logger.trace(["afterimage", "RTs created: compFB.idx=" + handleIdx(this._compFB).toString() +
                      " oldFB.idx=" + handleIdx(this._oldFB).toString()])
    }

    /**
     * 创建单纹理 frame buffer（无 depth）。
     */
    private func _createFB(renderer: ThreeRenderer, tex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => tex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /**
     * 销毁内部双 RT。
     */
    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                if (isValidHandle(this._compFB)) {
                    renderer.destroyFrameBuffer(this._compFB)
                    this._compFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (isValidHandle(this._compTex)) {
                    renderer.destroyTexture(this._compTex)
                    this._compTex = INVALID_TEXTURE_HANDLE
                }
                if (isValidHandle(this._oldFB)) {
                    renderer.destroyFrameBuffer(this._oldFB)
                    this._oldFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (isValidHandle(this._oldTex)) {
                    renderer.destroyTexture(this._oldTex)
                    this._oldTex = INVALID_TEXTURE_HANDLE
                }
            case None => ()
        }
        this._rtsCreated = false
    }

    /**
     * 首帧渲染前主动 clear old RT（避免 tOld 初始为垃圾数据）。
     * 用一个空 view touch + clear 实现。
     */
    private func _clearOldRT(renderer: ThreeRenderer): Unit {
        if (this._oldCleared) {
            return
        }
        let viewId = UInt16(AfterimagePass.AFTERIMAGE_VIEW_ID_BASE + 0u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._oldFB)
        // clear color=0（黑色）+ 不清深度
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
        this._oldCleared = true
        Logger.trace(["afterimage", "old RT cleared (first frame)"])
    }

    /**
     * 编译 afterimage shader。
     */
    private func _compileAfterimage(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("afterimage")) {
            case Some(sp) =>
                if (!this._afterimageCompiled) {
                    sp.compileBgfx()
                    this._afterimageProg = Some(Box(sp.programHandle))
                    this._afterimageCompiled = true
                    Logger.trace(["afterimage", "afterimage shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._afterimageProg
            case None =>
                Logger.trace(["afterimage", "afterimage shader not registered"])
                return None
        }
    }

    /**
     * 编译 copy shader。
     */
    private func _compileCopy(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("copy")) {
            case Some(sp) =>
                if (!this._copyCompiled) {
                    sp.compileBgfx()
                    this._copyProg = Some(Box(sp.programHandle))
                    this._copyCompiled = true
                    Logger.trace(["afterimage", "copy shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._copyProg
            case None =>
                Logger.trace(["afterimage", "copy shader not registered"])
                return None
        }
    }

    /**
     * comp pass：残影融合。
     * tOld=_oldTex, tNew=readBuffer → mix → _compFB
     */
    private func _renderComp(
        renderer: ThreeRenderer,
        readBuffer: FrameBufferHandle
    ): Unit {
        let viewId = UInt16(AfterimagePass.AFTERIMAGE_VIEW_ID_BASE + 0u16)
        let w = UInt16(this._width)
        let h = UInt16(this._height)

        // 视口 + 渲染目标 = comp RT
        this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
        this.setRenderTarget(renderer, viewId, this._compFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        match (this._compileAfterimage()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) { return }

                let uniforms = BgfxUniforms()

                // stage 0 = tOld（上一帧残影）
                let uOld = uniforms.createUniform("tOld", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uOld, this._oldTex, 0u32)

                // stage 1 = tNew（当前帧输入 = readBuffer color 0）
                let uNew = uniforms.createUniform("tNew", UniformType.Sampler.value())
                let newTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 1u8, uNew, newTex, 0u32)

                // u_damp（vec4: x=damp）
                let uDamp = uniforms.createUniform("u_damp", UniformType.Vec4.value())
                let dampMem = BgfxMemory(16u32)
                dampMem.writeFloats([this.damp, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uDamp, dampMem, num: 1u16)

                this.submitQuad(viewId, prog)

                Logger.trace(["afterimage", "comp pass: view=" + viewId.toString() +
                              " damp=" + this.damp.toString()])
            case None => ()
        }
    }

    /**
     * copy pass：把 comp RT 复制到 writeBuffer（或 renderToScreen 时写屏幕）。
     */
    private func _renderCopy(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle
    ): Unit {
        let viewId = UInt16(AfterimagePass.AFTERIMAGE_VIEW_ID_BASE + 1u16)
        let w = UInt16(this._width)
        let h = UInt16(this._height)

        // 视口
        this.setViewport(renderer, viewId, 0u16, 0u16, w, h)

        // renderToScreen=true 时写 swap chain（无效 FB handle），否则写 writeBuffer
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        match (this._compileCopy()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) { return }

                let uniforms = BgfxUniforms()

                // stage 0 = tDiffuse（comp RT 的纹理）
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiffuse, this._compTex, 0u32)

                // u_opacity（vec4: x=opacity=1.0，完全透传）
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let opMem = BgfxMemory(16u32)
                opMem.writeFloats([1.0, 1.0, 1.0, 1.0], 4)
                this.setUniform(renderer, uOpacity, opMem, num: 1u16)

                this.submitQuad(viewId, prog)

                Logger.trace(["afterimage", "copy pass: view=" + viewId.toString() +
                              " renderToScreen=" + this.renderToScreen.toString()])
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 执行 afterimage pass
     * @brief[en] Executes the afterimage pass
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（copy pass 的输出目标）
     * @param[zh-cn] readBuffer 读 buffer（当前帧输入，绑到 tNew）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (output target of the copy pass)
     * @param[en] readBuffer Read buffer (current frame input, bound to tNew)
     * @param[en] deltaTime Frame delta time
     * @explain[zh-cn] 流程：1. comp pass：tOld=_oldTex, tNew=readBuffer → mix → _compFB；
     *         2. copy pass：把 _compFB 复制到 writeBuffer（或屏幕）；
     *         3. swap：_oldFB ↔ _compFB，_oldTex ↔ _compTex（下一帧用新残影）。
     * @explain[en] Flow: 1. comp pass: tOld=_oldTex, tNew=readBuffer → mix → _compFB;
     *         2. copy pass: copies _compFB to writeBuffer (or screen);
     *         3. swap: _oldFB ↔ _compFB, _oldTex ↔ _compTex (the new afterimage is used next frame).
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        if (!this._rtsCreated) {
            this.setSize(this._width, this._height)
        }
        if (!this._rtsCreated) { return }
        if (!isValidHandle(this._compFB) || !isValidHandle(this._oldFB)) { return }

        // 首帧前清 old RT（避免 tOld 初始为垃圾数据）
        this._clearOldRT(renderer)

        // ===== 1. comp pass（残影融合）=====
        this._renderComp(renderer, readBuffer)

        // ===== 2. copy pass（结果输出）=====
        this._renderCopy(renderer, writeBuffer)

        // ===== 3. swap（_oldFB ↔ _compFB，_oldTex ↔ _compTex）=====
        let tmpFB = this._oldFB
        this._oldFB = this._compFB
        this._compFB = tmpFB

        let tmpTex = this._oldTex
        this._oldTex = this._compTex
        this._compTex = tmpTex

        Logger.trace(["afterimage", "swap done: oldFB.idx=" + handleIdx(this._oldFB).toString() +
                      " compFB.idx=" + handleIdx(this._compFB).toString()])
    }

    /**
     * @brief[zh-cn] 释放 afterimage pass 占用的所有 GPU 资源
     * @brief[en] Releases all GPU resources held by the afterimage pass
     * @explain[zh-cn] shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
     *         全屏 quad 由 EffectComposer 持单例统一管理。
     * @explain[en] The shader programs are managed globally by PostProcessingShaders and are not disposed here;
     *         the full-screen quad is managed as a singleton by EffectComposer.
     */
    public override func dispose(): Unit {
        this._destroyRTs()
        // shader program 由 PostProcessingShaders 全局管理，不在此 dispose
        // 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose
        Logger.trace(["afterimage", "disposed"])
    }
}
