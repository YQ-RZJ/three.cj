package texturepass

/**
 * texturepass 渲染场景：
 * - 盒子 + 多色球 + 点光源的基础场景
 * - EffectComposer 链：RenderPass → TexturePass（程序生成的彩条纹理覆盖屏幕，opacity=1.0）→ 上屏
 *   验证 TexturePass 把一张纹理渲满屏的效果。
 *
 * 体现：TexturePass 基础设施 pass 集成、bgfx TextureHandle 喂入 + CopyShader opacity 乘。
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
import three.rendering.postprocessing.TexturePass
import three.rendering.postprocessing.FullScreenQuad
import three.rendering.types.*
import three.rendering.bgfx.BgfxConstants
import three.utils.memory.BgfxMemory
import three.utils.memory.AutoFreePtr

/// 创建场景：相机 + 方向光 + 环境光 + 盒子 + 多色球
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>) {
    let scene = Scene()
    scene.name = "TexturePassScene"
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

/// 程序生成 256x256 彩条纹理（8 条水平彩条：红/绿/蓝/黄/青/紫/白/黑），返回 bgfx TextureHandle。
/// 对照 three.js TexturePass 用 TextureLoader.load 加载图片；本测试用程序生成避免文件依赖。
/// 用 renderer.createTexture2D 高阶 API（mem 用 BgfxMemory 包装）上传，不直接触 bgfx4cj。
public func createStripeTexture(renderer: BgfxRenderer): TextureHandle {
    let w: UInt16 = 256u16
    let h: UInt16 = 256u16
    // 8 条彩条，每条 32 行高
    let colors: Array<UInt8> = [
        0xFF, 0x00, 0x00, 0xFF,  // 红
        0x00, 0xFF, 0x00, 0xFF,  // 绿
        0x00, 0x00, 0xFF, 0xFF,  // 蓝
        0xFF, 0xFF, 0x00, 0xFF,  // 黄
        0x00, 0xFF, 0xFF, 0xFF,  // 青
        0xFF, 0x00, 0xFF, 0xFF,  // 紫
        0xFF, 0xFF, 0xFF, 0xFF,  // 白
        0x00, 0x00, 0x00, 0xFF,  // 黑
    ]
    let pixBuf = ArrayList<UInt8>()
    for (y in 0..256) {
        let stripe = Int64(y) / 32   // 0..7
        let idx = stripe * 4
        for (_ in 0..256) {
            pixBuf.add(colors[idx])
            pixBuf.add(colors[idx + 1])
            pixBuf.add(colors[idx + 2])
            pixBuf.add(colors[idx + 3])
        }
    }
    // pixBuf → BgfxMemory（安全包装）→ renderer.createTexture2D 上传
    let totalBytes = UInt32(w) * UInt32(h) * 4u32
    let mem = BgfxMemory(totalBytes)
    let pixArr = Array<UInt8>(pixBuf.size, { i => pixBuf[i] })
    mem.writeUInt8(pixArr, Int64(pixBuf.size))
    let flags: UInt64 = UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
    return renderer.createTexture2D(w, h, false, 1u16, TextureFormat.RGBA8.value(), flags, Some(mem))
}

/// 渲染循环逻辑（相机轨道控制 + Scene 状态切换）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）

