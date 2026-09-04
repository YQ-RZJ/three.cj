/**
 * @file[zh-cn] ShadowSlot
 * @brief[zh-cn] 单个阴影光源的全部 GPU 资源（按光源 ID 分桶）
 * @explain[zh-cn] 对照 Three.js LightShadow + WebGLShadowMap：每光源一份 render target + depth texture + viewId。
 *
 * @file[en] ShadowSlot
 * @brief[en] All GPU resources for a single shadow light (bucketed by light ID)
 * @explain[en] Corresponds to Three.js LightShadow + WebGLShadowMap: one render target + depth texture + viewId per light.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 单个阴影光源的全部 GPU 资源（按光源 ID 分桶）
 * @explain[zh-cn] 对照 Three.js LightShadow + WebGLShadowMap：每光源一份 render target + depth texture + viewId
 *
 * @brief[en] All GPU resources for a single shadow light (bucketed by light ID)
 * @explain[en] Corresponds to Three.js LightShadow + WebGLShadowMap: one render target + depth texture + viewId per light
 */
public class ShadowSlot {
    /**
     * @brief[zh-cn] 该阴影光源占用的起始 view ID（cube 占 6 个连续 view ID）
     *
     * @brief[en] Starting view ID for this shadow light (cube occupies 6 consecutive view IDs)
     */
    public var baseViewId: UInt16 = 0u16
    /**
     * @brief[zh-cn] 阴影 framebuffer（cube 时为 face 0 的 fb 占位）
     *
     * @brief[en] Shadow framebuffer (placeholder for face 0 fb when cube)
     */
    public var frameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
    /**
     * @brief[zh-cn] 阴影深度纹理句柄（2D 或 cube）
     *
     * @brief[en] Shadow depth texture handle (2D or cube)
     */
    public var texture: TextureHandle = TextureHandle(65535u16)
    /**
     * @brief[zh-cn] cube 阴影的 6 个 face 独立 framebuffer（仅 isCube=true 时使用）
     *
     * @brief[en] Per-face framebuffers for cube shadow (only when isCube=true)
     */
    public var faceFrameBuffers: ArrayList<FrameBufferHandle> = ArrayList<FrameBufferHandle>()
    /**
     * @brief[zh-cn] bias × lightViewProj 矩阵（主 pass 绑 directionalShadowMatrix[i] / spotLightMatrix[i]）
     *
     * @brief[en] bias × lightViewProj matrix (bound as directionalShadowMatrix[i] / spotLightMatrix[i] in main pass)
     */
    public var shadowMatrix: Matrix4 = Matrix4()
    /**
     * @brief[zh-cn] 阴影 framebuffer 尺寸
     *
     * @brief[en] Shadow framebuffer size
     */
    public var size: Int64 = 0
    /**
     * @brief[zh-cn] 是否为 cube 阴影（PointLight）
     *
     * @brief[en] Whether this is a cube shadow (PointLight)
     */
    public var isCube: Bool = false
    /**
     * @brief[zh-cn] 光源世界坐标（cube 阴影 vertex 端算 worldPos - lightPos[i] 用）
     *
     * @brief[en] Light world position (used for cube shadow vertex calculation worldPos - lightPos[i])
     */
    public var lightPos: Vector3 = Vector3()
    /**
     * @brief[zh-cn] 阴影相机 near（主 pass 绑 u_pointShadowNearFar[i].x 用）
     *
     * @brief[en] Shadow camera near (bound as u_pointShadowNearFar[i].x in main pass)
     */
    public var near: Float64 = 0.1
    /**
     * @brief[zh-cn] 阴影相机 far（主 pass 绑 u_pointShadowNearFar[i].y 用）
     *
     * @brief[en] Shadow camera far (bound as u_pointShadowNearFar[i].y in main pass)
     */
    public var far: Float64 = 100.0
    /**
     * @brief[zh-cn] per-light 深度 bias（来自 light.shadow.bias，主 pass 绑 u_xxxShadowParams[i].x 用）
     *
     * @brief[en] Per-light depth bias (from light.shadow.bias, bound as u_xxxShadowParams[i].x in main pass)
     */
    public var bias: Float64 = 0.0
    /**
     * @brief[zh-cn] per-light 法线 bias（来自 light.shadow.normalBias，vertex 端法线偏移 u_xxxShadowParams[i].y 用）
     *
     * @brief[en] Per-light normal bias (from light.shadow.normalBias, used for vertex normal offset u_xxxShadowParams[i].y)
     */
    public var normalBias: Float64 = 0.0

    // ===== VSM 专用资源（仅 shadowType == VSM 时创建，对照 BgfxShadowMap.ShadowMapInfo）=====
    /**
     * @brief[zh-cn] VSM 深度纹理（D32，原生深度，深度 pass 写入）
     *
     * @brief[en] VSM depth texture (D32, native depth, written by depth pass)
     */
    public var vsmDepthTexture: TextureHandle = TextureHandle(65535u16)
    /**
     * @brief[zh-cn] VSM 垂直 blur 输出 / 水平 blur 输入（RG16F 中间结果）
     *
     * @brief[en] VSM vertical blur output / horizontal blur input (RG16F intermediate result)
     */
    public var vsmPassTexture: TextureHandle = TextureHandle(65535u16)
    /**
     * @brief[zh-cn] VSM 垂直 blur 输出 framebuffer（写入 vsmPassTexture）
     *
     * @brief[en] VSM vertical blur output framebuffer (writes to vsmPassTexture)
     */
    public var vsmPassFrameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)
    /**
     * @brief[zh-cn] VSM 水平 blur 输出 framebuffer（写入 texture=RG16F 最终结果，主 pass 采样）
     *
     * @brief[en] VSM horizontal blur output framebuffer (writes to texture=RG16F final result, sampled by main pass)
     */
    public var vsmFinalFrameBuffer: FrameBufferHandle = FrameBufferHandle(65535u16)

    public init() {}
}
