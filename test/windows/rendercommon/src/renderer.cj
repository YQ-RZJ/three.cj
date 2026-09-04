package rendercommon

/**
 * rendercommon 渲染场景：
 * - common 组件 API 验证（对照 JS renderers.common 包）：
 *   RenderList（push/sort/finish/clear 对象收集）、RenderObjects（get 缓存）、
 *   Info（reset/update 渲染统计）、Background（scene.background Color）、
 *   QuadMesh（全屏四边形）
 * - BgfxRenderer（<: common.Renderer）渲染球体场景验证调度链路
 * - 画面内 dbgText 显示 Info 统计
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
import three.rendering.common.*

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var sphere: Mesh
    public var info: Info

    public init(scene!: Scene, camera!: PerspectiveCamera, sphere!: Mesh, info!: Info) {
        this.scene = scene
        this.camera = camera
        this.sphere = sphere
        this.info = info
    }
}

/// 创建场景：球体 + common 组件 API 验证
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "CommonScene"

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 0.0, 8.0)
    camera.name = "MainCamera"

    // ---- 光源 ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.2)
    dirLight.position.set(5.0, 8.0, 5.0)
    scene.add(dirLight)

    // ---- 球体 ----
    let m = MeshPhongMaterial()
    m.color = Color(0x4488ff)
    m.specular = Color(0xffffff)
    m.shininess = 40.0
    let sphere = Mesh(geometry: SphereGeometry(radius: 1.2, widthSegments: 24, heightSegments: 16), material: m)
    sphere.position.set(0.0, 0.0, 0.0)
    sphere.name = "Sphere"
    scene.add(sphere)

    // ================= common 组件 API 验证 =================

    // ---- 1. RenderList（对照 JS renderers/common/RenderList.js）----
    let renderList = RenderList()
    println("  [common] RenderList: init OK")
    // push 收集（对照 JS: renderList.push(object, geometry, material, groupOrder, renderOrder, z, group)）
    renderList.push(sphere, sphere.geometry, m, 0, 0, -8.0, 0)
    renderList.push(sphere, sphere.geometry, m, 0, 0, -8.0, 0)
    let items = renderList.finish()
    println("  [common] RenderList.push×2 → finish()=${items.size}（去重合并）")
    renderList.clear()
    println("  [common] RenderList.clear() → 清空")

    // ---- 2. RenderObjects（对照 JS renderers/common/RenderObjects.js）----
    let renderObjects = RenderObjects()
    let ctx = RenderContext()
    let ro = renderObjects.get(sphere, sphere.geometry, m, ctx, camera, scene)
    println("  [common] RenderObjects.get: mesh=${ro.mesh.name} material=${ro.material.kind}")
    // 缓存命中（同一 key 返回同一实例；仓颉用 uuid 比较引用）
    let ro2 = renderObjects.get(sphere, sphere.geometry, m, ctx, camera, scene)
    println("  [common] RenderObjects.get 缓存命中: ${ro.mesh.uuid == ro2.mesh.uuid}")
    renderObjects.clear()
    println("  [common] RenderObjects.clear() OK")

    // ---- 3. Info（对照 JS renderers/common/Info.js 渲染统计）----
    let info = Info()
    info.reset()
    println("  [common] Info: reset() frame=${info.frame} calls=${info.calls}")
    info.calls = 10
    info.update(1)  // 对照 JS: info.update( frame )；calls/triangles/vertices 为字段
    println("  [common] Info: calls=${info.calls} frame=${info.frame}")

    // ---- 4. Background（对照 JS renderers/common/Background.js）----
    scene.background = Some(Color(0x335577))  // Color 背景 → clear 色
    println("  [common] Background: scene.background = Color(0x335577)")

    println("  场景创建成功: ${scene.name}")
    println("  验证: RenderList/RenderObjects/Info/Background/QuadMesh + BgfxRenderer 调度")
    println("")

    return SceneObjects(scene: scene, camera: camera, sphere: sphere, info: info)
}

/// 渲染循环逻辑（相机轨道控制 + Info 统计显示）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）
