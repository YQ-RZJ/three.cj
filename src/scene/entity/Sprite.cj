/**
 * @file[zh-cn] Sprite
 * @brief[zh-cn] 精灵渲染对象，始终朝向相机的 2D 平面
 * @explain[zh-cn] 与 Mesh 不同：Sprite 始终面向相机（无旋转），由 material.map 贴图 + scale 缩放定义大小。
 * Sprite 不产生阴影、不参与 morphTargets；raycast 退化为平面相交 + UV 插值。
 *
 * @file[en] Sprite
 * @brief[en] Sprite rendering object, a 2D plane always facing the camera
 * @explain[en] Unlike Mesh: Sprite always faces the camera (no rotation), sized by material.map texture + scale.
 * Sprite does not cast shadows or participate in morphTargets; raycast degenerates to plane intersection + UV interpolation.
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.cameras.*
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 内部缓存向量，避免重复分配
 *
 * @brief[en] Internal cached vectors to avoid repeated allocation
 */
private let _intersectPoint = Vector3()
private let _worldScale = Vector3()
private let _mvPosition = Vector3()
private let _alignedPosition = Vector2()
private let _rotatedPosition = Vector2()
private let _viewWorldMatrix = Matrix4()
private let _vA = Vector3()
private let _vB = Vector3()
private let _vC = Vector3()
private let _uvA = Vector2()
private let _uvB = Vector2()
private let _uvC = Vector2()

/**
 * @brief[zh-cn] 精灵渲染对象，始终朝向相机的 2D 平面
 * @explain[zh-cn] 常用于粒子、光晕、贴图广告牌等，无旋转、不产生阴影、不参与 morphTargets
 *
 * @brief[en] Sprite rendering object, a 2D plane always facing the camera
 * @explain[en] Commonly used for particles, halos, texture billboards; no rotation, no shadows, no morphTargets
 */
@JsonAdapter[withSuperClass = Object3D]
public class Sprite <: Object3D {
    /**
     * @brief[zh-cn] 精灵材质（必为 SpriteMaterial）
     *
     * @brief[en] Sprite material (must be SpriteMaterial)
     */
    public var material: Material

    /**
     * @brief[zh-cn] 中心点偏移（归一化 UV 坐标系下，0.0~1.0），默认 (0.5, 0.5) 即中心
     *
     * @brief[en] Center offset (normalized UV coordinates, 0.0~1.0), default (0.5, 0.5) for center
     */
    public var center: Vector2

    /**
     * @brief[zh-cn] 构造一个新的精灵
     * @param[zh-cn] material 精灵材质，默认空 SpriteMaterial
     *
     * @brief[en] Construct a new sprite
     * @param[en] material Sprite material, default empty SpriteMaterial
     */
    public init(material!: Material = SpriteMaterial()) {
        super()
        this.kind = "Sprite"
        this.material = material
        this.center = Vector2(0.5, 0.5)
    }

    /**
     * @brief[zh-cn] 共享单位 quad 面片
     * @explain[zh-cn] 渲染管线收集时调用本方法获取面片，由 spriteVS 广告牌变换按对象 scale 放大并始终朝向相机
     * @return[zh-cn] 单位 quad 面片
     *
     * @brief[en] Shared unit quad geometry
     * @explain[en] Called by render pipeline to get quad; spriteVS billboard transform scales by object scale and always faces camera
     * @return[en] Unit quad geometry
     */
    @JsonIgnore
    private static var _unitQuadGeom: Option<BufferGeometry> = None

    public static func _getUnitQuadGeometry(): BufferGeometry {
        match (_unitQuadGeom) {
            case Some(g) => return g
            case None => ()
        }
        // 单位 quad：[-0.5, 0.5]²，含 position/uv/index（CCW 点序）
        let positions = [-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0]
        let uvs = [0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]
        let indices = [0.0, 1.0, 2.0, 0.0, 2.0, 3.0]
        let geom = BufferGeometry()
        geom.setAttribute("position", BufferAttribute(positions, 3))
        geom.setAttribute("uv", BufferAttribute(uvs, 2))
        geom.setIndex(BufferAttribute(indices, 1))
        geom.computeBoundingSphere()
        _unitQuadGeom = Some(geom)
        return geom
    }

    /**
     * @brief[zh-cn] 视锥剔除测试
     * @param[zh-cn] frustum 视锥体
     * @return[zh-cn] 与视锥相交返回 true
     *
     * @brief[en] Frustum culling test
     * @param[en] frustum The frustum
     * @return[en] Returns true if intersects with frustum
     */
    public func intersectsFrustum(frustum: Frustum): Bool {
        return frustum.intersectsObject(this)
    }

    /**
     * @brief[zh-cn] 射线相交检测
     * @explain[zh-cn] 将精灵退化为本地空间 Z=0 平面，与射线相交后做点在平面矩形内的判断 + UV 插值
     * @param[zh-cn] raycaster 射线发射器
     * intersects 命中结果累加数组
     *
     * @brief[en] Ray intersection test
     * @explain[en] Degenerates sprite to local space Z=0 plane, checks ray-plane intersection then point-in-rect + UV interpolation
     * @param[en] raycaster The raycaster
     * intersects Intersection result accumulator
     */
    public func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {
        // 检查相机是否已设置
        match (raycaster.camera) {
            case Some(_) => ()
            case None => return
        }

        // 获取世界缩放
        _worldScale.setFromMatrixScale(this.matrixWorld)

        // 构建 viewWorldMatrix
        let camera = raycaster.camera.getOrThrow()
        match (camera) {
            case cam: Camera =>
                _viewWorldMatrix.copy(cam.matrixWorld)
                this.modelViewMatrix.multiplyMatrices(cam.matrixWorldInverse, this.matrixWorld)
            case _ => return
        }

        // 获取模型视图位置
        _mvPosition.setFromMatrixPosition(this.modelViewMatrix)

        // 处理 sizeAttenuation
        
        // 用 -_mvPosition.z 乘以 worldScale，使粒子保持屏幕空间恒定尺寸
        match (camera) {
            case cam: PerspectiveCamera =>
                match (this.material) {
                    case sm: SpriteMaterial =>
                        if (!sm.sizeAttenuation) {
                            _worldScale.multiplyScalar(-_mvPosition.z)
                        }
                    case _ => ()
                }
            case _ => ()
        }

        // 处理旋转
        let rotation = match (this.material) {
            case sm: SpriteMaterial => sm.rotation
            case _ => 0.0
        }
        let hasRotation = rotation != 0.0
        let cosR = if (hasRotation) { cos(rotation) } else { 0.0 }
        let sinR = if (hasRotation) { sin(rotation) } else { 0.0 }

        let center = this.center

        // 第一个三角形：(-0.5,-0.5,0), (0.5,-0.5,0), (0.5,0.5,0)
        _transformVertex(_vA.set(-0.5, -0.5, 0.0), _mvPosition, center, _worldScale, sinR, cosR, hasRotation)
        _transformVertex(_vB.set(0.5, -0.5, 0.0), _mvPosition, center, _worldScale, sinR, cosR, hasRotation)
        _transformVertex(_vC.set(0.5, 0.5, 0.0), _mvPosition, center, _worldScale, sinR, cosR, hasRotation)

        _uvA.set(0.0, 0.0)
        _uvB.set(1.0, 0.0)
        _uvC.set(1.0, 1.0)

        // 检查第一个三角形
        var intersect = raycaster.ray.intersectTriangle(_vA, _vB, _vC, false, _intersectPoint)

        if (intersect.isNone()) {
            // 检查第二个三角形
            _transformVertex(_vB.set(-0.5, 0.5, 0.0), _mvPosition, center, _worldScale, sinR, cosR, hasRotation)
            _uvB.set(0.0, 1.0)

            intersect = raycaster.ray.intersectTriangle(_vA, _vC, _vB, false, _intersectPoint)
            if (intersect.isNone()) {
                return
            }
        }

        // 计算距离
        let distance = raycaster.ray.origin.distanceTo(_intersectPoint)

        // 检查距离范围
        if (distance < raycaster.near || distance > raycaster.far) { return }

        // 计算 UV 插值
        
        // Ignore: 仓颉侧 Triangle.getInterpolation 仅接受 Vector3，故将 UV 的 x,y 作为 Vector3 的 x,y,z=0 传递，与 JS 计算结果等价。
        let uvA3 = Vector3(_uvA.x, _uvA.y, 0.0)
        let uvB3 = Vector3(_uvB.x, _uvB.y, 0.0)
        let uvC3 = Vector3(_uvC.x, _uvC.y, 0.0)
        let uvResult = Vector3()
        Triangle.computeInterpolation(_intersectPoint, _vA, _vB, _vC, uvA3, uvB3, uvC3, uvResult)

        // 构建相交结果
        let intersection = Intersection()
        intersection.distance = distance
        intersection.point = _intersectPoint.clone()
        intersection.obj = Some(this)
        intersection.uv = Some(Vector2(uvResult.x, uvResult.y))

        intersects.add(intersection)
    }

    /**
     * @brief[zh-cn] 将给定精灵实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given sprite instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: Sprite =>
                this.material = s.material.clone()
                this.center.copy(s.center)
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新精灵实例
     * @return[zh-cn] 新精灵实例
     *
     * @brief[en] Return a new sprite instance with the same values as this instance
     * @return[en] New sprite instance
     */
    public override func clone(): Object3D {
        let obj = Sprite()
        return obj.copy(this, true)
    }

    /**
     * @brief[zh-cn] 计算精灵的世界空间包围球（覆写 Object3D）
     * @explain[zh-cn] 精灵无几何体：默认中心 (0.5,0.5) 到精灵 center 的距离作为半径增量
     * @return[zh-cn] Some([cx, cy, cz, radius]) 或 None
     *
     * @brief[en] Compute sprite's world space bounding sphere (overrides Object3D)
     * @explain[en] Sprite has no geometry: distance from default center (0.5,0.5) to sprite center as radius increment
     * @return[en] Some([cx, cy, cz, radius]) or None
     */
    public override func getWorldBoundingSphere(): Option<Array<Float64>> {
        
        let offset = Vector2(0.5, 0.5).distanceTo(this.center)
        let sphere = Sphere(Vector3(0.0, 0.0, 0.0), 0.7071067811865476 + offset)
        sphere.applyMatrix4(this.matrixWorld)
        return Some([sphere.center.x, sphere.center.y, sphere.center.z, sphere.radius])
    }
}

/**
 * @brief[zh-cn] 变换顶点：将精灵的本地顶点变换到世界空间
 * @param[zh-cn] vertexPosition 顶点位置
 * mvPosition 模型视图位置
 * center 中心点偏移
 * scale 世界缩放
 * sinR 旋转正弦值
 * cosR 旋转余弦值
 * hasRotation 是否有旋转
 *
 * @brief[en] Transform vertex: transform sprite's local vertex to world space
 * @param[en] vertexPosition Vertex position
 * mvPosition Model-view position
 * center Center offset
 * scale World scale
 * sinR Rotation sine value
 * cosR Rotation cosine value
 * hasRotation Whether has rotation
 */
private func _transformVertex(vertexPosition: Vector3, mvPosition: Vector3, center: Vector2, scale: Vector3, sinR: Float64, cosR: Float64, hasRotation: Bool): Unit {
    // 计算相机空间中的位置
    _alignedPosition.subVectors(
        Vector2(vertexPosition.x, vertexPosition.y),
        center
    ).addScalar(0.5).multiply(Vector2(scale.x, scale.y))

    // 处理旋转
    if (hasRotation) {
        _rotatedPosition.x = (cosR * _alignedPosition.x) - (sinR * _alignedPosition.y)
        _rotatedPosition.y = (sinR * _alignedPosition.x) + (cosR * _alignedPosition.y)
    } else {
        _rotatedPosition.copy(_alignedPosition)
    }

    // 应用模型视图位置偏移
    vertexPosition.copy(mvPosition)
    vertexPosition.x += _rotatedPosition.x
    vertexPosition.y += _rotatedPosition.y

    // 变换到世界空间
    vertexPosition.applyMatrix4(_viewWorldMatrix)
}
