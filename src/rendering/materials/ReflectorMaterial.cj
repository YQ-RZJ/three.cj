/**
 * @file[zh-cn] 反射面材质
 * @brief[zh-cn] 反射面材质，GroundReflector专用，对应JS侧ReflectorShader
 * @explain[zh-cn] 
 * 对应 Three.js examples/jsm/objects/GroundReflector.js 内嵌 ReflectorShader。
 * kind = "ReflectorMaterial"，BgfxBackend 按 kind 映射到 ShaderLibs "reflector" program。
 * 持反射 RT 纹理句柄（tDiffuse/tDepth）与 ReflectorShader 全部 uniform 参数。
 * doRender() 每帧更新这些参数，渲染线程经 BgfxBackend._bindMaterialUniforms 读本材质字段绑定到 bgfx。
 * Three.cj bgfx 差异：JS 用 ShaderMaterial + uniforms 对象；bgfx uniform 最小单位 vec4，
 * 本材质把 scalar uniform 存 Float64 字段，BgfxBackend 绑定为 vec4.x。
 *
 * @file[en] Reflector Material
 * @brief[en] Reflector material, dedicated to GroundReflector, corresponding to JS ReflectorShader
 * @explain[en] 
 * Corresponds to Three.js examples/jsm/objects/GroundReflector.js embedded ReflectorShader.
 * kind = "ReflectorMaterial", BgfxBackend maps by kind to ShaderLibs "reflector" program.
 * Holds reflection RT texture handles (tDiffuse/tDepth) and all ReflectorShader uniform parameters.
 * doRender() updates these parameters each frame; the render thread reads material fields via BgfxBackend._bindMaterialUniforms to bind to bgfx.
 * Three.cj bgfx difference: JS uses ShaderMaterial + uniforms object; bgfx uniform minimum unit is vec4,
 * this material stores scalar uniforms as Float64 fields, BgfxBackend binds as vec4.x.
 */
package three.rendering.materials

import three.core.math.Color
import three.core.math.Matrix4
import three.rendering.types.*

/**
 * @brief[zh-cn] 反射面材质，GroundReflector专用
 * @explain[zh-cn] 
 * 对应 Three.js examples/jsm/objects/GroundReflector.js 内嵌 ReflectorShader。
 * 持反射 RT 纹理句柄与全部 uniform 参数，doRender() 每帧更新。
 *
 * @brief[en] Reflector material, dedicated to GroundReflector
 * @explain[en] 
 * Corresponds to Three.js examples/jsm/objects/GroundReflector.js embedded ReflectorShader.
 * Holds reflection RT texture handles and all uniform parameters, updated each frame by doRender().
 */
public class ReflectorMaterial <: Material {
    /**
     * @brief[zh-cn] 反射RT的color纹理句柄（tDiffuse）
     *
     * @brief[en] Reflection RT color texture handle (tDiffuse)
     */
    public var tDiffuse: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * @brief[zh-cn] 反射RT的深度纹理句柄（tDepth，RGBA32F存NDC深度，useDepthTexture=true时有效）
     *
     * @brief[en] Reflection RT depth texture handle (tDepth, RGBA32F stores NDC depth, effective when useDepthTexture=true)
     */
    public var tDepth: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * @brief[zh-cn] 纹理投影矩阵（反射RT→地面UV）
     *
     * @brief[en] Texture projection matrix (reflection RT → ground UV)
     */
    public var textureMatrix: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 反射贴图混合色（RGB），默认0x7F7F7F
     *
     * @brief[en] Reflection map blend color (RGB), default 0x7F7F7F
     */
    public var reflectorColor: Color = Color(0x7f, 0x7f, 0x7f)

    /**
     * @brief[zh-cn] 最大反射距离（距离衰减上界），默认180
     *
     * @brief[en] Maximum reflection distance (distance attenuation upper bound), default 180
     */
    public var maxDistance: Float64 = 180.0

    /**
     * @brief[zh-cn] 菲涅尔系数（doRender每帧计算），默认1
     *
     * @brief[en] Fresnel coefficient (computed each frame by doRender), default 1
     */
    public var fresnelCoe: Float64 = 1.0

    /**
     * @brief[zh-cn] 镜像虚拟相机near，默认0.1
     *
     * @brief[en] Mirror virtual camera near, default 0.1
     */
    public var virtualCameraNear: Float64 = 0.1

    /**
     * @brief[zh-cn] 镜像虚拟相机far，默认100
     *
     * @brief[en] Mirror virtual camera far, default 100
     */
    public var virtualCameraFar: Float64 = 100.0

    /**
     * @brief[zh-cn] 镜像虚拟相机投影矩阵
     *
     * @brief[en] Mirror virtual camera projection matrix
     */
    public var virtualCameraProjectionMatrix: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 镜像虚拟相机世界矩阵
     *
     * @brief[en] Mirror virtual camera world matrix
     */
    public var virtualCameraMatrixWorld: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 镜像虚拟相机投影逆矩阵
     *
     * @brief[en] Mirror virtual camera projection inverse matrix
     */
    public var virtualCameraProjectionMatrixInverse: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 分辨率宽度，默认1
     *
     * @brief[en] Resolution width, default 1
     */
    public var resolutionX: Float64 = 1.0

    /**
     * @brief[zh-cn] 分辨率高度，默认1
     *
     * @brief[en] Resolution height, default 1
     */
    public var resolutionY: Float64 = 1.0

    /**
     * @brief[zh-cn] 是否使用深度纹理，默认false
     * @explain[zh-cn] 
     * true → shader走useDepthTexture分支：深度反投影重建世界位置，
     * worldPosition.y > maxDistance 丢弃 + DISTANCE_ATTENUATION距离衰减 + FRESNEL。
     * false → 非深度分支：gl_FragColor = blendOverlay(base.rgb, color), alpha=1.0。
     *
     * @brief[en] Whether to use depth texture, default false
     * @explain[en] 
     * true → shader uses useDepthTexture branch: depth reprojection reconstructs world position,
     * worldPosition.y > maxDistance discards + DISTANCE_ATTENUATION distance attenuation + FRESNEL.
     * false → non-depth branch: gl_FragColor = blendOverlay(base.rgb, color), alpha=1.0.
     */
    public var useDepthTexture: Bool = false

    /**
     * @brief[zh-cn] 距离衰减开关，默认true，仅useDepthTexture=true时生效
     *
     * @brief[en] Distance attenuation toggle, default true, only effective when useDepthTexture=true
     */
    public var distanceAttenuation: Bool = true

    /**
     * @brief[zh-cn] 菲涅尔开关，默认true，仅useDepthTexture=true时生效
     *
     * @brief[en] Fresnel toggle, default true, only effective when useDepthTexture=true
     */
    public var fresnel: Bool = true

    /**
     * @brief[zh-cn] 构造一个新的反射面材质
     *
     * @brief[en] Construct a new reflector material
     */
    public init() {
        super()
        this.kind = "ReflectorMaterial"
        this.transparent = true
    }

    /**
     * @brief[zh-cn] 将给定ReflectorMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ReflectorMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: ReflectorMaterial): ReflectorMaterial {
        super.copy(source)
        this.tDiffuse = source.tDiffuse
        this.tDepth = source.tDepth
        this.textureMatrix.copy(source.textureMatrix)
        this.reflectorColor.copy(source.reflectorColor)
        this.maxDistance = source.maxDistance
        this.opacity = source.opacity
        this.fresnelCoe = source.fresnelCoe
        this.virtualCameraNear = source.virtualCameraNear
        this.virtualCameraFar = source.virtualCameraFar
        this.virtualCameraProjectionMatrix.copy(source.virtualCameraProjectionMatrix)
        this.virtualCameraMatrixWorld.copy(source.virtualCameraMatrixWorld)
        this.virtualCameraProjectionMatrixInverse.copy(source.virtualCameraProjectionMatrixInverse)
        this.resolutionX = source.resolutionX
        this.resolutionY = source.resolutionY
        this.useDepthTexture = source.useDepthTexture
        this.distanceAttenuation = source.distanceAttenuation
        this.fresnel = source.fresnel
        return this
    }
}
