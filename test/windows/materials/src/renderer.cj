package sp_materials

/**
 * sp_materials 渲染场景（v2 生命周期模式）：
 * - 一圈 18 颗材质球均匀分布在半径 7 的圆上，覆盖全部材质类型：
 *     MeshBasic / MeshLambert / MeshPhong / MeshStandard / MeshPhysical /
 *     MeshNormal / MeshMatcap / MeshToon / MeshDepth / MeshDistance /
 *     Shadow / RawShader / Shader / LineBasic / LineDashed / Points / Sprite
 * - 每颗球材质类型 + 颜色不同，便于视觉识别；材质球缓慢自转
 * - 相机与 geometries 测试一致：鼠标左键拖动自由旋转、滚轮缩放
 * - 相机正前方发射射线，命中材质球时打印材质名 debug 日志
 *   （对照 geometries 测试的 Raycaster 用法 + geometry.computeBoundingSphere 前提）
 *
 * 说明：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
 */

import std.sync.*
import std.time.*
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
import three.rendering.cameras.*
import three.rendering.lights.*
import three.scene.entity.LineSegments
import three.rendering.BgfxRenderer

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var spheres: ArrayList<Object3D>
    public var extras: ArrayList<Object3D>

    public init(scene!: Scene, camera!: PerspectiveCamera, spheres!: ArrayList<Object3D>, extras!: ArrayList<Object3D>) {
        this.scene = scene
        this.camera = camera
        this.spheres = spheres
        this.extras = extras
    }
}

/// 按索引创建对应材质类型的球体
/// 覆盖渲染器分发的全部材质类型（对照 BgfxBackend 的 mat.kind 分发）
/// SpriteMaterial 特殊：改为面片模型（PlaneGeometry）展示广告牌视觉效果
/// （对照 three.js Sprite：SpriteMaterial 本质渲染于始终朝向相机的面片）
func createSphereByMaterialType(i: Int64): Object3D {
    var material: Material = MeshBasicMaterial()
    var typeName = ""

    match (i % 17) {
        case 0 =>
            let m = MeshBasicMaterial()
            m.color = Color(0xff4040)
            material = m
            typeName = "MeshBasicMaterial"
        case 1 =>
            let m = MeshLambertMaterial()
            m.color = Color(0x40ff40)
            material = m
            typeName = "MeshLambertMaterial"
        case 2 =>
            let m = MeshPhongMaterial()
            m.color = Color(0x4040ff)
            m.specular = Color(0xffffff)
            m.shininess = 60.0
            material = m
            typeName = "MeshPhongMaterial"
        case 3 =>
            let m = MeshStandardMaterial()
            m.color = Color(0xffff40)
            m.roughness = 0.3
            m.metalness = 0.6
            material = m
            typeName = "MeshStandardMaterial"
        case 4 =>
            let m = MeshPhysicalMaterial()
            m.color = Color(0xff40ff)
            m.clearcoat = 0.6
            m.clearcoatRoughness = 0.2
            m.roughness = 0.4
            m.metalness = 0.3
            material = m
            typeName = "MeshPhysicalMaterial"
        case 5 =>
            let m = MeshNormalMaterial()
            m.color = Color(0x40ffff)
            material = m
            typeName = "MeshNormalMaterial"
        case 6 =>
            let m = MeshMatcapMaterial()
            m.color = Color(0xffaa40)
            material = m
            typeName = "MeshMatcapMaterial"
        case 7 =>
            let m = MeshToonMaterial()
            m.color = Color(0x40aaff)
            material = m
            typeName = "MeshToonMaterial"
        case 8 =>
            let m = MeshDepthMaterial()
            m.color = Color(0xffffff)
            material = m
            typeName = "MeshDepthMaterial"
        case 9 =>
            let m = MeshDistanceMaterial()
            m.color = Color(0xffffff)
            material = m
            typeName = "MeshDistanceMaterial"
        case 10 =>
            let m = ShadowMaterial()
            m.color = Color(0x000000)
            material = m
            typeName = "ShadowMaterial"
        case 11 =>
            let m = RawShaderMaterial()
            m.color = Color(0xaaaaaa)
            material = m
            typeName = "RawShaderMaterial"
        case 12 =>
            let m = ShaderMaterial()
            m.color = Color(0xaaaaaa)
            material = m
            typeName = "ShaderMaterial"
        case 13 =>
            let m = LineBasicMaterial()
            m.color = Color(0xff8080)
            material = m
            typeName = "LineBasicMaterial"
        case 14 =>
            let m = LineDashedMaterial()
            m.color = Color(0x80ff80)
            m.dashSize = 0.3
            m.gapSize = 0.2
            material = m
            typeName = "LineDashedMaterial"
        case 15 =>
            let m = PointsMaterial()
            m.color = Color(0x8080ff)
            m.size = 0.15
            material = m
            typeName = "PointsMaterial"
        case _ =>
            let m = SpriteMaterial()
            m.color = Color(0xffff80)
            material = m
            typeName = "SpriteMaterial"
    }

    // 模型适配（对照 three.js：材质决定着色，图元/模型决定视觉形态）：
    //   - SpriteMaterial → PlaneGeometry 面片（广告牌，spriteVS 内始终朝向相机）
    //   - LineBasicMaterial/LineDashedMaterial → EdgesGeometry 线框球（LINES 图元，
    //     只渲染边缘线段，避免球体三角索引被 LINES 图元渲染成混乱线条）
    //   - PointsMaterial → SphereGeometry 球体（POINTS 图元，顶点渲染为点云）
    //   - 其余 → SphereGeometry 球体
    let geom = if (typeName == "SpriteMaterial") {
        PlaneGeometry(width: 1.8, height: 1.8)
    } else if (typeName == "LineBasicMaterial" || typeName == "LineDashedMaterial") {
        EdgesGeometry(SphereGeometry(radius: 0.9, widthSegments: 20, heightSegments: 14))
    } else {
        SphereGeometry(radius: 0.9, widthSegments: 20, heightSegments: 14)
    }
    // 对照 geometries 测试：Mesh.raycast 依赖 geometry.boundingSphere，须先计算
    geom.computeBoundingSphere()

    let obj = if (typeName == "LineBasicMaterial" || typeName == "LineDashedMaterial") {
        let lineObj = LineSegments(geometry: geom, material: material)
        if (typeName == "LineDashedMaterial") {
            lineObj.computeLineDistances()
        }
        lineObj
    } else {
        Mesh(geometry: geom, material: material)
    }
    obj.name = typeName
    return obj
}

/// 创建场景：一圈 18 颗材质球 + 相机 + 光源
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "MaterialsScene"

    // ---- 相机（位于圆心，即原点） ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 0.0, 0.0)
    camera.name = "CenterCamera"

    // ---- 光源（照亮 Lambert/Phong/Standard 等） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.35)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.2)
    dirLight.position.set(5.0, 8.0, 5.0)
    scene.add(dirLight)
    let dirLight2 = DirectionalLight(color: Color(0xffffff), intensity: 0.6)
    dirLight2.position.set(-6.0, -4.0, -6.0)
    scene.add(dirLight2)

    // ---- 一圈 18 颗材质球均匀分布（半径 7） ----
    let spheres = ArrayList<Object3D>()
    let COUNT = 18
    var sphereArr = Array<Object3D>(COUNT, { _ => Object3D() })
    for (i in 0..COUNT) {
        let obj = createSphereByMaterialType(i)
        let angle = Float64(i) * PI * 2.0 / Float64(COUNT)
        obj.position.set(7.0 * sin(angle), 0.0, 7.0 * cos(angle))
        sphereArr[i] = obj
        scene.add(obj)
    }
    // 对照仓颉 std: ArrayList.add(all:) 批量追加
    spheres.add(all: sphereArr)

    println("  场景创建成功: ${scene.name}")
    println("  材质球总数: ${spheres.size}")
    println("  覆盖材质类型: Basic/Lambert/Phong/Standard/Physical/Normal/Matcap/Toon/Depth/Distance/Shadow/RawShader/Shader/LineBasic/LineDashed/Points/Sprite")
    println("  相机: 原点 (0,0,0)，鼠标左键拖动旋转、滚轮缩放")
    println("")

    return SceneObjects(scene: scene, camera: camera, spheres: spheres, extras: ArrayList<Object3D>())
}
