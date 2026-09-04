package volumecloud

/**
 * volumecloud 渲染场景：
 * - 地面（MeshPhongMaterial）+ 多色方块（MeshBasic/Phong），作为体积云叠加的参照物
 * - 方向光 + 环境光
 * - EffectComposer 链：RenderPass → VolumeCloudPass（全屏 ray marching 体积云）→ OutputPass → 上屏
 * - 验证 VolumeCloudPass 体积云效果（3D Simplex 噪声 + wang_hash 抖动 + smoothstep 密度 + 差分着色）
 *
 * 对照 three.js: examples/webgl_volume_cloud.html（相机绕原点轨道旋转观察云盒）
 *
 * 按键交互（详见 win32.cj printHelp）：
 *   - 1: 完整体积云流程（默认参数：threshold=0.25 opacity=0.25 range=0.1 steps=100）
 *   - 2: 更浓密的云（opacity=0.5）
 *   - 3: 更高步数精细云（steps=200）
 *   - 4: 跳过 VolumeCloudPass（pass.enabled=false），纯 RenderPass 直出
 *   - ←/→: 调整 threshold；↑/↓: 调整 opacity
 *   - 空格: 暂停/恢复相机轨道旋转
 *   - H: 打印帮助
 */

import std.sync.*
import std.collection.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.lights.*

/// VolumeCloudPass 默认参数（R 键重置时回到此值）
public let DEFAULT_THRESHOLD: Float64 = 0.25
public let DEFAULT_OPACITY: Float64 = 0.25
public let DEFAULT_RANGE: Float64 = 0.1
public let DEFAULT_STEPS: Float64 = 100.0

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_DENSE: Int64 = 2
public let MODE_FINE: Int64 = 3
public let MODE_BYPASS: Int64 = 4

public var g_debugMode: Int64 = 1  // 默认 MODE_FULL
public var g_threshold: Float64 = 0.25  // 密度阈值（默认 0.25，对照 JS 示例）
public var g_opacity: Float64 = 0.25    // 不透明度（默认 0.25，对照 JS 示例）
public var g_steps: Float64 = 100.0     // ray marching 步数（默认 100，对照 JS 示例）
public var g_pauseRotation: Bool = false
public var g_resetParams: Bool = false  // R 键触发重置

public func printHelp(): Unit {
    println("  === 体积云测试按键帮助 ===")
    println("  1: 完整体积云流程（默认参数：threshold=0.25 opacity=0.25 range=0.1 steps=100）")
    println("  2: 更浓密的云（opacity=0.5）")
    println("  3: 更高步数精细云（steps=200）")
    println("  4: 跳过 VolumeCloudPass（pass.enabled=false），纯 RenderPass 直出")
    println("  ↑/↓: 调整 opacity（不透明度）")
    println("  ←/→: 调整 threshold（密度阈值）")
    println("  空格: 暂停/恢复相机轨道旋转（静态观察云）")
    println("  R: 重置参数到默认值")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整相机轨道角度；滚轮: 缩放")
    println("  ==============================")
}

/// 创建场景：相机 + 灯光 + 地面 + 多色方块（体积云参照物）
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "VolumeCloudScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 0.0, 8.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: fov=60 near=0.1 far=100 pos=(0,0,8)")

    // 灯光：环境光 + 方向光
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.4)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)
    println("  灯光创建成功: ambient + directional")

    // 地面（体积云参照物：云盒底部与地面高度一致）
    let floor = BoxGeometry(width: 12.0, height: 0.2, depth: 12.0)
    let floorMat = MeshPhongMaterial()
    floorMat.color = Color(0x40, 0x55, 0x70)
    let floorMesh = Mesh(geometry: floor, material: floorMat)
    floorMesh.position.set(0.0, -2.0, 0.0)
    scene.add(floorMesh)

    // 多色方块（体积云穿过参照物，观察遮挡/混合）
    let meshes = ArrayList<Mesh>()
    let boxConfigs = [
        (Color(0xff, 0x40, 0x40), -2.0, 0.0, -1.0, MeshBasicMaterial()),
        (Color(0x40, 0xff, 0x40),  0.0, 0.0,  0.0, MeshPhongMaterial()),
        (Color(0x40, 0x80, 0xff),  2.0, 0.0,  1.0, MeshBasicMaterial()),
    ]
    for ((col, x, y, z, _) in boxConfigs) {
        let g = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let m = MeshBasicMaterial()
        m.color = col
        let box = Mesh(geometry: g, material: m)
        box.position.set(x, y, z)
        meshes.add(box)
        scene.add(box)
    }

    println("  方块创建成功: ${meshes.size} 个")
    println("")

    return (scene, camera, meshes)
}

