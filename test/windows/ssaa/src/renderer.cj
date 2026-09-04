package ssaa

/**
 * ssaa 渲染场景：
 * - 盒子 + 多色球 + 地面网格，边缘清晰的几何体（最能体现锯齿 → SSAA 平滑）
 * - 场景整体缓慢旋转，方便观察各角度边缘
 * - pass 链：SSAARenderPass（单帧多 jitter 样本累加，sampleLevel=3 → 8 样本）
 *
 * 体现：SSAARenderPass 超采样集成（jitter 抖动相机 + 加性混合累加）、
 *       sampleLevel 控制样本数（2^sampleLevel）、unbiased 权重微调、
 *       needsSwap=true 链交换。
 *
 * 正确渲染效果（供对照）：
 *   - 样本数越多边缘越平滑（sampleLevel=3 → 8 样本已可见明显改善；
 *     sampleLevel=4 → 16 样本更干净；sampleLevel=5 → 32 样本接近完美但帧率下降）
 *   - 单帧内完成全部样本（SSAA 是空间超采样，非时间累加），画面始终稳定无残影
 * 注：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
 */

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
import std.collection.*

/// 创建场景：相机 + 方向光 + 环境光 + 盒子 + 多色球 + 地面
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Object3D>) {
    let scene = Scene()
    scene.name = "SSAAScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 3.0, 11.0)
    camera.lookAt(Vector3(0.0, 0.5, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.35)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.9)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)

    let meshes = ArrayList<Object3D>()

    // 中央盒子（边缘锐利，AA 重点观察对象）
    let box = BoxGeometry(width: 2.2, height: 2.2, depth: 2.2)
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0xe0, 0x60, 0x40)
    let boxMesh = Mesh(geometry: box, material: boxMat)
    boxMesh.position.set(0.0, 1.4, 0.0)
    meshes.add(boxMesh)
    scene.add(boxMesh)

    // 三个彩色球（曲面边缘）
    let sphereConfigs = [
        (Color(0x40, 0xc0, 0x60), -3.2, 0.6, 0.0),
        (Color(0x40, 0x80, 0xe0),  0.0, 0.6, -2.6),
        (Color(0xd0, 0xc0, 0x30),  3.2, 0.6, 0.0),
    ]
    for ((col, x, y, z) in sphereConfigs) {
        let g = SphereGeometry(radius: 0.75, widthSegments: 20, heightSegments: 14)
        let m = MeshPhongMaterial()
        m.color = col
        let sphere = Mesh(geometry: g, material: m)
        sphere.position.set(x, y, z)
        meshes.add(sphere)
        scene.add(sphere)
    }

    // 地面（大平面，远处边缘锯齿）
    let ground = BoxGeometry(width: 20.0, height: 0.2, depth: 20.0)
    let groundMat = MeshPhongMaterial()
    groundMat.color = Color(0x50, 0x52, 0x58)
    let groundMesh = Mesh(geometry: ground, material: groundMat)
    groundMesh.position.set(0.0, -0.1, 0.0)
    meshes.add(groundMesh)
    scene.add(groundMesh)

    println("  几何体创建成功: ${meshes.size} 个")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, meshes)
}
