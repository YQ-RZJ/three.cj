package perfRenderTest

/**
 * 真实渲染路径性能测试（配合 scripts/tracy_receiver.py 采集 Tracy 协议基线）
 *
 * 设计要点：
 * - 真实生产渲染管线：ThreeRenderer.render(scene, camera) 走完整
 *   _render -> _collectRenderObjects -> RenderList.sort/finish -> BgfxBackend.draw 链，
 *   插桩 @Zone 全部位于这些真实热路径（three.rendering.*）。
 * - 固定相机：位置/朝向恒定，不旋转、不移动，剔除与投影完全确定。
 * - 固定对象规模：FEW=25 立方体 / MANY=800 立方体，确定性网格排布（无随机）。
 * - 固定测量方案：每阶段 WARMUP_FRAMES 预热 + MEASURE_FRAMES 计测帧，
 *   自动切换阶段、全部完成自动关闭窗口退出。
 * - 帧标记：每帧 ProfFrame.mark()（门面无条件 API），接收端据此统计帧耗时。
 * - 画面内统计：setDebug(DEBUG_TEXT) + dbgTextPrintf 显示 FPS / draw call / 三角形数，
 *   不引入 GUI 依赖；帧耗时用 EMA(alpha=0.1) 平滑，FPS 每帧均为有效数值。
 * - 日志：统一使用 three.utils.log 的级别宏（@LogInfo/@LogDebug/@LogError）。
 *   档位由编译期环境变量 THREE_LOG_LEVEL 决定（off/error/warn/info/debug/trace，
 *   未设置按 off，此时日志调用点不生成任何代码）；改动档位后需重新构建。
 *   启动/阶段信息为 Info 级，逐帧统计为 Debug 级。
 *
 * 运行（PowerShell）：
 *   $env:EXTEDN_LIBS_PATH_WIN_X64="C:\workspace\Web\24w\three.cj\three.cj\libs"
 *   $env:THREE_PROFILER="three.rendering,three.perf"   # 编译期档位，切换需重编译
 *   $env:THREE_LOG_LEVEL=info                          # 编译期档位，切换需重编译
 *   cjpm build / cjpm run
 *   同时启动 python scripts/tracy_receiver.py --out captures/perf_few_many
 */

import std.math.*
import std.time.*
import std.collection.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.profiler.*
import three.utils.log.*
import three.utils.log.macros.*

// ===== 测试参数（固定，保证可复现） =====
const FEW_OBJECTS: Int64 = 25
const MANY_OBJECTS: Int64 = 800
const WARMUP_FRAMES: Int64 = 60
const MEASURE_FRAMES: Int64 = 240
const PALETTE_SIZE: Int64 = 10
const SPACING: Float64 = 1.6          // 网格间距
const PI_F: Float64 = 3.14159265358979323846

// 立方体颜色调色板（共享材质，控制材质数恒定）
let PALETTE: Array<UInt32> = [
    0xd9553f, 0xe8a33d, 0xe5d752, 0x7cb342, 0x2e9e6b,
    0x2f8fbf, 0x3f51b5, 0x7e57c2, 0xc2185b, 0x90a4ae
]

/**
 * 性能测试窗口：固定相机渲染场景，按阶段（少对象 -> 多对象）自动推进并退出。
 */
public class PerfRenderWindow <: WindowEngine {
    // ===== 渲染状态 =====
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
    var boxGeom: BoxGeometry = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
    var mats: ArrayList<MeshBasicMaterial> = ArrayList<MeshBasicMaterial>()
    var meshes: ArrayList<Mesh> = ArrayList<Mesh>()

    // ===== 阶段控制 =====
    var frame: Int64 = 0          // 总帧数
    var phase: Int64 = 0          // 0=FEW / 1=MANY
    var phaseFrame: Int64 = 0     // 当前阶段内帧计数
    var startTime: MonoTime = MonoTime.now()

    // ===== 画面内统计（bgfx 调试文本层） =====
    var emaFrameMs: Float64 = 0.0   // 帧耗时指数滑动平均（EMA），FPS 由其导出

    // ===== 生命周期：窗口创建后 =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        @LogInfo(["perf", "【1/4】初始化 ThreeRenderer（绑定窗口 ${hwnd}，${w}x${h}）..."])
        this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
        let rok = this.renderer.initBgfx(hwnd, w, h)
        if (!rok) {
            @LogError(["perf", "ThreeRenderer.initBgfx 失败！"])
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x1a1a24))
        // 开启 bgfx 调试文本（DEBUG_TEXT = 0x08）——画面内 FPS / draw call 显示的前提
        this.renderer.setDebug(0x00000008)
        @LogInfo(["perf", "ThreeRenderer 初始化成功"])

        // 共享材质调色板
        for (hex in PALETTE) {
            let m = MeshBasicMaterial()
            m.color = Color(hex)
            this.mats.add(m)
        }

        // 固定相机：位置/朝向恒定
        this.camera.position.set(0.0, 3.0, 14.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        this.buildScene(FEW_OBJECTS)
        @LogInfo(["perf", "【2/4】场景构建成功：${FEW_OBJECTS} 立方体（phase 0，确定性网格排布）"])
        @LogInfo(["perf", "【3/4】渲染循环：每阶段 ${WARMUP_FRAMES} 预热帧 + ${MEASURE_FRAMES} 计测帧，固定相机，自动退出"])
        @LogInfo(["perf", "【4/4】开始..."])
    }

    // ===== 生命周期：每帧 =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        this.phaseFrame++

        // 阶段推进：每阶段跑满 WARMUP+MEASURE 帧后切换
        let phaseFrames = WARMUP_FRAMES + MEASURE_FRAMES
        if (this.phaseFrame > phaseFrames) {
            this.phase++
            this.phaseFrame = 1
            if (this.phase >= 2) {
                let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
                // 末帧渲染统计（draw call / 三角形数）：用于校验合批与剔除结果是否正确
                // （800 立方体经自动实例化应折叠为 10 个实例化 draw call）
                @LogInfo(["perf", "=== perf 测试完成：总帧数=${this.frame}，耗时=${elapsed}s，" +
                    "末帧 drawCalls=${this.renderer.info.render.calls}，tris=${this.renderer.info.render.triangles} ==="])
                this.requestClose()
                return
            }
            let count = if (this.phase == 1) { MANY_OBJECTS } else { FEW_OBJECTS }
            this.buildScene(count)
            @LogInfo(["perf", "【phase ${this.phase}】场景重建：${count} 立方体（warmup=${WARMUP_FRAMES}, measure=${MEASURE_FRAMES}）"])
        }

        // 固定相机宽高比（窗口尺寸恒定，宽高比恒定）
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 真实渲染路径
        this.renderer.render(this.scene, this.camera)
        ProfFrame.mark()   // 主帧标记（接收端据此统计帧耗时）

        // 画面内统计（bgfx 调试文本层）：FPS / draw call / 三角形数 / 阶段进度
        this.drawHud(dt)

        // 周期输出逐帧统计（验证负载确实切换）
        if (this.frame % 60 == 1) {
            @LogDebug(["perf", "【render】frame=${this.frame} phase=${this.phase} " +
                "drawCalls=${this.renderer.info.render.calls} tris=${this.renderer.info.render.triangles}"])
        }
    }

    // ===== 画面内统计：FPS / draw call =====
    // 走 bgfx 内置调试文本层（setDebug(DEBUG_TEXT) + dbgTextPrintf），不引入 GUI 依赖。
    // 帧耗时用 EMA（alpha=0.1）平滑，FPS 每帧由平滑值导出——始终是有效数值，
    // 既不跳 0 也不会因单帧抖动而剧烈摆动。
    private func drawHud(dt: Float64): Unit {
        let frameMs = dt * 1000.0
        this.emaFrameMs = if (this.emaFrameMs == 0.0) {
            frameMs
        } else {
            this.emaFrameMs * 0.9 + frameMs * 0.1
        }
        let fps = if (this.emaFrameMs > 0.0) { 1000.0 / this.emaFrameMs } else { 0.0 }

        let phaseName = if (this.phase == 0) { "FEW" } else { "MANY" }
        let objCount = if (this.phase == 0) { FEW_OBJECTS } else { MANY_OBJECTS }
        let calls = this.renderer.info.render.calls
        let tris = this.renderer.info.render.triangles

        this.renderer.dbgTextClear(0x00, false)
        this.renderer.dbgTextPrintf(
            0, 0, 0x0f,
            "three.perf phase=" + phaseName + " objects=" + objCount.toString() +
            " frame=" + this.frame.toString() + "/" + (WARMUP_FRAMES + MEASURE_FRAMES).toString()
        )
        this.renderer.dbgTextPrintf(
            0, 1, 0x0e,
            "fps=" + fps.toString() + " calls=" + calls.toString() + " tris=" + tris.toString()
        )
    }

    // ===== 生命周期：关闭前清理 =====
    public override func onClose(): Unit {
        @LogInfo(["perf", "【cleanup】关闭渲染器..."])
        this.renderer.shutdown()
        @LogInfo(["perf", "=== perf 测试完成 ==="])
    }

    // ===== 场景构建：确定性网格排布（side x side，取前 count 个） =====
    func buildScene(count: Int64): Unit {
        // 清空旧场景
        for (m in this.meshes) {
            this.scene.remove(m)
        }
        this.meshes.clear()

        let side = Int64(ceil(sqrt(Float64(count))))
        let half = Float64(side) * SPACING * 0.5
        var k: Int64 = 0
        while (k < count) {
            let ix = k % side
            let iz = k / side
            let x = Float64(ix) * SPACING - half + SPACING * 0.5
            let z = Float64(iz) * SPACING - half + SPACING * 0.5
            let scale = 1.0 + 0.5 * (Float64(k % 5) / 4.0)
            let mesh = Mesh(geometry: this.boxGeom, material: this.mats[k % PALETTE_SIZE])
            mesh.position.set(x, 0.5 * scale, z)
            mesh.scale.set(scale, scale, scale)
            mesh.frustumCulled = true
            this.scene.add(mesh)
            this.meshes.add(mesh)
            k++
        }
        // 静态场景：一次性刷新世界矩阵，供收集阶段确定性剔除
        this.scene.updateMatrixWorld(true)
    }
}

main(): Int64 {
    @LogInfo(["perf", "=== three4cj 真实渲染路径性能测试 ==="])

    // ---- 步骤 1: 创建窗口 ----
    let win = PerfRenderWindow()
    let wok = win.start(title: "three4cj PerfRender", width: 1280, height: 720)
    if (!wok) {
        @LogError(["perf", "WindowEngine.start 失败！"])
        return 1
    }
    win.setResizable(false)
    @LogInfo(["perf", "窗口创建成功：${win.getWidth()}x${win.getHeight()}"])

    // ---- 步骤 2: 等待自动退出（阶段跑完后 requestClose） ----
    win.wait()
    return 0
}
