package outputpass

/**
 * outputpass 渲染场景：
 * - 盒子 + 多色球（部分球 emissive > 1 模拟 HDR）+ 点光源的基础场景
 * - EffectComposer 链：RenderPass → OutputPass（ACESFilmic tone mapping + sRGB）→ 上屏
 *   验证 OutputPass 色调映射 + sRGB 色彩空间转换的效果（HDR > 1 被压缩到 [0,1] 屏幕显示）。
 *
 * 体现：OutputPass 基础设施 pass 集成、OutputShader 7 种 ToneMapping #define 编译、sRGB OETF 转换。
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
import three.rendering.postprocessing.OutputPass
import three.rendering.postprocessing.FullScreenQuad
import three.utils.constants.*

/// 创建场景：相机 + 方向光 + 环境光 + 盒子 + 多色球（部分 emissive > 1 模拟 HDR）
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "OutputPassScene"
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

    // 多色球：部分用 MeshBasicMaterial + color > 1 模拟 HDR emissive（OutputPass 把 >1 压到 [0,1]）
    let spheres = ArrayList<Mesh>()
    let sphereConfigs = [
        (Color(0xff, 0x40, 0x40), -3.0, 0.0, 0.0, 1.0),   // 普通 Phong 球（LDR）
        (Color(0x40, 0xff, 0x40), -1.5, 0.0, 0.0, 3.0),   // HDR 绿球（color ×3，OutputPass 压缩）
        (Color(0x40, 0x40, 0xff),  0.0, 0.0, 0.0, 1.0),   // 普通 Phong 球（LDR）
        (Color(0xff, 0xff, 0x40),  1.5, 0.0, 0.0, 4.0),   // HDR 黄球（color ×4，OutputPass 压缩）
        (Color(0x40, 0x40, 0x40),  3.0, 0.0, 0.0, 1.0),   // 普通 Phong 球（LDR）
    ]
    for ((col, x, y, z, intensity) in sphereConfigs) {
        let g = SphereGeometry(radius: 0.8, widthSegments: 24, heightSegments: 16)
        // intensity > 1 用 MeshBasicMaterial + color 放大模拟 HDR；= 1 用 MeshPhongMaterial 常规
        let m = if (intensity > 1.0) {
            let bm = MeshBasicMaterial()
            bm.color = Color(col.r * intensity, col.g * intensity, col.b * intensity)
            bm
        } else {
            let pm = MeshPhongMaterial()
            pm.color = col
            pm
        }
        let sphere = Mesh(geometry: g, material: m)
        sphere.position.set(x, y, z)
        spheres.add(sphere)
        scene.add(sphere)
    }
    println("  球体创建成功: ${spheres.size} 个（含 HDR emissive 球）")
    println("")

    return (scene, camera, spheres)
}

/// 渲染循环逻辑已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）

