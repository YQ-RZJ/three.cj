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
 * @file[zh-cn] TAARenderPass 时间抗锯齿渲染 pass
 * @brief[zh-cn] 时间抗锯齿渲染 pass —— 跨帧累加 jitter 样本
 * @explain[zh-cn] 算法（TAA，extends SSAARenderPass）：
 *         - accumulate=false：直接 super.render()（单次场景渲染，无累加），accumulateIndex 复位 -1
 *         - accumulate=true：
 *             1. 若 accumulateIndex==-1：super.render(renderer, holdRT, readBuffer)
 *                首帧 SSAA 渲染（sampleLevel=0 → 单样本 [0,0] 无抖动）写入 holdRT（"基础帧"），
 *                accumulateIndex=0
 *             2. jitterOffsets = _JitterVectors[5]（固定 32 样本）
 *                sampleWeight = 1.0 / 32
 *             3. 若 accumulateIndex ∈ [0, 32)：
 *                  numSamplesPerFrame = 2^sampleLevel（TAA 默认 1 样本/帧）
 *                  for i in 0..numSamplesPerFrame：
 *                    j = accumulateIndex；jitter = jitterOffsets[j]
 *                    camera.setViewOffset(jitter × 0.0625)
 *                    renderer.render(scene, camera) → writeBuffer（当前帧抖动样本）
 *                    copy shader（opacity=sampleWeight，加性）→ sampleRT
 *                      （accumulateIndex==0 时先清 sampleRT；之后跨帧累加不清）
 *                    accumulateIndex++
 *                    若 >= 32 break
 *                  camera.clearViewOffset()
 *             4. accumulationWeight = accumulateIndex × sampleWeight
 *                if accumulationWeight > 0：
 *                  copy sampleRT（opacity=1.0，覆盖写）→ writeBuffer
 *                if accumulationWeight < 1.0：
 *                  copy holdRT（opacity=1-accumulationWeight，加性）→ writeBuffer
 *             5. 关键：sampleRT 是"跨帧累加池"（仅 accumulateIndex==0 时清黑一次，
 *                之后每帧 + 当前样本×sampleWeight 不清除）。32 帧后 accumulateIndex=32，
 *                accumulationWeight=1.0，writeBuffer = sampleRT = 完整 32 样本平均结果。
 *                holdRT 是首帧无抖动"基础帧"，前 32 帧以 (1-accumulationWeight) 权重补充画面。
 *         正确渲染效果（供测试对照）：
 *         - 场景静止时：画面从首帧起逐帧累积，约 32 帧后达到完整 32 样本 AA 结果（最清晰、
 *           锯齿最少），画面稳定不再变化（scene 静止时 TAA 收敛）。
 *         - 场景运动时：无重投影（非 TRAA），旧样本残留在 sampleRT 中产生拖影/残影；
 *           运动越大残影越明显（该效果不使用 reprojection）。
 *         - accumulate=false 时退化为单次渲染（同 SSAARenderPass sampleLevel=0，无 AA 效果）。
 *         渲染差异：
 *         - _sampleRenderTarget 由父类持有；本 pass 复用父类 protected _sampleFB。
 *         - _holdRenderTarget 用 bgfx FrameBufferHandle（RGBA16F color only，无 depth attachment）。
 *         - renderer.autoClear=false 手动控制 clear；bgfx 用 bgfx_set_view_clear_cj flags=0 不清。
 *         - copy shader 经 BgfxUniforms.createUniform("u_opacity"/"tDiffuse")。
 *         - 加性混合 = src*1 + dst*1（makeBlendFunc(ONE, ONE)）。
 *         序列化约束（★关键，同 SSAARenderPass）：
 *         renderer.render(scene, camera) 内部走 _execBgfx（同步等待），_execBgfx 不可重入。
 *         故本 pass 的"每 jitter 样本"流程拆为多步顺序执行，各步独立 _execBgfx，不嵌套。
 *         super.render 调用同样独立执行（不包进 execBgfx 闭包）。
 *         用法：
 *         let taaPass = TAARenderPass(scene, camera, quad)
 *         taaPass.accumulate = true   // 启用跨帧累加
 *         composer.addPass(taaPass)
 *
 * @file[en] TAARenderPass temporal antialiasing render pass
 * @brief[en] Temporal antialiasing render pass - accumulates jittered samples across frames
 * @explain[en] Algorithm (TAA, extends SSAARenderPass):
 *         - accumulate=false: directly calls super.render() (single scene render, no accumulation); accumulateIndex reset to -1
 *         - accumulate=true:
 *             1. If accumulateIndex==-1: super.render(renderer, holdRT, readBuffer)
 *                First frame SSAA render (sampleLevel=0 → single sample [0,0] without jitter) written to holdRT ("base frame"),
 *                accumulateIndex=0
 *             2. jitterOffsets = _JitterVectors[5] (fixed 32 samples)
 *                sampleWeight = 1.0 / 32
 *             3. If accumulateIndex ∈ [0, 32):
 *                  numSamplesPerFrame = 2^sampleLevel (TAA default 1 sample/frame)
 *                  for i in 0..numSamplesPerFrame:
 *                    j = accumulateIndex; jitter = jitterOffsets[j]
 *                    camera.setViewOffset(jitter × 0.0625)
 *                    renderer.render(scene, camera) → writeBuffer (current frame jittered sample)
 *                    copy shader (opacity=sampleWeight, additive) → sampleRT
 *                      (clear sampleRT first when accumulateIndex==0; keep cross-frame accumulation afterwards)
 *                    accumulateIndex++
 *                    break if >= 32
 *                  camera.clearViewOffset()
 *             4. accumulationWeight = accumulateIndex × sampleWeight
 *                if accumulationWeight > 0:
 *                  copy sampleRT (opacity=1.0, overwrite) → writeBuffer
 *                if accumulationWeight < 1.0:
 *                  copy holdRT (opacity=1-accumulationWeight, additive) → writeBuffer
 *             5. Key: sampleRT is a "cross-frame accumulation pool" (cleared to black only when accumulateIndex==0,
 *                then each frame + current sample × sampleWeight without clearing). After 32 frames accumulateIndex=32,
 *                accumulationWeight=1.0, writeBuffer = sampleRT = full 32-sample average result.
 *                holdRT is the first-frame non-jittered "base frame", supplementing the picture with weight (1-accumulationWeight) for the first 32 frames.
 *         Correct render result (for testing reference):
 *         - Static scene: picture accumulates frame by frame from the first frame, reaching the full 32-sample AA result after ~32 frames (sharpest,
 *           least aliasing), then stable (TAA converges when the scene is static).
 *         - Moving scene: no reprojection (not TRAA), old samples remain in sampleRT producing ghosting/afterimage;
 *           the bigger the motion the more visible the ghosting (this effect uses no reprojection).
 *         - accumulate=false degrades to a single render (same as SSAARenderPass sampleLevel=0, no AA).
 *         Rendering differences:
 *         - _sampleRenderTarget is held by the parent class; this pass reuses the parent's protected _sampleFB.
 *         - _holdRenderTarget uses bgfx FrameBufferHandle (RGBA16F color only, no depth attachment).
 *         - renderer.autoClear=false controls clear manually; bgfx uses bgfx_set_view_clear_cj flags=0 to not clear.
 *         - copy shader via BgfxUniforms.createUniform("u_opacity"/"tDiffuse").
 *         - Additive blending = src*1 + dst*1 (makeBlendFunc(ONE, ONE)).
 *         Serialization constraint (★critical, same as SSAARenderPass):
 *         renderer.render(scene, camera) internally goes through _execBgfx (synchronously waits); _execBgfx is not reentrant.
 *         So this pass's "per-jitter sample" flow is split into multiple sequential steps, each with an independent _execBgfx, no nesting.
 *         The super.render call also executes independently (not wrapped in an execBgfx closure).
 *         Usage:
 *         let taaPass = TAARenderPass(scene, camera, quad)
 *         taaPass.accumulate = true   // enable cross-frame accumulation
 *         composer.addPass(taaPass)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.bgfx.BgfxBackend
import three.rendering.types.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.cameras.*
import three.scene.scenegraph.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import std.collection.*
import std.math.*

/**
 * TAA jitter 向量表（索引 5 = 32 样本）。
 * TAARenderPass 固定使用 _JitterVectors[5]（32 样本），跨帧累加。
 */
public let TAA_JITTER_VECTORS: Array<Array<Array<Int64>>> = [
    // sampleLevel = 0：1 样本
    [[0, 0]],
    // sampleLevel = 1：2 样本
    [[4, 4], [-4, -4]],
    // sampleLevel = 2：4 样本
    [[-2, -6], [6, -2], [-6, 2], [2, 6]],
    // sampleLevel = 3：8 样本
    [[1, -3], [-1, 3], [5, 1], [-3, -5], [-5, 5], [-7, -1], [3, 7], [7, -7]],
    // sampleLevel = 4：16 样本
    [
        [1, 1], [-1, -3], [-3, 2], [4, -1],
        [-5, -2], [2, 5], [5, 3], [3, -5],
        [-2, 6], [0, -7], [-4, -6], [-6, 4],
        [-8, 0], [7, -4], [6, 7], [-7, -8]
    ],
    // sampleLevel = 5：32 样本（TAA 固定使用此级别）
    [
        [-4, -7], [-7, -5], [-3, -5], [-5, -4],
        [-1, -4], [-2, -2], [-6, -1], [-4, 0],
        [-7, 1], [-1, 2], [-6, 3], [-3, 3],
        [-7, 6], [-3, 6], [-5, 7], [-1, 7],
        [5, -7], [1, -6], [6, -5], [4, -4],
        [2, -3], [7, -2], [1, -1], [4, -1],
        [2, 1], [6, 2], [0, 4], [4, 4],
        [2, 5], [7, 5], [5, 6], [3, 7]
    ]
]

/**
 * @brief[zh-cn] 时间抗锯齿渲染 pass
 * @brief[en] Temporal antialiasing render pass
 * @explain[zh-cn] 跨帧累加 jitter 样本（无重投影，故非 TRAA）。
 * @explain[en] Accumulates jittered samples across frames (no reprojection, so not TRAA).
 */
public class TAARenderPass <: SSAARenderPass {
    /**
     * TAA pass 用的 view ID 段约定（避开 SSAO 160/Bloom/shadow 50~127/
     * ShaderPass 200~209/SavePass 210/TexturePass 211/OutputPass 212/FXAAPass 213/
     * SMAA 214~216/SSAA 217）。
     * - TAA_VIEW_ACCUM（219）：copy shader 把 writeBuffer × sampleWeight 加性累加到 sampleRT
     * - TAA_VIEW_HOLD（220）：最终合成 writeBuffer = sampleRT（覆盖）+ holdRT×残留（加性）
     */
    public static let TAA_VIEW_ACCUM: UInt16 = 219u16
    public static let TAA_VIEW_HOLD: UInt16 = 220u16

    /**
     * 是否累加帧。false 时直接 super.render()（单次场景渲染，无累加）。
     * 默认 false。
     */
    public var accumulate: Bool = false

    /**
     * 累加索引。-1 表示未开始累加，0..jitterOffsets.length-1 表示当前累加到的样本。
     * 默认 -1。
     */
    public var accumulateIndex: Int64 = -1

    /**
     * hold RT 的 color 纹理（RGBA16F，HalfFloatType，无 depth）。
     */
    private var _holdTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * hold RT 的 frame buffer。
     */
    private var _holdFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /**
     * hold RT 是否已创建。
     */
    private var _holdCreated: Bool = false

    /**
     * 上次记录的相机位置（用于检测视角变化）。
     * TAA 无重投影：accumulateIndex 达到 jitterCount(32) 后场景不再渲染，
     * 画面固定。为支持"视角可移动"，检测相机 position 变化时重置
     * accumulateIndex=-1，触发重新累积（画面跟随新视角收敛）。
     */
    private var _lastCamX: Float64 = 0.0
    private var _lastCamY: Float64 = 0.0
    private var _lastCamZ: Float64 = 0.0
    private var _hasCam: Bool = false

    /**
     * 构造 TAARenderPass。
     *
     * @param scene 待渲染场景
     * @param camera 待渲染相机
     * @param clearColor clear 颜色（默认透明黑）
     * @param clearAlpha clear alpha（默认 0）
     *
     * 差异：全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     */
    public init(
        scene: Scene,
        camera: Camera,
        clearColor!: UInt32 = 0x00000000u32,
        clearAlpha!: Float64 = 0.0
    ) {
        super(scene, camera, clearColor: clearColor, clearAlpha: clearAlpha)
        // TAA 默认 sampleLevel=0（TAA 固定使用 _JitterVectors[5]（32 样本）做跨帧 jitter；
        // sampleLevel 仅用于 numSamplesPerFrame = 2^sampleLevel（默认 1 样本/帧）。）
        this.sampleLevel = 0
        // TAA 默认 needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
    }

    /**
     * 设置 pass 尺寸（重建内部 sampleRT + holdRT）。
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        // 尺寸未变且 sampleRT+holdRT 均已创建，跳过
        if (width == this._width && height == this._height && this._rtsCreated && this._holdCreated) {
            return
        }
        // 父类 SSAARenderPass.setSize 重建 sampleRT（有尺寸守卫）
        super.setSize(width, height)
        // 重建 holdRT（销毁旧 + 创建新）—— 经缓存的 renderer 高阶 API 序列化
        match (this._renderer) {
            case Some(renderer) =>
                if (this._holdCreated) {
                    renderer.destroyFrameBuffer(this._holdFB)
                    renderer.destroyTexture(this._holdTex)
                    this._holdTex = INVALID_TEXTURE_HANDLE
                    this._holdFB = INVALID_FRAME_BUFFER_HANDLE
                    this._holdCreated = false
                }
                if (width <= 0 || height <= 0) {
                    return
                }
                let w = UInt16(width)
                let h = UInt16(height)
                let rtFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
                // hold RT：RGBA16F color only（无 depth attachment）
                this._holdTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.RGBA16F.value(), rtFlags, None)
                let handles = Array<TextureHandle>(1, { _ => this._holdTex })
                this._holdFB = renderer.createFrameBuffer(1u8, handles, true)
                this._holdCreated = true
            case None => ()
        }
        Logger.trace(["TAARenderPass", "setSize done ${width}x${height} holdFB.idx=${handleIdx(this._holdFB)}"])
    }

    /**
     * 执行 TAA 渲染 pass。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（累加结果输出；renderToScreen=true 时写屏幕）
     * @param readBuffer 读 buffer（TAA 不直接用 readBuffer，而是渲染场景到 writeBuffer/sampleRT）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // accumulate=false：直接 super.render()（单次场景渲染，无累加）
        if (!this.accumulate) {
            super.render(renderer, writeBuffer, readBuffer, deltaTime)
            this.accumulateIndex = -1
            return
        }

        // accumulate=true：跨帧累加
        // 检测相机视角变化：TAA 无重投影，相机移动后旧累积样本失真；
        //   重置 accumulateIndex=-1 让下一帧重新累积（super.render 刷新 holdRT），
        //   从而画面跟随新视角收敛（否则 accumulateIndex 达 32 后场景不再渲染，
        //   画面永远固定为旧视角）。
        let camPos = this.camera.position
        if (this._hasCam) {
            let d = abs(camPos.x - this._lastCamX) + abs(camPos.y - this._lastCamY) + abs(camPos.z - this._lastCamZ)
            if (d > 0.0001) {
                this.accumulateIndex = -1
            }
        }
        this._lastCamX = camPos.x
        this._lastCamY = camPos.y
        this._lastCamZ = camPos.z
        this._hasCam = true

        // 编译 copy shader（仅首次，复用父类 _copyProg）
        this._ensureCopyCompiled()
        match (this._copyProg) {
            case Some(copyProg) =>
                if (!isValidHandle(copyProg)) { return }
                this._renderTAA(renderer, writeBuffer, readBuffer, deltaTime, copyProg)
            case None => ()
        }
    }

    /**
     * 实际执行跨帧累加 TAA。
     *
     * 序列化约束（★关键，同 SSAARenderPass）：
     *   renderer.render(scene, camera) 内部走 _execBgfx（同步等待），_execBgfx 不可重入。
     *   故本 pass 的"每 jitter 样本"流程拆为多步顺序执行，各步独立 _execBgfx，不嵌套。
     */
    private func _renderTAA(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64,
        copyProg: ProgramHandle
    ): Unit {
        let rw = renderer.width
        let rh = renderer.height
        let rt = this.renderToScreen
        let viewId = renderer.viewId
        let alphaByte = UInt32(Int32(this.clearAlpha * 255.0)) & 0xFFu32
        let colWithAlpha = ((this.clearColor & 0x00FFFFFFu32) << 8) | alphaByte
        let clearFlags: UInt16 = BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH  // CLEAR_COLOR | CLEAR_DEPTH

        // 确保 sampleRT（父类）与 holdRT 已创建（若 setSize 未调，首帧 lazy 创建）
        if (!isValidHandle(this._sampleFB) || !this._holdCreated) {
            this.setSize(Int64(rw), Int64(rh))
        }
        if (!isValidHandle(this._sampleFB) || !this._holdCreated) { return }

        // jitterOffsets = _JitterVectors[5]（32 样本，TAA 固定）
        let jitterOffsets = TAA_JITTER_VECTORS[5]
        let jitterCount = jitterOffsets.size
        // sampleWeight = 1.0 / jitterOffsets.length
        let sampleWeight = 1.0 / Float64(jitterCount)

        // ===== 首帧：accumulateIndex==-1 → super.render(holdRT)，accumulateIndex=0 =====
        if (this.accumulateIndex == -1) {
            // super.render = SSAARenderPass.render（sampleLevel=0 → 1 样本 [0,0] 无抖动）
            // 把首帧场景写入 holdRT（"基础帧"）。
            // 注意：super.render 内部会确保 sampleRT 已创建并编译 copy shader。
            //       _rtsCreated/_holdCreated 此时已为 true（上方 setSize），super 不会重建。
            super.render(renderer, this._holdFB, readBuffer, deltaTime)
            this.accumulateIndex = 0
        }

        // ===== 累加循环（accumulateIndex ∈ [0, 32)）=====
        if (this.accumulateIndex >= 0 && this.accumulateIndex < jitterCount) {
            // numSamplesPerFrame = 2^sampleLevel（TAA 默认 1）
            let numSamplesPerFrame = Int64(pow(2.0, Float64(this.sampleLevel)))
            var i: Int64 = 0
            while (i < numSamplesPerFrame) {
                let j = this.accumulateIndex
                let jitterOffset = jitterOffsets[j]

                // camera.setViewOffset 抖动（jitter × 0.0625，映射到 [-0.5,0.5)）
                match (this.camera) {
                    case p: PerspectiveCamera =>
                        p.setViewOffset(
                            Float64(rw), Float64(rh),
                            Float64(jitterOffset[0]) * 0.0625,
                            Float64(jitterOffset[1]) * 0.0625,
                            Float64(rw), Float64(rh)
                        )
                    case _ => ()
                }

                // 设 view 0 frame buffer = writeBuffer + clear，渲染当前帧抖动样本
                // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
                this.setRenderTarget(renderer, viewId, writeBuffer)
                this.clearRenderTarget(renderer, viewId, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)
                renderer.render(this.scene, this.camera)

                // copy shader：writeBuffer × sampleWeight 加性 → sampleRT（跨帧累加池）
                // accumulateIndex==0 时先清 sampleRT（黑），之后跨帧累加不清除。
                let sampleView = TAARenderPass.TAA_VIEW_ACCUM
                let sw = Float32(sampleWeight)
                let clearSample = (j == 0)

                // 设累加 view 的 rect + frame buffer（sampleRT）
                // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
                this.setViewport(renderer, sampleView, 0u16, 0u16, UInt16(rw), UInt16(rh))
                this.setRenderTarget(renderer, sampleView, this._sampleFB)
                if (clearSample) {
                    // 首样本：清 sampleRT 为黑（CLEAR_COLOR，颜色 0）
                    this.clearRenderTarget(renderer, sampleView, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
                } else {
                    // 后续样本：不清除，保留跨帧累加结果
                    this.clearRenderTarget(renderer, sampleView, 0x0000u16, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
                }

                // 绑 writeBuffer color 0 到 tDiffuse sampler
                let uniforms = BgfxUniforms()
                let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let writeTex = this.getTexture(renderer, writeBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uTex, writeTex, 0u32)

                // u_opacity.x = sampleWeight
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let opacityMem = BgfxMemory(16u32)
                opacityMem.writeFloats([Float64(sw), 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

                // 加性混合：BGFX_STATE_BLEND_FUNC(ONE, ONE) = src*1 + dst*1
                let blendState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                    BgfxBackend.makeBlendFunc(BgfxConstants.BLEND_ONE, BgfxConstants.BLEND_ONE)

                // 必须用 submitWithState：submit() 内部会覆盖 state 为覆盖写，加性累加失效
                this.submitQuadWithState(sampleView, copyProg, blendState)

                this.accumulateIndex = this.accumulateIndex + 1
                if (this.accumulateIndex >= jitterCount) {
                    break
                }
                i++
            }

            // camera.clearViewOffset（恢复）
            match (this.camera) {
                case p: PerspectiveCamera => p.clearViewOffset()
                case _ => ()
            }
        }

        // ===== 最终合成 writeBuffer = sampleRT（覆盖）+ holdRT×残留（加性）=====
        //   accumulationWeight = accumulateIndex × sampleWeight
        //   if accumulationWeight > 0：copy sampleRT opacity=1.0 → writeBuffer（覆盖）
        //   if accumulationWeight < 1.0：copy holdRT opacity=1-accumulationWeight → writeBuffer（加性）
        // 关键：合成目标始终是离屏 writeBuffer（而非屏幕 swap chain）。
        //   renderer.render 内部 finishRender 每次都会 bgfx_frame（双缓冲交换）；
        //   若合成直接写屏幕 + 逐分支 bgfx_frame，back buffer 在步骤间被交换，
        //   加性混合叠加到残留 buffer → 画面越亮/闪烁。
        //   故先合成到离屏 writeBuffer，最后一步（步骤 f）统一拷到屏幕 + 单次 bgfx_frame。
        let accumulationWeight = Float64(this.accumulateIndex) * sampleWeight

        // if accumulationWeight > 0：copy sampleRT（opacity=1.0，覆盖写，先清）
        if (accumulationWeight > 0.0) {
            let finalView = TAARenderPass.TAA_VIEW_HOLD
            // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
            this.setViewport(renderer, finalView, 0u16, 0u16, UInt16(rw), UInt16(rh))
            this.setRenderTarget(renderer, finalView, writeBuffer)
            this.clearRenderTarget(renderer, finalView, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)

            // 绑 sampleRT color 0 到 tDiffuse sampler
            let uniforms = BgfxUniforms()
            let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
            let sampleTex = this.getTexture(renderer, this._sampleFB, 0u8)
            this.bindTexture(renderer, 0u8, uTex, sampleTex, 0u32)

            // u_opacity.x = 1.0
            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
            let opacityMem = BgfxMemory(16u32)
            opacityMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
            this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

            // 普通混合（覆盖写）
            let blendState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW

            this.submitQuadWithState(finalView, copyProg, blendState)
            // 注意：此处不调 bgfx_frame —— 上屏由步骤 f 统一处理
        }

        // if accumulationWeight < 1.0：copy holdRT（opacity=1-accumulationWeight，加性）
        if (accumulationWeight < 1.0) {
            let finalView2 = TAARenderPass.TAA_VIEW_HOLD
            let holdWeight = Float32(1.0 - accumulationWeight)
            // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
            this.setViewport(renderer, finalView2, 0u16, 0u16, UInt16(rw), UInt16(rh))
            this.setRenderTarget(renderer, finalView2, writeBuffer)
            // 不清除，加性叠加到已有 writeBuffer
            this.clearRenderTarget(renderer, finalView2, 0x0000u16, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

            // 绑 holdRT color 0 到 tDiffuse sampler
            let uniforms = BgfxUniforms()
            let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
            let holdTex = this.getTexture(renderer, this._holdFB, 0u8)
            this.bindTexture(renderer, 0u8, uTex, holdTex, 0u32)

            // u_opacity.x = 1 - accumulationWeight
            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
            let opacityMem = BgfxMemory(16u32)
            opacityMem.writeFloats([Float64(holdWeight), 0.0, 0.0, 0.0], 4)
            this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

            // 加性混合：BGFX_STATE_BLEND_FUNC(ONE, ONE) = src*1 + dst*1
            let blendState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                BgfxBackend.makeBlendFunc(BgfxConstants.BLEND_ONE, BgfxConstants.BLEND_ONE)

            // 必须用 submitWithState：submit() 内部会覆盖 state 为覆盖写，加性累加失效
            this.submitQuadWithState(finalView2, copyProg, blendState)
            // 注意：此处不调 bgfx_frame —— 上屏由步骤 f 统一处理
        }

        // ===== f. renderToScreen=true 时：把合成结果一次性拷到屏幕 + 触发一次 bgfx_frame =====
        if (rt) {
            let outputView = TAARenderPass.TAA_VIEW_HOLD  // 复用合成 view
            // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
            this.setViewport(renderer, outputView, 0u16, 0u16, UInt16(rw), UInt16(rh))
            // 写屏幕（swap chain = 无效 FB handle）
            this.setRenderTarget(renderer, outputView, INVALID_FRAME_BUFFER_HANDLE)
            this.clearRenderTarget(renderer, outputView, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)

            // 绑 writeBuffer color 0 到 tDiffuse sampler
            let uniforms = BgfxUniforms()
            let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
            let writeTex = this.getTexture(renderer, writeBuffer, 0u8)
            this.bindTexture(renderer, 0u8, uTex, writeTex, 0u32)

            // u_opacity.x = 1.0（覆盖写，非加性）
            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
            let opacityMem = BgfxMemory(16u32)
            opacityMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
            this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

            // 普通覆盖写状态
            let state = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW
            this.submitQuadWithState(outputView, copyProg, state)
            // 不在此调 bgfx_frame：frame 统一由 EffectComposer.render 末尾触发
            // （bgfx_frame 是双缓冲交换，每帧仅一次；pass 只负责 submit）
        }
    }

    /**
     * 释放 TAARenderPass 占用的所有 GPU 资源（holdRT + copy shader）。
     */
    public override func dispose(): Unit {
        // 销毁 holdRT
        match (this._renderer) {
            case Some(renderer) =>
                if (this._holdCreated) {
                    renderer.destroyFrameBuffer(this._holdFB)
                    renderer.destroyTexture(this._holdTex)
                    this._holdTex = INVALID_TEXTURE_HANDLE
                    this._holdFB = INVALID_FRAME_BUFFER_HANDLE
                    this._holdCreated = false
                }
            case None => ()
        }
        // 父类 SSAARenderPass.dispose 销毁 sampleRT + copy shader
        super.dispose()
    }

    // ===== 内部辅助 =====

    /**
     * 编译 copy shader（仅首次，复用父类 _copyProg）。
     */
    private func _ensureCopyCompiled(): Unit {
        if (this._copyProg.isSome()) {
            return
        }
        // 后处理 shader 已迁移到 postprocessing 内部注册表 PostProcessingShaders
        match (PostProcessingShaders.get("copy")) {
            case Some(sp) =>
                sp.compileBgfx()
                this._copyProg = Some(Box(sp.programHandle))
            case None => Logger.warn(["TAARenderPass", "shader copy not found"])
        }
    }
}
