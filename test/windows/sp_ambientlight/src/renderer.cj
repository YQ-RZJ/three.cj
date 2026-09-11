package sp_ambientlight

/**
 * sp_ambientlight 渲染场景：
 * - 一个环境光（AmbientLight）：从各方向均匀照亮场景，不产生阴影
 * - 一个方向光（DirectionalLight，castShadow=true）：产生遮挡阴影效果
 * - 悬浮立方体（caster）+ 地面平面（receiver）
 *
 * 目的：验证 AmbientLight 的 u_ambientColor 传递与均匀打亮效果，
 * 同时保留方向光阴影以对比"环境光 vs 直接光+阴影"。
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
    public var ambient: AmbientLight
    public var dirLight: DirectionalLight

    public init(scene!: Scene, camera!: PerspectiveCamera, cube!: Mesh, ambient!: AmbientLight, dirLight!: DirectionalLight) {
        this.scene = scene
        this.camera = camera
        this.cube = cube
        this.ambient = ambient
        this.dirLight = dirLight
    }
}

/// 创建场景：地面平面+悬浮立方体+环境光+方向光（阴影）
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "AmbientLightScene"
    println("  场景创建成功: ${scene.name}")

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 45.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(8.0, 6.0, 8.0)
    camera.lookAt(Vector3(0.0, 1.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（被测光源：均匀打亮场景）----
    // 对照 three.js webgl_lights_ambientlight 示例：
    // 环境光不产生阴影、不依赖方向/位置，颜色均匀叠加到各物体。
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.45)
    ambient.name = "Ambient"
    scene.add(ambient)
    println("  环境光创建成功: color=#ffffff intensity=0.45")

    // ---- 方向光（产生遮挡阴影效果的辅助光源）----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
    dirLight.position.set(5.0, 10.0, 7.5)
    dirLight.castShadow = true
    // 阴影贴图分辨率：1024 下 texel 更大，抗 acne 不足 → 地面出现波浪纹；2048 下密度更高
    dirLight.shadow.mapSize.set(2048.0, 2048.0)
    // 抗 acne（自照亮表面交替亮暗条纹/波浪纹）：以 sp_fullphong 为基线
    //   - normalBias：沿世界法线偏移 shadowWorldPosition（shadowmap_vertex.cj:47），
    //     地面是水平掠射面（光方向与法线夹角约 42°，深度梯度大），
    //     需要较大偏移（0.05 ≈ 6 texel）才能压住细密条纹
    //   - bias：沿投影深度方向偏移（shadowmap_pars_fragment.cj:108），过大导致棱线阴影错位
    dirLight.shadow.normalBias = 0.05
    dirLight.shadow.bias = -0.001
    // 配置阴影正交相机视锥：紧贴地面 12×12（±7 覆盖地面 + 立方体，texel 密度提升约 30%）
    match (dirLight.shadow.camera) {
        case oc: OrthographicCamera =>
            oc.left = -7.0; oc.right = 7.0
            oc.top = 7.0; oc.bottom = -7.0
            oc.near = 0.5; oc.far = 30.0
            oc.updateProjectionMatrix()
        case _ => ()
    }
    dirLight.name = "DirLight"
    scene.add(dirLight)
    println("  方向光创建成功（带阴影）")

    // ---- 光源位置标记球（不影响光照，仅视觉示意）----
    let lightMarkerGeom = SphereGeometry(radius: 0.3, widthSegments: 12, heightSegments: 8)
    let lightMarkerMat = MeshPhongMaterial()
    lightMarkerMat.color = Color(0xffff00)   // 黄色小球标记方向光位置
    lightMarkerMat.specular = Color(0x000000)
    let lightMarker = Mesh(geometry: lightMarkerGeom, material: lightMarkerMat)
    lightMarker.position.copy(dirLight.position)
    lightMarker.name = "LightMarker"
    lightMarker.castShadow = false
    lightMarker.receiveShadow = false
    scene.add(lightMarker)

    // ---- 地面平面（receiver） ----
    let planeGeom = PlaneGeometry(width: 12.0, height: 12.0)
    let planeMat = MeshPhongMaterial()
    planeMat.color = Color(0x888888)
    planeMat.specular = Color(0x000000)
    planeMat.side = 2  // DoubleSide
    let plane = Mesh(geometry: planeGeom, material: planeMat)
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
    boxMat.color = Color(0x44aaff)
    boxMat.specular = Color(0x444444)
    boxMat.shininess = 30.0
    let box = Mesh(geometry: boxGeom, material: boxMat)
    box.position.set(0.0, 2.0, 0.0)
    box.name = "FloatingCube"
    box.castShadow = true
    box.receiveShadow = false
    scene.add(box)
    println("  悬浮立方体创建成功")

    println("  场景子对象数: ${scene.children.size}")
    println("")

    return SceneObjects(scene: scene, camera: camera, cube: box, ambient: ambient, dirLight: dirLight)
}

/// 渲染循环逻辑（相机轨道控制 + 渲染）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）
