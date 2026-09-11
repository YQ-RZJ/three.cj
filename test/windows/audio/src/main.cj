package threeAudioTest

/**
 * 音频渲染测试入口（v2 生命周期模式）：3D 空间音频 + 渲染
 *
 * 场景描述：
 * - 相机位于原点，作为音频听者（AudioListener）
 * - 一个彩色小球绕相机旋转，作为音源（PositionalAudio）
 * - 使用 OpenAL 实现空间音效，小球位置实时同步到音频源
 *
 * 模块说明：
 * - main.cj:     TestWindow <: WindowEngine（onInit 创建渲染器/场景/音频 →
 *                onFrame 每帧球体运动 + 渲染 → onClose 清理音频与渲染器）
 * - renderer.cj: Three.js 场景设置、音频初始化
 */

import std.io.*
import std.fs.{File, Path as FsPath}
import std.collection.*
import std.time.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.cameras.*
import three.audio.*
import three.audio.listener.*
import three.audio.device.*
import three.audio.source.*
import three.audio.mixer.*
import three.audio.capture.*
import three.resource.loader.AudioLoader

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景/音频（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var mesh: Mesh = Mesh()
    var listener: AudioListener = AudioListener()
    var sound: PositionalAudio = PositionalAudio(listener: AudioListener())
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/音频） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[2/6] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            println("  ThreeRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x1a, 0x1a, 0x2e))  // 深蓝色背景
        println("  ThreeRenderer 初始化成功")
        println("")

        println("[3/6] 创建场景和音频...")
        let (scene, camera, mesh, listener, sound) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.mesh = mesh
        this.listener = listener
        this.sound = sound
        println("")

        // ---- 步骤 3.5: 高级音频能力验证（效果器/多普勒/AudioLoader） ----
        verifyAudioCapabilities(this.listener, this.sound)

        // ---- 步骤 3.6: 麦克风捕获 + HRTF 验证 ----
        verifyCaptureAndHrtf()

        // ---- 步骤 4: 进入渲染循环 ----
        println("[4/6] 进入渲染循环...")
        println("  按窗口关闭按钮退出\n")

        // 开始播放音频
        if (this.sound.buffer.isSome()) {
            this.sound.play()
            println("  音频开始播放（球体绕相机旋转，注意声音的空间变化）\n")
        }
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++

        // 更新球体旋转
        this.frame++
        let angle = Float64(this.frame) * 0.02

        // 球体围绕相机旋转（以相机位置为圆心做圆周运动）
        let radius = 3.0
        let cx = this.camera.position.x
        let cy = this.camera.position.y
        let cz = this.camera.position.z
        let x = cx + radius * cos(angle)
        let z = cz + radius * sin(angle)
        this.mesh.position.set(x, cy, z)
        this.mesh.rotation.y = angle * 0.5

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 注意：AudioListener 和 PositionalAudio 的 updateMatrixWorld
        // 会在 renderer.render -> scene.updateMatrixWorld 时自动调用，
        // 将世界位置同步到 OpenAL，无需手动更新。

        // 渲染场景
        this.renderer.render(this.scene, this.camera)

        // 每 120 帧打印一次日志
        if (this.frame % 120 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            let dist = (this.mesh.position.x * this.mesh.position.x +
                        this.mesh.position.y * this.mesh.position.y +
                        this.mesh.position.z * this.mesh.position.z) ** 0.5
            println("  [render] frame=${this.frame} fps=${fps.toString()} " +
                "球体位置=(${this.mesh.position.x.toString()}, " +
                "${this.mesh.position.y.toString()}, " +
                "${this.mesh.position.z.toString()}) " +
                "距原点=${dist.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理音频 + 渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")
        // 打印最终统计信息
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        println("  总帧数: ${this.totalFrames}")
        if (elapsed > 0.0) {
            println("  平均 FPS: ${(Float64(this.totalFrames) / elapsed).toString()}")
        }
        println("")

        // ---- 步骤 5: 清理音频资源 ----
        println("[5/6] 清理音频资源...")
        this.sound.stop()
        this.sound.disconnect()
        let audioCtx = this.listener.context
        audioCtx.shutdown()
        println("  音频已关闭")
        println("")

        // ---- 步骤 6: 关闭渲染器与窗口 ----
        this.renderer.shutdown()
        println("[6/6] ThreeRenderer + WindowEngine 已关闭")
    }
}

main(): Int64 {
    println("=== Three.cj Audio + Rendering 测试 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/6] 创建窗口（WindowEngine）...")
    let win = TestWindow()
    let wok = win.start(title: "three4cj Audio + Rendering", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}

// =============================================================================
// 高级音频能力验证（效果器 8 工厂 / 多普勒 / AudioLoader）
// =============================================================================

/// 验证并落盘 audio_cap.log；效果器对象创建后立即释放（仅验证工厂可用性）
public func verifyAudioCapabilities(listener: AudioListener, sound: PositionalAudio): Unit {
    println("\n=== 高级音频能力验证（效果器/多普勒/AudioLoader） ===")
    let log = StringBuilder()
    log.append("=== 高级音频能力验证（效果器/多普勒/AudioLoader） ===\n")
    var passCount: Int64 = 0
    var failCount: Int64 = 0

    // ---- [A] AudioLoader 解码（miniaudio → AudioBuffer） ----
    log.append("[A] AudioLoader 解码\n")
    let loader = AudioLoader()
    try {
        let buf = loader.load("res/sound.mp3")
        let ok = buf.bufferId != 0u32 && buf.frameCount > 0u64
        if (ok) { passCount += 1 } else { failCount += 1 }
        log.append("  ${if (ok) { "[PASS]" } else { "[FAIL]" }} AudioLoader 加载成功: "
            + "channels=${buf.channels} rate=${buf.sampleRate} frames=${buf.frameCount}\n")
    } catch (e: Exception) {
        failCount += 1
        log.append("  [FAIL] AudioLoader 加载异常: ${e.toString()}\n")
    }

    // ---- [B] 效果器 8 个新工厂创建 ----
    log.append("[B] 效果器 8 个新工厂创建\n")
    let names = ["Distortion", "Flanger", "FrequencyShifter", "PitchShifter",
                 "RingModulator", "Autowah", "Compressor", "VocalMorpher"]
    // 仓颉：lambda 参数须类型标注（无括号），数组元素用 `(Int64) -> AudioEffect` 统一签名
    let factories: Array<(Int64) -> AudioEffect> = [
        { _: Int64 => AudioEffect.createDistortionEffect() },
        { _: Int64 => AudioEffect.createFlangerEffect() },
        { _: Int64 => AudioEffect.createFrequencyShifterEffect() },
        { _: Int64 => AudioEffect.createPitchShifterEffect() },
        { _: Int64 => AudioEffect.createRingModulatorEffect() },
        { _: Int64 => AudioEffect.createAutowahEffect() },
        { _: Int64 => AudioEffect.createCompressorEffect() },
        { _: Int64 => AudioEffect.createVocalMorpherEffect() },
    ]
    var effects = ArrayList<AudioEffect>()
    for (i in 0..factories.size) {
        try {
            let e = factories[i](0)
            let ok = e.effectId != 0u32
            if (ok) { passCount += 1 } else { failCount += 1 }
            log.append("  ${if (ok) { "[PASS]" } else { "[FAIL]" }} ${names[i]} effectId=${e.effectId}\n")
            effects.add(e)
        } catch (ex: Exception) {
            failCount += 1
            log.append("  [FAIL] ${names[i]} 创建异常: ${ex.toString()}\n")
        }
    }

    // ---- [C] 效果槽挂接 + 源发送路径 ----
    log.append("[C] 效果槽挂接\n")
    let slot = AudioEffectSlot()
    try {
        slot.create()
        let ok = slot.slotId != 0u32
        if (ok) { passCount += 1 } else { failCount += 1 }
        log.append("  ${if (ok) { "[PASS]" } else { "[FAIL]" }} 效果槽创建 slotId=${slot.slotId}\n")
        if (effects.size > 0) {
            slot.setEffect(effects[0])  // 挂 Distortion 效果
            log.append("  [info] 效果槽已挂 Distortion\n")
        }
        sound.connectEffectSlot(slot, 0)
        log.append("  [info] PositionalAudio 已连接效果槽 send=0\n")
    } catch (ex: Exception) {
        failCount += 1
        log.append("  [FAIL] 效果槽/发送路径异常: ${ex.toString()}\n")
    }

    // ---- [D] 多普勒设置（setVelocity + 全局因子/声速） ----
    log.append("[D] 多普勒设置\n")
    try {
        listener.context.setDopplerFactor(1.0f32)
        listener.context.setSpeedOfSound(343.3f32)
        sound.setVelocity(Vector3(5.0, 0.0, 0.0))
        passCount += 1
        log.append("  [PASS] setDopplerFactor/setSpeedOfSound/setVelocity 调用成功\n")
        log.append("  [info] velocity=(${sound.getVelocity().x}, ${sound.getVelocity().y}, ${sound.getVelocity().z})\n")
    } catch (ex: Exception) {
        failCount += 1
        log.append("  [FAIL] 多普勒设置异常: ${ex.toString()}\n")
    }

    // 清理：释放效果器与槽（仅验证创建，不长期持有）
    for (e in effects) { e.dispose() }
    slot.dispose()

    log.append("\n=== 能力验证结果 ===\n")
    log.append("  PASS: ${passCount}\n")
    log.append("  FAIL: ${failCount}\n")
    log.append(if (failCount == 0) { "  == 能力验证全部通过 ==\n" } else { "  == 存在失败 ==\n" })
    let out = log.toString()
    println(out)
    try {
        File.appendTo(FsPath("./audio_cap.log"), out.toArray())
    } catch (_) {
        // 忽略落盘失败
    }
}

// =============================================================================
// 麦克风捕获（AudioRecorder）+ HRTF 验证
// =============================================================================

/// 验证麦克风捕获（打开/启动/采样读取/停止/关闭）与 HRTF（设置/枚举/选择）
/// 结果追加到 audio_cap.log；麦克风缺失时打开失败记为 SKIP（环境相关）
public func verifyCaptureAndHrtf(): Unit {
    println("\n=== 麦克风捕获 + HRTF 验证 ===")
    let log = StringBuilder()
    log.append("\n=== 麦克风捕获 + HRTF 验证 ===\n")
    var passCount: Int64 = 0
    var failCount: Int64 = 0

    // ---- [A] AudioRecorder 麦克风捕获 ----
    log.append("[A] AudioRecorder 麦克风捕获\n")
    let recorder = AudioRecorder()
    let opened = recorder.open(44100u32, 1u32, bufferSize: 8192)
    if (!opened) {
        log.append("  [SKIP] 无法打开捕获设备（可能无麦克风），跳过捕获验证\n")
    } else {
        log.append("  [PASS] 捕获设备打开成功: rate=${recorder.frequency} channels=${recorder.channels}\n")
        passCount += 1

        // 启动捕获
        let started = recorder.start()
        if (started) {
            passCount += 1
            log.append("  [PASS] 捕获已启动\n")
        } else {
            failCount += 1
            log.append("  [FAIL] 捕获启动失败\n")
        }

        // 忙等 ~300ms 让采样累积（std.time 忙等，避免引入 std.thread 依赖）
        let waitStart = MonoTime.now()
        while ((MonoTime.now() - waitStart).toMilliseconds() < 300) {
            // 空转等待捕获缓冲累积
        }
        let avail = recorder.getAvailableSamples()
        log.append("  [info] 可用采样帧数=${avail}\n")
        if (avail > 0) {
            passCount += 1
            log.append("  [PASS] 采样读取: getAvailableSamples > 0\n")
        } else {
            failCount += 1
            log.append("  [FAIL] 无采样数据（getAvailableSamples == 0）\n")
        }

        // 读取采样（最多 4096 帧）
        let toRead: Int32 = if (avail > 4096i32) { 4096i32 } else { avail }
        if (toRead > 0) {
            let pcmBuf = unsafe { LibC.malloc<UInt8>(count: Int64(toRead) * 2) }
            let bytes = recorder.readSamples(pcmBuf, toRead)
            unsafe { LibC.free(pcmBuf) }
            if (bytes == toRead * 2) {
                passCount += 1
                log.append("  [PASS] readSamples 读取 ${toRead} 帧 / ${bytes} 字节\n")
            } else {
                failCount += 1
                log.append("  [FAIL] readSamples 返回字节数异常: ${bytes}\n")
            }
        }

        // 停止 + 关闭
        recorder.stop()
        recorder.close()
        if (!recorder.opened) {
            passCount += 1
            log.append("  [PASS] 捕获已停止并关闭设备\n")
        } else {
            failCount += 1
            log.append("  [FAIL] 设备关闭失败\n")
        }
    }

    // ---- [B] HRTF 设置与枚举 ----
    log.append("[B] HRTF 设置与枚举\n")
    let ctx = AudioContext.context
    ctx.setHrtfEnabled(true)
    let status = ctx.getHrtfStatus()
    log.append("  [info] HRTF 状态码=${status}（1=启用 2=拒绝 3=必需 4=检测到头戴 5=格式不支持）\n")
    let hrtfCount = ctx.getHrtfCount()
    if (hrtfCount > 0) {
        passCount += 1
        log.append("  [PASS] 可用 HRTF 数量=${hrtfCount}\n")
        let names = ctx.getHrtfList()
        for (i in 0..names.size) {
            log.append("  [info]   HRTF[${i}] = ${names[i]}\n")
        }
        // 选择第一个 HRTF
        ctx.selectHrtf(0)
        passCount += 1
        log.append("  [PASS] selectHrtf(0) 调用成功\n")
    } else {
        log.append("  [info] 设备无可用 HRTF（数量=0，环境相关，不判失败）\n")
    }

    log.append("\n=== 捕获+HRTF 验证结果 ===\n")
    log.append("  PASS: ${passCount}\n")
    log.append("  FAIL: ${failCount}\n")
    log.append(if (failCount == 0) { "  == 捕获+HRTF 验证通过 ==\n" } else { "  == 存在失败 ==\n" })
    let out = log.toString()
    println(out)
    try {
        File.appendTo(FsPath("./audio_cap.log"), out.toArray())
    } catch (_) {
        // 忽略落盘失败
    }
}
