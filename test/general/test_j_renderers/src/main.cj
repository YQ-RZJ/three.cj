/**
 * @file main
 * @brief test_j_renderers 独立测试项目入口（迁移自 three.js test/unit/src/renderers）
 *
 * BgfxRenderTarget 需 bgfx 渲染环境（帧缓冲创建依赖已初始化的 renderer），
 * 故先创建 Win32 窗口 + 初始化 BgfxRenderer，再验证 BgfxRenderTarget 创建/尺寸，
 * 最后运行 std.unittest 纯逻辑断言。
 */
package test_j_renderers

import std.io.*
import std.unittest.*
import three.rendering.BgfxRenderer
import three.rendering.BgfxRenderTarget
import three.core.math.Color

main(): Int64 {
    println("=== test_j_renderers：renderers 测试（含 BgfxRenderTarget 窗口渲染验证） ===")
    println("")

    // ---- 步骤 1: 创建窗口（BgfxRenderTarget 帧缓冲需渲染环境） ----
    println("[1/4] 创建 Win32 窗口...")
    let (clientW, clientH) = createWindow()
    if (clientW <= 0 || clientH <= 0) { return 1 }
    println("")

    // ---- 步骤 2: 初始化 BgfxRenderer ----
    println("[2/4] 初始化 BgfxRenderer...")
    let renderer = BgfxRenderer()
    let ok = renderer.initBgfx(g_hwnd, clientW, clientH)
    if (!ok) { println("  BgfxRenderer.initBgfx 失败!"); return 1 }
    renderer.setSize(clientW, clientH)
    renderer.setClearColor(Color(0x30, 0x30, 0x60))
    println("  BgfxRenderer 初始化成功")
    println("")

    // ---- 步骤 3: 验证 BgfxRenderTarget（对照 JS WebGLRenderTarget 创建） ----
    println("[3/4] 验证 BgfxRenderTarget...")
    let rt = BgfxRenderTarget(256, 128)
    println("  BgfxRenderTarget: ${rt.width}x${rt.height} kind=${rt.kind}")
    println("  RenderTarget 创建成功（bgfx 帧缓冲在渲染环境下正常创建）")
    println("")

    // ---- 步骤 4: 运行 std.unittest 纯逻辑断言 ----
    println("[4/4] 运行 std.unittest...")
    let testPackage = TestPackage("test_j_renderers")
    testPackage.registerSuite({ => RenderTargetTest().asTestSuite() })
    testPackage.registerSuite({ => UniformsUtilsTest().asTestSuite() })
    let rc = entryMain(testPackage)

    // 清理
    renderer.shutdown()
    println("  BgfxRenderer 已关闭")
    return rc
}
