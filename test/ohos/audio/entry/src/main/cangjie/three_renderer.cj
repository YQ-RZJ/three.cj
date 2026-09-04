package ohos_app_cangjie_entry

/**
 * 仓颉侧 three 渲染引擎与 ArkTS 侧 XComponent 的桥接（纯仓颉实现，无 C++）。
 *
 * 职责：
 *  - 通过 three.cj 的 WindowEngine 获取 native window 句柄/尺寸后，初始化
 *    three 引擎的 BgfxRenderer（bgfx + OpenGLES），创建音频可视化场景
 *    （地面 + 球体 + 3D 空间音频），并在窗口泵线程中驱动渲染循环
 *    （ThreeWindow 生命周期：onInit 初始化 → onFrame 每帧驱动 → onClose 清理，
 *    与 ohos/base 结构一致）。
 *
 * OHOS 说明（nm 注册模式 + XComponent 直连建窗）：
 *  - ArkTS 侧 XComponent 设 libraryname='SDL3'，mmg 加载 libSDL3.so 时 SDL 的
 *    OHOS_XcomponentExport 会把该 XComponent 注册进 SDL 注册表并挂接触摸/键鼠回调；
 *  - SDL 建窗时直接从注册表取该 XComponent 的 native window 建窗，native window
 *    经 SDL_PROP_WINDOW_OHOS_WINDOW_POINTER 交给本文件 onInit 里的
 *    BgfxRenderer.initBgfx 绑定渲染；
 *  - 输入事件按 xcompentId 路由进该 SDL 窗口，经 InputEngine 查询。
 */

import std.sync.*
import std.time.*
import std.runtime.*
import std.math.*
import ohos.app.ability.ui_ability.*
import three.rendering.BgfxRenderer
import three.window.WindowEngine
import three.window.WindowConfig
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.scene.entity.*
import three.rendering.cameras.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.materials.*
import std.convert.RadixConvertible
import kit.CoreFileKit.*
import three.audio.*
import three.audio.listener.*
import three.audio.device.*
import three.audio.source.*
import three.resource.loader.AudioLoader

// ===== 全局状态 =====
// WindowEngine 实例：startThreeRender 中创建并绑定 XComponent，
// resizeThreeRender 中通过 updateSize 保持窗口尺寸同步（跨平台接口）。

var g_windowEngine: Option<WindowEngine> = None

var g_renderRunning = AtomicBool(false)
var g_renderFrame: Int64 = 0
// ArkTS onAreaChange 事件驱动的待应用尺寸（0 = 无更新）。写入后渲染线程每帧
// 读原子并应用，curW/curH 更新后自然不再触发，无需清零，无竞争。
var g_resizeW = AtomicInt32(0)
var g_resizeH = AtomicInt32(0)

// ===== 着色器源码（参考 windows/audio：球体音源可视化 + 网格地面） =====

// 球体顶点着色器
let SPHERE_VS: String = """
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
let SPHERE_FS: String = """
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
let GROUND_VS: String = """
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
let GROUND_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 冷色调网格
    vec3 gridColor = v_color.xyz * (ambient + diff * 0.5);
    gl_FragColor = vec4(gridColor, 1.0);
}
"""

// ===== 几何体辅助：地面参考平面（参考 windows/audio） =====

func createGroundGeometry(): BufferGeometry {
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

// ===== OHOS 渲染窗口：复用跨平台 WindowEngine 生命周期（参考 ohos/base） =====
// onInit 用 SDL 窗口的 native window 句柄初始化 BgfxRenderer（OpenGLES）并
// 创建音频场景；onFrame 驱动球体绕相机旋转 + 渲染；onClose 清理音频与渲染器。

public class ThreeWindow <: WindowEngine {
    var renderer: BgfxRenderer = BgfxRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var ground: Mesh
    var mesh: Mesh
    var listener: AudioListener = AudioListener()
    var sound: PositionalAudio = PositionalAudio(listener: AudioListener())
    var soundOk: Bool = false
    var frame: Int64 = 0
    var appliedW: Int32 = 0
    var appliedH: Int32 = 0
    // ArkTS 侧经 wrapper 传入的 UIAbilityContext：用于读取 rawfile 音频
    // （rawfile 无真实文件系统路径）。为 None 时跳过音频加载（仅渲染，无声音）。
    var audioContext: Option<UIAbilityContext> = None

    /// 构造：创建地面与球体网格（不依赖窗口，可在字段初始化阶段完成）
    public init() {
        // 地面参考网格
        let groundGeom = createGroundGeometry()
        let groundMat = ShaderMaterial(GROUND_VS, GROUND_FS)
        this.ground = Mesh(geometry: groundGeom, material: groundMat)
        this.ground.position.set(0.0, -1.0, 0.0)
        // 彩色球体（音源可视化）
        let sphereGeom = SphereGeometry(radius: 0.5, widthSegments: 24, heightSegments: 16)
        let sphereMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
        this.mesh = Mesh(geometry: sphereGeom, material: sphereMat)
        this.mesh.position.set(3.0, 0.0, 0.0)  // 初始位置在 X 轴
    }

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/音频） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        // OHOS 窗口真实尺寸由 ArkTS XComponent 控制（onAreaChange 写入 g_resizeW/H）；
        // start() 时传的是占位尺寸，优先使用 ArkTS 已同步的真实尺寸。
        let rw = g_resizeW.load()
        let rh = g_resizeH.load()
        let w = if (rw > 0i32) { rw } else { this.getWidth() }
        let h = if (rh > 0i32) { rh } else { this.getHeight() }
        let rok = this.renderer.initBgfx(hwnd, w, h)
        if (!rok) {
            this.requestClose()
            return
        }
        this.appliedW = w
        this.appliedH = h
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))  // 灰蓝色背景，与 windows/audio 一致

        // 相机固定（参考 windows/audio）：位置 (0,2,5)，朝向原点
        this.camera.position.set(0.0, 2.0, 5.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        // 场景添加：地面 + 球体（音源可视化）
        this.scene.add(this.ground)
        this.scene.add(this.mesh)

        // 3D 空间音频初始化（参考 windows/audio + HEAD 版 rawfile 加载）
        this.initAudio()
    }

    // ===== 音频初始化：上下文 → 听者挂相机 → rawfile 加载 → 球体挂音源 =====
    func initAudio(): Unit {
        // 1. 初始化音频上下文（全局单例）
        let audioCtx = AudioContext.context
        let audioOk = audioCtx.initialize()
        if (!audioOk) {
            return
        }
        // 2. 创建 AudioListener 并挂载到相机（听者）
        this.listener = AudioListener()
        this.camera.add(this.listener)
        // 3. 加载音频文件（rawfile 无真实文件系统路径：经 resourceManager 读字节 →
        //    写入沙箱 filesDir → AudioLoader.load 解码）
        this.sound = PositionalAudio(listener: this.listener)
        var soundOk = false
        match (this.audioContext) {
            case Some(ctx) =>
                try {
                    let rawBytes = ctx.resourceManager.getRawFileContent("sound.mp3")
                    let destPath = ctx.filesDir + "/sound.mp3"
                    let file = FileIo.open(destPath, mode: OpenMode.READ_WRITE | OpenMode.CREATE | OpenMode.TRUNC)
                    // Array<UInt8> → Array<Byte>（FileIo.write 接受 Byte 数组，元素可由 UInt8 直接构造）
                    let bytes: Array<Byte> = Array<Byte>(rawBytes.size, { i => rawBytes[i] })
                    let written = FileIo.write(file.fd, bytes)
                    FileIo.close(file)
                    if (written == Int64(rawBytes.size)) {
                        let loader = AudioLoader()
                        let audioBuffer = loader.load(destPath)
                        this.sound.setBuffer(audioBuffer)
                        this.sound.setLoop(true)
                        this.sound.setRefDistance(1.0)
                        this.sound.setRolloffFactor(1.0)
                        this.sound.setMaxDistance(30.0)
                        this.sound.setDistanceModel(2)  // inverseClamped
                        this.sound.setVolume(1.0)
                        soundOk = true
                    }
                } catch (e: Exception) {
                    // 音频加载失败：仅渲染，无声音输出
                }
            case None => ()  // 未获取 UIAbilityContext：跳过音频，仅渲染
        }
        // 4. 将 PositionalAudio 挂载到球体（球体世界位置自动同步到音频源）
        this.mesh.add(this.sound)
        // 5. 开始播放（球体绕相机旋转，声音随距离变化）
        this.soundOk = soundOk
        if (soundOk) {
            this.sound.play()
        }
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        let angle = Float64(this.frame) * 0.02

        // 球体围绕相机旋转（以相机位置为圆心做圆周运动，参考 windows/audio）
        let radius = 3.0
        let cx = this.camera.position.x
        let cy = this.camera.position.y
        let cz = this.camera.position.z
        let bx = cx + radius * cos(angle)
        let bz = cz + radius * sin(angle)
        // 球 y 与相机视线对齐：相机 (0,2,5) lookAt 原点（俯视），球若与相机同高
        // 会投影到画面偏上；按视线方向修正（相机到原点 xz 距离=5），使球投影到
        // 画面中央，纵向上与相机视线同高（视觉上与相机对齐）。
        let ballY = cy * (1.0 - radius / 5.0)
        this.mesh.position.set(bx, ballY, bz)
        this.mesh.rotation.y = angle * 0.5

        // 应用 ArkTS onAreaChange 尺寸（XComponent 尺寸由 ArkTS 控制）
        let rw = g_resizeW.load()
        let rh = g_resizeH.load()
        if (rw > 0i32 && rh > 0i32 && (rw != this.appliedW || rh != this.appliedH)) {
            this.appliedW = rw
            this.appliedH = rh
            this.renderer.setSize(rw, rh)
        }
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 渲染场景（AudioListener / PositionalAudio 的世界位置在 render 内部
        // updateMatrixWorld 时自动同步到 OpenAL，无需手动更新）
        this.renderer.render(this.scene, this.camera)
    }

    // ===== 生命周期：关闭前（清理音频 + 渲染器） =====
    public override func onClose(): Unit {
        // 清理音频（仅初始化成功时；参考 windows/audio onClose）
        if (this.soundOk) {
            this.sound.stop()
            this.sound.disconnect()
            let audioCtx = this.listener.context
            audioCtx.shutdown()
        }
        this.renderer.shutdown()
    }
}

// ===== 启动 three 渲染（WindowEngine + 窗口泵线程驱动） =====
// context：ArkTS 传入的 UIAbilityContext，用于读取 rawfile 音频（为 None 时仅渲染）。

public func startThreeRender(context: Option<UIAbilityContext>): Bool {
    if (g_renderRunning.load()) {
        return true
    }
    let win = ThreeWindow()
    win.audioContext = context
    let cfg = WindowConfig()
    cfg.resizable = false
    // width/height 传占位值：OHOS 建窗回退路径会从注册的 XComponent 取真实
    // native window 并回填真实尺寸；真实尺寸随后由 ArkTS onAreaChange 同步。
    let ok = win.start(title: "ThreeRender", width: 1, height: 1, config: cfg)
    if (ok) {
        g_windowEngine = Some(win)
        g_renderRunning.store(true)
    }
    return ok
}

// ===== 事件驱动 resize：由 ArkTS 侧 XComponent onAreaChange 触发（旋转/窗口尺寸变化） =====
// 写入原子变量，渲染线程每帧只读内存原子（非 FFI、无锁、开销≈0），
// 与参考项目 xcomponent-vsync-master 的 OnSurfaceChanged 事件驱动等价。

public func resizeThreeRender(w: Int32, h: Int32): Unit {
    if (w > 0 && h > 0) {
        g_resizeW.store(w)
        g_resizeH.store(h)
        // 同步 three.cj WindowEngine 的窗口尺寸（跨平台接口；
        // OHOS 上 XComponent 由 ArkTS 控制，仅更新内部尺寸供渲染查询）
        match (g_windowEngine) {
            case Some(engine) => engine.updateSize(w, h)
            case None => ()
        }
    }
}

// ===== 停止 three 渲染 =====

public func stopThreeRender(): Unit {
    g_renderRunning.store(false)
    match (g_windowEngine) {
        case Some(engine) => engine.shutdown()
        case None => ()
    }
    g_windowEngine = None
}

// ===== 查询渲染状态 =====

public func isThreeRendering(): Bool {
    return g_renderRunning.load()
}
