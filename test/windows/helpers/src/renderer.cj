/**
 * @file renderer
 * @brief test_helpers 视觉测试（v2 生命周期模式）：将所有 helper 摆进场景渲染，人工确认显示效果
 *
 * 展示的 helpers（对照 three.js 全部 13 个）：
 * - AxesHelper（坐标轴）、ArrowHelper（箭头）、Box3Helper、BoxHelper、
 *   CameraHelper、DirectionalLightHelper、GridHelper、HemisphereLightHelper、
 *   PlaneHelper、PointLightHelper、PolarGridHelper、SkeletonHelper、SpotLightHelper
 *
 * 说明：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
 */
package test_helpers

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
import three.rendering.helpers.*
import three.rendering.BgfxRenderer
import three.utils.constants.DoubleSide
import three.audio.listener.AudioListener
import three.audio.source.PositionalAudio
import three.physics.body.RigidBody
import three.physics.world.PhysicsWorld
import three.physics.constraint.*
import three.physics.interfaces.*

/// 几何体绕圈半径
public let SHOW_RADIUS: Float64 = 6.0

/// 创建场景：所有 helpers 围一圈 + 相机轨道旋转
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Object3D>, PhysicsWorld) {
    let scene = Scene()
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 200.0)
    camera.position.set(0.0, 4.0, 14.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))

    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.4)
    scene.add(ambient)

    // ---- 中央：坐标轴 + 网格 ----
    let axes = AxesHelper(size: 2.0)
    axes.name = "AxesHelper"
    scene.add(axes)

    let grid = GridHelper(size: 10.0, divisions: 10, color1: Color(0x444444), color2: Color(0x888888))
    grid.position.y = -0.01
    grid.name = "GridHelper"
    scene.add(grid)

    let polar = PolarGridHelper(radius: 3.0, sectors: 12, rings: 4, divisions: 32)
    polar.position.y = 0.01
    polar.name = "PolarGridHelper"
    scene.add(polar)

    // ---- 包围盒类 helpers（绕 Y 轴围一圈）----
    let objects = ArrayList<Object3D>()

    // ArrowHelper：三个方向
    let arrowX = ArrowHelper(dir: Vector3(1.0, 0.0, 0.0), origin: Vector3(0.0, 0.0, 0.0), length: 2.0, color: 0xff4444)
    arrowX.position.set(-2.5, 1.5, 0.0)
    arrowX.name = "ArrowHelper-X"
    objects.add(arrowX); scene.add(arrowX)

    let arrowY = ArrowHelper(dir: Vector3(0.0, 1.0, 0.0), origin: Vector3(0.0, 0.0, 0.0), length: 2.0, color: 0x44ff44)
    arrowY.position.set(2.5, 1.5, 0.0)
    arrowY.name = "ArrowHelper-Y"
    objects.add(arrowY); scene.add(arrowY)

    // Box3Helper：包一个中心 (1,1,1) 尺寸 (2,2,2) 的盒
    let box3 = Box3().setFromCenterAndSize(Vector3(1.0, 1.0, 1.0), Vector3(2.0, 2.0, 2.0))
    let box3h = Box3Helper(box3, color: 0xffff44)
    box3h.name = "Box3Helper"
    objects.add(box3h); scene.add(box3h)

    // BoxHelper：包一个球体 mesh（BoxHelper.update 需对象有 geometry）
    let sphereMesh = Mesh(geometry: SphereGeometry(radius: 1.0, widthSegments: 16, heightSegments: 12),
                          material: MeshPhongMaterial())
    sphereMesh.material.color = Color(0x4488ff)
    sphereMesh.material.side = DoubleSide
    sphereMesh.position.set(3.0, 1.0, 0.0)
    sphereMesh.updateMatrixWorld(true)
    let boxh = BoxHelper(sphereMesh, color: 0xffff44)
    boxh.name = "BoxHelper"
    objects.add(boxh); scene.add(boxh)

    // PlaneHelper：展示 y=1 平面
    let planeHelper = PlaneHelper(Plane(Vector3(0.0, 1.0, 0.0), 1.0), size: 2.0, hex: 0xff44ff)
    planeHelper.name = "PlaneHelper"
    objects.add(planeHelper); scene.add(planeHelper)

    // SkeletonHelper：简单骨骼链（root -> b1 -> b2）
    let skelRoot = Object3D()
    let bone1 = Bone(); let bone2 = Bone()
    bone1.position.set(0.0, 0.5, 0.0)
    bone2.position.set(0.0, 0.5, 0.0)
    bone1.add(bone2)
    skelRoot.add(bone1)
    let skel = SkeletonHelper(skelRoot)
    skel.name = "SkeletonHelper"
    objects.add(skel); scene.add(skel)

    // CameraHelper：可视化一个辅助相机
    let auxCam = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.5, far: 20.0)
    auxCam.position.set(2.0, 3.0, 3.0)
    auxCam.lookAt(Vector3(0.0, 0.0, 0.0))
    auxCam.updateMatrixWorld(true)
    let camH = CameraHelper(auxCam)
    camH.name = "CameraHelper"
    objects.add(camH); scene.add(camH)

    // ---- 光源 helpers ----
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 0.8)
    dirLight.position.set(-3.0, 4.0, -3.0)
    scene.add(dirLight)
    let dirH = DirectionalLightHelper(dirLight, size: 0.6)
    dirH.name = "DirectionalLightHelper"
    objects.add(dirH); scene.add(dirH)

    let hemiLight = HemisphereLight(skyColor: Color(0xffbb88), groundColor: Color(0x8888ff), intensity: 0.6)
    hemiLight.position.set(0.0, 3.0, -3.0)
    scene.add(hemiLight)
    let hemiH = HemisphereLightHelper(hemiLight, size: 0.8)
    hemiH.name = "HemisphereLightHelper"
    objects.add(hemiH); scene.add(hemiH)

    let pointLight = PointLight(color: Color(0xff8844), intensity: 1.0)
    pointLight.position.set(3.0, 3.0, -3.0)
    scene.add(pointLight)
    let pointH = PointLightHelper(pointLight, sphereSize: 0.5)
    pointH.name = "PointLightHelper"
    objects.add(pointH); scene.add(pointH)

    let spotLight = SpotLight(color: Color(0xffffff), intensity: 1.0)
    spotLight.position.set(0.0, 5.0, 4.0)
    spotLight.angle = 0.5
    spotLight.distance = 12.0
    scene.add(spotLight)
    let spotH = SpotLightHelper(spotLight)
    spotH.name = "SpotLightHelper"
    objects.add(spotH); scene.add(spotH)

    // ---- audio helpers ----
    let listener = AudioListener()
    camera.add(listener)

    let audio = PositionalAudio(listener: listener)
    audio.position.set(3.0, 1.0, 3.0)
    audio.setRefDistance(1.0)
    audio.setMaxDistance(4.0)
    audio.setDirectionalCone(coneInnerAngle: 60.0, coneOuterAngle: 120.0, coneOuterGain: 0.3)
    audio.setVelocity(Vector3(0.0, 0.0, 2.0))
    scene.add(audio)
    let audioH = PositionalAudioHelper(audio, color: 0xffaa00)
    audioH.name = "PositionalAudioHelper"
    objects.add(audioH); scene.add(audioH)

    let listenerH = AudioListenerHelper(listener, size: 0.5)
    listenerH.name = "AudioListenerHelper"
    objects.add(listenerH); scene.add(listenerH)

    // ---- physics helpers ----
    let world = PhysicsWorld()
    let ok = world.start(maxBodies: 128u32, gravity: Vector3(0.0, -9.81, 0.0))
    if (!ok) {
        println("[renderer] PhysicsWorld.start 失败，物理 helper 将不可见")
    }

    let groundMesh = Mesh(geometry: BoxGeometry(width: 6.0, height: 0.2, depth: 6.0),
                          material: MeshPhongMaterial())
    groundMesh.material.color = Color(0x666666)
    groundMesh.position.set(-2.0, 0.0, 2.0)
    scene.add(groundMesh)

    let bodyA = RigidBody(world: world)
        .setShape(PhysicsShape.box(0.6, 0.6, 0.6))
        .setStatic()
        .attach(groundMesh)

    let boxMesh = Mesh(geometry: BoxGeometry(width: 0.6, height: 0.6, depth: 0.6),
                       material: MeshPhongMaterial())
    boxMesh.material.color = Color(0xff8844)
    boxMesh.position.set(-2.0, 2.0, 2.0)
    scene.add(boxMesh)

    let bodyB = RigidBody(world: world)
        .setShape(PhysicsShape.box(0.6, 0.6, 0.6))
        .setDynamic()
        .attach(boxMesh)

    let bodyH = RigidBodyHelper(bodyB, shape: PhysicsShape.box(0.6, 0.6, 0.6), color: 0x00ff00)
    bodyH.name = "RigidBodyHelper"
    objects.add(bodyH); scene.add(bodyH)

    let constraintDesc = PhysicsConstraintDesc(
        constraintType: PhysicsConstraintType.Distance,
        space: PhysicsConstraintSpace.WorldSpace,
        anchor1: Vector3(-2.0, 0.5, 2.0),
        anchor2: Vector3(-2.0, 1.7, 2.0),
        limitMin: 0.5,
        limitMax: 2.0)
    let constraint = PhysicsConstraint.distance(world, bodyA.handle, bodyB.handle,
                                                Vector3(-2.0, 0.5, 2.0), Vector3(-2.0, 1.7, 2.0),
                                                0.5, 2.0)
    let constraintH = ConstraintHelper(world, constraintDesc, bodyA, bodyB, color: 0xffaa00)
    constraintH.name = "ConstraintHelper"
    objects.add(constraintH); scene.add(constraintH)

    return (scene, camera, objects, world)
}
