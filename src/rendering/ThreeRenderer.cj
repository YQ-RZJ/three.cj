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
 * @file[zh-cn] ThreeRenderer bgfx 渲染器
 * @brief[zh-cn] bgfx 渲染器 — Renderer 子类的薄实现
 * @explain[zh-cn] ThreeRenderer <: Renderer，继承 Renderer 的 _render 调度层，
 *
 * @file[en] ThreeRenderer bgfx renderer
 * @brief[en] bgfx renderer — thin implementation of Renderer subclass
 * @explain[en] ThreeRenderer <: Renderer, inherits Renderer's _render scheduling layer,
 * - _execBgfx: all bgfx API calls are delegated to a dedicated system thread
 * - initBgfx: bgfx_init_cj + platformData.nwh
 * - render: delegates to Renderer pipeline via _execBgfx → _render(scene, camera)
 * All rendering logic is handled by backend: BgfxBackend + subsystems (RenderLists/RenderContexts etc.).
 *
 * @package three.rendering
 */
package three.rendering

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.scenegraph.*
import three.rendering.materials.*
import three.rendering.cameras.*
import three.rendering.textures.*
import three.rendering.interfaces.IRenderer
import three.rendering.interfaces.IRenderTarget
import three.rendering.common.*
import three.rendering.shaders.*
import three.rendering.bgfx.*
import three.rendering.bgfx.*
import three.rendering.types.*
import three.core.thread.*
import three.utils.memory.intToCPointer
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.memory.PtrArray
import bgfx4cj.bgfx as bgfx
import bgfx4cj.bx.*
import std.collection.*
import std.runtime.*
import std.time.*

// ===== 跨平台渲染器选择 =====

/**
 * @brief[zh-cn] 默认渲染器类型（根据平台自动选择 Direct3D11/Vulkan/OpenGLES/Metal）
 *
 * @brief[en] Default renderer type (auto-selected per platform: Direct3D11/Vulkan/OpenGLES/Metal)
 */
@When[os == "Windows"]
public let DEFAULT_RENDERER_TYPE: UInt32 = RendererType.Direct3D11.value()

/**
 * @brief[zh-cn] 默认渲染器类型（Linux GNU：Vulkan）
 *
 * @brief[en] Default renderer type (Linux GNU: Vulkan)
 */
@When[os == "Linux" && env == "gnu"]
public let DEFAULT_RENDERER_TYPE: UInt32 = RendererType.Vulkan.value()

/**
 * @brief[zh-cn] 默认渲染器类型（Android：OpenGLES）
 *
 * @brief[en] Default renderer type (Android: OpenGLES)
 */
@When[os == "Linux" && env == "android"]
public let DEFAULT_RENDERER_TYPE: UInt32 = RendererType.OpenGLES.value()

/**
 * @brief[zh-cn] 默认渲染器类型（OpenHarmony：OpenGLES）
 *
 * @brief[en] Default renderer type (OpenHarmony: OpenGLES)
 */
@When[os == "Linux" && env == "ohos"]
public let DEFAULT_RENDERER_TYPE: UInt32 = RendererType.OpenGLES.value()

/**
 * @brief[zh-cn] 默认渲染器类型（macOS/iOS：Metal）
 *
 * @brief[en] Default renderer type (macOS/iOS: Metal)
 */
@When[os == "macOS" || os == "iOS"]
public let DEFAULT_RENDERER_TYPE: UInt32 = RendererType.Metal.value()

/**
 * @brief[zh-cn] 默认渲染器类型（未知平台回退值）
 *
 * @brief[en] Default renderer type (unknown platform fallback value)
 */
@When[
    os != "Windows" &&
    os != "Linux" &&
    os != "macOS" &&
    os != "iOS"
]
public let DEFAULT_RENDERER_TYPE: UInt32 = 0u32

/**
 * @brief[zh-cn] 清除颜色标志位
 *
 * @brief[en] Clear color flag bit
 */
public let CLEAR_COLOR: UInt16 = 0x0001u16

/**
 * @brief[zh-cn] 清除深度标志位
 *
 * @brief[en] Clear depth flag bit
 */
public let CLEAR_DEPTH: UInt16 = 0x0002u16

/**
 * @brief[zh-cn] bgfx 顶点属性语义：位置
 *
 * @brief[en] bgfx vertex attribute semantic: position
 */
public let BGFX_ATTRIB_POSITION: UInt32 = 0u32

/**
 * @brief[zh-cn] bgfx uniform 类型：Vec4
 *
 * @brief[en] bgfx uniform type: Vec4
 */
public let BGFX_UNIFORM_VEC4: UInt32 = UniformType.Vec4.value()

/**
 * @brief[zh-cn] bgfx uniform 类型：Mat4
 *
 * @brief[en] bgfx uniform type: Mat4
 */
public let BGFX_UNIFORM_MAT4: UInt32 = UniformType.Mat4.value()

/**
 * @brief[zh-cn] bgfx 渲染器 — Renderer 薄实现
 * @explain[zh-cn] 继承 Renderer 的 _render 调度管线，仅封装 bgfx 专用线程约束。
 * - finishRender → bgfx_touch
 *
 * @brief[en] bgfx renderer — thin Renderer implementation
 * @explain[en] All rendering logic is handled by backend: BgfxBackend:
 * - beginRender → bgfx_set_view_rect + bgfx_set_view_clear
 * - draw → bgfx_set_vertex_buffer + bgfx_set_state + bgfx_submit
 * - finishRender → bgfx_touch
 * Inherits Renderer's _render scheduling pipeline, only encapsulates bgfx-specific thread constraints.
 * All rendering logic is handled by backend: BgfxBackend:
 */
public class ThreeRenderer <: Renderer & IRenderer {
    /**
     * @brief[zh-cn] 当前渲染 view id
     *
     * @brief[en] Current render view id
     */
    public var viewId: UInt16 = 0u16
    /**
     * @brief[zh-cn] 清除色（RGBA32）
     *
     * @brief[en] Clear color (RGBA32)
     */
    public var clearColor: UInt32 = 0x00000000u32

    /**
     * @brief[zh-cn] 设置清除色 — Three.js 对齐：renderer.setClearColor(color, alpha)
     * @param[zh-cn] color 清除颜色
     * alpha 透明度，默认 1.0
     *
     * @brief[en] Set clear color — Three.js alignment: renderer.setClearColor(color, alpha)
     * @param[en] color Clear color
     * alpha Alpha value, default 1.0
     */
    public func setClearColor(color: Color, alpha!: Float64 = 1.0): Unit {
        let r = UInt8(color.r * 255.0)
        let g = UInt8(color.g * 255.0)
        let b = UInt8(color.b * 255.0)
        let a = UInt8(alpha * 255.0)
        let newColor = (UInt32(r) << 24) | (UInt32(g) << 16) | (UInt32(b) << 8) | UInt32(a)
        this.clearColor = newColor
        // 同步到 backend.clearColor，供 BgfxBackend.beginRender 读取（避免循环依赖）
        this.backend.clearColor = newColor
        // bgfx API 必须在渲染线程执行
        _execBgfx({ =>
            bgfx.bgfx_set_view_clear_cj(this.viewId, CLEAR_COLOR | CLEAR_DEPTH, this.clearColor, 1.0f32, 0)
        })
    }

    // ===== bgfx 同步原语 =====
    // 使用 three.core.thread 的系统级 Mutex/Condition（基于 sdl4cj，而非 std.sync），
    // 因为需要跨用户态与系统线程同步。
    private var _renderMtx = Mutex()
    private var _renderCmdCnd = Condition()
    private var _renderDoneCnd = Condition()
    // FIFO 命令队列 + 单调完成序号（多提交者并发安全）：
    // 旧实现用共享布尔 _renderDone + 单次 signal() 通知完成，多个提交者
    // （ArkTS 主线程 setColor 等参数更新 + 窗口泵线程 onFrame render）并发时，
    // 提交者的唤醒会被彼此吞掉（_renderDone 被重置 / signal 被别的等待者消费），
    // 导致某个提交者永久孤儿等待 → 泵线程 onFrame 不返回 → shutdown().wait() 死锁。
    // 新实现：每个提交者持有自己的序号，等待 doneSeq 追上该序号；完成时
    // broadcast 唤醒全部等待者，各自由谓词判断是否继续等待。
    private var _renderQueue = ArrayList<() -> Unit>()
    private var _renderSubmitSeq: Int64 = 0
    private var _renderDoneSeq: Int64 = 0
    private var _renderExit: Bool = false
    private var _renderSThread: Option<SThread<Unit>> = None
    private var _renderReady: Bool = false
    private var _initBgfxResult: Bool = false

    // ===== BgfxBackend 后端 =====
    // 通过父类 Renderer.backend 访问

    // ===== 尺寸 =====
    private var _width: Int32 = 0
    private var _height: Int32 = 0

    public init() {
        super()
        this.backend = BgfxBackend()
    }

    // ===== 线程基础设施 =====

    private func _initRenderThread(): Unit {
        if (this._renderSThread.isSome()) { return }
        // Mutex/Condition 已在字段声明处初始化
        this._renderSThread = SThread{ this._renderLoop(); () }
    }

    private func _renderLoop(): Unit {
        this._renderReady = true
        while (!this._renderExit) {
            this._renderMtx.lock()
            while (this._renderQueue.isEmpty() && !this._renderExit) {
                this._renderCmdCnd.wait(this._renderMtx)
            }
            if (this._renderQueue.isEmpty() || this._renderExit) {
                // 退出：剩余未执行命令按"放弃"处理——推进完成序号并唤醒其提交者，
                // 避免任何人悬挂在 _renderDoneCnd 上
                let abandoned = this._renderQueue.size
                if (abandoned > 0) {
                    this._renderQueue.clear()
                    this._renderDoneSeq += Int64(abandoned)
                    this._renderDoneCnd.broadcast()
                }
                this._renderMtx.unlock()
                break
            }
            let cmd = this._renderQueue.remove(at: 0)
            this._renderMtx.unlock()

            // 渲染线程执行 bgfx 闭包：持全局可重入锁，与主线程裸调互斥。
            // 闭包内部（如 BgfxUniforms/BgfxBackend 再调 bgfx FFI）同线程重入，不会自我死锁。
            bgfxCallMtx.lock()
            let cmdStart = MonoTime.now()
            try {
                cmd()
            } catch (e: Error) {
                // 异常隔离：单条命令失败不能杀渲染线程，否则其提交者永久等待
                @LogError(["ThreeRenderer._renderLoop: bgfx cmd failed: ${e}"])
            }
            bgfxCallMtx.unlock()
            // 诊断日志（只记录、不解锁）：单条命令异常耗时说明原生层/管线异常，
            // 是排查帧卡顿与挂死的关键信号
            let cmdCostMs = (MonoTime.now() - cmdStart).toMilliseconds()
            if (cmdCostMs > 200) {
                @LogWarn(["ThreeRenderer: bgfx cmd cost ${cmdCostMs}ms (>200)"])
            }

            this._renderMtx.lock()
            this._renderDoneSeq += 1
            // broadcast 而非 signal：多个提交者可能同时在等，signal 只唤醒一个，
            // 若唤醒的那位谓词未满足（其序号更靠后）会继续睡，其余提交者成孤儿
            this._renderDoneCnd.broadcast()
            this._renderMtx.unlock()
        }
    }

    private func _execBgfx(cmd: () -> Unit): Unit {
        if (this._renderSThread.isNone()) {
            this._initRenderThread()
        }
        this._renderMtx.lock()
        if (this._renderExit) {
            // 渲染线程已退出（bgfx 已 shutdown）：命令不再执行，直接返回，
            // 防止提交者等待一个永远不会推进的序号
            this._renderMtx.unlock()
            return
        }
        this._renderSubmitSeq += 1
        let mySeq = this._renderSubmitSeq
        this._renderQueue.add(cmd)
        this._renderCmdCnd.signal()
        while (this._renderDoneSeq < mySeq) {
            this._renderDoneCnd.wait(this._renderMtx)
        }
        this._renderMtx.unlock()
    }

/**
 * @brief[zh-cn] 公开线程序列化入口：外部模块的 bgfx API 调用排队到渲染线程
 * @explain[zh-cn] 外部模块（如 EffectComposer/Pass）的 bgfx API 调用必须经此方法排队到渲染线程，
 * @param[zh-cn] cmd 待执行的 bgfx 调用闭包
 *
 * @brief[en] Public thread serialization entry: external modules' bgfx API calls queued to render thread
 * @explain[en] External modules' (e.g. EffectComposer/Pass) bgfx API calls must be queued to the render thread
 * @param[en] cmd bgfx call closure to execute
 */
    public func execBgfx(cmd: () -> Unit): Unit {
        this._execBgfx(cmd)
    }

    // ===== 2.2 init =====

/**
 * @brief[zh-cn] 初始化 bgfx 渲染器
 * @param[zh-cn] hwnd 原生窗口句柄
 * width 窗口逻辑宽度
 * height 窗口逻辑高度
 * @return[zh-cn] 初始化是否成功
 * @explain[zh-cn] width/height 为逻辑尺寸，内部会按 pixelRatio 换算为物理后备缓冲尺寸后传给 bgfx。
 *
 * @brief[en] Initialize bgfx renderer
 * @param[en] hwnd Native window handle
 * width Window logical width
 * height Window logical height
 * @return[en] Whether initialization succeeded
 * @explain[en] width/height are logical dimensions; internally converted to physical backbuffer dimensions using pixelRatio before passing to bgfx.
 */
    public func initBgfx(hwnd: UIntNative, width: Int32, height: Int32): Bool {
        this._initBgfxResult = false
        _execBgfx({ => this._initBgfxResult = this._initBgfxImpl(hwnd, width, height) })
        return this._initBgfxResult
    }

    private func _initBgfxImpl(hwnd: UIntNative, width: Int32, height: Int32): Bool {
        ShaderLibs.initialize()
        // width/height 为逻辑尺寸；bgfx 初始化需使用物理后备缓冲尺寸（乘以 pixelRatio）
        super.setSize(Int64(width), Int64(height))
        let physicalW = Int32(this.width)
        let physicalH = Int32(this.height)
        this._width = physicalW; this._height = physicalH
        let initPtrHolder = AutoFreePtr<bgfx.Init>(unsafe { LibC.malloc<bgfx.Init>() })
        let initPtr = initPtrHolder.get()
        unsafe { initPtr.write(bgfx.Init()) }
        bgfx.bgfx_init_ctor_cj(initPtr)
        var initParams = unsafe { initPtr.read() }
        initParams.`type` = DEFAULT_RENDERER_TYPE
        initParams.vendorId = bgfx.PCI_ID_NONE
        initParams.deviceId = bgfx.PCI_ID_NONE
        // 新版 bgfx：主窗口交换链经 Init.swapChain 传入（nwh 从 platformData 移入 swapChain）
        initParams.swapChain.width = UInt32(physicalW); initParams.swapChain.height = UInt32(physicalH)
        initParams.reset = 0x00000080u32
        initParams.swapChain.numBackBuffers = 2
        initParams.swapChain.maxFrameLatency = 2
        initParams.debug = false
        initParams.profile = false
        @LogDebug(["API", "setting nwh via intToCPointer, hwnd=" + hwnd.toString()])
        initParams.swapChain.nwh = intToCPointer(hwnd)
        unsafe { initPtr.write(initParams) }
        var ok = bgfx.bgfx_init_cj(initPtr)
        if (!ok && initParams.`type` != 0u32) {
            initParams.`type` = 0u32
            unsafe { initPtr.write(initParams) }
            ok = bgfx.bgfx_init_cj(initPtr)
        }
        initPtrHolder.dispose()
        if (ok) {
            bgfx.bgfx_set_debug_cj(0u32)
            bgfx.bgfx_set_view_clear_cj(this.viewId, CLEAR_COLOR | CLEAR_DEPTH, this.clearColor, 1.0f32, 0)
            ShaderLibs.get("depth")?.compileBgfx()
            // 关键修复：bgfx_init_cj 成功后必须标记 BgfxBackend.initialized = true。
            // BgfxBackend 有两条 init 路径：(a) 构造器 init() 只初始化子模块不调 bgfx_init；
            // (b) initialize(renderer) override 调 bgfx_init + 设 initialized=true。
            // 此处 _initBgfxImpl 走自己的 bgfx_init 路径没调 backend.initialize()，
            // 导致 initialized 永远是构造器默认值 false → renderShadowMap 内 ffi 调用返回 invalid handle。
            // initialized 是 Backend 基类 public var，可直接赋值。
            match (this.backend) {
                case bgfx: BgfxBackend => bgfx.initialized = true
                case _ => ()
            }
        }
        return ok
    }

    // ===== 2.3 render =====

/**
 * @brief[zh-cn] 设置渲染目标（IRenderer 接口实现，CubeCamera 6 面渲染的渲染目标切换）
 * @param[zh-cn] renderTarget 渲染目标
 * cubeFace 立方体面索引（0~5）
 * mipLevel mipmap 层级
 *
 * @brief[en] Set render target (IRenderer interface implementation, CubeCamera 6-face render target switching)
 * @param[en] renderTarget Render target
 * cubeFace Cube face index (0~5)
 * mipLevel Mipmap level
 */
    public func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit {
        ()
    }

/**
 * @brief[zh-cn] 获取当前渲染目标
 * @return[zh-cn] 当前渲染目标（None 表示默认帧缓冲）
 *
 * @brief[en] Get current render target
 * @return[en] Current render target (None for default framebuffer)
 */
    public func getRenderTarget(): Option<IRenderTarget> {
        return None
    }

/**
 * @brief[zh-cn] 渲染场景（经 _execBgfx 委托到渲染线程）
 * @param[zh-cn] scene 待渲染场景
 * camera 渲染相机
 *
 * @brief[en] Render scene (delegated to render thread via _execBgfx)
 * @param[en] scene Scene to render
 * camera Render camera
 */
    public func render(scene: Scene, camera: Camera): Unit {
        _execBgfx({ => super.render(scene, camera) })
    }

/**
 * @brief[zh-cn] 获取当前渲染 view id（override 基类钩子）
 * @return[zh-cn] 当前 view id
 *
 * @brief[en] Get current render view id (override base class hook)
 * @return[en] Current view id
 */
    public override func getRenderViewId(): UInt16 {
        return this.viewId
    }

/**
 * @brief[zh-cn] 关闭 bgfx 渲染器，释放资源
 *
 * @brief[en] Shutdown bgfx renderer and release resources
 */
    public func shutdown(): Unit {
        ShaderLibs.shutdown()
        _execBgfx({ => bgfx.bgfx_shutdown_cj() })
        this._renderMtx.lock()
        this._renderExit = true
        // 丢弃未执行命令并释放其提交者（推进序号 + 双条件唤醒），确保 shutdown 不悬挂
        let abandoned = this._renderQueue.size
        if (abandoned > 0) {
            this._renderQueue.clear()
            this._renderDoneSeq += Int64(abandoned)
        }
        this._renderDoneCnd.broadcast()
        this._renderCmdCnd.signal()
        this._renderMtx.unlock()
    }

/**
 * @brief[zh-cn] 设置渲染器尺寸
 * @param[zh-cn] width 逻辑宽度（像素）
 * height 逻辑高度（像素）
 * @explain[zh-cn] 内部会按 pixelRatio 换算为物理后备缓冲尺寸，并触发 bgfx reset。
 *
 * @brief[en] Set renderer size
 * @param[en] width Logical width in pixels
 * height Logical height in pixels
 * @explain[en] Internally converted to physical backbuffer dimensions using pixelRatio, and triggers bgfx reset.
 */
    public func setSize(width: Int32, height: Int32): Unit {
        // width/height 为逻辑尺寸；内部按 pixelRatio 换算为物理后备缓冲尺寸
        super.setSize(Int64(width), Int64(height))
        let physicalW = Int32(this.width)
        let physicalH = Int32(this.height)
        let changed = (physicalW != this._width || physicalH != this._height)
        this._width = physicalW; this._height = physicalH
        // bgfx 在表面尺寸变化（旋转/窗口缩放）后必须重建后备缓冲，
        // 否则 backbuffer 尺寸与 surface 不匹配 → 横屏后画面闪烁/内容错乱。
        // flags 与 initBgfx 保持一致（0x00000080 = FLUSH_AFTER_RENDER）。
        // format 必须传 TextureFormat.Count 哨兵——bgfx 见 Count 才会沿用 init 时的
        // 后台缓冲格式；传 0 会被当作 TextureFormat.BC1（压缩格式），D3D11 后端
        // IDXGISwapChain::ResizeBuffers 收到压缩格式返回 E_INVALIDARG，swapchain
        // 保持旧尺寸 → 画面定格/内容只占左上角。
        if (changed) {
            this.reset(UInt32(physicalW), UInt32(physicalH), 0x00000080u32,
                bgfx.TextureFormat.Count.value())
        }
        // SSAO pass 尺寸由 EffectComposer.setSize 转发（SSAO 已 Pass 化，不再经 renderer 内置同步）
    }

/**
 * @brief[zh-cn] 设置阴影类型（转调 BgfxBackend.shadowMap）
 * @param[zh-cn] value 阴影类型值
 *
 * @brief[en] Set shadow type (delegates to BgfxBackend.shadowMap)
 * @param[en] value Shadow type value
 */
    public func setShadowType(value: Int64): Unit {
        _execBgfx({ =>
            match (this.backend as BgfxBackend) {
                case Some(bgfx) => bgfx.setShadowType(value)
                case None => ()
            }
        })
    }

    // ===== SSAO 已 Pass 化（对齐 bloom：composer.addPass(SSAOPass(scene, camera))） =====
    // 原 renderer.setSSAOEnabled / setSSAOParams / renderSSAO / blitSSAO 内置转发已移除。
    // 测试侧直接构造 SSAOPass 并经 EffectComposer 注入：
    //   composer.addPass(RenderPass(scene, camera))
    //   composer.addPass(SSAOPass(scene, camera))
    //   composer.render()
    // 尺寸由 composer.setSize 转发（SSAOPass.setSize override），无需 renderer 内置同步。

    // ========================================================================
    // ===== 后处理高阶 API（对齐 Three.js WebGLRenderer 暴露位置/命名） =====
    // ========================================================================
    //
    // 设计动机：原 postprocessing 中所有 pass 直接调底层 bgfx API
    // （bgfx_set_view_frame_buffer_cj / bgfx_set_texture_cj / bgfx_set_uniform_cj /
    //   bgfx_submit_cj / bgfx_set_view_clear_cj / bgfx_set_view_rect_cj ...），
    // 违反 Three.js 的分层设计——Three.js 的 pass 只用 renderer.setRenderTarget /
    // renderer.clear / fsQuad.render(renderer) 等高阶 API，不接触底层 WebGL。
    //
    // 本组方法把 bgfx 底层调用封装进 renderer 内部，对外暴露与 Three.js
    // `WebGLRenderer` 等价的高阶 API。命名/位置严格对齐 Three.js：
    //   - setRenderTarget / getRenderTarget  ← renderer.setRenderTarget(null)
    //   - clear / setClearColor              ← renderer.clear / setClearColor
    //   - setViewport                        ← renderer.setViewport
    //   - bindTexture / getTexture           ← gl.bindTexture + fsQuad uniforms
    //   - setUniform                         ← gl.uniform*
    //   - submitFullScreenQuad               ← fsQuad.render(renderer)
    //   - createTexture2D / destroyTexture   ← WebGLRenderTarget 内部纹理生命周期
    //   - createFrameBuffer / destroyFrameBuffer ← WebGLRenderTarget 生命周期
    //
    // 所有方法内部统一走 _execBgfx 序列化到渲染线程，pass 无须再手动包 execBgfx。
    // bgfx 特有概念（view id / texture stage / uniform handle）以高阶参数暴露：
    //   viewId 由 pass 自己持有（对齐 EffectComposer.allocViewId 分配模型）。
    //
    // 线程模型约束（★关键，供 pass 实现者遵守）：
    //   - 这些高阶 API 自身走 _execBgfx（同步等待渲染线程）。
    //   - _execBgfx 不可重入：调用本组方法期间不能再调 renderer.render（其内部
    //     也走 _execBgfx），否则自我等待死锁。
    //   - 若 pass 流程需要"set view → renderer.render → copy 加性"这种交错，
    //     应拆为多次顺序独立调用，每次调用各走 _execBgfx 但不嵌套。
    // ========================================================================

    // ----- RenderTarget / View 设置（对齐 setRenderTarget/setViewport/clear） -----

/**
 * @brief[zh-cn] 设置某 view 的渲染目标 frame buffer
 * @param[zh-cn] viewId bgfx view id（pass 持有，由 EffectComposer.allocViewId 分配）
 * fb 目标 frame buffer；传无效 handle（idx=65535）表示写 swap chain（屏幕）
 *
 * @brief[en] Set render target Frame buffer for a view
 * @param[en] viewId bgfx view id (held by pass, allocated by EffectComposer.allocViewId)
 * fb Target Frame buffer; pass invalid handle (idx=65535) to write to swap chain (screen)
 */
    public func setViewFrameBuffer(viewId: UInt16, fb: FrameBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_frame_buffer_cj(viewId, fb.value) })
    }

/**
 * @brief[zh-cn] 设置某 view 的视口矩形（像素）
 * @param[zh-cn] viewId bgfx view id
 * x 视口左上角 x（像素）
 * y 视口左上角 y（像素）
 * w 视口宽（像素）
 * h 视口高（像素）
 *
 * @brief[en] Set viewport rectangle for a view (in pixels)
 * @param[en] viewId bgfx view id
 * x Viewport top-left x (pixels)
 * y Viewport top-left y (pixels)
 * w Viewport width (pixels)
 * h Viewport height (pixels)
 */
    public func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_rect_cj(viewId, x, y, w, h) })
    }

/**
 * @brief[zh-cn] 设置某 view 的 clear（颜色 + 深度 + 模板）
 * @param[zh-cn] viewId bgfx view id
 * flags clear 标志位（CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004）
 * color clear 颜色（UInt32）
 * depth clear 深度（0.0~1.0，默认 1.0）
 * stencil clear 模板值（默认 0）
 *
 * @brief[en] Set clear for a view (color + depth + stencil)
 * @param[en] viewId bgfx view id
 * flags Clear flag bits (CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004)
 * color Clear color (UInt32)
 * depth Clear depth (0.0~1.0, default 1.0)
 * stencil Clear stencil value (default 0)
 */
    public func setViewClear(
        viewId: UInt16,
        flags: UInt16,
        color: UInt32,
        depth!: Float32 = 1.0f32,
        stencil!: UInt8 = 0u8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_clear_cj(viewId, flags, color, depth, stencil) })
    }

/**
 * @brief[zh-cn] 设置某 view 的 view/proj 变换矩阵
 * @param[zh-cn] viewId bgfx view id
 * view 4×4 view 矩阵数据
 * proj 4×4 projection 矩阵数据
 *
 * @brief[en] Set view/proj transform matrices for a view
 * @param[en] viewId bgfx view id
 * view 4×4 view matrix data
 * proj 4×4 projection matrix data
 */
    public func setViewTransform(
        viewId: UInt16,
        view: BgfxMemory,
        proj: BgfxMemory
    ): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_transform_cj(viewId, unsafe { CPointer<Unit>(view.data()) }, unsafe { CPointer<Unit>(proj.data()) }) })
    }

/**
 * @brief[zh-cn] 设置某 view 的渲染模式
 * @param[zh-cn] viewId bgfx view id
 * mode ViewMode.value()（默认/顺序/深度升序/深度降序）
 *
 * @brief[en] Set render mode for a view
 * @param[en] viewId bgfx view id
 * mode ViewMode.value() (Default/Sequential/DepthAscending/DepthDescending)
 */
    public func setViewMode(viewId: UInt16, mode: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_mode_cj(viewId, mode) })
    }

/**
 * @brief[zh-cn] 设置某 view 的名称（调试用）
 * @param[zh-cn] viewId bgfx view id
 * name view 名称（UTF-8）
 *
 * @brief[en] Set name for a view (for debugging)
 * @param[en] viewId bgfx view id
 * name View name (UTF-8)
 */
    public func setViewName(viewId: UInt16, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_view_name_cj(viewId, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 设置某 view 的执行顺序
 * @param[zh-cn] viewId bgfx view id
 * order view id 数组
 *
 * @brief[en] Set execution order for a view
 * @param[en] viewId bgfx view id
 * order View id array
 */
    public func setViewOrder(viewId: UInt16, order: PtrArray<UInt16>): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_order_cj(viewId, UInt16(order.size()), order.data()) })
    }

/**
 * @brief[zh-cn] 设置某 view 的裁剪矩形
 * @param[zh-cn] viewId bgfx view id
 * x 裁剪区左上角 x（像素）
 * y 裁剪区左上角 y（像素）
 * w 裁剪区宽（像素）
 * h 裁剪区高（像素）
 *
 * @brief[en] Set scissor rectangle for a view
 * @param[en] viewId bgfx view id
 * x Scissor top-left x (pixels)
 * y Scissor top-left y (pixels)
 * w Scissor width (pixels)
 * h Scissor height (pixels)
 */
    public func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_scissor_cj(viewId, x, y, w, h) })
    }

/**
 * @brief[zh-cn] 按后备缓冲比例设置某 view 的视口矩形
 * @param[zh-cn] viewId bgfx view id
 * x 视口左上角 x 比例基准
 * y 视口左上角 y 比例基准
 * ratio BackbufferRatio.value()（Half/Quarter/Eighth/Sixteenth/Double）
 *
 * @brief[en] Set viewport rectangle for a view by backbuffer ratio
 * @param[en] viewId bgfx view id
 * x Viewport top-left x ratio base
 * y Viewport top-left y ratio base
 * ratio BackbufferRatio.value() (Half/Quarter/Eighth/Sixteenth/Double)
 */
    public func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_rect_ratio_cj(viewId, x, y, ratio) })
    }

/**
 * @brief[zh-cn] 设置某 view 的多渲染目标清除（每附件独立颜色）
 * @param[zh-cn] viewId bgfx view id
 * flags clear 标志位（CLEAR_* 组合）
 * depth clear 深度
 * stencil clear 模板值
 *
 * @brief[en] Set MRT clear for a view (per-attachment independent colors)
 * @param[en] viewId bgfx view id
 * flags Clear flag bits (CLEAR_* combination)
 * depth Clear depth
 * stencil Clear stencil value
 */
    public func setViewClearMRT(
        viewId: UInt16,
        flags: UInt16,
        depth: Float32,
        stencil: UInt8,
        c0: UInt8, c1: UInt8, c2: UInt8, c3: UInt8,
        c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_set_view_clear_mrt_cj(viewId, flags, depth, stencil, c0, c1, c2, c3, c4, c5, c6, c7) })
    }

/**
 * @brief[zh-cn] 重置某 view 的全部状态
 * @param[zh-cn] viewId bgfx view id
 *
 * @brief[en] Reset all states of a view
 * @param[en] viewId bgfx view id
 */
    public func resetView(viewId: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_reset_view_cj(viewId) })
    }

/**
 * @brief[zh-cn] 设置调色板颜色（rgba 4 个 float）
 * @param[zh-cn] index 调色板索引（0..15）
 * rgba 4 个 float 指针（r,g,b,a）
 *
 * @brief[en] Set palette color (rgba 4 floats)
 * @param[en] index Palette index (0..15)
 * rgba 4 float pointer (r,g,b,a)
 */
    public func setPaletteColor(index: UInt8, rgba: PtrArray<Float32>): Unit {
        _execBgfx({ => bgfx.bgfx_set_palette_color_cj(index, rgba.data()) })
    }

/**
 * @brief[zh-cn] 设置调色板颜色（4 分量 float 版本）
 * @param[zh-cn] index 调色板索引（0..15）
 * r 红（0.0~1.0）
 * g 绿（0.0~1.0）
 * b 蓝（0.0~1.0）
 * a 透明度（0.0~1.0）
 *
 * @brief[en] Set palette color (4-component float version)
 * @param[en] index Palette index (0..15)
 * r Red (0.0~1.0)
 * g Green (0.0~1.0)
 * b Blue (0.0~1.0)
 * a Alpha (0.0~1.0)
 */
    public func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit {
        _execBgfx({ => bgfx.bgfx_set_palette_color_rgba32f_cj(index, r, g, b, a) })
    }

/**
 * @brief[zh-cn] 设置调色板颜色（8bit 打包版本）
 * @param[zh-cn] index 调色板索引（0..15）
 * rgba 打包颜色（0xRRGGBBAA）
 *
 * @brief[en] Set palette color (8bit packed version)
 * @param[en] index Palette index (0..15)
 * rgba Packed color (0xRRGGBBAA)
 */
    public func setPaletteColorRgba8(index: UInt8, rgba: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_palette_color_rgba8_cj(index, rgba) })
    }

    // ----- 纹理 / Uniform 绑定（对齐 gl.bindTexture / gl.uniform*） -----

/**
 * @brief[zh-cn] 绑定纹理到指定 stage 的 sampler
 * @param[zh-cn] stage 纹理 stage（0..MAX_TEXTURE_SAMPLERS-1）
 * sampler sampler uniform 句柄
 * tex 待绑纹理句柄
 * flags 采样器 flags（如 SAMPLER_U_CLAMP|SAMPLER_V_CLAMP，0 表示用纹理默认）
 *
 * @brief[en] Bind texture to specified stage sampler
 * @param[en] stage Texture stage (0..MAX_TEXTURE_SAMPLERS-1)
 * sampler Sampler uniform handle
 * tex Texture handle to bind
 * flags Sampler flags (e.g. SAMPLER_U_CLAMP|SAMPLER_V_CLAMP, 0 for texture default)
 */
    public func bindTexture(stage: UInt8, sampler: UniformHandle, tex: TextureHandle, flags: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_texture_cj(stage, sampler.value, tex.value, flags) })
    }

/**
 * @brief[zh-cn] 取 frame buffer 指定 attachment 的纹理句柄
 * @param[zh-cn] fb 源 frame buffer
 * attachment attachment 索引（0=主 color，1=depth 等）
 * @return[zh-cn] attachment 对应的 TextureHandle
 *
 * @brief[en] Get texture handle of a Frame buffer attachment
 * @param[en] fb Source Frame buffer
 * attachment Attachment index (0=main color, 1=depth etc.)
 * @return[en] TextureHandle for the attachment
 */
    public func getTexture(fb: FrameBufferHandle, attachment: UInt8): TextureHandle {
        let resultBox: Box<TextureHandle> = Box(INVALID_TEXTURE_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_get_texture_cj(fb.value, attachment))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 设置 uniform 数据
 * @param[zh-cn] handle uniform 句柄
 * data uniform 数据指针（float32 数组）
 * num 数组长度（默认 1）
 *
 * @brief[en] Set uniform data
 * @param[en] handle Uniform handle
 * data Uniform data pointer (float32 array)
 * num Array length (default 1)
 */
    public func setUniform(handle: UniformHandle, data: BgfxMemory, num!: UInt16 = 1u16): Unit {
        _execBgfx({ => bgfx.bgfx_set_uniform_cj(handle.value, unsafe { CPointer<Unit>(data.data()) }, num) })
    }

/**
 * @brief[zh-cn] 设置模板状态（per-draw 瞬态）
 * @param[zh-cn] fstencil 前面 stencil 位域
 * bstencil 后面 stencil 位域
 *
 * @brief[en] Set stencil state (per-draw transient)
 * @param[en] fstencil Front stencil bitfield
 * bstencil Back stencil bitfield
 */
    public func setStencil(fstencil: UInt32, bstencil: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_stencil_cj(fstencil, bstencil) })
    }

    // ----- 纹理 / FrameBuffer 生命周期（对齐 WebGLRenderTarget/Texture dispose） -----

/**
 * @brief[zh-cn] 创建 2D 纹理
 * @param[zh-cn] w 纹理宽（像素）
 * h 纹理高（像素）
 * hasMips 是否生成 mipmap
 * numLayers 图层数（1=普通 2D 纹理）
 * format 纹理格式
 * flags 纹理 flags
 * mem 纹理数据内存（null 表示空 RT）
 * @return[zh-cn] 纹理句柄
 *
 * @brief[en] Create 2D texture
 * @param[en] w Texture width (pixels)
 * h Texture height (pixels)
 * hasMips Whether to generate mipmaps
 * numLayers Number of layers (1=plain 2D texture)
 * format Texture format
 * flags Texture flags
 * mem Texture data memory (null for empty RT)
 * @return[en] Texture handle
 */
    public func createTexture2D(
        w: UInt16,
        h: UInt16,
        hasMips: Bool,
        numLayers: UInt16,
        format: UInt32,
        flags: UInt64,
        mem: Option<BgfxMemory>
    ): TextureHandle {
        let resultBox: Box<TextureHandle> = Box(INVALID_TEXTURE_HANDLE)
        let memRef = mem
        _execBgfx({ =>
            let memPtr = match (memRef) {
                case Some(m) => m.get()
                case None => CPointer<bgfx.Memory>()
            }
            resultBox.value = Box(bgfx.bgfx_create_texture_2d_cj(w, h, hasMips, numLayers, format, flags, memPtr))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 创建 cube 纹理
 * @param[zh-cn] side cube 面边长（像素）
 * hasMips 是否生成 mipmap
 * numLayers 图层数
 * format 纹理格式
 * flags 纹理 flags
 * mem 6 面连续像素数据（null 表示空 cube RT）
 * @return[zh-cn] cube 纹理句柄
 *
 * @brief[en] Create cube texture
 * @param[en] side Cube face side length (pixels)
 * hasMips Whether to generate mipmaps
 * numLayers Number of layers
 * format Texture format
 * flags Texture flags
 * mem 6-face continuous pixel data (null for empty cube RT)
 * @return[en] Cube texture handle
 */
    public func createTextureCube(
        side: UInt16,
        hasMips: Bool,
        numLayers: UInt16,
        format: UInt32,
        flags: UInt64,
        mem: Option<BgfxMemory>
    ): TextureHandle {
        let resultBox: Box<TextureHandle> = Box(INVALID_TEXTURE_HANDLE)
        let memRef = mem
        _execBgfx({ =>
            let memPtr = match (memRef) {
                case Some(m) => m.get()
                case None => CPointer<bgfx.Memory>()
            }
            resultBox.value = Box(bgfx.bgfx_create_texture_cube_cj(side, hasMips, numLayers, format, flags, memPtr))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 创建 3D 纹理
 * @param[zh-cn] w 纹理宽（像素）
 * h 纹理高（像素）
 * d 纹理深（层数）
 * hasMips 是否生成 mipmap
 * format 纹理格式
 * flags 纹理 flags
 * mem 纹理数据内存（Some=有数据；None=空 3D RT）
 * @return[zh-cn] 3D 纹理句柄
 *
 * @brief[en] Create 3D texture
 * @param[en] w Texture width (pixels)
 * h Texture height (pixels)
 * d Texture depth (layers)
 * hasMips Whether to generate mipmaps
 * format Texture format
 * flags Texture flags
 * mem Texture data memory (Some=data; None=empty 3D RT)
 * @return[en] 3D texture handle
 */
    public func createTexture3D(
        w: UInt16,
        h: UInt16,
        d: UInt16,
        hasMips: Bool,
        format: UInt32,
        flags: UInt64,
        mem: Option<BgfxMemory>
    ): TextureHandle {
        let resultBox: Box<TextureHandle> = Box(INVALID_TEXTURE_HANDLE)
        let memRef = mem
        _execBgfx({ =>
            let memPtr = match (memRef) {
                case Some(m) => m.get()
                case None => CPointer<bgfx.Memory>()
            }
            resultBox.value = Box(bgfx.bgfx_create_texture_3d_cj(w, h, d, hasMips, format, flags, memPtr))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 设置 bgfx 全局调试标志
 * @param[zh-cn] debug bgfx 调试标志位
 *
 * @brief[en] Set bgfx global debug flags
 * @param[en] debug bgfx debug flag bits
 */
    public func setDebug(debug: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_debug_cj(debug) })
    }

/**
 * @brief[zh-cn] 销毁纹理句柄
 * @param[zh-cn] tex 待销毁纹理句柄
 *
 * @brief[en] Destroy texture handle
 * @param[en] tex Texture handle to destroy
 */
    public func destroyTexture(tex: TextureHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_texture_cj(tex.value) })
    }

/**
 * @brief[zh-cn] 由多个纹理句柄创建 frame buffer
 * @param[zh-cn] numAttachments attachment 数量
 * handles attachments 纹理句柄数组
 * destroyHandles bgfx 销毁 FB 时是否自动销毁这些 texture 句柄
 * @return[zh-cn] frame buffer 句柄
 *
 * @brief[en] Create Frame buffer from multiple texture handles
 * @param[en] numAttachments Number of attachments
 * handles Attachment texture handle array
 * destroyHandles Whether bgfx auto-destroys these texture handles when FB is destroyed
 * @return[en] Frame buffer handle
 */
    public func createFrameBuffer(
        numAttachments: UInt8,
        handles: Array<TextureHandle>,
        destroyHandles: Bool
    ): FrameBufferHandle {
        let resultBox: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)
        let handlesRef = handles
        _execBgfx({ =>
            // 构造连续内存的 bgfx TextureHandle 数组（attachment 顺序对应索引）
            let holder = AutoFreePtr<bgfx.TextureHandle>(unsafe { LibC.malloc<bgfx.TextureHandle>(count: Int64(handlesRef.size)) })
            for (i in 0..handlesRef.size) {
                unsafe { (holder.get() + i).write(0, handlesRef[i].value) }
            }
            resultBox.value = Box(bgfx.bgfx_create_frame_buffer_from_handles_cj(numAttachments, holder.get(), destroyHandles))
            holder.dispose()
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由宽高创建空 frame buffer
 * @param[zh-cn] w 宽（像素）
 * h 高（像素）
 * format 纹理格式
 * depthFlags 深度 attachment flags
 * @return[zh-cn] frame buffer 句柄
 *
 * @brief[en] Create empty Frame buffer by width and height
 * @param[en] w Width (pixels)
 * h Height (pixels)
 * format Texture format
 * depthFlags Depth attachment flags
 * @return[en] Frame buffer handle
 */
    public func createFrameBuffer(
        w: UInt16,
        h: UInt16,
        format: UInt32,
        depthFlags: UInt64
    ): FrameBufferHandle {
        let resultBox: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_frame_buffer_cj(w, h, format, depthFlags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁 frame buffer 句柄。
 * @explain[zh-cn] 销毁 frame buffer 句柄，释放 GPU 资源。
 * @param[zh-cn] fb 待销毁 frame buffer 句柄
 *
 * @brief[en] Destroy Frame buffer handle
 * @explain[en] Destroy frame buffer handle, release GPU resources.
 * @param[en] fb 待销毁 Frame buffer handle
 */
    public func destroyFrameBuffer(fb: FrameBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_frame_buffer_cj(fb.value) })
    }

/**
 * @brief[zh-cn] blit 拷贝：把 src 纹理区域拷贝到 dst 纹理
 * @explain[zh-cn] 将源纹理区域拷贝到目标纹理，底层使用 bgfx_blit 实现。
 * @param[zh-cn] viewId bgfx view id
 * dst 目标纹理（Box 包装句柄）
 * src 源纹理（Box 包装句柄）
 * width 拷贝宽度（像素）
 * height 拷贝高度（像素）
 *
 * @brief[en] Blit copy: copy src texture region to dst texture
 * @explain[en] Copy source texture region to destination texture, implemented via bgfx_blit.
 * Wraps bgfx_blit_cj, external code does not need to access texture handle internal pointers.
 * @param[en] viewId bgfx view id
 * dst Destination texture (Box-wrapped handle)
 * src Source texture (Box-wrapped handle)
 * width Copy width (pixels)
 * height Copy height (pixels)
 */
    public func blitTexture(viewId: UInt16, dst: TextureHandle, src: TextureHandle, width: UInt16, height: UInt16): Unit {
        _execBgfx({ =>
            bgfx.bgfx_blit_cj(viewId, dst.value, 0u8, 0u16, 0u16, 0u16,
                              src.value, 0u8, 0u16, 0u16, 0u16,
                              width, height, 1u16)
        })
    }

/**
 * @brief[zh-cn] 回读纹理到 CPU 内存（异步）
 * @explain[zh-cn] 返回数据就绪的 frame 序号，调用方等待该帧后再读 data。
 * bgfx 为异步 read_texture，需等 readyFrame 后再访问 data。
 * @param[zh-cn] tex 源纹理（Box 包装句柄）
 * data 回读目标缓冲（PtrArray<UInt8>，底层指针由内部持有）
 * mip mip 层（默认 0）
 * @return[zh-cn] 数据就绪的 frame 序号（此后才可安全读 data）
 *
 * @brief[en] Read texture back to CPU memory (asynchronous)
 * @explain[en] Asynchronous texture readback to CPU memory.
 * bgfx uses asynchronous read_texture; must wait for readyFrame before accessing data.
 * Returns frame number when data is ready; caller must wait for that frame before reading data.
 * @param[en] tex Source texture (Box-wrapped handle)
 * data Readback target buffer (PtrArray<UInt8>, internal pointer held internally)
 * mip Mip level (default 0)
 * @return[en] Frame number when data is ready (safe to read data after this frame)
 */
    public func readTexture(tex: TextureHandle, data: PtrArray<UInt8>, mip!: UInt8 = 0u8): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        let dataRef = data
        _execBgfx({ =>
            // 新版 bgfx：bgfx_read_texture 以 TextureRegion 描述源区域（mip=0、区域取整图）
            let regionHolder = AutoFreePtr<bgfx.TextureRegion>(unsafe { LibC.malloc<bgfx.TextureRegion>() })
            let region = regionHolder.get()
            bgfx.bgfx_texture_region_init_cj(region, tex.value, 0u16, 0u16, 0u16, 0u16)
            var regionVal = unsafe { region.read() }
            regionVal.mip = mip
            unsafe { region.write(regionVal) }
            resultBox.value = bgfx.bgfx_read_texture_cj(region, unsafe { CPointer<Unit>(dataRef.data()) })
            regionHolder.dispose()
        })
        return resultBox.value
    }

    // ----- Submit / Draw（对齐 fsQuad.render(renderer) + submit） -----

/**
 * @brief[zh-cn] 触发某 view 的 empty submit（仅推进 clear / view 序号，不绘制）
 * @explain[zh-cn] 触发指定 view 的空提交，推进 clear/view 序号而不执行绘制，bgfx touch 是 clear 的载体。
 * @param[zh-cn] viewId bgfx view id
 *
 * @brief[en] Trigger empty submit for a view (only advances clear / view sequence, no drawing)
 * @explain[en] Trigger empty submit for a view, advances clear/view sequence without drawing; bgfx touch is the carrier for clear.
 * @param[en] viewId bgfx view id
 */
    public func touchView(viewId: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_touch_cj(viewId) })
    }

/**
 * @brief[zh-cn] 触发一次 bgfx frame 双缓冲交换上屏
 * @explain[zh-cn] 显式触发 bgfx frame 双缓冲交换上屏，非自动帧循环驱动。
 * @param[zh-cn] capture 是否截屏（默认 false）
 *
 * @brief[en] Trigger a bgfx frame double-buffer swap to screen
 * @explain[en] Passes should not call this directly — frame is triggered uniformly at the end of EffectComposer.render.
 * Passes should not call this directly — frame is triggered uniformly at the end of EffectComposer.render.
 * @param[en] capture Whether to capture screenshot (default false)
 */
    public func present(capture!: Bool = false): Unit {
        _execBgfx({ => bgfx.bgfx_frame_cj(flags: if (capture) { bgfx.FRAME_DEBUG_CAPTURE } else { bgfx.FRAME_NONE }) })
    }

    // ========================================================================
    // ===== Draw 提交封装（对齐 Three.js gl.drawElements + fsQuad.render） =====
    // ========================================================================
    // 设计动机：postprocessing pass（如 SavePass/UnrealBloomPass/SSRPass）需自行
    // submit 全屏 quad，原直接调 bgfx_submit_cj / bgfx_set_state_cj / bgfx_set_transform_cj
    // 违反分层。本组方法把这些 per-draw 瞬态状态封装进 renderer。
    // 与 Three.js WebGLState 对齐：state 是持久的，bgfx 是 per-draw 瞬态，
    // 故每次 submit 前需重设 state/transform/index buffer。
    // ========================================================================

/**
 * @brief[zh-cn] 提交当前 draw 到指定 view
 * @explain[zh-cn] 提交当前绘制命令到指定 view，绑定 program 并执行渲染。
 * @param[zh-cn] viewId bgfx view id
 * program 已编译的 program handle
 * depth 深度值（默认 0，供排序用）
 * blend 混合标志位（0xFF 表示用 program 默认）
 *
 * @brief[en] Submit current draw to specified view
 * @explain[en] Submit current draw call to specified view, bind program and execute rendering.
 * @param[en] viewId bgfx view id
 * program Compiled program handle
 * depth Depth value (default 0, for sorting)
 * blend Blend flags (0xFF means use program default)
 */
    public func submit(viewId: UInt16, program: ProgramHandle, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit {
        _execBgfx({ => bgfx.bgfx_submit_cj(viewId, program.value, depth, blend) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 渲染状态
 * @explain[zh-cn] 设置 per-draw 渲染状态，bgfx 使用逐绘制瞬态状态，每次 submit 前需重设。
 * @param[zh-cn] state 完整 render state 位域（BGFX_STATE_* 组合）
 * rgba 颜色混合因子（默认 0，表示用 program 默认）
 *
 * @brief[en] Set per-draw render state
 * @explain[en] Set per-draw render state bitfield. bgfx uses per-draw transient state, must be reset before each submit.
 * @param[en] state Complete render state bitfield (BGFX_STATE_* combination)
 * rgba Color blend factor (default 0, means use program default)
 */
    public func setState(state: UInt64, rgba!: UInt32 = 0u32): Unit {
        _execBgfx({ => bgfx.bgfx_set_state_cj(state, rgba) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 模型变换矩阵
 * @explain[zh-cn] 设置 per-draw 模型变换矩阵，列主序 4×4 矩阵，支持实例化批量。
 * @param[zh-cn] matrix 4×4 模型矩阵指针（16 个 float32，列主序）
 * num 矩阵数量（默认 1，实例化时 >1）
 *
 * @brief[en] Set per-draw model transform matrix
 * @explain[en] Set per-draw model transform matrix, column-major 4x4 matrix, supports instancing batch.
 * bgfx model matrix is per-draw transient, must be reset before each submit.
 * @param[en] matrix 4×4 model matrix pointer (16 float32, column-major)
 * num Number of matrices (default 1, >1 for instancing)
 */
    public func setTransform(matrix: BgfxMemory, num!: UInt16 = 1u16): Unit {
        _execBgfx({ => bgfx.bgfx_set_transform_cj(unsafe { CPointer<Unit>(matrix.data()) }, num) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 顶点缓冲（带 layout）。
 * @explain[zh-cn] 设置 per-draw 顶点缓冲及顶点布局，绑定顶点数据流。
 * @param[zh-cn] stage 顶点缓冲 stage（bgfx 通常 0，单流）
 * vb 顶点缓冲句柄
 * startVertex 起始顶点索引（默认 0）
 * numVertices 顶点数（0xFFFFFFFF 表示全部）
 * layout 顶点布局句柄
 *
 * @brief[en] Set per-draw vertex buffer with layout
 * @explain[en] Set per-draw vertex buffer with layout, bind vertex data stream.
 * @param[en] stage Vertex buffer stage (typically 0 for bgfx, single stream)
 * vb vertex buffer handle
 * startVertex Start vertex index (default 0)
 * numVertices Vertex count (0xFFFFFFFF means all)
 * layout Vertex layout handle
 */
    public func setVertexBufferWithLayout(
        stage: UInt8,
        vb: VertexBufferHandle,
        layout: VertexLayoutHandle,
        startVertex!: UInt32 = 0u32,
        numVertices!: UInt32 = 0xFFFFFFFFu32
    ): Unit {
        _execBgfx({ => bgfx.bgfx_set_vertex_buffer_with_layout_cj(stage, vb.value, startVertex, numVertices, layout.value) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 索引缓冲。
 * @explain[zh-cn] 设置 per-draw 索引缓冲，绑定索引数据流。
 * @param[zh-cn] ib 索引缓冲句柄
 * firstIndex 起始索引（默认 0）
 * numIndices 索引数（0xFFFFFFFF 表示全部）
 *
 * @brief[en] Set per-draw index buffer
 * @explain[en] Set per-draw index buffer, bind index data stream.
 * @param[en] ib Index buffer handle
 * firstIndex Start index (default 0)
 * numIndices Index count (0xFFFFFFFF means all)
 */
    public func setIndexBuffer(ib: IndexBufferHandle, firstIndex!: UInt32 = 0u32, numIndices!: UInt32 = 0xFFFFFFFFu32): Unit {
        _execBgfx({ => bgfx.bgfx_set_index_buffer_cj(ib.value, firstIndex, numIndices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 裁剪矩形（非 view 级，per-draw 瞬态）。
 * @explain[zh-cn] 设置 per-draw 裁剪矩形，bgfx 返回可复用的缓存序号。
 * @param[zh-cn] x 裁剪区左上角 x（像素）
 * y 裁剪区左上角 y（像素）
 * w 裁剪区宽（像素）
 * h 裁剪区高（像素）
 * @return[zh-cn] 裁剪 cache 序号（可用 setScissorCached 复用）
 *
 * @brief[en] Set per-draw scissor rectangle (per-draw transient, not view-level)
 * @explain[en] Set per-draw scissor rectangle, bgfx returns a reusable cache index.
 * @param[en] x Scissor top-left x (pixels)
 * y Scissor top-left y (pixels)
 * w Scissor width (pixels)
 * h Scissor height (pixels)
 * @return[en] Scissor cache index (can be reused with setScissorCached)
 */
    public func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16 {
        let resultBox: Box<UInt16> = Box(0u16)
        _execBgfx({ => resultBox.value = bgfx.bgfx_set_scissor_cj(x, y, w, h) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 复用缓存的裁剪矩形（setScissor 返回的 cache 序号）。
 * @explain[zh-cn] 复用缓存的裁剪矩形，避免重复设置（bgfx 缓存优化）。
 *
 * @brief[en] Reuse cached scissor rectangle (cache index returned by setScissor)
 * @explain[en] Reuse cached scissor rectangle, avoids repeated setup (bgfx cache optimization).
 */
    public func setScissorCached(cache: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_set_scissor_cached_cj(cache) })
    }

/**
 * @brief[zh-cn] 复用缓存的变换矩阵（setTransform 返回的 cache 序号）。
 * @explain[zh-cn] 复用缓存的变换矩阵，避免重复上传矩阵（bgfx 缓存优化）。
 *
 * @brief[en] Reuse cached transform matrix (cache index returned by setTransform)
 * @explain[en] Reuse cached transform matrix, avoids re-uploading matrices (bgfx cache optimization).
 */
    public func setTransformCached(cache: UInt32, num: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_set_transform_cached_cj(cache, num) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 调试标记（渲染线程可见，用于调试工具）。
 * @explain[zh-cn] 设置 per-draw 调试标记，用于 GPU 调试工具中标注绘制区域。
 *
 * @brief[en] Set per-draw debug marker (visible in render thread, for debug tools)
 * @explain[en] Set per-draw debug marker, used to annotate draw regions in GPU debug tools.
 */
    public func setMarker(name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_marker_cj(cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 设置顶点计数（无缓冲顶点模式，顶点由着色器生成）。
 * @explain[zh-cn] 设置顶点计数，用于无缓冲顶点模式（顶点由着色器生成）。
 *
 * @brief[en] Set vertex count (no vertex buffer mode, vertices generated by shader)
 * @explain[en] Set vertex count for no vertex buffer mode (vertices generated by shader).
 */
    public func setVertexCount(numVertices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_vertex_count_cj(numVertices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 顶点缓冲（无 layout，layout 需已绑定）。
 * @explain[zh-cn] 设置 per-draw 顶点缓冲（无 layout），布局需已绑定。
 *
 * @brief[en] Set per-draw vertex buffer (no layout, layout must be bound already)
 * @explain[en] Set per-draw vertex buffer without layout, layout must be bound already.
 */
    public func setVertexBuffer(stage: UInt8, vb: VertexBufferHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit {
        _execBgfx({ => bgfx.bgfx_set_vertex_buffer_cj(stage, vb.value, startVertex, numVertices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 动态顶点缓冲（无 layout）。
 * @explain[zh-cn] 设置 per-draw 动态顶点缓冲（无 layout），绑定动态顶点数据流。
 *
 * @brief[en] Set per-draw dynamic vertex buffer (no layout)
 * @explain[en] Set per-draw dynamic vertex buffer without layout, bind dynamic vertex data stream.
 */
    public func setDynamicVertexBuffer(stage: UInt8, vb: DynamicVertexBufferHandle, startVertex!: UInt32 = 0u32, numVertices!: UInt32 = 0xFFFFFFFFu32): Unit {
        _execBgfx({ => bgfx.bgfx_set_dynamic_vertex_buffer_cj(stage, vb.value, startVertex, numVertices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 动态顶点缓冲（带 layout）。
 * @explain[zh-cn] 设置 per-draw 动态顶点缓冲（带 layout），绑定动态顶点数据流及布局。
 *
 * @brief[en] Set per-draw dynamic vertex buffer (with layout)
 * @explain[en] Set per-draw dynamic vertex buffer with layout, bind dynamic vertex data stream and layout.
 */
    public func setDynamicVertexBufferWithLayout(
        stage: UInt8,
        vb: DynamicVertexBufferHandle,
        layout: VertexLayoutHandle,
        startVertex!: UInt32 = 0u32,
        numVertices!: UInt32 = 0xFFFFFFFFu32
    ): Unit {
        _execBgfx({ => bgfx.bgfx_set_dynamic_vertex_buffer_with_layout_cj(stage, vb.value, startVertex, numVertices, layout.value) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 动态索引缓冲。
 * @explain[zh-cn] 设置 per-draw 动态索引缓冲，绑定动态索引数据流。
 *
 * @brief[en] Set per-draw dynamic index buffer
 * @explain[en] Set per-draw dynamic index buffer, bind dynamic index data stream.
 */
    public func setDynamicIndexBuffer(ib: DynamicIndexBufferHandle, firstIndex!: UInt32 = 0u32, numIndices!: UInt32 = 0xFFFFFFFFu32): Unit {
        _execBgfx({ => bgfx.bgfx_set_dynamic_index_buffer_cj(ib.value, firstIndex, numIndices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 实例数据缓冲。
 * @explain[zh-cn] 设置 per-draw 实例数据缓冲，绑定实例化数据流。
 *
 * @brief[en] Set per-draw instance data buffer
 * @explain[en] Set per-draw instance data buffer, bind instanced data stream.
 */
    public func setInstanceDataBuffer(idb: InstanceDataBufferPtr, start: UInt32, num: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_instance_data_buffer_cj(idb.value, start, num) })
    }

/**
 * @brief[zh-cn] 从顶点缓冲设置 per-draw 实例数据。
 * @explain[zh-cn] 从顶点缓冲设置 per-draw 实例数据，实例数据来自普通顶点缓冲。
 *
 * @brief[en] Set per-draw instance data from vertex buffer
 * @explain[en] Set per-draw instance data from vertex buffer, instance data sourced from regular vertex buffer.
 */
    public func setInstanceDataFromVertexBuffer(vb: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_instance_data_from_vertex_buffer_cj(vb.value, startVertex, num) })
    }

/**
 * @brief[zh-cn] 从动态顶点缓冲设置 per-draw 实例数据。
 *
 * @brief[en] Set per-draw instance data from dynamic vertex buffer
 */
    public func setInstanceDataFromDynamicVertexBuffer(vb: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_instance_data_from_dynamic_vertex_buffer_cj(vb.value, startVertex, num) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 实例计数。
 * @explain[zh-cn] 设置 per-draw 实例计数，指定本次绘制的实例数量。
 *
 * @brief[en] Set per-draw instance count
 * @explain[en] Set per-draw instance count, specify the number of instances for this draw call.
 */
    public func setInstanceCount(numInstances: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_instance_count_cj(numInstances) })
    }

/**
 * @brief[zh-cn] 设置遮挡查询条件（visible 决定后续 draw 是否执行）。
 * @explain[zh-cn] 设置遮挡查询条件，visible 决定后续 draw 是否执行。
 *
 * @brief[en] Set occlusion query condition (visible determines if subsequent draw executes)
 * @explain[en] Set occlusion query condition, visible determines if subsequent draw executes.
 */
    public func setCondition(query: OcclusionQueryHandle, visible: Bool): Unit {
        _execBgfx({ => bgfx.bgfx_set_condition_cj(query.value, visible) })
    }

/**
 * @brief[zh-cn] 丢弃当前 draw 的指定状态组（优化：通知 bgfx 后续不再使用这些状态）。
 * @explain[zh-cn] 丢弃当前 draw 的指定状态组，通知 bgfx 后续不再使用这些状态（性能优化）。
 *
 * @brief[en] Discard specified state groups for current draw (optimization hint to bgfx)
 * @explain[en] Discard specified state groups for current draw, hint to bgfx that these states are no longer needed (performance optimization).
 */
    public func discard(flags: UInt8): Unit {
        _execBgfx({ => bgfx.bgfx_discard_cj(flags) })
    }

/**
 * @brief[zh-cn] 提交带遮挡查询的 draw。
 * @explain[zh-cn] 提交带遮挡查询的绘制命令，查询结果决定可见性。
 *
 * @brief[en] Submit draw with occlusion query
 * @explain[en] Submit draw with occlusion query, query result determines visibility.
 */
    public func submitOcclusionQuery(viewId: UInt16, program: ProgramHandle, query: OcclusionQueryHandle, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8): Unit {
        _execBgfx({ => bgfx.bgfx_submit_occlusion_query_cj(viewId, program.value, query.value, depth, blend) })
    }

/**
 * @brief[zh-cn] 提交间接绘制（GPU 侧生成 draw 参数）。
 * @explain[zh-cn] 提交间接绘制，由 GPU 侧生成 draw 参数。
 *
 * @brief[en] Submit indirect draw (GPU-generated draw parameters)
 * @explain[en] Submit indirect draw, draw parameters generated on GPU side.
 */
    public func submitIndirect(
        viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle,
        start: UInt32, num: UInt32, depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_submit_indirect_cj(viewId, program.value, indirect.value, start, num, depth, blend) })
    }

/**
 * @brief[zh-cn] 提交带计数缓冲的间接绘制。
 * @explain[zh-cn] 提交带计数缓冲的间接绘制，支持 GPU 端动态控制绘制数量。
 *
 * @brief[en] Submit indirect draw with count buffer
 * @explain[en] Submit indirect draw with count buffer, supports GPU-side dynamic draw count control.
 */
    public func submitIndirectCount(
        viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle,
        start: UInt32, numHandle: IndexBufferHandle, numIndex: UInt32, numMax: UInt32,
        depth!: UInt32 = 0u32, blend!: UInt8 = 0xFFu8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_submit_indirect_count_cj(viewId, program.value, indirect.value, start, numHandle.value, numIndex, numMax, depth, blend) })
    }

/**
 * @brief[zh-cn] 提交计算调度。
 * @explain[zh-cn] 提交计算调度，按工作组维度分发计算着色器。
 *
 * @brief[en] Submit compute dispatch
 * @explain[en] Submit compute dispatch, dispatch compute shader by workgroup dimensions.
 */
    public func dispatch(viewId: UInt16, program: ProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags!: UInt8 = 0xFFu8): Unit {
        _execBgfx({ => bgfx.bgfx_dispatch_cj(viewId, program.value, numX, numY, numZ, flags) })
    }

/**
 * @brief[zh-cn] 提交间接计算调度。
 * @explain[zh-cn] 提交间接计算调度，调度参数由间接缓冲提供。
 *
 * @brief[en] Submit indirect compute dispatch
 * @explain[en] Submit indirect compute dispatch, dispatch parameters provided by indirect buffer.
 */
    public func dispatchIndirect(viewId: UInt16, program: ProgramHandle, indirect: IndirectBufferHandle, start: UInt32, num: UInt32, flags!: UInt8 = 0xFFu8): Unit {
        _execBgfx({ => bgfx.bgfx_dispatch_indirect_cj(viewId, program.value, indirect.value, start, num, flags) })
    }

/**
 * @brief[zh-cn] 绑定计算索引缓冲。
 * @explain[zh-cn] 绑定计算索引缓冲到指定 stage。
 *
 * @brief[en] Bind compute index buffer
 * @explain[en] Bind compute index buffer to specified stage.
 */
    public func setComputeIndexBuffer(stage: UInt8, ib: IndexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_compute_index_buffer_cj(stage, ib.value, access) })
    }

/**
 * @brief[zh-cn] 绑定计算顶点缓冲。
 * @explain[zh-cn] 绑定计算顶点缓冲到指定 stage。
 *
 * @brief[en] Bind compute vertex buffer
 * @explain[en] Bind compute vertex buffer to specified stage.
 */
    public func setComputeVertexBuffer(stage: UInt8, vb: VertexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_compute_vertex_buffer_cj(stage, vb.value, access) })
    }

/**
 * @brief[zh-cn] 绑定计算动态索引缓冲。
 *
 * @brief[en] Bind compute dynamic index buffer
 */
    public func setComputeDynamicIndexBuffer(stage: UInt8, ib: DynamicIndexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_compute_dynamic_index_buffer_cj(stage, ib.value, access) })
    }

/**
 * @brief[zh-cn] 绑定计算动态顶点缓冲。
 *
 * @brief[en] Bind compute dynamic vertex buffer
 */
    public func setComputeDynamicVertexBuffer(stage: UInt8, vb: DynamicVertexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_compute_dynamic_vertex_buffer_cj(stage, vb.value, access) })
    }

/**
 * @brief[zh-cn] 绑定计算间接缓冲。
 *
 * @brief[en] Bind compute indirect buffer
 */
    public func setComputeIndirectBuffer(stage: UInt8, ib: IndirectBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_compute_indirect_buffer_cj(stage, ib.value, access) })
    }

/**
 * @brief[zh-cn] 绑定图像（compute shader image unit）。
 * @explain[zh-cn] 绑定图像到计算着色器 image unit。
 *
 * @brief[en] Bind image (compute shader image unit)
 * @explain[en] Bind image to compute shader image unit.
 */
    public func setImage(stage: UInt8, tex: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_image_cj(stage, tex.value, mip, access, format) })
    }

/**
 * @brief[zh-cn] 触发 view 的 empty submit（仅推进 clear / view 序号，不绘制）。
 * @explain[zh-cn] 触发 view 的空提交，推进 clear/view 序号而不执行绘制，bgfx touch 是 clear 的载体。
 * @param[zh-cn] viewId bgfx view id
 *
 * @brief[en] Touch view (empty submit, advances clear/view sequence without drawing)
 * @explain[en] Trigger empty submit for a view, advances clear/view sequence without drawing; bgfx touch is the carrier for clear.
 * @param[en] viewId bgfx view id
 */
    public func touch(viewId: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_touch_cj(viewId) })
    }

    // ========================================================================
    // ===== 顶点/索引缓冲 + 布局生命周期封装 =====
    // ========================================================================
    // 设计动机：GltfLoader 等外部加载器需自行创建顶点缓冲，
    // 原直接调 bgfx_create_vertex_buffer_cj / bgfx_create_vertex_layout_cj
    // 违反分层。本组方法把这些资源创建/销毁封装进 renderer。
    // 与 Three.js WebGLGeometries 对齐：geometry 创建 GPU 资源。
    //
    // bgfx VertexLayout 创建序列（底层 FFI）：
    //   malloc(VertexLayout) → begin(layout, rendererType)
    //   → add(layout, attrib, num, type, normalized, asInt) ×N
    //   → end(layout) → create_vertex_layout(layout) → VertexLayoutHandle
    // 本 renderer 高阶 API 暴露 createVertexLayout(attributes)，封装整个序列；
    // 外部加载器只需提供属性描述列表，无须接触 CPointer<VertexLayout>。
    // ========================================================================

/**
 * @brief[zh-cn] 顶点缓冲创建所需：内存 + 对应布局句柄。
 * @explain[zh-cn] 顶点缓冲创建所需：内存 + 对应布局句柄。
 * 注意：layout 必须是经 createVertexLayout 创建的有效 VertexLayoutHandle。
 * bgfx create_vertex_buffer 接收 CPointer<VertexLayout>（而非 handle），
 * 故此处需保存 createVertexLayout 内部 malloc 的 VertexLayout 指针以便后续销毁。
 * 简化设计：layout 内存由本 renderer 持有，外部只拿 VertexLayoutHandle。
 *
 * @brief[en] Vertex buffer creation requirements: memory + corresponding layout handle
 * @explain[en] Vertex buffer creation requirements: memory + corresponding layout handle.
 * Note: layout must be a valid VertexLayoutHandle created by createVertexLayout.
 * bgfx create_vertex_buffer receives CPointer<VertexLayout> (not handle),
 * so the VertexLayout pointer malloc'd internally by createVertexLayout must be saved for later destruction.
 * Simplified design: layout memory is owned by this renderer, external code only gets the VertexLayoutHandle.
 */
    private var _layoutPtrs: HashMap<UInt16, AutoFreePtr<bgfx.VertexLayout>> = HashMap<UInt16, AutoFreePtr<bgfx.VertexLayout>>()

/**
 * @brief[zh-cn] 创建顶点布局（从属性描述列表）。
 * @explain[zh-cn] 创建顶点布局，封装 bgfx begin→add→end→create_vertex_layout 四步序列。
 * @param[zh-cn] attributes 属性描述列表（BgfxAttributeDesc）
 * @return[zh-cn] 顶点布局句柄（无效则 idx=65535）
 *
 * @brief[en] Create vertex layout from attribute description list
 * @explain[en] Create vertex layout, encapsulates the bgfx begin→add→end→create_vertex_layout sequence.
 * @param[en] attributes attribute description list (BgfxAttributeDesc)
 * @return[en] vertex layout handle (invalid if idx=65535)
 */
    public func createVertexLayout(attributes: Array<BgfxAttributeDesc>): VertexLayoutHandle {
        let resultBox: Box<VertexLayoutHandle> = Box(INVALID_VERTEX_LAYOUT_HANDLE)
        _execBgfx({ =>
            // 1. malloc VertexLayout
            let layoutHolder = AutoFreePtr<bgfx.VertexLayout>(unsafe { LibC.malloc<bgfx.VertexLayout>() })
            let layout = layoutHolder.get()
            // 2. begin + add ×N + end
            bgfx.bgfx_vertex_layout_begin_cj(layout, RendererType.Noop.value())
            for (attr in attributes) {
                bgfx.bgfx_vertex_layout_add_cj(layout, attr.attrib, attr.num, attr.attribType, attr.normalized, attr.asInt)
            }
            bgfx.bgfx_vertex_layout_end_cj(layout)
            // 3. create handle
            let handle = bgfx.bgfx_create_vertex_layout_cj(layout)
            resultBox.value = Box(handle)
            // 4. 保存 layout 内存，供 destroyVertexLayout 释放
            this._layoutPtrs.add(handle.idx, layoutHolder)
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁顶点布局句柄。
 * @explain[zh-cn] 销毁顶点布局句柄并释放内部布局内存。
 * @param[zh-cn] layout 待销毁顶点布局句柄
 *
 * @brief[en] Destroy vertex layout handle
 * @explain[en] Destroys the vertex layout handle and frees the internal layout memory.
 * @param[en] layout vertex layout handle to destroy
 */
    public func destroyVertexLayout(layout: VertexLayoutHandle): Unit {
        _execBgfx({ =>
            bgfx.bgfx_destroy_vertex_layout_cj(layout.value)
            // 释放 malloc 的 VertexLayout 内存
            match (this._layoutPtrs.get(layout.value.idx)) {
                case Some(holder) => holder.dispose()
                case None => ()
            }
            this._layoutPtrs.remove(layout.value.idx)
        })
    }

/**
 * @brief[zh-cn] 创建顶点缓冲。
 * @explain[zh-cn] 创建静态顶点缓冲，上传顶点数据到 GPU。
 * 注意：bgfx_create_vertex_buffer_cj 第二参为 CPointer<VertexLayout>（layout 内存指针），
 * 而非 VertexLayoutHandle。本方法要求外部传入 createVertexLayout 返回的 handle，
 * 但因 FFI 需要 layout 内存指针，此处需要外部同时传 layout 内存指针。
 * 外部加载器经 createVertexLayout 拿到 handle 后，可再经本方法用 layout 内存指针创建 VB。
 * @param[zh-cn] mem 顶点数据内存（bgfx_make_ref_cj 包装的像素数据）
 * layout 顶点布局内存指针（CPointer<VertexLayout>）
 * flags 缓冲 flags（默认 0）
 * @return[zh-cn] 顶点缓冲句柄
 *
 * @brief[en] Create vertex buffer
 * @explain[en] Create static vertex buffer, upload vertex data to GPU.
 * 注意：bgfx_create_vertex_buffer_cj 第二参为 CPointer<VertexLayout>（layout 内存指针），
 * 而非 VertexLayoutHandle。本方法要求外部传入 createVertexLayout 返回的 handle，
 * 简化方案：直接暴露 CPointer<VertexLayout> 参数（与 BgfxAttributeUtils 一致），
 * @param[en] mem vertex data memory (wrapped by bgfx_make_ref_cj)
 * layout Vertex layout memory pointer (CPointer<VertexLayout>)
 * flags buffer flags (default 0)
 * @return[en] vertex buffer handle
 */
    public func createVertexBuffer(
        mem: BgfxMemory,
        layout: VertexLayoutHandle,
        flags!: UInt16 = 0u16
    ): VertexBufferHandle {
        let resultBox: Box<VertexBufferHandle> = Box(INVALID_VERTEX_BUFFER_HANDLE)
        _execBgfx({ =>
            match (this._layoutPtrs.get(layout.value.idx)) {
                case Some(holder) => resultBox.value = Box(bgfx.bgfx_create_vertex_buffer_cj(mem.get(), holder.get(), flags))
                case None => resultBox.value = INVALID_VERTEX_BUFFER_HANDLE
            }
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 用 layout handle 创建顶点缓冲（安全封装，外部无须管理 layout 指针）。
 * @explain[zh-cn] 创建静态顶点缓冲（安全封装），外部无需管理 layout 指针。
 * 设计动机：bgfx_create_vertex_buffer_cj 第二参为 CPointer<VertexLayout>（layout 内存指针），
 * 而非 handle。本方法内部从 createVertexLayout 保存的 layout 指针表中按 handle.idx 查询，
 * 外部只需传 VertexLayoutHandle，无须 malloc / begin / add / end / create_vertex_layout
 * 整条 raw FFI 序列，也无须接触 CPointer<VertexLayout>。
 * @param[zh-cn] mem 顶点数据内存（bgfx_make_ref_cj 包装的像素数据）
 * layout 经 renderer.createVertexLayout 创建的布局句柄
 * flags 缓冲 flags（默认 0）
 * @return[zh-cn] 顶点缓冲句柄（layout 不存在时为无效句柄）
 *
 * @brief[en] Create vertex buffer using layout handle (safe wrapper, no layout pointer management needed)
 * @explain[en] Create static vertex buffer (safe wrapper), no layout pointer management needed.
 * 设计动机：bgfx_create_vertex_buffer_cj 第二参为 CPointer<VertexLayout>（layout 内存指针），
 * 而非 handle。本方法内部从 createVertexLayout 保存的 layout 指针表中按 handle.idx 查询，
 * 外部只需传 VertexLayoutHandle，无须 malloc / begin / add / end / create_vertex_layout
 * 整条 raw FFI 序列，也无须接触 CPointer<VertexLayout>.
 * @param[en] mem vertex data memory (wrapped by bgfx_make_ref_cj)
 * layout layout handle created by renderer.createVertexLayout
 * flags buffer flags (default 0)
 * @return[en] vertex buffer handle（Invalid handle if layout does not exist）
 */
    public func createVertexBufferFromLayout(
        mem: BgfxMemory,
        layout: VertexLayoutHandle,
        flags!: UInt16 = 0u16
    ): VertexBufferHandle {
        let resultBox: Box<VertexBufferHandle> = Box(INVALID_VERTEX_BUFFER_HANDLE)
        _execBgfx({ =>
            match (this._layoutPtrs.get(layout.value.idx)) {
                case Some(holder) => resultBox.value = Box(bgfx.bgfx_create_vertex_buffer_cj(mem.get(), holder.get(), flags))
                case None => resultBox.value = INVALID_VERTEX_BUFFER_HANDLE
            }
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 创建索引缓冲。
 * @explain[zh-cn] 创建静态索引缓冲，上传索引数据到 GPU。
 * @param[zh-cn] mem 索引数据内存
 * flags 缓冲 flags（默认 0）
 * @return[zh-cn] 索引缓冲句柄
 *
 * @brief[en] Create index buffer
 * @explain[en] Create static index buffer, upload index data to GPU.
 * @param[en] mem index data memory
 * flags buffer flags (default 0)
 * @return[en] index buffer handle
 */
    public func createIndexBuffer(
        mem: BgfxMemory,
        flags!: UInt16 = 0u16
    ): IndexBufferHandle {
        let resultBox: Box<IndexBufferHandle> = Box(INVALID_INDEX_BUFFER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_index_buffer_cj(mem.get(), flags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁顶点缓冲句柄。
 * @explain[zh-cn] 销毁顶点缓冲句柄，释放 GPU 资源。
 * @param[zh-cn] vb 待销毁顶点缓冲句柄
 *
 * @brief[en] Destroy vertex buffer handle
 * @explain[en] Destroy vertex buffer handle, release GPU resources.
 * @param[en] vb 待销毁vertex buffer handle
 */
    public func destroyVertexBuffer(vb: VertexBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_vertex_buffer_cj(vb.value) })
    }

/**
 * @brief[zh-cn] 销毁索引缓冲句柄。
 * @explain[zh-cn] 销毁索引缓冲句柄，释放 GPU 资源。
 * @param[zh-cn] ib 待销毁索引缓冲句柄
 *
 * @brief[en] Destroy index buffer handle
 * @explain[en] Destroy index buffer handle, release GPU resources.
 * @param[en] ib index buffer handle to destroy
 */
    public func destroyIndexBuffer(ib: IndexBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_index_buffer_cj(ib.value) })
    }

/**
 * @brief[zh-cn] 包装原始像素数据为 bgfx Memory 引用。
 * @explain[zh-cn] 包装原始像素数据为 bgfx Memory 引用，供 create*Buffer 使用。
 * bgfx 需 bgfx_make_ref_cj 把 (data, size) 包装为 Memory*。
 * @param[zh-cn] data 像素数据指针
 * size 数据字节数
 * @return[zh-cn] bgfx Memory 引用指针
 *
 * @brief[en] Wrap raw pixel data as bgfx Memory reference
 * @explain[en] Wrap raw pixel data as bgfx Memory reference.
 * bgfx 需 bgfx_make_ref_cj 把 (data, size) 包装为 Memory*，供 create*Buffer 使用.
 * @param[en] data pixel data pointer
 * size data byte count
 * @return[en] bgfx Memory reference pointer
 */
    public func makeRef(data: PtrArray<UInt8>): BgfxMemory {
        let resultBox: Box<BgfxMemory> = Box(BgfxMemory(0u32))
        let dataRef = data
        _execBgfx({ =>
            resultBox.value = BgfxMemory.ref(unsafe { CPointer<Unit>(dataRef.data()) }, UInt32(dataRef.size()))
        })
        return resultBox.value
    }

    // ========================================================================
    // ===== 资源生命周期补充：纹理变体 / framebuffer 变体 =====
    // ========================================================================
    // 设计动机：与 Three.js WebGLTextures / WebGLRenderTarget 对齐，纹理与
    // render target 的创建/更新/查询变体统一经 renderer 高阶 API 暴露，
    // 外部渲染开发只依赖 ThreeRenderer 一个类，无须 import 其他类。
    // ========================================================================

/**
 * @brief[zh-cn] 创建 2D 纹理（按后备缓冲比例）。
 * @explain[zh-cn] 创建按后备缓冲比例缩放的 2D 纹理，随窗口自动调整尺寸。
 * @param[zh-cn] ratio BackbufferRatio.value()（Half/Quarter/Eighth/Sixteenth/Double）
 * hasMips 是否生成 mipmap
 * numLayers 图层数（默认 1）
 * format 纹理格式（TextureFormat.value()）
 * flags 纹理 flags（TEXTURE_RT | SAMPLER_* 组合）
 * @return[zh-cn] 纹理句柄
 *
 * @brief[en] Create 2D texture (scaled by backbuffer ratio)
 * @explain[en] Create 2D texture scaled by backbuffer ratio, automatically resizes with window.
 * @param[en] ratio BackbufferRatio.value() (Half/Quarter/Eighth/Sixteenth/Double)
 * hasMips whether to generate mipmaps
 * numLayers layer count (default 1)
 * format texture format（TextureFormat.value()）
 * flags texture flags (TEXTURE_RT | SAMPLER_* combination)
 * @return[en] texture handle
 */
    public func createTexture2DScaled(
        ratio: UInt32,
        hasMips: Bool,
        numLayers: UInt16,
        format: UInt32,
        flags: UInt64
    ): TextureHandle {
        let resultBox: Box<TextureHandle> = Box(INVALID_TEXTURE_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_texture_2d_scaled_cj(ratio, hasMips, numLayers, format, flags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 更新 2D 纹理子区域数据。
 * @explain[zh-cn] 更新 2D 纹理子区域数据。
 * @param[zh-cn] tex 目标纹理句柄
 * layer 图层索引
 * mip mip 层
 * x 子区域 x 偏移
 * y 子区域 y 偏移
 * width 子区域宽
 * height 子区域高
 * mem 像素数据（BgfxMemory）
 * pitch 行步长（字节）
 *
 * @brief[en] Update 2D texture sub-region data
 * @explain[en] Update 2D texture sub-region data.
 * @param[en] tex 目标texture handle
 * layer layer index
 * mip mip level
 * x sub-region x offset
 * y sub-region y offset
 * width sub-region width
 * height sub-region height
 * mem pixel data (BgfxMemory)
 * pitch row pitch (bytes)
 */
    public func updateTexture2D(
        tex: TextureHandle, layer: UInt16, mip: UInt8,
        x: UInt16, y: UInt16, width: UInt16, height: UInt16,
        mem: BgfxMemory, pitch: UInt16
    ): Unit {
        _execBgfx({ => bgfx.bgfx_update_texture_2d_cj(tex.value, layer, mip, x, y, width, height, mem.get(), pitch) })
    }

/**
 * @brief[zh-cn] 更新 3D 纹理子区域数据。
 * @explain[zh-cn] 更新 3D 纹理子区域数据。
 *
 * @brief[en] Update 3D texture sub-region data
 * @explain[en] Update 3D texture sub-region data.
 */
    public func updateTexture3D(
        tex: TextureHandle, mip: UInt8,
        x: UInt16, y: UInt16, z: UInt16,
        width: UInt16, height: UInt16, depth: UInt16,
        mem: BgfxMemory
    ): Unit {
        _execBgfx({ => bgfx.bgfx_update_texture_3d_cj(tex.value, mip, x, y, z, width, height, depth, mem.get()) })
    }

/**
 * @brief[zh-cn] 更新 cube 纹理面子区域数据。
 * @explain[zh-cn] 更新 cube 纹理面子区域数据。
 *
 * @brief[en] Update cube texture face sub-region data
 * @explain[en] Update cube texture face sub-region data.
 */
    public func updateTextureCube(
        tex: TextureHandle, layer: UInt16, side: UInt8, mip: UInt8,
        x: UInt16, y: UInt16, width: UInt16, height: UInt16,
        mem: BgfxMemory, pitch: UInt16
    ): Unit {
        _execBgfx({ => bgfx.bgfx_update_texture_cube_cj(tex.value, layer, side, mip, x, y, width, height, mem.get(), pitch) })
    }

/**
 * @brief[zh-cn] 设置纹理调试名称。
 * @explain[zh-cn] 设置纹理调试名称，用于 GPU 调试工具中标识纹理。
 *
 * @brief[en] Set texture debug name
 * @explain[en] Set texture debug name, used to identify textures in GPU debug tools.
 */
    public func setTextureName(tex: TextureHandle, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_texture_name_cj(tex.value, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 查询纹理参数是否有效。
 * @explain[zh-cn] 查询纹理参数是否有效，创建前校验用。
 * @param[zh-cn] depth 深度（2D 纹理=1）
 * cubeMap 是否 cube
 * numLayers 图层数
 * format 纹理格式
 * flags 纹理 flags
 * @return[zh-cn] 是否有效
 *
 * @brief[en] Check if texture parameters are valid
 * @explain[en] Check if texture parameters are valid, used for pre-creation validation.
 * @param[en] depth depth (1 for 2D textures)
 * cubeMap whether it is a cubemap
 * numLayers layer count
 * format texture format
 * flags texture flags
 * @return[en] whether valid
 */
    public func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: UInt32, flags: UInt64): Bool {
        let resultBox: Box<Bool> = Box(false)
        _execBgfx({ => resultBox.value = bgfx.bgfx_is_texture_valid_cj(depth, cubeMap, numLayers, format, flags) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 计算纹理存储大小。
 * @explain[zh-cn] 计算纹理存储大小，用于预分配内存。
 * @param[zh-cn] info 输出 TextureInfo 指针
 * width 宽
 * height 高
 * depth 深
 * cubeMap 是否 cube
 * hasMips 是否 mipmap
 * numLayers 图层数
 * format 纹理格式
 *
 * @brief[en] Calculate texture storage size
 * @explain[en] Calculate texture storage size, used for pre-allocating memory.
 * @param[en] info output TextureInfo pointer
 * width width
 * height height
 * depth depth
 * cubeMap whether it is a cubemap
 * hasMips whether mipmapped
 * numLayers layer count
 * format texture format
 */
    public func calcTextureSize(
        info: CPointer<bgfx.TextureInfo>,
        width: UInt16, height: UInt16, depth: UInt16,
        cubeMap: Bool, hasMips: Bool, numLayers: UInt16, format: UInt32
    ): Unit {
        _execBgfx({ => bgfx.bgfx_calc_texture_size_cj(info, width, height, depth, cubeMap, hasMips, numLayers, format) })
    }

/**
 * @brief[zh-cn] 创建 frame buffer（按后备缓冲比例）。
 * @explain[zh-cn] 创建按后备缓冲比例缩放的 frame buffer，随窗口自动调整尺寸。
 *
 * @brief[en] Create Frame buffer (scaled by backbuffer ratio)
 * @explain[en] Create frame buffer scaled by backbuffer ratio, automatically resizes with window.
 */
    public func createFrameBufferScaled(ratio: UInt32, format: UInt32, textureFlags: UInt64): FrameBufferHandle {
        let resultBox: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_frame_buffer_scaled_cj(ratio, format, textureFlags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由 Attachment 列表创建 frame buffer。
 * @explain[zh-cn] 由 Attachment 列表创建 frame buffer，支持多附件渲染目标。
 * @param[zh-cn] attachments attachment 数组（Box 包装的 Attachment）
 * destroyTexture 销毁 FB 时是否自动销毁 attachment 纹理
 * @return[zh-cn] frame buffer 句柄
 *
 * @brief[en] Create Frame buffer from attachment list
 * @explain[en] Create frame buffer from attachment list, supports multi-attachment render targets.
 * @param[en] attachments attachment array (Box-wrapped Attachment)
 * destroyTexture whether to auto-destroy attachment textures when FB is destroyed
 * @return[en] Frame buffer handle
 */
    public func createFrameBufferFromAttachment(attachments: Array<Attachment>, destroyTexture: Bool): FrameBufferHandle {
        let resultBox: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)
        let num = UInt8(attachments.size)
        let attachmentsRef = attachments
        _execBgfx({ =>
            let holder = AutoFreePtr<bgfx.Attachment>(unsafe { LibC.malloc<bgfx.Attachment>(count: Int64(num)) })
            for (i in 0..Int64(num)) {
                unsafe { (holder.get() + i).write(0, attachmentsRef[i].value) }
            }
            resultBox.value = Box(bgfx.bgfx_create_frame_buffer_from_attachment_cj(num, holder.get(), destroyTexture))
            holder.dispose()
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由原生窗口句柄创建 frame buffer（离屏窗口渲染）。
 * @explain[zh-cn] 新版 bgfx 以 SwapChain 描述符取代 bgfx_create_frame_buffer_from_nwh。
 *
 * @brief[en] Create Frame buffer from native window handle (offscreen window rendering)
 * @explain[en] New bgfx replaces bgfx_create_frame_buffer_from_nwh with a SwapChain descriptor.
 */
    public func createFrameBufferFromNwh(
        nwh: CPointer<Unit>,
        width: UInt16, height: UInt16,
        format: UInt32, depthFormat: UInt32
    ): FrameBufferHandle {
        let resultBox: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)
        _execBgfx({ =>
            let descHolder = AutoFreePtr<bgfx.SwapChain>(unsafe { LibC.malloc<bgfx.SwapChain>() })
            let desc = descHolder.get()
            unsafe { desc.write(bgfx.SwapChain()) }
            var sc = unsafe { desc.read() }
            sc.nwh = nwh
            sc.width = UInt32(width)
            sc.height = UInt32(height)
            sc.formatColor = format
            sc.formatDepthStencil = depthFormat
            unsafe { desc.write(sc) }
            resultBox.value = Box(bgfx.bgfx_create_frame_buffer_from_swap_chain_cj(desc))
            descHolder.dispose()
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 查询 frame buffer 配置是否有效。
 * @explain[zh-cn] 查询 frame buffer 配置是否有效，创建前校验用。
 *
 * @brief[en] Check if Frame buffer configuration is valid
 * @explain[en] Check if frame buffer configuration is valid, used for pre-creation validation.
 */
    public func isFrameBufferValid(num: UInt8, attachment: AttachmentPtr): Bool {
        let resultBox: Box<Bool> = Box(false)
        _execBgfx({ => resultBox.value = bgfx.bgfx_is_frame_buffer_valid_cj(num, attachment.value) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 设置 frame buffer 调试名称。
 *
 * @brief[en] Set Frame buffer debug name
 */
    public func setFrameBufferName(fb: FrameBufferHandle, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_frame_buffer_name_cj(fb.value, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 设置索引缓冲调试名称。
 *
 * @brief[en] Set index buffer debug name
 */
    public func setIndexBufferName(ib: IndexBufferHandle, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_index_buffer_name_cj(ib.value, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 设置顶点缓冲调试名称。
 *
 * @brief[en] Set vertex buffer debug name
 */
    public func setVertexBufferName(vb: VertexBufferHandle, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_vertex_buffer_name_cj(vb.value, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 初始化 Attachment 结构。
 * @explain[zh-cn] 初始化 Attachment 结构，配置纹理附件的访问方式和层级。
 *
 * @brief[en] Initialize Attachment structure
 * @explain[en] Initialize Attachment structure, configure texture attachment access mode and layers.
 */
    public func attachmentInit(
        attachment: CPointer<bgfx.Attachment>,
        tex: TextureHandle, access: UInt32,
        layer: UInt16, numLayers: UInt16, mip: UInt16, resolve: UInt8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_attachment_init_cj(attachment, tex.value, access, layer, numLayers, mip, flags: resolve) })
    }

    // ========================================================================
    // ===== 资源生命周期补充：动态缓冲 / 间接缓冲 / 遮挡查询 =====
    // ========================================================================
    // 设计动机：动态缓冲（每帧可更新）、间接绘制缓冲、遮挡查询统一经
    // renderer 高阶 API 暴露，外部渲染开发只依赖 ThreeRenderer 一个类。
    // 对照 Three.js WebGLGeometries（静态缓冲）的扩展：动态缓冲对应
    // BufferAttribute 的 needsUpdate 每帧更新路径。
    // ========================================================================

/**
 * @brief[zh-cn] 创建动态顶点缓冲（仅指定数量，数据后续 update 填充）。
 * @explain[zh-cn] 创建动态顶点缓冲（仅指定数量），数据后续通过 update 填充。
 * @param[zh-cn] num 顶点数量
 * layout 顶点布局指针（CPointer<bgfx.VertexLayout>）
 * flags 缓冲 flags（BUFFER_* 组合）
 * @return[zh-cn] 动态顶点缓冲句柄
 *
 * @brief[en] Create dynamic vertex buffer (size only, data filled by subsequent update)
 * @explain[en] Create dynamic vertex buffer (size only), data filled by subsequent update.
 * @param[en] num vertex count
 * layout vertex layout pointer (CPointer<bgfx.VertexLayout>)
 * flags buffer flags (BUFFER_* combination)
 * @return[en] 动态vertex buffer handle
 */
    public func createDynamicVertexBuffer(num: UInt32, layout: VertexLayoutPtr, flags: UInt16): DynamicVertexBufferHandle {
        let resultBox: Box<DynamicVertexBufferHandle> = Box(INVALID_DYNAMIC_VERTEX_BUFFER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_dynamic_vertex_buffer_cj(num, layout.value, flags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由内存创建动态顶点缓冲。
 * @explain[zh-cn] 由内存创建动态顶点缓冲，立即上传数据。
 * @param[zh-cn] mem 顶点数据内存（Some=有数据；None=空）
 * layout 顶点布局指针
 * flags 缓冲 flags
 * @return[zh-cn] 动态顶点缓冲句柄
 *
 * @brief[en] Create dynamic vertex buffer from memory
 * @explain[en] Create dynamic vertex buffer from memory, upload data immediately.
 * @param[en] mem vertex data memory (Some=data; None=empty)
 * layout vertex layout pointer
 * flags 缓冲 flags
 * @return[en] 动态vertex buffer handle
 */
    public func createDynamicVertexBufferMem(mem: Option<BgfxMemory>, layout: VertexLayoutPtr, flags: UInt16): DynamicVertexBufferHandle {
        let resultBox: Box<DynamicVertexBufferHandle> = Box(INVALID_DYNAMIC_VERTEX_BUFFER_HANDLE)
        let memRef = mem
        _execBgfx({ =>
            let memPtr = match (memRef) {
                case Some(m) => m.get()
                case None => CPointer<bgfx.Memory>()
            }
            resultBox.value = Box(bgfx.bgfx_create_dynamic_vertex_buffer_mem_cj(memPtr, layout.value, flags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 更新动态顶点缓冲数据。
 * @explain[zh-cn] 更新动态顶点缓冲的部分数据。
 *
 * @brief[en] Update dynamic vertex buffer data
 * @explain[en] Update partial data of dynamic vertex buffer.
 */
    public func updateDynamicVertexBuffer(handle: DynamicVertexBufferHandle, startVertex: UInt32, mem: BgfxMemory): Unit {
        _execBgfx({ => bgfx.bgfx_update_dynamic_vertex_buffer_cj(handle.value, startVertex, mem.get()) })
    }

/**
 * @brief[zh-cn] 销毁动态顶点缓冲。
 * @explain[zh-cn] 销毁动态顶点缓冲，释放 GPU 资源。
 *
 * @brief[en] Destroy dynamic vertex buffer
 * @explain[en] Destroy dynamic vertex buffer, release GPU resources.
 */
    public func destroyDynamicVertexBuffer(handle: DynamicVertexBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_dynamic_vertex_buffer_cj(handle.value) })
    }

/**
 * @brief[zh-cn] 创建动态索引缓冲（仅指定数量）。
 * @explain[zh-cn] 创建动态索引缓冲（仅指定数量），数据后续通过 update 填充。
 *
 * @brief[en] Create dynamic index buffer (size only)
 * @explain[en] Create dynamic index buffer (size only), data filled by subsequent update.
 */
    public func createDynamicIndexBuffer(num: UInt32, flags: UInt16): DynamicIndexBufferHandle {
        let resultBox: Box<DynamicIndexBufferHandle> = Box(INVALID_DYNAMIC_INDEX_BUFFER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_dynamic_index_buffer_cj(num, flags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由内存创建动态索引缓冲。
 * @explain[zh-cn] 由内存创建动态索引缓冲，立即上传数据。
 *
 * @brief[en] Create dynamic index buffer from memory
 * @explain[en] Create dynamic index buffer from memory, upload data immediately.
 */
    public func createDynamicIndexBufferMem(mem: Option<BgfxMemory>, flags: UInt16): DynamicIndexBufferHandle {
        let resultBox: Box<DynamicIndexBufferHandle> = Box(INVALID_DYNAMIC_INDEX_BUFFER_HANDLE)
        let memRef = mem
        _execBgfx({ =>
            let memPtr = match (memRef) {
                case Some(m) => m.get()
                case None => CPointer<bgfx.Memory>()
            }
            resultBox.value = Box(bgfx.bgfx_create_dynamic_index_buffer_mem_cj(memPtr, flags))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 更新动态索引缓冲数据。
 * @explain[zh-cn] 更新动态索引缓冲的部分数据。
 *
 * @brief[en] Update dynamic index buffer data
 * @explain[en] Update partial data of dynamic index buffer.
 */
    public func updateDynamicIndexBuffer(handle: DynamicIndexBufferHandle, startIndex: UInt32, mem: BgfxMemory): Unit {
        _execBgfx({ => bgfx.bgfx_update_dynamic_index_buffer_cj(handle.value, startIndex, mem.get()) })
    }

/**
 * @brief[zh-cn] 销毁动态索引缓冲。
 * @explain[zh-cn] 销毁动态索引缓冲，释放 GPU 资源。
 *
 * @brief[en] Destroy dynamic index buffer
 * @explain[en] Destroy dynamic index buffer, release GPU resources.
 */
    public func destroyDynamicIndexBuffer(handle: DynamicIndexBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_dynamic_index_buffer_cj(handle.value) })
    }

/**
 * @brief[zh-cn] 创建间接绘制缓冲（GPU 侧生成 draw 参数）。
 * @explain[zh-cn] 创建间接绘制缓冲，用于 GPU 侧生成 draw 参数。
 *
 * @brief[en] Create indirect draw buffer (GPU-generated draw parameters)
 * @explain[en] Create indirect draw buffer, used for GPU-generated draw parameters.
 */
    public func createIndirectBuffer(num: UInt32): IndirectBufferHandle {
        let resultBox: Box<IndirectBufferHandle> = Box(INVALID_INDIRECT_BUFFER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_indirect_buffer_cj(num))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁间接绘制缓冲。
 * @explain[zh-cn] 销毁间接绘制缓冲，释放 GPU 资源。
 *
 * @brief[en] Destroy indirect draw buffer
 * @explain[en] Destroy indirect draw buffer, release GPU resources.
 */
    public func destroyIndirectBuffer(handle: IndirectBufferHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_indirect_buffer_cj(handle.value) })
    }

/**
 * @brief[zh-cn] 创建遮挡查询。
 * @explain[zh-cn] 创建遮挡查询对象，用于检测像素可见性。
 *
 * @brief[en] Create occlusion query
 * @explain[en] Create occlusion query object, used to detect pixel visibility.
 */
    public func createOcclusionQuery(): OcclusionQueryHandle {
        let resultBox: Box<OcclusionQueryHandle> = Box(INVALID_OCCLUSION_QUERY_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_occlusion_query_cj())
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 查询遮挡查询结果。
 * @explain[zh-cn] 查询遮挡查询结果，返回可见像素数或 0。
 * @param[zh-cn] handle 遮挡查询句柄
 * result 输出结果指针（Int32：可见像素数或 0）
 * @return[zh-cn] 结果状态（0=未就绪，1=已就绪，对应 OcclusionQueryResult.value()）
 *
 * @brief[en] Get occlusion query result
 * @explain[en] Get occlusion query result, returns visible pixel count or 0.
 * @param[en] handle occlusion query handle
 * result output result pointer (Int32: visible pixel count or 0)
 * @return[en] Result status (0=not ready, 1=ready, OcclusionQueryResult.value())
 */
    public func getOcclusionQueryResult(handle: OcclusionQueryHandle, result: PtrArray<Int32>): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        _execBgfx({ => resultBox.value = bgfx.bgfx_get_result_cj(handle.value, result.data()) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁遮挡查询。
 * @explain[zh-cn] 销毁遮挡查询对象，释放 GPU 资源。
 *
 * @brief[en] Destroy occlusion query
 * @explain[en] Destroy occlusion query object, release GPU resources.
 */
    public func destroyOcclusionQuery(handle: OcclusionQueryHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_occlusion_query_cj(handle.value) })
    }

    // ========================================================================
    // ===== 资源生命周期补充：shader / program / uniform =====
    // ========================================================================
    // 设计动机：着色器、程序、uniform 的创建/销毁/查询统一经 renderer 高阶
    // API 暴露，外部渲染开发只依赖 ThreeRenderer 一个类，无须 import 内部
    // 管理类（BgfxPrograms / BgfxUniforms 为 renderer 内部实现细节）。
    // 对照 Three.js：WebGLPrograms / WebGLUniforms 是 renderer 内部组件，
    // 用户通过 WebGLRenderer 暴露的 API 使用。
    // ========================================================================

/**
 * @brief[zh-cn] 由二进制源码创建着色器。
 * @explain[zh-cn] 由二进制源码创建着色器，bgfx 使用预编译二进制格式。
 * @param[zh-cn] mem 着色器二进制数据（BgfxMemory）
 * @return[zh-cn] 着色器句柄
 *
 * @brief[en] Create shader from binary source
 * @explain[en] Create shader from binary source, bgfx uses pre-compiled binary format.
 * @param[en] mem shader binary data (BgfxMemory)
 * @return[en] shader handle
 */
    public func createShader(mem: BgfxMemory): ShaderHandle {
        let resultBox: Box<ShaderHandle> = Box(INVALID_SHADER_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_shader_cj(mem.get()))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁着色器。
 * @explain[zh-cn] 销毁着色器，释放 GPU 资源。
 *
 * @brief[en] Destroy shader
 * @explain[en] Destroy shader, release GPU resources.
 */
    public func destroyShader(handle: ShaderHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_shader_cj(handle.value) })
    }

/**
 * @brief[zh-cn] 设置着色器调试名称。
 * @explain[zh-cn] 设置着色器调试名称，用于 GPU 调试工具中标识着色器。
 *
 * @brief[en] Set shader debug name
 * @explain[en] Set shader debug name, used to identify shaders in GPU debug tools.
 */
    public func setShaderName(handle: ShaderHandle, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_set_shader_name_cj(handle.value, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 获取着色器引用的 uniform 句柄列表。
 * @explain[zh-cn] 获取着色器引用的 uniform 句柄列表，用于反射查询。
 * @param[zh-cn] handle 着色器句柄
 * max 最大查询数量
 * @return[zh-cn] (uniform 句柄数组, 实际数量)
 *
 * @brief[en] Get list of uniform handles referenced by shader
 * @explain[en] Get list of uniform handles referenced by shader, used for reflection queries.
 * @param[en] handle shader handle
 * max maximum query count
 * @return[en] (uniform handle array and actual count
 */
    public func getShaderUniforms(handle: ShaderHandle, max: UInt16): (Array<UniformHandle>, UInt16) {
        let resultBox: Box<(Array<UniformHandle>, UInt16)> = Box((Array<UniformHandle>(), 0u16))
        _execBgfx({ =>
            let holder = AutoFreePtr<bgfx.UniformHandle>(unsafe { LibC.malloc<bgfx.UniformHandle>(count: Int64(max)) })
            let num = bgfx.bgfx_get_shader_uniforms_cj(handle.value, holder.get(), max)
            let arr = Array<UniformHandle>(Int64(num), { _ => INVALID_UNIFORM_HANDLE })
            for (i in 0..Int64(num)) {
                arr[i] = Box(unsafe { (holder.get() + i).read() })
            }
            holder.dispose()
            resultBox.value = (arr, num)
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由 vs+fs 链接程序。
 * @explain[zh-cn] 由顶点着色器和片元着色器链接程序。
 * @param[zh-cn] vsh 顶点着色器句柄
 * fsh 片元着色器句柄
 * destroyShaders 链接后是否销毁输入着色器
 * @return[zh-cn] 程序句柄
 *
 * @brief[en] Link program from vertex + fragment shader
 * @explain[en] Link program from vertex and fragment shaders.
 * @param[en] vsh Vertex shader handle
 * fsh Fragment shader handle
 * destroyShaders whether to destroy input shaders after linking
 * @return[en] program handle
 */
    public func createProgram(vsh: ShaderHandle, fsh: ShaderHandle, destroyShaders: Bool): ProgramHandle {
        let resultBox: Box<ProgramHandle> = Box(INVALID_PROGRAM_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_program_cj(vsh.value, fsh.value, destroyShaders))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 由计算着色器创建程序。
 * @explain[zh-cn] 由计算着色器创建程序。
 *
 * @brief[en] Create program from compute shader
 * @explain[en] Create program from compute shader.
 */
    public func createComputeProgram(csh: ShaderHandle, destroyShaders: Bool): ProgramHandle {
        let resultBox: Box<ProgramHandle> = Box(INVALID_PROGRAM_HANDLE)
        _execBgfx({ =>
            resultBox.value = Box(bgfx.bgfx_create_compute_program_cj(csh.value, destroyShaders))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁程序。
 * @explain[zh-cn] 销毁程序，释放 GPU 资源。
 *
 * @brief[en] Destroy program
 * @explain[en] Destroy program, release GPU resources.
 */
    public func destroyProgram(handle: ProgramHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_program_cj(handle.value) })
    }

/**
 * @brief[zh-cn] 创建 uniform 句柄。
 * @explain[zh-cn] 创建 uniform 句柄，按名称和类型注册全局 uniform。
 * @param[zh-cn] name uniform 名称
 * uniformType UniformType.value()（Sampler/Vec4/Mat3/Mat4 等）
 * num 数组长度（默认 1）
 * @return[zh-cn] uniform 句柄
 *
 * @brief[en] Create uniform handle
 * @explain[en] Create uniform handle, register global uniform by name and type.
 * @param[en] name uniform name
 * uniformType UniformType.value()（Sampler/Vec4/Mat3/Mat4 等）
 * num array length (default 1)
 * @return[en] uniform handle
 */
    public func createUniform(name: String, uniformType: UInt32, num!: UInt16 = 1u16): UniformHandle {
        let resultBox: Box<UniformHandle> = Box(INVALID_UNIFORM_HANDLE)
        let nameRef = name
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(nameRef) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            resultBox.value = Box(bgfx.bgfx_create_uniform_cj(cName, uniformType, num))
            cNameHolder.dispose()
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 销毁 uniform 句柄。
 * @explain[zh-cn] 销毁 uniform 句柄，释放资源。
 *
 * @brief[en] Destroy uniform handle
 * @explain[en] Destroy uniform handle, release resources.
 */
    public func destroyUniform(handle: UniformHandle): Unit {
        _execBgfx({ => bgfx.bgfx_destroy_uniform_cj(handle.value) })
    }

/**
 * @brief[zh-cn] 获取 uniform 信息（名称/类型/数量）。
 * @explain[zh-cn] 获取 uniform 信息（名称/类型/数量），用于反射查询。
 * @param[zh-cn] handle uniform 句柄
 * info 输出 UniformInfo 指针
 *
 * @brief[en] Get uniform info (name/type/count)
 * @explain[en] Get uniform info (name/type/count), used for reflection queries.
 * @param[en] handle uniform handle
 * info output UniformInfo pointer
 */
    public func getUniformInfo(handle: UniformHandle, info: UniformInfoPtr): Unit {
        _execBgfx({ => bgfx.bgfx_get_uniform_info_cj(handle.value, info.value) })
    }

    // ========================================================================
    // ===== 瞬态缓冲绑定（渲染命令，per-draw 瞬态） =====
    // ========================================================================
    // 对照 Three.js: BufferAttribute 的每帧更新路径 —— 瞬态缓冲每帧由
    // 渲染管线分配、提交后自动回收，适合粒子/动态网格等高频更新数据。
    // ========================================================================

/**
 * @brief[zh-cn] 设置 per-draw 瞬态索引缓冲。
 * @explain[zh-cn] 设置 per-draw 瞬态索引缓冲，用于动态更新索引数据。
 *
 * @brief[en] Set per-draw transient index buffer
 * @explain[en] Set per-draw transient index buffer, used for dynamic index data update.
 */
    public func setTransientIndexBuffer(tib: TransientIndexBufferPtr, firstIndex: UInt32, numIndices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_transient_index_buffer_cj(tib.value, firstIndex, numIndices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 瞬态顶点缓冲（无 layout）。
 * @explain[zh-cn] 设置 per-draw 瞬态顶点缓冲（无 layout），用于动态更新顶点数据。
 *
 * @brief[en] Set per-draw transient vertex buffer (no layout)
 * @explain[en] Set per-draw transient vertex buffer (no layout), used for dynamic vertex data update.
 */
    public func setTransientVertexBuffer(stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_set_transient_vertex_buffer_cj(stream, tvb.value, startVertex, numVertices) })
    }

/**
 * @brief[zh-cn] 设置 per-draw 瞬态顶点缓冲（带 layout）。
 * @explain[zh-cn] 设置 per-draw 瞬态顶点缓冲（带 layout），绑定瞬态顶点数据流及布局。
 *
 * @brief[en] Set per-draw transient vertex buffer (with layout)
 * @explain[en] Set per-draw transient vertex buffer with layout, bind transient vertex data stream and layout.
 */
    public func setTransientVertexBufferWithLayout(
        stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32,
        layoutHandle: VertexLayoutHandle
    ): Unit {
        _execBgfx({ => bgfx.bgfx_set_transient_vertex_buffer_with_layout_cj(stream, tvb.value, startVertex, numVertices, layoutHandle.value) })
    }

    // ========================================================================
    // ===== 渲染器查询 / 平台控制（信息查询与全局状态） =====
    // ========================================================================
    // 对照 Three.js: renderer.capabilities / renderer.info / renderer.setSize
    // —— 渲染后端能力与统计查询、重置与平台数据设置统一经 renderer 暴露。
    // ========================================================================

/**
 * @brief[zh-cn] 获取当前渲染后端类型。
 * @explain[zh-cn] 获取当前渲染后端类型，用于能力探测。
 * @return[zh-cn] RendererType.value()
 *
 * @brief[en] Get current renderer backend type
 * @explain[en] Get current renderer backend type, used for capability detection.
 * @return[en] RendererType.value()
 */
    public func getRendererType(): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        _execBgfx({ => resultBox.value = bgfx.bgfx_get_renderer_type_cj() })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 获取渲染后端名称（C 字符串）。
 * @explain[zh-cn] 获取渲染后端名称，用于标识当前渲染器。
 *
 * @brief[en] Get renderer backend name
 * @explain[en] Get renderer backend name, used to identify the current renderer.
 */
    public func getRendererName(`type`: UInt32): String {
        let resultBox: Box<CString> = Box(CString(CPointer<UInt8>()))
        _execBgfx({ => resultBox.value = bgfx.bgfx_get_renderer_name_cj(`type`) })
        return resultBox.value.toString()
    }

/**
 * @brief[zh-cn] 获取支持的后端列表。
 * @explain[zh-cn] 获取支持的后端列表，用于多后端探测。
 *
 * @brief[en] Get supported backend list
 * @explain[en] Get supported backend list, used for multi-backend detection.
 */
    public func getSupportedRenderers(max: UInt8, `enum`: PtrArray<UInt32>): UInt8 {
        let resultBox: Box<UInt8> = Box(0u8)
        _execBgfx({ => resultBox.value = bgfx.bgfx_get_supported_renderers_cj(max, `enum`.data()) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 获取渲染器能力（CPointer，读取字段由调用方负责）。
 * @explain[zh-cn] 获取渲染器能力信息（Caps 指针）。
 *
 * @brief[en] Get renderer capabilities (CPointer, caller responsible for reading fields)
 * @explain[en] Get renderer capabilities info (Caps pointer).
 */
    public func getCaps(): CapsPtr {
        let resultBox: Box<CapsPtr> = Box(Box(CPointer<bgfx.Caps>()))
        _execBgfx({ => resultBox.value = Box(bgfx.bgfx_get_caps_cj()) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 获取渲染器统计（CPointer，指针在下一帧 frame 前有效）。
 * @explain[zh-cn] 获取渲染器统计信息（Stats 指针）。
 *
 * @brief[en] Get renderer statistics (CPointer, valid until next frame)
 * @explain[en] Get renderer statistics info (Stats pointer).
 */
    public func getStats(): StatsPtr {
        let resultBox: Box<StatsPtr> = Box(Box(CPointer<bgfx.Stats>()))
        _execBgfx({ => resultBox.value = Box(bgfx.bgfx_get_stats_cj()) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 获取 bgfx 内部数据（caps/context 指针）。
 * @explain[zh-cn] 获取 bgfx 内部数据（caps/context 指针），用于底层平台集成。
 *
 * @brief[en] Get bgfx internal data (caps/context pointer)
 * @explain[en] Get bgfx internal data (caps/context pointer), used for low-level platform integration.
 */
    public func getInternalData(): InternalDataPtr {
        let resultBox: Box<InternalDataPtr> = Box(Box(CPointer<bgfx.InternalData>()))
        _execBgfx({ => resultBox.value = Box(bgfx.bgfx_get_internal_data_cj()) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 获取 bgfx 扩展接口（版本匹配时返回接口指针）。
 *
 * @brief[en] Get bgfx extension interface (returns interface pointer if version matches)
 */
    public func getInterface(version: UInt32): UnitPtr {
        let resultBox: Box<UnitPtr> = Box(Box(CPointer<Unit>()))
        _execBgfx({ => resultBox.value = Box(bgfx.bgfx_get_interface_cj(version)) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 重置后备缓冲（分辨率/标志/格式）。
 * @explain[zh-cn] 新版 bgfx 的 bgfx_reset 以 SwapChain 描述符传入尺寸/格式，
 * 尺寸写入 swapChain 副本后重置。
 *
 * @brief[en] Reset backbuffer (resolution/flags/format)
 * @explain[en] New bgfx bgfx_reset takes a SwapChain descriptor for size/format;
 * size is written into the swap chain copy before reset.
 */
    public func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit {
        _execBgfx({ =>
            let descHolder = AutoFreePtr<bgfx.SwapChain>(unsafe { LibC.malloc<bgfx.SwapChain>() })
            let desc = descHolder.get()
            unsafe { desc.write(bgfx.SwapChain()) }
            var sc = unsafe { desc.read() }
            sc.width = width
            sc.height = height
            sc.formatColor = format
            unsafe { desc.write(sc) }
            bgfx.bgfx_reset_cj(flags, desc)
            descHolder.dispose()
        })
    }

/**
 * @brief[zh-cn] 手动驱动渲染帧。
 * @explain[zh-cn] 手动驱动渲染帧，非自动帧循环驱动。
 * @param[zh-cn] msecs 等待毫秒数（-1 阻塞等待）
 * @return[zh-cn] RenderFrame.value()
 *
 * @brief[en] Manually drive render frame
 * @explain[en] Manually drive render frame, not driven by automatic frame loop.
 * @param[en] msecs wait timeout in milliseconds (-1 to block)
 * @return[en] RenderFrame.value()
 */
    public func renderFrame(msecs: Int32): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        _execBgfx({ => resultBox.value = bgfx.bgfx_render_frame_cj(msecs) })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 请求截屏保存到文件。
 *
 * @brief[en] Request screenshot saved to file
 */
    public func requestScreenShot(fb: FrameBufferHandle, filePath: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(filePath) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_request_screen_shot_cj(fb.value, cName)
            cNameHolder.dispose()
        })
    }

    // ========================================================================
    // ===== 调试文本（on-screen debug text） =====
    // ========================================================================
    // 对照 Three.js: 无直接对应（bgfx 内置调试文本覆盖层）。
    // ========================================================================

    /**
     * @brief[zh-cn] 清除调试文本
     *
     * @brief[en] Clear debug text
     */
    public func dbgTextClear(attr: UInt8, small: Bool): Unit {
        _execBgfx({ => bgfx.bgfx_dbg_text_clear_cj(attr, small) })
    }

    /**
     * @brief[zh-cn] 输出格式化调试文本（C 风格格式字符串）
     *
     * @brief[en] Output formatted debug text (C-style format string)
     */
    public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit {
        let cFormat = unsafe { LibC.mallocCString(format) }
        _execBgfx({ => bgfx.bgfx_dbg_text_printf_cj(x, y, attr, cFormat) })
        unsafe { LibC.free(cFormat) }
    }

    /**
     * @brief[zh-cn] 输出格式化调试文本（va_list 版）
     *
     * @brief[en] Output formatted debug text (va_list version)
     */
    public func dbgTextVprintf(x: UInt16, y: UInt16, attr: UInt8, format: String, argList: UnitPtr): Unit {
        let cFormat = unsafe { LibC.mallocCString(format) }
        _execBgfx({ => bgfx.bgfx_dbg_text_vprintf_cj(x, y, attr, cFormat, argList.value) })
        unsafe { LibC.free(cFormat) }
    }

    /**
     * @brief[zh-cn] 绘制调试文本图像（8bit 每像素）
     *
     * @brief[en] Draw debug text image (8bit per pixel)
     */
    public func dbgTextImage(x: UInt16, y: UInt16, width: UInt16, height: UInt16, data: UnitPtr, pitch: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_dbg_text_image_cj(x, y, width, height, data.value, pitch) })
    }

    // ========================================================================
    // ===== 纹理补充：通用创建 / 直接访问 / 内部覆盖 =====
    // ========================================================================
    // 对照 Three.js WebGLTextures —— 纹理的通用创建（按 TextureInfo）、
    // 直接访问指针与内部存储覆盖属高级纹理集成能力，统一经 renderer 暴露。
    // ========================================================================

/**
 * @brief[zh-cn] 按 TextureInfo 创建纹理（通用入口）。
 * @explain[zh-cn] 按 TextureInfo 创建纹理（通用入口），支持完整参数配置。
 * @param[zh-cn] mem 纹理数据内存（Some=有数据；None=空 RT）
 * flags 纹理 flags
 * skip 跳过的 mip 数
 * info 纹理信息指针（TextureInfo）
 * @return[zh-cn] 纹理句柄
 *
 * @brief[en] Create texture from TextureInfo (generic entry)
 * @explain[en] Create texture from TextureInfo (generic entry), supports full parameter configuration.
 * @param[en] mem texture data memory (Some=data; None=empty RT)
 * flags texture flags
 * skip number of mips to skip
 * info texture info pointer (TextureInfo)
 * @return[en] texture handle
 */
    public func createTexture(mem: Option<BgfxMemory>, flags: UInt64, skip: UInt8, info: TextureInfoPtr): TextureHandle {
        let resultBox: Box<TextureHandle> = Box(INVALID_TEXTURE_HANDLE)
        let memRef = mem
        _execBgfx({ =>
            let memPtr = match (memRef) {
                case Some(m) => m.get()
                case None => CPointer<bgfx.Memory>()
            }
            resultBox.value = Box(bgfx.bgfx_create_texture_cj(memPtr, flags, skip, info.value))
        })
        return resultBox.value
    }

/**
 * @brief[zh-cn] 获取纹理直接访问指针（零拷贝读纹理）。
 * @explain[zh-cn] 获取纹理直接访问指针，支持零拷贝读纹理。
 *
 * @brief[en] Get texture direct access pointer (zero-copy texture read)
 * @explain[en] Get texture direct access pointer, supports zero-copy texture read.
 */
    public func getDirectAccessPtr(tex: TextureHandle): UnitPtr {
        let resultBox: Box<UnitPtr> = Box(Box(CPointer<Unit>()))
        _execBgfx({ => resultBox.value = Box(bgfx.bgfx_get_direct_access_ptr_cj(tex.value)) })
        return resultBox.value
    }

    // ========================================================================
    // ===== Encoder（多线程编码器） =====
    // ========================================================================
    // 对照 Three.js: 无直接对应（WebGL 单线程）。bgfx 提供多线程提交能力：
    // 每个线程经 encoderBegin 获取独立 encoder，提交 draw 命令后 encoderEnd
    // 合并到渲染队列。经 renderer 暴露，统一走 _execBgfx 线程序列化。
    // ========================================================================

    /**
     * @brief[zh-cn] 获取编码器实例（多线程渲染用）
     *
     * @brief[en] Get encoder instance (for multi-threaded rendering)
     */
    public func encoderBegin(forThread: Bool): EncoderPtr {
        let resultBox: Box<EncoderPtr> = Box(Box(CPointer<bgfx.Encoder>()))
        _execBgfx({ => resultBox.value = Box(bgfx.bgfx_encoder_begin_cj(forThread)) })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 提交编码器中的命令
     *
     * @brief[en] End and submit encoder commands
     */
    public func encoderEnd(encoder: EncoderPtr): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_end_cj(encoder.value) })
    }

    /**
     * @brief[zh-cn] 编码器内设置调试标记
     *
     * @brief[en] Set debug marker in encoder
     */
    public func encoderSetMarker(encoder: EncoderPtr, name: String): Unit {
        _execBgfx({ =>
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx.bgfx_encoder_set_marker_cj(encoder.value, cName, Int32(name.size))
            cNameHolder.dispose()
        })
    }

    /**
     * @brief[zh-cn] 编码器内设置渲染状态
     *
     * @brief[en] Set render state in encoder
     */
    public func encoderSetState(encoder: EncoderPtr, state: UInt64, rgba: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_state_cj(encoder.value, state, rgba) })
    }

    /**
     * @brief[zh-cn] 编码器内设置遮挡查询条件
     *
     * @brief[en] Set occlusion query condition in encoder
     */
    public func encoderSetCondition(encoder: EncoderPtr, handle: OcclusionQueryHandle, visible: Bool): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_condition_cj(encoder.value, handle.value, visible) })
    }

    /**
     * @brief[zh-cn] 编码器内设置模板状态
     *
     * @brief[en] Set stencil state in encoder
     */
    public func encoderSetStencil(encoder: EncoderPtr, fstencil: UInt32, bstencil: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_stencil_cj(encoder.value, fstencil, bstencil) })
    }

    /**
     * @brief[zh-cn] 编码器内设置裁剪矩形（返回 cache 序号）
     *
     * @brief[en] Set scissor rectangle in encoder (returns cache index)
     */
    public func encoderSetScissor(encoder: EncoderPtr, x: UInt16, y: UInt16, width: UInt16, height: UInt16): UInt16 {
        let resultBox: Box<UInt16> = Box(0u16)
        _execBgfx({ => resultBox.value = bgfx.bgfx_encoder_set_scissor_cj(encoder.value, x, y, width, height) })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 编码器内复用缓存裁剪矩形
     *
     * @brief[en] Reuse cached scissor rectangle in encoder
     */
    public func encoderSetScissorCached(encoder: EncoderPtr, cache: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_scissor_cached_cj(encoder.value, cache) })
    }

    /**
     * @brief[zh-cn] 编码器内设置变换矩阵
     *
     * @brief[en] Set transform matrix in encoder
     */
    public func encoderSetTransform(encoder: EncoderPtr, mtx: BgfxMemory, num: UInt16): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        _execBgfx({ => resultBox.value = bgfx.bgfx_encoder_set_transform_cj(encoder.value, unsafe { CPointer<Unit>(mtx.data()) }, num) })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 编码器内复用缓存变换
     *
     * @brief[en] Reuse cached transform in encoder
     */
    public func encoderSetTransformCached(encoder: EncoderPtr, cache: UInt32, num: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_transform_cached_cj(encoder.value, cache, num) })
    }

    /**
     * @brief[zh-cn] 编码器内分配变换矩阵
     *
     * @brief[en] Allocate transform matrix in encoder
     */
    public func encoderAllocTransform(encoder: EncoderPtr, transform: TransformPtr, num: UInt16): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        _execBgfx({ => resultBox.value = bgfx.bgfx_encoder_alloc_transform_cj(encoder.value, transform.value, num) })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 编码器内设置 uniform
     *
     * @brief[en] Set uniform in encoder
     */
    public func encoderSetUniform(encoder: EncoderPtr, handle: UniformHandle, value: BgfxMemory, num: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_uniform_cj(encoder.value, handle.value, unsafe { CPointer<Unit>(value.data()) }, num) })
    }

    /**
     * @brief[zh-cn] 编码器内设置索引缓冲
     *
     * @brief[en] Set index buffer in encoder
     */
    public func encoderSetIndexBuffer(encoder: EncoderPtr, handle: IndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_index_buffer_cj(encoder.value, handle.value, firstIndex, numIndices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置动态索引缓冲
     *
     * @brief[en] Set dynamic index buffer in encoder
     */
    public func encoderSetDynamicIndexBuffer(encoder: EncoderPtr, handle: DynamicIndexBufferHandle, firstIndex: UInt32, numIndices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_dynamic_index_buffer_cj(encoder.value, handle.value, firstIndex, numIndices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置瞬态索引缓冲
     *
     * @brief[en] Set transient index buffer in encoder
     */
    public func encoderSetTransientIndexBuffer(encoder: EncoderPtr, tib: TransientIndexBufferPtr, firstIndex: UInt32, numIndices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_transient_index_buffer_cj(encoder.value, tib.value, firstIndex, numIndices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置顶点缓冲
     *
     * @brief[en] Set vertex buffer in encoder
     */
    public func encoderSetVertexBuffer(encoder: EncoderPtr, stream: UInt8, handle: VertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_vertex_buffer_cj(encoder.value, stream, handle.value, startVertex, numVertices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置顶点缓冲（带 layout）
     *
     * @brief[en] Set vertex buffer with layout in encoder
     */
    public func encoderSetVertexBufferWithLayout(
        encoder: EncoderPtr, stream: UInt8, handle: VertexBufferHandle,
        startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle
    ): Unit {
        _execBgfx({ =>
            bgfx.bgfx_encoder_set_vertex_buffer_with_layout_cj(encoder.value, stream, handle.value, startVertex, numVertices, layoutHandle.value)
        })
    }

    /**
     * @brief[zh-cn] 编码器内设置动态顶点缓冲
     *
     * @brief[en] Set dynamic vertex buffer in encoder
     */
    public func encoderSetDynamicVertexBuffer(encoder: EncoderPtr, stream: UInt8, handle: DynamicVertexBufferHandle, startVertex: UInt32, numVertices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_dynamic_vertex_buffer_cj(encoder.value, stream, handle.value, startVertex, numVertices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置动态顶点缓冲（带 layout）
     *
     * @brief[en] Set dynamic vertex buffer with layout in encoder
     */
    public func encoderSetDynamicVertexBufferWithLayout(
        encoder: EncoderPtr, stream: UInt8, handle: DynamicVertexBufferHandle,
        startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle
    ): Unit {
        _execBgfx({ =>
            bgfx.bgfx_encoder_set_dynamic_vertex_buffer_with_layout_cj(encoder.value, stream, handle.value, startVertex, numVertices, layoutHandle.value)
        })
    }

    /**
     * @brief[zh-cn] 编码器内设置瞬态顶点缓冲
     *
     * @brief[en] Set transient vertex buffer in encoder
     */
    public func encoderSetTransientVertexBuffer(encoder: EncoderPtr, stream: UInt8, tvb: TransientVertexBufferPtr, startVertex: UInt32, numVertices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_transient_vertex_buffer_cj(encoder.value, stream, tvb.value, startVertex, numVertices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置瞬态顶点缓冲（带 layout）
     *
     * @brief[en] Set transient vertex buffer with layout in encoder
     */
    public func encoderSetTransientVertexBufferWithLayout(
        encoder: EncoderPtr, stream: UInt8, tvb: TransientVertexBufferPtr,
        startVertex: UInt32, numVertices: UInt32, layoutHandle: VertexLayoutHandle
    ): Unit {
        _execBgfx({ =>
            bgfx.bgfx_encoder_set_transient_vertex_buffer_with_layout_cj(encoder.value, stream, tvb.value, startVertex, numVertices, layoutHandle.value)
        })
    }

    /**
     * @brief[zh-cn] 编码器内设置顶点计数
     *
     * @brief[en] Set vertex count in encoder
     */
    public func encoderSetVertexCount(encoder: EncoderPtr, numVertices: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_vertex_count_cj(encoder.value, numVertices) })
    }

    /**
     * @brief[zh-cn] 编码器内设置实例数据缓冲
     *
     * @brief[en] Set instance data buffer in encoder
     */
    public func encoderSetInstanceDataBuffer(encoder: EncoderPtr, idb: InstanceDataBufferPtr, start: UInt32, num: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_instance_data_buffer_cj(encoder.value, idb.value, start, num) })
    }

    /**
     * @brief[zh-cn] 编码器内从顶点缓冲设置实例数据
     *
     * @brief[en] Set instance data from vertex buffer in encoder
     */
    public func encoderSetInstanceDataFromVertexBuffer(encoder: EncoderPtr, handle: VertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_instance_data_from_vertex_buffer_cj(encoder.value, handle.value, startVertex, num) })
    }

    /**
     * @brief[zh-cn] 编码器内从动态顶点缓冲设置实例数据
     *
     * @brief[en] Set instance data from dynamic vertex buffer in encoder
     */
    public func encoderSetInstanceDataFromDynamicVertexBuffer(encoder: EncoderPtr, handle: DynamicVertexBufferHandle, startVertex: UInt32, num: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer_cj(encoder.value, handle.value, startVertex, num) })
    }

    /**
     * @brief[zh-cn] 编码器内设置实例计数
     *
     * @brief[en] Set instance count in encoder
     */
    public func encoderSetInstanceCount(encoder: EncoderPtr, numInstances: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_instance_count_cj(encoder.value, numInstances) })
    }

    /**
     * @brief[zh-cn] 编码器内绑定纹理
     *
     * @brief[en] Bind texture in encoder
     */
    public func encoderSetTexture(encoder: EncoderPtr, stage: UInt8, sampler: UniformHandle, handle: TextureHandle, flags: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_texture_cj(encoder.value, stage, sampler.value, handle.value, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内触发 view
     *
     * @brief[en] Touch view in encoder
     */
    public func encoderTouch(encoder: EncoderPtr, id: UInt16): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_touch_cj(encoder.value, id) })
    }

    /**
     * @brief[zh-cn] 编码器内提交 draw
     *
     * @brief[en] Submit draw in encoder
     */
    public func encoderSubmit(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, depth: UInt32, flags: UInt8): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_submit_cj(encoder.value, id, program.value, depth, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内提交遮挡查询 draw
     *
     * @brief[en] Submit draw with occlusion query in encoder
     */
    public func encoderSubmitOcclusionQuery(
        encoder: EncoderPtr, id: UInt16, program: ProgramHandle,
        occlusionQuery: OcclusionQueryHandle, depth: UInt32, flags: UInt8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_submit_occlusion_query_cj(encoder.value, id, program.value, occlusionQuery.value, depth, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内提交间接绘制
     *
     * @brief[en] Submit indirect draw in encoder
     */
    public func encoderSubmitIndirect(
        encoder: EncoderPtr, id: UInt16, program: ProgramHandle,
        indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, depth: UInt32, flags: UInt8
    ): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_submit_indirect_cj(encoder.value, id, program.value, indirectHandle.value, start, num, depth, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内提交带计数间接绘制
     *
     * @brief[en] Submit indirect draw with count buffer in encoder
     */
    public func encoderSubmitIndirectCount(
        encoder: EncoderPtr, id: UInt16, program: ProgramHandle,
        indirectHandle: IndirectBufferHandle, start: UInt32, numHandle: IndexBufferHandle,
        numIndex: UInt32, numMax: UInt32, depth: UInt32, flags: UInt8
    ): Unit {
        _execBgfx({ =>
            bgfx.bgfx_encoder_submit_indirect_count_cj(encoder.value, id, program.value, indirectHandle.value, start, numHandle.value, numIndex, numMax, depth, flags)
        })
    }

    /**
     * @brief[zh-cn] 编码器内绑定计算索引缓冲
     *
     * @brief[en] Bind compute index buffer in encoder
     */
    public func encoderSetComputeIndexBuffer(encoder: EncoderPtr, stage: UInt8, handle: IndexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_compute_index_buffer_cj(encoder.value, stage, handle.value, access) })
    }

    /**
     * @brief[zh-cn] 编码器内绑定计算顶点缓冲
     *
     * @brief[en] Bind compute vertex buffer in encoder
     */
    public func encoderSetComputeVertexBuffer(encoder: EncoderPtr, stage: UInt8, handle: VertexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_compute_vertex_buffer_cj(encoder.value, stage, handle.value, access) })
    }

    /**
     * @brief[zh-cn] 编码器内绑定计算动态索引缓冲
     *
     * @brief[en] Bind compute dynamic index buffer in encoder
     */
    public func encoderSetComputeDynamicIndexBuffer(encoder: EncoderPtr, stage: UInt8, handle: DynamicIndexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_compute_dynamic_index_buffer_cj(encoder.value, stage, handle.value, access) })
    }

    /**
     * @brief[zh-cn] 编码器内绑定计算动态顶点缓冲
     *
     * @brief[en] Bind compute dynamic vertex buffer in encoder
     */
    public func encoderSetComputeDynamicVertexBuffer(encoder: EncoderPtr, stage: UInt8, handle: DynamicVertexBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_compute_dynamic_vertex_buffer_cj(encoder.value, stage, handle.value, access) })
    }

    /**
     * @brief[zh-cn] 编码器内绑定计算间接缓冲
     *
     * @brief[en] Bind compute indirect buffer in encoder
     */
    public func encoderSetComputeIndirectBuffer(encoder: EncoderPtr, stage: UInt8, handle: IndirectBufferHandle, access: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_compute_indirect_buffer_cj(encoder.value, stage, handle.value, access) })
    }

    /**
     * @brief[zh-cn] 编码器内绑定图像
     *
     * @brief[en] Bind image in encoder
     */
    public func encoderSetImage(encoder: EncoderPtr, stage: UInt8, handle: TextureHandle, mip: UInt8, access: UInt32, format: UInt32): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_set_image_cj(encoder.value, stage, handle.value, mip, access, format) })
    }

    /**
     * @brief[zh-cn] 编码器内提交计算调度
     *
     * @brief[en] Submit compute dispatch in encoder
     */
    public func encoderDispatch(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags: UInt8): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_dispatch_cj(encoder.value, id, program.value, numX, numY, numZ, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内提交间接计算调度
     *
     * @brief[en] Submit indirect compute dispatch in encoder
     */
    public func encoderDispatchIndirect(encoder: EncoderPtr, id: UInt16, program: ProgramHandle, indirectHandle: IndirectBufferHandle, start: UInt32, num: UInt32, flags: UInt8): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_dispatch_indirect_cj(encoder.value, id, program.value, indirectHandle.value, start, num, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内丢弃状态组
     *
     * @brief[en] Discard state groups in encoder
     */
    public func encoderDiscard(encoder: EncoderPtr, flags: UInt8): Unit {
        _execBgfx({ => bgfx.bgfx_encoder_discard_cj(encoder.value, flags) })
    }

    /**
     * @brief[zh-cn] 编码器内纹理区域拷贝
     *
     * @brief[en] Blit texture region in encoder
     */
    public func encoderBlit(
        encoder: EncoderPtr, id: UInt16,
        dst: TextureHandle, dstMip: UInt8, dstX: UInt16, dstY: UInt16, dstZ: UInt16,
        src: TextureHandle, srcMip: UInt8, srcX: UInt16, srcY: UInt16, srcZ: UInt16,
        width: UInt16, height: UInt16, depth: UInt16
    ): Unit {
        _execBgfx({ =>
            bgfx.bgfx_encoder_blit_cj(encoder.value, id, dst.value, dstMip, dstX, dstY, dstZ, src.value, srcMip, srcX, srcY, srcZ, width, height, depth)
        })
    }
}
