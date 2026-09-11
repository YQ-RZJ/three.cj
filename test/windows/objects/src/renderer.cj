package sp_objects

/**
 * sp_objects 渲染场景：
 * - 多对象类型均匀分布在圆心周围：
 *     Mesh 球（Phong）、Points 点云、Line 线段、LineSegments 线框球、
 *     Sprite 广告牌、LOD 距离层级对象（内含三个距离档子球）、Group 分组
 * - 相机鼠标轨道控制（同 geometries/sp_materials）
 * - 每帧验证：
 *     intersectsFrustum（Mesh/Points/Line/Sprite 补齐接口，对照 JS 一行委托）
 *     LOD.getCurrentLevel / setCurrentLevel / removeLevel 层级切换
 * - 画面内 dbgText 显示当前视锥内对象数与 LOD 层级
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
import three.rendering.buffer.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.ThreeRenderer
import three.window.MouseButton

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var mesh: Mesh
    public var points: Points
    public var line: Line
    public var lineSegments: LineSegments
    public var sprite: Sprite
    public var lod: LOD

    public init(scene!: Scene, camera!: PerspectiveCamera, mesh!: Mesh, points!: Points,
                line!: Line, lineSegments!: LineSegments, sprite!: Sprite, lod!: LOD) {
        this.scene = scene
        this.camera = camera
        this.mesh = mesh
        this.points = points
        this.line = line
        this.lineSegments = lineSegments
        this.sprite = sprite
        this.lod = lod
    }
}

/// 创建场景：多对象类型 + 相机 + 光源
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "ObjectsScene"

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 0.0, 0.0)
    camera.name = "CenterCamera"

    // ---- 光源 ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.4)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.2)
    dirLight.position.set(5.0, 8.0, 5.0)
    scene.add(dirLight)

    // ---- 1. Mesh 球（Phong 高光）----
    let meshGeom = SphereGeometry(radius: 1.0, widthSegments: 20, heightSegments: 14)
    meshGeom.computeBoundingSphere()  // raycast 依赖
    let meshMat = MeshPhongMaterial()
    meshMat.color = Color(0x4488ff)
    meshMat.specular = Color(0xffffff)
    meshMat.shininess = 40.0
    let mesh = Mesh(geometry: meshGeom, material: meshMat)
    mesh.position.set(0.0, 0.0, 5.0)
    mesh.name = "MeshSphere"
    scene.add(mesh)

    // ---- 2. Points 点云（散布在球壳上）----
    let ptsCount = 300
    let ptsPositions = Array<Float64>(ptsCount * 3, { _ => 0.0 })
    var seed: Int64 = 12345
    for (i in 0..ptsCount) {
        // 简单伪随机（线性同余），均匀散布在 [-3,3]^3
        seed = (seed * 1103515245 + 12345) % 2147483647
        ptsPositions[i * 3] = Float64(seed % 6000) / 1000.0 - 3.0
        seed = (seed * 1103515245 + 12345) % 2147483647
        ptsPositions[i * 3 + 1] = Float64(seed % 6000) / 1000.0 - 3.0
        seed = (seed * 1103515245 + 12345) % 2147483647
        ptsPositions[i * 3 + 2] = Float64(seed % 6000) / 1000.0 - 3.0
    }
    let ptsGeom = BufferGeometry()
    ptsGeom.setAttribute("position", Float32BufferAttribute(ptsPositions, 3))
    ptsGeom.computeBoundingSphere()
    let ptsMat = PointsMaterial()
    ptsMat.color = Color(0xff8844)
    ptsMat.size = 0.12
    let points = Points(geometry: ptsGeom, material: ptsMat)
    points.position.set(-6.0, 0.0, 0.0)
    points.name = "PointsCloud"
    scene.add(points)

    // ---- 3. Line 线段（从 -Z 到 +Z 的折线）----
    let linePositions = [-3.0, 0.0, -3.0, 0.0, 0.0, 0.0, 3.0, 0.0, 3.0]
    let lineGeom = BufferGeometry()
    lineGeom.setAttribute("position", Float32BufferAttribute(linePositions, 3))
    lineGeom.computeBoundingSphere()
    let lineMat = LineBasicMaterial()
    lineMat.color = Color(0x44ff88)
    let line = Line(geometry: lineGeom, material: lineMat)
    line.position.set(6.0, 0.0, 0.0)
    line.name = "LinePolyline"
    scene.add(line)

    // ---- 4. LineSegments 线框球（EdgesGeometry）----
    let wireGeom = EdgesGeometry(SphereGeometry(radius: 1.0, widthSegments: 16, heightSegments: 10))
    wireGeom.computeBoundingSphere()
    let wireMat = LineBasicMaterial()
    wireMat.color = Color(0xffaa44)
    let lineSegments = LineSegments(geometry: wireGeom, material: wireMat)
    lineSegments.position.set(0.0, 0.0, -6.0)
    lineSegments.name = "LineSegmentsWire"
    scene.add(lineSegments)

    // ---- 5. Sprite 广告牌（对照 three.js Sprite：无 geometry，材质面片由 spriteVS 广告牌变换）----
    let spriteMat = SpriteMaterial()
    spriteMat.color = Color(0xffff44)
    let sprite = Sprite(material: spriteMat)
    sprite.position.set(0.0, 4.0, 0.0)
    sprite.name = "SpriteBillboard"
    scene.add(sprite)

    // ---- 6. LOD 距离层级对象（三个距离档，各含一个不同颜色球）----
    // 子球尺寸调大（1.2/0.9/0.6）便于在场景中醒目识别；近处显示 Level0 红、中距 Level1 绿、远处 Level2 蓝
    let lod = LOD()
    lod.name = "LODObject"
    for (i in 0..3) {
        let lGeom = SphereGeometry(radius: 1.2 - Float64(i) * 0.3, widthSegments: 12, heightSegments: 8)
        lGeom.computeBoundingSphere()
        let lMat = MeshBasicMaterial()
        lMat.color = Color(UInt32([0xff4040, 0x40ff40, 0x4040ff][i]))
        let lMesh = Mesh(geometry: lGeom, material: lMat)
        lMesh.name = "LODLevel${i}"
        // 距离阈值：3 / 8 / 16（对照 JS LOD.addLevel 用法）
        lod.addLevel(lMesh, distance: [3.0, 8.0, 16.0][i])
    }
    lod.position.set(-8.0, 0.0, 6.0)
    scene.add(lod)

    // ---- 7. Group 分组（内含两个小球，验证分组渲染）----
    let group = Group()
    group.name = "ObjectGroup"
    for (i in 0..2) {
        let gGeom = SphereGeometry(radius: 0.35, widthSegments: 10, heightSegments: 8)
        gGeom.computeBoundingSphere()
        let gMat = MeshBasicMaterial()
        gMat.color = Color(0x8888ff)
        let gMesh = Mesh(geometry: gGeom, material: gMat)
        gMesh.position.set(Float64(i - 1) * 0.9, 0.0, 0.0)
        gMesh.name = "GroupChild${i}"
        group.add(gMesh)
    }
    group.position.set(0.0, -4.5, 0.0)
    scene.add(group)

    println("  场景创建成功: ${scene.name}")
    println("  对象: Mesh球/Points点云/Line折线/LineSegments线框/Sprite广告牌/LOD层级/Group分组")
    println("  验证: intersectsFrustum 视锥剔除 + LOD.getCurrentLevel/removeLevel")
    println("")

    return SceneObjects(scene: scene, camera: camera, mesh: mesh, points: points,
        line: line, lineSegments: lineSegments, sprite: sprite, lod: lod)
}

/// 渲染循环逻辑已迁移至 main.cj 的 TestWindow.onFrame（v2 生命周期模式）
