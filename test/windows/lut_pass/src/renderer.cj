package lut_pass

/**
 * lut_pass 渲染场景（v2 生命周期模式）：
 * - 彩色立方体 + 渐变球（含 HDR 高光），便于观察颜色分级映射
 * - 地板（MeshPhongMaterial）+ 方向光 + 环境光 + 点光源
 * - 程序化生成 4 种 3D LUT（identity/warm/cool/contrast）上传为 3D 纹理（RGBA8, 16³）
 * - EffectComposer 链：RenderPass → LUTPass（lut/intensity 可调）→ OutputPass → 上屏
 * - 验证 LUTPass 3D 查找表颜色分级效果
 *
 * 按键交互（中间步骤独立呈现，详见 printHelp）：
 *   - 1: 完整 LUT 流程（intensity=1.0）
 *   - 2: 半强度混合（intensity=0.5，原图与 LUT 各半）
 *   - 3: 零强度（intensity=0，LUTPass 直通，等价原图）
 *   - 4: 跳过 LUTPass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓: 调整 intensity（混合强度）
 *   - ←/→: 切换 LUT 类型（identity/warm/cool/contrast 循环）
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
import three.rendering.ThreeRenderer
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.types.*
import three.rendering.bgfx.BgfxConstants

/// LUTPass 默认参数（R 键重置时回到此值）
public let DEFAULT_INTENSITY: Float64 = 1.0

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_HALF: Int64 = 2
public let MODE_ZERO: Int64 = 3
public let MODE_BYPASS: Int64 = 4

public let LUT_IDENTITY: Int64 = 1
public let LUT_WARM: Int64 = 2
public let LUT_COOL: Int64 = 3
public let LUT_CONTRAST: Int64 = 4

public var g_debugMode: Int64 = 1        // 默认 MODE_FULL
public var g_intensity: Float64 = 1.0    // 混合强度
public var g_lutType: Int64 = LUT_WARM   // 默认 warm（暖色调，效果明显）
public var g_pauseRotation: Bool = false
public var g_resetLut: Bool = false      // R 键触发重置

public func printHelp(): Unit {
    println("  === LUTPass 测试按键帮助 ===")
    println("  1: 完整 LUT 流程（intensity=1.0）")
    println("  2: 半强度混合（intensity=0.5，原图与 LUT 各半）")
    println("  3: 零强度（intensity=0，LUTPass 直通，等价原图）")
    println("  4: 跳过 LUTPass（pass.enabled=false），纯 RenderPass 直出")
    println("  ↑/↓: 调整 intensity（混合强度，↑ 增大，↓ 减小）")
    println("  ←/→: 切换 LUT 类型（identity/warm/cool/contrast 循环）")
    println("  空格: 暂停/恢复立方体旋转（静态场景下观察颜色映射）")
    println("  R: 重置参数到默认值（intensity=1.0 LUT=warm）")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整公转角度；滚轮: 缩放")
    println("  ==============================")
}
public let DEFAULT_LUT_TYPE: Int64 = LUT_WARM

/// LUT 边长（3D 纹理 16×16×16，RGBA8）
public let LUT_SIZE: Int64 = 16

/** 3D LUT 纹理句柄数组（下标 = LUT 类型 1..4，索引 [lutType-1]） */
var g_lutTextures: ArrayList<TextureHandle> = ArrayList<TextureHandle>()

/**
 * 生成 LUT 纹理数据并上传为 bgfx 3D 纹理。
 *
 * 对照 three.js LUTPass 用法：`new LUTPass({ lut: texture3D })`，lut 是 Data3DTexture
 * （image.data = RGBA 字节流，尺寸 size×size×size）。
 *
 * 3D 纹理数据布局（与 Data3DTexture 一致，bgfx 同约定）：
 *   data[ (z * size + y) * size + x ]  ← texel(x=r, y=g, z=b)
 *   R 通道 = x（红色分量），G = y，B = z（最慢维度为 B）
 *
 * @param lutType LUT 类型（1=identity 2=warm 3=cool 4=contrast）
 * @return 上传后的 3D 纹理句柄
 */
public func createLutTexture(renderer: ThreeRenderer, lutType: Int64): TextureHandle {
    let size = LUT_SIZE
    let total = size * size * size * 4  // RGBA8 每 texel 4 字节
    let data = Array<UInt8>(total, { _ => 0u8 })

    for (z in 0..size) {
        for (y in 0..size) {
            for (x in 0..size) {
                // 输入分量归一化 [0,1]
                let rIn = Float64(x) / Float64(size - 1)
                let gIn = Float64(y) / Float64(size - 1)
                let bIn = Float64(z) / Float64(size - 1)

                // 各 LUT 类型的映射函数（对照常见 color grading LUT 风格）
                var rOut = rIn
                var gOut = gIn
                var bOut = bIn
                match (lutType) {
                    case LUT_IDENTITY =>
                        // 恒等：无颜色变化（验证 LUT 管线正确性的基准）
                        ()
                    case LUT_WARM =>
                        // 暖色调：加红减蓝
                        rOut = min(1.0, rIn * 1.12 + 0.03)
                        gOut = gIn * 0.97
                        bOut = bIn * 0.82
                    case LUT_COOL =>
                        // 冷色调：加蓝减红
                        rOut = rIn * 0.82
                        gOut = gIn * 0.95
                        bOut = min(1.0, bIn * 1.12 + 0.03)
                    case LUT_CONTRAST =>
                        // 对比度增强：S 曲线（以 0.5 为中心拉伸）
                        let s = 1.35
                        rOut = clamp(0.5 + (rIn - 0.5) * s, 0.0, 1.0)
                        gOut = clamp(0.5 + (gIn - 0.5) * s, 0.0, 1.0)
                        bOut = clamp(0.5 + (bIn - 0.5) * s, 0.0, 1.0)
                    case _ => ()
                }

                let idx = (z * size + y) * size + x
                data[idx * 4 + 0] = UInt8(Int64(rOut * 255.0 + 0.5))
                data[idx * 4 + 1] = UInt8(Int64(gOut * 255.0 + 0.5))
                data[idx * 4 + 2] = UInt8(Int64(bOut * 255.0 + 0.5))
                data[idx * 4 + 3] = 255u8  // alpha 恒 1
            }
        }
    }

    // 上传 3D 纹理（RGBA8，Clamp 采样，线性过滤 —— LUT 需三线性插值平滑过渡）
    let mem = BgfxMemory(UInt32(total))
    mem.writeUInt8(data, total)
    let tex = renderer.createTexture3D(
        UInt16(size), UInt16(size), UInt16(size), false,
        TextureFormat.RGBA8.value(),
        UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_W_CLAMP),
        Some(mem))
    Logger.debug(["lut", "createLutTexture: type=" + lutType.toString() +
                  " size=" + size.toString() + " tex.idx=" + handleIdx(tex).toString()])
    return tex
}

/// 创建场景：相机 + 灯光 + 地板 + 彩色立方体 + 渐变球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "LUTScene"
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

    // 彩色立方体（覆盖红/绿/蓝/黄，LUT 色彩映射在各纯色上差异明显）
    let cubes = ArrayList<Mesh>()
    let cubeConfigs = [
        (Color(0xff, 0x40, 0x40), -3.0, 0.0, 0.0),   // 红立方体
        (Color(0x40, 0xff, 0x40),  0.0, 0.0, 0.0),   // 绿立方体
        (Color(0x40, 0x40, 0xff),  3.0, 0.0, 0.0),   // 蓝立方体
        (Color(0xff, 0xff, 0x40),  0.0, 1.0, 2.0),   // 黄立方体
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

    // 渐变球（含 HDR 高光，LUT 对高光色温偏移的观察点）
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

    println("  立方体 + 球体创建成功: ${cubes.size} 个（含 HDR emissive 球，颜色覆盖全光谱）")
    println("")

    return (scene, camera, cubes)
}
