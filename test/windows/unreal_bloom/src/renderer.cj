package unreal_bloom

/**
 * bloom 渲染场景：
 * - 几个不同颜色的高强度发光球体（emissive 零件）在来回移动
 * - 一束弱方向光 + 环境光提供基础照明，不抢 Bloom 光晕
 * - 启用 Bloom 后处理（金字塔下/上采样 + combine）
 *
 * 体现：Bloom 后处理 pass 集成、发光材质（MeshBasicMaterial 高 color intensity）、
 *       主颜色 RT → Bloom downsample/upsample → combine 写回主输出。
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
    scene.name = "BloomScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：略俯视，朝向场景中心
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // ---- 环境光（弱，仅填底暗区，不抢 Bloom 光晕） ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.15)
    ambient.name = "Ambient"
    scene.add(ambient)

    // ---- 方向光（弱，提供微弱定向感） ----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.2)
    dirLight.position.set(6.0, 10.0, 6.0)
    dirLight.name = "DirLight"
    scene.add(dirLight)

    // ---- 几个高强度发光球体（MeshBasicMaterial color × 高 intensity 模拟 emissive）----
    // MeshBasicMaterial 无光照，color 直接输出 → 高强度 color 值 > 1 经 Bloom 金字塔捕捉发光
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
        // 高强度颜色：color 值 × 2.0 模拟 emissive 发光（Bloom 捕捉 > 1 的亮度）
        // col.r/g/b 是 0-1 Float64（Color(hex) 构造已归一化），直接放大即可（RGBA16F 支持 >1）
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

