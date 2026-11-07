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
 * @file[zh-cn] UnrealBloomPass Bloom 后处理 pass
 * @brief[zh-cn] Bloom 后处理 pass —— UnrealBloomPass 完整实现
 * @explain[zh-cn] 算法（UnrealBloom 完整 5 级金字塔）：
 *         1. 亮度提取 pass：从 readBuffer 采样，threshold 之上的像素写入 bright RT
 *         2. 高斯金字塔（5 级 mip）：
 *           for each level i (0..4):
 *             a. 水平模糊：colorTexture = inputRT, direction=X → renderTargetsHorizontal[i]
 *             b. 垂直模糊：colorTexture = renderTargetsHorizontal[i], direction=Y → renderTargetsVertical[i]
 *             inputRT = renderTargetsVertical[i]
 *         3. composite pass：5 个 blurTexture 加权混合 → renderTargetsHorizontal[0]
 *         4. blend pass：bloom 结果加性叠加回 readBuffer → writeBuffer（屏幕）
 *         可分离高斯：kernelSizeArray = [6, 10, 14, 18, 22]，每级 kernel 半径递增。
 *         bloomFactors = [1.0, 0.8, 0.6, 0.4, 0.2]，大 mip 贡献小。
 *
 * @file[en] UnrealBloomPass Bloom post-processing pass
 * @brief[en] Bloom post-processing pass - full UnrealBloomPass implementation
 * @explain[en] Algorithm (full UnrealBloom 5-level pyramid):
 *         1. Brightness extraction pass: samples readBuffer, pixels above threshold go to the bright RT
 *         2. Gaussian pyramid (5 mip levels):
 *           for each level i (0..4):
 *             a. Horizontal blur: colorTexture = inputRT, direction=X → renderTargetsHorizontal[i]
 *             b. Vertical blur: colorTexture = renderTargetsHorizontal[i], direction=Y → renderTargetsVertical[i]
 *             inputRT = renderTargetsVertical[i]
 *         3. Composite pass: weighted mix of 5 blur textures → renderTargetsHorizontal[0]
 *         4. Blend pass: additively adds the bloom result back to readBuffer → writeBuffer (screen)
 *         Separable Gaussian: kernelSizeArray = [6, 10, 14, 18, 22], kernel radius grows per level.
 *         bloomFactors = [1.0, 0.8, 0.6, 0.4, 0.2], larger mips contribute less.
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.utils.safe.IReleasable
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.BgfxMemory
import three.utils.memory.AutoFreePtr
import three.utils.log.*
import three.utils.log.macros.*
import std.collection.*
import std.math.*
import three.profiler.*
import three.profiler.macros.*

/**
 * 单级金字塔 RT 资源（水平 + 垂直各一个 RT）。
 */
public class BloomMipLevel {
    /** 水平模糊输出 RT（width × height） */
    public var horizontalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    /** 水平模糊输出纹理 */
    public var horizontalTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 垂直模糊输出 RT */
    public var verticalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    /** 垂直模糊输出纹理 */
    public var verticalTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 该级宽度 */
    public var width: Int64 = 0
    /** 该级高度 */
    public var height: Int64 = 0
    /** 高斯核半径（6/10/14/18/22） */
    public var kernelRadius: Int64 = 0
    /**
     * @brief[zh-cn] 预计算的高斯系数（vec4 数组：x=系数，yzw=padding）
     * @explain[zh-cn] 系数只取决于 kernelRadius，与帧无关。原实现在每次模糊 pass
     *               （每帧 5 级 × 2 方向 = 10 次）都重新分配数组并重算系数，
     *               属纯重复计算 + 堆分配。此处按级别预计算一次并复用。
     *
     * @brief[en] Precomputed Gaussian coefficients (vec4 array: x=coefficient, yzw=padding)
     * @explain[en] The coefficients depend only on kernelRadius and are frame-invariant.
     *              The previous implementation reallocated the array and recomputed them
     *              on every blur pass (5 levels × 2 directions = 10 times per frame) —
     *              pure repeated computation plus heap allocation. Now precomputed per level.
     */
    public var gaussCoefs: Array<Float64> = Array<Float64>(0, { _ => 0.0 })

    public init() {}
}

/**
 * @brief[zh-cn] Bloom 后处理 pass（UnrealBloom 完整 5 级金字塔实现）
 * @explain[zh-cn] 亮度提取 → 5 级高斯金字塔模糊 → 加权合成 → 加性叠加回场景。
 *
 * @brief[en] Bloom post-processing pass (full 5-level pyramid UnrealBloom implementation)
 * @explain[en] Brightness extraction → 5-level Gaussian pyramid blur → weighted composite → additive
 *         blend back into the scene.
 */
public class UnrealBloomPass <: Pass & IReleasable {
    /**
     * @brief[zh-cn] Bloom 强度
     * @explain[zh-cn] 控制整体 bloom 贡献量。
     *
     * @brief[en] Bloom strength
     * @explain[en] Controls overall bloom contribution.
     */
    public var strength: Float64

    /**
     * @brief[zh-cn] 亮度阈值（超过此亮度才贡献 bloom）
     * @explain[zh-cn] 低于阈值的像素不参与 bloom。
     *
     * @brief[en] Brightness threshold (pixels above this brightness contribute to bloom)
     * @explain[en] Pixels below the threshold do not contribute to bloom.
     */
    public var threshold: Float64

    /**
     * @brief[zh-cn] Bloom 半径（0~1）
     * @explain[zh-cn] 决定模糊扩散范围。
     *
     * @brief[en] Bloom radius (0~1)
     * @explain[en] Determines the blur spread range.
     */
    public var radius: Float64

    /**
     * 金字塔级数（固定 5）。
     */
    public let nMips: Int64 = 5

    /**
     * 各级高斯核半径，逐级递增。
     */
    public let kernelSizeArray: Array<Int64> = [6, 10, 14, 18, 22]

    /**
     * 各级 bloom 因子（大 mip 贡献小）。
     */
    public let bloomFactors: Array<Float64> = [1.0, 0.8, 0.6, 0.4, 0.2]

    /**
     * RT 宽度（全分辨率）。
     */
    private var _width: Int64 = 0

    /**
     * RT 高度（全分辨率）。
     */
    private var _height: Int64 = 0

    /**
     * bright RT（亮度提取结果，半分辨率）。
     */
    private var _brightFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _brightTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 金字塔各级 RT（5 级，水平 + 垂直）。
     */
    private var _mipLevels: ArrayList<BloomMipLevel> = ArrayList<BloomMipLevel>()

    /**
     * RT 是否已创建。
     */
    private var _rtsCreated: Bool = false

    /** 渲染器引用（render() 时缓存，setSize/dispose 经其高阶 API 创建/销毁资源） */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: 亮度提取
     *   +1..+10: 5 级 × (水平+垂直)
     *   +11: composite
     *   +12: blend（写屏幕）
     * 取 200 起避开阴影（64+）/SSAO（160+）段。
     */
    public static let BLOOM_VIEW_ID_BASE: UInt16 = 200u16

    /**
     * 构造 BgfxUnrealBloomPass。
     *
     * @param strength Bloom 强度
     * @param threshold 亮度阈值
     * @param radius Bloom 半径
     */
    public init(strength!: Float64 = 1.0, threshold!: Float64 = 1.0, radius!: Float64 = 0.4) {
        super()
        this.strength = strength
        this.threshold = threshold
        this.radius = radius
        // needsSwap=false：bloom 最后一步 blend 直接把结果写到 writeBuffer
        // （或 renderToScreen=true 时写屏幕），不依赖 EffectComposer swap 交换 buffer；
        // 若设 true 会与 RenderPass 的 buffer 语义错位。
        this.needsSwap = false
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /**
     * 设置 pass 尺寸，创建/重建所有 RT。
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
     * 创建所有 RT：bright RT + 5 级金字塔（水平+垂直）。
     */
    private func _createRTs(): Unit {
        // 先销毁旧 RT
        this._destroyRTs()

        if (this._width <= 0 || this._height <= 0) {
            return
        }

        if (let Some(renderer) <- this._renderer) {
            // bright RT：半分辨率 RGBA16F
            let bw = this._width / 2
            let bh = this._height / 2
            this._brightTex = renderer.createTexture2D(
                UInt16(bw), UInt16(bh), false, 1u16,
                TextureFormat.RGBA16F.value(),
                BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
                None)
            this._brightFB = this._createFB(renderer, this._brightTex)

            // 5 级金字塔，每级尺寸减半
            var resx = bw
            var resy = bh
            for (i in 0..this.nMips) {
                let level = BloomMipLevel()
                level.width = resx
                level.height = resy
                level.kernelRadius = this.kernelSizeArray[i]
                // 预计算该级高斯系数（与帧无关，仅算一次）
                //   sigma = kernelRadius / 3
                //   coefficients[i] = 0.39894 * exp(-0.5 * i*i / (sigma*sigma)) / sigma
                // shader 声明 uniform vec4 bloomGaussCoefs[KERNEL_RADIUS]（bgfx uniform 数组按 vec4 对齐，
                // 每个 vec4 的 x=系数，yzw=padding）
                let kr = level.kernelRadius
                let sigma = Float64(kr) / 3.0
                let gaussFloats = Array<Float64>(kr * 4, { _ => 0.0 })
                for (gi in 0..kr) {
                    let fi = Float64(gi)
                    gaussFloats[gi * 4 + 0] = 0.39894 * exp(-0.5 * fi * fi / (sigma * sigma)) / sigma
                }
                level.gaussCoefs = gaussFloats

                // 水平模糊 RT
                level.horizontalTex = renderer.createTexture2D(
                    UInt16(resx), UInt16(resy), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
                    None)
                level.horizontalFB = this._createFB(renderer, level.horizontalTex)

                // 垂直模糊 RT
                level.verticalTex = renderer.createTexture2D(
                    UInt16(resx), UInt16(resy), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
                    None)
                level.verticalFB = this._createFB(renderer, level.verticalTex)

                this._mipLevels.add(level)

                resx = resx / 2
                resy = resy / 2
            }

            this._rtsCreated = true
        }
    }

    /**
     * 创建单纹理 frame buffer（无 depth）。
     * 对照 SSAOPass._createFB。
     */
    private func _createFB(renderer: ThreeRenderer, tex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => tex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /**
     * 销毁所有 RT。
     */
    private func _destroyRTs(): Unit {
        if (let Some(renderer) <- this._renderer) {
            if (Handle.isValid(this._brightFB)) {
                renderer.destroyFrameBuffer(this._brightFB)
                this._brightFB = INVALID_FRAME_BUFFER_HANDLE
            }
            if (Handle.isValid(this._brightTex)) {
                renderer.destroyTexture(this._brightTex)
                this._brightTex = INVALID_TEXTURE_HANDLE
            }
            for (level in this._mipLevels) {
                if (Handle.isValid(level.horizontalFB)) {
                    renderer.destroyFrameBuffer(level.horizontalFB)
                    level.horizontalFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (Handle.isValid(level.horizontalTex)) {
                    renderer.destroyTexture(level.horizontalTex)
                    level.horizontalTex = INVALID_TEXTURE_HANDLE
                }
                if (Handle.isValid(level.verticalFB)) {
                    renderer.destroyFrameBuffer(level.verticalFB)
                    level.verticalFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (Handle.isValid(level.verticalTex)) {
                    renderer.destroyTexture(level.verticalTex)
                    level.verticalTex = INVALID_TEXTURE_HANDLE
                }
            }
            this._mipLevels.clear()
        }
        this._rtsCreated = false
    }

    /**
     * 执行 Bloom pass。
     *
     * 流程（对照 UnrealBloomPass.render）：
     *   1. 亮度提取 → bright RT
     *   2. 5 级高斯金字塔（水平+垂直模糊）
     *   3. composite → renderTargetsHorizontal[0]
     *   4. blend → writeBuffer（加性叠加）
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（最终 bloom 结果写入这里）
     * @param readBuffer 读 buffer（上一 pass 的场景渲染结果）
     * @param deltaTime 帧间隔
     */
    @Zone[three.rendering.postprocessing.UnrealBloomPass.render, name=unrealBloomPass]
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // 共享 quad 单例的 renderer 已由 EffectComposer 构造时统一注入（quad.setRenderer），此处无需重复注入
        if (!this._rtsCreated) {
            this.setSize(this._width, this._height)
        }
        if (!this._rtsCreated) { return }
        if (this._mipLevels.size < this.nMips) { return }

        @LogTrace(["UnrealBloom", "render ENTER strength=${this.strength} threshold=${this.threshold} radius=${this.radius} size=${this._width}x${this._height} brightFB=${Handle.idx(this._brightFB)}"])

        // 各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
        // clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
        // 调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
        // 故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。
        // ===== 1. 亮度提取 pass（BLOOM_VIEW_ID_BASE+0）=====
        this._renderLuminosity(renderer, readBuffer)

        // ===== 2. 5 级高斯金字塔（水平+垂直模糊）=====
        this._renderGaussianPyramid(renderer)

        // ===== 3. composite pass（5 个 blurTexture 加权混合）=====
        this._renderComposite(renderer)

        // ===== 4. blend pass（bloom 加性叠加回 readBuffer，写入 writeBuffer）=====
        this._renderBlend(renderer, writeBuffer, readBuffer)
    }

    /**
     * 亮度提取 pass：从 readBuffer 采样，threshold 之上的像素写入 bright RT。
     */
    private func _renderLuminosity(renderer: ThreeRenderer, readBuffer: FrameBufferHandle): Unit {
        let viewId = UInt16(UnrealBloomPass.BLOOM_VIEW_ID_BASE + 0u16)
        let level0 = this._mipLevels[0]
        // 视口设为 level0 尺寸（半分辨率）
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(level0.width), UInt16(level0.height))
        this.setRenderTarget(renderer, viewId, this._brightFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let progOpt = PostProcessingShaders.get("bloom_luminosity")
        if (let Some(sp) <- progOpt) {
            if (!Handle.isValid(Box(sp.programHandle))) {
                sp.compileBgfx()
            }
            let prog = Box(sp.programHandle)
            if (!Handle.isValid(prog)) { return }

            let uniforms = this._passUniforms()
            let readTex = this.getTexture(renderer, readBuffer, 0u8)
            let uDiffuse = this._cachedUniform("bloomDiffuse", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uDiffuse, readTex, 0u32)

            // bloomParams: x=threshold, y=smoothWidth, z=strength, w=0
            let uParams = this._cachedUniform("bloomParams", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uParams, 3, this.threshold, 0.01, this.strength, 0.0)

            @LogTrace(["UnrealBloom", "luminosity view=${viewId} readTex=${Handle.idx(readTex)}brightFB=${Handle.idx(this._brightFB)}}rightTex=${Handle.idx(this._brightTex)} }rams=(threshold=${this.threshold}, smooth=0.01, strength=${this.strength}) viewport=${level0.width}x${level0.height}"])
            this.submitQuad(viewId, prog)
        }
    }

    /**
     * 5 级高斯金字塔：每级水平+垂直可分离高斯模糊。
     *
     * 流程：
     *   inputRT = bright RT
     *   for i in 0..4:
     *     水平：colorTexture=inputRT.texture, direction=X → horizontal[i]
     *     垂直：colorTexture=horizontal[i].texture, direction=Y → vertical[i]
     *     inputRT = vertical[i]
     */
    private func _renderGaussianPyramid(renderer: ThreeRenderer): Unit {
        var inputTex = this._brightTex
        for (i in 0..this.nMips) {
            let level = this._mipLevels[i]
            let baseView = UInt16(UnrealBloomPass.BLOOM_VIEW_ID_BASE + 1u16 + UInt16(i) * 2u16)
            @LogTrace(["UnrealBloom", "pyramid level=${i} baseView=${baseView} size=${level.width}x${level.height} kernelRadius=${level.kernelRadius} inputTex=${Handle.idx(inputTex)}"])

            // 水平模糊 pass（direction=X）
            this._renderBlurPass(
                renderer,
                baseView,
                level.horizontalFB,
                level.horizontalTex,
                inputTex,
                level,
                true  // horizontal
            )

            // 垂直模糊 pass（direction=Y，输入为水平结果）
            this._renderBlurPass(
                renderer,
                UInt16(baseView + 1u16),
                level.verticalFB,
                level.verticalTex,
                level.horizontalTex,
                level,
                false  // vertical
            )

            inputTex = level.verticalTex
        }
    }

    /**
     * 单级可分离高斯模糊 pass（水平或垂直）。
     *
     * @param viewId bgfx view ID
     * @param fb 输出 frame buffer
     * @param fbTex 输出纹理
     * @param inputTex 输入纹理
     * @param level 该级信息（尺寸、kernelRadius）
     * @param horizontal true=水平模糊, false=垂直模糊
     */
    private func _renderBlurPass(
        renderer: ThreeRenderer,
        viewId: UInt16,
        fb: FrameBufferHandle,
        fbTex: TextureHandle,
        inputTex: TextureHandle,
        level: BloomMipLevel,
        horizontal: Bool
    ): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(level.width), UInt16(level.height))
        this.setRenderTarget(renderer, viewId, fb)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        // 使用 bloom_blur_k{radius} 独立变体（PostProcessingShaders 注册了
        // bloom_blur_k6/k10/k14/k18/k22 五个 program），每级 mip 用自己编译的 program，
        // 避免共享单例只按首个 mip 的 KERNEL_RADIUS=6 编译一次、后续各级模糊半径失效。
        let progName = "bloom_blur_k" + level.kernelRadius.toString()
        let progOpt = PostProcessingShaders.get(progName)
        if (let Some(sp) <- progOpt) {
            // 带 KERNEL_RADIUS define 编译
            if (!Handle.isValid(Box(sp.programHandle))) {
                let defineStr = "KERNEL_RADIUS=" + level.kernelRadius.toString()
                sp.compileBgfx(extraDefines: [defineStr])
            }
            let prog = Box(sp.programHandle)
            if (!Handle.isValid(prog)) { return }

            let uniforms = this._passUniforms()
            // colorTexture（输入纹理）
            let uColor = this._cachedUniform("bloomColorTexture", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uColor, inputTex, 0u32)

            // invSize（1/width, 1/height, 0, 0）
            let uInvSize = this._cachedUniform("bloomInvSize", UniformType.Vec4.value())
            this._setVec2Uniform(renderer, uInvSize, 0, 1.0 / Float64(level.width), 1.0 / Float64(level.height))

            // direction（X=1,0 或 Y=0,1）
            let uDir = this._cachedUniform("bloomDirection", UniformType.Vec4.value())
            let dirMem = this._uploadMem(1, 16u32)
            if (horizontal) {
                dirMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
            } else {
                dirMem.writeFloats([0.0, 1.0, 0.0, 0.0], 4)
            }
            this.setUniform(renderer, uDir, dirMem)

            // 高斯系数（预计算，按 kernelRadius 生成）：
            //   sigma = kernelRadius / 3
            //   coefficients[i] = 0.39894 * exp(-0.5 * i*i / (sigma*sigma)) / sigma
            // shader 声明 uniform vec4 bloomGaussCoefs[KERNEL_RADIUS]（bgfx uniform 数组按 vec4 对齐，
            // 每个 vec4 的 x=系数，yzw=padding）
            // 系数已在建 RT 时按级预计算（level.gaussCoefs），此处直接复用。
            let gaussFloats = level.gaussCoefs
            let sigma = Float64(level.kernelRadius) / 3.0
            @LogTrace(["UnrealBloom", "blur view=${viewId} dir=${if (horizontal) { "X" } else { "Y" }} inputTex=${Handle.idx(inputTex)}outFB=${Handle.idx(fb)}}utTex=${Handle.idx(fbTex)} }vSize=(${1.0 / Float64(level.width)}, ${1.0 / Float64(level.height)}) sigma=${sigma} gauss[0]=${gaussFloats[0]} gauss[1]=${gaussFloats[4]} gauss[2]=${gaussFloats[8]}"])
            let uGauss = this._cachedUniform("bloomGaussCoefs", UniformType.Vec4.value(), num: UInt16(level.kernelRadius))
            // 复用上传缓冲（每级 kernelRadius 不同 → 容量按需增长；同一 uniform 提交后立即复用）
            let gaussMem = this._uploadMem(2, UInt32(level.kernelRadius * 16))
            gaussMem.writeFloats(gaussFloats, Int64(gaussFloats.size))
            this.setUniform(renderer, uGauss, gaussMem, num: UInt16(level.kernelRadius))

            this.submitQuad(viewId, prog)
        }
    }

    /**
     * composite pass：5 个 blurTexture（金字塔各级垂直模糊结果）加权混合。
     *
     * 输出写入 renderTargetsHorizontal[0]（复用为临时 RT）。
     */
    private func _renderComposite(renderer: ThreeRenderer): Unit {
        let viewId = UInt16(UnrealBloomPass.BLOOM_VIEW_ID_BASE + 11u16)
        let level0 = this._mipLevels[0]
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(level0.width), UInt16(level0.height))
        // composite 输出到 mipLevels[0].horizontalFB（复用为临时 RT）
        this.setRenderTarget(renderer, viewId, this._mipLevels[0].horizontalFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let progOpt = PostProcessingShaders.get("bloom_composite")
        if (let Some(sp) <- progOpt) {
            if (!Handle.isValid(Box(sp.programHandle))) {
                sp.compileBgfx()
            }
            let prog = Box(sp.programHandle)
            if (!Handle.isValid(prog)) { return }

            let uniforms = this._passUniforms()
            // 5 个 blurTexture（金字塔各级垂直模糊结果）
            let uBlur1 = this._cachedUniform("bloomBlur1", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uBlur1, this._mipLevels[0].verticalTex, 0u32)
            let uBlur2 = this._cachedUniform("bloomBlur2", UniformType.Sampler.value())
            this.bindTexture(renderer, 1u8, uBlur2, this._mipLevels[1].verticalTex, 0u32)
            let uBlur3 = this._cachedUniform("bloomBlur3", UniformType.Sampler.value())
            this.bindTexture(renderer, 2u8, uBlur3, this._mipLevels[2].verticalTex, 0u32)
            let uBlur4 = this._cachedUniform("bloomBlur4", UniformType.Sampler.value())
            this.bindTexture(renderer, 3u8, uBlur4, this._mipLevels[3].verticalTex, 0u32)
            let uBlur5 = this._cachedUniform("bloomBlur5", UniformType.Sampler.value())
            this.bindTexture(renderer, 4u8, uBlur5, this._mipLevels[4].verticalTex, 0u32)

            // bloomStrength
            let uStrength = this._cachedUniform("bloomStrength", UniformType.Vec4.value())
            this._setScalarUniform(renderer, uStrength, 4, this.strength)

            // bloomRadius
            let uBloomRadius = this._cachedUniform("bloomRadius", UniformType.Vec4.value())
            this._setScalarUniform(renderer, uBloomRadius, 5, this.radius)

            // bloomFactors（5 个，传 vec4 数组前 5 个，w=padding）
            let uFactors = this._cachedUniform("bloomFactors", UniformType.Vec4.value(), num: 5u16)
            let fMem = this._uploadMem(6, 80u32)
            let fData: Array<Float64> = [
                this.bloomFactors[0], 0.0, 0.0, 0.0,
                this.bloomFactors[1], 0.0, 0.0, 0.0,
                this.bloomFactors[2], 0.0, 0.0, 0.0,
                this.bloomFactors[3], 0.0, 0.0, 0.0,
                this.bloomFactors[4], 0.0, 0.0, 0.0
            ]
            fMem.writeFloats(fData, 20)
            this.setUniform(renderer, uFactors, fMem, num: 5u16)

            @LogTrace(["UnrealBloom", "composite view=${viewId} outFB=${Handle.idx(this._mipLevels[0].horizontalFB)} blurTexs=(${Handle.idx(this._mipLevels[0].verticalTex)}, ${Handle.idx(this._mipLevels[1].verticalTex)}, ${Handle.idx(this._mipLevels[2].verticalTex)}, ${Handle.idx(this._mipLevels[3].verticalTex)}, ${Handle.idx(this._mipLevels[4].verticalTex)}) strength=${this.strength} radius=${this.radius} factors=(${this.bloomFactors[0]}, ${this.bloomFactors[1]}, ${this.bloomFactors[2]}, ${this.bloomFactors[3]}, ${this.bloomFactors[4]})"])
            this.submitQuad(viewId, prog)
        }
    }

    /**
     * blend pass：bloom composite 结果加性叠加回 readBuffer 场景颜色，写入 writeBuffer。
     *
     * 关键：当 renderToScreen=true（composer 链最后一个 enabled pass）时，
     * blend view 的 frame buffer 设为无效 handle（swap chain）而非 writeBuffer，
     * 并在 submit 后调 bgfx_frame_cj 触发双缓冲交换上屏。
     */
    private func _renderBlend(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle): Unit {
        let viewId = UInt16(UnrealBloomPass.BLOOM_VIEW_ID_BASE + 12u16)
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        // renderToScreen=true 时写 swap chain（无效 FB handle），否则写 writeBuffer（离屏 RT）
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)

        let progOpt = PostProcessingShaders.get("bloom_blend")
        if (let Some(sp) <- progOpt) {
            if (!Handle.isValid(Box(sp.programHandle))) {
                sp.compileBgfx()
            }
            let prog = Box(sp.programHandle)
            if (!Handle.isValid(prog)) { return }

            let uniforms = this._passUniforms()
            // stage 0 = bloom composite 结果（mipLevels[0].horizontalFB 的纹理）
            let uBloom = this._cachedUniform("bloomTexture", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uBloom, this._mipLevels[0].horizontalTex, 0u32)

            // stage 1 = readBuffer 场景颜色
            let uScene = this._cachedUniform("bloomScene", UniformType.Sampler.value())
            let readTex = this.getTexture(renderer, readBuffer, 0u8)
            this.bindTexture(renderer, 1u8, uScene, readTex, 0u32)

            @LogTrace(["UnrealBloom", "blend view=${viewId} renderToScreen=${this.renderToScreen} bloomTex=${Handle.idx(this._mipLevels[0].horizontalTex)} sceneTex=${Handle.idx(readTex)} writeBuffer=${Handle.idx(writeBuffer)}"])
            this.submitQuad(viewId, prog)

            // 不在此调 bgfx_frame：frame 统一由 EffectComposer.render 末尾触发
            // （bgfx_frame 是双缓冲交换，每帧仅一次；pass 只负责 submit）
        }
    }

    /**
     * 释放 bloom pass 占用的所有 GPU 资源。
     */
    public override func release(): Bool {
        this._destroyRTs()
        // 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose
        // 必须经 _disposePassUniforms() 释放，否则 composer 重建/切换后句柄泄漏（同 SMAA 修复点①）。
        this._disposePassUniforms()
        return true
    }
}
