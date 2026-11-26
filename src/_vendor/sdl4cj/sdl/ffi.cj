/**
 * @file sdl4cj CFFI 函数声明
 * @brief SDL3 C API 的所有 foreign 函数声明
 * @explain 本文件包含 SDL3 公共 API 的 foreign 函数声明。
 *         这些函数是包级私有的，外部调用请使用 `ffi_exports.cj` 中的 `_cj` 包装。
 * @note 仓颉枚举是引用类型，不满足 CType 约束。foreign 函数使用 UInt32
 *       作为 C 枚举的底层表示。调用方通过 `EnumType.value()` 和
 *       `EnumType.fromValue(u32)` 进行转换。
 * @note 位掩码参数（SDL_InitFlags、SDL_WindowFlags、SDL_Keymod 等）直接
 *       以 UInt32 / UInt64 / UInt16 传递。
 * @note C 字符串（const char *）使用 CString 类型。
 * @note 变参函数（如 SDL_Log）仅声明固定参数部分，调用时传格式串本身。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 初始化（SDL_init.h）
// =============================================================================

foreign func SDL_Init(flags: UInt32): Bool
foreign func SDL_InitSubSystem(flags: UInt32): Bool
foreign func SDL_QuitSubSystem(flags: UInt32): Unit
@FastNative
foreign func SDL_WasInit(flags: UInt32): UInt32
foreign func SDL_Quit(): Unit
@FastNative
foreign func SDL_IsMainThread(): Bool
@FastNative
foreign func SDL_SetAppMetadata(appname: CString, appversion: CString, appidentifier: CString): Bool
@FastNative
foreign func SDL_SetAppMetadataProperty(name: CString, value: CString): Bool
@FastNative
foreign func SDL_GetAppMetadataProperty(name: CString): CString

// =============================================================================
// 错误处理（SDL_error.h）
// =============================================================================

@FastNative
foreign func SDL_SetError(fmt: CString): Bool
@FastNative
foreign func SDL_OutOfMemory(): Bool
@FastNative
foreign func SDL_GetError(): CString
@FastNative
foreign func SDL_ClearError(): Bool

// =============================================================================
// 定时器（SDL_timer.h）
// =============================================================================

@FastNative
foreign func SDL_GetTicks(): UInt64
@FastNative
foreign func SDL_GetTicksNS(): UInt64
@FastNative
foreign func SDL_GetPerformanceCounter(): UInt64
@FastNative
foreign func SDL_GetPerformanceFrequency(): UInt64
foreign func SDL_Delay(ms: UInt32): Unit
foreign func SDL_DelayNS(ns: UInt64): Unit
@FastNative
foreign func SDL_AddTimer(interval: UInt32, callback: CPointer<Unit>, userdata: CPointer<Unit>): SDL_TimerID
@FastNative
foreign func SDL_RemoveTimer(id: SDL_TimerID): Bool
foreign func SDL_DelayPrecise(ms: UInt32): Unit

// =============================================================================
// 版本（SDL_version.h）
// =============================================================================

@FastNative
foreign func SDL_GetVersion(): Int32
@FastNative
foreign func SDL_GetRevision(): CString

// =============================================================================
// 平台（SDL_platform.h）
// =============================================================================

@FastNative
foreign func SDL_GetPlatform(): CString

// =============================================================================
// 日志（SDL_log.h）
// =============================================================================

@FastNative
foreign func SDL_SetLogPriorities(priority: UInt32): Unit
@FastNative
foreign func SDL_SetLogPriority(category: Int32, priority: UInt32): Unit
@FastNative
foreign func SDL_GetLogPriority(category: Int32): UInt32
@FastNative
foreign func SDL_ResetLogPriorities(): Unit
@FastNative
foreign func SDL_Log(fmt: CString): Unit
@FastNative
foreign func SDL_LogTrace(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_LogVerbose(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_LogDebug(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_LogInfo(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_LogWarn(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_LogError(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_LogCritical(category: Int32, fmt: CString): Unit
@FastNative
foreign func SDL_SetLogOutputFunction(callback: CPointer<Unit>, userdata: CPointer<Unit>): Unit
@FastNative
foreign func SDL_GetLogOutputFunction(callback: CPointer<CPointer<Unit>>, userdata: CPointer<CPointer<Unit>>): Unit

// =============================================================================
// 提示（SDL_hints.h）
// =============================================================================

@FastNative
foreign func SDL_SetHintWithPriority(name: CString, value: CString, priority: UInt32): Bool
@FastNative
foreign func SDL_SetHint(name: CString, value: CString): Bool
@FastNative
foreign func SDL_ResetHint(name: CString): Bool
@FastNative
foreign func SDL_ResetHints(): Unit
@FastNative
foreign func SDL_GetHint(name: CString): CString
@FastNative
foreign func SDL_GetHintBoolean(name: CString, default_value: Bool): Bool

// =============================================================================
// 属性（SDL_properties.h）
// =============================================================================

@FastNative
foreign func SDL_GetGlobalProperties(): UInt32
@FastNative
foreign func SDL_CreateProperties(): UInt32
@FastNative
foreign func SDL_CopyProperties(src: UInt32, dst: UInt32): Bool
@FastNative
foreign func SDL_SetStringProperty(props: UInt32, name: CString, value: CString): Bool
@FastNative
foreign func SDL_SetNumberProperty(props: UInt32, name: CString, value: Int64): Bool
@FastNative
foreign func SDL_SetFloatProperty(props: UInt32, name: CString, value: Float32): Bool
@FastNative
foreign func SDL_SetBooleanProperty(props: UInt32, name: CString, value: Bool): Bool
@FastNative
foreign func SDL_SetPointerProperty(props: UInt32, name: CString, value: CPointer<Unit>): Bool
@FastNative
foreign func SDL_HasProperty(props: UInt32, name: CString): Bool
@FastNative
foreign func SDL_GetPropertyType(props: UInt32, name: CString): UInt32
@FastNative
foreign func SDL_GetStringProperty(props: UInt32, name: CString, default_value: CString): CString
@FastNative
foreign func SDL_GetNumberProperty(props: UInt32, name: CString, default_value: Int64): Int64
@FastNative
foreign func SDL_GetFloatProperty(props: UInt32, name: CString, default_value: Float32): Float32
@FastNative
foreign func SDL_GetBooleanProperty(props: UInt32, name: CString, default_value: Bool): Bool
@FastNative
foreign func SDL_GetPointerProperty(props: UInt32, name: CString, default_value: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func SDL_ClearProperty(props: UInt32, name: CString): Bool
@FastNative
foreign func SDL_GetNumProperties(props: UInt32): Int32
@FastNative
foreign func SDL_DestroyProperties(props: UInt32): Unit

// =============================================================================
// 视频 / 窗口（SDL_video.h）
// =============================================================================

@FastNative
foreign func SDL_GetNumVideoDrivers(): Int32
@FastNative
foreign func SDL_GetVideoDriver(index: Int32): CString
@FastNative
foreign func SDL_GetCurrentVideoDriver(): CString
@FastNative
foreign func SDL_GetDisplays(count: CPointer<Int32>): CPointer<UInt32>
@FastNative
foreign func SDL_GetPrimaryDisplay(): UInt32
@FastNative
foreign func SDL_GetDisplayBounds(displayID: UInt32, rect: CPointer<SDL_Rect>): Bool
@FastNative
foreign func SDL_GetDisplayName(displayID: UInt32): CString
@FastNative
foreign func SDL_GetDesktopDisplayMode(displayID: UInt32): SDL_DisplayMode
@FastNative
foreign func SDL_GetCurrentDisplayMode(displayID: UInt32): SDL_DisplayMode
@FastNative
foreign func SDL_GetWindowPixelDensity(window: SDL_Window): Float32
foreign func SDL_CreateWindow(title: CString, w: Int32, h: Int32, flags: UInt64): SDL_Window
@FastNative
foreign func SDL_CreatePopupWindow(parent: SDL_Window, offset_x: Int32, offset_y: Int32, w: Int32, h: Int32, flags: UInt64): SDL_Window
foreign func SDL_CreateWindowWithProperties(props: UInt32): SDL_Window
@FastNative
foreign func SDL_GetWindowID(window: SDL_Window): UInt32
@FastNative
foreign func SDL_GetWindowFromID(id: UInt32): SDL_Window
@FastNative
foreign func SDL_GetWindowFlags(window: SDL_Window): UInt64
@FastNative
foreign func SDL_SetWindowTitle(window: SDL_Window, title: CString): Bool
@FastNative
foreign func SDL_GetWindowTitle(window: SDL_Window): CString
@FastNative
foreign func SDL_SetWindowPosition(window: SDL_Window, x: Int32, y: Int32): Bool
@FastNative
foreign func SDL_SetWindowSize(window: SDL_Window, w: Int32, h: Int32): Bool
@FastNative
foreign func SDL_SetWindowResizable(window: SDL_Window, resizable: Bool): Bool
@FastNative
foreign func SDL_GetWindowPosition(window: SDL_Window, x: CPointer<Int32>, y: CPointer<Int32>): Bool
@FastNative
foreign func SDL_GetWindowSize(window: SDL_Window, w: CPointer<Int32>, h: CPointer<Int32>): Bool
@FastNative
foreign func SDL_GetWindowSizeInPixels(window: SDL_Window, w: CPointer<Int32>, h: CPointer<Int32>): Bool
@FastNative
foreign func SDL_ShowWindow(window: SDL_Window): Bool
@FastNative
foreign func SDL_HideWindow(window: SDL_Window): Bool
@FastNative
foreign func SDL_RaiseWindow(window: SDL_Window): Bool
@FastNative
foreign func SDL_MaximizeWindow(window: SDL_Window): Bool
@FastNative
foreign func SDL_MinimizeWindow(window: SDL_Window): Bool
@FastNative
foreign func SDL_RestoreWindow(window: SDL_Window): Bool
foreign func SDL_DestroyWindow(window: SDL_Window): Unit
@FastNative
foreign func SDL_GetWindowProperties(window: SDL_Window): UInt32
@FastNative
foreign func SDL_SetWindowMinimumSize(window: SDL_Window, min_w: Int32, min_h: Int32): Bool
@FastNative
foreign func SDL_GetWindowMinimumSize(window: SDL_Window, min_w: CPointer<Int32>, min_h: CPointer<Int32>): Bool
@FastNative
foreign func SDL_SetWindowMaximumSize(window: SDL_Window, max_w: Int32, max_h: Int32): Bool
@FastNative
foreign func SDL_GetWindowMaximumSize(window: SDL_Window, max_w: CPointer<Int32>, max_h: CPointer<Int32>): Bool
@FastNative
foreign func SDL_GetWindowBordersSize(window: SDL_Window, top: CPointer<Int32>, left: CPointer<Int32>, bottom: CPointer<Int32>, right: CPointer<Int32>): Bool
@FastNative
foreign func SDL_SetWindowFullscreen(window: SDL_Window, fullscreen: Bool): Bool
@FastNative
foreign func SDL_SetWindowFullscreenMode(window: SDL_Window, mode: SDL_DisplayMode): Bool
@FastNative
foreign func SDL_GetWindowFullscreenMode(window: SDL_Window): SDL_DisplayMode
@FastNative
foreign func SDL_SetWindowBordered(window: SDL_Window, bordered: Bool): Bool
@FastNative
foreign func SDL_SetWindowOpacity(window: SDL_Window, opacity: Float32): Bool
@FastNative
foreign func SDL_GetWindowOpacity(window: SDL_Window, out_opacity: CPointer<Float32>): Bool
@FastNative
foreign func SDL_SetWindowAlwaysOnTop(window: SDL_Window, on_top: Bool): Bool
@FastNative
foreign func SDL_SetWindowFocusable(window: SDL_Window, focusable: Bool): Bool
@FastNative
foreign func SDL_SetWindowModal(window: SDL_Window, modal: Bool): Bool
@FastNative
foreign func SDL_SetWindowIcon(window: SDL_Window, icon: SDL_Surface): Bool
@FastNative
foreign func SDL_SetWindowParent(window: SDL_Window, parent: SDL_Window): Bool
@FastNative
foreign func SDL_GetWindowParent(window: SDL_Window): SDL_Window
@FastNative
foreign func SDL_SetWindowAspectRatio(window: SDL_Window, min_aspect: Float32, max_aspect: Float32): Bool
@FastNative
foreign func SDL_GetWindowAspectRatio(window: SDL_Window, min_aspect: CPointer<Float32>, max_aspect: CPointer<Float32>): Bool
@FastNative
foreign func SDL_SetWindowMouseGrab(window: SDL_Window, grabbed: Bool): Bool
@FastNative
foreign func SDL_GetWindowMouseGrab(window: SDL_Window): Bool
@FastNative
foreign func SDL_SetWindowKeyboardGrab(window: SDL_Window, grabbed: Bool): Bool
@FastNative
foreign func SDL_GetWindowKeyboardGrab(window: SDL_Window): Bool
@FastNative
foreign func SDL_SetWindowMouseRect(window: SDL_Window, rect: CPointer<SDL_Rect>): Bool
@FastNative
foreign func SDL_GetWindowMouseRect(window: SDL_Window): CPointer<SDL_Rect>
@FastNative
foreign func SDL_GetWindowDisplayScale(window: SDL_Window): Float32
@FastNative
foreign func SDL_GetWindowPixelFormat(window: SDL_Window): UInt32
@FastNative
foreign func SDL_GetWindowSafeArea(window: SDL_Window, rect: CPointer<SDL_Rect>): Bool
@FastNative
foreign func SDL_GetWindows(count: CPointer<Int32>): CPointer<SDL_Window>
@FastNative
foreign func SDL_GetWindowSurface(window: SDL_Window): SDL_Surface
@FastNative
foreign func SDL_GetWindowSurfaceVSync(window: SDL_Window, vsync: CPointer<Int32>): Bool
@FastNative
foreign func SDL_SetWindowSurfaceVSync(window: SDL_Window, vsync: Int32): Bool
@FastNative
foreign func SDL_GetWindowICCProfile(window: SDL_Window, size: CPointer<UInt64>): CPointer<Unit>
@FastNative
foreign func SDL_GetWindowProgressState(window: SDL_Window): Int32
@FastNative
foreign func SDL_GetWindowProgressValue(window: SDL_Window, progress: CPointer<UInt64>): Bool
@FastNative
foreign func SDL_SetWindowProgressState(window: SDL_Window, state: Int32): Bool
@FastNative
foreign func SDL_SetWindowProgressValue(window: SDL_Window, progress: UInt64): Bool
foreign func SDL_CreateWindowAndRenderer(title: CString, width: Int32, height: Int32, window_flags: UInt64, window: CPointer<SDL_Window>, renderer: CPointer<SDL_Renderer>): Bool
@FastNative
foreign func SDL_SetWindowShape(window: SDL_Window, shape: SDL_Surface): Bool
@FastNative
foreign func SDL_SetWindowHitTest(window: SDL_Window, callback: CPointer<Unit>, callback_data: CPointer<Unit>): Bool
@FastNative
foreign func SDL_SetWindowFillDocument(window: SDL_Window, document: CString, length: UInt64): Bool

// =============================================================================
// 事件（SDL_events.h）
// =============================================================================

@FastNative
foreign func SDL_PumpEvents(): Unit
@FastNative
foreign func SDL_PollEvent(event: CPointer<SDL_Event>): Bool
foreign func SDL_WaitEvent(event: CPointer<SDL_Event>): Bool
foreign func SDL_WaitEventTimeout(event: CPointer<SDL_Event>, timeoutMS: Int32): Bool
@FastNative
foreign func SDL_PushEvent(event: CPointer<SDL_Event>): Bool
@FastNative
foreign func SDL_HasEvent(`type`: UInt32): Bool
@FastNative
foreign func SDL_HasEvents(minType: UInt32, maxType: UInt32): Bool
@FastNative
foreign func SDL_FlushEvent(`type`: UInt32): Unit
@FastNative
foreign func SDL_FlushEvents(minType: UInt32, maxType: UInt32): Unit
@FastNative
foreign func SDL_GetWindowFromEvent(event: CPointer<SDL_Event>): SDL_Window
@FastNative
foreign func SDL_AddEventWatch(filter: CPointer<Unit>, userdata: CPointer<Unit>): Bool
@FastNative
foreign func SDL_RemoveEventWatch(filter: CPointer<Unit>, userdata: CPointer<Unit>): Unit
@FastNative
foreign func SDL_EventEnabled(`type`: UInt32): Bool
@FastNative
foreign func SDL_SetEventEnabled(`type`: UInt32, enabled: Bool): Bool

// =============================================================================
// 键盘（SDL_keyboard.h）
// =============================================================================

@FastNative
foreign func SDL_HasKeyboard(): Bool
@FastNative
foreign func SDL_GetKeyboardFocus(): SDL_Window
@FastNative
foreign func SDL_GetKeyboardState(numkeys: CPointer<Int32>): CPointer<Bool>
@FastNative
foreign func SDL_ResetKeyboard(): Unit
@FastNative
foreign func SDL_GetModState(): UInt16
@FastNative
foreign func SDL_SetModState(modstate: UInt16): Unit
@FastNative
foreign func SDL_GetKeyFromScancode(scancode: UInt32, modstate: UInt16, key_event: Bool): UInt32
@FastNative
foreign func SDL_GetScancodeFromKey(key: UInt32, modstate: CPointer<UInt16>): UInt32
@FastNative
foreign func SDL_GetScancodeName(scancode: UInt32): CString
@FastNative
foreign func SDL_GetScancodeFromName(name: CString): UInt32
@FastNative
foreign func SDL_GetKeyName(key: UInt32): CString
@FastNative
foreign func SDL_GetKeyFromName(name: CString): UInt32
@FastNative
foreign func SDL_StartTextInput(window: SDL_Window): Bool
@FastNative
foreign func SDL_TextInputActive(window: SDL_Window): Bool
@FastNative
foreign func SDL_StopTextInput(window: SDL_Window): Bool
@FastNative
foreign func SDL_GetKeyboardNameForID(instance_id: UInt32): CString
@FastNative
foreign func SDL_GetKeyboards(count: CPointer<Int32>): CPointer<UInt32>
@FastNative
foreign func SDL_GetTextInputArea(window: SDL_Window, rect: CPointer<SDL_Rect>, cursor: CPointer<Int32>): Bool
@FastNative
foreign func SDL_SetTextInputArea(window: SDL_Window, rect: CPointer<SDL_Rect>, cursor: Int32): Bool
@FastNative
foreign func SDL_HasScreenKeyboardSupport(): Bool
@FastNative
foreign func SDL_ClearComposition(window: SDL_Window): Bool

// =============================================================================
// 鼠标（SDL_mouse.h）
// =============================================================================

@FastNative
foreign func SDL_HasMouse(): Bool
@FastNative
foreign func SDL_GetMouseFocus(): SDL_Window
@FastNative
foreign func SDL_GetMouseState(x: CPointer<Float32>, y: CPointer<Float32>): UInt32
@FastNative
foreign func SDL_GetGlobalMouseState(x: CPointer<Float32>, y: CPointer<Float32>): UInt32
@FastNative
foreign func SDL_GetRelativeMouseState(x: CPointer<Float32>, y: CPointer<Float32>): UInt32
@FastNative
foreign func SDL_WarpMouseInWindow(window: SDL_Window, x: Float32, y: Float32): Unit
@FastNative
foreign func SDL_SetWindowRelativeMouseMode(window: SDL_Window, enabled: Bool): Bool
@FastNative
foreign func SDL_GetWindowRelativeMouseMode(window: SDL_Window): Bool
@FastNative
foreign func SDL_CaptureMouse(enabled: Bool): Bool
@FastNative
foreign func SDL_CreateSystemCursor(id: UInt32): SDL_Cursor
@FastNative
foreign func SDL_SetCursor(cursor: SDL_Cursor): Bool
@FastNative
foreign func SDL_GetCursor(): SDL_Cursor
@FastNative
foreign func SDL_GetDefaultCursor(): SDL_Cursor
@FastNative
foreign func SDL_DestroyCursor(cursor: SDL_Cursor): Unit
@FastNative
foreign func SDL_ShowCursor(): Bool
@FastNative
foreign func SDL_HideCursor(): Bool
@FastNative
foreign func SDL_CursorVisible(): Bool
@FastNative
foreign func SDL_CreateCursor(data: CPointer<UInt8>, mask: CPointer<UInt8>, w: Int32, h: Int32, hot_x: Int32, hot_y: Int32): SDL_Cursor
@FastNative
foreign func SDL_CreateColorCursor(surface: SDL_Surface, hot_x: Int32, hot_y: Int32): SDL_Cursor
@FastNative
foreign func SDL_CreateAnimatedCursor(frames: CPointer<SDL_Surface>, durations: CPointer<Int32>, num_frames: Int32, hot_x: Int32, hot_y: Int32): SDL_Cursor

// =============================================================================
// 触摸（SDL_touch.h）
// =============================================================================

@FastNative
foreign func SDL_GetTouchDevices(count: CPointer<Int32>): CPointer<UInt64>
@FastNative
foreign func SDL_GetTouchDeviceName(touchID: UInt64): CString
@FastNative
foreign func SDL_GetTouchDeviceType(touchID: UInt64): UInt32
@FastNative
foreign func SDL_GetTouchFingers(touchID: UInt64, count: CPointer<Int32>): CPointer<CPointer<Unit>>

// =============================================================================
// 矩形（SDL_rect.h）
// @note SDL_PointInRect / SDL_RectEmpty / SDL_RectsEqual 是头文件内联函数，
//       不可链接，已在 ffi_exports.cj 中以纯仓颉函数重新实现。
// =============================================================================

@FastNative
foreign func SDL_HasRectIntersection(A: CPointer<SDL_Rect>, B: CPointer<SDL_Rect>): Bool
@FastNative
foreign func SDL_GetRectIntersection(A: CPointer<SDL_Rect>, B: CPointer<SDL_Rect>, result: CPointer<SDL_Rect>): Bool
@FastNative
foreign func SDL_GetRectUnion(A: CPointer<SDL_Rect>, B: CPointer<SDL_Rect>, result: CPointer<SDL_Rect>): Bool
@FastNative
foreign func SDL_GetRectEnclosingPoints(points: CPointer<SDL_Point>, count: Int32, clip: CPointer<SDL_Rect>, result: CPointer<SDL_Rect>): Bool

// =============================================================================
// 像素格式（SDL_pixels.h）
// =============================================================================

@FastNative
foreign func SDL_GetPixelFormatName(format: UInt32): CString
@FastNative
foreign func SDL_GetPixelFormatForMasks(bpp: Int32, Rmask: UInt32, Gmask: UInt32, Bmask: UInt32, Amask: UInt32): UInt32
@FastNative
foreign func SDL_GetPixelFormatDetails(format: UInt32): SDL_PixelFormatDetails
