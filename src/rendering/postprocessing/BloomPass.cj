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
 * @file[zh-cn] BloomPass Bloom 后处理 pass（简单版）
 * @brief[zh-cn] Bloom 后处理 pass（简单版）——水平/垂直高斯卷积 + 强度合成
 * @explain[zh-cn] 算法（简单版 Bloom，3 个 pass）：
 *         1. 水平卷积 pass：ConvolutionShader，uImageIncrement = blurX = (0.001953125, 0)
 *           → renderTargetX（场景水平模糊）
 *         2. 垂直卷积 pass：ConvolutionShader，uImageIncrement = blurY = (0, 0.001953125)
 *           → renderTargetY（水平结果再垂直模糊）
 *         3. 合成 pass：CombineShader（scene + strength × blur，AdditiveBlending）
 *           → 读回 readBuffer（场景）叠加模糊结果
 *         与 UnrealBloomPass 的关系：
 *         - BloomPass：基础效果，1 遍水平 + 1 遍垂直高斯卷积（kernelSize 默认 25 / sigma 默认 4），开销小
 *         - UnrealBloomPass：高级效果，5 级金字塔 mip 模糊 + 加权合成，开销大
 *         - 两者是独立 Pass 类，可分别挂载到 EffectComposer
 *         渲染差异：
 *         - 两个中间 RT 用半浮点（RGBA16F）
 *         - bgfx view id 全局稀缺，本 pass 用 BLOOM_VIEW_ID_BASE=237 段（避开 SSAO 160 /
 *           UnrealBloom 200~212 / Afterimage 221 / Outline 223 / Film 224 / Glitch 225 /
 *           DotScreen 226 / Halftone 227 / Bokeh 228）
 *         - CombineShader 依赖 AdditiveBlending 叠加；bgfx 无全局混合状态，
 *           改为 shader 内显式相加 sceneColor + strength × blurColor（见 BLOOM_COMBINE_FS）
 *         - cKernel 是 float 数组；bgfx uniform 数组按 vec4 对齐，cKernel[i].x=系数
 *         - defines KERNEL_SIZE_FLOAT/INT 在材质创建时固化；bgfx 在首次编译时经
 *           compileBgfxWithDefines 传入
 *
 * @file[en] BloomPass Bloom post-processing pass (simple version)
 * @brief[en] Bloom post-processing pass (simple version) - horizontal/vertical Gaussian
 *         convolution + intensity combine
 * @explain[en] Algorithm (simple Bloom, 3 passes):
 *         1. Horizontal convolution pass: ConvolutionShader, uImageIncrement = blurX = (0.001953125, 0)
 *           → renderTargetX (scene horizontally blurred)
 *         2. Vertical convolution pass: ConvolutionShader, uImageIncrement = blurY = (0, 0.001953125)
 *           → renderTargetY (horizontal result blurred vertically)
 *         3. Combine pass: CombineShader (scene + strength × blur, AdditiveBlending)
 *           → read back into readBuffer (scene) with blur added
 *         Relation to UnrealBloomPass:
 *         - BloomPass: basic effect, 1 horizontal + 1 vertical Gaussian convolution
 *           (kernelSize default 25 / sigma default 4), low cost
 *         - UnrealBloomPass: advanced effect, 5-level mip pyramid blur + weighted combine, high cost
 *         - They are independent Pass classes mountable on an EffectComposer
 *         Rendering differences:
 *         - The two intermediate RTs use half float (RGBA16F)
 *         - bgfx view ids are globally scarce; this pass uses the BLOOM_VIEW_ID_BASE=237 range
 *           (avoiding SSAO 160 / UnrealBloom 200~212 / Afterimage 221 / Outline 223 / Film 224 /
 *           Glitch 225 / DotScreen 226 / Halftone 227 / Bokeh 228)
 *         - CombineShader relies on AdditiveBlending; bgfx has no global blend state,
 *           so the shader explicitly adds sceneColor + strength × blurColor (see BLOOM_COMBINE_FS)
 *         - cKernel is a float array; bgfx uniforms align to vec4, cKernel[i].x = coefficient
 *         - defines KERNEL_SIZE_FLOAT/INT are fixed at material creation; bgfx passes them in at
 *           first compile via compileBgfxWithDefines
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
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] Bloom 后处理 pass（简单版）
 * @brief[en] Bloom post-processing pass (simple version)
 * @explain[zh-cn] 水平 + 垂直各一遍高斯卷积 + strength 合成回场景。
 * @explain[en] One horizontal and one vertical Gaussian convolution pass, then combine the
 *         blurred result back into the scene scaled by strength.
 */
public class BloomPass <: Pass {
    /**
     * @brief[zh-cn] Bloom 强度（合成时 blur 乘数）
     * @brief[en] Bloom strength (blur multiplier at combine)
     * @explain[zh-cn] 默认 1.0。
     * @explain[en] Default 1.0.
     */
    public var strength: Float64

    /**
     * @brief[zh-cn] 卷积核大小（shader 循环次数）
     * @brief[en] Kernel size (shader loop count)
     * @explain[zh-cn] 默认 25，决定卷积采样范围。
     * @explain[en] Default 25, determines the convolution sampling range.
     */
    public var kernelSize: Int64

    /**
     * @brief[zh-cn] 高斯 sigma（控制核展宽，buildKernel 用）
     * @brief[en] Gaussian sigma (controls kernel spread, used by buildKernel)
     * @explain[zh-cn] 默认 4。
     * @explain[en] Default 4.
     */
    public var sigma: Float64

    /**
     * 卷积采样步长（水平方向），固定值，与 RT 尺寸无关。
     */
    private static let BLUR_X: Float64 = 0.001953125

    /**
     * 卷积采样步长（垂直方向），固定值。
     */
    private static let BLUR_Y: Float64 = 0.001953125

    /**
     * 最大卷积核尺寸（buildKernel 上限）。
     */
    private static let MAX_KERNEL_SIZE: Int64 = 25

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: 水平卷积（readBuffer → renderTargetX）
     *   +1: 垂直卷积（renderTargetX → renderTargetY）
     *   +2: 合成（scene + strength × blur → 屏幕 / readBuffer）
     * 取 237 起避开既有硬编码段：SSAO 160 / SSR 176 / Bloom(Unreal) 200~212 /
     * Mask 220 / Afterimage 221~223 / Outline 223 / Film 224 / Glitch 225 /
     * DotScreen 226 / Halftone 227 / Bokeh 228~229 / Pixelated 230~233 /
     * Transition 234~236。
     */
    public static let BLOOM_VIEW_ID_BASE: UInt16 = 237u16

    /**
     * RT 宽度（全分辨率）。
     */
    private var _width: Int64 = 0

    /**
     * RT 高度（全分辨率）。
     */
    private var _height: Int64 = 0

    /**
     * 中间 RT X（水平卷积结果）。
     */
    private var _rtXFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _rtXTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 中间 RT Y（垂直卷积结果）。
     */
    private var _rtYFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _rtYTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * RT 是否已创建。
     */
    private var _rtsCreated: Bool = false

    /**
     * 渲染器引用（render() 时缓存，setSize/dispose 经其高阶 API 序列化）。
     */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * 归一化高斯核系数（buildKernel(sigma) 结果，补齐到 kernelSize 长度）。
     */
    private var _kernel: Array<Float64> = Array<Float64>(0, { _ => 0.0 })

    /**
     * 构造 BgfxBloomPass。
     *
     * @param strength Bloom 强度（默认 1.0）
     * @param kernelSize 卷积核大小（默认 25，shader 循环次数）
     * @param sigma 高斯 sigma（默认 4，决定核实际展宽）
     *
     * needsSwap=false（结果直接合成回 readBuffer，不依赖 composer swap）。
     */
    public init(strength!: Float64 = 1.0, kernelSize!: Int64 = 25, sigma!: Float64 = 4.0) {
        super()
        this.strength = strength
        this.kernelSize = kernelSize
        this.sigma = sigma
        this.needsSwap = false
        // 预计算归一化高斯核（buildKernel），补齐到 kernelSize 长度供 vec4 对齐上传
        this._kernel = this._buildKernel(sigma, kernelSize)
    }

    /**
     * 计算归一化高斯核。
     *   kernelSize = min(2 * ceil(sigma * 3) + 1, 25)
     *   halfWidth = (kernelSize - 1) * 0.5
     *   values[i] = gauss(i - halfWidth, sigma) / sum   // 归一化
     *
     * 差异：实际核长度 = min(2 * ceil(sigma*3) + 1, 25)（可能 < 构造参数 kernelSize），
     * shader 循环仍按构造参数 kernelSize 次。cj 侧统一补齐到 kernelSize 长度（尾部补 0），
     * 使 cKernel uniform 数组长度与 KERNEL_SIZE_INT 完全一致，避免越界/未定义读取。
     *
     * @param sigma 高斯 sigma
     * @param kernelSize 目标数组长度（= 构造参数 kernelSize，shader KERNEL_SIZE_INT）
     * @return 归一化高斯核（长度 = kernelSize）
     */
    private func _buildKernel(sigma: Float64, kernelSize: Int64): Array<Float64> {
        var n = 2 * Int64(ceil(sigma * 3.0)) + 1
        if (n > BloomPass.MAX_KERNEL_SIZE) { n = BloomPass.MAX_KERNEL_SIZE }
        let halfWidth = (Float64(n) - 1.0) * 0.5
        let values = Array<Float64>(n, { _ => 0.0 })
        var sum = 0.0
        for (i in 0..n) {
            let x = Float64(i) - halfWidth
            values[i] = exp(-(x * x) / (2.0 * sigma * sigma))
            sum += values[i]
        }
        // 归一化
        for (i in 0..n) {
            values[i] = values[i] / sum
        }
        // 补齐到 kernelSize（尾部补 0，与 KERNEL_SIZE_INT 循环一致）
        let padded = Array<Float64>(kernelSize, { _ => 0.0 })
        for (i in 0..n) {
            padded[i] = values[i]
        }
        return padded
    }

    /**
     * 设置 pass 尺寸，创建/重建中间 RT。
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
     * 创建两个中间 RT（RGBA16F，无 depth）。
     */
    private func _createRTs(): Unit {
        this._destroyRTs()
        if (this._width <= 0 || this._height <= 0) {
            return
        }
        let flags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
        match (this._renderer) {
            case Some(renderer) =>
                this._rtXTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    flags,
                    None)
                this._rtXFB = this._createFB(renderer, this._rtXTex)

                this._rtYTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    flags,
                    None)
                this._rtYFB = this._createFB(renderer, this._rtYTex)

                this._rtsCreated = true
            case None => ()
        }
        Logger.trace(["BloomPass", "RTs created: ${this._width}x${this._height} rtX=${handleIdx(this._rtXTex)} rtY=${handleIdx(this._rtYTex)}"])
    }

    /**
     * 创建单纹理 frame buffer（无 depth）。
     * 对照 UnrealBloomPass._createFB。
     */
    private func _createFB(renderer: ThreeRenderer, tex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => tex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /**
     * 销毁两个中间 RT。
     */
    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                if (isValidHandle(this._rtXFB)) {
                    renderer.destroyFrameBuffer(this._rtXFB)
                    this._rtXFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (isValidHandle(this._rtXTex)) {
                    renderer.destroyTexture(this._rtXTex)
                    this._rtXTex = INVALID_TEXTURE_HANDLE
                }
                if (isValidHandle(this._rtYFB)) {
                    renderer.destroyFrameBuffer(this._rtYFB)
                    this._rtYFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (isValidHandle(this._rtYTex)) {
                    renderer.destroyTexture(this._rtYTex)
                    this._rtYTex = INVALID_TEXTURE_HANDLE
                }
            case None => ()
        }
        this._rtsCreated = false
    }

    /**
     * 执行 Bloom pass。
     *
     * 流程：
     *   1. 水平卷积：readBuffer → renderTargetX
     *   2. 垂直卷积：renderTargetX → renderTargetY
     *   3. 合成：scene + strength × blur → 屏幕（renderToScreen）或 readBuffer
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer
     * @param readBuffer 读 buffer（上一 pass 的场景渲染结果）
     * @param deltaTime 帧间隔
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
        Logger.trace(["BloomPass", "render ENTER strength=${this.strength} kernelSize=${this.kernelSize} sigma=${this.sigma}"])

        // ===== 1. 水平卷积 pass（BLOOM_VIEW_ID_BASE+0）=====
        this._renderConvPass(renderer, 0u16, readBuffer, this._rtXFB, this._rtXTex, BloomPass.BLUR_X, 0.0)

        // ===== 2. 垂直卷积 pass（BLOOM_VIEW_ID_BASE+1）=====
        this._renderConvPass(renderer, 1u16, this._rtXFB, this._rtYFB, this._rtYTex, 0.0, BloomPass.BLUR_Y)

        // ===== 3. 合成 pass（BLOOM_VIEW_ID_BASE+2）=====
        this._renderCombine(renderer, readBuffer)
    }

    /**
     * 单遍高斯卷积 pass（水平或垂直）。
     *
     * @param renderer 渲染器
     * @param viewOffset view id 偏移（0=水平，1=垂直）
     * @param inputFB 输入 frame buffer（读）
     * @param outFB 输出 frame buffer（写）
     * @param outTex 输出纹理（供下一步采样）
     * @param incX 步长 x（blurX.x 或 0）
     * @param incY 步长 y（0 或 blurY.y）
     */
    private func _renderConvPass(
        renderer: ThreeRenderer,
        viewOffset: UInt16,
        inputFB: FrameBufferHandle,
        outFB: FrameBufferHandle,
        outTex: TextureHandle,
        incX: Float64,
        incY: Float64
    ): Unit {
        let viewId = UInt16(UInt16(BloomPass.BLOOM_VIEW_ID_BASE) + viewOffset)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, outFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let progOpt = PostProcessingShaders.get("bloom_conv")
        match (progOpt) {
            case Some(sp) =>
                // 首次使用按 kernelSize 编译（KERNEL_SIZE_FLOAT / KERNEL_SIZE_INT 两个 define）
                if (isValidHandle(Box(sp.programHandle))) {
                    let defSizeF = "KERNEL_SIZE_FLOAT=" + Float64(this.kernelSize).toString()
                    let defSizeI = "KERNEL_SIZE_INT=" + this.kernelSize.toString()
                    sp.compileBgfx(extraDefines: [defSizeF, defSizeI])
                    Logger.trace(["BloomPass", "conv shader compiled: KERNEL_SIZE_FLOAT=${defSizeF} KERNEL_SIZE_INT=${defSizeI}"])
                }
                let prog = Box(sp.programHandle)
                if (!isValidHandle(prog)) { return }

                let uniforms = BgfxUniforms()
                // tDiffuse（输入纹理，水平=readBuffer / 垂直=renderTargetX）
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                let inputTex = this.getTexture(renderer, inputFB, 0u8)
                this.bindTexture(renderer, 0u8, uDiffuse, inputTex, 0u32)

                // uImageIncrement（卷积步长，xy=增量）
                let uInc = uniforms.createUniform("uImageIncrement", UniformType.Vec4.value())
                let incMem = BgfxMemory(16u32)
                incMem.writeFloats([incX, incY, 0.0, 0.0], 4)
                this.setUniform(renderer, uInc, incMem)

                // cKernel（归一化高斯核，vec4 数组：x=系数，yzw=padding）
                let uKernel = uniforms.createUniform("cKernel", UniformType.Vec4.value(), UInt16(this.kernelSize))
                let kernMem = BgfxMemory(UInt32(this.kernelSize * 16))
                let kernFloats: Array<Float64> = Array<Float64>(this.kernelSize * 4, { _ => 0.0 })
                for (i in 0..this.kernelSize) {
                    kernFloats[i * 4 + 0] = this._kernel[i]
                }
                kernMem.writeFloats(kernFloats, Int64(kernFloats.size))
                this.setUniform(renderer, uKernel, kernMem, num: UInt16(this.kernelSize))

                Logger.trace(["BloomPass", "conv pass view=${viewId} inc=(${incX}, ${incY}) kernel[0]=${this._kernel[0]} kernel[1]=${this._kernel[1]} outTex=${handleIdx(outTex)}"])
                this.submitQuad(viewId, prog)
            case None => ()
        }
    }

    /**
     * 合成 pass：scene + strength × blur 叠加回 readBuffer（或 renderToScreen 时写屏幕）。
     *
     * bgfx 差异：依赖 AdditiveBlending 混合状态把 blur 叠加到 readBuffer 既有内容；
     * bgfx 无全局混合状态，shader 内显式采样 scene(readBuffer) + blur(renderTargetY) 相加。
     */
    private func _renderCombine(renderer: ThreeRenderer, readBuffer: FrameBufferHandle): Unit {
        let viewId = UInt16(BloomPass.BLOOM_VIEW_ID_BASE + 2u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        // renderToScreen=true 时写 swap chain（无效 FB handle），否则写 readBuffer（后续 pass 可读）
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, readBuffer)
        }
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let progOpt = PostProcessingShaders.get("bloom_combine")
        match (progOpt) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    sp.compileBgfx()
                }
                let prog = Box(sp.programHandle)
                if (!isValidHandle(prog)) { return }

                let uniforms = BgfxUniforms()
                // stage 0 = readBuffer 场景
                let uScene = uniforms.createUniform("bloomScene", UniformType.Sampler.value())
                let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)

                // stage 1 = 垂直卷积结果（renderTargetY）
                let uBlur = uniforms.createUniform("bloomBlur", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uBlur, this._rtYTex, 0u32)

                // uStrength
                let uStrength = uniforms.createUniform("uStrength", UniformType.Vec4.value())
                let sMem = BgfxMemory(16u32)
                sMem.writeFloats([this.strength, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uStrength, sMem)

                Logger.trace(["BloomPass", "combine view=${viewId} renderToScreen=${this.renderToScreen} strength=${this.strength} sceneTex=${handleIdx(sceneTex)} blurTex=${handleIdx(this._rtYTex)}"])
                this.submitQuad(viewId, prog)
            case None => ()
        }
    }

    /**
     * 释放 bloom pass 占用的所有 GPU 资源。
     */
    public override func dispose(): Unit {
        this._destroyRTs()
        // 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose
    }
}
