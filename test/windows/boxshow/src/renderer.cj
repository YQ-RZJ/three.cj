package boxshow

/**
 * boxshow 渲染场景：
 * - 一个朝向相机的开放盒子（去掉前面板，相机可以看到盒子内部）
 * - 盒子内部有几个不同颜色的球体在来回移动
 * - 几个不同颜色的点光源在盒子内部来回移动
 * - 一束方向光提供基础照明与阴影
 *
 * 体现：材质（MeshPhongMaterial 高光）、光照（点光源 + 方向光 + 环境光）、
 *       阴影（castShadow/receiveShadow）系统。
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
import three.rendering.BgfxRenderer
import three.window.MouseButton

/// 盒子内部尺寸（盒子内壁范围）
public let BOX_HALF: Float64 = 4.0
public let BOX_DEPTH: Float64 = 4.0

/// 球体与点光源动画数据
public class AnimState {
    public var phase: Float64
    public var speed: Float64
    public var axis: Int64   // 0=x, 1=y, 2=z
    public var amp: Float64
    public init(phase!: Float64 = 0.0, speed!: Float64 = 1.0, axis!: Int64 = 0, amp!: Float64 = 2.0) {
        this.phase = phase
        this.speed = speed
        this.axis = axis
        this.amp = amp
    }
}

/// 创建场景、相机、开放盒子、移动球、移动点光源、方向光
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>, ArrayList<PointLight>) {
    let scene = Scene()
    scene.name = "BoxShowScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：在盒子前方略高位置，朝向盒子内部
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 1.5, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（弱，让阴影区不至于全黑） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    ambient.name = "Ambient"
    scene.add(ambient)

    // ---- 方向光（提供方向性阴影） ----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(6.0, 10.0, 6.0)
    dirLight.castShadow = true
    dirLight.shadow.mapSize.set(2048.0, 2048.0)
    // 抗方向光阴影 acne（地板亮区波纹/指纹）：
    //   - normalBias：沿世界法线偏移 shadowWorldPosition（shadowmap_vertex.cj:47），棱线处连续不产生接缝
    //   - bias：沿投影深度方向偏移（shadowmap_pars_fragment.cj:108），过大导致盒子内壁棱线阴影错位
    //   原配置 bias/normalBias 均默认 0 → 无偏移 → 阴影贴图有限精度让自照亮表面产生交替亮暗条纹（acne）
    dirLight.shadow.normalBias = 0.02
    dirLight.shadow.bias = -0.0002
    // 正交相机视锥覆盖整个盒子
    match (dirLight.shadow.camera) {
        case oc: OrthographicCamera =>
            oc.left = -8.0; oc.right = 8.0
            oc.top = 8.0; oc.bottom = -8.0
            oc.near = 0.5; oc.far = 50.0
            oc.updateProjectionMatrix()
        case _ => ()
    }
    dirLight.name = "DirLight"
    scene.add(dirLight)

    // ---- 开放盒子（去掉前面板 +Z，让相机能看到内部） ----
    let boxGeom = createOpenBoxGeometry(BOX_HALF * 2.0, BOX_HALF * 2.0, BOX_DEPTH * 2.0)
    boxGeom.name = "OpenBox"
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0xdddddd)
    boxMat.specular = Color(0x333333)
    boxMat.shininess = 20.0
    boxMat.side = 2  // DoubleSide：内壁法线向内，双面渲染确保所有面可见
    let boxMesh = Mesh(geometry: boxGeom, material: boxMat)
    boxMesh.name = "OpenBox"
    boxMesh.castShadow = false
    boxMesh.receiveShadow = true
    // 盒子内壁朝向相机：默认盒子前面板在 +Z，去掉它即可
    boxMesh.position.set(0.0, 0.0, 0.0)
    scene.add(boxMesh)
    println("  开放盒子创建成功")

    // ---- 几个不同颜色的球体，在盒子内部来回移动 ----
    let spheres = ArrayList<Mesh>()
    let sphereConfigs = [
        (Color(0xff3030), 0.6, 0.0,  0.0,  0.0, 1.0, 0, 2.6),  // 红，X 轴来回
        (Color(0x30ff30), 0.5, 0.0,  0.0,  0.0, 1.3, 1, 2.0),  // 绿，Y 轴来回
        (Color(0x3060ff), 0.55,0.0,  0.0,  0.0, 0.9, 0, 2.2),  // 蓝，X 轴来回（不同相位/速度）
        (Color(0xffaa00), 0.5, 0.0,  0.0,  0.0, 1.6, 2, 1.8),  // 橙，Z 轴来回
    ]
    for ((col, r, px, py, pz, spd, ax, amp) in sphereConfigs) {
        let g = SphereGeometry(radius: r, widthSegments: 24, heightSegments: 16)
        let m = MeshPhongMaterial()
        m.color = col
        m.specular = Color(0xffffff)
        m.shininess = 80.0
        let sphere = Mesh(geometry: g, material: m)
        sphere.position.set(px, py, pz)
        sphere.name = "Sphere"
        sphere.castShadow = true
        sphere.receiveShadow = true
        // 用 userData 存动画状态（Object3D.userData 是 HashMap）
        sphere.userData.add("__anim", AnimState(phase: Float64(spheres.size) * 1.3, speed: spd, axis: ax, amp: amp))
        spheres.add(sphere)
        scene.add(sphere)
    }
    println("  球体创建成功: ${spheres.size} 个")

    // ---- 几个不同颜色的点光源，在盒子内部来回移动 ----
    let pointLights = ArrayList<PointLight>()
    let lightConfigs = [
        (Color(0xff2040), 5.0, 0.0, 1.0),  // 红
        (Color(0x40ff80), 5.0, 0.0, 1.0),  // 绿
        (Color(0x4080ff), 5.0, 0.0, 1.0),  // 蓝
        (Color(0xffee40), 4.0, 0.0, 1.0),  // 黄
    ]
    var li: Int64 = 0
    for ((col, intens, dist, dec) in lightConfigs) {
        let pl = PointLight(color: col, intensity: intens, distance: dist, decay: dec)
        pl.position.set(0.0, 0.0, 0.0)
        pl.castShadow = true
        pl.shadow.mapSize.set(512.0, 512.0)
        // shadow.camera 覆盖盒子范围（半宽 4 + 移动幅度）
        match (pl.shadow.camera as PerspectiveCamera) {
            case pc: PerspectiveCamera =>
                pc.near = 0.1
                pc.far = 12.0
                pc.updateProjectionMatrix()
            case _ => ()
        }
        // per-light bias（对齐 three.js：bias 是 light.shadow 属性，由场景设置）。
        // 本实现比较语义下点光源需负 bias 抗自阴影（acne），取 -0.01。
        pl.shadow.bias = -0.01
        pl.name = "PointLight"
        pl.userData.add("__anim", AnimState(phase: Float64(li) * 1.7, speed: 0.8 + Float64(li) * 0.15, axis: Int64(li % 3), amp: 2.4))
        pointLights.add(pl)
        scene.add(pl)
        li++
    }
    println("  点光源创建成功: ${pointLights.size} 个")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, spheres, pointLights)
}
