package geometries

/**
 * test_geometries 渲染场景（v2 生命周期模式）：
 * - 场景内创建全部 geometries（22 个），围成一圈（360° 平均分布）
 * - 几何体绕圆心（相机）公转（速度减半）+ 每个几何体自传（绕自身轴）
 * - 相机位于圆心：鼠标左键拖动旋转相机朝向（自转——非绕他物）；滚轮缩放
 * - 场景内无法渲染文本（仓颉无 Canvas 文字 API）——改为每帧检测相机命中的
 *   模型并在窗口标题栏显示其名字
 *
 * 说明：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
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
import three.rendering.geometry.LineCurve3
import three.rendering.geometry.Shape
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.BgfxRenderer
import three.utils.constants.DoubleSide

/// 几何体围圈半径与数量
public let ORBIT_RADIUS: Float64 = 9.0
public let GEOM_COUNT: Int64 = 22

/// 各几何体圆周角（公转角度）
public let geomAngles = Array<Float64>(GEOM_COUNT, { _ => 0.0 })

/// 几何体名称（与 createGeometryByIndex 索引对应）
let geomNames = [
    "Box", "Capsule", "Circle", "Cone", "Cylinder", "Dodecahedron",
    "Edges", "Extrude", "Icosahedron", "Lathe", "Octahedron", "Plane",
    "Polyhedron", "Ring", "Shape", "Sphere", "Tetrahedron", "Torus",
    "TorusKnot", "Tube", "Wireframe", "Box2"
]

/// 相机鼠标控制状态（水平角/俯仰角——自转朝向）
public var orbitTheta: Float64 = 0.0
public var orbitPhi: Float64 = 0.0

/// 创建场景：所有 geometries 围一圈（360° 平均分）+ 相机位于圆心
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Object3D>) {
    let scene = Scene()
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 200.0)
    // 相机位于圆心且与几何体同平面（y=0）——水平射线才能命中围圈的几何体（高度匹配）
    camera.position.set(0.0, 0.0, 0.0)

    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.35)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(8.0, 12.0, 8.0)
    scene.add(dirLight)

    // 固定色板（循环给几何体上色）
    let palette = [Color(0xff4444), Color(0x44ff44), Color(0x4488ff), Color(0xffff44), Color(0xff44ff), Color(0x44ffff), Color(0xffffff)]
    let objects = ArrayList<Object3D>()
    let baseAngle = PI * 2.0 / Float64(GEOM_COUNT)
    for (i in 0..GEOM_COUNT) {
        let color = palette[i % 7]
        let geometry = createGeometryByIndex(i)
        geometry.computeBoundingSphere()

        // EdgesGeometry / WireframeGeometry 是线段数据（每 2 顶点一条独立线段，无 index），
        // 必须用 LineSegments + LineBasicMaterial 渲染；
        // 用 Mesh + MeshPhongMaterial 时 bgfx 按 TriangleList 解释顶点 → 实心面闪烁。
        let isLine: Bool = (i == 6 || i == 20)
        let obj: Object3D = if (isLine) {
            let lineMat = LineBasicMaterial()
            lineMat.color = color
            LineSegments(geometry: geometry, material: lineMat)
        } else {
            let material = MeshPhongMaterial()
            material.color = color
            // 双面渲染：相机在圆心看几何体内侧（背面）——需 DoubleSide 才可见且可被 raycast 命中
            material.side = DoubleSide
            Mesh(geometry: geometry, material: material)
        }
        obj.name = geomNames[i]
        // 360° 平均分布
        geomAngles[i] = baseAngle * Float64(i)
        obj.position.set(ORBIT_RADIUS * sin(geomAngles[i]), 0.0, ORBIT_RADIUS * cos(geomAngles[i]))
        objects.add(obj)
        scene.add(obj)
    }
    return (scene, camera, objects)
}

/// 按索引创建几何体（22 个 geometries 全量覆盖）
func createGeometryByIndex(i: Int64): BufferGeometry {
    match (i) {
        case 0 => return BoxGeometry()
        case 1 => return CapsuleGeometry()
        case 2 => return CircleGeometry()
        case 3 => return ConeGeometry()
        case 4 => return CylinderGeometry()
        case 5 => return DodecahedronGeometry()
        case 6 => return EdgesGeometry(BoxGeometry())
        case 7 => return ExtrudeGeometry()
        case 8 => return IcosahedronGeometry()
        case 9 => return LatheGeometry([Vector2(0.0, 0.0), Vector2(0.5, 1.0), Vector2(0.0, 2.0)])
        case 10 => return OctahedronGeometry()
        case 11 => return PlaneGeometry()
        case 12 => return PolyhedronGeometry(vertices: [1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0], indices: [2, 1, 0, 0, 3, 2, 1, 3, 0, 2, 3, 1])
        case 13 => return RingGeometry()
        case 14 => return ShapeGeometry(Shape([Vector3(0.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0), Vector3(2.0, 2.0, 0.0), Vector3(0.0, 2.0, 0.0)]))
        case 15 => return SphereGeometry()
        case 16 => return TetrahedronGeometry()
        case 17 => return TorusGeometry()
        case 18 => return TorusKnotGeometry()
        case 19 => return TubeGeometry(LineCurve3(v1: Vector3(0.0, 0.0, 0.0), v2: Vector3(1.0, 0.0, 0.0)))
        case 20 => return WireframeGeometry(BoxGeometry())
        case _ => return BoxGeometry()
    }
}
