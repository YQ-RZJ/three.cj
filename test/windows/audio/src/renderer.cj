package threeAudioTest

/**
 * Three.js 场景设置 + 音频控制
 *
 * 场景：一个彩色小球绕相机旋转，同时播放 3D 空间音频
 * - 相机固定在（0, 2, 5），看向与相机同高的（0, 2, 0），使轨道球体位于画面中心
 * - AudioListener 挂载在相机上
 * - PositionalAudio 挂载在球体上，球体绕 Y 轴旋转
 * - 声音具有距离衰减效果：球体靠近时声音大，远离时声音小
 */

import std.sync.*
import std.time.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.window.MouseButton
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.cameras.*
import three.rendering.ThreeRenderer
import three.rendering.materials.ShaderMaterial
import three.audio.*
import three.audio.listener.*
import three.audio.device.*
import three.audio.source.*
import three.resource.loader.AudioLoader

// ========== 着色器源码（仓颉顶层常量需先定义后引用，置于文件顶部）==========
// ========== 着色器源码 ==========

// 球体顶点着色器
public let SPHERE_VS: String = """
$input a_position, a_normal, a_color0
$output v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_color   = a_color0;
    v_worldPos = worldPos.xyz;
}
"""

// 球体片段着色器（暖色调发光效果，音源可视化）
public let SPHERE_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    // 边缘光效果
    float rim = 1.0 - max(dot(normal, vec3(0.0, 0.0, 1.0)), 0.0);
    rim = pow(rim, 2.0) * 0.6;

    // 暖色调（橙红色），音源视觉标识
    vec3 baseColor = vec3(1.0, 0.4, 0.2);
    vec3 litColor = baseColor * (ambient + diff * 0.8) + vec3_splat(rim) * vec3(1.0, 0.6, 0.3);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// 地面顶点着色器
public let GROUND_VS: String = """
$input a_position, a_normal, a_color0
$output v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_color   = a_color0;
    v_worldPos = worldPos.xyz;
}
"""

// 地面片段着色器（网格地面，冷色调）
public let GROUND_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 冷色调网格
    vec3 gridColor = v_color * (ambient + diff * 0.5);
    gl_FragColor = vec4(gridColor, 1.0);
}
"""


/// 创建场景、相机、球体网格和音频
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Mesh, AudioListener, PositionalAudio) {
    // 创建场景
    let scene = Scene()
    scene.name = "AudioTestScene"

    // 创建相机 (PerspectiveCamera)
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 2.0, 5.0)
    // 球体在 main.cj 中沿相机高度（y=2）做圆周运动，因此 lookAt 目标也取 y=2，确保球体在画面中心
    camera.lookAt(Vector3(0.0, 2.0, 0.0))
    camera.name = "MainCamera"
    println("  相机创建成功: 位置=(${camera.position.x}, ${camera.position.y}, ${camera.position.z})")

    // 创建地面参考网格（一个平面）
    let groundGeom = createGroundGeometry()
    let groundMat = ShaderMaterial(GROUND_VS, GROUND_FS)
    let ground = Mesh(geometry: groundGeom, material: groundMat)
    ground.name = "Ground"
    ground.position.set(0.0, -1.0, 0.0)
    scene.add(ground)

    // 创建彩色球体（音源可视化）
    let sphereGeom = SphereGeometry(radius: 0.5, widthSegments: 24, heightSegments: 16)
    let sphereMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
    let sphere = Mesh(geometry: sphereGeom, material: sphereMat)
    sphere.name = "AudioSourceSphere"
    sphere.position.set(3.0, 0.0, 0.0)  // 初始位置在 X 轴
    scene.add(sphere)
    println("  球体创建成功")

    // ===== 音频初始化 =====
    // 1. 初始化音频上下文
    let audioCtx = AudioContext.context
    let audioOk = audioCtx.initialize()
    if (!audioOk) {
        println("  [警告] 音频上下文初始化失败，将无音频输出")
    } else {
        println("  音频上下文初始化成功")
    }

    // 2. 创建 AudioListener 并挂载到相机
    let listener = AudioListener()
    listener.name = "AudioListener"
    camera.add(listener)
    println("  AudioListener 已挂载到相机")

    // 3. 加载音频文件
    var sound = PositionalAudio(listener: listener)
    sound.name = "PositionalAudio"
    if (audioOk) {
        let loader = AudioLoader()
        try {
            let audioBuffer = loader.load("res/sound.mp3")
            sound.setBuffer(audioBuffer)
            sound.setLoop(true)
            sound.setRefDistance(1.0)
            sound.setRolloffFactor(1.0)
            sound.setMaxDistance(30.0)
            sound.setDistanceModel(2)  // inverseClamped
            sound.setVolume(1.0)
            println("  音频文件加载成功: 声道=${audioBuffer.channels.toString()} 采样率=${audioBuffer.sampleRate.toString()} 帧=${audioBuffer.frameCount.toString()}")
        } catch (e: Exception) {
            println("  [警告] 音频文件加载失败: ${e.toString()}")
        }
    }

    // 4. 将 PositionalAudio 挂载到球体上
    //    这样球体的世界位置会自动同步到音频源
    sphere.add(sound)
    println("  PositionalAudio 已挂载到球体")

    return (scene, camera, sphere, listener, sound)
}

/// 创建地面几何体（一个简单的大平面 + 颜色网格）
public func createGroundGeometry(): BufferGeometry {
    let size = 20.0
    let half = size / 2.0

    // 4 个顶点形成一个平面
    let posData = [
        -half, 0.0, -half,
         half, 0.0, -half,
         half, 0.0,  half,
        -half, 0.0,  half,
    ]
    let normData = [
        0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
    ]
    let colData = [
        0.25, 0.28, 0.35,
        0.25, 0.28, 0.35,
        0.25, 0.28, 0.35,
        0.25, 0.28, 0.35,
    ]
    let idxData = [
        0, 1, 2,
        0, 2, 3,
    ]

    let positions = Array<Float64>(posData.size, { i => posData[i] })
    let normals = Array<Float64>(normData.size, { i => normData[i] })
    let colors = Array<Float64>(colData.size, { i => colData[i] })
    let indices = Array<Float64>(idxData.size, { i => Float64(idxData[i]) })

    let geom = BufferGeometry()
    geom.setIndex(BufferAttribute(indices, 1))
    geom.setAttribute("position", BufferAttribute(positions, 3))
    geom.setAttribute("normal", BufferAttribute(normals, 3))
    geom.setAttribute("color", BufferAttribute(colors, 3))
    return geom
}
