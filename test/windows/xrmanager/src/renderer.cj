package xrmanager

/**
 * xrmanager 渲染场景：
 * - 构造 XRManager（关联 renderer）、XRController（inputState 跟踪）、
 *   XRDepthSensing（深度纹理），验证全部公开接口（对照 JS WebXR* 类）
 * - updateCamera / setProjectionFromUnion / updateUserCamera 调用验证（非 Presenting 时无副作用）
 * - 简单球体场景回退渲染 + 画面内 dbgText 显示 XR 状态
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
import three.rendering.ThreeRenderer
import three.rendering.xr.*
import three.rendering.textures.*
import bgfx4cj.bgfx.*
import three.utils.log.Logger
import three.utils.log.LogLevel

/// XRReferenceSpaceType 枚举转字符串（仓颉枚举无内置 ToString）
public func refSpaceStr(rs: XRReferenceSpaceType): String {
    match (rs) {
        case XRReferenceSpaceType.LocalFloor => return "LocalFloor"
        case XRReferenceSpaceType.Local => return "Local"
        case XRReferenceSpaceType.Bounded => return "Bounded"
        case XRReferenceSpaceType.Unbounded => return "Unbounded"
    }
}

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var xrManager: XRManager
    public var controller: XRController
    public var controllerGrip: XRController
    public var depthSensing: XRDepthSensing
    public var sphere: Mesh

    public init(scene!: Scene, camera!: PerspectiveCamera, xrManager!: XRManager,
                controller!: XRController, controllerGrip!: XRController,
                depthSensing!: XRDepthSensing, sphere!: Mesh) {
        this.scene = scene
        this.camera = camera
        this.xrManager = xrManager
        this.controller = controller
        this.controllerGrip = controllerGrip
        this.depthSensing = depthSensing
        this.sphere = sphere
    }
}

/// 创建场景：XR 管理器/控制器/深度感知构造 + 接口验证 + 球体
public func createScene(width: Int32, height: Int32, renderer: ThreeRenderer): SceneObjects {
    Logger.setLevel(LogLevel.Debug)

    let scene = Scene()
    scene.name = "XRScene"

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

    // ================= xr 接口验证 =================

    // ---- 1. XRManager（对照 JS WebXRManager）----
    let xrManager = XRManager(renderer)
    println("  [xr] XRManager: isXRPresenting=${xrManager.isXRPresenting()}")
    xrManager.setReferenceSpaceType(XRReferenceSpaceType.LocalFloor)
    println("  [xr] setReferenceSpaceType(LocalFloor) → get=${refSpaceStr(xrManager.getReferenceSpaceType())}")
    xrManager.setFramebufferScaleFactor(0.8)
    xrManager.setFoveation(0.5)
    println("  [xr] foveation=${xrManager.getFoveation()} envBlend=${xrManager.getEnvironmentBlendMode()}")
    xrManager.setEnabled(true)
    println("  [xr] setEnabled(true) OK")
    let xrCam = xrManager.getCamera()
    println("  [xr] getCamera: isArrayCamera=${(xrCam is ArrayCamera).toString()} kind=${xrCam.kind}")
    let ctrl0 = xrManager.getController(0)
    println("  [xr] getController(0): spaceType=${ctrl0.spaceType}")
    let grip0 = xrManager.getControllerGrip(0)
    println("  [xr] getControllerGrip(0): spaceType=${grip0.spaceType}")
    let hand0 = xrManager.getHand(0)
    println("  [xr] getHand(0): spaceType=${hand0.spaceType}")
    // updateCamera（非 presenting 无副作用）+ 私有联合投影/用户相机更新调用路径
    xrManager.updateCamera(camera)
    println("  [xr] updateCamera(non-presenting) OK")
    // 会话接口（无 XR 设备，验证不崩溃）
    xrManager.requestSession("immersive-vr")
    println("  [xr] requestSession(immersive-vr) → presenting=${xrManager.isXRPresenting()}")
    // 注意：此处保留 presenting=true（不 endSession），
    // 渲染循环将用 ArrayCamera（左右眼）渲染双眼画面；endSession 放循环结束后验证。

    // ---- 2. XRController（对照 JS WebXRController）----
    let controller = XRController()
    // connect/disconnect/update 需 inputSource 等参数（对照 JS: controller.connect(inputSource)）
    let fakeInput = "fake-input-source"
    controller.connect(fakeInput)
    let raySpace0 = controller.getTargetRaySpace()
    println("  [xr] Controller: connect() raySpace.visible=${raySpace0.visible} hasInputSource=${raySpace0.hasInputSource}")
    controller.disconnect(fakeInput)
    let raySpace1 = controller.getTargetRaySpace()
    println("  [xr] Controller: disconnect() hasInputSource=${raySpace1.hasInputSource}")
    controller.update(fakeInput, "frame", "refSpace")
    let raySpace2 = controller.getTargetRaySpace()
    println("  [xr] Controller: update() spaceType=${raySpace2.spaceType} inputState=${raySpace2.inputState.size}")
    let raySpace = controller.getTargetRaySpace()
    let gripSpace = controller.getGripSpace()
    let handSpace = controller.getHandSpace()
    println("  [xr] Controller spaces: targetRay=${raySpace.spaceType} grip=${gripSpace.spaceType} hand=${handSpace.spaceType}")

    // ---- 3. XRDepthSensing（对照 JS WebXRDepthSensing）----
    let depthSensing = XRDepthSensing()
    println("  [xr] DepthSensing: isAvailable=${depthSensing.isAvailable()}")
    // setTexture 需 bgfx TextureHandle（对照 JS: WebXRDepthSensing.setDepthTexture）
    let depthTexHandle = TextureHandle(2u16)
    depthSensing.setTexture(depthTexHandle)
    println("  [xr] DepthSensing: setTexture OK")
    let depthMesh = depthSensing.getMesh()
    println("  [xr] DepthSensing: getMesh=${match (depthMesh) { case Some(m) => "Some" case None => "None" }}")
    depthSensing.update(0.1, 100.0, 64, 64)
    depthSensing.reset()
    depthSensing.dispose()
    println("  [xr] DepthSensing: update/reset/dispose OK")

    println("  场景创建成功: ${scene.name}")
    println("  验证: XRManager/Controller/DepthSensing 全部公开接口")
    println("")

    return SceneObjects(scene: scene, camera: camera, xrManager: xrManager,
        controller: controller, controllerGrip: controller, depthSensing: depthSensing, sphere: sphere)
}

