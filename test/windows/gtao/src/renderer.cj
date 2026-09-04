package sp_gtao

/**
 * sp_gtao 渲染场景（对齐 three.js 官方案例 webgl_postprocessing_gtao.html 的尺度与参数，v2 生命周期模式）：
 * - 场景：自建"小街区"（地面 + 建筑 + 球体），细节尺度 0.25~3 单位
 *   （官方用 LittlestTokyo.glb scale 0.01，模型细节 ~1 单位；Three.cj 的 GltfLoader
 *   对该 4MB/71mesh/618accessor 模型解析过慢且不重建节点层级，故以自建几何体复刻尺度）
 * - 相机：PerspectiveCamera(40, aspect, near=1, far=100)，position (5,2,8)，target (0,0.5,0)
 * - 灯光：环境光 + 方向光（官方案例用 RoomEnvironment 环境贴图，Three.cj 暂无，以灯光替代）
 * - GTAO 参数完全对齐官方案例 aoParameters/pdParameters：
 *   radius=0.25, distanceExponent=1, thickness=1, distanceFallOff=1, scale=1
 *   lumaPhi=10, depthPhi=2, normalPhi=3, radius=4（pd）, blendIntensity=1
 *
 * 说明：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
 */

import std.sync.*
import std.time.*
import std.math.*
import std.fs.*
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
import three.resource.loader.GltfLoader

/// 轨道控制目标（对齐官方 OrbitControls.target）
public let ORBIT_TARGET: Vector3 = Vector3(0.0, 0.5, 0.0)

// ===== 输出模式诊断状态（原 win32.cj 按键切换，迁移至 WindowEngine 输入） =====
public var g_outputMode: Int64 = 0   // BgfxGTAOPass.OUTPUT_DEFAULT
public var g_outputDirty = AtomicBool(false)

/// 创建场景、相机、灯光与"小街区"几何体
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Group) {
    let scene = Scene()
    scene.name = "GTAOScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：对齐官方 PerspectiveCamera(40, aspect, 1, 100)，position (5,2,8)
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 40.0, aspect: aspect, near: 1.0, far: 100.0)
    camera.position.set(5.0, 6.0, 8.0)
    camera.lookAt(ORBIT_TARGET)
    camera.name = "MainCamera"
    println("  相机创建成功: fov=40 near=1 far=100 pos=(5,2,8)")

    // 灯光（替代 RoomEnvironment 环境贴图：环境光 + 方向光）
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
    ambient.name = "Ambient"
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
    dirLight.position.set(5.0, 10.0, 7.0)
    dirLight.name = "DirLight"
    scene.add(dirLight)
    println("  灯光创建成功: ambient + directional")

    // 自建"小街区"（细节尺度 0.25~3 单位，radius=0.25 相对合适）
    let group = Group()
    group.name = "MiniCity"

    // 地面（大平面，GTAO 在建筑/球体与地面接触处产生遮蔽）
    let groundMat = MeshPhongMaterial()
    groundMat.color = Color(0xcccccc)
    groundMat.side = 2
    let ground = Mesh(geometry: BoxGeometry(width: 12.0, height: 0.2, depth: 12.0), material: groundMat)
    ground.position.set(0.0, -0.1, 0.0)
    group.add(ground)

    // 建筑 1（高楼）
    let b1Mat = MeshPhongMaterial()
    b1Mat.color = Color(0x8899bb)
    let b1 = Mesh(geometry: BoxGeometry(width: 1.2, height: 2.5, depth: 1.2), material: b1Mat)
    b1.position.set(-2.0, 1.25, 0.0)
    group.add(b1)

    // 建筑 2（矮楼）
    let b2Mat = MeshPhongMaterial()
    b2Mat.color = Color(0xbb9988)
    let b2 = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.8, depth: 1.0), material: b2Mat)
    b2.position.set(0.5, 0.9, -1.0)
    group.add(b2)

    // 建筑 3（宽楼）
    let b3Mat = MeshPhongMaterial()
    b3Mat.color = Color(0x88bb99)
    let b3 = Mesh(geometry: BoxGeometry(width: 1.5, height: 1.2, depth: 1.5), material: b3Mat)
    b3.position.set(2.0, 0.6, 1.0)
    group.add(b3)

    // 球体 1（与地面接触，产生 AO）
    let s1Mat = MeshPhongMaterial()
    s1Mat.color = Color(0xcc5555)
    let s1 = Mesh(geometry: SphereGeometry(radius: 0.6, widthSegments: 24, heightSegments: 16), material: s1Mat)
    s1.position.set(-0.5, 0.6, 1.5)
    group.add(s1)

    // 球体 2（与建筑 1 相邻）
    let s2Mat = MeshPhongMaterial()
    s2Mat.color = Color(0x55cc88)
    let s2 = Mesh(geometry: SphereGeometry(radius: 0.4, widthSegments: 24, heightSegments: 16), material: s2Mat)
    s2.position.set(-1.2, 0.4, 0.8)
    group.add(s2)

    // 小立方体（散落在地面，缝隙产生 AO）
    let c1Mat = MeshPhongMaterial()
    c1Mat.color = Color(0xbbaa44)
    let c1 = Mesh(geometry: BoxGeometry(width: 0.5, height: 0.5, depth: 0.5), material: c1Mat)
    c1.position.set(0.0, 0.25, 2.0)
    group.add(c1)

    scene.add(group)
    println("  小街区创建成功: ground + 3 建筑 + 2 球 + 1 立方体")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, group)
}
