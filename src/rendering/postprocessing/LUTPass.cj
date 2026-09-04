/**
 * @file[zh-cn] BgfxLUTPass 颜色分级后处理 pass
 * @brief[zh-cn] 颜色分级后处理 pass —— 通过 3D 查找表（LUT）做色彩映射
 * @explain[zh-cn] 算法：
 *         1. val = texture2D(tDiffuse, vUv) 取当前像素颜色
 *         2. pixelWidth = 1/lutSize; halfPixelWidth = 0.5/lutSize
 *         3. uvw = vec3(halfPixelWidth) + val.rgb * (1 - pixelWidth)（向中心收半像素，采样从边缘像素中心开始）
 *         4. lutVal = vec4(texture3D(lut, uvw).rgb, val.a) —— 3D LUT 查表，保留 alpha
 *         5. gl_FragColor = mix(val, lutVal, intensity) —— 按 intensity 混合原图与 LUT 结果
 *         流程：单遍全屏 pass：readBuffer.color0 → tDiffuse → LUT 查表 → writeBuffer（或屏幕）；
 *         本 pass 持 lut/lutSize/intensity 字段。
 *         渲染差异：本 pass 继承 ShaderPass("lut")，shader 已在 PostProcessingShaders 注册，
 *         override bindExtraUniforms 绑定 3D LUT 纹理（stage 1）+ u_lutSize/u_intensity；
 *         3D LUT 用 bgfx_create_texture_3d_cj（RGBA8）+ SAMPLER3D(lut, 1) + texture3D 采样；
 *         bgfx uniform 最小单位 vec4，故用 u_lutSize(vec4.x) / u_intensity(vec4.x)。
 *
 * @file[en] BgfxLUTPass color grading post-processing pass
 * @brief[en] Color grading post-processing pass - color mapping via a 3D lookup table (LUT)
 * @explain[en] Algorithm:
 *         1. val = texture2D(tDiffuse, vUv) samples the current pixel color
 *         2. pixelWidth = 1/lutSize; halfPixelWidth = 0.5/lutSize
 *         3. uvw = vec3(halfPixelWidth) + val.rgb * (1 - pixelWidth) (inset by half a pixel so sampling starts
 *            from the center of edge pixels)
 *         4. lutVal = vec4(texture3D(lut, uvw).rgb, val.a) - 3D LUT lookup, alpha preserved
 *         5. gl_FragColor = mix(val, lutVal, intensity) - mixes the original image with the LUT result by intensity
 *         Flow: a single-pass full-screen pass: readBuffer.color0 → tDiffuse → LUT lookup → writeBuffer (or screen);
 *         this pass holds lut/lutSize/intensity fields.
 *         Rendering differences: this pass extends ShaderPass("lut"), whose shader is registered in
 *         PostProcessingShaders; bindExtraUniforms binds the 3D LUT texture (stage 1) plus u_lutSize/u_intensity;
 *         the 3D LUT is created via bgfx_create_texture_3d_cj (RGBA8) with SAMPLER3D(lut, 1) + texture3D sampling;
 *         bgfx uniforms have a minimum unit of vec4, so u_lutSize(vec4.x) / u_intensity(vec4.x) are used.
 *
 * @package three.rendering.postprocessing
 */

package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.BgfxMemory
import three.utils.log.Logger

/**
 * @brief[zh-cn] 颜色分级（LUT）后处理 pass
 * @brief[en] Color grading (LUT) post-processing pass
 * @explain[zh-cn] 单遍全屏 pass，用 3D LUT 纹理做色彩映射，按 intensity 与原图混合。
 *         lut/lutSize/intensity 以 public 字段暴露，运行时修改字段 → render() 内每帧同步到 bgfx uniform。
 * @explain[en] A single-pass full-screen pass that maps colors with a 3D LUT texture, mixed with the original
 *         image by intensity. lut/lutSize/intensity are exposed as public fields; modifying them at runtime
 *         syncs to the bgfx uniforms each frame inside render().
 */
public class LUTPass <: ShaderPass {
    /**
     * @brief[zh-cn] 3D LUT 纹理（bgfx TextureHandle，RGBA8，尺寸 lutSize×lutSize×lutSize）
     * @brief[en] 3D LUT texture (bgfx TextureHandle, RGBA8, size lutSize×lutSize×lutSize)
     * @explain[zh-cn] 无效 handle（idx=65535）时 pass 跳过（无 LUT 可查）。
     * @explain[en] When the handle is invalid (idx=65535), the pass is skipped (nothing to look up).
     */
    public var lut: TextureHandle

    /**
     * @brief[zh-cn] LUT 边长（像素，如 16/32，3D 纹理三边等长）
     * @brief[en] LUT edge length (pixels, e.g. 16/32; all three edges of the 3D texture are equal)
     */
    public var lutSize: Int64

    /**
     * @brief[zh-cn] 混合强度 [0,1]：0=原图，1=完全 LUT 映射
     * @brief[en] Mix intensity [0,1]: 0=original image, 1=fully LUT-mapped
     */
    public var intensity: Float64

    /**
     * @brief[zh-cn] 构造 LUTPass
     * @brief[en] Constructs LUTPass
     * @param[zh-cn] lut 3D LUT 纹理句柄（默认无效 → pass 跳过）
     * @param[zh-cn] lutSize LUT 边长（默认 0，与无效纹理配套；有效纹理时必须 > 0）
     * @param[zh-cn] intensity 混合强度（默认 1.0）
     * @param[en] lut The 3D LUT texture handle (default invalid → pass skipped)
     * @param[en] lutSize LUT edge length (default 0, paired with an invalid texture; must be > 0 for a valid texture)
     * @param[en] intensity Mix intensity (default 1.0)
     */
    public init(
        lut!: TextureHandle = INVALID_TEXTURE_HANDLE,
        lutSize!: Int64 = 0,
        intensity!: Float64 = 1.0
    ) {
        super("lut", textureID: "tDiffuse")
        this.lut = lut
        this.lutSize = lutSize
        this.intensity = intensity
        // needsSwap=true（继承 ShaderPass 默认）
        Logger.trace(["lut", "LUTPass constructed: lutIdx=" + handleIdx(lut).toString() +
                      " lutSize=" + lutSize.toString() +
                      " intensity=" + intensity.toString()])
    }

    /**
     * @brief[zh-cn] 子类扩展钩子：submit 前绑定 LUT 相关 uniform
     * @brief[en] Subclass extension hook: binds the LUT-related uniforms before submit
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] uniforms 已创建 tDiffuse sampler 的 uniform 注册表（继续创建 LUT uniforms）
     * @param[en] renderer Renderer
     * @param[en] uniforms The uniform registry where the tDiffuse sampler has been created (LUT uniforms are added here)
     * @explain[zh-cn] 绑定：stage 1：lut（SAMPLER3D，3D LUT 纹理）；u_lutSize（vec4.x = lutSize）；
     *         u_intensity（vec4.x = intensity）。bgfx 需在 submit 前经 uniforms 注册表 createUniform + setUniform 绑定。
     * @explain[en] Binds: stage 1: lut (SAMPLER3D, the 3D LUT texture); u_lutSize (vec4.x = lutSize);
     *         u_intensity (vec4.x = intensity). In bgfx the uniforms must be bound via the uniform registry
     *         createUniform + setUniform before submit.
     */
    public override func bindExtraUniforms(renderer: BgfxRenderer, uniforms: BgfxUniforms): Unit {
        // 3D LUT 纹理绑定（stage 1，SAMPLER3D(lut, 1)）
        let uLut = uniforms.createUniform("lut", UniformType.Sampler.value())
        this.bindTexture(renderer, 1u8, uLut, this.lut, 0u32)
        // lutSize / intensity（bgfx 最小单位 vec4，x=value）
        this.setUniformVec4(renderer, uniforms, "u_lutSize",   Float64(this.lutSize))
        this.setUniformVec4(renderer, uniforms, "u_intensity", this.intensity)
        Logger.trace(["lut", "bindExtraUniforms: lutIdx=" + handleIdx(this.lut).toString() +
                      " lutSize=" + this.lutSize.toString() +
                      " intensity=" + this.intensity.toString()])
    }

    /**
     * 设置单个 vec4 uniform（x=value, y/z/w=0）。辅助方法，简化 uniforms 设置。
     */
    private func setUniformVec4(
        renderer: BgfxRenderer,
        uniforms: BgfxUniforms,
        name: String,
        value: Float64
    ): Unit {
        let handle = uniforms.createUniform(name, UniformType.Vec4.value())
        let mem = BgfxMemory(16u32)
        mem.writeFloats([value, 0.0, 0.0, 0.0], 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    /**
     * @brief[zh-cn] 执行 LUT pass
     * @brief[en] Executes the LUT pass
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 的输出目标）
     * @param[zh-cn] readBuffer 读 buffer（上一 pass 结果，绑到 tDiffuse）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (output target of this pass)
     * @param[en] readBuffer Read buffer (previous pass result, bound to tDiffuse)
     * @param[en] deltaTime Frame delta time
     * @explain[zh-cn] 流程：1. 绑定 tDiffuse = readBuffer.color0（stage 0，基类 ShaderPass 完成）；
     *         2. bindExtraUniforms 绑定 lut（stage 1）+ u_lutSize/u_intensity；
     *         3. 全屏 quad submit（覆盖写 state）。
     * @explain[en] Flow: 1. binds tDiffuse = readBuffer.color0 (stage 0, done by the base ShaderPass);
     *         2. bindExtraUniforms binds lut (stage 1) + u_lutSize/u_intensity;
     *         3. submits the full-screen quad (overwrite state).
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 无有效 LUT 纹理时跳过（无查表可做）
        if (!isValidHandle(this.lut)) {
            Logger.trace(["lut", "render: lut texture invalid (idx=65535), skip pass"])
            return
        }
        if (this.lutSize <= 0) {
            Logger.trace(["lut", "render: lutSize<=0, skip pass"])
            return
        }
        Logger.trace(["lut", "render: entering LUTPass.render (lutIdx=" + handleIdx(this.lut).toString() +
                      " lutSize=" + this.lutSize.toString() +
                      " intensity=" + this.intensity.toString() +
                      " writeBuffer=" + handleIdx(writeBuffer).toString() +
                      " readBuffer=" + handleIdx(readBuffer).toString() + ")"])
        super.render(renderer, writeBuffer, readBuffer, deltaTime)
    }

    /**
     * @brief[zh-cn] 释放 LUTPass 占用的 GPU 资源
     * @brief[en] Releases the GPU resources held by LUTPass
     * @explain[zh-cn] lut shader program 由 PostProcessingShaders 全局管理，不在此 dispose；
     *         3D LUT 纹理由 caller 创建/销毁（本 pass 不拥有所有权）；
     *         全屏 quad 由 EffectComposer 持单例统一管理。
     * @explain[en] The lut shader program is managed globally by PostProcessingShaders and is not disposed here;
     *         the 3D LUT texture is created/destroyed by the caller (this pass does not own it);
     *         the full-screen quad is managed as a singleton by EffectComposer.
     */
    public override func dispose(): Unit {
        Logger.trace(["lut", "disposed"])
    }
}
