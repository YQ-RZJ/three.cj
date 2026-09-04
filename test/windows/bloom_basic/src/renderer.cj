package bloom_basic

/**
 * bloom_basic 渲染场景：
 * - 几个不同颜色的高强度发光球体（emissive 零件）在来回移动
 * - 一束弱方向光 + 环境光提供基础照明
 * - 启用简单版 Bloom（BgfxBloomPass：水平卷积 + 垂直卷积 + strength 合成）
 *
 * 验证：three.js BloomPass（简单版）迁移到 Three.cj 后的正确性。
 * 与 unreal_bloom（UnrealBloomPass 5 级金字塔）形成对照：
 *   - BloomPass：kernelSize=25 / sigma=4，两遍卷积 + 合成，开销小
 *   - UnrealBloomPass：threshold 亮度提取 + 5 级 mip 模糊，效果更柔
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
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.BgfxBloomPass

/// 球体动画数据
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

/// 创建场景：相机 + 方向光 + 环境光 + 几个高强度发光球体
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "BloomBasicScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：略俯视，朝向场景中心
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（弱，仅填底暗区） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.15)
    ambient.name = "Ambient"
    scene.add(ambient)

    // ---- 方向光（弱，提供微弱定向感） ----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.2)
    dirLight.position.set(6.0, 10.0, 6.0)
    dirLight.name = "DirLight"
    scene.add(dirLight)

    // ---- 几个高强度发光球体（MeshBasicMaterial color × 高 intensity）----
    // 简单版 BloomPass 无 threshold 亮度提取，直接模糊整帧；高亮 color > 1 的球体
    // 经卷积模糊后形成光晕，再以 strength 合成回原图。
    let spheres = ArrayList<Mesh>()
    // (颜色, 半径, 移动轴, 速度, 相位, 幅度)
    let sphereConfigs = [
        (Color(0xff3030), 0.8, 0, 1.0, 0.0, 3.0),  // 红，X 轴
        (Color(0x30ff30), 0.7, 1, 1.3, 1.0, 2.5),  // 绿，Y 轴
        (Color(0x3060ff), 0.75, 2, 0.9, 2.0, 2.8), // 蓝，Z 轴
        (Color(0xffaa00), 0.6, 0, 1.6, 3.0, 2.2),  // 橙，X 轴（不同相位/速度）
        (Color(0xff00ff), 0.65, 1, 0.7, 4.0, 3.2), // 紫红，Y 轴
    ]
    var si: Int64 = 0
    for ((col, r, ax, spd, ph, amp) in sphereConfigs) {
        let g = SphereGeometry(radius: r, widthSegments: 24, heightSegments: 16)
        let m = MeshBasicMaterial()
        // 高强度颜色：color 值 × 2.0 模拟 emissive 发光（RGBA16F 支持 >1）
        m.color = Color(col.r * 2.0, col.g * 2.0, col.b * 2.0)
        let sphere = Mesh(geometry: g, material: m)
        sphere.position.set(0.0, 0.0, 0.0)
        sphere.name = "GlowSphere"
        sphere.userData.add("__anim", AnimState(phase: ph, speed: spd, axis: ax, amp: amp))
        spheres.add(sphere)
        scene.add(sphere)
        si++
    }
    println("  发光球体创建成功: ${spheres.size} 个")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, spheres)
}
