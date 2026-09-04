package halftone

/**
 * halftone 渲染场景（v2 生命周期模式）：
 * - 旋转多色立方体 + 多色球（部分 emissive > 1 模拟 HDR），围绕原点公转
 * - 地板（MeshPhongMaterial）+ 方向光 + 环境光 + 点光源
 * - EffectComposer 链：RenderPass → HalftonePass（shape/radius/blending 可调）→ OutputPass → 上屏
 * - 验证 HalftonePass RGB 半色调效果（旋转网点印刷风，5 种形状 × 5 种混合模式）
 *
 * 按键交互（中间步骤独立呈现，详见 printHelp）：
 *   - 1: 完整 halftone 流程（默认参数：shape=1/Dot radius=4 blending=1）
 *   - 2: Square 形状网点模式（shape=4，方形网点）
 *   - 3: Diamond 形状网点模式（shape=5，菱形网点）
 *   - 4: 跳过 HalftonePass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓: 调整 radius（网点半径）
 *   - ←/→: 调整 blending（混合强度）
 *   - S: 切换 shape（Dot/Ellipse/Line/Square/Diamond 循环）
 *   - G: 切换 greyscale（灰度/彩色）
 *   - D: 切换 disable（禁用透传）
 *   - 空格: 暂停/恢复立方体旋转
 *   - R: 重置参数到默认值
 *   - H: 打印帮助
 *
 * 说明：渲染循环与按键交互已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
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

/// HalftonePass 默认参数（R 键重置时回到此值）
public let DEFAULT_SHAPE: Int64 = 1         // Dot
public let DEFAULT_RADIUS: Float64 = 4.0
public let DEFAULT_ROTATE_R: Float64 = 3.141592653589793 / 12.0
public let DEFAULT_ROTATE_G: Float64 = 3.141592653589793 / 12.0 * 2.0
public let DEFAULT_ROTATE_B: Float64 = 3.141592653589793 / 12.0 * 3.0
public let DEFAULT_SCATTER: Float64 = 0.0

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_SQUARE: Int64 = 2
public let MODE_DIAMOND: Int64 = 3
public let MODE_BYPASS: Int64 = 4

public var g_debugMode: Int64 = 1     // 默认 MODE_FULL
public var g_shape: Int64 = 1         // 网点形状（1=Dot 2=Ellipse 3=Line 4=Square 5=Diamond）
public var g_radius: Float64 = 4.0     // 网点半径
public var g_blending: Float64 = 1.0   // 混合强度
public var g_greyscale: Bool = false   // 灰度
public var g_disable: Bool = false     // 禁用透传
public var g_pauseRotation: Bool = false
public var g_resetHalftone: Bool = false  // R 键触发重置

public func printHelp(): Unit {
    println("  === Halftone 测试按键帮助 ===")
    println("  1: 完整 halftone 流程（默认参数：shape=1/Dot radius=4 blending=1）")
    println("  2: Square 形状网点模式（shape=4，方形网点）")
    println("  3: Diamond 形状网点模式（shape=5，菱形网点）")
    println("  4: 跳过 HalftonePass（pass.enabled=false），纯 RenderPass 直出")
    println("  ↑/↓: 调整 radius（网点半径，↑ 增大，↓ 减小）")
    println("  ←/→: 调整 blending（混合强度，← 减弱，→ 增强）")
    println("  S: 切换 shape（Dot/Ellipse/Line/Square/Diamond 循环）")
    println("  G: 切换 greyscale（灰度/彩色）")
    println("  D: 切换 disable（禁用透传）")
    println("  空格: 暂停/恢复立方体旋转（静态场景下观察网点）")
    println("  R: 重置参数到默认值（shape=1 radius=4 blending=1）")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整公转角度；滚轮: 缩放")
    println("  ==============================")
}
public let DEFAULT_BLENDING: Float64 = 1.0
public let DEFAULT_BLENDING_MODE: Int64 = 1   // Linear

/// 创建场景：相机 + 灯光 + 地板 + 旋转立方体 + 多色球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "HalftoneScene"
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

    // 多色立方体（围绕原点公转 + 自转，产生动态画面便于观察网点）
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

    // 多色球（部分 emissive > 1 模拟 HDR，网点在亮区对比更明显）
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
