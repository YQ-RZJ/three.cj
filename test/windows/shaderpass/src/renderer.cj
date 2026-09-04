package shaderpass

/**
 * shaderpass 渲染场景：
 * - 盒子 + 多色球 + 点光源的基础场景
 * - EffectComposer 链：RenderPass → ShaderPass("copy")（透传 readBuffer）→ 上屏
 *   验证 ShaderPass 通用 shader pass（用 CopyShader 1:1 透传）的效果。
 *
 * 体现：ShaderPass 基础设施 pass 集成、全屏 quad + sampler 绑 readBuffer、needsSwap=true 链交换。
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

/// 创建场景：相机 + 方向光 + 环境光 + 盒子 + 多色球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "ShaderPassScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)

    let box = BoxGeometry(width: 8.0, height: 0.3, depth: 8.0)
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0x80, 0x80, 0x80)
    let boxMesh = Mesh(geometry: box, material: boxMat)
    boxMesh.position.set(0.0, -1.5, 0.0)
    scene.add(boxMesh)

    let spheres = ArrayList<Mesh>()
    let sphereConfigs = [
        (Color(0xff, 0x40, 0x40), -2.0, 0.0, 0.0),
        (Color(0x40, 0xff, 0x40),  0.0, 0.0, 0.0),
        (Color(0x40, 0x40, 0xff),  2.0, 0.0, 0.0),
    ]
    for ((col, x, y, z) in sphereConfigs) {
        let g = SphereGeometry(radius: 0.8, widthSegments: 24, heightSegments: 16)
        let m = MeshPhongMaterial()
        m.color = col
        let sphere = Mesh(geometry: g, material: m)
        sphere.position.set(x, y, z)
        spheres.add(sphere)
        scene.add(sphere)
    }
    println("  球体创建成功: ${spheres.size} 个")
    println("")

    return (scene, camera, spheres)
}
