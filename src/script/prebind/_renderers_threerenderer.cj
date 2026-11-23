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
 * @file[zh-cn] renderers_threerenderer ThreeRenderer 渲染器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.ThreeRenderer 绑定为 Lua 类型 three.renderers.ThreeRenderer
 * @explain[zh-cn] 覆盖脚本开发所需的全部 public 方法：
 * - 构造：new()；
 * - 初始化：initBgfx(hwnd, width, height[, vsync, msaa, maxAnisotropy, numBackBuffers,
 *   maxFrameLatency])（hwnd 取 WindowEngine.getNativeWindowHandle() 的整数值）；
 * - 渲染入口：render(scene, camera) / renderAsync(scene, camera) / syncFrame() /
 *   present([capture])；
 * - 呈现与调试配置：viewId / clearColor（RGBA32）/ setClearColor(color[, alpha]) /
 *   setSize(width, height) / setShadowType(value) / setWireframe(enabled) / setDebug(flags) /
 *   getRendererType()（抽象后端类型枚举数值）/ getCapabilities()（GfxCapsSummary）/
 *   release()，以及只读 releasable（ThreeRenderer 实现 IReleasable）；
 * - 抽象层工厂：makeShaderProgram(name, vs, fs[, varyingDef]) 返回 IShaderProgram；
 *   makeUniformRegistry() 返回 IUniformRegistry；
 * - 继承自 Renderer 的通用配置（直接在 ThreeRenderer 表上暴露）：width / height / autoClear /
 *   autoClearColor / autoClearDepth / autoClearStencil / alpha / depth / stencil /
 *   outputColorSpace / toneMapping / toneMappingExposure / logarithmicDepthBuffer /
 *   reversedDepthBuffer / sortObjects / samples / enableSpatialCulling / frameIndex（只读）/
 *   getSize()（返回 [w, h]）/ setPixelRatio / getPixelRatio；
 * - 渲染统计：info（返回 three.renderers.common.Info 注册对象，与渲染器同一实例，实时反映
 *   calls / triangles / vertices / frame 及 render / compute / memory 子统计）；
 * - 渲染目标：setRenderTarget(renderTarget, cubeFace[, mipLevel]) /
 *   getRenderTarget()（返回 RenderTarget 或 nil）；
 * - 线程序列化逃生舱：runOnRenderThread(callback)（同步投递到渲染线程执行，回调在渲染线程运行）；
 * - 顶层常量：DEFAULT_RENDERER_TYPE / CLEAR_COLOR / CLEAR_DEPTH / BGFX_ATTRIB_POSITION /
 *   BGFX_UNIFORM_VEC4 / BGFX_UNIFORM_MAT4 挂到类表上以同名 staticMethod 暴露，
 *   Lua 侧按函数取值（如 ThreeRenderer.CLEAR_COLOR()）。
 * 使用前提：initBgfx 与一切 GPU 命令方法经渲染后端命令队列（runOnRenderThread）投递到渲染线程
 * 并等待完成；渲染器必须已由引擎完成渲染后端初始化（渲染线程已启动）后调用，否则主线程会
 * 阻塞等待。new() / 属性读写 / 工厂方法可安全调用。
 * 跳过成员：Renderer 内部数据结构（renderLists / renderContexts / renderObjects / lighting /
 * background / renderBundles 等复杂容器）、渲染管线内部钩子 getRenderViewId /
 * _syncRenderStats、getSceneMeshes（返回内部渲染对象列表）。
 *
 * @file[en] renderers_threerenderer  Lua binding of the ThreeRenderer renderer
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.ThreeRenderer as the Lua type three.renderers.ThreeRenderer
 * @explain[en] Covers every public method a script needs:
 * - constructor: new();
 * - initialization: initBgfx(hwnd, width, height[, vsync, msaa, maxAnisotropy, numBackBuffers,
 *   maxFrameLatency]) (hwnd is the integer from WindowEngine.getNativeWindowHandle());
 * - render entry points: render(scene, camera) / renderAsync(scene, camera) / syncFrame() /
 *   present([capture]);
 * - presentation and debug config: viewId / clearColor (RGBA32) / setClearColor(color[, alpha]) /
 *   setSize(width, height) / setShadowType(value) / setWireframe(enabled) / setDebug(flags) /
 *   getRendererType() (the abstract backend type enum value) / getCapabilities() (GfxCapsSummary) /
 *   release(), plus read-only releasable (ThreeRenderer implements IReleasable);
 * - abstraction factories: makeShaderProgram(name, vs, fs[, varyingDef]) returns IShaderProgram;
 *   makeUniformRegistry() returns IUniformRegistry;
 * - common Renderer config (exposed directly on the ThreeRenderer table): width / height /
 *   autoClear / autoClearColor / autoClearDepth / autoClearStencil / alpha / depth / stencil /
 *   outputColorSpace / toneMapping / toneMappingExposure / logarithmicDepthBuffer /
 *   reversedDepthBuffer / sortObjects / samples / enableSpatialCulling / frameIndex (read-only) /
 *   getSize() (returns [w, h]) / setPixelRatio / getPixelRatio;
 * - render statistics: info (returns the registered three.renderers.common.Info object; it is the
 *   same instance as the renderer's, so calls / triangles / vertices / frame and the
 *   render / compute / memory sub-statistics are always current);
 * - render target: setRenderTarget(renderTarget, cubeFace[, mipLevel]) /
 *   getRenderTarget() (returns a RenderTarget or nil);
 * - thread-serialization escape hatch: runOnRenderThread(callback) (posts synchronously onto the
 *   render thread; the callback runs there);
 * - top-level constants: DEFAULT_RENDERER_TYPE / CLEAR_COLOR / CLEAR_DEPTH /
 *   BGFX_ATTRIB_POSITION / BGFX_UNIFORM_VEC4 / BGFX_UNIFORM_MAT4 are attached to the class
 *   table as same-named staticMethods and read from Lua as functions
 *   (e.g. ThreeRenderer.CLEAR_COLOR()).
 * Precondition: initBgfx and every GPU command method go through the render-backend command queue
 * (runOnRenderThread), which posts to the render thread and waits for completion; they may only be
 * called after the engine has finished render-backend initialization (render thread running),
 * otherwise the caller thread blocks. new() / property reads / factory methods are safe at any time.
 * Skipped members: Renderer internal data structures (renderLists / renderContexts / renderObjects /
 * lighting / background / renderBundles and other complex containers), the internal pipeline
 * hooks getRenderViewId / _syncRenderStats, and getSceneMeshes (returns internal render objects).
 */
package three.script.prebind

import three.renderers.{ThreeRenderer, DEFAULT_RENDERER_TYPE, CLEAR_COLOR, CLEAR_DEPTH, BGFX_ATTRIB_POSITION, 
    BGFX_UNIFORM_VEC4, BGFX_UNIFORM_MAT4}
import three.renderers.cameras.Camera
import three.renderers.common.GfxRendererType
import three.renderers.rendertarget.RenderTarget
import three.scene.scenegraph.Scene
import three.core.math.Color
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ThreeRenderer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.ThreeRenderer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ThreeRenderer
 * @param[en] vm The target virtual machine (class table at three.renderers.ThreeRenderer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installThreeRenderer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.ThreeRenderer")
    // ===== 构造 =====
    b.constructor {_ => ThreeRenderer()}
    // ===== 初始化（hwnd 为整数原生窗口句柄） =====
    b.method("initBgfx") {
        ref, args => [LuaValue.of(
            ref
                .cast<ThreeRenderer>()
                .initBgfx(UIntNative(UInt64(prebindInt(args, 0))), Int32(prebindInt(args, 1)), Int32(prebindInt(args, 2)),
                    vsync: prebindBool(args, 3), msaa: UInt32(prebindInt(args, 4) & 0xFFFFFFFF),
                    maxAnisotropy: UInt32(prebindInt(args, 5) & 0xFFFFFFFF),
                    numBackBuffers: UInt8(prebindInt(args, 6, default: 2) & 0xFF),
                    maxFrameLatency: UInt8(prebindInt(args, 7, default: 2) & 0xFF)))]
    }
    // ===== 抽象层工厂 =====
    b.staticMethod("makeShaderProgram") {
        args => [prebindRegister(
            ThreeRenderer.makeShaderProgram(prebindStr(args, 0), prebindStr(args, 1), prebindStr(args, 2),
                varyingDef: prebindStr(args, 3)), "three.renderers._interfaces.IShaderProgram")]
    }
    b.staticMethod("makeUniformRegistry") {
        _ => [prebindRegister(ThreeRenderer.makeUniformRegistry(), "three.renderers._interfaces.IUniformRegistry")]
    }
    // ===== 呈现配置 =====
    b.property("viewId", getter: Some({ref => LuaValue.of(Int64(ref.cast<ThreeRenderer>().viewId))}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().viewId = UInt16(v.intValue())}))
    b.property("clearColor", getter: Some({ref => LuaValue.of(Int64(ref.cast<ThreeRenderer>().clearColor))}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().clearColor = UInt32(v.intValue())}))
    b.method("setClearColor") {
        ref, args =>
            ref.cast<ThreeRenderer>().setClearColor(prebindAs<Color>(args, 0), alpha: prebindNum(args, 1, default: 1.0))
            Array<LuaValue>()
    }
    b.method("setSize") {
        ref, args =>
            ref.cast<ThreeRenderer>().setSize(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            Array<LuaValue>()
    }
    b.method("setShadowType") {
        ref, args =>
            ref.cast<ThreeRenderer>().setShadowType(prebindInt(args, 0))
            Array<LuaValue>()
    }
    b.method("setWireframe") {
        ref, args =>
            ref.cast<ThreeRenderer>().setWireframe(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.method("getRendererType") {
        ref, _ => [LuaValue.of(Int64(ref.cast<ThreeRenderer>().getRendererType().value()))]
    }
    b.method("setDebug") {
        ref, args =>
            ref.cast<ThreeRenderer>().setDebug(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    b.method("getCapabilities") {
        ref, _ => [prebindRegister(ref.cast<ThreeRenderer>().getCapabilities(), "three.renderers.common.GfxCapsSummary")]
    }
    // ===== 继承自 Renderer 的通用渲染配置（在 ThreeRenderer 表上直接暴露） =====
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().width)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().width = v.intValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().height)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().height = v.intValue()}))
    b.property("autoClear", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().autoClear)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().autoClear = v.boolValue()}))
    b.property("autoClearColor", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().autoClearColor)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().autoClearColor = v.boolValue()}))
    b.property("autoClearDepth", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().autoClearDepth)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().autoClearDepth = v.boolValue()}))
    b.property("autoClearStencil", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().autoClearStencil)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().autoClearStencil = v.boolValue()}))
    b.property("alpha", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().alpha)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().alpha = v.boolValue()}))
    b.property("depth", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().depth)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().depth = v.boolValue()}))
    b.property("stencil", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().stencil)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().stencil = v.boolValue()}))
    b.property("outputColorSpace", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().outputColorSpace)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().outputColorSpace = v.stringValue()}))
    b.property("toneMapping", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().toneMapping)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().toneMapping = v.intValue()}))
    b.property("toneMappingExposure", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().toneMappingExposure)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().toneMappingExposure = v.numberValue()}))
    b.property("logarithmicDepthBuffer",
        getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().logarithmicDepthBuffer)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().logarithmicDepthBuffer = v.boolValue()}))
    b.property("reversedDepthBuffer", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().reversedDepthBuffer)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().reversedDepthBuffer = v.boolValue()}))
    b.property("sortObjects", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().sortObjects)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().sortObjects = v.boolValue()}))
    b.property("samples", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().samples)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().samples = v.intValue()}))
    b.property("enableSpatialCulling",
        getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().enableSpatialCulling)}),
        setter: Some({ref, v => ref.cast<ThreeRenderer>().enableSpatialCulling = v.boolValue()}))
    b.property("frameIndex", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().frameIndex)}))
    // ===== 渲染统计（同一实例，实时反映当前统计） =====
    b.property("info",
        getter: Some({ref => prebindRegister(ref.cast<ThreeRenderer>().info, "three.renderers.common.Info")}))
    b.method("getSize") {
        ref, _ =>
            let (w, h) = ref.cast<ThreeRenderer>().getSize()
            [LuaValue.Array([LuaValue.of(w), LuaValue.of(h)])]
    }
    b.method("setPixelRatio") {
        ref, args =>
            ref.cast<ThreeRenderer>().setPixelRatio(prebindNum(args, 0, default: 1.0))
            Array<LuaValue>()
    }
    b.method("getPixelRatio") {
        ref, _ => [LuaValue.of(ref.cast<ThreeRenderer>().getPixelRatio())]
    }
    // ===== 渲染目标 =====
    b.method("setRenderTarget") {
        ref, args =>
            ref
                .cast<ThreeRenderer>()
                .setRenderTarget(prebindAs<RenderTarget>(args, 0), prebindInt(args, 1), prebindInt(args, 2))
            Array<LuaValue>()
    }
    b.method("getRenderTarget") {
        ref, _ => match (ref.cast<ThreeRenderer>().getRenderTarget()) {
            case Some(rt) => [prebindRegister(rt, "three.renderers.rendertarget.RenderTarget")]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 线程序列化逃生舱（回调在渲染线程同步执行） =====
    b.method("runOnRenderThread") {
        ref, args =>
            let fnValue = if (args.size > 0) {
                args[0]
            } else {
                LuaValue.Nil
            }
            ref.cast<ThreeRenderer>().runOnRenderThread({
                => if (let Some(cb) <- LuaCallback.fromValue(vm, fnValue)) {
                    try {
                        cb.call(args: Array<LuaValue>())
                    } catch (_: Exception) {
                        // 回调异常不打断渲染线程
                    }
                }
            })
            Array<LuaValue>()
    }
    // ===== 渲染入口 =====
    b.method("render") {
        ref, args =>
            ref.cast<ThreeRenderer>().render(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
            Array<LuaValue>()
    }
    b.method("renderAsync") {
        ref, args =>
            ref.cast<ThreeRenderer>().renderAsync(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
            Array<LuaValue>()
    }
    b.method("syncFrame") {
        ref, _ =>
            ref.cast<ThreeRenderer>().syncFrame()
            Array<LuaValue>()
    }
    b.method("present") {
        ref, args =>
            ref.cast<ThreeRenderer>().present(capture: prebindBool(args, 0))
            Array<LuaValue>()
    }
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<ThreeRenderer>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<ThreeRenderer>().release())]
    }
    // ===== 顶层常量（按函数取值） =====
    b.staticMethod("DEFAULT_RENDERER_TYPE") {_ => [LuaValue.of(Int64(DEFAULT_RENDERER_TYPE))]}
    b.staticMethod("CLEAR_COLOR") {_ => [LuaValue.of(Int64(CLEAR_COLOR))]}
    b.staticMethod("CLEAR_DEPTH") {_ => [LuaValue.of(Int64(CLEAR_DEPTH))]}
    b.staticMethod("BGFX_ATTRIB_POSITION") {_ => [LuaValue.of(Int64(BGFX_ATTRIB_POSITION))]}
    b.staticMethod("BGFX_UNIFORM_VEC4") {_ => [LuaValue.of(Int64(BGFX_UNIFORM_VEC4))]}
    b.staticMethod("BGFX_UNIFORM_MAT4") {_ => [LuaValue.of(Int64(BGFX_UNIFORM_MAT4))]}
    b.install(vm)
}
