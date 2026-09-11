package cubetexture

/**
 * cubetexture 渲染场景：
 * - 盒子 + 多色球 + 环境光 + 方向光的基础场景
 * - EffectComposer 链：RenderPass → CubeTexturePass（立方体贴图背景）→ 上屏
 *   验证 CubeTexturePass 把 CubeTexture 当作天空盒/背景渲染的效果。
 *
 * 体现：CubeTexturePass 基础设施 pass 集成、bgfx view 级 submit 立方体背景。
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
import three.window.MouseButton
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.CubeTexturePass
import three.rendering.postprocessing.OutputPass
import three.rendering.textures.CubeTexture

/// 创建场景：相机 + 方向光 + 环境光 + 盒子 + 多色球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "CubeTextureScene"
    println("  场景创建成功: ${scene.name}")

    // 相机
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 12.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // 环境光 + 方向光
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)

    // 盒子（底板）
    let box = BoxGeometry(width: 8.0, height: 0.3, depth: 8.0)
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0x80, 0x80, 0x80)
    let boxMesh = Mesh(geometry: box, material: boxMat)
    boxMesh.position.set(0.0, -1.5, 0.0)
    scene.add(boxMesh)

    // 多色球
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
