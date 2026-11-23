/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] IRenderPipeline 渲染编排接口
 * @brief[zh-cn] 渲染管线编排契约（即时命令模型），叠加在 GPU API 抽象之上
 * @explain[zh-cn] 本接口承接原 common/Backend 抽象基类的编排职责：Renderer 基类
 * 的 _render 调度管线经本接口驱动后端（beginRender → draw → finishRender，外加
 * 阴影预 pass 与调试 blit 钩子）。它继承根包 IRenderBackend（GPU API 契约），
 * 使渲染器仅需持有一个后端引用即可同时使用两层能力。
 * 可见性设计：声明为顶层 protected（= 当前模块内全部包可见），使
 * three.renderers（Renderer 调用方）、three.renderers._bgfx（BgfxBackend 实现
 * 方）、后处理等引擎子包都能引用，而模块外（测试项目、用户项目）不可见——
 * 编排接口与 GPU API 契约一样属于引擎内部抽象层。参数类型 IRenderObject/
 * IRenderContext 已按 C9 收纳至 three.renderers._interfaces 子包，经本包
 * public import 重导出。
 *
 * @file[en] IRenderPipeline render pipeline orchestration interface
 * @brief[en] The render pipeline orchestration contract (immediate command model), layered on top of the GPU API abstraction
 * @explain[en] This interface takes over the orchestration duty of the former
 * common/Backend abstract base class: the Renderer base class's _render scheduling
 * pipeline drives the backend through it (beginRender → draw → finishRender, plus
 * the shadow pre-pass and debug blit hooks). It extends the root-package
 * IRenderBackend (the GPU API contract), so the renderer holds a single backend
 * reference covering both layers.
 * Visibility design: declared top-level protected (= visible to all packages in the
 * current module), so three.renderers (the Renderer caller), three.renderers._bgfx
 * (the BgfxBackend implementer) and other engine subpackages can all reference it,
 * while it stays invisible outside the module (test projects, user projects) — the
 * orchestration interface belongs to the engine-internal abstraction layer just like
 * the GPU API contract. Parameter types IRenderObject/IRenderContext have been
 * collected into the three.renderers._interfaces subpackage per C9 and are
 * re-exported by this package via public import.
 *
 * @package three.renderers.common
 */
package three.renderers.common

import three.renderers._interfaces.IRenderBackend
import three.scene.scenegraph.Scene

public import three.renderers._interfaces.IRenderObject
public import three.renderers._interfaces.IRenderContext

protected interface IRenderPipeline <: IRenderBackend {
    /**
     * 开始渲染 pass（清屏/视口/视图变换等 pass 级状态就绪）。
     */
    func beginRender(renderContext: IRenderContext): Unit

    /**
     * 开始渲染 pass（RenderContext 具体类重载）。
     */
    func beginRender(renderContext: RenderContext): Unit

    /**
     * 执行一次绘制（提交当前渲染对象）。
     */
    func draw(renderObject: IRenderObject): Unit

    /**
     * 结束渲染 pass（帧收尾/上屏驱动）。
     */
    func finishRender(renderContext: IRenderContext): Unit

    /**
     * 结束渲染 pass（RenderContext 具体类重载）。
     */
    func finishRender(renderContext: RenderContext): Unit

    /**
     * 结束离屏渲染 pass（仅 touchView 标记活跃并失效帧内光源缓存，不触发上屏/帧提交）。
     */
    func finishRenderPass(renderContext: RenderContext): Unit

    /**
     * 阴影深度预 pass 钩子（主渲染前生成阴影贴图）。
     */
    func prepareShadowMap(scene: Scene): Unit

    /**
     * 绑定阴影 uniform 到主 pass draw。
     */
    func bindShadowUniforms(): Unit

    /**
     * 全屏 blit 阴影贴图到屏幕（调试用）。
     */
    func blitShadowMap(mainViewId: UInt16): Unit
}
