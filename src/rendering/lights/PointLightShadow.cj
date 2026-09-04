/**
 * @file[zh-cn] 点光源阴影配置
 * @brief[zh-cn] 专用于PointLight的阴影配置，内部相机为透视投影
 * @explain[zh-cn] 
 * 对应 Three.js lights/PointLightShadow.js。内部相机为 PerspectiveCamera（透视投影），
 * 默认 fov=90、aspect=1、near=0.5、far=500。点光源阴影需6面立方体阴影贴图，渲染器内部处理多面渲染。
 * 点光源强制 smType = SM_TYPE_OMNI（立方体6面阴影）。
 *
 * @file[en] Point Light Shadow
 * @brief[en] Shadow configuration specific to PointLight, with a perspective camera internally
 * @explain[en] 
 * Corresponds to Three.js lights/PointLightShadow.js. The internal camera is a PerspectiveCamera,
 * default fov=90, aspect=1, near=0.5, far=500. Point light shadows require a 6-face cube shadow map,
 * with multi-face rendering handled internally by the renderer.
 * Point light forces smType = SM_TYPE_OMNI (cube 6-face shadow).
 */
package three.rendering.lights

import three.rendering.cameras.*
import three.core.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 专用于PointLight的阴影配置，内部相机为透视投影
 * @explain[zh-cn] 
 * 对应 Three.js lights/PointLightShadow.js。内部相机为 PerspectiveCamera（透视投影），
 * 默认 fov=90、aspect=1、near=0.5、far=500。点光源阴影需6面立方体阴影贴图，渲染器内部处理多面渲染。
 * 点光源强制 smType = SM_TYPE_OMNI（立方体6面阴影）。
 *
 * @brief[en] Shadow configuration specific to PointLight, with a perspective camera internally
 * @explain[en] 
 * Corresponds to Three.js lights/PointLightShadow.js. The internal camera is a PerspectiveCamera,
 * default fov=90, aspect=1, near=0.5, far=500. Point light shadows require a 6-face cube shadow map,
 * with multi-face rendering handled internally by the renderer.
 * Point light forces smType = SM_TYPE_OMNI (cube 6-face shadow).
 */
@JsonAdapter[withSuperClass = LightShadow]
public class PointLightShadow <: LightShadow {
    /**
     * @brief[zh-cn] 6面立方体阴影相机的方向向量（+X, -X, +Y, -Y, +Z, -Z）
     *
     * @brief[en] Direction vectors for 6-face cube shadow cameras (+X, -X, +Y, -Y, +Z, -Z)
     */
    public var cubeDirections: ArrayList<Vector3>

    /**
     * @brief[zh-cn] 6面立方体阴影相机的up向量
     *
     * @brief[en] Up vectors for 6-face cube shadow cameras
     */
    public var cubeUps: ArrayList<Vector3>

    /**
     * @brief[zh-cn] 构造一个新的点光源阴影配置
     *
     * @brief[en] Construct a new point light shadow configuration
     */
    public init() {
        super(PerspectiveCamera(fov: 90.0, aspect: 1.0, near: 0.5, far: 500.0))
        this.kind = "PointLightShadow"
        // 强制 Omni 模式（立方体 6 面阴影）
        this.smType = SM_TYPE_OMNI
        this.cubeDirections = ArrayList<Vector3>([
            Vector3(1.0, 0.0, 0.0), Vector3(-1.0, 0.0, 0.0),
            Vector3(0.0, 1.0, 0.0), Vector3(0.0, -1.0, 0.0),
            Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, -1.0)
        ])
        this.cubeUps = ArrayList<Vector3>([
            Vector3(0.0, 1.0, 0.0), Vector3(0.0, 1.0, 0.0),
            Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, 1.0),
            Vector3(0.0, 1.0, 0.0), Vector3(0.0, 1.0, 0.0)
        ])
    }

    /**
     * @brief[zh-cn] 获取指定面的方向向量
     * @param[zh-cn] faceIndex 面索引（0..5）
     * @return[zh-cn] 该面的方向向量
     *
     * @brief[en] Get the direction vector for the specified face
     * @param[en] faceIndex Face index (0..5)
     * @return[en] Direction vector for that face
     */
    public func getCubeDirection(faceIndex: Int64): Vector3 {
        return this.cubeDirections[faceIndex]
    }

    /**
     * @brief[zh-cn] 获取指定面的up向量
     * @param[zh-cn] faceIndex 面索引（0..5）
     * @return[zh-cn] 该面的up向量
     *
     * @brief[en] Get the up vector for the specified face
     * @param[en] faceIndex Face index (0..5)
     * @return[en] Up vector for that face
     */
    public func getCubeUp(faceIndex: Int64): Vector3 {
        return this.cubeUps[faceIndex]
    }

    /**
     * @brief[zh-cn] 计算6面立方体阴影相机的view矩阵
     * @param[zh-cn] lightPos 光源世界坐标
     * faceIndex 面索引（0..5）
     * @return[zh-cn] 该面的view矩阵
     *
     * @brief[en] Compute the view matrix for a 6-face cube shadow camera
     * @param[en] lightPos Light world position
     * faceIndex Face index (0..5)
     * @return[en] View matrix for that face
     */
    public func computeFaceViewMatrix(lightPos: Vector3, faceIndex: Int64): Matrix4 {
        let dir = this.cubeDirections[faceIndex]
        let up = this.cubeUps[faceIndex]
        let target = lightPos.clone().add(dir)
        return Matrix4().lookAt(lightPos, target, up)
    }

    /**
     * @brief[zh-cn] 覆写updateMatrices：点光源阴影矩阵为单位矩阵
     * @explain[zh-cn] 
     * 点光源cube阴影不需要shadowMatrix变换，直接用光源位置采样。
     * 主pass shader中: vPointShadowCoord = worldPos - u_pointShadowLightPos。
     * 故这里只更新光源位置，不调用super.updateMatrices。
     * @param[zh-cn] light 正在渲染阴影的光源
     *
     * @brief[en] Override updateMatrices: point light shadow matrix is identity
     * @explain[en] 
     * Point light cube shadows don't need shadowMatrix transformation; they sample using light position directly.
     * In the main pass shader: vPointShadowCoord = worldPos - u_pointShadowLightPos.
     * So only the light position is updated here; super.updateMatrices is not called.
     * @param[en] light The light for which the shadow is being rendered
     */
    public override func updateMatrices(light: Light): Unit {
        // 点光源 cube 阴影不需要 shadowMatrix 变换，直接用光源位置采样
        // 主 pass shader 中: vPointShadowCoord = worldPos - u_pointShadowLightPos
        // 故这里只更新光源位置（light.matrixWorld 已由上层更新）
        // 不调用 super.updateMatrices（那是 DirectionalLight/SpotLight 的逻辑）
        this.matrix.identity()
    }
}
