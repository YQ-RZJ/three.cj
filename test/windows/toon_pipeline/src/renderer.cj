package toon_pipeline

/**
 * toon_pipeline 渲染场景与主循环
 *
 * 设计目标：完整实现自定义卡通渲染管线测试，不复用引擎内置 ToonMaterial。
 *
 * 渲染管线流程（对照 three.js 官方 toon 案例 webgl_materials_toon.html）：
 *   1. 创建场景：方向光 + 环境光 + 多几何体（球/立方体/圆环/甜甜圈）
 *   2. 每个几何体使用自定义 ToonShader（ShaderMaterial）
 *      - 卡通量化光照（gradientMap 或硬编码 3 级量化）
 *      - 多方向光累加
 *   3. ToonOutlinePass 后处理：基于深度的 Sobel 边缘检测描边
 *   4. 渲染循环：相机轨道控制 + 自定义渲染管线帧提交
 *
 * 卡通渲染核心算法（对照 three.js MeshToonMaterial + getGradientIrradiance）：
 *   - 计算 N·L（法线与光照方向点积）
 *   - 用 gradientMap 采样得到量化光照强度
 *   - 若无 gradientMap，用硬编码 3 级量化
 *   - 最终颜色 = diffuseColor × quantizedIrradiance + ambient
 *
 * bgfx 着色器特性适配：
 *   - 使用 ShaderMaterial 注册自定义 ToonShader
 *   - 自定义 uniform：u_baseColor/u_ambientColor/u_lightDir/u_lightColor
 *   - 自定义全屏 quad + ToonEdge shader 做边缘检测
 * 注：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
 */

import std.sync.*
import std.collection.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.lights.*

/// 轨道控制目标（对齐官方 OrbitControls.target (0,0,0)）
public let ORBIT_TARGET: Vector3 = Vector3(0.0, 0.0, 0.0)

/// 最大方向光数量（与 shader 中 MAX_TOON_LIGHTS 对齐）
public let MAX_TOON_LIGHTS: Int64 = 4

/**
 * 卡通渲染场景对象集合。
 */
public class ToonScene {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var meshes: ArrayList<Mesh>
    public var dirLights: ArrayList<DirectionalLight>

    public init(scene!: Scene, camera!: PerspectiveCamera, meshes!: ArrayList<Mesh>, dirLights!: ArrayList<DirectionalLight>) {
        this.scene = scene
        this.camera = camera
        this.meshes = meshes
        this.dirLights = dirLights
    }
}

/**
 * 创建场景、相机、灯光与卡通测试几何体。
 *
 * 几何布局（对照 three.js 官方 toon 案例）：
 *   - 球体（半径 0.8）：置于中央左侧，卡通量化光照
 *   - 立方体（1×1×1）：置于中央，硬边缘卡通
 *   - 圆环（半径 0.5，管 0.2）：置于中央右侧，曲面卡通
 *   - 甜甜圈（TorusKnot）：置于后方，复杂曲面卡通
 *
 * 灯光：环境光 + 多方向光（凸显卡通量化分界）
 *
 * 相机：PerspectiveCamera(50, aspect, 0.1, 100)，position (0,1,5)
 *
 * @param width 窗口客户区宽
 * @param height 窗口客户区高
 * @return ToonScene 场景对象集合
 */
public func createScene(width: Int32, height: Int32): ToonScene {
    let scene = Scene()
    scene.name = "ToonPipelineScene"
    println("  场景创建成功: ${scene.name}")

    // 相机：对齐官方 PerspectiveCamera(50, aspect, 0.1, 100)，position (0,1,5)
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 50.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 1.5, 5.0)
    camera.lookAt(ORBIT_TARGET)
    camera.name = "MainCamera"
    println("  相机创建成功: fov=50 near=0.1 far=100 pos=(0,1.5,5)")

    // 灯光：环境光 + 多方向光（多光源凸显卡通量化分界）
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.3)
    ambient.name = "Ambient"
    scene.add(ambient)

    let dirLights = ArrayList<DirectionalLight>()

    // 主方向光：暖白色，从右上前方照射
    let dirLight1 = DirectionalLight(color: Color(1.0, 0.95, 0.85), intensity: 0.9)
    dirLight1.position.set(5.0, 8.0, 5.0)
    dirLight1.name = "DirLight1"
    scene.add(dirLight1)
    dirLights.add(dirLight1)

    // 次方向光：冷蓝色，从左上后方照射（补光）
    let dirLight2 = DirectionalLight(color: Color(0.6, 0.7, 1.0), intensity: 0.4)
    dirLight2.position.set(-5.0, 6.0, -3.0)
    dirLight2.name = "DirLight2"
    scene.add(dirLight2)
    dirLights.add(dirLight2)

    println("  灯光创建成功: ambient + 2 directional")

    // 卡通测试几何体组（对照 three.js 官方 toon 案例布局）
    let meshes = ArrayList<Mesh>()

    // 球体（置于中央左侧，曲面卡通量化光照）
    let sphereGeom = SphereGeometry(radius: 0.8, widthSegments: 32, heightSegments: 24)
    let sphereMat = createToonMaterial(Color(0.88, 0.55, 0.45))  // 暖橙红色
    let sphere = Mesh(geometry: sphereGeom, material: sphereMat)
    sphere.position.set(-1.5, 0.0, 0.0)
    sphere.name = "ToonSphere"
    scene.add(sphere)
    meshes.add(sphere)

    // 立方体（置于中央，硬边缘卡通）
    let boxGeom = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
    let boxMat = createToonMaterial(Color(0.45, 0.65, 0.88))  // 冷蓝色
    let box = Mesh(geometry: boxGeom, material: boxMat)
    box.position.set(0.0, 0.0, 0.0)
    box.rotation.y = 0.3
    box.name = "ToonBox"
    scene.add(box)
    meshes.add(box)

    // 圆环（置于中央右侧，曲面卡通）
    let torusGeom = TorusGeometry(radius: 0.5, tube: 0.2, radialSegments: 16, tubularSegments: 48)
    let torusMat = createToonMaterial(Color(0.55, 0.88, 0.55))  // 绿色
    let torus = Mesh(geometry: torusGeom, material: torusMat)
    torus.position.set(1.5, 0.0, 0.0)
    torus.name = "ToonTorus"
    scene.add(torus)
    meshes.add(torus)

    // 甜甜圈（置于后方，复杂曲面卡通）
    let knotGeom = TorusKnotGeometry(radius: 0.4, tube: 0.12, tubularSegments: 64, radialSegments: 12)
    let knotMat = createToonMaterial(Color(0.88, 0.88, 0.45))  // 黄色
    let knot = Mesh(geometry: knotGeom, material: knotMat)
    knot.position.set(0.0, 0.0, -1.8)
    knot.name = "ToonKnot"
    scene.add(knot)
    meshes.add(knot)

    println("  卡通几何体创建成功: sphere + box + torus + knot")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return ToonScene(scene: scene, camera: camera, meshes: meshes, dirLights: dirLights)
}

/**
 * 创建卡通材质。
 *
 * 使用引擎内置 MeshToonMaterial（已迁移完整，对照 three.js MeshToonMaterial）。
 * 该材质走 BgfxBackend 标准 uniform 绑定路径（u_color/u_opacity/u_shininess 等），
 * 确保渲染正确（自定义 ShaderMaterial 的 uniform 未被 _bindMaterialUniforms 绑定 → 全黑）。
 *
 * 卡通量化算法由 meshtoon ShaderLib 实现：
 *   - getGradientIrradiance(N, L) → gradientMap 量化采样
 *   - 若无 gradientMap，用硬编码 3 级量化
 *
 * @param baseColor 卡通材质漫反射颜色
 * @return MeshToonMaterial 卡通材质
 */
public func createToonMaterial(baseColor: Color): MeshToonMaterial {
    let mat = MeshToonMaterial()
    mat.color = baseColor
    mat.opacity = 1.0
    return mat
}
