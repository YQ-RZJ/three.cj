/**
 * @file sdl4cj 公共函数包装
 * @brief SDL3 C API 的仓颉安全包装函数
 * @explain 本文件为每个 SDL3 foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note 每个函数对应一个 C 端 SDL3 函数，功能与 C API 一致。
 *     Cangjie 从外部调用时，应使用这些 `_cj` 后缀的包装函数。
 * @note 字符串参数使用 CString（由调用方用 `toCString()` / `LibC.mallocCString()`
 *       创建，用完用 `LibC.free()` 释放）；返回 CString 的可调用 `.toString()`
 *       转为仓颉 String。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 初始化（SDL_init.h）
// =============================================================================

/**
 * @brief 初始化 SDL 子系统
 * @param flags 初始化标志（SDL_INIT_* 位或，如 SDL_INIT_VIDEO）
 * @return Bool 成功返回 true，失败返回 false（可用 SDL_GetError_cj 获取错误）
 */
public func SDL_Init_cj(flags: UInt32): Bool {
    return unsafe {
        SDL_Init(flags)
    }
}

/**
 * @brief 初始化指定 SDL 子系统
 * @param flags 初始化标志（SDL_INIT_* 位或）
 * @return Bool 成功返回 true
 */
public func SDL_InitSubSystem_cj(flags: UInt32): Bool {
    return unsafe {
        SDL_InitSubSystem(flags)
    }
}

/**
 * @brief 关闭指定 SDL 子系统
 * @param flags 初始化标志（SDL_INIT_* 位或）
 */
public func SDL_QuitSubSystem_cj(flags: UInt32): Unit {
    unsafe {
        SDL_QuitSubSystem(flags)
    }
}

/**
 * @brief 查询指定子系统是否已初始化
 * @param flags 初始化标志（SDL_INIT_* 位或）
 * @return UInt32 已初始化的子系统标志
 */
public func SDL_WasInit_cj(flags: UInt32): UInt32 {
    return unsafe {
        SDL_WasInit(flags)
    }
}

/**
 * @brief 关闭所有 SDL 子系统并退出
 */
public func SDL_Quit_cj(): Unit {
    unsafe {
        SDL_Quit()
    }
}

/**
 * @brief 判断当前是否在主线程
 * @return Bool 在主线程返回 true
 */
public func SDL_IsMainThread_cj(): Bool {
    return unsafe {
        SDL_IsMainThread()
    }
}

/**
 * @brief 设置应用元数据（名称、版本、标识符）
 * @param appname 应用名称
 * @param appversion 应用版本
 * @param appidentifier 应用标识符
 * @return Bool 成功返回 true
 */
public func SDL_SetAppMetadata_cj(appname: CString, appversion: CString, appidentifier: CString): Bool {
    return unsafe {
        SDL_SetAppMetadata(appname, appversion, appidentifier)
    }
}

/**
 * @brief 设置应用元数据属性
 * @param name 属性名
 * @param value 属性值
 * @return Bool 成功返回 true
 */
public func SDL_SetAppMetadataProperty_cj(name: CString, value: CString): Bool {
    return unsafe {
        SDL_SetAppMetadataProperty(name, value)
    }
}

/**
 * @brief 获取应用元数据属性
 * @param name 属性名
 * @return CString 属性值（可用 .toString() 转 String）
 */
public func SDL_GetAppMetadataProperty_cj(name: CString): CString {
    return unsafe {
        SDL_GetAppMetadataProperty(name)
    }
}

// =============================================================================
// 错误处理（SDL_error.h）
// =============================================================================

/**
 * @brief 设置当前线程的错误信息
 * @param fmt 错误格式串
 * @return Bool 成功返回 true
 */
public func SDL_SetError_cj(fmt: CString): Bool {
    return unsafe {
        SDL_SetError(fmt)
    }
}

/**
 * @brief 设置"内存不足"错误
 * @return Bool 成功返回 true
 */
public func SDL_OutOfMemory_cj(): Bool {
    return unsafe {
        SDL_OutOfMemory()
    }
}

/**
 * @brief 获取当前线程的错误信息
 * @return CString 错误信息（可用 .toString() 转 String）
 */
public func SDL_GetError_cj(): CString {
    return unsafe {
        SDL_GetError()
    }
}

/**
 * @brief 清除当前线程的错误信息
 * @return Bool 成功返回 true
 */
public func SDL_ClearError_cj(): Bool {
    return unsafe {
        SDL_ClearError()
    }
}

// =============================================================================
// 定时器（SDL_timer.h）
// =============================================================================

/**
 * @brief 获取自 SDL 初始化以来的毫秒数
 * @return UInt64 毫秒数
 */
public func SDL_GetTicks_cj(): UInt64 {
    return unsafe {
        SDL_GetTicks()
    }
}

/**
 * @brief 获取自 SDL 初始化以来的纳秒数
 * @return UInt64 纳秒数
 */
public func SDL_GetTicksNS_cj(): UInt64 {
    return unsafe {
        SDL_GetTicksNS()
    }
}

/**
 * @brief 获取高精度性能计数器值
 * @return UInt64 计数器值（配合 SDL_GetPerformanceFrequency_cj 计时）
 */
public func SDL_GetPerformanceCounter_cj(): UInt64 {
    return unsafe {
        SDL_GetPerformanceCounter()
    }
}

/**
 * @brief 获取高精度性能计数器频率（每秒计数）
 * @return UInt64 频率
 */
public func SDL_GetPerformanceFrequency_cj(): UInt64 {
    return unsafe {
        SDL_GetPerformanceFrequency()
    }
}

/**
 * @brief 延时指定毫秒数
 * @param ms 毫秒数
 */
public func SDL_Delay_cj(ms: UInt32): Unit {
    unsafe {
        SDL_Delay(ms)
    }
}

/**
 * @brief 延时指定纳秒数
 * @param ns 纳秒数
 */
public func SDL_DelayNS_cj(ns: UInt64): Unit {
    unsafe {
        SDL_DelayNS(ns)
    }
}

// =============================================================================
// 版本（SDL_version.h）
// =============================================================================

/**
 * @brief 获取 SDL 编译版本号（编码为 int）
 * @return Int32 版本号（SDL_VERSIONNUM 编码）
 */
public func SDL_GetVersion_cj(): Int32 {
    return unsafe {
        SDL_GetVersion()
    }
}

/**
 * @brief 获取 SDL 修订号（Git 提交）
 * @return CString 修订号（可用 .toString() 转 String）
 */
public func SDL_GetRevision_cj(): CString {
    return unsafe {
        SDL_GetRevision()
    }
}

// =============================================================================
// 平台（SDL_platform.h）
// =============================================================================

/**
 * @brief 获取当前平台名称
 * @return CString 平台名称，如 "Windows"、"Linux"、"OHOS"（可用 .toString()）
 */
public func SDL_GetPlatform_cj(): CString {
    return unsafe {
        SDL_GetPlatform()
    }
}

// =============================================================================
// 日志（SDL_log.h）
// =============================================================================

/**
 * @brief 设置所有日志类别的默认优先级
 * @param priority 日志优先级（SDL_LogPriority）
 */
public func SDL_SetLogPriorities_cj(priority: UInt32): Unit {
    unsafe {
        SDL_SetLogPriorities(priority)
    }
}

/**
 * @brief 设置指定日志类别的优先级
 * @param category 日志类别
 * @param priority 日志优先级（SDL_LogPriority）
 */
public func SDL_SetLogPriority_cj(category: Int32, priority: UInt32): Unit {
    unsafe {
        SDL_SetLogPriority(category, priority)
    }
}

/**
 * @brief 获取指定日志类别的优先级
 * @param category 日志类别
 * @return UInt32 日志优先级（SDL_LogPriority）
 */
public func SDL_GetLogPriority_cj(category: Int32): UInt32 {
    return unsafe {
        SDL_GetLogPriority(category)
    }
}

/**
 * @brief 重置所有日志优先级为默认值
 */
public func SDL_ResetLogPriorities_cj(): Unit {
    unsafe {
        SDL_ResetLogPriorities()
    }
}

/**
 * @brief 记录一条普通日志
 * @param fmt 日志格式串（不含占位符时直接输出文本）
 */
public func SDL_Log_cj(fmt: CString): Unit {
    unsafe {
        SDL_Log(fmt)
    }
}

/**
 * @brief 记录一条追踪级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogTrace_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogTrace(category, fmt)
    }
}

/**
 * @brief 记录一条详细级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogVerbose_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogVerbose(category, fmt)
    }
}

/**
 * @brief 记录一条调试级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogDebug_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogDebug(category, fmt)
    }
}

/**
 * @brief 记录一条信息级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogInfo_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogInfo(category, fmt)
    }
}

/**
 * @brief 记录一条警告级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogWarn_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogWarn(category, fmt)
    }
}

/**
 * @brief 记录一条错误级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogError_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogError(category, fmt)
    }
}

/**
 * @brief 记录一条严重级日志
 * @param category 日志类别
 * @param fmt 日志格式串
 */
public func SDL_LogCritical_cj(category: Int32, fmt: CString): Unit {
    unsafe {
        SDL_LogCritical(category, fmt)
    }
}

// =============================================================================
// 提示（SDL_hints.h）
// =============================================================================

/**
 * @brief 以指定优先级设置提示
 * @param name 提示名
 * @param value 提示值
 * @param priority 优先级（SDL_HintPriority）
 * @return Bool 成功返回 true
 */
public func SDL_SetHintWithPriority_cj(name: CString, value: CString, priority: UInt32): Bool {
    return unsafe {
        SDL_SetHintWithPriority(name, value, priority)
    }
}

/**
 * @brief 设置提示（普通优先级）
 * @param name 提示名
 * @param value 提示值
 * @return Bool 成功返回 true
 */
public func SDL_SetHint_cj(name: CString, value: CString): Bool {
    return unsafe {
        SDL_SetHint(name, value)
    }
}

/**
 * @brief 重置指定提示为默认值
 * @param name 提示名
 * @return Bool 成功返回 true
 */
public func SDL_ResetHint_cj(name: CString): Bool {
    return unsafe {
        SDL_ResetHint(name)
    }
}

/**
 * @brief 重置所有提示为默认值
 */
public func SDL_ResetHints_cj(): Unit {
    unsafe {
        SDL_ResetHints()
    }
}

/**
 * @brief 获取指定提示的值
 * @param name 提示名
 * @return CString 提示值（可用 .toString() 转 String）
 */
public func SDL_GetHint_cj(name: CString): CString {
    return unsafe {
        SDL_GetHint(name)
    }
}

/**
 * @brief 获取指定提示的布尔值
 * @param name 提示名
 * @param default_value 默认值
 * @return Bool 提示布尔值
 */
public func SDL_GetHintBoolean_cj(name: CString, default_value: Bool): Bool {
    return unsafe {
        SDL_GetHintBoolean(name, default_value)
    }
}

// =============================================================================
// 属性（SDL_properties.h）
// =============================================================================

/**
 * @brief 获取全局属性集合 ID
 * @return UInt32 全局属性集合 ID
 */
public func SDL_GetGlobalProperties_cj(): UInt32 {
    return unsafe {
        SDL_GetGlobalProperties()
    }
}

/**
 * @brief 创建新的属性集合
 * @return UInt32 属性集合 ID（0 表示失败）
 */
public func SDL_CreateProperties_cj(): UInt32 {
    return unsafe {
        SDL_CreateProperties()
    }
}

/**
 * @brief 将源属性集合复制到目标属性集合
 * @param src 源属性集合 ID
 * @param dst 目标属性集合 ID
 * @return Bool 成功返回 true
 */
public func SDL_CopyProperties_cj(src: UInt32, dst: UInt32): Bool {
    return unsafe {
        SDL_CopyProperties(src, dst)
    }
}

/**
 * @brief 设置字符串属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param value 属性值
 * @return Bool 成功返回 true
 */
public func SDL_SetStringProperty_cj(props: UInt32, name: CString, value: CString): Bool {
    return unsafe {
        SDL_SetStringProperty(props, name, value)
    }
}

/**
 * @brief 设置整数属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param value 属性值
 * @return Bool 成功返回 true
 */
public func SDL_SetNumberProperty_cj(props: UInt32, name: CString, value: Int64): Bool {
    return unsafe {
        SDL_SetNumberProperty(props, name, value)
    }
}

/**
 * @brief 设置浮点属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param value 属性值
 * @return Bool 成功返回 true
 */
public func SDL_SetFloatProperty_cj(props: UInt32, name: CString, value: Float32): Bool {
    return unsafe {
        SDL_SetFloatProperty(props, name, value)
    }
}

/**
 * @brief 设置布尔属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param value 属性值
 * @return Bool 成功返回 true
 */
public func SDL_SetBooleanProperty_cj(props: UInt32, name: CString, value: Bool): Bool {
    return unsafe {
        SDL_SetBooleanProperty(props, name, value)
    }
}

/**
 * @brief 设置指针属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param value 指针值（可为 null，表示清空该属性）
 * @return Bool 成功返回 true
 */
public func SDL_SetPointerProperty_cj(props: UInt32, name: CString, value: CPointer<Unit>): Bool {
    return unsafe {
        SDL_SetPointerProperty(props, name, value)
    }
}

/**
 * @brief 判断属性是否存在
 * @param props 属性集合 ID
 * @param name 属性名
 * @return Bool 存在返回 true
 */
public func SDL_HasProperty_cj(props: UInt32, name: CString): Bool {
    return unsafe {
        SDL_HasProperty(props, name)
    }
}

/**
 * @brief 获取属性类型
 * @param props 属性集合 ID
 * @param name 属性名
 * @return UInt32 属性类型（SDL_PropertyType）
 */
public func SDL_GetPropertyType_cj(props: UInt32, name: CString): UInt32 {
    return unsafe {
        SDL_GetPropertyType(props, name)
    }
}

/**
 * @brief 获取字符串属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param default_value 默认值
 * @return CString 属性值（可用 .toString() 转 String）
 */
public func SDL_GetStringProperty_cj(props: UInt32, name: CString, default_value: CString): CString {
    return unsafe {
        SDL_GetStringProperty(props, name, default_value)
    }
}

/**
 * @brief 获取整数属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param default_value 默认值
 * @return Int64 属性值
 */
public func SDL_GetNumberProperty_cj(props: UInt32, name: CString, default_value: Int64): Int64 {
    return unsafe {
        SDL_GetNumberProperty(props, name, default_value)
    }
}

/**
 * @brief 获取浮点属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param default_value 默认值
 * @return Float32 属性值
 */
public func SDL_GetFloatProperty_cj(props: UInt32, name: CString, default_value: Float32): Float32 {
    return unsafe {
        SDL_GetFloatProperty(props, name, default_value)
    }
}

/**
 * @brief 获取布尔属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @param default_value 默认值
 * @return Bool 属性值
 */
public func SDL_GetBooleanProperty_cj(props: UInt32, name: CString, default_value: Bool): Bool {
    return unsafe {
        SDL_GetBooleanProperty(props, name, default_value)
    }
}

/**
 * @brief 获取指针属性（原生句柄，如窗口的 OHNativeWindow* / HWND / ANativeWindow 等）
 * @param props 属性集合 ID
 * @param name 属性名
 * @param default_value 默认值
 * @return CPointer<Unit> 指针值，未找到时返回 default_value
 */
public func SDL_GetPointerProperty_cj(props: UInt32, name: CString, default_value: CPointer<Unit>): CPointer<Unit> {
    return unsafe {
        SDL_GetPointerProperty(props, name, default_value)
    }
}

/**
 * @brief 清除属性
 * @param props 属性集合 ID
 * @param name 属性名
 * @return Bool 成功返回 true
 */
public func SDL_ClearProperty_cj(props: UInt32, name: CString): Bool {
    return unsafe {
        SDL_ClearProperty(props, name)
    }
}

/**
 * @brief 获取属性集合中的属性数量
 * @param props 属性集合 ID
 * @return Int32 属性数量
 */
public func SDL_GetNumProperties_cj(props: UInt32): Int32 {
    return unsafe {
        SDL_GetNumProperties(props)
    }
}

/**
 * @brief 销毁属性集合
 * @param props 属性集合 ID
 */
public func SDL_DestroyProperties_cj(props: UInt32): Unit {
    unsafe {
        SDL_DestroyProperties(props)
    }
}

/**
 * @brief 获取窗口的属性集合 ID（跨平台获取原生窗口句柄用）
 * @param window 窗口指针
 * @return UInt32 属性集合 ID
 */
public func SDL_GetWindowProperties_cj(window: SDL_Window): UInt32 {
    return unsafe {
        SDL_GetWindowProperties(window)
    }
}

// =============================================================================
// 视频 / 窗口（SDL_video.h）
// =============================================================================

/**
 * @brief 获取视频驱动数量
 * @return Int32 视频驱动数量
 */
public func SDL_GetNumVideoDrivers_cj(): Int32 {
    return unsafe {
        SDL_GetNumVideoDrivers()
    }
}

/**
 * @brief 获取指定索引的视频驱动名称
 * @param index 驱动索引
 * @return CString 驱动名称（可用 .toString() 转 String）
 */
public func SDL_GetVideoDriver_cj(index: Int32): CString {
    return unsafe {
        SDL_GetVideoDriver(index)
    }
}

/**
 * @brief 获取当前使用的视频驱动名称
 * @return CString 驱动名称（可用 .toString() 转 String）
 */
public func SDL_GetCurrentVideoDriver_cj(): CString {
    return unsafe {
        SDL_GetCurrentVideoDriver()
    }
}

/**
 * @brief 获取所有显示器 ID 数组
 * @param count 输出显示器数量指针
 * @return CPointer<UInt32> 显示器 ID 数组（用完用 LibC.free 释放）
 */
public func SDL_GetDisplays_cj(count: CPointer<Int32>): CPointer<UInt32> {
    return unsafe {
        SDL_GetDisplays(count)
    }
}

/**
 * @brief 获取主显示器 ID
 * @return UInt32 主显示器 ID
 */
public func SDL_GetPrimaryDisplay_cj(): UInt32 {
    return unsafe {
        SDL_GetPrimaryDisplay()
    }
}

/**
 * @brief 获取显示器边界矩形
 * @param displayID 显示器 ID
 * @param rect 输出矩形指针
 * @return Bool 成功返回 true
 */
public func SDL_GetDisplayBounds_cj(displayID: UInt32, rect: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_GetDisplayBounds(displayID, rect)
    }
}

/**
 * @brief 获取显示器名称
 * @param displayID 显示器 ID
 * @return CString 显示器名称（可用 .toString() 转 String）
 */
public func SDL_GetDisplayName_cj(displayID: UInt32): CString {
    return unsafe {
        SDL_GetDisplayName(displayID)
    }
}

/**
 * @brief 获取显示器桌面显示模式
 * @param displayID 显示器 ID
 * @return SDL_DisplayMode 显示模式指针
 */
public func SDL_GetDesktopDisplayMode_cj(displayID: UInt32): SDL_DisplayMode {
    return unsafe {
        SDL_GetDesktopDisplayMode(displayID)
    }
}

/**
 * @brief 获取显示器当前显示模式
 * @param displayID 显示器 ID
 * @return SDL_DisplayMode 显示模式指针
 */
public func SDL_GetCurrentDisplayMode_cj(displayID: UInt32): SDL_DisplayMode {
    return unsafe {
        SDL_GetCurrentDisplayMode(displayID)
    }
}

/**
 * @brief 获取窗口像素密度
 * @param window 窗口指针
 * @return Float32 像素密度
 */
public func SDL_GetWindowPixelDensity_cj(window: SDL_Window): Float32 {
    return unsafe {
        SDL_GetWindowPixelDensity(window)
    }
}

/**
 * @brief 创建窗口
 * @param title 窗口标题
 * @param w 窗口宽度
 * @param h 窗口高度
 * @param flags 窗口标志（SDL_WINDOW_* 位或）
 * @return SDL_Window 窗口指针（null 表示失败）
 */
public func SDL_CreateWindow_cj(title: CString, w: Int32, h: Int32, flags: UInt64): SDL_Window {
    return unsafe {
        SDL_CreateWindow(title, w, h, flags)
    }
}

/**
 * @brief 创建弹出窗口
 * @param parent 父窗口
 * @param offset_x 偏移 X
 * @param offset_y 偏移 Y
 * @param w 窗口宽度
 * @param h 窗口高度
 * @param flags 窗口标志（SDL_WINDOW_* 位或）
 * @return SDL_Window 窗口指针（null 表示失败）
 */
public func SDL_CreatePopupWindow_cj(parent: SDL_Window, offset_x: Int32, offset_y: Int32, w: Int32, h: Int32, flags: UInt64): SDL_Window {
    return unsafe {
        SDL_CreatePopupWindow(parent, offset_x, offset_y, w, h, flags)
    }
}

/**
 * @brief 通过属性集合创建窗口
 * @param props 属性集合 ID（含 SDL_PROP_WINDOW_CREATE_* 属性）
 * @return SDL_Window 窗口指针（null 表示失败）
 */
public func SDL_CreateWindowWithProperties_cj(props: UInt32): SDL_Window {
    return unsafe {
        SDL_CreateWindowWithProperties(props)
    }
}

/**
 * @brief 获取窗口 ID
 * @param window 窗口指针
 * @return UInt32 窗口 ID
 */
public func SDL_GetWindowID_cj(window: SDL_Window): UInt32 {
    return unsafe {
        SDL_GetWindowID(window)
    }
}

/**
 * @brief 根据窗口 ID 获取窗口指针
 * @param id 窗口 ID
 * @return SDL_Window 窗口指针
 */
public func SDL_GetWindowFromID_cj(id: UInt32): SDL_Window {
    return unsafe {
        SDL_GetWindowFromID(id)
    }
}

/**
 * @brief 获取窗口标志
 * @param window 窗口指针
 * @return UInt64 窗口标志（SDL_WINDOW_* 位或）
 */
public func SDL_GetWindowFlags_cj(window: SDL_Window): UInt64 {
    return unsafe {
        SDL_GetWindowFlags(window)
    }
}

/**
 * @brief 设置窗口标题
 * @param window 窗口指针
 * @param title 新标题
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowTitle_cj(window: SDL_Window, title: CString): Bool {
    return unsafe {
        SDL_SetWindowTitle(window, title)
    }
}

/**
 * @brief 获取窗口标题
 * @param window 窗口指针
 * @return CString 标题（可用 .toString() 转 String）
 */
public func SDL_GetWindowTitle_cj(window: SDL_Window): CString {
    return unsafe {
        SDL_GetWindowTitle(window)
    }
}

/**
 * @brief 设置窗口位置
 * @param window 窗口指针
 * @param x X 坐标
 * @param y Y 坐标
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowPosition_cj(window: SDL_Window, x: Int32, y: Int32): Bool {
    return unsafe {
        SDL_SetWindowPosition(window, x, y)
    }
}

/**
 * @brief 设置窗口尺寸
 * @param window 窗口指针
 * @param w 新宽度
 * @param h 新高度
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowSize_cj(window: SDL_Window, w: Int32, h: Int32): Bool {
    return unsafe {
        SDL_SetWindowSize(window, w, h)
    }
}

/**
 * @brief 设置窗口是否可由用户调整大小（运行时切换，创建后也可用）
 * @param window 窗口指针
 * @param resizable true=可调节尺寸，false=锁定尺寸（不可调节）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowResizable_cj(window: SDL_Window, resizable: Bool): Bool {
    return unsafe {
        SDL_SetWindowResizable(window, resizable)
    }
}

/**
 * @brief 获取窗口位置
 * @param window 窗口指针
 * @param x 输出 X 坐标指针
 * @param y 输出 Y 坐标指针
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowPosition_cj(window: SDL_Window, x: CPointer<Int32>, y: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowPosition(window, x, y)
    }
}

/**
 * @brief 获取窗口尺寸
 * @param window 窗口指针
 * @param w 输出宽度指针
 * @param h 输出高度指针
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowSize_cj(window: SDL_Window, w: CPointer<Int32>, h: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowSize(window, w, h)
    }
}

/**
 * @brief 获取窗口像素尺寸
 * @param window 窗口指针
 * @param w 输出宽度指针
 * @param h 输出高度指针
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowSizeInPixels_cj(window: SDL_Window, w: CPointer<Int32>, h: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowSizeInPixels(window, w, h)
    }
}

/**
 * @brief 显示窗口
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_ShowWindow_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_ShowWindow(window)
    }
}

/**
 * @brief 隐藏窗口
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_HideWindow_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_HideWindow(window)
    }
}

/**
 * @brief 将窗口置顶
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_RaiseWindow_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_RaiseWindow(window)
    }
}

/**
 * @brief 最大化窗口
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_MaximizeWindow_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_MaximizeWindow(window)
    }
}

/**
 * @brief 最小化窗口
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_MinimizeWindow_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_MinimizeWindow(window)
    }
}

/**
 * @brief 恢复窗口
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_RestoreWindow_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_RestoreWindow(window)
    }
}

/**
 * @brief 销毁窗口
 * @param window 窗口指针
 */
public func SDL_DestroyWindow_cj(window: SDL_Window): Unit {
    unsafe {
        SDL_DestroyWindow(window)
    }
}

/**
 * @brief 设置窗口最小尺寸（resize 下限）
 * @param window 窗口指针
 * @param min_w 最小宽度
 * @param min_h 最小高度
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowMinimumSize_cj(window: SDL_Window, min_w: Int32, min_h: Int32): Bool {
    return unsafe {
        SDL_SetWindowMinimumSize(window, min_w, min_h)
    }
}

/**
 * @brief 获取窗口最小尺寸
 * @param window 窗口指针
 * @param min_w 输出参数：最小宽度
 * @param min_h 输出参数：最小高度
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowMinimumSize_cj(window: SDL_Window, min_w: CPointer<Int32>, min_h: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowMinimumSize(window, min_w, min_h)
    }
}

/**
 * @brief 设置窗口最大尺寸（resize 上限）
 * @param window 窗口指针
 * @param max_w 最大宽度
 * @param max_h 最大高度
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowMaximumSize_cj(window: SDL_Window, max_w: Int32, max_h: Int32): Bool {
    return unsafe {
        SDL_SetWindowMaximumSize(window, max_w, max_h)
    }
}

/**
 * @brief 获取窗口最大尺寸
 * @param window 窗口指针
 * @param max_w 输出参数：最大宽度
 * @param max_h 输出参数：最大高度
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowMaximumSize_cj(window: SDL_Window, max_w: CPointer<Int32>, max_h: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowMaximumSize(window, max_w, max_h)
    }
}

/**
 * @brief 获取窗口边框大小
 * @param window 窗口指针
 * @param top 输出参数：上边框
 * @param left 输出参数：左边框
 * @param bottom 输出参数：下边框
 * @param right 输出参数：右边框
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowBordersSize_cj(window: SDL_Window, top: CPointer<Int32>, left: CPointer<Int32>, bottom: CPointer<Int32>, right: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowBordersSize(window, top, left, bottom, right)
    }
}

/**
 * @brief 设置窗口是否全屏
 * @param window 窗口指针
 * @param fullscreen true=全屏，false=退出全屏
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowFullscreen_cj(window: SDL_Window, fullscreen: Bool): Bool {
    return unsafe {
        SDL_SetWindowFullscreen(window, fullscreen)
    }
}

/**
 * @brief 设置窗口全屏模式
 * @param window 窗口指针
 * @param mode 全屏显示模式（null 表示桌面全屏）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowFullscreenMode_cj(window: SDL_Window, mode: SDL_DisplayMode): Bool {
    return unsafe {
        SDL_SetWindowFullscreenMode(window, mode)
    }
}

/**
 * @brief 获取窗口当前全屏模式
 * @param window 窗口指针
 * @return SDL_DisplayMode 显示模式（未全屏返回 null）
 */
public func SDL_GetWindowFullscreenMode_cj(window: SDL_Window): SDL_DisplayMode {
    return unsafe {
        SDL_GetWindowFullscreenMode(window)
    }
}

/**
 * @brief 设置窗口是否有边框
 * @param window 窗口指针
 * @param bordered true=有边框，false=无边框
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowBordered_cj(window: SDL_Window, bordered: Bool): Bool {
    return unsafe {
        SDL_SetWindowBordered(window, bordered)
    }
}

/**
 * @brief 设置窗口透明度
 * @param window 窗口指针
 * @param opacity 透明度（0.0=完全透明，1.0=不透明）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowOpacity_cj(window: SDL_Window, opacity: Float32): Bool {
    return unsafe {
        SDL_SetWindowOpacity(window, opacity)
    }
}

/**
 * @brief 获取窗口透明度
 * @param window 窗口指针
 * @param out_opacity 输出参数：透明度（0.0-1.0）
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowOpacity_cj(window: SDL_Window, out_opacity: CPointer<Float32>): Bool {
    return unsafe {
        SDL_GetWindowOpacity(window, out_opacity)
    }
}

/**
 * @brief 设置窗口是否置顶
 * @param window 窗口指针
 * @param on_top true=置顶，false=取消置顶
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowAlwaysOnTop_cj(window: SDL_Window, on_top: Bool): Bool {
    return unsafe {
        SDL_SetWindowAlwaysOnTop(window, on_top)
    }
}

/**
 * @brief 设置窗口是否可聚焦
 * @param window 窗口指针
 * @param focusable true=可聚焦，false=不可聚焦
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowFocusable_cj(window: SDL_Window, focusable: Bool): Bool {
    return unsafe {
        SDL_SetWindowFocusable(window, focusable)
    }
}

/**
 * @brief 设置窗口是否模态
 * @param window 窗口指针
 * @param modal true=模态，false=非模态
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowModal_cj(window: SDL_Window, modal: Bool): Bool {
    return unsafe {
        SDL_SetWindowModal(window, modal)
    }
}

/**
 * @brief 设置窗口图标
 * @param window 窗口指针
 * @param icon 图标表面（SDL_Surface）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowIcon_cj(window: SDL_Window, icon: SDL_Surface): Bool {
    return unsafe {
        SDL_SetWindowIcon(window, icon)
    }
}

/**
 * @brief 设置窗口父窗口
 * @param window 窗口指针
 * @param parent 父窗口指针（null 表示独立窗口）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowParent_cj(window: SDL_Window, parent: SDL_Window): Bool {
    return unsafe {
        SDL_SetWindowParent(window, parent)
    }
}

/**
 * @brief 获取窗口父窗口
 * @param window 窗口指针
 * @return SDL_Window 父窗口指针（无父窗口返回 null）
 */
public func SDL_GetWindowParent_cj(window: SDL_Window): SDL_Window {
    return unsafe {
        SDL_GetWindowParent(window)
    }
}

/**
 * @brief 设置窗口宽高比约束
 * @param window 窗口指针
 * @param min_aspect 最小宽高比
 * @param max_aspect 最大宽高比
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowAspectRatio_cj(window: SDL_Window, min_aspect: Float32, max_aspect: Float32): Bool {
    return unsafe {
        SDL_SetWindowAspectRatio(window, min_aspect, max_aspect)
    }
}

/**
 * @brief 获取窗口宽高比约束
 * @param window 窗口指针
 * @param min_aspect 输出参数：最小宽高比
 * @param max_aspect 输出参数：最大宽高比
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowAspectRatio_cj(window: SDL_Window, min_aspect: CPointer<Float32>, max_aspect: CPointer<Float32>): Bool {
    return unsafe {
        SDL_GetWindowAspectRatio(window, min_aspect, max_aspect)
    }
}

/**
 * @brief 设置鼠标是否捕获到窗口（隐藏并锁定鼠标）
 * @param window 窗口指针
 * @param grabbed true=捕获，false=释放
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowMouseGrab_cj(window: SDL_Window, grabbed: Bool): Bool {
    return unsafe {
        SDL_SetWindowMouseGrab(window, grabbed)
    }
}

/**
 * @brief 获取窗口鼠标捕获状态
 * @param window 窗口指针
 * @return Bool 是否捕获
 */
public func SDL_GetWindowMouseGrab_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_GetWindowMouseGrab(window)
    }
}

/**
 * @brief 设置键盘是否捕获到窗口
 * @param window 窗口指针
 * @param grabbed true=捕获，false=释放
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowKeyboardGrab_cj(window: SDL_Window, grabbed: Bool): Bool {
    return unsafe {
        SDL_SetWindowKeyboardGrab(window, grabbed)
    }
}

/**
 * @brief 获取窗口键盘捕获状态
 * @param window 窗口指针
 * @return Bool 是否捕获
 */
public func SDL_GetWindowKeyboardGrab_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_GetWindowKeyboardGrab(window)
    }
}

/**
 * @brief 设置鼠标捕获区域
 * @param window 窗口指针
 * @param rect 捕获区域矩形（null 表示整个窗口）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowMouseRect_cj(window: SDL_Window, rect: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_SetWindowMouseRect(window, rect)
    }
}

/**
 * @brief 获取窗口鼠标捕获区域
 * @param window 窗口指针
 * @return CPointer<SDL_Rect> 捕获区域矩形（未设置返回 null）
 */
public func SDL_GetWindowMouseRect_cj(window: SDL_Window): CPointer<SDL_Rect> {
    return unsafe {
        SDL_GetWindowMouseRect(window)
    }
}

/**
 * @brief 获取窗口显示缩放比例
 * @param window 窗口指针
 * @return Float32 缩放比例
 */
public func SDL_GetWindowDisplayScale_cj(window: SDL_Window): Float32 {
    return unsafe {
        SDL_GetWindowDisplayScale(window)
    }
}

/**
 * @brief 获取窗口像素格式
 * @param window 窗口指针
 * @return UInt32 像素格式（SDL_PixelFormat）
 */
public func SDL_GetWindowPixelFormat_cj(window: SDL_Window): UInt32 {
    return unsafe {
        SDL_GetWindowPixelFormat(window)
    }
}

/**
 * @brief 获取窗口安全区域
 * @param window 窗口指针
 * @param rect 输出参数：安全区域矩形
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowSafeArea_cj(window: SDL_Window, rect: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_GetWindowSafeArea(window, rect)
    }
}

/**
 * @brief 枚举所有窗口
 * @param count 输出参数：窗口数量
 * @return CPointer<SDL_Window> 窗口指针数组（调用方需释放）
 */
public func SDL_GetWindows_cj(count: CPointer<Int32>): CPointer<SDL_Window> {
    return unsafe {
        SDL_GetWindows(count)
    }
}

/**
 * @brief 获取窗口表面（用于软件渲染）
 * @param window 窗口指针
 * @return SDL_Surface 窗口表面（null 表示失败）
 */
public func SDL_GetWindowSurface_cj(window: SDL_Window): SDL_Surface {
    return unsafe {
        SDL_GetWindowSurface(window)
    }
}

/**
 * @brief 获取窗口表面垂直同步设置
 * @param window 窗口指针
 * @param vsync 输出参数：垂直同步间隔（0=关闭）
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowSurfaceVSync_cj(window: SDL_Window, vsync: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetWindowSurfaceVSync(window, vsync)
    }
}

/**
 * @brief 设置窗口表面垂直同步
 * @param window 窗口指针
 * @param vsync 垂直同步间隔（0=关闭，1=每帧）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowSurfaceVSync_cj(window: SDL_Window, vsync: Int32): Bool {
    return unsafe {
        SDL_SetWindowSurfaceVSync(window, vsync)
    }
}

/**
 * @brief 获取窗口 ICC 色彩配置文件
 * @param window 窗口指针
 * @param size 输出参数：配置文件数据大小（字节）
 * @return CPointer<Unit> 配置文件数据（调用方需释放）
 */
public func SDL_GetWindowICCProfile_cj(window: SDL_Window, size: CPointer<UInt64>): CPointer<Unit> {
    return unsafe {
        SDL_GetWindowICCProfile(window, size)
    }
}

/**
 * @brief 获取窗口进度状态（任务栏进度条）
 * @param window 窗口指针
 * @return Int32 进度状态（SDL_ProgressState）
 */
public func SDL_GetWindowProgressState_cj(window: SDL_Window): Int32 {
    return unsafe {
        SDL_GetWindowProgressState(window)
    }
}

/**
 * @brief 获取窗口进度值（任务栏进度条）
 * @param window 窗口指针
 * @param progress 输出参数：进度值
 * @return Bool 成功返回 true
 */
public func SDL_GetWindowProgressValue_cj(window: SDL_Window, progress: CPointer<UInt64>): Bool {
    return unsafe {
        SDL_GetWindowProgressValue(window, progress)
    }
}

/**
 * @brief 设置窗口进度状态（任务栏进度条）
 * @param window 窗口指针
 * @param state 进度状态（SDL_ProgressState）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowProgressState_cj(window: SDL_Window, state: Int32): Bool {
    return unsafe {
        SDL_SetWindowProgressState(window, state)
    }
}

/**
 * @brief 设置窗口进度值（任务栏进度条）
 * @param window 窗口指针
 * @param progress 进度值
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowProgressValue_cj(window: SDL_Window, progress: UInt64): Bool {
    return unsafe {
        SDL_SetWindowProgressValue(window, progress)
    }
}

/**
 * @brief 创建窗口和软件渲染器
 * @param title 窗口标题（UTF-8）
 * @param width 窗口宽度
 * @param height 窗口高度
 * @param window_flags 窗口标志（SDL_WINDOW_* 位或）
 * @param window 输出参数：窗口指针
 * @param renderer 输出参数：渲染器指针
 * @return Bool 成功返回 true
 */
public func SDL_CreateWindowAndRenderer_cj(title: CString, width: Int32, height: Int32, window_flags: UInt64, window: CPointer<SDL_Window>, renderer: CPointer<SDL_Renderer>): Bool {
    return unsafe {
        SDL_CreateWindowAndRenderer(title, width, height, window_flags, window, renderer)
    }
}

/**
 * @brief 设置窗口形状（异形窗口）
 * @param window 窗口指针
 * @param shape 形状表面（透明度决定形状）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowShape_cj(window: SDL_Window, shape: SDL_Surface): Bool {
    return unsafe {
        SDL_SetWindowShape(window, shape)
    }
}

/**
 * @brief 设置窗口命中测试回调（自定义点击区域）
 * @param window 窗口指针
 * @param callback 命中测试回调函数指针（暂以 CPointer<Unit> 占位，可传 null）
 * @param callback_data 回调上下文数据
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowHitTest_cj(window: SDL_Window, callback: CPointer<Unit>, callback_data: CPointer<Unit>): Bool {
    return unsafe {
        SDL_SetWindowHitTest(window, callback, callback_data)
    }
}

/**
 * @brief 设置窗口填充文档（边缘到边缘内容适配）
 * @param window 窗口指针
 * @param document 文档字符串（UTF-8）
 * @param length 文档长度（0 表示以 null 结尾）
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowFillDocument_cj(window: SDL_Window, document: CString, length: UInt64): Bool {
    return unsafe {
        SDL_SetWindowFillDocument(window, document, length)
    }
}

// =============================================================================
// 事件（SDL_events.h）
// =============================================================================

/**
 * @brief 泵取事件（更新输入设备状态）
 */
public func SDL_PumpEvents_cj(): Unit {
    unsafe {
        SDL_PumpEvents()
    }
}

/**
 * @brief 轮询事件（非阻塞）
 * @param event 事件缓冲指针（SDL_Event，128 字节）
 * @return Bool 有事件返回 true，无事件返回 false
 */
public func SDL_PollEvent_cj(event: CPointer<SDL_Event>): Bool {
    return unsafe {
        SDL_PollEvent(event)
    }
}

/**
 * @brief 等待事件（阻塞）
 * @param event 事件缓冲指针（SDL_Event，128 字节）
 * @return Bool 成功返回 true
 */
public func SDL_WaitEvent_cj(event: CPointer<SDL_Event>): Bool {
    return unsafe {
        SDL_WaitEvent(event)
    }
}

/**
 * @brief 带超时等待事件
 * @param event 事件缓冲指针（SDL_Event，128 字节）
 * @param timeoutMS 超时毫秒数
 * @return Bool 成功返回 true
 */
public func SDL_WaitEventTimeout_cj(event: CPointer<SDL_Event>, timeoutMS: Int32): Bool {
    return unsafe {
        SDL_WaitEventTimeout(event, timeoutMS)
    }
}

/**
 * @brief 推送事件到事件队列
 * @param event 事件缓冲指针（SDL_Event，128 字节）
 * @return Bool 成功返回 true
 */
public func SDL_PushEvent_cj(event: CPointer<SDL_Event>): Bool {
    return unsafe {
        SDL_PushEvent(event)
    }
}

/**
 * @brief 判断事件队列中是否存在指定类型事件
 * @param `type` 事件类型（SDL_EVENT_*）
 * @return Bool 存在返回 true
 */
public func SDL_HasEvent_cj(`type`: UInt32): Bool {
    return unsafe {
        SDL_HasEvent(`type`)
    }
}

/**
 * @brief 判断事件队列中是否存在指定范围事件
 * @param minType 最小事件类型
 * @param maxType 最大事件类型
 * @return Bool 存在返回 true
 */
public func SDL_HasEvents_cj(minType: UInt32, maxType: UInt32): Bool {
    return unsafe {
        SDL_HasEvents(minType, maxType)
    }
}

/**
 * @brief 从事件队列中清除指定类型事件
 * @param `type` 事件类型（SDL_EVENT_*）
 */
public func SDL_FlushEvent_cj(`type`: UInt32): Unit {
    unsafe {
        SDL_FlushEvent(`type`)
    }
}

/**
 * @brief 从事件队列中清除指定范围事件
 * @param minType 最小事件类型
 * @param maxType 最大事件类型
 */
public func SDL_FlushEvents_cj(minType: UInt32, maxType: UInt32): Unit {
    unsafe {
        SDL_FlushEvents(minType, maxType)
    }
}

/**
 * @brief 从事件中获取关联窗口
 * @param event 事件缓冲指针
 * @return SDL_Window 关联窗口指针
 */
public func SDL_GetWindowFromEvent_cj(event: CPointer<SDL_Event>): SDL_Window {
    return unsafe {
        SDL_GetWindowFromEvent(event)
    }
}

// =============================================================================
// 键盘（SDL_keyboard.h）
// =============================================================================

/**
 * @brief 判断系统是否有键盘
 * @return Bool 有键盘返回 true
 */
public func SDL_HasKeyboard_cj(): Bool {
    return unsafe {
        SDL_HasKeyboard()
    }
}

/**
 * @brief 获取拥有键盘焦点的窗口
 * @return SDL_Window 窗口指针
 */
public func SDL_GetKeyboardFocus_cj(): SDL_Window {
    return unsafe {
        SDL_GetKeyboardFocus()
    }
}

/**
 * @brief 获取键盘状态数组
 * @param numkeys 输出按键数量指针
 * @return CPointer<Bool> 键盘状态数组（按扫描码索引，按下为 true）
 */
public func SDL_GetKeyboardState_cj(numkeys: CPointer<Int32>): CPointer<Bool> {
    return unsafe {
        SDL_GetKeyboardState(numkeys)
    }
}

/**
 * @brief 重置键盘状态
 */
public func SDL_ResetKeyboard_cj(): Unit {
    unsafe {
        SDL_ResetKeyboard()
    }
}

/**
 * @brief 获取当前键盘修饰符
 * @return UInt16 修饰符（SDL_KMOD_* 位或）
 */
public func SDL_GetModState_cj(): UInt16 {
    return unsafe {
        SDL_GetModState()
    }
}

/**
 * @brief 设置当前键盘修饰符
 * @param modstate 修饰符（SDL_KMOD_* 位或）
 */
public func SDL_SetModState_cj(modstate: UInt16): Unit {
    unsafe {
        SDL_SetModState(modstate)
    }
}

/**
 * @brief 从扫描码获取键码
 * @param scancode 扫描码（SDL_SCANCODE_*）
 * @param modstate 修饰符（SDL_KMOD_* 位或）
 * @param key_event 是否为按键事件
 * @return UInt32 键码（SDLK_*）
 */
public func SDL_GetKeyFromScancode_cj(scancode: UInt32, modstate: UInt16, key_event: Bool): UInt32 {
    return unsafe {
        SDL_GetKeyFromScancode(scancode, modstate, key_event)
    }
}

/**
 * @brief 从键码获取扫描码
 * @param key 键码（SDLK_*）
 * @param modstate 输出修饰符指针
 * @return UInt32 扫描码（SDL_SCANCODE_*）
 */
public func SDL_GetScancodeFromKey_cj(key: UInt32, modstate: CPointer<UInt16>): UInt32 {
    return unsafe {
        SDL_GetScancodeFromKey(key, modstate)
    }
}

/**
 * @brief 获取扫描码名称
 * @param scancode 扫描码（SDL_SCANCODE_*）
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetScancodeName_cj(scancode: UInt32): CString {
    return unsafe {
        SDL_GetScancodeName(scancode)
    }
}

/**
 * @brief 从名称获取扫描码
 * @param name 名称
 * @return UInt32 扫描码（SDL_SCANCODE_*）
 */
public func SDL_GetScancodeFromName_cj(name: CString): UInt32 {
    return unsafe {
        SDL_GetScancodeFromName(name)
    }
}

/**
 * @brief 获取键码名称
 * @param key 键码（SDLK_*）
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetKeyName_cj(key: UInt32): CString {
    return unsafe {
        SDL_GetKeyName(key)
    }
}

/**
 * @brief 从名称获取键码
 * @param name 名称
 * @return UInt32 键码（SDLK_*）
 */
public func SDL_GetKeyFromName_cj(name: CString): UInt32 {
    return unsafe {
        SDL_GetKeyFromName(name)
    }
}

/**
 * @brief 开始文本输入
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_StartTextInput_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_StartTextInput(window)
    }
}

/**
 * @brief 判断文本输入是否激活
 * @param window 窗口指针
 * @return Bool 激活返回 true
 */
public func SDL_TextInputActive_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_TextInputActive(window)
    }
}

/**
 * @brief 停止文本输入
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_StopTextInput_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_StopTextInput(window)
    }
}

// =============================================================================
// 鼠标（SDL_mouse.h）
// =============================================================================

/**
 * @brief 判断系统是否有鼠标
 * @return Bool 有鼠标返回 true
 */
public func SDL_HasMouse_cj(): Bool {
    return unsafe {
        SDL_HasMouse()
    }
}

/**
 * @brief 获取拥有鼠标焦点的窗口
 * @return SDL_Window 窗口指针
 */
public func SDL_GetMouseFocus_cj(): SDL_Window {
    return unsafe {
        SDL_GetMouseFocus()
    }
}

/**
 * @brief 获取鼠标状态（相对窗口）
 * @param x 输出 X 坐标指针
 * @param y 输出 Y 坐标指针
 * @return UInt32 鼠标按键状态（SDL_BUTTON_*MASK 位或）
 */
public func SDL_GetMouseState_cj(x: CPointer<Float32>, y: CPointer<Float32>): UInt32 {
    return unsafe {
        SDL_GetMouseState(x, y)
    }
}

/**
 * @brief 获取全局鼠标状态（相对屏幕）
 * @param x 输出 X 坐标指针
 * @param y 输出 Y 坐标指针
 * @return UInt32 鼠标按键状态（SDL_BUTTON_*MASK 位或）
 */
public func SDL_GetGlobalMouseState_cj(x: CPointer<Float32>, y: CPointer<Float32>): UInt32 {
    return unsafe {
        SDL_GetGlobalMouseState(x, y)
    }
}

/**
 * @brief 获取相对鼠标状态
 * @param x 输出相对 X 坐标指针
 * @param y 输出相对 Y 坐标指针
 * @return UInt32 鼠标按键状态（SDL_BUTTON_*MASK 位或）
 */
public func SDL_GetRelativeMouseState_cj(x: CPointer<Float32>, y: CPointer<Float32>): UInt32 {
    return unsafe {
        SDL_GetRelativeMouseState(x, y)
    }
}

/**
 * @brief 在窗口内移动鼠标
 * @param window 窗口指针
 * @param x X 坐标
 * @param y Y 坐标
 */
public func SDL_WarpMouseInWindow_cj(window: SDL_Window, x: Float32, y: Float32): Unit {
    unsafe {
        SDL_WarpMouseInWindow(window, x, y)
    }
}

/**
 * @brief 设置窗口相对鼠标模式
 * @param window 窗口指针
 * @param enabled 是否启用
 * @return Bool 成功返回 true
 */
public func SDL_SetWindowRelativeMouseMode_cj(window: SDL_Window, enabled: Bool): Bool {
    return unsafe {
        SDL_SetWindowRelativeMouseMode(window, enabled)
    }
}

/**
 * @brief 获取窗口相对鼠标模式
 * @param window 窗口指针
 * @return Bool 是否启用
 */
public func SDL_GetWindowRelativeMouseMode_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_GetWindowRelativeMouseMode(window)
    }
}

/**
 * @brief 捕获鼠标
 * @param enabled 是否捕获
 * @return Bool 成功返回 true
 */
public func SDL_CaptureMouse_cj(enabled: Bool): Bool {
    return unsafe {
        SDL_CaptureMouse(enabled)
    }
}

/**
 * @brief 创建系统光标
 * @param id 光标类型（SDL_SystemCursor）
 * @return SDL_Cursor 光标指针
 */
public func SDL_CreateSystemCursor_cj(id: UInt32): SDL_Cursor {
    return unsafe {
        SDL_CreateSystemCursor(id)
    }
}

/**
 * @brief 设置当前光标
 * @param cursor 光标指针
 * @return Bool 成功返回 true
 */
public func SDL_SetCursor_cj(cursor: SDL_Cursor): Bool {
    return unsafe {
        SDL_SetCursor(cursor)
    }
}

/**
 * @brief 获取当前光标
 * @return SDL_Cursor 光标指针
 */
public func SDL_GetCursor_cj(): SDL_Cursor {
    return unsafe {
        SDL_GetCursor()
    }
}

/**
 * @brief 获取默认光标
 * @return SDL_Cursor 光标指针
 */
public func SDL_GetDefaultCursor_cj(): SDL_Cursor {
    return unsafe {
        SDL_GetDefaultCursor()
    }
}

/**
 * @brief 销毁光标
 * @param cursor 光标指针
 */
public func SDL_DestroyCursor_cj(cursor: SDL_Cursor): Unit {
    unsafe {
        SDL_DestroyCursor(cursor)
    }
}

/**
 * @brief 显示光标
 * @return Bool 成功返回 true
 */
public func SDL_ShowCursor_cj(): Bool {
    return unsafe {
        SDL_ShowCursor()
    }
}

/**
 * @brief 隐藏光标
 * @return Bool 成功返回 true
 */
public func SDL_HideCursor_cj(): Bool {
    return unsafe {
        SDL_HideCursor()
    }
}

/**
 * @brief 判断光标是否可见
 * @return Bool 可见返回 true
 */
public func SDL_CursorVisible_cj(): Bool {
    return unsafe {
        SDL_CursorVisible()
    }
}

// =============================================================================
// 触摸（SDL_touch.h）
// =============================================================================

/**
 * @brief 获取触摸设备 ID 数组
 * @param count 输出设备数量指针
 * @return CPointer<UInt64> 触摸设备 ID 数组（用完用 LibC.free 释放）
 */
public func SDL_GetTouchDevices_cj(count: CPointer<Int32>): CPointer<UInt64> {
    return unsafe {
        SDL_GetTouchDevices(count)
    }
}

/**
 * @brief 获取触摸设备名称
 * @param touchID 触摸设备 ID
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetTouchDeviceName_cj(touchID: UInt64): CString {
    return unsafe {
        SDL_GetTouchDeviceName(touchID)
    }
}

/**
 * @brief 获取触摸设备类型
 * @param touchID 触摸设备 ID
 * @return UInt32 触摸设备类型（SDL_TouchDeviceType）
 */
public func SDL_GetTouchDeviceType_cj(touchID: UInt64): UInt32 {
    return unsafe {
        SDL_GetTouchDeviceType(touchID)
    }
}

/**
 * @brief 获取触摸设备的手指数组
 * @param touchID 触摸设备 ID
 * @param count 输出手指数量指针
 * @return CPointer<CPointer<Unit>> 手指指针数组（用完用 LibC.free 释放）
 */
public func SDL_GetTouchFingers_cj(touchID: UInt64, count: CPointer<Int32>): CPointer<CPointer<Unit>> {
    return unsafe {
        SDL_GetTouchFingers(touchID, count)
    }
}

// =============================================================================
// 矩形（SDL_rect.h）
// @note SDL_PointInRect / SDL_RectEmpty / SDL_RectsEqual 在 C 端是头文件
//       内联函数，不可链接，因此这里以纯仓颉函数重新实现（逻辑一致）。
// =============================================================================

/**
 * @brief 判断点是否在矩形内（C 端为内联函数，此处纯仓颉实现）
 * @param p 点
 * @param r 矩形
 * @return Bool 在矩形内返回 true
 */
public func SDL_PointInRect_cj(p: SDL_Point, r: SDL_Rect): Bool {
    (p.x >= r.x) && (p.x < (r.x + r.w)) && (p.y >= r.y) && (p.y < (r.y + r.h))
}

/**
 * @brief 判断矩形是否为空（C 端为内联函数，此处纯仓颉实现）
 * @param r 矩形
 * @return Bool 为空返回 true
 */
public func SDL_RectEmpty_cj(r: SDL_Rect): Bool {
    (r.w <= 0) || (r.h <= 0)
}

/**
 * @brief 判断两个矩形是否相等（C 端为内联函数，此处纯仓颉实现）
 * @param a 矩形 A
 * @param b 矩形 B
 * @return Bool 相等返回 true
 */
public func SDL_RectsEqual_cj(a: SDL_Rect, b: SDL_Rect): Bool {
    (a.x == b.x) && (a.y == b.y) && (a.w == b.w) && (a.h == b.h)
}

/**
 * @brief 判断两个矩形是否相交
 * @param A 矩形 A 指针
 * @param B 矩形 B 指针
 * @return Bool 相交返回 true
 */
public func SDL_HasRectIntersection_cj(A: CPointer<SDL_Rect>, B: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_HasRectIntersection(A, B)
    }
}

/**
 * @brief 计算两个矩形的交集
 * @param A 矩形 A 指针
 * @param B 矩形 B 指针
 * @param result 输出交集矩形指针
 * @return Bool 有交集返回 true
 */
public func SDL_GetRectIntersection_cj(A: CPointer<SDL_Rect>, B: CPointer<SDL_Rect>, result: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_GetRectIntersection(A, B, result)
    }
}

/**
 * @brief 计算两个矩形的并集
 * @param A 矩形 A 指针
 * @param B 矩形 B 指针
 * @param result 输出并集矩形指针
 * @return Bool 成功返回 true
 */
public func SDL_GetRectUnion_cj(A: CPointer<SDL_Rect>, B: CPointer<SDL_Rect>, result: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_GetRectUnion(A, B, result)
    }
}

/**
 * @brief 计算包含所有点的最小矩形
 * @param points 点数组指针
 * @param count 点的数量
 * @param clip 裁剪矩形指针（可为 null）
 * @param result 输出矩形指针
 * @return Bool 成功返回 true
 */
public func SDL_GetRectEnclosingPoints_cj(points: CPointer<SDL_Point>, count: Int32, clip: CPointer<SDL_Rect>, result: CPointer<SDL_Rect>): Bool {
    return unsafe {
        SDL_GetRectEnclosingPoints(points, count, clip, result)
    }
}

// =============================================================================
// 像素格式（SDL_pixels.h）
// =============================================================================

/**
 * @brief 获取像素格式名称
 * @param format 像素格式（SDL_PixelFormat）
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetPixelFormatName_cj(format: UInt32): CString {
    return unsafe {
        SDL_GetPixelFormatName(format)
    }
}

/**
 * @brief 从掩码获取像素格式
 * @param bpp 每像素位数
 * @param Rmask 红色掩码
 * @param Gmask 绿色掩码
 * @param Bmask 蓝色掩码
 * @param Amask 透明度掩码
 * @return UInt32 像素格式（SDL_PixelFormat）
 */
public func SDL_GetPixelFormatForMasks_cj(bpp: Int32, Rmask: UInt32, Gmask: UInt32, Bmask: UInt32, Amask: UInt32): UInt32 {
    return unsafe {
        SDL_GetPixelFormatForMasks(bpp, Rmask, Gmask, Bmask, Amask)
    }
}

/**
 * @brief 获取像素格式详情
 * @param format 像素格式（SDL_PixelFormat）
 * @return SDL_PixelFormatDetails 像素格式详情指针
 */
public func SDL_GetPixelFormatDetails_cj(format: UInt32): SDL_PixelFormatDetails {
    return unsafe {
        SDL_GetPixelFormatDetails(format)
    }
}

/**
 * @brief 添加定时器（间隔触发回调）
 * @param interval 触发间隔（毫秒）
 * @param callback 回调函数指针（暂以 CPointer<Unit> 占位，可传 null）
 * @param userdata 回调上下文数据
 * @return SDL_TimerID 定时器 ID（0 表示失败）
 */
public func SDL_AddTimer_cj(interval: UInt32, callback: CPointer<Unit>, userdata: CPointer<Unit>): SDL_TimerID {
    return unsafe {
        SDL_AddTimer(interval, callback, userdata)
    }
}

/**
 * @brief 移除定时器
 * @param id 定时器 ID（SDL_AddTimer 返回值）
 * @return Bool 成功返回 true
 */
public func SDL_RemoveTimer_cj(id: SDL_TimerID): Bool {
    return unsafe {
        SDL_RemoveTimer(id)
    }
}

/**
 * @brief 高精度延时（忙等）
 * @param ms 延时毫秒数
 */
public func SDL_DelayPrecise_cj(ms: UInt32): Unit {
    unsafe {
        SDL_DelayPrecise(ms)
    }
}

/**
 * @brief 设置日志输出回调函数
 * @param callback 回调函数指针（暂以 CPointer<Unit> 占位，可传 null）
 * @param userdata 回调上下文数据
 */
public func SDL_SetLogOutputFunction_cj(callback: CPointer<Unit>, userdata: CPointer<Unit>): Unit {
    unsafe {
        SDL_SetLogOutputFunction(callback, userdata)
    }
}

/**
 * @brief 获取日志输出回调函数
 * @param callback 输出参数：回调函数指针
 * @param userdata 输出参数：回调上下文数据
 */
public func SDL_GetLogOutputFunction_cj(callback: CPointer<CPointer<Unit>>, userdata: CPointer<CPointer<Unit>>): Unit {
    unsafe {
        SDL_GetLogOutputFunction(callback, userdata)
    }
}

/**
 * @brief 添加事件监视回调（事件入队时触发）
 * @param filter 事件过滤器函数指针（暂以 CPointer<Unit> 占位，可传 null）
 * @param userdata 回调上下文数据
 * @return Bool 成功返回 true
 */
public func SDL_AddEventWatch_cj(filter: CPointer<Unit>, userdata: CPointer<Unit>): Bool {
    return unsafe {
        SDL_AddEventWatch(filter, userdata)
    }
}

/**
 * @brief 移除事件监视回调
 * @param filter 事件过滤器函数指针（须与 SDL_AddEventWatch 一致）
 * @param userdata 回调上下文数据（须与 SDL_AddEventWatch 一致）
 */
public func SDL_RemoveEventWatch_cj(filter: CPointer<Unit>, userdata: CPointer<Unit>): Unit {
    unsafe {
        SDL_RemoveEventWatch(filter, userdata)
    }
}

/**
 * @brief 查询指定事件类型是否启用
 * @param `type` 事件类型（SDL_EVENT_*）
 * @return Bool 是否启用
 */
public func SDL_EventEnabled_cj(`type`: UInt32): Bool {
    return unsafe {
        SDL_EventEnabled(`type`)
    }
}

/**
 * @brief 启用或禁用指定事件类型
 * @param `type` 事件类型（SDL_EVENT_*）
 * @param enabled 是否启用
 * @return Bool 成功返回 true
 */
public func SDL_SetEventEnabled_cj(`type`: UInt32, enabled: Bool): Bool {
    return unsafe {
        SDL_SetEventEnabled(`type`, enabled)
    }
}

/**
 * @brief 根据键盘实例 ID 获取键盘名称
 * @param instance_id 键盘实例 ID
 * @return CString 键盘名称（UTF-8）
 */
public func SDL_GetKeyboardNameForID_cj(instance_id: UInt32): CString {
    return unsafe {
        SDL_GetKeyboardNameForID(instance_id)
    }
}

/**
 * @brief 枚举所有键盘
 * @param count 输出参数：键盘数量
 * @return CPointer<UInt32> 键盘 ID 数组（调用方需释放）
 */
public func SDL_GetKeyboards_cj(count: CPointer<Int32>): CPointer<UInt32> {
    return unsafe {
        SDL_GetKeyboards(count)
    }
}

/**
 * @brief 获取文本输入区域（IME 位置）
 * @param window 窗口指针
 * @param rect 输出参数：输入区域矩形
 * @param cursor 输出参数：光标位置
 * @return Bool 成功返回 true
 */
public func SDL_GetTextInputArea_cj(window: SDL_Window, rect: CPointer<SDL_Rect>, cursor: CPointer<Int32>): Bool {
    return unsafe {
        SDL_GetTextInputArea(window, rect, cursor)
    }
}

/**
 * @brief 设置文本输入区域（IME 位置）
 * @param window 窗口指针
 * @param rect 输入区域矩形
 * @param cursor 光标位置
 * @return Bool 成功返回 true
 */
public func SDL_SetTextInputArea_cj(window: SDL_Window, rect: CPointer<SDL_Rect>, cursor: Int32): Bool {
    return unsafe {
        SDL_SetTextInputArea(window, rect, cursor)
    }
}

/**
 * @brief 查询当前平台是否支持屏幕键盘
 * @return Bool 是否支持
 */
public func SDL_HasScreenKeyboardSupport_cj(): Bool {
    return unsafe {
        SDL_HasScreenKeyboardSupport()
    }
}

/**
 * @brief 清除窗口的 IME 组合输入状态
 * @param window 窗口指针
 * @return Bool 成功返回 true
 */
public func SDL_ClearComposition_cj(window: SDL_Window): Bool {
    return unsafe {
        SDL_ClearComposition(window)
    }
}

/**
 * @brief 从位图数据创建系统光标
 * @param data 光标位图数据（1 位）
 * @param mask 光标掩码数据（1 位）
 * @param w 光标宽度
 * @param h 光标高度
 * @param hot_x 热点 X 坐标
 * @param hot_y 热点 Y 坐标
 * @return SDL_Cursor 光标指针（null 表示失败）
 */
public func SDL_CreateCursor_cj(data: CPointer<UInt8>, mask: CPointer<UInt8>, w: Int32, h: Int32, hot_x: Int32, hot_y: Int32): SDL_Cursor {
    return unsafe {
        SDL_CreateCursor(data, mask, w, h, hot_x, hot_y)
    }
}

/**
 * @brief 从表面创建彩色光标
 * @param surface 光标图像表面
 * @param hot_x 热点 X 坐标
 * @param hot_y 热点 Y 坐标
 * @return SDL_Cursor 光标指针（null 表示失败）
 */
public func SDL_CreateColorCursor_cj(surface: SDL_Surface, hot_x: Int32, hot_y: Int32): SDL_Cursor {
    return unsafe {
        SDL_CreateColorCursor(surface, hot_x, hot_y)
    }
}

/**
 * @brief 从帧序列创建动画光标
 * @param frames 帧表面数组
 * @param durations 每帧持续毫秒数组
 * @param num_frames 帧数
 * @param hot_x 热点 X 坐标
 * @param hot_y 热点 Y 坐标
 * @return SDL_Cursor 光标指针（null 表示失败）
 */
public func SDL_CreateAnimatedCursor_cj(frames: CPointer<SDL_Surface>, durations: CPointer<Int32>, num_frames: Int32, hot_x: Int32, hot_y: Int32): SDL_Cursor {
    return unsafe {
        SDL_CreateAnimatedCursor(frames, durations, num_frames, hot_x, hot_y)
    }
}
