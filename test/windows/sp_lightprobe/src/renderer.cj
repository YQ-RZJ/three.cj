package sp_lightprobe

/**
 * sp_lightprobe 渲染场景：
 * - 一个光照探针（LightProbe）：手动构造 SH3 系数，
 *   模拟"环境光（band 0）+ 顶部方向光（band 1 Y 轴）"的球谐辐照度场
 * - 一个方向光（DirectionalLight，castShadow=true）：产生遮挡阴影效果
 * - 悬浮立方体（caster）+ 地面平面（receiver）+ 球体（验证各朝向辐照度差异）
 *
 * SH3 系数构造说明（对照 Three.js SphericalHarmonics3 的辐照度公式）：
 *   getShIrradianceAt(N) = c0 * 0.886227                       (band 0，均匀环境)
 *                        + c1 * (2 * 0.511664) * N.y            (band 1，Y 轴方向光)
 *                        + c2 * (2 * 0.511664) * N.z
 *                        + c3 * (2 * 0.511664) * N.x
 *                        + ... (band 2，此处置 0)
 * 故构造：
 *   c0 = ambientColor / 0.886227            → 环境辐照度 ≈ ambientColor
 *   c1 = (0, dirColor / (2 * 0.511664), 0)  → 顶部辐照度增量 ≈ dirColor（朝下为负）
 * 本测试把 intensity 直接烘焙进系数（BgfxLightBinder 原样传递系数，不额外乘 intensity）。
 *
 * 注意：LightProbe 消费位于 standard（PBR）着色器的 getShIrradianceAt，
 * 故场景物体使用 MeshStandardMaterial 才能看到探针效果。
 * 注：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
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
    public var probe: LightProbe
    public var dirLight: DirectionalLight

    public init(scene!: Scene, camera!: PerspectiveCamera, cube!: Mesh, probe!: LightProbe, dirLight!: DirectionalLight) {
        this.scene = scene
        this.camera = camera
        this.cube = cube
        this.probe = probe
        this.dirLight = dirLight
    }
}

/// 构造 SH3 系数：band0 环境 + band1 Y 轴方向光
public func buildProbeSH(): SphericalHarmonics3 {
    let sh = SphericalHarmonics3()
    // band 0：均匀环境光（白色 × 0.35）
    // 公式：irradiance += c0 * 0.886227 → c0 = color / 0.886227
    sh.coefficients[0].set(0.35 / 0.886227, 0.35 / 0.886227, 0.38 / 0.886227)
    // band 1 Y 轴：顶部方向光（暖白 × 0.5，法线朝 +Y 的顶部面更亮）
    // 公式：irradiance += c1 * (2 * 0.511664) * N.y → c1 = color / (2 * 0.511664)
    sh.coefficients[1].set(0.0, 0.5 / (2.0 * 0.511664), 0.0)
    // band 1 Z/X 与 band 2 保持 0（无水平方向光/高阶细节）
    return sh
}

/// 创建场景：地面平面+悬浮立方体+球体+光照探针+方向光（阴影）
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "LightProbeScene"
    println("  场景创建成功: ${scene.name}")

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 45.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(8.0, 6.0, 8.0)
    camera.lookAt(Vector3(0.0, 1.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 光照探针（被测光源：SH3 球谐辐照度）----
    let sh = buildProbeSH()
    let probe = LightProbe(sh: sh, intensity: 1.0)
    probe.name = "LightProbe"
    scene.add(probe)
    println("  光照探针创建成功（band0 环境 + band1 顶部方向光）")

    // ---- 方向光（产生遮挡阴影效果的辅助光源）----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.7)
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
    let lightMarkerMat = MeshStandardMaterial()
    lightMarkerMat.color = Color(0xffff00)   // 黄色小球标记方向光位置
    lightMarkerMat.roughness = 0.5
    lightMarkerMat.metalness = 0.0
    let lightMarker = Mesh(geometry: lightMarkerGeom, material: lightMarkerMat)
    lightMarker.position.copy(dirLight.position)
    lightMarker.name = "LightMarker"
    lightMarker.castShadow = false
    lightMarker.receiveShadow = false
    scene.add(lightMarker)

    // ---- 地面平面（receiver，MeshStandardMaterial 以消费探针辐照度）----
    let planeGeom = PlaneGeometry(width: 12.0, height: 12.0)
    let planeMat = MeshStandardMaterial()
    planeMat.color = Color(0x888888)
    planeMat.roughness = 0.8
    planeMat.metalness = 0.0
    planeMat.side = 2  // DoubleSide
    let plane = Mesh(geometry: planeGeom, material: planeMat)
    plane.rotation.x = -PI / 2.0
    plane.position.set(0.0, 0.0, 0.0)
    plane.name = "GroundPlane"
    plane.castShadow = false
    plane.receiveShadow = true
    scene.add(plane)
    println("  地面平面创建成功")

    // ---- 悬浮立方体（caster，MeshStandardMaterial）----
    let boxGeom = BoxGeometry(width: 1.5, height: 1.5, depth: 1.5)
    let boxMat = MeshStandardMaterial()
    boxMat.color = Color(0x44aaff)
    boxMat.roughness = 0.4
    boxMat.metalness = 0.0
    let box = Mesh(geometry: boxGeom, material: boxMat)
    box.position.set(-1.5, 2.0, 0.0)
    box.name = "FloatingCube"
    box.castShadow = true
    box.receiveShadow = false
    scene.add(box)
    println("  悬浮立方体创建成功")

    // ---- 球体（验证 SH 辐照度各朝向渐变）----
    let sphereGeom = SphereGeometry(radius: 1.0, widthSegments: 32, heightSegments: 16)
    let sphereMat = MeshStandardMaterial()
    sphereMat.color = Color(0x88ccff)
    sphereMat.roughness = 0.5
    sphereMat.metalness = 0.0
    let sphere = Mesh(geometry: sphereGeom, material: sphereMat)
    sphere.position.set(2.0, 1.2, 0.0)
    sphere.name = "ProbeSphere"
    sphere.castShadow = true
    sphere.receiveShadow = false
    scene.add(sphere)
    println("  探针球体创建成功")

    println("  场景子对象数: ${scene.children.size}")
    println("")

    return SceneObjects(scene: scene, camera: camera, cube: box, probe: probe, dirLight: dirLight)
}
