/**
 * @file[zh-cn] 平行光阴影配置
 * @brief[zh-cn] 平行光阴影配置，专用于 DirectionalLight
 * @explain[zh-cn] 
 * 对应 Three.js lights/DirectionalLightShadow.js。内部相机为 OrthographicCamera（正交投影），
 * 默认视锥范围 [-5,5]×[-5,5]×[0.5,500]。支持 CSM（级联阴影贴图）。
 *
 * @file[en] Directional Light Shadow
 * @brief[en] Directional light shadow configuration, specific to DirectionalLight
 * @explain[en] 
 * Corresponds to Three.js lights/DirectionalLightShadow.js. Internal camera is OrthographicCamera,
 * default frustum range [-5,5]×[-5,5]×[0.5,500]. Supports CSM (Cascaded Shadow Maps).
 */
package three.rendering.lights

import three.rendering.cameras.*
import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 平行光阴影配置，专用于 DirectionalLight
 * @explain[zh-cn] 
 * 内部相机为 OrthographicCamera（正交投影），默认视锥范围 [-5,5]×[-5,5]×[0.5,500]。
 * 支持 CSM（级联阴影贴图）。
 *
 * @brief[en] Directional light shadow configuration, specific to DirectionalLight
 * @explain[en] 
 * Internal camera is OrthographicCamera, default frustum range [-5,5]×[-5,5]×[0.5,500].
 * Supports CSM (Cascaded Shadow Maps).
 */
@JsonAdapter[withSuperClass = LightShadow]
public class DirectionalLightShadow <: LightShadow {
    /**
     * @brief[zh-cn] CSM 各级阴影矩阵数组（长度 = cascadeCount）
     *
     * @brief[en] CSM cascade shadow matrices array (length = cascadeCount)
     */
    public var cascadeMatrices: ArrayList<Matrix4>

    /**
     * @brief[zh-cn] CSM 各级视锥体（用于裁剪物体）
     *
     * @brief[en] CSM cascade frustums (used for object culling)
     */
    public var cascadeFrustums: ArrayList<Frustum>

    /**
     * @brief[zh-cn] 构造一个新的平行光阴影配置
     *
     * @brief[en] Construct a new directional light shadow configuration
     */
    public init() {
        super(OrthographicCamera(left: -5.0, right: 5.0, top: 5.0, bottom: -5.0, near: 0.5, far: 500.0))
        this.kind = "DirectionalLightShadow"
        this.cascadeMatrices = ArrayList<Matrix4>()
        this.cascadeFrustums = ArrayList<Frustum>()
    }

    /**
     * @brief[zh-cn] 启用 CSM 级联阴影
     * @explain[zh-cn] 
     * 设置 smType = SM_TYPE_CASCADE，cascadeCount = CSM_CASCADE_COUNT，
     * 初始化 4 级 OrthographicCamera 数组。
     * @param[zh-cn] mainCamera 主相机（提供 near/far 用于切分）
     *
     * @brief[en] Enable CSM cascaded shadows
     * @explain[en] 
     * Sets smType = SM_TYPE_CASCADE, cascadeCount = CSM_CASCADE_COUNT,
     * initializes 4-level OrthographicCamera array.
     * @param[en] mainCamera Main camera (provides near/far for splitting)
     */
    public func enableCSM(mainCamera: Camera): Unit {
        this.smType = SM_TYPE_CASCADE
        this.cascadeCount = CSM_CASCADE_COUNT
        // 计算级联切分
        this.cascadeSplits = this.calculateCascadeSplits(
            this.cascadeCount, mainCamera.near, mainCamera.far, this.cascadeLambda)
        // 初始化 4 级阴影相机
        this.initCascadeCameras()
        // 初始化各级矩阵与视锥体
        this.cascadeMatrices.clear()
        this.cascadeFrustums.clear()
        for (_ in 0..Int64(this.cascadeCount)) {
            this.cascadeMatrices.add(Matrix4())
            this.cascadeFrustums.add(Frustum())
        }
    }

    /**
     * @brief[zh-cn] 更新 CSM 级联阴影相机矩阵
     * @param[zh-cn] light 正在渲染阴影的 DirectionalLight
     * mainCamera 主相机
     * mainCameraNear 主相机 near
     * mainCameraFar 主相机 far
     *
     * @brief[en] Update CSM cascade shadow camera matrices
     * @param[en] light The DirectionalLight currently rendering shadows
     * mainCamera Main camera
     * mainCameraNear Main camera near
     * mainCameraFar Main camera far
     */
    public func updateCSMMatrices(light: Light, mainCamera: Camera): Unit {
        if (this.cascadeCount == 0) { return }
        // 重新计算切分（主相机 near/far 可能变化）
        this.cascadeSplits = this.calculateCascadeSplits(
            this.cascadeCount, mainCamera.near, mainCamera.far, this.cascadeLambda)
        // 光源世界位置
        let lightPos = Vector3()
        lightPos.setFromMatrixPosition(light.matrixWorld)
        // 光源目标
        let lightTarget = match (light) {
            case dl: DirectionalLight => dl.target.position
            case _ => lightPos
        }
        // 各级阴影相机更新
        for (i in 0..Int64(this.cascadeCount)) {
            let cascadeCam = this.cascadeCameras[i]
            cascadeCam.position.copy(lightPos)
            cascadeCam.lookAt(lightTarget)
            cascadeCam.updateMatrixWorld(false)
            // 更新各级 near/far（基于 cascadeSplits）
            cascadeCam.near = this.cascadeSplits[i]
            cascadeCam.far = this.cascadeSplits[i + 1]
            cascadeCam.updateProjectionMatrix()
            // 计算级联阴影矩阵
            let projScreenMatrix = Matrix4().multiplyMatrices(
                cascadeCam.projectionMatrix, cascadeCam.matrixWorldInverse)
            this.cascadeFrustums[i].setFromProjectionMatrix(projScreenMatrix)
            // 阴影矩阵（NDC [-1,1] → UV [0,1] 偏置）
            let shadowMatrix = this.cascadeMatrices[i]
            shadowMatrix.set(0.5, 0.0, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0, 1.0)
            shadowMatrix.multiply(projScreenMatrix)
        }
    }

    /**
     * @brief[zh-cn] 获取指定级联索引的阴影矩阵
     * @param[zh-cn] cascadeIndex 级联索引
     * @return[zh-cn] 阴影矩阵
     *
     * @brief[en] Get the shadow matrix for the specified cascade index
     * @param[en] cascadeIndex Cascade index
     * @return[en] Shadow matrix
     */
    public func getCascadeMatrix(cascadeIndex: Int64): Matrix4 {
        if (cascadeIndex < 0 || cascadeIndex >= this.cascadeMatrices.size) {
            return Matrix4()
        }
        return this.cascadeMatrices[cascadeIndex]
    }

    /**
     * @brief[zh-cn] 获取指定级联索引的阴影相机
     * @param[zh-cn] cascadeIndex 级联索引
     * @return[zh-cn] 阴影相机
     *
     * @brief[en] Get the shadow camera for the specified cascade index
     * @param[en] cascadeIndex Cascade index
     * @return[en] Shadow camera
     */
    public func getCascadeCamera(cascadeIndex: Int64): OrthographicCamera {
        return this.cascadeCameras[cascadeIndex]
    }

    /**
     * @brief[zh-cn] 获取指定级联索引的视锥体
     * @param[zh-cn] cascadeIndex 级联索引
     * @return[zh-cn] 视锥体
     *
     * @brief[en] Get the frustum for the specified cascade index
     * @param[en] cascadeIndex Cascade index
     * @return[en] Frustum
     */
    public func getCascadeFrustum(cascadeIndex: Int64): Frustum {
        return this.cascadeFrustums[cascadeIndex]
    }
}
