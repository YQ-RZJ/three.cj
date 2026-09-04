package threeTest

/**
 * Three.js 渲染场景设置与渲染循环
 */

import std.sync.*
import std.time.*
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
import three.window.WindowEngine
import three.window.MouseButton
import three.rendering.materials.ShaderMaterial

/// 创建场景、相机和立方体
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Mesh) {
    // 创建场景
    let scene = Scene()
    scene.name = "TestScene"
    println("  场景创建成功: ${scene.name}")

    // 创建相机 (PerspectiveCamera)
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 5.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: ${camera.name}")
    println("    位置: (${camera.position.x}, ${camera.position.y}, ${camera.position.z})")

    // 创建彩色立方体
    println("  创建彩色立方体...")
    let geometry = createColoredBoxGeometry(1.5, 1.5, 1.5)
    geometry.name = "ColoredCube"
    println("  彩色立方体几何体创建成功")

    // 创建 ShaderMaterial（使用自定义着色器）
    let material = ShaderMaterial(CUBE_VS, CUBE_FS)
    material.name = "CubeShaderMaterial"
    println("  ShaderMaterial 创建成功: ${material.name}")

    // 创建 Mesh
    let mesh = Mesh(geometry: geometry, material: material)
    mesh.name = "ColoredCubeMesh"
    mesh.position.set(0.0, 0.0, 0.0)
    println("  Mesh 创建成功: ${mesh.name}")

    // 将 Mesh 添加到场景
    scene.add(mesh)
    println("  Mesh 已添加到场景")
    println("  场景子对象数: ${scene.children.size}")
    println("")

    return (scene, camera, mesh)
}
