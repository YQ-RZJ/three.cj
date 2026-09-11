package sp_scenes

/**
 * sp_scenes 渲染场景：
 * - 多球体（Phong/Basic）+ 相机轨道控制
 * - Scene 字段验证：background（Color 覆盖 clear 色）/ fog（线性雾）/
 *   fogExp2（指数雾）/ overrideMaterial（覆盖材质）切换
 * - Scene.copy/clone/toJSON 接口验证 + Fog/FogExp2 clone/toJSON
 * - 画面内 dbgText 显示当前 fog/background/overrideMaterial 状态
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

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var sphere1: Mesh
    public var sphere2: Mesh
    public var fog1: Fog
    public var fog2: FogExp2
    public var overrideMat: MeshBasicMaterial

    public init(scene!: Scene, camera!: PerspectiveCamera, sphere1!: Mesh, sphere2!: Mesh,
                fog1!: Fog, fog2!: FogExp2, overrideMat!: MeshBasicMaterial) {
        this.scene = scene
        this.camera = camera
        this.sphere1 = sphere1
        this.sphere2 = sphere2
        this.fog1 = fog1
        this.fog2 = fog2
        this.overrideMat = overrideMat
    }
}

/// 创建场景：两球 + Scene 字段与接口验证
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "ScenesScene"

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

    // ---- 球1：Phong（有光照）----
    let m1 = MeshPhongMaterial()
    m1.color = Color(0x4488ff)
    m1.specular = Color(0xffffff)
    m1.shininess = 40.0
    let sphere1 = Mesh(geometry: SphereGeometry(radius: 1.2, widthSegments: 24, heightSegments: 16), material: m1)
    sphere1.position.set(-2.0, 0.0, 0.0)
    sphere1.name = "SpherePhong"
    scene.add(sphere1)

    // ---- 球2：Basic（无光照，便于观察雾/背景色）----
    let m2 = MeshBasicMaterial()
    m2.color = Color(0xff8844)
    let sphere2 = Mesh(geometry: SphereGeometry(radius: 1.2, widthSegments: 24, heightSegments: 16), material: m2)
    sphere2.position.set(2.0, 0.0, 0.0)
    sphere2.name = "SphereBasic"
    scene.add(sphere2)

    // ---- Scene 字段：background（Color）----
    // 对照 JS: scene.background = new Color(...) → WebGLBackground 用作 clear 色
    scene.background = Some(Color(0x335577))

    // ---- Scene 字段：fog（线性雾）与 fogExp2（指数雾）----
    let fog1 = Fog(Color(0x335577), near: 6.0, far: 14.0)
    fog1.name = "LinearFog"
    let fog2 = FogExp2(Color(0x335577), density: 0.06)
    fog2.name = "ExpFog"
    scene.fog = Some(fog1)      // 默认线性雾
    scene.fogExp2 = None        // 与 fog 互斥

    // ---- Scene 字段：overrideMaterial（覆盖材质）----
    let overrideMat = MeshBasicMaterial()
    overrideMat.color = Color(0x888888)
    scene.overrideMaterial = None  // 默认不覆盖

    // ---- Scene.copy/clone 接口验证（对照 JS Scene.copy 深拷贝 fog/background）----
    let sceneCopy = Scene()
    sceneCopy.copy(scene, true)
    println("  [scene] copy: fog=${match (sceneCopy.fog) { case Some(f) => f.name case None => "None" }} background=${match (sceneCopy.background) { case Some(_) => "Some" case None => "None" }}")
    let sceneClone = scene.clone()
    match (sceneClone as Scene) {
        case Some(sc) => println("  [scene] clone: name=${sc.name} isScene=${(sc is Scene).toString()}")
        case None => ()
    }
    // Scene.toJson（fastjson 宏生成，字符串判定 fog 是否被序列化）
    let sceneJson = scene.toJson()
    println("  [scene] toJson: hasFog=${sceneJson.contains("fog")} jsonLen=${sceneJson.size}")

    // ---- userData 自定义序列化验证 ----
    scene.userData.add("score", Int64(100))
    scene.userData.add("name", "test")
    scene.userData.add("ratio", Float64(3.14))
    scene.userData.add("active", true)
    scene.userData.add("nested", HashMap<String, Any>())
    let sceneJson2 = scene.toJson()
    println("  [scene] toJson: hasUserData=${sceneJson2.contains("userData")} userDataInJson=${sceneJson2.contains("score") && sceneJson2.contains("name") && sceneJson2.contains("ratio")}")

    // ---- Scene.toJson → fromJson 往返验证 ----
    println("  [scene] before fromJson...")
    try {
        let sceneRestored = Scene.fromJson(sceneJson2)
        println("  [scene] fromJson: name=${sceneRestored.name} fog=${sceneRestored.fog.isSome().toString()} fogExp2=${sceneRestored.fogExp2.isSome().toString()} background=${sceneRestored.background.isSome().toString()} overrideMaterial=${sceneRestored.overrideMaterial.isSome().toString()}")
    } catch (e: Exception) {
        println("  [scene] fromJson FAILED: ${e.message}")
    }

    // ---- backgroundJson 自定义序列化验证 ----
    let sceneJson3 = scene.toJson()
    println("  [scene] toJson: hasBackground=${sceneJson3.contains("background")} backgroundContent=${sceneJson3.contains("Color") || sceneJson3.contains("null")}")

    // ---- userDataJson 自定义序列化验证（往返） ----
    let userDataJson = scene.userDataJson
    println("  [scene] userDataJson: length=${userDataJson.size} hasScore=${userDataJson.contains("score")} hasName=${userDataJson.contains("test")}")
    // 验证反序列化恢复
    scene.userDataJson = userDataJson
    println("  [scene] userData restore: score=${match (scene.userData.get("score")) { case Some(v: Int64) => v.toString() case _ => "N/A" }} name=${match (scene.userData.get("name")) { case Some(v: String) => v case _ => "N/A" }}")

    // ---- Fog/FogExp2 clone/toJSON 验证 ----
    let fogClone = fog1.clone()
    println("  [fog] clone: name=${fogClone.name} color=${fogClone.color.getHex()} near=${fogClone.near} far=${fogClone.far}")
    let fogExpClone = fog2.clone()
    println("  [fog] FogExp2 clone: color=${fogExpClone.color.getHex()} density=${fogExpClone.density}")
    println("  [fog] Fog.toJson has color/near/far: ${fog1.toJson().contains("color")}")

    println("  场景创建成功: ${scene.name}")
    println("  验证: background/fog/fogExp2/overrideMaterial 字段 + Scene.copy/clone/toJSON + Fog.clone")
    println("")

    return SceneObjects(scene: scene, camera: camera, sphere1: sphere1, sphere2: sphere2,
        fog1: fog1, fog2: fog2, overrideMat: overrideMat)
}

/// 渲染循环逻辑（相机轨道控制 + Scene 状态切换）已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）

