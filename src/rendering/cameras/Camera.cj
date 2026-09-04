/**
 * @file[zh-cn] Camera 相机基类
 * @brief[zh-cn] 抽象基类：所有具体相机类型继承本类
 * @explain[zh-cn] 派生自 Object3D，提供相机视矩阵、投影矩阵及近远裁剪面等通用属性。
 *
 * @file[en] Camera base class
 * @brief[en] Abstract base class: all concrete camera types inherit from this class
 * @explain[en] Extends Object3D, provides common camera properties such as view matrix,
 * projection matrix, and near/far clipping planes.
 *
 * @package three.rendering.cameras
 */
package three.rendering.cameras

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.utils.constants.*
import three.rendering.interfaces.ICamera
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 相机抽象基类，所有具体相机类型继承本类
 * @explain[zh-cn] 派生自 Object3D，提供相机视矩阵、投影矩阵及近远裁剪面等通用属性。
 *
 * @brief[en] Camera abstract base class, all concrete camera types inherit from this class
 * @explain[en] Extends Object3D, provides common camera properties such as view matrix,
 * projection matrix, and near/far clipping planes.
 */
@JsonAdapter[withSuperClass = Object3D]
public open class Camera <: Object3D & ICamera {
    /**
     * @brief[zh-cn] 视矩阵的逆矩阵（世界空间 → 观察空间）
     *
     * @brief[en] Inverse of the view matrix (world space → view space)
     */
    public var matrixWorldInverse: Matrix4

    /**
     * @brief[zh-cn] 投影矩阵
     *
     * @brief[en] Projection matrix
     */
    public var projectionMatrix: Matrix4

    /**
     * @brief[zh-cn] 投影矩阵的逆矩阵
     *
     * @brief[en] Inverse projection matrix
     */
    public var projectionMatrixInverse: Matrix4

    /**
     * @brief[zh-cn] 近裁剪面距离。默认 0.1
     *
     * @brief[en] Near clipping plane distance. Default 0.1
     */
    public var near: Float64

    /**
     * @brief[zh-cn] 远裁剪面距离。默认 2000
     *
     * @brief[en] Far clipping plane distance. Default 2000
     */
    public var far: Float64

    /**
     * @brief[zh-cn] 坐标系（WebGLCoordinateSystem / WebGPUCoordinateSystem），决定 Z 方向约定
     *
     * @brief[en] Coordinate system (WebGLCoordinateSystem / WebGPUCoordinateSystem), determines Z direction convention
     */
    public var coordinateSystem: Int64

    /**
     * @brief[zh-cn] 是否反向深度（WebGPU 等使用反向 Z [1,0] 范围）
     *
     * @brief[en] Whether reversed depth (WebGPU etc. use reversed Z [1,0] range)
     */
    @JsonIgnore
    private var _reversedDepth: Bool

    @JsonIgnore
    public mut prop reversedDepth: Bool {
        get() { this._reversedDepth }
        set(v) { this._reversedDepth = v }
    }

    /**
     * @brief[zh-cn] 构造一个新的相机
     * @param[zh-cn] near 近裁剪面距离，默认 0.1
     * far 远裁剪面距离，默认 2000
     *
     * @brief[en] Construct a new camera
     * @param[en] near Near clipping plane distance, default 0.1
     * far Far clipping plane distance, default 2000
     */
    public init(near!: Float64 = 0.1, far!: Float64 = 2000.0) {
        super()
        this.matrixWorldInverse = Matrix4()
        this.projectionMatrix = Matrix4()
        this.projectionMatrixInverse = Matrix4()
        this.near = near
        this.far = far
        this.kind = "Camera"
        this.coordinateSystem = WebGPUCoordinateSystem
        this._reversedDepth = false
    }

    /**
     * @brief[zh-cn] 返回相机朝向的世界方向（左手系 bgfx 下相机朝 +Z）
     * @param[zh-cn] target 目标向量
     * @return[zh-cn] 世界方向向量
     *
     * @brief[en] Return the world direction the camera is facing (in left-handed bgfx, camera faces +Z)
     * @param[en] target Target vector
     * @return[en] World direction vector
     */
    public override func getWorldDirection(target: Vector3): Vector3 {
        return super.getWorldDirection(target)
    }

    /**
     * @brief[zh-cn] 更新本相机及父级的世界矩阵，并同步 matrixWorldInverse
     * @param[zh-cn] force 是否强制更新
     *
     * @brief[en] Update world matrix of this camera and its parents, and sync matrixWorldInverse
     * @param[en] force Whether to force update
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        super.updateMatrixWorld(force)
        // 与 glTF 规范一致：从视矩阵中剔除缩放。
        let q = Quaternion()
        let s = Vector3()
        this.matrixWorld.decompose(this.position, q, s)
        if (s.x == 1.0 && s.y == 1.0 && s.z == 1.0) {
            this.matrixWorldInverse.copy(this.matrixWorld).invert()
        } else {
            this.matrixWorldInverse.compose(this.position, q, Vector3(1.0, 1.0, 1.0)).invert()
        }
    }

    /**
     * @brief[zh-cn] 将给定相机实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy values from the given camera instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] This instance
     */
    public open override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case c: Camera =>
                this.matrixWorldInverse.copy(c.matrixWorldInverse)
                this.projectionMatrix.copy(c.projectionMatrix)
                this.projectionMatrixInverse.copy(c.projectionMatrixInverse)
                this.coordinateSystem = c.coordinateSystem
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新相机实例
     * @return[zh-cn] 新相机实例
     *
     * @brief[en] Return a new camera instance with the same values as this instance
     * @return[en] New camera instance
     */
    public override func clone(): Object3D {
        return Camera().copy(this, true)
    }

    /**
     * @brief[zh-cn] 更新本相机及父级/子级的世界矩阵，并同步 matrixWorldInverse
     * @param[zh-cn] updateParents 是否更新父级
     * updateChildren 是否更新子级
     * force 是否强制更新
     *
     * @brief[en] Update world matrix of this camera, its parents and children, and sync matrixWorldInverse
     * @param[en] updateParents Whether to update parents
     * updateChildren Whether to update children
     * force Whether to force update
     */
    public override func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit {
        if (updateParents) {
            match (this.parent) {
                case Some(p) => p.updateWorldMatrix(true, false, force)
                case None => ()
            }
        }
        super.updateWorldMatrix(updateParents, updateChildren, force)
        this.matrixWorldInverse.copy(this.matrixWorld).invert()
    }
}
