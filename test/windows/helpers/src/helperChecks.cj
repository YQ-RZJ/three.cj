/**
 * @file helperChecks
 * @brief test_helpers 计算类断言：验证 three.helpers 各辅助对象生成的数据
 *
 * 覆盖（对照 three.js 参考实现）：
 * - AxesHelper: 顶点/颜色数组、vertexColors、setColors
 * - GridHelper: 顶点数、中心线颜色
 * - PolarGridHelper: 顶点数、颜色交替
 * - Box3Helper: updateMatrixWorld 后的 position/scale
 * - BoxHelper: update() 后的 8 个包围盒顶点
 * - ArrowHelper: 线几何体端点、setDirection/setLength 后 quaternion/scale
 * - CameraHelper: pointMap 键集合、setColors 后颜色属性
 * - DirectionalLightHelper: update() 后 targetLine.scale.z = 光→目标距离
 * - HemisphereLightHelper: wireframe、color 属性、update 后 sky/ground 半色
 * - PlaneHelper: fill 材质 transparent/opacity
 * - PointLightHelper: wireframe
 * - SkeletonHelper: bones 列表、setColors 蓝/绿
 * - SpotLightHelper: 锥体几何顶点数（5 侧线 + 32 段圆环）
 */
package test_helpers

import std.collection.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.helpers.*
import three.audio.listener.AudioListener
import three.audio.source.PositionalAudio
import three.physics.body.RigidBody
import three.physics.world.PhysicsWorld
import three.physics.interfaces.*

/// 断言计数（失败数）
var g_failCount: Int64 = 0
var g_checkCount: Int64 = 0

/// 记录一条断言结果
func check(name: String, cond: Bool): Unit {
    g_checkCount += 1
    if (cond) {
        println("  [PASS] ${name}")
    } else {
        g_failCount += 1
        println("  [FAIL] ${name}")
    }
}

/// 取属性数组（Option 展开 + 空数组兜底）
func attrArray(geom: BufferGeometry, name: String): Array<Float64> {
    match (geom.getAttribute(name)) {
        case Some(a) => return a.array
        case None => return Array<Float64>(0, { _ => 0.0 })
    }
}

/// 取属性 count（顶点数）
func attrCount(geom: BufferGeometry, name: String): Int64 {
    match (geom.getAttribute(name)) {
        case Some(a) => return a.count
        case None => return 0
    }
}

/// 运行全部计算类断言，返回是否全部通过
public func runHelperChecks(): Bool {
    println("=== helpers 计算类断言 ===")
    checkAxesHelper()
    checkGridHelper()
    checkPolarGridHelper()
    checkBox3Helper()
    checkBoxHelper()
    checkArrowHelper()
    checkCameraHelper()
    checkDirectionalLightHelper()
    checkHemisphereLightHelper()
    checkPlaneHelper()
    checkPointLightHelper()
    checkSkeletonHelper()
    checkSpotLightHelper()
    checkPositionalAudioHelper()
    checkAudioListenerHelper()
    checkRigidBodyHelper()
    checkConstraintHelper()
    println("  断言总数: ${g_checkCount}  失败: ${g_failCount}")
    return g_failCount == 0
}

// ===== AxesHelper =====

func checkAxesHelper(): Unit {
    let axes = AxesHelper(size: 2.0)
    // 3 轴 × 2 顶点 = 6 顶点 = 18 floats
    check("AxesHelper: 顶点数 == 6", attrCount(axes.geometry, "position") == 6)
    check("AxesHelper: 颜色数 == 6", attrCount(axes.geometry, "color") == 6)
    // 对照 JS: colors = [1,0,0, 1,0.6,0, 0,1,0, 0.6,1,0, 0,0,1, 0,0.6,1]
    let colors = attrArray(axes.geometry, "color")
    check("AxesHelper: X 轴起点红 (1,0,0)", colors.size >= 3 && colors[0] == 1.0 && colors[1] == 0.0 && colors[2] == 0.0)
    check("AxesHelper: X 轴终点渐变 (1,0.6,0)", colors.size >= 6 && colors[3] == 1.0 && colors[4] == 0.6 && colors[5] == 0.0)
    check("AxesHelper: Z 轴终点渐变 (0,0.6,1)", colors.size >= 18 && colors[15] == 0.0 && colors[16] == 0.6 && colors[17] == 1.0)
    // vertexColors 必须开启（对照 JS material.vertexColors: true）
    check("AxesHelper: vertexColors == true", axes.material.vertexColors)
    // setColors 更新颜色
    axes.setColors(Color(1.0, 0.0, 0.0), Color(0.0, 1.0, 0.0), Color(0.0, 0.0, 1.0))
    let colors2 = attrArray(axes.geometry, "color")
    check("AxesHelper: setColors 后 X 轴起点红", colors2[0] == 1.0 && colors2[1] == 0.0 && colors2[2] == 0.0)
    check("AxesHelper: setColors 后 Z 轴终点蓝", colors2[15] == 0.0 && colors2[16] == 0.0 && colors2[17] == 1.0)
}

// ===== GridHelper =====

func checkGridHelper(): Unit {
    let grid = GridHelper(size: 10.0, divisions: 4, color1: Color(0x444444), color2: Color(0x888888))
    // (divisions+1) 条双向线 × 4 顶点 = 20 顶点
    check("GridHelper: 顶点数 == 20", attrCount(grid.geometry, "position") == 20)
    check("GridHelper: 颜色数 == 20", attrCount(grid.geometry, "color") == 20)
    check("GridHelper: vertexColors == true", grid.material.vertexColors)
    // 中心线（i == center == 2）用 color1：第 i 条线 4 顶点 × 3 分量，起始索引 = 2*4*3 = 24
    let colors = attrArray(grid.geometry, "color")
    let c1r = Float64(0x44) / 255.0
    check("GridHelper: 中心线用 color1", abs(colors[24] - c1r) < 0.001)
    // 边缘线（i=0）用 color2 0x888888 → (136/255≈0.5333)
    let c2r = Float64(0x88) / 255.0
    check("GridHelper: 边缘线用 color2", abs(colors[0] - c2r) < 0.001)
}

// ===== PolarGridHelper =====

func checkPolarGridHelper(): Unit {
    let polar = PolarGridHelper(radius: 5.0, sectors: 4, rings: 2, divisions: 8)
    // 径向线 4 条 × 2 顶点 + 圆环 2 圈 × 8 段 × 2 顶点 = 8 + 32 = 40 顶点
    check("PolarGridHelper: 顶点数 == 40", attrCount(polar.geometry, "position") == 40)
    check("PolarGridHelper: vertexColors == true", polar.material.vertexColors)
    // 颜色交替：径向线 i=0 用 color2（偶）、i=1 用 color1（奇）——对照 JS (i&1)?color1:color2
    let colors = attrArray(polar.geometry, "color")
    let c1r = Float64(0x44) / 255.0
    let c2r = Float64(0x88) / 255.0
    // 顶点 2,3（第 2 条径向线 i=1 → color1）
    check("PolarGridHelper: 径向线奇偶交替", abs(colors[6] - c1r) < 0.001)
    // 顶点 0,1（第 1 条径向线 i=0 → color2）
    check("PolarGridHelper: 径向线首条 color2", abs(colors[0] - c2r) < 0.001)
}

// ===== Box3Helper =====

func checkBox3Helper(): Unit {
    let box = Box3().setFromCenterAndSize(Vector3(1.0, 2.0, 3.0), Vector3(4.0, 4.0, 4.0))
    let helper = Box3Helper(box, color: 0xffff00)
    helper.updateMatrixWorld(true)
    // 对照 JS: box.getCenter(position); box.getSize(scale); scale *= 0.5
    check("Box3Helper: position == center (1,2,3)",
        abs(helper.position.x - 1.0) < 1e-9 && abs(helper.position.y - 2.0) < 1e-9 && abs(helper.position.z - 3.0) < 1e-9)
    check("Box3Helper: scale == half size (2,2,2)",
        abs(helper.scale.x - 2.0) < 1e-9 && abs(helper.scale.y - 2.0) < 1e-9 && abs(helper.scale.z - 2.0) < 1e-9)
}

// ===== BoxHelper =====

func checkBoxHelper(): Unit {
    let mesh = Mesh(geometry: BoxGeometry(width: 2.0, height: 2.0, depth: 2.0), material: MeshBasicMaterial())
    mesh.updateMatrixWorld(true)
    let helper = BoxHelper(mesh, color: 0xffff00)
    helper.update()
    // BoxGeometry 尺寸 2 → min=(-1,-1,-1) max=(1,1,1)
    let pos = attrArray(helper.geometry, "position")
    check("BoxHelper: 8 个顶点 (24 floats)", pos.size == 24)
    check("BoxHelper: 顶点0 = max (1,1,1)", pos.size >= 3 && pos[0] == 1.0 && pos[1] == 1.0 && pos[2] == 1.0)
    check("BoxHelper: 顶点1 = (min.x,max.y,max.z) (-1,1,1)", pos.size >= 6 && pos[3] == -1.0 && pos[4] == 1.0 && pos[5] == 1.0)
    check("BoxHelper: 顶点7 = (max.x,min.y,min.z) (1,-1,-1)", pos.size >= 24 && pos[21] == 1.0 && pos[22] == -1.0 && pos[23] == -1.0)
}

// ===== ArrowHelper =====

func checkArrowHelper(): Unit {
    let arrow = ArrowHelper(dir: Vector3(0.0, 0.0, 1.0), origin: Vector3(0.0, 0.0, 0.0), length: 2.0, color: 0xff0000)
    // 对照 JS: _lineGeometry = [0,0,0, 0,1,0]（单位长度线段，靠 scale.y 拉伸）
    let linePos = attrArray(arrow.line.geometry, "position")
    check("ArrowHelper: 线几何体 2 顶点", attrCount(arrow.line.geometry, "position") == 2)
    check("ArrowHelper: 线端点1 = (0,1,0)", linePos.size >= 6 && linePos[3] == 0.0 && linePos[4] == 1.0 && linePos[5] == 0.0)
    // setDirection(+Y) → quaternion 单位 (0,0,0,1)
    arrow.setDirection(Vector3(0.0, 1.0, 0.0))
    check("ArrowHelper: setDirection(+Y) 单位四元数",
        arrow.quaternion.x == 0.0 && arrow.quaternion.y == 0.0 && arrow.quaternion.z == 0.0 && arrow.quaternion.w == 1.0)
    // setLength: line.scale.y = max(0.0001, length - headLength)；cone.position.y = length
    arrow.setLength(2.0, 0.4, 0.2)
    check("ArrowHelper: setLength 线 scale.y == 1.6", abs(arrow.line.scale.y - 1.6) < 1e-9)
    check("ArrowHelper: setLength 锥 position.y == 2.0", abs(arrow.cone.position.y - 2.0) < 1e-9)
    check("ArrowHelper: setLength 锥 scale == (0.2,0.4,0.2)",
        abs(arrow.cone.scale.x - 0.2) < 1e-9 && abs(arrow.cone.scale.y - 0.4) < 1e-9 && abs(arrow.cone.scale.z - 0.2) < 1e-9)
    // 构造颜色（对照 JS: 材质 color 参数）
    check("ArrowHelper: 线材质颜色 == 红", arrow.line.material.color.r == 1.0 && arrow.line.material.color.g == 0.0 && arrow.line.material.color.b == 0.0)
}

// ===== CameraHelper =====

func checkCameraHelper(): Unit {
    let cam = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 10.0)
    cam.updateProjectionMatrix()
    let helper = CameraHelper(cam)
    // pointMap 键集合：n1..n4, f1..f4, p, c, t, u1..u3, cn1..cn4, cf1..cf4 = 22 键
    let expectedKeys = ["n1", "n2", "n3", "n4", "f1", "f2", "f3", "f4", "p", "c", "t",
                        "u1", "u2", "u3", "cn1", "cn2", "cn3", "cn4", "cf1", "cf2", "cf3", "cf4"]
    var allKeys = true
    for (k in expectedKeys) {
        if (!helper.pointMap.contains(k)) { allKeys = false }
    }
    check("CameraHelper: pointMap 含 22 个键", allKeys && helper.pointMap.size == 22)
    // 25 条线 × 2 = 50 顶点
    check("CameraHelper: 顶点数 == 50", attrCount(helper.geometry, "position") == 50)
    // setColors 后颜色非全 0（构造默认已调用）
    let colors = attrArray(helper.geometry, "color")
    var anyNonZero = false
    for (i in 0..colors.size) {
        if (colors[i] != 0.0) { anyNonZero = true }
    }
    check("CameraHelper: setColors 后颜色非全 0", anyNonZero)
    check("CameraHelper: vertexColors == true", helper.material.vertexColors)
}

// ===== DirectionalLightHelper =====

func checkDirectionalLightHelper(): Unit {
    let light = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
    light.position.set(0.0, 5.0, 0.0)
    // target 默认位于原点
    let helper = DirectionalLightHelper(light, size: 1.0)
    helper.update()
    // 对照 JS: targetLine.scale.z = _v3.length()（光→目标距离 = 5）
    check("DirectionalLightHelper: targetLine.scale.z == 5", abs(helper.targetLine.scale.z - 5.0) < 1e-6)
    check("DirectionalLightHelper: 默认颜色取光源色", helper.lightPlane.material.color.r == 1.0)
}

// ===== HemisphereLightHelper =====

func checkHemisphereLightHelper(): Unit {
    let light = HemisphereLight(skyColor: Color(1.0, 0.0, 0.0), groundColor: Color(0.0, 1.0, 0.0), intensity: 1.0)
    let helper = HemisphereLightHelper(light, size: 1.0)
    // 对照 JS: material.wireframe = true
    check("HemisphereLightHelper: wireframe == true", helper.material.wireframe)
    // 构造时已 update()：color 属性前一半 sky 后一半 ground
    let meshOpt = helper.children[0] as Mesh
    var colorAttrOk = false
    var halfSky = false
    var halfGround = false
    match (meshOpt) {
        case Some(mesh) =>
            match (mesh.geometry.getAttribute("color")) {
                case Some(colors) =>
                    colorAttrOk = colors.count > 0
                    if (colors.count >= 2) {
                        halfSky = (colors.getX(0) == 1.0 && colors.getY(0) == 0.0 && colors.getZ(0) == 0.0)
                        halfGround = (colors.getX(colors.count / 2) == 0.0 && colors.getY(colors.count / 2) == 1.0 && colors.getZ(colors.count / 2) == 0.0)
                    }
                case None => ()
            }
        case None => ()
    }
    check("HemisphereLightHelper: color 属性存在", colorAttrOk)
    check("HemisphereLightHelper: 上半 sky 红", halfSky)
    check("HemisphereLightHelper: 下半 ground 绿", halfGround)
}

// ===== PlaneHelper =====

func checkPlaneHelper(): Unit {
    let plane = Plane(Vector3(0.0, 1.0, 0.0), 1.0)
    let helper = PlaneHelper(plane, size: 2.0, hex: 0xffff00)
    // fill 面（children[0]）材质 transparent + opacity 0.2
    var fillOk = false
    if (helper.children.size >= 1) {
        let fillOpt = helper.children[0] as Mesh
        match (fillOpt) {
            case Some(fill) =>
                fillOk = fill.material.transparent && abs(fill.material.opacity - 0.2) < 1e-9
            case None => ()
        }
    }
    check("PlaneHelper: fill 面 transparent+opacity 0.2", fillOk)
    // 线框颜色 = hex 0xffff00
    check("PlaneHelper: 线框颜色黄色", helper.material.color.r == 1.0 && helper.material.color.g == 1.0 && helper.material.color.b == 0.0)
    // updateMatrixWorld：scale = (0.5*size, 0.5*size, 1)
    helper.updateMatrixWorld(true)
    check("PlaneHelper: scale == (1,1,1)", abs(helper.scale.x - 1.0) < 1e-9 && abs(helper.scale.y - 1.0) < 1e-9 && abs(helper.scale.z - 1.0) < 1e-9)
}

// ===== PointLightHelper =====

func checkPointLightHelper(): Unit {
    let light = PointLight(color: Color(1.0, 0.0, 0.0), intensity: 1.0)
    let helper = PointLightHelper(light, sphereSize: 1.0)
    check("PointLightHelper: wireframe == true", helper.material.wireframe)
    // update() 后材质颜色 = 光源色
    check("PointLightHelper: 颜色取光源红", helper.material.color.r == 1.0 && helper.material.color.g == 0.0 && helper.material.color.b == 0.0)
}

// ===== SkeletonHelper =====

func checkSkeletonHelper(): Unit {
    let root = Object3D()
    let b1 = Bone(); let b2 = Bone()
    b1.add(b2)
    root.add(b1)
    let helper = SkeletonHelper(root)
    // bones = [b1, b2]（递归收集；root 不是 Bone）
    check("SkeletonHelper: bones 数 == 2", helper.bones.size == 2)
    // 仅父为 Bone 的连线：b1.parent=root（非 Bone）不连，b2.parent=b1（Bone）连 → 1 线 = 2 顶点
    check("SkeletonHelper: 顶点数 == 2", attrCount(helper.geometry, "position") == 2)
    // setColors 蓝/绿（构造已调用）
    let colors = attrArray(helper.geometry, "color")
    check("SkeletonHelper: 顶点0 蓝", colors.size >= 3 && colors[0] == 0.0 && colors[1] == 0.0 && colors[2] == 1.0)
    check("SkeletonHelper: 顶点1 绿", colors.size >= 6 && colors[3] == 0.0 && colors[4] == 1.0 && colors[5] == 0.0)
}

// ===== SpotLightHelper =====

func checkSpotLightHelper(): Unit {
    let light = SpotLight(color: Color(0xffffff), intensity: 1.0)
    light.position.set(0.0, 5.0, 0.0)
    let helper = SpotLightHelper(light)
    // 5 侧线 × 2 + 32 段圆环 × 2 = 74 顶点
    check("SpotLightHelper: 锥体顶点数 == 74", attrCount(helper.cone.geometry, "position") == 74)
    // update() 后按 distance/angle 缩放锥体
    light.distance = 10.0
    light.angle = 0.5
    helper.update()
    let coneWidth = 10.0 * tan(0.5)
    check("SpotLightHelper: cone.scale.z == distance 10", abs(helper.cone.scale.z - 10.0) < 1e-6)
    check("SpotLightHelper: cone.scale.x == width", abs(helper.cone.scale.x - coneWidth) < 1e-6)
}

// ===== PositionalAudioHelper =====

func checkPositionalAudioHelper(): Unit {
    let listener = AudioListener()
    let audio = PositionalAudio(listener: listener)
    audio.position.set(1.0, 2.0, 3.0)
    audio.setRefDistance(2.0)
    audio.setMaxDistance(8.0)
    audio.setDirectionalCone(coneInnerAngle: 60.0, coneOuterAngle: 120.0, coneOuterGain: 0.5)
    audio.setVelocity(Vector3(0.0, 0.0, 4.0))

    let helper = PositionalAudioHelper(audio, color: 0xff8800)
    helper.update()

    // 内锥/外锥几何顶点数：5 侧线 × 2 + 32 段圆环 × 2 = 74
    check("PositionalAudioHelper: 内锥顶点数 == 74", attrCount(helper.innerCone.geometry, "position") == 74)
    check("PositionalAudioHelper: 外锥顶点数 == 74", attrCount(helper.outerCone.geometry, "position") == 74)
    // 内锥可见（60° < 360°），外锥可见（120° < 360°）
    check("PositionalAudioHelper: 内锥可见", helper.innerCone.visible)
    check("PositionalAudioHelper: 外锥可见", helper.outerCone.visible)
    // refDistance/maxDistance 球体缩放
    check("PositionalAudioHelper: refSphere.scale == (2,2,2)",
        abs(helper.refSphere.scale.x - 2.0) < 1e-9 && abs(helper.refSphere.scale.y - 2.0) < 1e-9 && abs(helper.refSphere.scale.z - 2.0) < 1e-9)
    check("PositionalAudioHelper: maxSphere.scale == (8,8,8)",
        abs(helper.maxSphere.scale.x - 8.0) < 1e-9 && abs(helper.maxSphere.scale.y - 8.0) < 1e-9 && abs(helper.maxSphere.scale.z - 8.0) < 1e-9)
    // velocity 箭头可见且长度合理
    check("PositionalAudioHelper: velocityArrow 可见", helper.velocityArrow.visible)
    check("PositionalAudioHelper: velocityArrow 长度 == 4",
        abs(helper.velocityArrow.cone.position.y - 4.0) < 1e-9)
}

// ===== AudioListenerHelper =====

func checkAudioListenerHelper(): Unit {
    let listener = AudioListener()
    listener.position.set(0.0, 1.0, 0.0)
    listener.lookAt(Vector3(0.0, 1.0, 5.0))

    let helper = AudioListenerHelper(listener, size: 1.0)
    helper.update()

    // 头部坐标轴、前方向箭头、上方向弧
    check("AudioListenerHelper: 包含 AxesHelper", helper.axes.kind == "AxesHelper")
    check("AudioListenerHelper: forwardArrow 长度 == 1",
        abs(helper.forwardArrow.cone.position.y - 1.0) < 1e-9)
    check("AudioListenerHelper: upArc 有线段", attrCount(helper.upArc.geometry, "position") > 0)
}

// ===== RigidBodyHelper =====

func checkRigidBodyHelper(): Unit {
    let world = PhysicsWorld()
    let body = RigidBody(world: world).setShape(PhysicsShape.sphere(0.5))
    let helper = RigidBodyHelper(body, shape: PhysicsShape.sphere(0.5), color: 0x00ff00)

    // 球体线框至少包含一些顶点
    check("RigidBodyHelper: sphere shape 顶点数 > 0", attrCount(helper.shapeLines.geometry, "position") > 0)

    // 切换为 Box 形状
    helper.setShape(PhysicsShape.box(1.0, 2.0, 3.0))
    check("RigidBodyHelper: box shape 顶点数 == 8", attrCount(helper.shapeLines.geometry, "position") == 8)
}

// ===== ConstraintHelper =====

func checkConstraintHelper(): Unit {
    let world = PhysicsWorld()
    let bodyA = RigidBody(world: world).setShape(PhysicsShape.sphere(0.5))
    let bodyB = RigidBody(world: world).setShape(PhysicsShape.sphere(0.5))

    let desc = PhysicsConstraintDesc(
        constraintType: PhysicsConstraintType.Point,
        space: PhysicsConstraintSpace.WorldSpace,
        anchor1: Vector3(0.0, 1.0, 0.0),
        anchor2: Vector3(1.0, 1.0, 0.0))

    let helper = ConstraintHelper(world, desc, bodyA, bodyB, color: 0xffaa00)
    helper.update()

    // 连线有两个端点（6 floats）
    check("ConstraintHelper: 连线顶点数 == 2", attrCount(helper.connection.geometry, "position") == 2)

    // 锚点 A 在 (0,1,0)
    check("ConstraintHelper: anchorA 位置 == (0,1,0)",
        abs(helper.anchorA.position.x - 0.0) < 1e-9 && abs(helper.anchorA.position.y - 1.0) < 1e-9 && abs(helper.anchorA.position.z - 0.0) < 1e-9)
    // 锚点 B 在 (1,1,0)
    check("ConstraintHelper: anchorB 位置 == (1,1,0)",
        abs(helper.anchorB.position.x - 1.0) < 1e-9 && abs(helper.anchorB.position.y - 1.0) < 1e-9 && abs(helper.anchorB.position.z - 0.0) < 1e-9)
}
