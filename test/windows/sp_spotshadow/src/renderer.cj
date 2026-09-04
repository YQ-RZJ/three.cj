package sp_spotshadow

/**
 * sp_spotshadow 渲染场景：
 * - 一个聚光灯（带阴影）从斜上方照射悬浮立方体
 * - 悬浮立方体（caster）投影到地面
 * - 地面平面（receiver）接收阴影
 * - 光源位置标记球（不影响光照）
 *
 * 目的：验证 SpotLight 阴影投射能力。
 * 阴影贴图通过 BgfxShadowMap.getShadowMap(SpotLight.id) 按 SpotLight.id 分配独立 FB，
 * 主 pass 渲染时按光源 id 查回对应阴影纹理。
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
    public var spotLight: SpotLight

    public init(scene!: Scene, camera!: PerspectiveCamera, cube!: Mesh, spotLight!: SpotLight) {
        this.scene = scene
        this.camera = camera
        this.cube = cube
        this.spotLight = spotLight
    }
}

/// 创建场景：地面平面+悬浮立方体+聚光灯+环境光+光源标记
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "SpotShadowScene"
    println("  场景创建成功: ${scene.name}")

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 45.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(8.0, 6.0, 8.0)
    camera.lookAt(Vector3(0.0, 1.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（中等亮度，让背光面和非锥体区域可见） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.5)
    ambient.name = "Ambient"
    scene.add(ambient)

    // ---- 聚光灯（产生阴影的主光源） ----
    // angle=1.0rad ≈ 57°，penumbra=0.3 软半影，确保地面平面在锥体内
    // 强度适中、decay=1 小衰减，确保立方体与地面充分受光
    let spotLight = SpotLight(color: Color(0xffffff), intensity: 10.0,
                              distance: 30.0, angle: 1.0, penumbra: 0.3, decay: 1.0)
    spotLight.position.set(5.0, 10.0, 5.0)
    spotLight.target.position.set(0.0, 1.0, 0.0)
    spotLight.castShadow = true
    // 阴影贴图分辨率
    spotLight.shadow.mapSize.set(1024.0, 1024.0)
    // 深度偏移：负值消除地面 shadow acne（波浪纹）； SpotLight 典型区间 [-0.0001, -0.001]
    spotLight.shadow.bias = -0.0005
    // 聚光阴影相机参数（fov 由 SpotLightShadow.updateMatrices 按 angle*focus 自动调整）
    match (spotLight.shadow.camera) {
        case pc: PerspectiveCamera =>
            pc.near = 1.0
            pc.far = 30.0
            pc.updateProjectionMatrix()
        case _ => ()
    }
    spotLight.name = "SpotLight"
    scene.add(spotLight)
    scene.add(spotLight.target)
    println("  聚光灯创建成功: position=(${spotLight.position.x.toString()}, ${spotLight.position.y.toString()}, ${spotLight.position.z.toString()}) angle=${spotLight.angle.toString()}")

    // ---- 光源位置标记球（不影响光照，仅视觉示意） ----
    let lightMarkerGeom = SphereGeometry(radius: 0.3, widthSegments: 12, heightSegments: 8)
    let lightMarkerMat = MeshPhongMaterial()
    lightMarkerMat.color = Color(0xffff00)   // 黄色小球标记光源位置
    lightMarkerMat.specular = Color(0x000000) // 无高光
    let lightMarker = Mesh(geometry: lightMarkerGeom, material: lightMarkerMat)
    lightMarker.position.copy(spotLight.position)
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

    return SceneObjects(scene: scene, camera: camera, cube: box, spotLight: spotLight)
}
