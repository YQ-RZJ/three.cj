package sp_fullphong

/**
 * shadowplane 渲染场景：
 * - 一个方向光（带阴影）从上方斜照
 * - 一个悬浮的立方体（caster），投影阴影到地面
 * - 一个地面平面（receiver），接收阴影
 * - 一个小球体标记光源位置（不影响光照）
 *
 * 目的：用最简几何体直观验证"光照遮挡→阴影投射"的核心效果。
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
import three.rendering.ThreeRenderer
import three.window.MouseButton

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var cube: Mesh
    public var dirLight: DirectionalLight

    public init(scene!: Scene, camera!: PerspectiveCamera, cube!: Mesh, dirLight!: DirectionalLight) {
        this.scene = scene
        this.camera = camera
        this.cube = cube
        this.dirLight = dirLight
    }
}

/// 创建场景：地面平面+悬浮立方体+方向光+环境光+光源标记
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "ShadowPlaneScene"
    println("  场景创建成功: ${scene.name}")

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 45.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(8.0, 6.0, 8.0)
    camera.lookAt(Vector3(0.0, 1.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（弱，让阴影区不至于全黑） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.2)
    ambient.name = "Ambient"
    scene.add(ambient)

    // ---- 方向光（产生阴影的主光源） ----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
    dirLight.position.set(5.0, 10.0, 7.5)
    dirLight.castShadow = true
    // 阴影贴图分辨率（对齐 boxshow 2048：1024 下 texel 更大，normalBias=0.02 仅覆盖约 1.3 texel，
    // 抗 acne 不足 → 地面仍出现波浪纹；2048 下覆盖约 2.5 texel 与 boxshow 一致）
    dirLight.shadow.mapSize.set(2048.0, 2048.0)
    // 抗 acne（自照亮表面交替亮暗条纹/波浪纹）：以 boxshow 为基线，并针对地面掠射增强
    //   - normalBias：沿世界法线偏移 shadowWorldPosition（shadowmap_vertex.cj:47），棱线处连续不产生接缝
    //     boxshow 内壁是垂直面（光斜射深度梯度小），0.02 足够；本场景地面是水平掠射面
    //     （光方向与法线夹角约 42°，深度梯度大），需要更大偏移（0.05 ≈ 6 texel）才能压住细密条纹
    //   - bias：沿投影深度方向偏移（shadowmap_pars_fragment.cj:108），过大导致棱线阴影错位
    dirLight.shadow.normalBias = 0.05
    dirLight.shadow.bias = -0.001
    // 配置阴影正交相机视锥：紧贴地面 12×12（原 [-8,8] 下地面只占 75%，texel 粗 →
    // 细密条纹更明显；缩到 ±7 覆盖地面 + 立方体，2048 texel 密度提升约 30%，抗 acne 更强）
    match (dirLight.shadow.camera) {
        case oc: OrthographicCamera =>
            oc.left = -7.0; oc.right = 7.0
            oc.top = 7.0; oc.bottom = -7.0
            oc.near = 0.5; oc.far = 50.0
            oc.updateProjectionMatrix()
        case _ => ()
    }
    dirLight.name = "DirLight"
    scene.add(dirLight)
    println("  方向光创建成功: position=(${dirLight.position.x.toString()}, ${dirLight.position.y.toString()}, ${dirLight.position.z.toString()})")

    // ---- 光源位置标记球（不影响光照，仅视觉示意） ----
    let lightMarkerGeom = SphereGeometry(radius: 0.3, widthSegments: 12, heightSegments: 8)
    let lightMarkerMat = MeshPhongMaterial()
    lightMarkerMat.color = Color(0xffff00)   // 黄色小球标记光源位置
    lightMarkerMat.specular = Color(0x000000) // 无高光
    let lightMarker = Mesh(geometry: lightMarkerGeom, material: lightMarkerMat)
    lightMarker.position.copy(dirLight.position)
    lightMarker.name = "LightMarker"
    lightMarker.castShadow = false
    lightMarker.receiveShadow = false
    scene.add(lightMarker)
    println("  光源标记球创建成功")

    // ---- 地面平面（receiver） ----
    let planeGeom = PlaneGeometry(width: 12.0, height: 12.0)
    let planeMat = MeshPhongMaterial()
    planeMat.color = Color(0x888888)   // 灰色地面
    planeMat.specular = Color(0x000000) // 无高光
    planeMat.side = 2  // DoubleSide
    let plane = Mesh(geometry: planeGeom, material: planeMat)
    // PlaneGeometry 默认在 XY 平面，法线 +Z。
    // 旋转 -90° 绕 X 轴使其平躺（法线朝上 +Y）
    plane.rotation.x = -PI / 2.0
    plane.position.set(0.0, 0.0, 0.0)
    plane.name = "GroundPlane"
    plane.castShadow = false
    plane.receiveShadow = true
    scene.add(plane)
    println("  地面平面创建成功")

    // ---- 悬浮立方体（caster） ----
    let boxGeom = BoxGeometry(width: 1.5, height: 1.5, depth: 1.5)
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0x44aaff)     // 蓝色立方体
    boxMat.specular = Color(0x444444)
    boxMat.shininess = 30.0
    let box = Mesh(geometry: boxGeom, material: boxMat)
    box.position.set(0.0, 2.0, 0.0)   // 悬浮在地面上方
    box.name = "FloatingCube"
    box.castShadow = true
    box.receiveShadow = false
    scene.add(box)
    println("  悬浮立方体创建成功")

    println("  场景子对象数: ${scene.children.size}")
    println("")

    return SceneObjects(scene: scene, camera: camera, cube: box, dirLight: dirLight)
}

/// 渲染循环逻辑（相机轨道控制 + 渲染）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）
