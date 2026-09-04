package sp_pointshadow

/**
 * sp_pointshadow 渲染场景：
 * - 开放盒子（去掉 +Z 前面板，相机从开口看内部）作为接收阴影的包围盒
 * - 最中心固定一个点光源（带阴影）
 * - 一个球体全方位围绕光源运动（覆盖 cube 6 个面方向）
 *
 * 目的：验证「单个点光源」的阴影形状是否正确（球体投影应为圆形），
 * 以区分点光源阴影异常是点光源本身问题，还是多光源混合才出现。
 */

import std.sync.*
import std.collection.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.cameras.*
import three.rendering.lights.*

/// 盒子内部半宽（内壁范围）
public let BOX_HALF: Float64 = 4.0
/// 盒子深度半宽
public let BOX_DEPTH: Float64 = 4.0

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var box: Mesh
    public var pointLight: PointLight
    public var sphere: Mesh

    public init(scene!: Scene, camera!: PerspectiveCamera, box!: Mesh, pointLight!: PointLight, sphere!: Mesh) {
        this.scene = scene
        this.camera = camera
        this.box = box
        this.pointLight = pointLight
        this.sphere = sphere
    }
}

/// 开放盒子几何体（无前面板 +Z，内壁法线向内）
/// 对照 boxshow/src/resources.cj createOpenBoxGeometry
public func createOpenBoxGeometry(width: Float64, height: Float64, depth: Float64): BufferGeometry {
    let w2 = width / 2.0
    let h2 = height / 2.0
    let d2 = depth / 2.0

    // 5 个面 × 4 顶点 = 20 顶点
    // 顺序：back(-Z), top(+Y), bottom(-Y), right(+X), left(-X)
    let posData = [
        // back (-Z)
        -w2, -h2, -d2,   w2, -h2, -d2,   w2,  h2, -d2,  -w2,  h2, -d2,
        // top (+Y)
        -w2,  h2, -d2,   w2,  h2, -d2,   w2,  h2,  d2,  -w2,  h2,  d2,
        // bottom (-Y)
        -w2, -h2,  d2,   w2, -h2,  d2,   w2, -h2, -d2,  -w2, -h2, -d2,
        // right (+X)
         w2, -h2,  d2,   w2, -h2, -d2,   w2,  h2, -d2,   w2,  h2,  d2,
        // left (-X)
        -w2, -h2, -d2,  -w2, -h2,  d2,  -w2,  h2,  d2,  -w2,  h2, -d2,
    ]
    // 内壁法线：每个面法线指向盒内
    let normData = [
        // back (-Z): normal +Z
        0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,
        // top (+Y): normal -Y
        0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,
        // bottom (-Y): normal +Y
        0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,
        // right (+X): normal -X
       -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,
        // left (-X): normal +X
        1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    ]
    // 5 个面 × 2 三角形 × 3 顶点 = 30 索引
    let idxData = [
        0, 1, 2,  0, 2, 3,       // back
        4, 5, 6,  4, 6, 7,       // top
        8, 9,10,  8,10,11,       // bottom
       12,14,13, 12,15,14,       // right (reversed winding for inward normal -X)
       16,18,17, 16,19,18,       // left (reversed winding for inward normal +X)
    ]

    let positions = Array<Float64>(posData.size, { i => posData[i] })
    let normals = Array<Float64>(normData.size, { i => normData[i] })
    let indices = Array<Float64>(idxData.size, { i => Float64(idxData[i]) })

    let geom = BufferGeometry()
    geom.setIndex(BufferAttribute(indices, 1))
    geom.setAttribute("position", BufferAttribute(positions, 3))
    geom.setAttribute("normal", BufferAttribute(normals, 3))
    return geom
}

/// 创建场景：开放盒子 + 中心固定点光源 + 全方位绕行球体 + 环境光
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "PointShadowBoxScene"
    println("  场景创建成功: ${scene.name}")

    // ---- 相机：在盒子前方（+Z 开口）略高位置，朝向盒子内部 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 1.5, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（弱，让阴影区不至于全黑） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.2)
    ambient.name = "Ambient"
    scene.add(ambient)

    // ---- 中心固定点光源（唯一光源，验证单点光源阴影形状） ----
    let pointLight = PointLight(color: Color(0xffffff), intensity: 12.0,
                                distance: 0.0, decay: 1.0)
    pointLight.position.set(0.0, 0.0, 0.0)   // 盒子中心
    pointLight.castShadow = true
    pointLight.shadow.mapSize.set(512.0, 512.0)
    // 抗 acne（cube 阴影贴图自照亮表面交替亮暗条纹/波浪纹）：与 boxshow 点光源一致
    // 点光源阴影 acne 在 fragment 端 dp += bias（shadowmap_pars_fragment.cj getPointShadow），需负 bias 抗自阴影
    // boxshow 对点光源用 -0.01；此处 cube 范围更大、精度更稀，取 -0.02 强化抗 acne
    pointLight.shadow.bias = -0.02
    // 阴影相机 near/far 覆盖盒子内部（与 face 渲染一致的 slot.near/slot.far）
    match (pointLight.shadow.camera) {
        case pc: PerspectiveCamera =>
            pc.fov = 90.0
            pc.near = 0.1
            pc.far = 12.0
            pc.updateProjectionMatrix()
        case _ => ()
    }
    pointLight.name = "CenterPointLight"
    scene.add(pointLight)
    println("  中心点光源创建成功: position=(0, 0, 0)")

    // ---- 开放盒子（去掉前面板 +Z，让相机能看到内部；内壁接收阴影） ----
    let boxGeom = createOpenBoxGeometry(BOX_HALF * 2.0, BOX_HALF * 2.0, BOX_DEPTH * 2.0)
    boxGeom.name = "OpenBox"
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0xdddddd)
    boxMat.specular = Color(0x333333)
    boxMat.shininess = 20.0
    boxMat.side = 2  // DoubleSide：内壁法线向内，双面渲染确保所有面可见
    let box = Mesh(geometry: boxGeom, material: boxMat)
    box.name = "OpenBox"
    box.castShadow = false
    box.receiveShadow = true
    box.position.set(0.0, 0.0, 0.0)
    scene.add(box)
    println("  开放盒子创建成功")

    // ---- 绕行球体（caster）：全方位围绕光源运动，覆盖 cube 6 个面方向 ----
    let sphereGeom = SphereGeometry(radius: 0.6, widthSegments: 24, heightSegments: 16)
    let sphereMat = MeshPhongMaterial()
    sphereMat.color = Color(0xff3030)
    sphereMat.specular = Color(0xffffff)
    sphereMat.shininess = 60.0
    let sphere = Mesh(geometry: sphereGeom, material: sphereMat)
    sphere.position.set(2.5, 0.0, 0.0)   // 初始 +X 方向
    sphere.name = "OrbitSphere"
    sphere.castShadow = true
    sphere.receiveShadow = false
    scene.add(sphere)
    println("  绕行球体创建成功")

    println("  场景子对象数: ${scene.children.size}")
    println("")

    return SceneObjects(scene: scene, camera: camera, box: box, pointLight: pointLight, sphere: sphere)
}
