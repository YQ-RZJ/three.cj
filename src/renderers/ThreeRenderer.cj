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
 * @file[zh-cn] ThreeRenderer 渲染器
 * @brief[zh-cn] 渲染器 — 继承 Renderer 调度管线的引擎渲染器门面
 * @explain[zh-cn] 本文件不直接调用任何后端绑定 API：GPU 能力经引擎抽象层
 * （IRenderBackend，由后端实现包提供）下发，命令线程路由由后端命令执行器
 * （gfxBackendExec）承担。对外公开面为受控高级 API（render/renderAsync/
 * syncFrame/initBgfx/setSize/setClearColor/present/setRenderTarget/
 * getRenderTarget/setShadowType/release/getRendererType/getCapabilities 与
 * runOnRenderThread 逃生舱）；GPU 资源句柄不在公开面上——引擎内的 pass 系
 * 经 Pass 基类内建后端访问与 EngineRenderTarget 资源对象操作资源，外部
 * 使用者经 EngineRenderTarget 等资源对象间接持有句柄。
 * 线程模型：所有 GPU 命令经 gfxBackendExec 序列化到唯一命令线程（同线程
 * 调用走快路径直接执行）；renderAsync 为单向投递、syncFrame 等待全部完成。
 *
 * @file[en] ThreeRenderer
 * @brief[en] The renderer — the engine renderer facade inheriting the Renderer scheduling pipeline
 * @explain[en] This file makes no direct backend-binding API calls: GPU capabilities go
 * through the engine abstraction layer (IRenderBackend, provided by the backend
 * implementation package), and command-thread routing is handled by the backend
 * command executor (gfxBackendExec). The public surface is the controlled
 * high-level API (render/renderAsync/syncFrame/initBgfx/setSize/setClearColor/
 * present/setRenderTarget/getRenderTarget/setShadowType/release/getRendererType/
 * getCapabilities plus the runOnRenderThread escape hatch); GPU resource handles
 * stay off the public face — engine-internal passes operate resources through the
 * Pass base class's built-in backend access and the EngineRenderTarget resource
 * object, external users hold handles indirectly via resource objects like
 * EngineRenderTarget.
 * Threading: all GPU commands serialize onto the single command thread via
 * gfxBackendExec (same-thread calls take the fast path and run directly);
 * renderAsync is fire-and-forget, syncFrame waits for everything.
 *
 * @package three.renderers
 */
package three.renderers

import three.renderers.buffer.*
import three.utils.memory.PtrArray
import three.renderers.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.renderers.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.renderers.materials.*
import three.renderers.cameras.*
import three.renderers.textures.*
import three.renderers._interfaces.{IRenderTarget, IShaderProgram}
public import three.renderers._interfaces.IRenderer
public import three.renderers._interfaces.IUniformRegistry
import three.renderers.common.*
import three.renderers.shaders.*
import three.renderers._bgfx.*
import three.renderers._gfx.*
import three.utils.safe.IReleasable
import three.utils.log.*
import three.utils.log.macros.*
import three.profiler.*
import three.profiler.macros.*
import std.collection.*

// ===== 跨平台渲染器选择 =====

/**
 * @brief[zh-cn] 默认渲染器类型（根据平台自动选择 Direct3D11/Vulkan/OpenGLES/Metal）
 *
 * @brief[en] Default renderer type (auto-selected per platform: Direct3D11/Vulkan/OpenGLES/Metal)
 */
@When[os == "Windows"]
public let DEFAULT_RENDERER_TYPE: UInt32 = GfxRendererType.Direct3D11.value()

/**
 * @brief[zh-cn] 默认渲染器类型（Linux GNU：Vulkan）
 *
 * @brief[en] Default renderer type (Linux GNU: Vulkan)
 */
@When[os == "Linux" && env == "gnu"]
public let DEFAULT_RENDERER_TYPE: UInt32 = GfxRendererType.Vulkan.value()

/**
 * @brief[zh-cn] 默认渲染器类型（Android：OpenGLES）
 *
 * @brief[en] Default renderer type (Android: OpenGLES)
 */
@When[os == "Linux" && env == "android"]
public let DEFAULT_RENDERER_TYPE: UInt32 = GfxRendererType.OpenGLES.value()

/**
 * @brief[zh-cn] 默认渲染器类型（OpenHarmony：OpenGLES）
 *
 * @brief[en] Default renderer type (OpenHarmony: OpenGLES)
 */
@When[os == "Linux" && env == "ohos"]
public let DEFAULT_RENDERER_TYPE: UInt32 = GfxRendererType.OpenGLES.value()

/**
 * @brief[zh-cn] 默认渲染器类型（macOS/iOS：Metal）
 *
 * @brief[en] Default renderer type (macOS/iOS: Metal)
 */
@When[os == "macOS" || os == "iOS"]
public let DEFAULT_RENDERER_TYPE: UInt32 = GfxRendererType.Metal.value()

/**
 * @brief[zh-cn] 默认渲染器类型（未知平台回退值）
 *
 * @brief[en] Default renderer type (unknown platform fallback value)
 */
@When[os != "Windows" && os != "Linux" && os != "macOS" && os != "iOS"]
public let DEFAULT_RENDERER_TYPE: UInt32 = 0u32

/**
 * @brief[zh-cn] 清除颜色标志位
 *
 * @brief[en] Clear color flag bit
 */
public let CLEAR_COLOR: UInt16 = GfxClearFlag.COLOR

/**
 * @brief[zh-cn] 清除深度标志位
 *
 * @brief[en] Clear depth flag bit
 */
public let CLEAR_DEPTH: UInt16 = GfxClearFlag.DEPTH

/**
 * @brief[zh-cn] 顶点属性语义：位置
 *
 * @brief[en] Vertex attribute semantic: position
 */
public let BGFX_ATTRIB_POSITION: UInt32 = GfxAttrib.Position.value()

/**
 * @brief[zh-cn] uniform 类型：Vec4
 *
 * @brief[en] Uniform type: Vec4
 */
public let BGFX_UNIFORM_VEC4: UInt32 = GfxUniformType.Vec4.value()

/**
 * @brief[zh-cn] uniform 类型：Mat4
 *
 * @brief[en] Uniform type: Mat4
 */
public let BGFX_UNIFORM_MAT4: UInt32 = GfxUniformType.Mat4.value()

/**
 * @brief[zh-cn] 渲染器 — Renderer 薄实现
 * @explain[zh-cn] 继承 Renderer 的 _render 调度管线（beginRender → draw →
 * finishRender 编排经 IRenderPipeline 驱动后端实现）；GPU 能力全部经
 * IRenderBackend 抽象接口下发，命令线程路由由后端命令执行器承担。
 *
 * @brief[en] The renderer — a thin Renderer implementation
 * @explain[en] Inherits Renderer's _render scheduling pipeline (the beginRender →
 * draw → finishRender orchestration drives the backend through IRenderPipeline);
 * GPU capabilities all go through the IRenderBackend abstraction interface, and
 * command-thread routing belongs to the backend command executor.
 */
public class ThreeRenderer <: Renderer & IRenderer & IReleasable {
    /**
     * @brief[zh-cn] 当前渲染 view id
     * @explain[zh-cn] 模块内读写（pass 系临时切换 view / 脚本绑定层读写），
     * 不在公开面上。
     *
     * @brief[en] Current render view id
     * @explain[en] Read-write within the module (passes temporarily switch views /
     * the script binding layer reads and writes); not on the public face.
     */
    protected var viewId: UInt16 = 0u16
    /**
     * @brief[zh-cn] 清除色（RGBA32）
     * @explain[zh-cn] 模块内读写；对外经 setClearColor 设置。
     *
     * @brief[en] Clear color (RGBA32)
     * @explain[en] Read-write within the module; set externally via setClearColor.
     */
    protected var clearColor: UInt32 = 0x00000000u32

    /**
     * @brief[zh-cn] 创建着色器程序（抽象层工厂）
     * @explain[zh-cn] 供 postprocessing 等上层包在不 import bgfx 的前提下创建着色器程序对象；
     * 签名对齐 ShaderProgram 的构造调用（name / vertexShader / fragmentShader / varyingDef），
     * 返回抽象接口 IShaderProgram。
     *
     * @param[zh-cn] name 着色器程序名称
     * @param[zh-cn] vertexShader 顶点着色器源码
     * @param[zh-cn] fragmentShader 片段着色器源码
     * @param[zh-cn] varyingDef varying 定义（.sc 格式），默认为空
     *
     * @brief[en] Creates a shader program (abstraction-layer factory)
     * @explain[en] Lets upper packages such as postprocessing create shader program objects without
     * importing bgfx; the signature matches the ShaderProgram constructor call
     * (name / vertexShader / fragmentShader / varyingDef) and returns the IShaderProgram interface.
     *
     * @param[en] name Shader program name
     * @param[en] vertexShader Vertex shader source
     * @param[en] fragmentShader Fragment shader source
     * @param[en] varyingDef Varying definition (.sc format), default empty
     */
    public static func makeShaderProgram(name: String, vertexShader: String, fragmentShader: String,
        varyingDef!: String = ""): IShaderProgram {
        return ShaderProgram(name, vertexShader, fragmentShader, varyingDef: varyingDef)
    }

    /**
     * @brief[zh-cn] 创建 uniform 注册表（抽象层工厂）
     * @explain[zh-cn] 供 postprocessing 等上层包在不 import bgfx 的前提下创建 uniform 注册表；
     * 返回抽象接口 IUniformRegistry，Pass 基类经此获取实例并长期复用。
     *
     * @brief[en] Creates a uniform registry (abstraction-layer factory)
     * @explain[en] Lets upper packages such as postprocessing create a uniform registry without importing
     * bgfx; returns the IUniformRegistry interface, and the Pass base class obtains and reuses the instance.
     */
    public static func makeUniformRegistry(): IUniformRegistry {
        return BgfxUniforms()
    }

    /**
     * @brief[zh-cn] 设置清除色
     * @param[zh-cn] color 清除颜色
     * alpha 透明度，默认 1.0
     *
     * @brief[en] Set clear color
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
        // 同步到后端实现持有的清除色（供 beginRender 读取）
        if (let Some(bb) <- (this.backend as BgfxBackend)) {
            bb.clearColor = newColor
        }
        this
            .backend
            .setViewClear(this.viewId, GfxClearFlag.COLOR | GfxClearFlag.DEPTH, this.clearColor, depth: 1.0f32,
                stencil: 0u8)
    }

    // ===== 后端初始化配置 =====
    // initBgfx 时由实参写入，setSize 触发后端 reset 时复用同一份 flags，
    // 避免 reset 后 V-Sync / MSAA 等状态与初始化时不一致。
    // 默认与 initBgfx 的默认参数一致：不开 V-Sync、不开 MSAA。
    private var _resetFlags: UInt32 = GfxResetFlag.NONE

    // ===== 尺寸 =====
    private var _width: Int32 = 0
    private var _height: Int32 = 0

    private var _initBgfxResult: Bool = false

    public init() {
        super(BgfxBackend())
    }

    // ===== 初始化与生命周期 =====

    /**
     * @brief[zh-cn] 初始化渲染后端
     * @param[zh-cn] hwnd 原生窗口句柄
     * width 窗口逻辑宽度
     * height 窗口逻辑高度
     * vsync 是否开启垂直同步（默认 false，即不锁定刷新率）。开启后帧率被显示器刷新率
     *   锁死（60Hz 显示器即 60FPS 上限）；关闭则按 CPU/GPU 实际耗时出帧，
     *   简单场景可达数百 FPS，但可能出现画面撕裂、帧间隔不均。
     * msaa 多重采样档位，取 GfxResetFlag.MSAA_* 常量组合（0 表示关闭）。
     * maxAnisotropy 最大各向异性过滤（0 = 不启用）。
     * numBackBuffers 后备缓冲数量（1~MAX_BACK_BUFFERS，越大越能掩盖 GPU 抖动，延迟也越高）。
     * maxFrameLatency 允许的最大帧排队数。
     * @return[zh-cn] 初始化是否成功
     * @explain[zh-cn] width/height 为逻辑尺寸，内部会按 pixelRatio 换算为物理后备缓冲尺寸后
     *   传给后端。
     *
     * @brief[en] Initialize the render backend
     * @param[en] hwnd Native window handle
     * width Window logical width
     * height Window logical height
     * vsync Enable vertical sync (default false, i.e. refresh rate not capped). When on, the frame
     *   rate is capped by the display refresh rate (60Hz display → 60FPS ceiling); when off, frames
     *   are produced as fast as CPU/GPU allow (hundreds of FPS on simple scenes) but
     *   tearing/uneven pacing may occur.
     * msaa Multisample level, combine GfxResetFlag.MSAA_* constants (0 = disabled).
     * maxAnisotropy Maximum anisotropy filtering (0 = disabled).
     * numBackBuffers Number of back buffers (1..MAX_BACK_BUFFERS; more hides GPU jitter, adds latency).
     * maxFrameLatency Maximum queued frames allowed.
     * @return[en] Whether initialization succeeded
     * @explain[en] width/height are logical dimensions; internally converted to physical backbuffer
     * dimensions using pixelRatio before passing to the backend.
     */
    public func initBgfx(
        hwnd: UIntNative,
        width: Int32,
        height: Int32,
        vsync!: Bool = false,
        msaa!: UInt32 = GfxResetFlag.NONE,
        maxAnisotropy!: UInt32 = GfxResetFlag.NONE,
        numBackBuffers!: UInt8 = 2u8,
        maxFrameLatency!: UInt8 = 2u8
    ): Bool {
        this._initBgfxResult = false
        gfxBackendExec.execSync(
            {
                =>
                    ShaderLibs.initialize()
                    // width/height 为逻辑尺寸；后端初始化需使用物理后备缓冲尺寸（乘以 pixelRatio）
                    super.setSize(Int64(width), Int64(height))
                    let physicalW = Int32(this.width)
                    let physicalH = Int32(this.height)
                    this._width = physicalW
                    this._height = physicalH
                    // reset 标志位按位组合：MSAA | (VSYNC 可选) | MAXANISOTROPY(可选)，
                    // 缓存供 setSize 的后端 reset 复用，保证 reset 前后呈现设置一致。
                    var resetFlags = msaa
                    if (vsync) {
                        resetFlags |= GfxResetFlag.VSYNC
                    }
                    if (maxAnisotropy != GfxResetFlag.NONE) {
                        resetFlags |= GfxResetFlag.MAXANISOTROPY
                    }
                    this._resetFlags = resetFlags
                    this._initBgfxResult = this
                        .backend
                        .initialize(hwnd, physicalW, physicalH, vsync: vsync, msaa: msaa, maxAnisotropy: maxAnisotropy,
                            numBackBuffers: numBackBuffers, maxFrameLatency: maxFrameLatency)
                    if (this._initBgfxResult) {
                        this
                            .backend
                            .setViewClear(this.viewId, GfxClearFlag.COLOR | GfxClearFlag.DEPTH, this.clearColor,
                                depth: 1.0f32, stencil: 0u8)
                        ShaderLibs.get("depth")?.compileBgfx()
                    }
            }
        )
        return this._initBgfxResult
    }

    // ===== 渲染入口 =====

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
     * @brief[zh-cn] 渲染场景（经命令执行器委托到命令线程）
     * @param[zh-cn] scene 待渲染场景
     * camera 渲染相机
     *
     * @brief[en] Render scene (delegated to the command thread via the command executor)
     * @param[en] scene Scene to render
     * camera Render camera
     */
    @Zone[three.renderers.ThreeRenderer.render]
    public func render(scene: Scene, camera: Camera): Unit {
        gfxBackendExec.execSync({=> super.render(scene, camera)})
    }

    /**
     * @brief[zh-cn] 离屏渲染场景到指定 view（不触发 bgfx_frame 上屏）
     * @explain[zh-cn] 供 EffectComposer 内的 RenderPass / RenderTransitionPass / SSRPass 等
     * 后处理 pass 使用：在单帧内将场景渲染到已绑定 RT 的目标 view，统一由 EffectComposer
     * 链尾调用一次 present 上屏，避免同帧多次 bgfx_frame 导致的画面闪烁与扫描黑块。
     */
    public func renderToView(
        scene: Scene,
        camera: Camera,
        viewId!: Option<UInt16> = None,
        viewport!: Option<(Int32, Int32, Int32, Int32)> = None,
        clearColor!: Option<UInt32> = None
    ): Unit {
        gfxBackendExec.execSync({
            => super.renderPass(scene, camera, present: false, viewId: viewId, viewport: viewport, clearColor: clearColor)
        })
    }

    /**
     * @brief[zh-cn] 填充渲染上下文中的默认清屏色
     */
    public override func _fillRenderContext(renderContext: RenderContext): Unit {
        renderContext.clearColor = this.clearColor
    }

    /**
     * 异步渲染一帧：把整帧渲染投递到命令线程后立即返回（管线化）
     *
     * 与 render 的区别：render 同步等待命令线程执行完（含上屏驱动提交）才返回；
     * renderAsync 提交后立即返回，主线程的下一帧准备工作（输入/逻辑/HUD）与
     * 命令线程的驱动提交重叠，吞吐上限由"两侧较慢者"决定。
     *
     * 正确性约束（必须遵守，否则产生场景读写竞争）：
     * - 每帧在**修改场景/材质/几何体之前**先调用 syncFrame()，等待上一帧渲染执行完毕；
     *   典型 WindowEngine 帧循环即"onFrame 开头 syncFrame → 改场景 → renderAsync"。
     * - renderAsync 返回后到下一帧 syncFrame 之间，不要触碰场景图（只做 HUD/输入等输出型操作）。
     * - renderer.info 在 renderAsync 返回时反映的是上一帧统计（渲染后延迟一帧的语义）。
     *
     * @brief[en] Render one frame asynchronously: post the whole frame to the command thread and return immediately
     * @explain[en] Unlike the synchronous render (which blocks until the command thread
     * finishes, including the driver submission), renderAsync returns right after posting,
     * so the next frame's main-thread work overlaps the command thread. Callers MUST
     * call syncFrame() before mutating the scene in the next frame.
     */
    public func renderAsync(scene: Scene, camera: Camera): Unit {
        gfxBackendExec.execAsync({=> super.render(scene, camera)})
    }

    /**
     * 等待所有已投递命令（含未完成的异步帧）执行完毕
     *
     * 与 renderAsync 配对使用：每帧开始修改场景前调用。无未完成命令时仅一次原子读，无开销。
     *
     * @brief[en] Wait until all posted commands (including a pending async frame) have executed
     * @explain[en] Paired with renderAsync: call at the start of a frame before mutating the scene.
     * Costs one atomic read when nothing is pending.
     */
    public func syncFrame(): Unit {
        gfxBackendExec.waitIdle()
    }

    /**
     * @brief[zh-cn] 同步后端渲染统计到抽象层 info（帧末钩子）
     * @explain[zh-cn] 后端直接提交路径不经过 BufferRenderer，绘制统计累加在后端
     * 实现的 info 上；此处在命令线程内把本帧 calls/triangles 同步到 renderer.info
     * 并清零后端计数，供主线程消费方读取。
     *
     * @brief[en] Sync backend render stats into abstract-layer info (frame-end hook)
     * @explain[en] The backend direct submit path bypasses BufferRenderer, so draw stats
     * accumulate on the backend's own info; this syncs the frame's calls/triangles into
     * renderer.info on the command thread and resets backend counters for main-thread
     * consumers.
     */
    public override func _syncRenderStats(): Unit {
        if (let Some(bb) <- (this.backend as BgfxBackend)) {
            this.info.render.calls = bb.info.render.calls
            this.info.render.triangles = bb.info.render.triangles
            this.info.calls = bb.info.render.calls
            this.info.triangles = bb.info.render.triangles
            bb.info.reset()
        }
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
     * @brief[zh-cn] 关闭渲染器，释放资源
     *
     * @brief[en] Shutdown the renderer and release resources
     */
    public func release(): Bool {
        ShaderLibs.release()
        // 后端关机：同步执行设备关闭，随后停止命令线程（线程退出路径会放弃
        // 残留命令并推进完成序号，保证等待者不悬挂）。
        this.backend.shutdown()
        return true
    }

    /**
     * @brief[zh-cn] 设置渲染器尺寸
     * @param[zh-cn] width 逻辑宽度（像素）
     * height 逻辑高度（像素）
     * @explain[zh-cn] 内部会按 pixelRatio 换算为物理后备缓冲尺寸，并触发后端 reset。
     *
     * @brief[en] Set renderer size
     * @param[en] width Logical width in pixels
     * height Logical height in pixels
     * @explain[en] Internally converted to physical backbuffer dimensions using pixelRatio, and triggers a backend reset.
     */
    public func setSize(width: Int32, height: Int32): Unit {
        // width/height 为逻辑尺寸；内部按 pixelRatio 换算为物理后备缓冲尺寸
        super.setSize(Int64(width), Int64(height))
        let physicalW = Int32(this.width)
        let physicalH = Int32(this.height)
        let changed = (physicalW != this._width || physicalH != this._height)
        this._width = physicalW
        this._height = physicalH
        // 表面尺寸变化（旋转/窗口缩放）后必须重建后备缓冲，否则后备缓冲尺寸与
        // surface 不匹配 → 横屏后画面闪烁/内容错乱。flags 复用 initBgfx 写入的
        // _resetFlags（V-Sync / MSAA 等），保证 reset 前后呈现设置一致；
        // format 传格式计数哨兵，后端沿用初始化时的后台缓冲格式。
        if (changed) {
            this.backend.reset(UInt32(physicalW), UInt32(physicalH), this._resetFlags, GFX_FORMAT_COUNT_SENTINEL)
        }
    }

    /**
     * @brief[zh-cn] 设置阴影类型（转调后端实现）
     * @param[zh-cn] value 阴影类型值
     *
     * @brief[en] Set shadow type (delegates to the backend implementation)
     * @param[en] value Shadow type value
     */
    public func setShadowType(value: Int64): Unit {
        gfxBackendExec.execSync({
            => if (let Some(bb) <- (this.backend as BgfxBackend)) {
                bb.setShadowType(value)
            }
        })
    }

    /**
     * @brief[zh-cn] 设置后端调试标志（如线框模式），经命令线程路由保证顺序
     * @explain[zh-cn] 调试标志为后端全局状态（设置后持续影响所有后续提交），
     * 签名不含后端类型；用完复位 0（DEBUG_NONE）避免影响后续渲染。
     * @param[zh-cn] debug 调试标志位组合
     *
     * @brief[en] Set backend debug flags (e.g. wireframe), routed through the command thread
     * @explain[en] Debug flags are backend-global state (persistently affecting all
     * subsequent submissions); the signature carries no backend types. Reset to 0
     * (DEBUG_NONE) when done to avoid affecting later renderers.
     * @param[en] debug Debug flag bit combination
     */
    public func setDebug(debug: UInt32): Unit {
        gfxBackendExec.execSync({
            => this.backend.setDebug(debug)
        })
    }

    /**
     * @brief[zh-cn] 清空调试文本覆盖层
     * @explain[zh-cn] 画面内调试文本（dbgTextPrintf）的每帧入口，转发到渲染后端，
     * 经命令线程异步投递（纯输出型，免跨线程往返）。使用前提：initBgfx 前后
     * 经 setDebug(DEBUG_TEXT) 开启调试文本覆盖层。
     * @param[zh-cn] attr 文本属性（前景/背景色，同 bgfx 约定）
     * @param[zh-cn] small true 使用小号字体
     *
     * @brief[en] Clears the debug text overlay
     * @explain[en] Per-frame entry for on-screen debug text (dbgTextPrintf); forwards to the render
     * backend and posts asynchronously on the command thread (pure output, no cross-thread round-trip).
     * Prerequisite: enable the overlay via setDebug(DEBUG_TEXT).
     * @param[en] attr Text attribute (fg/bg colors, same as bgfx convention)
     * @param[en] small true to use the small font
     */
    public func dbgTextClear(attr: UInt8, small!: Bool = false): Unit {
        gfxBackendExec.execAsync({
            => this.backend.dbgTextClear(attr, small)
        })
    }

    /**
     * @brief[zh-cn] 在调试文本覆盖层打印一行文本
     * @explain[zh-cn] 屏幕空间网格坐标（单位：字符格），非像素；(0,0) 为左上角。
     * 转发到渲染后端，经命令线程异步投递。
     * @param[zh-cn] x 列（字符格）
     * @param[zh-cn] y 行（字符格）
     * @param[zh-cn] attr 文本属性（前景/背景色，同 bgfx 约定，如 0x0f 白底黑字风格）
     * @param[zh-cn] format 文本内容（无 C 格式化语义，按字面输出）
     *
     * @brief[en] Prints a line of text on the debug text overlay
     * @explain[en] Screen-space grid coordinates (in character cells), not pixels; (0,0) is top-left.
     * Forwards to the render backend and posts asynchronously on the command thread.
     * @param[en] x Column (character cell)
     * @param[en] y Row (character cell)
     * @param[en] attr Text attribute (fg/bg colors, same as bgfx convention, e.g. 0x0f)
     * @param[en] format Text content (no C formatting semantics, printed literally)
     */
    public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit {
        gfxBackendExec.execAsync(
            {
                => this.backend.dbgTextPrintf(x, y, attr, format)
            }
        )
    }

    /**
     * @brief[zh-cn] 在调试文本覆盖层绘制图像（8bit 每像素）
     * @param[zh-cn] x 列（字符格） @param[zh-cn] y 行（字符格）
     * @param[zh-cn] w 宽（字符格） @param[zh-cn] h 高（字符格）
     * @param[zh-cn] data 图像数据（每像素 1 字节索引）
     * @param[zh-cn] pitch 每行字节数
     *
     * @brief[en] Draws an image on the debug text overlay (8bit per pixel)
     * @param[en] x Column @param[en] y Row
     * @param[en] w Width (cells) @param[en] h Height (cells)
     * @param[en] data Image data (1 byte index per pixel)
     * @param[en] pitch Bytes per row
     */
    public func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16,
        data: PtrArray<UInt8>, pitch: UInt16): Unit {
        gfxBackendExec.execAsync(
            {
                => this.backend.dbgTextImage(x, y, w, h, data, pitch)
            }
        )
    }

    /**
     * @brief[zh-cn] 开启/关闭线框调试模式（语义化封装，不暴露后端调试标志数值）
     * @explain[zh-cn] 等价于 setDebug(线框标志) / setDebug(无标志)，供外部模块在不接触
     * 后端常量数值的前提下切换线框渲染。
     * @param[zh-cn] enabled true 开启线框，false 关闭
     *
     * @brief[en] Enables/disables wireframe debug mode (semantic wrapper, exposing no backend flag values)
     * @explain[en] Equivalent to setDebug(wireframe flag) / setDebug(no flag), letting external
     * modules toggle wireframe renderers without touching backend constant values.
     * @param[en] enabled true to enable wireframe, false to disable
     */
    public func setWireframe(enabled: Bool): Unit {
        this.setDebug(if (enabled) { BgfxConstants.DEBUG_WIREFRAME } else { BgfxConstants.DEBUG_NONE })
    }

    /**
     * @brief[zh-cn] 开启/关闭调试文本覆盖层（语义化封装，不暴露后端调试标志数值）
     * @explain[zh-cn] 等价于 setDebug(调试文本标志) / setDebug(无标志)，是
     * dbgTextPrintf / dbgTextClear 画面内文本渲染的前提，供外部模块在不接触
     * 后端常量数值的前提下开关画面内调试文本。
     * @param[zh-cn] enabled true 开启调试文本覆盖层，false 关闭
     *
     * @brief[en] Enables/disables the debug text overlay (semantic wrapper, exposing no backend flag values)
     * @explain[en] Equivalent to setDebug(debug text flag) / setDebug(no flag); prerequisite for
     * on-screen text via dbgTextPrintf / dbgTextClear, letting external modules toggle it without
     * touching backend constant values.
     * @param[en] enabled true to enable the debug text overlay, false to disable
     */
    public func setDebugText(enabled: Bool): Unit {
        this.setDebug(if (enabled) { BgfxConstants.DEBUG_TEXT } else { BgfxConstants.DEBUG_NONE })
    }

    // ========================================================================
    // ===== 公开线程序列化入口（逃生舱） =====
    // ========================================================================

    /**
     * @brief[zh-cn] 公开线程序列化入口：把任意闭包路由到命令线程执行
     * @explain[zh-cn] 外部模块（如 EffectComposer/Pass/宿主集成）需要与渲染命令
     * 保持顺序的任意代码经此方法排队到命令线程。
     * @param[zh-cn] cmd 待执行的闭包
     *
     * @brief[en] Public thread serialization entry: routes an arbitrary closure onto the command thread
     * @explain[en] External modules (e.g. EffectComposer/Pass/host integration) route any
     * code that must stay ordered with render commands through this method.
     * @param[en] cmd The closure to execute
     */
    public func runOnRenderThread(cmd: () -> Unit): Unit {
        gfxBackendExec.execSync(cmd)
    }

    // ========================================================================
    // ===== 上屏与查询（转发抽象层接口） =====
    // ========================================================================

    /**
     * @brief[zh-cn] 触发一次双缓冲交换上屏
     * @explain[zh-cn] 显式触发双缓冲交换上屏，非自动帧循环驱动。
     * @param[zh-cn] capture 是否截屏（默认 false）
     *
     * @brief[en] Trigger a double-buffer swap to screen
     * @explain[en] Explicitly triggers a double-buffer swap, not driven by the automatic frame loop.
     * @param[en] capture Whether to capture a screenshot (default false)
     */
    public func present(capture!: Bool = false): Unit {
        this.backend.present(capture: capture)
    }

    /**
     * @brief[zh-cn] 获取当前渲染后端类型
     * @explain[zh-cn] 获取当前渲染后端类型，用于能力探测。
     * @return[zh-cn] 渲染器后端类型枚举
     *
     * @brief[en] Get current renderer backend type
     * @explain[en] Get current renderer backend type, used for capability detection.
     * @return[en] The renderer backend type enum
     */
    public func getRendererType(): GfxRendererType {
        this.backend.getRendererType()
    }

    /**
     * @brief[zh-cn] 获取后端能力摘要
     * @explain[zh-cn] 能力查询的公开形态：后端能力以值拷贝结构返回（无指针、无
     * 后端类型耦合），供外部按需探测（最大纹理尺寸/支持的格式位等）。
     * @return[zh-cn] 能力摘要（值语义）
     *
     * @brief[en] Get the backend capability summary
     * @explain[en] The public form of capability queries: backend caps are returned as a
     * value-copied struct (no pointers, no backend-type coupling) for external probing
     * (max texture size / supported format bits etc.).
     * @return[en] The capability summary (value semantics)
     */
    public func getCapabilities(): GfxCapsSummary {
        this.backend.getCapsSummary()
    }
}
