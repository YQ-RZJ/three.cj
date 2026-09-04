package threeTest

/**
 * Three.js 渲染场景设置（v2 生命周期模式）。
 * 说明：渲染循环已移入 main.cj 的 TestWindow.onFrame（窗口泵线程驱动）。
 */

import std.sync.*
import std.time.*
import std.math.*
import std.fs.*
import std.fs.Path as FsPath
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.BgfxRenderer
import three.resource.loader.GltfLoader
import three.rendering.lights.*

/// 创建场景、相机和灯光
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Group) {
    let aspect = Float64(width) / Float64(height)

    // 创建场景
    let scene = Scene()
    scene.name = "TestScene"
    println("  场景创建成功: ${scene.name}")

    // 创建相机
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 5.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")
    println("    位置: (${camera.position.x}, ${camera.position.y}, ${camera.position.z})")

    // 创建方向光
    println("  创建方向光...")
    let dirLight = DirectionalLight(color: Color(1.0, 1.0, 1.0), intensity: 1.0)
    dirLight.position.set(1.0, 2.0, 3.0)
    dirLight.name = "MainLight"
    scene.add(dirLight)
    println("  方向光创建成功: ${dirLight.name}")

    // 创建环境光
    let ambientLight = AmbientLight(color: Color(0.3, 0.3, 0.3), intensity: 0.5)
    ambientLight.name = "AmbientLight"
    scene.add(ambientLight)
    println("  环境光创建成功: ${ambientLight.name}")

    // 加载 GLB 模型
    let modelGroup = loadGLBModel(camera)
    scene.add(modelGroup)
    println("  GLB 模型已添加到场景")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, modelGroup)
}

/// 加载 GLB 模型并自动调整相机
private func loadGLBModel(camera: PerspectiveCamera): Group {
    var modelGroup = Group()
    modelGroup.name = "GLBModel"
    var hasValidModel = false

    println("  加载 GLB 模型...")
    let loader = GltfLoader()
    let filePath = FsPath("res/glTF.glb")
    let bytesResult: Option<Array<UInt8>> = try {
        Some(File.readFrom(filePath))
    } catch (e: Exception) {
        println("  读取 GLB 文件失败: ${e.toString()}")
        None
    }

    match (bytesResult) {
        case Some(bytes) =>
            let (jsonData, binData) = loader.parseGlb(bytes)
            println("  GLB 解析完成: JSON keys=${jsonData.size.toString()}, binData size=${binData.size.toString()}")
            modelGroup = loader.parse(jsonData, binData, ".")
            modelGroup.name = "GLBModel"
            println("  GLB 模型加载成功: children=${modelGroup.children.size.toString()}")

            // 计算模型包围盒，自动调整相机
            var bboxMin = Vector3(1e10, 1e10, 1e10)
            var bboxMax = Vector3(-1e10, -1e10, -1e10)
            func traverseForBBox(obj: Object3D): Unit {
                match (obj) {
                    case m: Mesh =>
                        let posAttrOpt = m.geometry.getAttribute("position")
                        match (posAttrOpt) {
                            case Some(attr) =>
                                hasValidModel = true
                                for (i in 0..attr.count) {
                                    let x = attr.getX(i); let y = attr.getY(i); let z = attr.getZ(i)
                                    if (x < bboxMin.x) { bboxMin.x = x }
                                    if (y < bboxMin.y) { bboxMin.y = y }
                                    if (z < bboxMin.z) { bboxMin.z = z }
                                    if (x > bboxMax.x) { bboxMax.x = x }
                                    if (y > bboxMax.y) { bboxMax.y = y }
                                    if (z > bboxMax.z) { bboxMax.z = z }
                                }
                            case None => ()
                        }
                    case _ => ()
                }
                for (child in obj.children) { traverseForBBox(child) }
            }
            traverseForBBox(modelGroup)

            let bboxSize = max(bboxMax.x - bboxMin.x, bboxMax.y - bboxMin.y, bboxMax.z - bboxMin.z)
            let bboxCenter = Vector3(
                (bboxMin.x + bboxMax.x) / 2.0,
                (bboxMin.y + bboxMax.y) / 2.0,
                (bboxMin.z + bboxMax.z) / 2.0
            )
            println("  BBox: size=${bboxSize.toString()} center=(${bboxCenter.x.toString()}, ${bboxCenter.y.toString()}, ${bboxCenter.z.toString()})")

            if (hasValidModel && bboxSize > 0.0) {
                let targetSize = 5.0
                let scaleFactor = targetSize / bboxSize
                modelGroup.scale.set(scaleFactor, scaleFactor, scaleFactor)
                modelGroup.position.set(-bboxCenter.x * scaleFactor, -bboxCenter.y * scaleFactor, -bboxCenter.z * scaleFactor)
                println("  模型自动缩放: scale=${scaleFactor.toString()}")
                let dist = targetSize * 2.0
                camera.position.set(0.0, dist * 0.3, dist)
                camera.lookAt(Vector3(0.0, 0.0, 0.0))
                camera.near = 0.01
                camera.far = dist * 4.0
                camera.updateProjectionMatrix()
                println("  相机调整: pos=(${camera.position.x.toString()}, ${camera.position.y.toString()}, ${camera.position.z.toString()})")
            }
        case None => ()
    }

    // 如果模型加载失败，使用备用 BoxGeometry
    if (!hasValidModel) {
        println("  使用备用 BoxGeometry")
        let fallbackGeom = BoxGeometry(width: 1.5, height: 1.5, depth: 1.5)
        let fallbackMat = MeshBasicMaterial()
        fallbackMat.color = Color(0x88aaff)
        let fallbackMesh = Mesh(geometry: fallbackGeom, material: fallbackMat)
        modelGroup.add(fallbackMesh)
    }

    return modelGroup
}
