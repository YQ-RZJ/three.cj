package sp_shadowproj

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
    // 阴影贴图分辨率
    dirLight.shadow.mapSize.set(1024.0, 1024.0)
    // 配置阴影正交相机视锥：覆盖地面范围和立方体高度
    match (dirLight.shadow.camera) {
        case oc: OrthographicCamera =>
            oc.left = -8.0; oc.right = 8.0
            oc.top = 8.0; oc.bottom = -8.0
            oc.near = 0.5; oc.far = 30.0
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
