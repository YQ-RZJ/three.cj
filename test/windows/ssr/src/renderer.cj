package sp_ssr

/**
 * sp_ssr 渲染场景（对照 three.js 官方案例 webgl_postprocessing_ssr.html）：
 * - 场景：开放盒子（内壁反射）+ 地板 + 球体 + 立方体，提供典型反射几何
 * - 相机：PerspectiveCamera(50, aspect, near=0.1, far=100)，position (0,1.5,5)，target (0,1,0)
 * - 灯光：环境光 + 方向光 + 点光（多光源凸显反射差异）
 * - SSR 参数对齐官方案例：
 *     opacity=0.5, maxDistance=180, thickness=0.018, blur=true,
 *     distanceAttenuation=true, fresnel=true, infiniteThick=false
 *
 * 渲染循环（v2 生命周期模式）：
 * - EffectComposer：RenderPass → SSRPass
 * - 鼠标拖动 + 滚轮：相机围绕 target 公转（OrbitControls 等价）
 * - 按键交互：实时调整 SSR 各参数与 OUTPUT 调试模式
 * （渲染循环已移入 main.cj 的 TestWindow.onFrame，窗口泵线程驱动）
 */

import std.sync.*
import std.math.*
import std.collection.*
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
import three.scene.entity.GroundReflector

/// 轨道控制目标（对齐官方 OrbitControls.target (0,1,0)）
public let ORBIT_TARGET: Vector3 = Vector3(0.0, 1.0, 0.0)

// ===== 键盘交互状态（原 win32.cj，迁移至 WindowEngine 输入） =====
public var g_outputMode: Int64 = 0
public var g_outputDirty = AtomicBool(true)
public var g_blur: Bool = true
public var g_blurDirty = AtomicBool(true)
public var g_fresnel: Bool = true
public var g_fresnelDirty = AtomicBool(true)
public var g_distanceAttenuation: Bool = true
public var g_distanceAttenuationDirty = AtomicBool(true)
public var g_infiniteThick: Bool = false
public var g_infiniteThickDirty = AtomicBool(true)
public var g_debug: Bool = false
public var g_debugDirty = AtomicBool(true)
public var g_opacity: Float64 = 0.5
public var g_opacityDirty = AtomicBool(true)
public var g_maxDistance: Float64 = 180.0
public var g_maxDistanceDirty = AtomicBool(true)
public var g_thickness: Float64 = 0.018
public var g_thicknessDirty = AtomicBool(true)

/**
 * 创建场景、相机、灯光与反射测试几何体。
 *
 * 几何布局（无盒子场景：地面反射器 + 三个模型）：
 *   - 地面反射器（PlaneGeometry 水平放置，法线朝上 +Y）：平面反射贴图投影到地面
 *   - 球体（半径 0.6）：置于地面中央上方，反射在地面
 *   - 立方体（1×1×1）：置于一侧，反射在地面
 *   - 圆环：另一侧，增加曲面反射细节
 */
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Group, GroundReflector) {
    let scene = Scene()
    scene.name = "SSRScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：对齐官方 PerspectiveCamera(50, aspect, 0.1, 100)，position (0,1.5,5)
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 1.5, 5.0)
    camera.lookAt(ORBIT_TARGET)
    camera.name = "MainCamera"
    println("  相机创建成功: fov=50 near=0.1 far=100 pos=(0,1.5,5)")

    // 灯光：环境光 + 方向光 + 点光（多光源凸显反射差异）
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.4)
    ambient.name = "Ambient"
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(5.0, 10.0, 7.0)
    dirLight.name = "DirLight"
    scene.add(dirLight)
    let pointLight = PointLight(color: Color(0xffaa44), intensity: 0.6, distance: 20.0)
    pointLight.position.set(-3.0, 2.5, 2.0)
    pointLight.name = "PointLight"
    scene.add(pointLight)
    println("  灯光创建成功: ambient + directional + point")

    // 反射测试几何体组
    let group = Group()
    group.name = "SSRSceneGroup"

    // 普通地面（兜底可见层，对齐官方 webgl_postprocessing_ssr.html）：
    //   官方场景 = 普通灰色 plane（MeshPhongMaterial 0xcbcbcb）+ groundReflector 叠加
    //   （GroundReflector，depthWrite=false）。反射器在地面片元处采样反射深度 RT
    //   时背景为 far → worldPosition.y 超 maxDistance → discard（反射器自身透明），
    //   若没有普通地面兜底，地面将完全不可见。故恢复普通地面作为基础层。
    //   普通地面直接 scene.add（不进 group，保持 group 顺序 groundReflector=0/
    //   sphere=1/box=2/torus=3，selects 用 [1][2][3] 不变）。
    let groundMat = MeshPhongMaterial()
    groundMat.color = Color(0xcb, 0xcb, 0xcb)
    let groundPlane = Mesh(geometry: PlaneGeometry(width: 9.0, height: 9.0), material: groundMat)
    groundPlane.rotation.x = -3.141592653589793 / 2.0
    // ★z-fighting 修复：普通地面 y=-0.07，反射器 y=-0.05（在上方 0.02）。
    //   若两者同平面（同为 y=-0.05），bgfx 深度测试 DEPTH_TEST_LESS（严格小于）下
    //   反射器片元深度等于 GroundPlane → 深度测试失败 → 反射器被完全丢弃，
    //   地面只显示普通灰色、无反射效果（three.js 默认 LessEqual 且透明后渲才能重叠显示）。
    groundPlane.position.set(0.0, -0.07, 0.0)
    groundPlane.name = "GroundPlane"
    scene.add(groundPlane)

    // 地面反射器（对照官方 webgl_postprocessing_ssr.html groundReflector）：
    //   GroundReflector(PlaneGeometry, { textureWidth, textureHeight, color, useDepthTexture })
    //   - 地面平面反射（镜像相机渲场景到反射 RT，ReflectorShader 经 textureMatrix 投影到地面）
    //   - PlaneGeometry 绕 X 轴 -90° 旋转成水平面（法线朝上 +Y），镜像 normal=(0,0,1)→(0,1,0)
    //   - 对齐官方：material.depthWrite = false（叠加在普通地面上，不写深度防 z-fighting）
    //   - ★尺寸必须与普通地面完全一致（官方复用同一 geometry，9×9）：
    //     此前反射器用 8×8，导致倒影范围比地面小一圈，地面矩形外围有一圈
    //     普通地面色（0xcbcbcb）与内部倒影矩形（blendOverlay 混合色）不一致。
    //   - group.add 顺序 groundReflector=0/sphere=1/box=2/torus=3，selects 用 [1][2][3]
    let groundGeom = PlaneGeometry(width: 9.0, height: 9.0)
    let groundReflector = GroundReflector(
        groundGeom,
        textureWidth: Int64(width),
        textureHeight: Int64(height),
        color: Color(0x88, 0x88, 0x88),
        clipBias: 0.0,
        useDepthTexture: true
    )
    groundReflector.material.depthWrite = false
    groundReflector.rotation.x = -3.141592653589793 / 2.0
    groundReflector.position.set(0.0, -0.05, 0.0)
    groundReflector.name = "GroundReflector"
    group.add(groundReflector)

    // 球体（置于地面中央上方，反射在地面）
    let sphereMat = MeshPhongMaterial()
    sphereMat.color = Color(0xcc5555)
    sphereMat.shininess = 80.0
    let sphere = Mesh(geometry: SphereGeometry(radius: 0.6, widthSegments: 32, heightSegments: 24), material: sphereMat)
    sphere.position.set(0.0, 0.9, 0.0)
    sphere.name = "Sphere"
    group.add(sphere)

    // 立方体（置于一侧，反射在地面）
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0x5588cc)
    boxMat.shininess = 60.0
    let box = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.0, depth: 1.0), material: boxMat)
    box.position.set(2.0, 0.5, -1.0)
    box.name = "Box"
    group.add(box)

    // 圆环（另一侧，曲面反射细节）
    let torusMat = MeshPhongMaterial()
    torusMat.color = Color(0x55cc88)
    torusMat.shininess = 100.0
    let torus = Mesh(geometry: TorusGeometry(radius: 0.4, tube: 0.15, radialSegments: 16, tubularSegments: 48), material: torusMat)
    torus.position.set(-2.0, 0.7, 1.0)
    torus.name = "Torus"
    group.add(torus)

    scene.add(group)
    println("  反射场景创建成功: groundReflector + sphere + box + torus")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, group, groundReflector)
}
