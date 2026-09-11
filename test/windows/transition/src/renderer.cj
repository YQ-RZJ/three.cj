package transition

/**
 * transition 渲染场景：
 * - 场景A：红色系立方体 + 暖色球（过渡起点）
 * - 场景B：蓝色系立方体 + 冷色球（过渡终点）
 * - 程序生成过渡纹理（水平渐变灰度图，r 通道做阈值过渡）
 * - EffectComposer 链：RenderTransitionPass（mixRatio/threshold 可调）→ OutputPass → 上屏
 * - 验证 RenderTransitionPass 场景过渡效果（纹理过渡 + 纯比例混合）
 *
 * 按键交互（中间步骤独立呈现，详见 win32.cj printHelp）：
 *   - 1: 自动过渡循环（mixRatio 0→1→0 自动往复）
 *   - 2: 静态场景A（mixRatio=0，全场景A）
 *   - 3: 半过渡（mixRatio=0.5，A/B 各半）
 *   - 4: 静态场景B（mixRatio=1，全场景B）
 *   - ↑/↓: 手动调整 mixRatio（过渡比例）
 *   - ←/→: 调整 threshold（过渡纹理阈值）
 *   - T: 切换 useTexture（纹理过渡 / 纯比例混合）
 *   - 空格: 暂停/恢复自动过渡循环
 *   - R: 重置参数到默认值
 *   - H: 打印帮助
 * 注：渲染循环与按键交互已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
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
import three.rendering.types.*
import three.rendering.bgfx.BgfxConstants
import three.utils.memory.BgfxMemory
import three.utils.log.*
import three.rendering.*

/// RenderTransitionPass 默认参数（R 键重置时回到此值）
public let DEFAULT_MIX_RATIO: Float64 = 0.0
public let DEFAULT_THRESHOLD: Float64 = 0.1
public let DEFAULT_USE_TEXTURE: Bool = true

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_AUTO: Int64 = 1
public let MODE_SCENE_A: Int64 = 2
public let MODE_HALF: Int64 = 3
public let MODE_SCENE_B: Int64 = 4

public var g_debugMode: Int64 = 1          // 默认 MODE_AUTO
public var g_mixRatio: Float64 = 0.0       // 过渡比例
public var g_threshold: Float64 = 0.1      // 过渡纹理阈值
public var g_useTexture: Bool = true       // 纹理过渡
public var g_autoDirection: Int64 = 1      // 自动循环方向（1=0→1, -1=1→0）
public var g_pauseRotation: Bool = false   // 暂停自动循环
public var g_resetTransition: Bool = false // R 键触发重置

public func printHelp(): Unit {
    println("  === RenderTransitionPass 测试按键帮助 ===")
    println("  1: 自动过渡循环（mixRatio 0→1→0 自动往复）")
    println("  2: 静态场景A（mixRatio=0，全场景A）")
    println("  3: 半过渡（mixRatio=0.5，A/B 各半）")
    println("  4: 静态场景B（mixRatio=1，全场景B）")
    println("  ↑/↓: 手动调整 mixRatio（过渡比例，↑ 增大偏向场景B，↓ 减小偏向场景A）")
    println("  ←/→: 调整 threshold（过渡纹理阈值，← 减小效果更强，→ 增大效果更弱）")
    println("  T: 切换 useTexture（纹理过渡 / 纯比例混合）")
    println("  空格: 暂停/恢复自动过渡循环")
    println("  R: 重置参数到默认值（mixRatio=0 threshold=0.1 useTexture=true）")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整公转角度；滚轮: 缩放")
    println("  ==============================")
}

/** 过渡纹理尺寸（256×256 水平渐变灰度图） */
public let MIX_TEX_SIZE: Int64 = 256

/**
 * 生成过渡纹理（水平渐变灰度图，r 通道从黑到白）。
 * 对照 three.js RenderTransitionPass 示例用噪声/渐变纹理做 tMixTexture。
 * 用 renderer.createTexture2D 高阶 API（mem 用 BgfxMemory 包装）上传，不直接触 bgfx4cj。
 *
 * @param renderer 渲染器（经其高阶 API 序列化上传）
 * @return 过渡纹理句柄（RGBA8，Clamp 采样）
 */
public func createMixTexture(renderer: ThreeRenderer): TextureHandle {
    let w: UInt16 = UInt16(MIX_TEX_SIZE)
    let h: UInt16 = UInt16(MIX_TEX_SIZE)
    let pixBuf = ArrayList<UInt8>()
    for (y in 0..MIX_TEX_SIZE) {
        for (x in 0..MIX_TEX_SIZE) {
            // 水平渐变：r 从左（黑=0）到右（白=255），过渡从右到左推进
            let v = UInt8((x * 255) / (MIX_TEX_SIZE - 1))
            pixBuf.add(v)        // r（过渡阈值用）
            pixBuf.add(v)        // g
            pixBuf.add(v)        // b
            pixBuf.add(255u8)    // a
        }
    }
    let totalBytes = UInt32(w) * UInt32(h) * 4u32
    let mem = BgfxMemory(totalBytes)
    let pixArr = Array<UInt8>(pixBuf.size, { i => pixBuf[i] })
    mem.writeUInt8(pixArr, Int64(pixBuf.size))
    let flags: UInt64 = UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
    let tex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.RGBA8.value(), flags, Some(mem))
    let tagDebug: Array<String> = ["transition", "createMixTexture: ${MIX_TEX_SIZE}x${MIX_TEX_SIZE} tex.idx=" + handleIdx(tex).toString()]
    Logger.debug(tagDebug)
    return tex
}

/**
 * 创建场景：相机 + 灯光 + 地板 + 立方体/球。
 * 场景A 红/暖色系，场景B 蓝/冷色系，两场景结构相同便于观察过渡。
 *
 * @return (sceneA, sceneB, cameraA, cameraB, 全部 mesh 列表)
 */
public func createScenes(
    width: Int32, height: Int32
): (Scene, Scene, PerspectiveCamera, PerspectiveCamera, ArrayList<Mesh>) {
    let sceneA = Scene()
    sceneA.name = "SceneA"
    let sceneB = Scene()
    sceneB.name = "SceneB"
    println("  场景创建成功: A=${sceneA.name} B=${sceneB.name}")

    let aspect = Float64(width) / Float64(height)
    let cameraA = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    cameraA.position.set(0.0, 3.0, 10.0)
    cameraA.lookAt(Vector3(0.0, 0.0, 0.0))
    let cameraB = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    cameraB.position.set(0.0, 3.0, 10.0)
    cameraB.lookAt(Vector3(0.0, 0.0, 0.0))
    println("  相机创建成功: A/B 各 fov=50 near=0.1 far=100 pos=(0,3,10)")

    // 灯光（两场景共用布局）
    let ambientA = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    sceneA.add(ambientA)
    let dirA = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirA.position.set(6.0, 10.0, 6.0)
    sceneA.add(dirA)
    let ambientB = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    sceneB.add(ambientB)
    let dirB = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirB.position.set(6.0, 10.0, 6.0)
    sceneB.add(dirB)
    println("  灯光创建成功: A/B 各 ambient + directional")

    // 地板（A 暖灰 / B 冷灰）
    let floorGeo = BoxGeometry(width: 12.0, height: 0.2, depth: 12.0)
    let floorMatA = MeshPhongMaterial()
    floorMatA.color = Color(0x70, 0x60, 0x50)
    let floorA = Mesh(geometry: floorGeo, material: floorMatA)
    floorA.position.set(0.0, -1.5, 0.0)
    sceneA.add(floorA)
    let floorMatB = MeshPhongMaterial()
    floorMatB.color = Color(0x50, 0x60, 0x70)
    let floorB = Mesh(geometry: floorGeo, material: floorMatB)
    floorB.position.set(0.0, -1.5, 0.0)
    sceneB.add(floorB)

    // 立方体（A 红/橙系，B 蓝/青系）
    let cubes = ArrayList<Mesh>()
    let cubeConfigsA = [
        (Color(0xff, 0x40, 0x40), -3.0, 0.0, 0.0),   // 红
        (Color(0xff, 0x80, 0x40),  0.0, 0.0, 0.0),   // 橙
        (Color(0xff, 0x40, 0x80),  3.0, 0.0, 0.0),   // 粉
        (Color(0xff, 0xff, 0x40),  0.0, 1.0, 2.0),   // 黄
    ]
    let cubeConfigsB = [
        (Color(0x40, 0x40, 0xff), -3.0, 0.0, 0.0),   // 蓝
        (Color(0x40, 0x80, 0xff),  0.0, 0.0, 0.0),   // 天蓝
        (Color(0x80, 0x40, 0xff),  3.0, 0.0, 0.0),   // 紫
        (Color(0x40, 0xff, 0xff),  0.0, 1.0, 2.0),   // 青
    ]
    for ((col, x, y, z) in cubeConfigsA) {
        let g = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let m = MeshPhongMaterial()
        m.color = col
        let cube = Mesh(geometry: g, material: m)
        cube.position.set(x, y, z)
        cubes.add(cube)
        sceneA.add(cube)
    }
    for ((col, x, y, z) in cubeConfigsB) {
        let g = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let m = MeshPhongMaterial()
        m.color = col
        let cube = Mesh(geometry: g, material: m)
        cube.position.set(x, y, z)
        cubes.add(cube)
        sceneB.add(cube)
    }

    // 球（A 暖色 HDR / B 冷色 HDR）
    let sphereA = SphereGeometry(radius: 0.6, widthSegments: 24, heightSegments: 16)
    let matA = MeshBasicMaterial()
    matA.color = Color(3.0, 1.5, 1.0)
    let sA = Mesh(geometry: sphereA, material: matA)
    sA.position.set(2.0, 1.5, -2.0)
    cubes.add(sA)
    sceneA.add(sA)
    let sphereB = SphereGeometry(radius: 0.6, widthSegments: 24, heightSegments: 16)
    let matB = MeshBasicMaterial()
    matB.color = Color(1.0, 1.5, 3.0)
    let sB = Mesh(geometry: sphereB, material: matB)
    sB.position.set(-2.0, 1.5, -2.0)
    cubes.add(sB)
    sceneB.add(sB)

    println("  立方体 + 球体创建成功: A/B 各 5 个（红暖 ↔ 蓝冷色系对照）")
    println("")

    return (sceneA, sceneB, cameraA, cameraB, cubes)
}
