package afterimage

/**
 * afterimage 渲染场景：
 * - 旋转立方体 + 多色球（部分 emissive > 1 模拟 HDR），围绕原点公转
 * - 地板（MeshPhongMaterial）+ 方向光 + 环境光 + 点光源
 * - EffectComposer 链：RenderPass → AfterimagePass（damp 可调）→ OutputPass → 上屏
 * - 验证 AfterimagePass 残影拖尾效果（damp 越大拖尾越长）
 *
 * 按键交互（中间步骤独立呈现，详见 win32.cj printHelp）：
 *   - 1: 完整 afterimage 流程（comp + copy），残影拖尾
 *   - 2: 仅 comp pass（残影融合），跳过 copy，观察融合中间结果
 *   - 3: 仅 copy pass（无残影），对照无 afterimage 的原始渲染
 *   - 4: 跳过 AfterimagePass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓: 调整 damp（↑ 增大残影，↓ 减小残影）
 *   - 空格: 暂停/恢复立方体旋转（静态场景下观察残影衰减）
 *   - R: 重置 afterimage pass（清空 old RT）
 *   - H: 打印帮助
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
import three.window.KeyCode
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.AfterimagePass
import three.rendering.postprocessing.OutputPass
import three.rendering.postprocessing.FullScreenQuad
import three.utils.constants.*
import three.utils.log.*
import three.utils.log.macros.*

/// 创建场景：相机 + 灯光 + 地板 + 旋转立方体 + 多色球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "AfterimageScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 3.0, 10.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: fov=50 near=0.1 far=100 pos=(0,3,10)")

    // 灯光：环境光 + 方向光 + 点光
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)
    let pointLight = PointLight(color: Color(0xffaa44), intensity: 0.6, distance: 20.0)
    pointLight.position.set(-3.0, 4.0, 3.0)
    scene.add(pointLight)
    println("  灯光创建成功: ambient + directional + point")

    // 地板
    let floor = BoxGeometry(width: 12.0, height: 0.2, depth: 12.0)
    let floorMat = MeshPhongMaterial()
    floorMat.color = Color(0x60, 0x60, 0x70)
    let floorMesh = Mesh(geometry: floor, material: floorMat)
    floorMesh.position.set(0.0, -1.5, 0.0)
    scene.add(floorMesh)

    // 多色立方体（围绕原点公转 + 自转，产生残影拖尾）
    let cubes = ArrayList<Mesh>()
    let cubeConfigs = [
        (Color(0xff, 0x40, 0x40), -3.0, 0.0, 0.0, 1.0),   // 红立方体（LDR）
        (Color(0x40, 0xff, 0x40),  0.0, 0.0, 0.0, 1.0),   // 绿立方体（LDR）
        (Color(0x40, 0x40, 0xff),  3.0, 0.0, 0.0, 1.0),   // 蓝立方体（LDR）
    ]
    for ((col, x, y, z, _) in cubeConfigs) {
        let g = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let m = MeshPhongMaterial()
        m.color = col
        let cube = Mesh(geometry: g, material: m)
        cube.position.set(x, y, z)
        cubes.add(cube)
        scene.add(cube)
    }

    // 多色球（部分 emissive > 1 模拟 HDR，afterimage 拖尾更明显）
    let sphereConfigs = [
        (Color(0xff, 0xff, 0x40), -2.0, 1.5, 2.0, 3.0),   // HDR 黄球
        (Color(0xff, 0x80, 0x40),  2.0, 1.5, -2.0, 2.5),  // HDR 橙球
    ]
    for ((col, x, y, z, intensity) in sphereConfigs) {
        let g = SphereGeometry(radius: 0.6, widthSegments: 24, heightSegments: 16)
        let m = MeshBasicMaterial()
        m.color = Color(col.r * intensity, col.g * intensity, col.b * intensity)
        let sphere = Mesh(geometry: g, material: m)
        sphere.position.set(x, y, z)
        cubes.add(sphere)
        scene.add(sphere)
    }

    println("  立方体 + 球体创建成功: ${cubes.size} 个（含 HDR emissive 球）")
    println("")

    return (scene, camera, cubes)
}

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_COMP_ONLY: Int64 = 2
public let MODE_COPY_ONLY: Int64 = 3
public let MODE_BYPASS: Int64 = 4

public var g_debugMode: Int64 = 1  // 默认 MODE_FULL
public var g_damp: Float64 = 0.96
public var g_pauseRotation: Bool = false
public var g_resetAfterimage: Bool = false  // R 键触发重置

public func printHelp(): Unit {
    println("  === Afterimage 测试按键帮助 ===")
    println("  1: 完整 afterimage 流程（comp + copy），残影拖尾")
    println("  2: 仅 comp pass（残影融合），观察融合中间结果")
    println("  3: 仅 copy pass（无残影），对照无 afterimage 的原始渲染")
    println("  4: 跳过 AfterimagePass（pass.enabled=false），纯 RenderPass 直出")
    println("  ↑/↓: 调整 damp（↑ 增大残影，↓ 减小残影）")
    println("  空格: 暂停/恢复立方体旋转（静态场景下观察残影衰减）")
    println("  R: 重置 afterimage pass（清空 old RT）")
    println("  H: 打印此帮助")
    println("  鼠标左键拖动: 调整公转角度；滚轮: 缩放")
    println("  ==============================")
}
