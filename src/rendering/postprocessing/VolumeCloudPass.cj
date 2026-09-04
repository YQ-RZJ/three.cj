/**
 * @file[zh-cn] VolumeCloudPass 体积云后处理 pass
 * @brief[zh-cn] 体积云后处理 pass —— 全屏 ray marching 体积云
 * @explain[zh-cn] 改造为全屏后处理：
 *         每个像素由逆视图投影矩阵重建世界射线，与云盒 AABB 求交后逐层步进；
 *         采样 CPU 生成的 3D Simplex 噪声纹理；
 *         wang_hash 抖动、smoothstep 密度、中心差分着色、alpha 累积；
 *         最终与场景色（tDiffuse=readBuffer）over 合成输出。
 *         渲染差异：
 *         - 3D 噪声纹理（R8）用 renderer.createTexture3D（Clamp + 线性过滤，对照 LUTPass 3D 纹理范式）。
 *         - 全屏 pass 在 FS 内由 u_invViewProj + u_cameraPos 重建射线（无物体级 VS）。
 *         - 噪声用 SimplexNoise（同为 [-1,1] 3D 噪声，替代等价）。
 *         - 云盒为世界空间 AABB（u_boxCenter/u_boxHalfSize），噪声采样坐标映射到 [0,1]³。
 *         - frame 每帧自增驱动抖动动画。
 *         用法：
 *         let cloudPass = VolumeCloudPass(camera: camera)
 *         cloudPass.cloudCenter = Vector3(0.0, 0.0, 0.0)   // 云盒中心（世界）
 *         cloudPass.cloudHalfSize = Vector3(4.0, 2.0, 4.0) // 云盒半尺寸（世界）
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(cloudPass)
 *
 * @file[en] VolumeCloudPass volume cloud render pass
 * @brief[en] Volume cloud post-processing pass - full-screen ray marched volume clouds
 * @explain[en] Reworked into a full-screen post-processing pass:
 *         Each pixel rebuilds a world ray from the inverse view-projection matrix, intersects
 *         the cloud box AABB and marches layer by layer.
 *         Samples a CPU-generated 3D Simplex noise texture;
 *         wang_hash jitter, smoothstep density, central-difference shading, alpha accumulation;
 *         finally over-composed with the scene color (tDiffuse=readBuffer).
 *         Rendering differences:
 *         - The 3D noise texture (R8) is uploaded via renderer.createTexture3D (Clamp + linear
 *           filtering, following the LUTPass 3D texture pattern).
 *         - Rays are rebuilt in the fragment shader from u_invViewProj + u_cameraPos (no per-object VS).
 *         - Noise uses SimplexNoise (also a [-1,1] 3D noise, equivalent replacement).
 *         - The cloud box is a world-space AABB (u_boxCenter/u_boxHalfSize), noise sample coords mapped to [0,1]³.
 *         - frame increments each frame to drive the jitter animation.
 *         Usage:
 *         let cloudPass = VolumeCloudPass(camera: camera)
 *         cloudPass.cloudCenter = Vector3(0.0, 0.0, 0.0)   // cloud box center (world)
 *         cloudPass.cloudHalfSize = Vector3(4.0, 2.0, 4.0) // cloud box half size (world)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(cloudPass)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.rendering.cameras.Camera
import three.core.math.*
import three.core.dsa.SimplexNoise
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import std.math.*

/**
 * @brief[zh-cn] 体积云后处理 pass（全屏 ray marching）
 * @brief[en] Volume cloud post-processing pass (full-screen ray marching)
 * @explain[zh-cn] 材质参数：threshold/opacity/range/steps/frame/base。
 * @explain[en] Material parameters: threshold/opacity/range/steps/frame/base.
 */
public class VolumeCloudPass <: ShaderPass {
    /**
     * 相机（每帧取 projectionMatrix × matrixWorldInverse 的逆重建射线）。
     */
    public var camera: Camera

    /**
     * 云盒中心（世界坐标）。
     */
    public var cloudCenter: Vector3

    /**
     * 云盒半尺寸（世界坐标，决定噪声纹理覆盖的世界范围）。
     */
    public var cloudHalfSize: Vector3

    /**
     * 云基准色（accumulate 起始色，默认 0x798aa0）。
     */
    public var base: Color

    /**
     * 密度阈值（默认 0.25）。
     */
    public var threshold: Float64

    /**
     * smoothstep 过渡宽度（默认 0.1）。
     */
    public var range: Float64

    /**
     * 云不透明度（默认 0.25）。
     */
    public var opacity: Float64

    /**
     * ray marching 步数（默认 100）。
     */
    public var steps: Float64

    /**
     * 帧号（每帧自增，驱动抖动种子动画）。
     */
    public var frame: Int64

    /**
     * 3D 噪声纹理边长（默认 64 平衡内存/质量）。
     */
    public var texSize: Int64

    /**
     * 3D 噪声纹理句柄（R8，texSize³，懒创建一次）。
     */
    private var _noiseTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 3D 噪声纹理是否已创建。
     */
    private var _noiseTexCreated: Bool = false

    /**
     * 挂载的渲染器（onAttach 时从 composer 持有，dispose 销毁自建纹理用）。
     */
    private var _renderer: Option<BgfxRenderer> = None

    /**
     * 构造 VolumeCloudPass。
     *
     * @param camera 相机（重建射线必需）
     * @param cloudCenter 云盒中心（默认原点）
     * @param cloudHalfSize 云盒半尺寸（默认 (4,2,4)）
     * @param base 云基准色（默认 0x798aa0）
     * @param threshold 密度阈值（默认 0.25）
     * @param range smoothstep 宽度（默认 0.1）
     * @param opacity 不透明度（默认 0.25）
     * @param steps 步数（默认 100）
     * @param texSize 3D 噪声边长（默认 64）
     */
    public init(
        camera: Camera,
        cloudCenter!: Vector3 = Vector3(0.0, 0.0, 0.0),
        cloudHalfSize!: Vector3 = Vector3(4.0, 2.0, 4.0),
        base!: Color = Color(0x798aa0),
        threshold!: Float64 = 0.25,
        range!: Float64 = 0.1,
        opacity!: Float64 = 0.25,
        steps!: Float64 = 100.0,
        texSize!: Int64 = 64
    ) {
        super("volumecloud", textureID: "tDiffuse")
        this.camera = camera
        this.cloudCenter = cloudCenter
        this.cloudHalfSize = cloudHalfSize
        this.base = base
        this.threshold = threshold
        this.range = range
        this.opacity = opacity
        this.steps = steps
        this.frame = 0
        this.texSize = texSize
        // 透明材质语义：needsSwap=true（基类默认）
        Logger.trace(["volumecloud", "VolumeCloudPass constructed: texSize=" + texSize.toString() +
                      " boxCenter=(${cloudCenter.x},${cloudCenter.y},${cloudCenter.z})" +
                      " boxHalf=(${cloudHalfSize.x},${cloudHalfSize.y},${cloudHalfSize.z})" +
                      " steps=" + steps.toString()])
    }

    /**
     * 挂载到 composer 时持有渲染器引用（dispose 销毁自建 3D 纹理需要 renderer）。
     *
     * @param composer 挂载的 EffectComposer（composer.renderer 即渲染器）
     */
    public override func onAttach(composer: EffectComposer): Unit {
        super.onAttach(composer)
        this._renderer = Some(composer.renderer)
    }

    /**
     * 子类扩展钩子：submit 前绑定体积云相关 uniform。
     * 材质 uniforms 直接改值（cameraPos/threshold/opacity/range/steps/frame）；
     * bgfx 需在 submit 前经 uniforms 注册表 createUniform + setUniform 绑定。
     *
     * 绑定：
     *   - stage 1：u_cloudMap（SAMPLER3D，3D 噪声纹理）
     *   - u_cloudInvViewProj（mat4，每帧由 camera.projectionMatrix × matrixWorldInverse 求逆）
     *   - u_cameraPos / u_boxCenter / u_boxHalfSize / u_base（vec4）
     *   - u_threshold / u_range / u_opacity / u_steps / u_frame / u_texSize（vec4.x）
     *
     * 注：逆视图投影矩阵 uniform 名避开 bgfx_shader.sh 内置的 u_invViewProj
     *（BgfxShaderSource.cj 已声明，HLSL 下重名会报 X3003 redefinition）。
     *
     * @param renderer 渲染器
     * @param uniforms 已创建 tDiffuse sampler 的 uniform 注册表（继续创建体积云 uniforms）
     */
    public override func bindExtraUniforms(renderer: BgfxRenderer, uniforms: BgfxUniforms): Unit {
        // 懒创建 3D 噪声纹理（首次 submit 前生成并上传）
        if (!this._noiseTexCreated) {
            this._createNoiseTexture(renderer)
        }
        // 3D 噪声纹理绑定（stage 1，SAMPLER3D(u_cloudMap, 1)）
        let uCloudMap = uniforms.createUniform("u_cloudMap", UniformType.Sampler.value())
        this.bindTexture(
            renderer, 1u8, uCloudMap, this._noiseTex,
            BgfxConstants.SAMPLER_U_CLAMP | BgfxConstants.SAMPLER_V_CLAMP | BgfxConstants.SAMPLER_W_CLAMP
        )

        // 逆视图投影矩阵（重建世界射线：world = invViewProj × ndc）
        let uInvViewProj = uniforms.createUniform("u_cloudInvViewProj", UniformType.Mat4.value())
        let viewProj = Matrix4()
        viewProj.multiplyMatrices(this.camera.projectionMatrix, this.camera.matrixWorldInverse)
        viewProj.invert()
        let invArr = viewProj.toArray(Array<Float64>(16, { _ => 0.0 }))
        let invMem = BgfxMemory(64u32)
        invMem.writeFloats(invArr, 16)
        this.setUniform(renderer, uInvViewProj, invMem)

        // 相机世界位置
        let camPos = this.camera.matrixWorld.getPosition()
        this.setUniformVec4(renderer, uniforms, "u_cameraPos", [camPos.x, camPos.y, camPos.z, 1.0])

        // 云盒中心/半尺寸
        this.setUniformVec4(renderer, uniforms, "u_boxCenter", [this.cloudCenter.x, this.cloudCenter.y, this.cloudCenter.z, 1.0])
        this.setUniformVec4(renderer, uniforms, "u_boxHalfSize", [this.cloudHalfSize.x, this.cloudHalfSize.y, this.cloudHalfSize.z, 1.0])

        // 云基准色
        this.setUniformVec4(renderer, uniforms, "u_base", [this.base.r, this.base.g, this.base.b, 1.0])

        // 参数（threshold/range/opacity/steps/frame）
        this.setUniformVec4(renderer, uniforms, "u_threshold", [this.threshold, 0.0, 0.0, 0.0])
        this.setUniformVec4(renderer, uniforms, "u_range",     [this.range,     0.0, 0.0, 0.0])
        this.setUniformVec4(renderer, uniforms, "u_opacity",   [this.opacity,   0.0, 0.0, 0.0])
        this.setUniformVec4(renderer, uniforms, "u_steps",     [this.steps,     0.0, 0.0, 0.0])
        this.setUniformVec4(renderer, uniforms, "u_frame",     [Float64(this.frame), 0.0, 0.0, 0.0])
        this.setUniformVec4(renderer, uniforms, "u_texSize",   [Float64(this.texSize), 0.0, 0.0, 0.0])
        Logger.trace(["volumecloud", "bindExtraUniforms: frame=" + this.frame.toString() +
                      " texIdx=" + handleIdx(this._noiseTex).toString() +
                      " steps=" + this.steps.toString()])
    }

    /**
     * 执行体积云 pass：帧号自增后委托基类（绑定 tDiffuse + submit quad）。
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this.frame += 1
        super.render(renderer, writeBuffer, readBuffer, deltaTime)
    }

    /**
     * 释放体积云 pass 占用的 GPU 资源。
     * volumecloud shader program 由 PostProcessingShaders 全局管理，不在此 dispose。
     * 3D 噪声纹理为本 pass 自建，须显式销毁；全屏 quad 由 EffectComposer 统一管理。
     */
    public override func dispose(): Unit {
        if (isValidHandle(this._noiseTex)) {
            match (this._renderer) {
                case Some(r) => r.destroyTexture(this._noiseTex)
                case None => ()
            }
            this._noiseTex = INVALID_TEXTURE_HANDLE
            this._noiseTexCreated = false
        }
    }

    // ========================================================================
    // ===== 内部辅助 =====
    // ========================================================================

    /**
     * 生成 3D Simplex 噪声纹理（R8，texSize³）。
     * 生成规则：
     *   d = 1.0 - length((x,y,z) - size/2) / size
     *   data[i] = (128 + 128 * noise(x*scale/1.5, y*scale, z*scale/1.5)) * d * d
     * scale=0.05；仓颉侧用 SimplexNoise（[-1,1]，替代等价）。
     *
     * @param renderer 渲染器（createTexture3D 上传）
     */
    private func _createNoiseTexture(renderer: BgfxRenderer): Unit {
        let size = this.texSize
        let noise = SimplexNoise()
        let scale = 0.05
        let half = Float64(size) / 2.0
        let data = Array<UInt8>(size * size * size, { _ => 0u8 })
        var i = 0
        for (z in 0..size) {
            for (y in 0..size) {
                for (x in 0..size) {
                    // 距中心的归一化距离
                    let dx = Float64(x) - half
                    let dy = Float64(y) - half
                    let dz = Float64(z) - half
                    let d = 1.0 - sqrt(dx * dx + dy * dy + dz * dz) / Float64(size)
                    // 3D 噪声
                    let n = noise.noise3d(
                        Float64(x) * scale / 1.5,
                        Float64(y) * scale,
                        Float64(z) * scale / 1.5
                    )
                    let v = (128.0 + 128.0 * n) * d * d
                    data[i] = UInt8(clamp(v, 0.0, 255.0))
                    i += 1
                }
            }
        }
        let total = UInt32(size * size * size)
        let mem = BgfxMemory(total)
        mem.writeUInt8(data, Int64(data.size))
        // R8 3D 纹理（Clamp + 线性过滤，对照 LUTPass 3D 纹理上传范式）
        this._noiseTex = renderer.createTexture3D(
            UInt16(size), UInt16(size), UInt16(size), false,
            TextureFormat.R8.value(),
            UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_W_CLAMP),
            Some(mem))
        this._noiseTexCreated = true
        Logger.trace(["volumecloud", "createNoiseTexture: size=" + size.toString() +
                      " texIdx=" + handleIdx(this._noiseTex).toString()])
    }

    /**
     * 设置单个 vec4 uniform（xyzw 全量传入）。辅助方法，简化 uniforms 设置。
     */
    private func setUniformVec4(
        renderer: BgfxRenderer,
        uniforms: BgfxUniforms,
        name: String,
        values: Array<Float64>
    ): Unit {
        let handle = uniforms.createUniform(name, UniformType.Vec4.value())
        let mem = BgfxMemory(16u32)
        mem.writeFloats(values, 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }
}
