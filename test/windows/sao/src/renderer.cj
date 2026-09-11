package sp_sao

/**
 * sp_sao 渲染场景（对齐 three.js 官方案例 webgl_postprocessing_sao.html）：
 * - 场景：120 个随机球体（SphereGeometry(3,48,24)，scale 0.05~0.25，位置 ±2 随机，
 *   随机旋转，颜色 HSL(h,1.0,0.3)），group 缓慢旋转
 * - 相机：PerspectiveCamera(65, aspect, near=3, far=10)，position.z = 7
 * - 灯光：3 个彩色点光源 + 环境光 0.2（官方案例 PointLight 500 为 WebGL 物理单位，
 *   Three.cj 采用与 ssao 测试一致的强度语义）
 * - SAO 参数：全部使用 SAOPass 默认值（saoBias=0.5, saoIntensity=0.18, saoScale=1,
 *   saoKernelRadius=100, saoMinResolution=0, saoBlur=true, saoBlurRadius=8,
 *   saoBlurStdDev=4, saoBlurDepthCutoff=0.01 —— 与官方案例 SAOPass 默认 params 完全一致）
 *
 * Three.cj 差异：官方案例用 InstancedMesh（120 实例共享几何体），但 SAOPass
 * 自建 VB/IB 按 geometry 缓存、逐 mesh 提交，不支持 instancing，故改为 120 个独立 Mesh。
 */

import std.sync.*
import std.time.*
import std.math.*
import std.random.*
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
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.SAOPass

/// 球体数量（对齐官方 InstancedMesh count = 120）
public let SPHERE_COUNT: Int64 = 120

// ===== 调试：SAO 输出模式（原 win32.cj 数字键 1-3 切换，迁移至 WindowEngine 输入 onFrame） =====
public var g_outputMode: Int64 = 0
public var g_outputDirty = AtomicBool(true)

/// 创建场景、相机、灯光与随机球体群
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Group) {
    let scene = Scene()
    scene.name = "SAOScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：对齐官方 PerspectiveCamera(65, aspect, 3, 10)，position.z = 7
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 65.0, aspect: aspect, near: 3.0, far: 10.0)
    camera.position.set(0.0, 0.0, 7.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: fov=65 near=3 far=10 pos=(0,0,7)")

    // 灯光（对齐官方：3 个彩色点光源对角布置 + 环境光 0.2）
    // 关键修正：官方案例 PointLight intensity=500 是 WebGL 物理单位（无衰减语义），
    // Three.cj 点光源 decay=2.0 物理衰减 + 距离衰减，intensity=5.0 在 (-10,-10,10)
    // 远处照度几乎为 0 → 球体只剩 ambient 0.2 + 环境反射项 → 暗色被 saoapply 当场景色。
    // 改为：方向光提供基础无衰减照明（对齐 SSAO 测试 boxshow 验证过的配置），
    //       点光源放近处 + 提高 intensity 让彩色光照可见，AO 阴影才有对比。
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)
    // 3 个彩色点光源放近处（对角 ±4 范围），intensity 提到 30 弥补 decay=2 衰减
    let light1 = PointLight(color: Color(0xff6060), intensity: 30.0)
    light1.position.set(-4.0, -4.0, 4.0)
    scene.add(light1)
    let light2 = PointLight(color: Color(0x60ff60), intensity: 30.0)
    light2.position.set(-4.0, 4.0, 4.0)
    scene.add(light2)
    let light3 = PointLight(color: Color(0x6060ff), intensity: 30.0)
    light3.position.set(4.0, -4.0, 4.0)
    scene.add(light3)
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    scene.add(ambient)
    println("  灯光创建成功: 方向光 0.8 + 3 近距点光 30 + ambient 0.3")

    // 随机球体群（对齐官方：位置 ±2、scale 0.05~0.25、随机旋转、HSL 颜色）
    let group = Group()
    group.name = "SphereField"
    let sphereGeom = SphereGeometry(radius: 3.0, widthSegments: 48, heightSegments: 24)
    var rng = Random()  // 对齐官方 Math.random()（无种子；如需复现可改 Random(12345)）
    for (i in 0..SPHERE_COUNT) {
        let material = MeshStandardMaterial()
        material.roughness = 0.5
        material.metalness = 0.0
        let h = rng.nextFloat64()
        let l = 0.3
        material.color = Color().setHSL(h, 1.0, l)
        let mesh = Mesh(geometry: sphereGeom, material: material)
        mesh.position.set(
            rng.nextFloat64() * 4.0 - 2.0,
            rng.nextFloat64() * 4.0 - 2.0,
            rng.nextFloat64() * 4.0 - 2.0)
        mesh.rotation.set(
            rng.nextFloat64(),
            rng.nextFloat64(),
            rng.nextFloat64())
        let s = rng.nextFloat64() * 0.2 + 0.05
        mesh.scale.set(s, s, s)
        group.add(mesh)
    }
    scene.add(group)
    println("  球体群创建成功: ${SPHERE_COUNT} 个")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, group)
}

/// 渲染循环逻辑（group 缓慢旋转 + SAO 输出模式切换）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）

