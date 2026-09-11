package particles

/**
 * particles 渲染场景：
 * - 旋转 Points 星云（程序生成 2000 个粒子散布在球壳/盘面，PointsMaterial + 圆点 map 纹理）
 * - 两个 Sprite 精灵（SpriteMaterial + 圆点纹理，广告牌始终朝向相机）
 * - 相机轨道旋转 + 粒子自转，验证 POINTS 图元 / size / sizeAttenuation / map 采样 / Sprite 广告牌
 *
 * 对照 three.js:
 *   - Points：`new THREE.Points(geometry, new THREE.PointsMaterial({ size, map, transparent }))`
 *     three.js 示例 webgl_points_sprites / webgl_points_dynamic 的点云形态
 *   - Sprite：`new THREE.Sprite(new THREE.SpriteMaterial({ map, color }))` 广告牌精灵
 *
 * 按键交互（详见 win32.cj printHelp）：
 *   - 1: 完整体现（Points + Sprite，默认参数：size=0.15）
 *   - 2: 大粒子模式（size=0.5）
 *   - 3: 小粒子模式（size=0.05）
 *   - 4: 隐藏 Points（只显示 Sprite）
 *   - ←/→: 调整粒子大小 size；↑/↓: 调整旋转速度
 *   - 空格: 暂停/恢复旋转；R: 重置参数；H: 帮助
 */

import std.sync.*
import std.time.*
import std.collection.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.textures.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.ThreeRenderer
import three.window.MouseButton
import three.window.KeyCode
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.Logger

/// 默认粒子参数（R 键重置时回到此值）
public let DEFAULT_PARTICLE_SIZE: Float64 = 0.15
public let DEFAULT_ROT_SPEED: Float64 = 0.5

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public let MODE_FULL: Int64 = 1
public let MODE_BIG: Int64 = 2
public let MODE_SMALL: Int64 = 3
public let MODE_NO_POINTS: Int64 = 4

public var g_debugMode: Int64 = 1  // 默认 MODE_FULL
public var g_particleSize: Float64 = 0.15  // Points 粒子大小
public var g_rotSpeed: Float64 = 0.5       // 粒子旋转速度（弧度/帧）
public var g_pauseRotation: Bool = false
public var g_resetParams: Bool = false  // R 键触发重置
public var g_hidePoints: Bool = false    // 4 键隐藏 Points

public func printHelp(): Unit {
    println("  === 粒子测试按键帮助 ===")
    println("  1: 完整体现（Points 点云 + Sprite 精灵，默认参数：size=0.15）")
    println("  2: 大粒子模式（size=0.5）")
    println("  3: 小粒子模式（size=0.05）")
    println("  4: 隐藏 Points（只显示 Sprite）")
    println("  ←/→: 调整粒子大小 size（← 减小，→ 增大）")
    println("  ↑/↓: 调整旋转速度（↑ 加快，↓ 减慢）")
    println("  空格: 暂停/恢复粒子旋转（静态观察粒子形态）")
    println("  R: 重置参数到默认值（size=0.15 rotSpeed=0.5）")
    println("  H: 打印此帮助")
    println("  ==============================")
    println("  鼠标左键拖动: 调整相机轨道角度；滚轮: 缩放")
    println("  ==============================")
}

/// 粒子数量（Points 星云）
public let PARTICLE_COUNT: Int64 = 2000

/**
 * 创建粒子场景。
 *
 * @param width 窗口客户区宽
 * @param height 窗口客户区高
 * @return (scene, camera, points, sprite)
 *         - points: Points 星云（可旋转 / 调 size / 隐藏）
 *         - sprite: 第一个 Sprite（广告牌精灵）
 */
public func createScene(
    width: Int32,
    height: Int32
): (Scene, PerspectiveCamera, Points, Sprite) {
    let scene = Scene()
    scene.name = "ParticlesScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 200.0)
    camera.position.set(0.0, 0.0, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: fov=60 near=0.1 far=200 pos=(0,0,12)")

    // 灯光：环境光（Points/Sprite 不受光照影响，但场景中若有 Mesh 参照物需要）
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
    scene.add(ambient)
    println("  灯光创建成功: ambient")

    // ===== 程序生成圆点纹理（对照 three.js CanvasTexture 画圆点；DataTexture 由管线自动上传）=====
    let dotTex = createDotTexture(64)
    println("  圆点纹理创建成功")

    // ===== Points 星云（球壳分布，对照 three.js PointsMaterial map 点精灵示例）=====
    let ptsCount = PARTICLE_COUNT
    let ptsPositions = Array<Float64>(ptsCount * 3, { _ => 0.0 })
    let ptsColors = Array<Float64>(ptsCount * 3, { _ => 0.0 })
    var seed: Int64 = 12345
    for (i in 0..ptsCount) {
        // 球壳随机分布（均匀方向 × 半径 4~7 随机），形成星云环带
        let r = 4.0 + Float64(seed % 300) / 100.0  // 4.0 ~ 6.99
        seed = (seed * 1103515245 + 12345) % 2147483647
        let theta = Float64(seed % 6283) / 1000.0  // 0 ~ 6.282
        seed = (seed * 1103515245 + 12345) % 2147483647
        let phi = Float64(seed % 3142) / 1000.0 - 1.5708  // -π/2 ~ π/2
        seed = (seed * 1103515245 + 12345) % 2147483647
        let cp = cos(phi)
        ptsPositions[i * 3] = r * cp * cos(theta)
        ptsPositions[i * 3 + 1] = r * sin(phi) * 0.6  // 垂直压扁成盘状星云
        ptsPositions[i * 3 + 2] = r * cp * sin(theta)
        // 颜色渐变（中心偏暖色，边缘偏冷色，对照 three.js 点精灵示例 vertexColors）
        let t = clamp((r - 4.0) / 3.0, 0.0, 1.0)
        ptsColors[i * 3] = 0.9 + 0.1 * t
        ptsColors[i * 3 + 1] = 0.5 + 0.3 * (1.0 - t)
        ptsColors[i * 3 + 2] = 0.4 + 0.5 * (1.0 - t)
    }
    let ptsGeom = BufferGeometry()
    ptsGeom.setAttribute("position", Float32BufferAttribute(ptsPositions, 3))
    ptsGeom.setAttribute("color", Float32BufferAttribute(ptsColors, 3))
    ptsGeom.computeBoundingSphere()
    let ptsMat = PointsMaterial()
    ptsMat.color = Color(0xffffff)
    ptsMat.size = DEFAULT_PARTICLE_SIZE
    ptsMat.sizeAttenuation = true
    ptsMat.transparent = true
    ptsMat.map = Some(dotTex)
    ptsMat.vertexColors = true
    let points = Points(geometry: ptsGeom, material: ptsMat)
    points.name = "PointsNebula"
    scene.add(points)
    println("  Points 星云创建成功: ${ptsCount} 粒子, size=${DEFAULT_PARTICLE_SIZE}")

    // ===== Sprite 精灵（广告牌，对照 three.js Sprite + SpriteMaterial map 示例）=====
    let spriteMat = SpriteMaterial()
    spriteMat.color = Color(0xffdd44)
    spriteMat.map = Some(dotTex)
    let sprite = Sprite(material: spriteMat)
    sprite.position.set(2.5, 1.5, 1.0)
    sprite.scale.set(2.0, 2.0, 1.0)
    sprite.name = "SpriteGolden"
    scene.add(sprite)
    println("  Sprite 精灵创建成功: 金色广告牌 (2.5,1.5,1.0) scale=2.0")

    println("")
    return (scene, camera, points, sprite)
}

/**
 * 创建圆点纹理（程序生成 DataTexture，RGBA8，中心亮边缘透明）。
 * 对照 three.js CanvasTexture 画圆形渐变点；仓颉侧沿用 textures 测试项目范式——
 * 创建 DataTexture 纯数据对象，材质 map = Some(tex)，由渲染管线按 needsUpdate 自动上传 GPU 纹理。
 *
 * @param size 纹理边长（像素，如 64）
 * @return DataTexture 圆点纹理
 */
public func createDotTexture(size: Int64): DataTexture {
    // 生成 size×size 圆点像素（RGBA8）：中心 alpha=255，边缘 alpha=0（对照 CanvasTexture 圆点）
    let w = Int64(size)
    let h = Int64(size)
    let cx = Float64(w - 1) / 2.0
    let cy = Float64(h - 1) / 2.0
    let maxR = Float64(w) / 2.0
    let data = Array<UInt8>(w * h * 4, { _ => 0u8 })
    for (y in 0..h) {
        for (x in 0..w) {
            let dx = Float64(x) - cx
            let dy = Float64(y) - cy
            let d = sqrt(dx * dx + dy * dy) / maxR
            let a = clamp(1.0 - d, 0.0, 1.0)
            let idx = (y * w + x) * 4
            data[idx] = 255u8        // R 白
            data[idx + 1] = 255u8    // G 白
            data[idx + 2] = 255u8    // B 白
            data[idx + 3] = UInt8(a * 255.0)  // 中心不透明，边缘透明
        }
    }
    let tex = DataTexture(data, w, h)
    tex.name = "DotSpriteTexture"
    tex.magFilter = LinearFilter
    tex.minFilter = LinearFilter
    tex.needsUpdate = true
    return tex
}

/// 渲染循环逻辑（键盘交互 + 轨道控制 + 粒子自转）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）

/// 将数值限定在 [min, max] 区间
func clamp(value: Float64, min: Float64, max: Float64): Float64 {
    if (value < min) { return min }
    if (value > max) { return max }
    return value
}
