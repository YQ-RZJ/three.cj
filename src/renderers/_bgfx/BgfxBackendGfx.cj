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
 * @file[zh-cn] BgfxBackendGfx 后端抽象接口实现（生命周期与视图域）
 * @brief[zh-cn] BgfxBackend 对 IRenderBackend 域 1（生命周期与设备）/域 2（视图治理）的实现
 * @explain[zh-cn] 实现体以 extend 形式落在独立文件，保持 BgfxBackend.cj 主体稳定：
 * - 全部调用经 gfxBackendExec 路由到命令线程（"任意线程"契约的落点）；
 * - 句柄/枚举经 GfxTranslation 翻译，bgfx 类型不出本包；
 * - 实现方法为 public（接口实现成员的可见性要求），但声明类 BgfxBackend 为
 *   protected（模块内可见、模块外不可见），故不构成引擎对外公开面。
 * 本文件含域 1/2；资源域见 BgfxBackendGfxResources.cj，提交/查询/调试/
 * encoder 域见 BgfxBackendGfxSubmit.cj（接口 conformance 声明在该文件收口）。
 *
 * @file[en] BgfxBackendGfx backend abstraction interface implementation (lifecycle & view domains)
 * @brief[en] BgfxBackend's implementation of IRenderBackend domain 1 (lifecycle & device) / domain 2 (view governance)
 * @explain[en] Implementations live in a dedicated file via extend, keeping the
 * BgfxBackend.cj body stable:
 * - every call routes through gfxBackendExec onto the command thread (the landing
 *   point of the "any thread" contract);
 * - handles/enums translate via GfxTranslation; bgfx types never leave this package;
 * - implementation methods are public (the visibility requirement of interface
 *   implementations), yet the declaring class BgfxBackend is protected (module-visible,
 *   invisible outside), so they do not form the engine's public surface.
 * This file covers domains 1/2; resource domains live in BgfxBackendGfxResources.cj,
 * submission/query/debug/encoder domains in BgfxBackendGfxSubmit.cj (where the
 * interface conformance declaration is finalized).
 *
 * @package three.renderers._bgfx
 */
protected package three.renderers._bgfx
import bgfx4cj.bgfx as bgfx
import bgfx4cj.bx.*
import three.renderers._gfx.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.PtrArray
import three.utils.memory.intToCPointer

// ============================================================================
// ===== 后端内部常量与辅助 =====
// ============================================================================

/**
 * @brief[zh-cn] 后端默认渲染器类型（按平台自动选择）
 * @explain[zh-cn] 与渲染器层的平台选择矩阵保持同值。独立声明的原因：bgfx 包
 * 不得反向 import 渲染器层成员（three.renderers 已依赖本包，反向导入将形成
 * 包级循环）。
 *
 * @brief[en] Backend default renderer type (auto-selected per platform)
 * @explain[en] Keeps the same values as the renderer-layer platform matrix.
 * Declared separately because the bgfx package must not import renderer-layer
 * members back (three.renderers already depends on this package; a reverse
 * import would form a package dependency cycle).
 */
@When[os == "Windows"]
internal let GFX_DEFAULT_RENDERER_TYPE: UInt32 = bgfx.RendererType.Direct3D11.value()

/**
 * @brief[zh-cn] 后端默认渲染器类型（Linux GNU：Vulkan）
 *
 * @brief[en] Backend default renderer type (Linux GNU: Vulkan)
 */
@When[os == "Linux" && env == "gnu"]
internal let GFX_DEFAULT_RENDERER_TYPE: UInt32 = bgfx.RendererType.Vulkan.value()

/**
 * @brief[zh-cn] 后端默认渲染器类型（Android：OpenGLES）
 *
 * @brief[en] Backend default renderer type (Android: OpenGLES)
 */
@When[os == "Linux" && env == "android"]
internal let GFX_DEFAULT_RENDERER_TYPE: UInt32 = bgfx.RendererType.OpenGLES.value()

/**
 * @brief[zh-cn] 后端默认渲染器类型（OpenHarmony：OpenGLES）
 *
 * @brief[en] Backend default renderer type (OpenHarmony: OpenGLES)
 */
@When[os == "Linux" && env == "ohos"]
internal let GFX_DEFAULT_RENDERER_TYPE: UInt32 = bgfx.RendererType.OpenGLES.value()

/**
 * @brief[zh-cn] 后端默认渲染器类型（macOS/iOS：Metal）
 *
 * @brief[en] Backend default renderer type (macOS/iOS: Metal)
 */
@When[os == "macOS" || os == "iOS"]
internal let GFX_DEFAULT_RENDERER_TYPE: UInt32 = bgfx.RendererType.Metal.value()

/**
 * @brief[zh-cn] 后端默认渲染器类型（未知平台回退值：自动选择）
 *
 * @brief[en] Backend default renderer type (unknown platform fallback: auto)
 */
@When[os != "Windows" && os != "Linux" && os != "macOS" && os != "iOS"]
internal let GFX_DEFAULT_RENDERER_TYPE: UInt32 = 0u32

/**
 * @brief[zh-cn] reset 的后台缓冲格式哨兵值
 * @explain[zh-cn] 后端 reset 的 format 参数传该哨兵表示沿用初始化时的后台
 * 缓冲格式（传 0 会被后端当作具体格式导致 resize 异常）。
 *
 * @brief[en] The backbuffer-format sentinel for reset
 * @explain[en] Passing this sentinel as the format parameter of backend reset
 * keeps the backbuffer format chosen at initialization (passing 0 is treated as
 * a concrete format and breaks resize).
 */
protected let GFX_FORMAT_COUNT_SENTINEL: UInt32 = bgfx.TextureFormat.Count.value()

// ============================================================================
// ===== 域 1：生命周期与设备 =====
// ============================================================================

extend BgfxBackend {
    /**
     * 初始化后端设备并绑定平台窗口。
     * width/height 为物理像素尺寸（渲染器层完成逻辑尺寸到物理尺寸的换算）；
     * msaa/maxAnisotropy 为呈现质量标志；numBackBuffers/maxFrameLatency 为
     * 交换链配置。返回 false 表示失败（含自动降级到自动选择渲染器后仍失败），
     * 不抛异常。渲染器层的初始化附属动作（shader 库初始化、主视图清屏等）
     * 不属后端职责，由渲染器在 initialize 成功后自行执行。
     */
    public func initialize(hwnd: UIntNative, width: Int32, height: Int32, vsync!: Bool, msaa!: UInt32,
        maxAnisotropy!: UInt32, numBackBuffers!: UInt8, maxFrameLatency!: UInt8): Bool {
        let resultBox: Box<Bool> = Box(false)
        gfxBackendExec.execSync(
            {
                =>
                    let initPtrHolder = AutoFreePtr<bgfx.Init>(unsafe { LibC.malloc<bgfx.Init>() })
                    let initPtr = initPtrHolder.get()
                    unsafe { initPtr.write(bgfx.Init()) }
                    bgfx.bgfx_init_ctor_cj(initPtr)
                    var initParams = unsafe { initPtr.read() }
                    initParams.`type` = GFX_DEFAULT_RENDERER_TYPE
                    initParams.vendorId = bgfx.PCI_ID_NONE
                    initParams.deviceId = bgfx.PCI_ID_NONE
                    // 主窗口交换链经 Init.swapChain 传入（nwh 从 platformData 移入 swapChain）
                    initParams.swapChain.width = UInt32(width)
                    initParams.swapChain.height = UInt32(height)
                    // reset 标志位按位组合：MSAA | (VSYNC 可选) | MAXANISOTROPY(可选)
                    var resetFlags = msaa
                    if (vsync) {
                        resetFlags |= bgfx.RESET_VSYNC
                    }
                    if (maxAnisotropy != bgfx.RESET_NONE) {
                        resetFlags |= bgfx.RESET_MAXANISOTROPY
                    }
                    initParams.reset = resetFlags
                    initParams.swapChain.numBackBuffers = numBackBuffers
                    initParams.swapChain.maxFrameLatency = maxFrameLatency
                    initParams.debug = false
                    initParams.profile = false
                    @LogDebug(["API", "setting nwh via intToCPointer, hwnd=" + hwnd.toString() +
                " reset=" + resetFlags.toString() + " numBackBuffers=" + numBackBuffers.toString() +
                " maxFrameLatency=" + maxFrameLatency.toString()])
                    initParams.swapChain.nwh = intToCPointer(hwnd)
                    unsafe { initPtr.write(initParams) }
                    var ok = bgfx.bgfx_init_cj(initPtr)
                    if (!ok && initParams.`type` != 0u32) {
                        // 失败降级：强制自动选择渲染器类型后重试
                        initParams.`type` = 0u32
                        unsafe { initPtr.write(initParams) }
                        ok = bgfx.bgfx_init_cj(initPtr)
                    }
                    initPtrHolder.dispose()
                    if (ok) {
                        bgfx.bgfx_set_debug_cj(0u32)
                        this.initialized = true
                    }
                    resultBox.value = ok
            }
        )
        return resultBox.value
    }

    /** 关闭后端并释放全部设备资源；随后停止命令线程（与渲染器释放序列一致：先同步关机、后停线程）。 */
    public func shutdown(): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_shutdown_cj()})
        gfxBackendExec.stopThread()
    }

    /** 重置后备缓冲（分辨率/标志/格式）。format 为后端格式值，传格式计数哨兵表示沿用初始化时的后台缓冲格式。 */
    public func reset(width: UInt32, height: UInt32, flags: UInt32, format: UInt32): Unit {
        gfxBackendExec.execSync(
            {
                =>
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
            }
        )
    }

    /** 设置全局调试标志位。 */
    public func setDebug(debug: UInt32): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_debug_cj(debug)})
    }

    /** 手动驱动一次渲染帧（阻塞等待模式由 msecs 决定），返回后端状态码。 */
    public func renderFrame(msecs: Int32): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        gfxBackendExec.execSync({
            => resultBox.value = bgfx.bgfx_render_frame_cj(msecs)
        })
        return resultBox.value
    }

    /** 请求截屏到文件。 */
    public func requestScreenShot(fb: GfxFrameBufferHandle, filePath: String): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(filePath) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    bgfx.bgfx_request_screen_shot_cj(toBgfx(fb), cName)
                    cNameHolder.dispose()
            }
        )
    }

    /** 触发一次双缓冲交换上屏；capture 为 true 时同时捕获截图。 */
    public func present(capture!: Bool): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_frame_cj(flags: if (capture) {
                bgfx.FRAME_DEBUG_CAPTURE
            } else {
                bgfx.FRAME_NONE
            })
        })
    }

    // ========================================================================
    // ===== 域 2：视图治理 =====
    // ========================================================================

    /** 设置视图渲染目标帧缓冲；传无效句柄表示写交换链（屏幕）。 */
    public func setViewFrameBuffer(viewId: UInt16, fb: GfxFrameBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_view_frame_buffer_cj(viewId, toBgfx(fb))})
    }

    /** 设置视图视口矩形（像素）。 */
    public func setViewRect(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_view_rect_cj(viewId, x, y, w, h)})
    }

    /** 设置视图清屏（颜色 + 深度 + 模板）。 */
    public func setViewClear(viewId: UInt16, flags: UInt16, rgba: UInt32, depth!: Float32, stencil!: UInt8): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_view_clear_cj(viewId, flags, rgba, depth, stencil)})
    }

    /** 设置视图 MRT 清屏（调色板色索引 c0-c7 + 深度 + 模板）。 */
    public func setViewClearMrt(viewId: UInt16, flags: UInt16, depth: Float32, stencil: UInt8, c0: UInt8, c1: UInt8,
        c2: UInt8, c3: UInt8, c4: UInt8, c5: UInt8, c6: UInt8, c7: UInt8): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_view_clear_mrt_cj(viewId, flags, depth, stencil, c0, c1, c2, c3, c4, c5, c6, c7)
        })
    }

    /** 设置视图 view/proj 变换矩阵（各 16 元素 Float32，列主序；零拷贝直传）。 */
    public func setViewTransform(viewId: UInt16, view: PtrArray<Float32>, proj: PtrArray<Float32>): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_view_transform_cj(viewId, unsafe { CPointer<Unit>(view.data()) },
                unsafe { CPointer<Unit>(proj.data()) })
        })
    }

    /** 设置视图渲染排序模式。 */
    public func setViewMode(viewId: UInt16, mode: GfxViewMode): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_view_mode_cj(viewId, toBgfx(mode).value())})
    }

    /** 设置视图名称（调试用）。 */
    public func setViewName(viewId: UInt16, name: String): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    bgfx.bgfx_set_view_name_cj(viewId, cName, Int32(name.size))
                    cNameHolder.dispose()
            }
        )
    }

    /** 设置视图执行顺序（按提交的顺序数组重排）。 */
    public func setViewOrder(viewId: UInt16, order: Array<UInt16>): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let holder = AutoFreePtr<UInt16>(unsafe { LibC.malloc<UInt16>(count: Int64(order.size)) })
                    let p = holder.get()
                    for (i in 0..order.size) {
                        unsafe { p.write(i, order[i]) }
                    }
                    bgfx.bgfx_set_view_order_cj(viewId, UInt16(order.size), p)
                    holder.dispose()
            }
        )
    }

    /** 设置视图裁剪矩形（像素）。 */
    public func setViewScissor(viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_view_scissor_cj(viewId, x, y, w, h)})
    }

    /** 按后缓冲比例设置视图视口矩形。 */
    public func setViewRectRatio(viewId: UInt16, x: UInt16, y: UInt16, ratio: GfxBackbufferRatio): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_view_rect_ratio_cj(viewId, x, y, toBgfx(ratio).value())})
    }

    /** 复位视图状态为默认。 */
    public func resetView(viewId: UInt16): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_reset_view_cj(viewId)})
    }

    /** 设置调色板颜色（RGBA float）。 */
    public func setPaletteColorRgba32f(index: UInt8, r: Float32, g: Float32, b: Float32, a: Float32): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_palette_color_rgba32f_cj(index, r, g, b, a)})
    }

    /** 触发视图空提交（推进清屏/序号，不绘制）。 */
    public func touchView(viewId: UInt16): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_touch_cj(viewId)})
    }
}
