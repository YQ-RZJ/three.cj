package sp_ssr

/**
 * capture.cj —— SSR 中间 RT 调试诊断（句柄索引通道）
 *
 * 触发方式：
 *   - 交互：窗口内按 C 键（win32.cj WM_KEYDOWN → requestCapture()）
 *   - 自动：命令行参数 --capture（main.cj 置 g_capAuto=true），第 45 帧自动抓取，
 *     输出完成后自动退出渲染循环，便于无人值守诊断。
 *
 * 渲染抽象重构后的迁移说明（renderers-abstraction-refactor 5.1）：
 *   - 旧实现的 GPU→CPU 像素回读管线（TEXTURE_READ_BACK 纹理 + blitTexture +
 *     readTexture + 落盘 capture 目录下 .raw 文件）依赖已收窄的 ThreeRenderer 薄包装 API
 *     与句柄类型，模块外不可再见（引擎暂无公开回读支撑面）。
 *   - 迁移后走 SSRPass/EffectComposer 的只读句柄索引公开通道
 *     （normalTextureIdx/depthTextureIdx/ssrTextureIdx/blur2TextureIdx/
 *     currentReadFrameBufferIdx），输出中间 RT 的句柄索引与尺寸诊断，
 *     验证后处理链资源分配正常；像素级回读待引擎提供公开回读 API 后恢复。
 *
 * 分层原则：本测试项目只使用引擎公开接口（ThreeRenderer 保留面 /
 * SSRPass/EffectComposer 公开通道），不接触句柄类型。
 */

import std.env.*
import std.sync.*
import std.collection.*
import three.renderers.ThreeRenderer
import three.renderers.postprocessing.SSRPass
import three.renderers.postprocessing.EffectComposer

// ===== 抓取状态机 =====
var g_capState: Int64 = 0      // 0=idle，1=已请求、本帧输出
var g_capAuto: Bool = false    // --capture 自动模式
let g_capRequested = AtomicBool(false)

/** 请求抓取一帧的 SSR 全部中间 RT 诊断输出（'C' 键 / --capture 自动模式） */
public func requestCapture(): Unit {
    g_capRequested.store(true)
}

/**
 * 每帧调用（composer.render 之后）：推进抓取状态机。
 *
 * @param frame 当前帧号（自动模式第 45 帧触发）
 * @param near/far 相机近远平面（诊断输出附注）
 */
public func tickCapture(
    renderer: ThreeRenderer,
    ssrPass: SSRPass,
    composer: EffectComposer,
    frame: Int64,
    near: Float64,
    far: Float64
): Unit {
    if (g_capAuto && g_capState == 0 && frame == 45) {
        println("[capture] --capture 自动模式：第 45 帧触发诊断输出")
        g_capRequested.store(true)
    }
    if (g_capState == 0) {
        if (g_capRequested.load()) {
            g_capRequested.store(false)
            _dumpDiagnostics(ssrPass, composer, near, far)
            g_capState = 1
        }
    } else {
        // 输出已完成：复位；自动模式直接退进程（渲染线程同步存在死锁风险，
        // 进程退出由 OS 回收全部资源）。
        g_capState = 0
        if (g_capAuto) {
            println("[capture] 自动模式诊断输出完成，退出渲染循环")
            getStdOut().flush()
            exit(0)
        }
    }
}

/** 输出 SSR 后处理链全部中间 RT 的句柄索引与尺寸诊断（经公开只读通道） */
func _dumpDiagnostics(ssrPass: SSRPass, composer: EffectComposer, near: Float64, far: Float64): Unit {
    let w = ssrPass.rtWidth()
    let h = ssrPass.rtHeight()
    if (w <= 0 || h <= 0) {
        println("[capture] pass RT 尺寸无效（首帧前？），放弃诊断输出")
        return
    }
    println("[capture] SSR 中间 RT 诊断（${w}x${h}, near=${near}, far=${far}）：")
    println("  [capture] scene(readBuffer).idx=${composer.currentReadFrameBufferIdx()}")
    println("  [capture] normal.idx=${ssrPass.normalTextureIdx()}")
    println("  [capture] depth.idx=${ssrPass.depthTextureIdx()}")
    println("  [capture] ssr.idx=${ssrPass.ssrTextureIdx()}")
    println("  [capture] blur2.idx=${ssrPass.blur2TextureIdx()}")
    match (ssrPass.groundReflector) {
        case Some(reflector) =>
            let (rtW, rtH) = reflector.getTextureSize()
            if (rtW > 0 && rtH > 0) {
                println("  [capture] reflectRT ${rtW}x${rtH} depthTex=${reflector.useDepthTexture.toString()}（反射 RT 像素内容回读待引擎公开回读 API）")
            } else {
                println("  [capture] 反射 RT 尺寸无效")
            }
        case None => println("  [capture] 无 groundReflector")
    }
    getStdOut().flush()
}
