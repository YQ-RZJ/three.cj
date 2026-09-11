package bokeh_pass

/**
 * bokeh_pass 渲染场景：
 * - 前后错落的彩色立方体 + 球（不同深度，制造景深差异便于观察散景）
 * - 地板（MeshPhongMaterial）+ 方向光 + 环境光 + 点光源
 * - EffectComposer 链：RenderPass → BokehPass（focus/aperture/maxblur 可调）→ OutputPass → 上屏
 * - 验证 BokehPass 景深散景效果（41 抽头 lens blur）
 *
 * 按键交互（中间步骤独立呈现，详见 main.cj printHelp）：
 *   - 1: 完整 bokeh 流程（默认参数：focus=6 aperture=0.05 maxblur=1.0）
 *   - 2: 深度图可视化（debugMode=1，深度 RT 伪彩显示）
 *   - 3: 原图直出（debugMode=2，跳过 41 抽头模糊，验证 tColor 绑定）
 *   - 4: 跳过 BokehPass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓: 调整 focus（焦点距离）
 *   - ←/→: 调整 aperture（光圈）
 *   - W/S: 调整 maxblur（最大模糊量）
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
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.BokehPass
import three.rendering.postprocessing.OutputPass
import three.rendering.postprocessing.FullScreenQuad
import three.utils.constants.*
import three.utils.log.Logger

/// BokehPass 默认参数（R 键重置时回到此值）
public let DEFAULT_FOCUS: Float64 = 6.0     // 焦点距离（世界单位）
public let DEFAULT_APERTURE: Float64 = 0.05 // 光圈（景深）
public let DEFAULT_MAXBLUR: Float64 = 1.0   // 最大模糊量

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_DEPTH: Int64 = 2
public let MODE_PASSTHROUGH: Int64 = 3
public let MODE_BYPASS: Int64 = 4

public var g_debugMode: Int64 = 1     // 默认 MODE_FULL
public var g_focus: Float64 = 6.0     // 焦点距离（世界单位）
public var g_aperture: Float64 = 0.05 // 光圈
public var g_maxblur: Float64 = 1.0   // 最大模糊量
public var g_pauseRotation: Bool = false
public var g_resetBokeh: Bool = false  // R 键触发重置

public func printHelp(): Unit {
    println("  === BokehPass 测试按键帮助 ===")
    println("  1: 完整 bokeh 流程（默认参数：focus=6 aperture=0.05 maxblur=1.0）")
    println("  2: 深度图可视化（debugMode=1，深度 RT 伪彩显示）")
    println("  3: 原图直出（debugMode=2，跳过 41 抽头模糊，验证 tColor 绑定）")
    println("  4: 跳过 BokehPass（pass.enabled=false），纯 RenderPass 直出")
    println("  ↑/↓: 调整 focus（焦点距离，↑ 增大，↓ 减小）")
    println("  ←/→: 调整 aperture（光圈，← 减小景深变深，→ 增大散景变强）")
    println("  W/S: 调整 maxblur（最大模糊量，W 增大散景半径，S 减小）")
    println("  空格: 暂停/恢复立方体旋转（静态场景下观察景深）")
    println("  R: 重置参数到默认值（focus=6 aperture=0.05 maxblur=1.0）")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整公转角度；滚轮: 缩放")
    println("  ==============================")
}

/// 创建场景：相机 + 灯光 + 地板 + 前后错落的彩色立方体/球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "BokehScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 3.0, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: fov=50 near=0.1 far=100 pos=(0,3,12)")

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
    let floor = BoxGeometry(width: 16.0, height: 0.2, depth: 16.0)
    let floorMat = MeshPhongMaterial()
    floorMat.color = Color(0x50, 0x50, 0x60)
    let floorMesh = Mesh(geometry: floor, material: floorMat)
    floorMesh.position.set(0.0, -1.5, 0.0)
    scene.add(floorMesh)

    // 前后错落的彩色立方体（Z 分布在 -4..+6，制造显著景深差异便于观察散景）
    let cubes = ArrayList<Mesh>()
    let cubeConfigs = [
        (Color(0xff, 0x40, 0x40), -4.0, 0.0, 6.0, 1.0),   // 红立方体（近相机，focus 之外 → 前景散景）
        (Color(0x40, 0xff, 0x40), -2.0, 0.0, 2.0, 1.0),   // 绿立方体（中景）
        (Color(0x40, 0x40, 0xff),  0.0, 0.0, -2.0, 1.0),  // 蓝立方体（焦点附近）
        (Color(0xff, 0xff, 0x40),  2.0, 0.0, -6.0, 1.0),  // 黄立方体（远，focus 之外 → 背景散景）
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

    // 多色球（部分 emissive > 1 模拟 HDR，散景在高亮处更明显）
    let sphereConfigs = [
        (Color(0xff, 0xff, 0x40), -1.0, 1.5, 0.0, 3.0),   // HDR 黄球（焦点附近，锐利）
        (Color(0xff, 0x80, 0x40),  1.0, 1.5, -4.0, 2.5),  // HDR 橙球（中远，背景散景）
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

    println("  立方体 + 球体创建成功: ${cubes.size} 个（含 HDR emissive 球，前后错落制造景深）")
    println("")

    return (scene, camera, cubes)
}

/// 将数值限定在 [min, max] 区间
func clamp(value: Float64, min: Float64, max: Float64): Float64 {
    if (value < min) { return min }
    if (value > max) { return max }
    return value
}
