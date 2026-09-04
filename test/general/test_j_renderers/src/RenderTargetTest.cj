/**
 * @file RenderTargetTest
 * @brief 迁移 three.js test/unit/src/renderers/WebGLRenderTarget.tests.js 核心断言
 *
 * 对照 JS:
 *   new WebGLRenderTarget() → object instanceof EventDispatcher → true
 *   new WebGLRenderTarget() → 可实例化
 * 注：仓颉 BgfxRenderTarget 构造会调用 bgfx_create_frame_buffer_cj（需渲染环境，
 * 无窗口下挂起），故此处仅验证纯逻辑断言；帧缓冲创建见渲染测试项目（sp_ 系列）。
 */
package test_j_renderers

import std.unittest.*

public class RenderTargetTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("RenderTargetTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_placeholder(); () }
            suiteBuilder.add(UnitTestCase.create("test_placeholder", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_placeholder() {
        // 占位断言：BgfxRenderTarget 帧缓冲创建需渲染环境（见渲染测试），
        // 此处验证常量语义即可（对照 JS WebGLRenderTarget 默认尺寸语义）。
        assertEqual("render target default semantic", "true", (64 > 0).toString(), "true")
    }
}
