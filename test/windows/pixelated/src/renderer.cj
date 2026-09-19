package pixelated

/**
 * pixelated 渲染场景：
 * - 彩色立方体 + 球（不同深度/朝向，制造深度与法线边缘，便于观察像素化边缘检测）
 * - 地板（MeshPhongMaterial）+ 方向光 + 环境光 + 点光源
 * - EffectComposer 链：RenderPixelatedPass（pixelSize/边缘强度可调）→ OutputPass → 上屏
 * - 验证 RenderPixelatedPass 像素化风格（低分辨率渲染 + 深度/法线边缘检测）
 *
 * 按键交互（中间步骤独立呈现，详见 win32.cj printHelp）：
 *   - 1: 完整像素化流程（默认参数：pixelSize=6 normalEdge=0.3 depthEdge=0.4）
 *   - 2: 大像素块模式（pixelSize=16，更粗的马赛克）
 *   - 3: 精细像素模式（pixelSize=2，接近原分辨率）
 *   - 4: 跳过 RenderPixelatedPass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓: 调整 pixelSize（像素尺寸）
 *   - ←/→: 调整 normalEdgeStrength（法线边缘强度）
 *   - W/S: 调整 depthEdgeStrength（深度边缘强度）
 *   - 空格: 暂停/恢复立方体旋转
 *   - R: 重置参数到默认值
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
import three.rendering.postprocessing.RenderPixelatedPass
import three.rendering.postprocessing.OutputPass
import three.rendering.postprocessing.FullScreenQuad
import three.utils.constants.*
import three.utils.log.*
import three.utils.log.macros.*

/// RenderPixelatedPass 默认参数（R 键重置时回到此值）
public let DEFAULT_PIXEL_SIZE: Int64 = 6
public let DEFAULT_NORMAL_EDGE: Float64 = 0.3
public let DEFAULT_DEPTH_EDGE: Float64 = 0.4

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_COARSE: Int64 = 2
public let MODE_FINE: Int64 = 3
public let MODE_BYPASS: Int64 = 4

public var g_debugMode: Int64 = 1          // 默认 MODE_FULL
public var g_pixelSize: Int64 = 6          // 像素尺寸
public var g_normalEdge: Float64 = 0.3     // 法线边缘强度
public var g_depthEdge: Float64 = 0.4      // 深度边缘强度
public var g_pauseRotation: Bool = false
public var g_resetPixelated: Bool = false  // R 键触发重置

public func printHelp(): Unit {
    println("  === RenderPixelatedPass 测试按键帮助 ===")
    println("  1: 完整像素化流程（默认参数：pixelSize=6 normalEdge=0.3 depthEdge=0.4）")
    println("  2: 大像素块模式（pixelSize=16，更粗的马赛克）")
    println("  3: 精细像素模式（pixelSize=2，接近原分辨率）")
    println("  4: 跳过 RenderPixelatedPass（pass.enabled=false），纯 RenderPass 直出")
    println("  ↑/↓: 调整 pixelSize（像素尺寸，↑ 增大马赛克更粗，↓ 减小更精细）")
    println("  ←/→: 调整 normalEdgeStrength（法线边缘强度，← 减弱 → 增强）")
    println("  W/S: 调整 depthEdgeStrength（深度边缘强度，W 增强 S 减弱）")
    println("  空格: 暂停/恢复立方体旋转（静态场景下观察像素化）")
    println("  R: 重置参数到默认值（pixelSize=6 normalEdge=0.3 depthEdge=0.4）")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整公转角度；滚轮: 缩放")
    println("  ==============================")
}

/// 创建场景：相机 + 灯光 + 地板 + 彩色立方体/球（含 HDR 高光）
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "PixelatedScene"
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

    // 彩色立方体（RGB 三原色 + 黄，深度错落制造深度边缘）
    let cubes = ArrayList<Mesh>()
    let cubeConfigs = [
        (Color(0xff, 0x40, 0x40), -3.0, 0.0, 0.0),   // 红立方体
        (Color(0x40, 0xff, 0x40),  0.0, 0.0, 0.0),   // 绿立方体
        (Color(0x40, 0x40, 0xff),  3.0, 0.0, 0.0),   // 蓝立方体
        (Color(0xff, 0xff, 0x40),  0.0, 1.0, 2.0),   // 黄立方体（前凸，深度边缘明显）
    ]
    for ((col, x, y, z) in cubeConfigs) {
        let g = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let m = MeshPhongMaterial()
        m.color = col
        let cube = Mesh(geometry: g, material: m)
        cube.position.set(x, y, z)
        cubes.add(cube)
        scene.add(cube)
    }

    // 渐变球（含 HDR 高光，法线边缘检测的观察点）
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

    println("  立方体 + 球体创建成功: ${cubes.size} 个（深度/法线边缘丰富的场景）")
    println("")

    return (scene, camera, cubes)
}

/// 渲染循环逻辑（键盘交互 + 轨道控制 + 立方体自转）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）

/// 将数值限定在 [min, max] 区间
func clamp(value: Float64, min: Float64, max: Float64): Float64 {
    if (value < min) { return min }
    if (value > max) { return max }
    return value
}
