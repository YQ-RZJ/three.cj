package sp_shadowfrustum

/**
 * sp_shadowfrustum 渲染场景：
 * - 方向光带阴影，光源跟随摄像头位置
 * - 悬浮立方体（caster）+ 地面平面（receiver）
 * - 阴影视锥线框盒：展示正交相机 left/right/top/bottom/near/far 在世界空间的位置
 *
 * 目的：从任意视角观察阴影相机的视锥是否覆盖了立方体+地面
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
import three.rendering.buffer.*
import three.rendering.cameras.*
import three.rendering.lights.*

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var cube: Mesh
    public var dirLight: DirectionalLight
    public var frustumMeshes: ArrayList<Mesh>  // 阴影视锥多个面

    public init(scene!: Scene, camera!: PerspectiveCamera, cube!: Mesh, dirLight!: DirectionalLight, frustumMeshes!: ArrayList<Mesh>) {
        this.scene = scene
        this.camera = camera
        this.cube = cube
        this.dirLight = dirLight
        this.frustumMeshes = frustumMeshes
    }
}

/// 构建 8 个阴影视锥顶点（在光源局部坐标系）
public func buildFrustumCorners(oc: OrthographicCamera): Array<Float64> {
    let l = oc.left; let r = oc.right
    let b = oc.bottom; let t = oc.top
    let n = oc.near; let f = oc.far
    return [
        l, b, n,   r, b, n,   r, t, n,   l, t, n,
        l, b, f,   r, b, f,   r, t, f,   l, t, f,
    ]
}

/// 将光源局部坐标系的 8 个点转换到世界空间
public func transformCornersToWorld(localCorners: Array<Float64>, lightPos: Vector3, lightTarget: Vector3, up: Vector3): Array<Float64> {
    let forward = Vector3()
    forward.copy(lightTarget).sub(lightPos).normalize()
    let right = Vector3().copy(up).cross(forward).normalize()
    let up2 = Vector3().copy(right).cross(forward).normalize()

    let worldCorners = Array<Float64>(24, { _ => 0.0 })
    for (i in 0..8) {
        let ci = i * 3
        let lx = localCorners[ci]
        let ly = localCorners[ci + 1]
        let lz = localCorners[ci + 2]
        let wx = lightPos.x + right.x * lx + up2.x * ly + forward.x * lz
        let wy = lightPos.y + right.y * lx + up2.y * ly + forward.y * lz
        let wz = lightPos.z + right.z * lx + up2.z * ly + forward.z * lz
        worldCorners[ci] = wx
        worldCorners[ci + 1] = wy
        worldCorners[ci + 2] = wz
    }
    return worldCorners
}

/// 创建视锥线框盒：近面(红)、远面(蓝)、侧面(橙半透明)
/// 每个部分独立 Mesh，方便区分
public func createFrustumMeshes(oc: OrthographicCamera): ArrayList<Mesh> {
    let l = oc.left; let r = oc.right
    let b = oc.bottom; let t = oc.top
    let n = oc.near; let f = oc.far

    // 8 个顶点在局部空间
    let corners = [
        l, b, n,   r, b, n,   r, t, n,   l, t, n,   // 0-3: near
        l, b, f,   r, b, f,   r, t, f,   l, t, f,   // 4-7: far
    ]

    /// 从一个面构建 Mesh（使用 BasicMaterial 直接显示颜色，无需法线/光照）
    func buildFace(quadVerts: Array<Int64>, color: Color, opacity: Float64): Mesh {
        let posList = ArrayList<Float64>()
        for (qi in 0..4) {
            let vi = quadVerts[qi]; let ci = vi * 3
            posList.add(corners[ci]); posList.add(corners[ci+1]); posList.add(corners[ci+2])
        }
        let idxList = [0.0, 1.0, 2.0, 0.0, 2.0, 3.0]

        let geom = BufferGeometry()
        geom.setIndex(BufferAttribute(idxList, 1))
        geom.setAttribute("position", BufferAttribute(posList.toArray(), 3))

        let mat = MeshBasicMaterial()
        mat.color = color
        mat.side = 2  // DoubleSide
        if (opacity < 1.0) { mat.transparent = true; mat.opacity = opacity }

        return Mesh(geometry: geom, material: mat)
    }

    let meshes = ArrayList<Mesh>()

    // 近面（红色，半透明 0.6）
    let nearM = buildFace([0, 1, 2, 3], Color(0xff3333), 0.6)
    nearM.name = "FrustumNear"
    meshes.add(nearM)

    // 远面（蓝色，半透明 0.4）
    let farM = buildFace([4, 5, 6, 7], Color(0x3377ff), 0.4)
    farM.name = "FrustumFar"
    meshes.add(farM)

    // 侧面（黄色，半透明 0.25）
    let sides = [
        [0, 4, 7, 3],   // left
        [1, 2, 6, 5],   // right
        [0, 1, 5, 4],   // bottom
        [3, 7, 6, 2],   // top
    ]
    for (sq in sides) {
        let sideM = buildFace(sq, Color(0xffcc00), 0.25)
        sideM.name = "FrustumSide"
        meshes.add(sideM)
    }

    return meshes
}

/// 创建场景
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "ShadowPlaneScene"
    println("  场景创建成功: ${scene.name}")

    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 45.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(5.0, 10.0, 7.5)
    camera.lookAt(Vector3(0.0, 1.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")

    // 环境光
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.2)
    ambient.name = "Ambient"; scene.add(ambient)

    // 方向光
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
    dirLight.position.set(5.0, 10.0, 7.5)
    dirLight.castShadow = true
    dirLight.shadow.mapSize.set(1024.0, 1024.0)
    // 深度偏移：负值消除地面 shadow acne（波浪纹）；
    dirLight.shadow.bias = -0.001
    match (dirLight.shadow.camera) {
        case oc: OrthographicCamera =>
            oc.left = -8.0; oc.right = 8.0
            oc.top = 8.0; oc.bottom = -8.0
            oc.near = 0.5; oc.far = 30.0
            oc.updateProjectionMatrix()
        case _ => ()
    }
    dirLight.name = "DirLight"; scene.add(dirLight)
    println("  方向光创建成功")

    // 地面平面
    let planeMat = MeshPhongMaterial()
    planeMat.color = Color(0x888888); planeMat.specular = Color(0x000000); planeMat.side = 2
    let plane = Mesh(geometry: PlaneGeometry(width: 12.0, height: 12.0), material: planeMat)
    plane.rotation.x = -PI / 2.0
    plane.name = "GroundPlane"; plane.castShadow = false; plane.receiveShadow = true
    scene.add(plane); println("  地面平面创建成功")

    // 悬浮立方体
    let boxMat = MeshPhongMaterial()
    boxMat.color = Color(0x44aaff); boxMat.specular = Color(0x444444); boxMat.shininess = 30.0
    let box = Mesh(geometry: BoxGeometry(width: 1.5, height: 1.5, depth: 1.5), material: boxMat)
    box.position.set(0.0, 2.0, 0.0)
    box.name = "FloatingCube"; box.castShadow = true; box.receiveShadow = false
    scene.add(box); println("  悬浮立方体创建成功")

    // 阴影视锥线框盒（近面红、远面蓝、侧面黄半透明）
    match (dirLight.shadow.camera) {
        case oc: OrthographicCamera =>
            let meshes = createFrustumMeshes(oc)
            for (m in meshes) {
                m.position.copy(dirLight.position)
                m.lookAt(dirLight.target.position)
                scene.add(m)
            }
            println("  阴影视锥线框盒创建成功 (${meshes.size} 个面)")

            println("  场景子对象数: ${scene.children.size}")
            println("")

            return SceneObjects(scene: scene, camera: camera, cube: box, dirLight: dirLight, frustumMeshes: meshes)
        case _ =>
            println("  [WARN] 阴影相机不是 OrthographicCamera")
            return SceneObjects(scene: scene, camera: camera, cube: box, dirLight: dirLight, frustumMeshes: ArrayList<Mesh>())
    }
}
