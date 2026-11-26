/**
 * @file sdl4cj 系统信息公共函数包装
 * @brief SDL3 CPU / 电源 / 剪贴板 / 消息框 / 文件系统 / 杂项 / GUID / 时间 的仓颉安全包装
 * @explain 本文件为系统信息模块的每个 foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中。
 * @note 字符串参数使用 CString，返回 CString 的可调用 `.toString()` 转 String。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// CPU 信息（SDL_cpuinfo.h）
// =============================================================================

/**
 * @brief 获取逻辑 CPU 核心数
 * @return Int32 逻辑 CPU 核心数
 */
public func SDL_GetNumLogicalCPUCores_cj(): Int32 {
    return unsafe {
        SDL_GetNumLogicalCPUCores()
    }
}

/**
 * @brief 获取 CPU 缓存行大小
 * @return Int32 缓存行大小（字节）
 */
public func SDL_GetCPUCacheLineSize_cj(): Int32 {
    return unsafe {
        SDL_GetCPUCacheLineSize()
    }
}

/**
 * @brief 判断 CPU 是否支持 AltiVec
 * @return Bool 支持返回 true
 */
public func SDL_HasAltiVec_cj(): Bool {
    return unsafe {
        SDL_HasAltiVec()
    }
}

/**
 * @brief 判断 CPU 是否支持 MMX
 * @return Bool 支持返回 true
 */
public func SDL_HasMMX_cj(): Bool {
    return unsafe {
        SDL_HasMMX()
    }
}

/**
 * @brief 判断 CPU 是否支持 SSE
 * @return Bool 支持返回 true
 */
public func SDL_HasSSE_cj(): Bool {
    return unsafe {
        SDL_HasSSE()
    }
}

/**
 * @brief 判断 CPU 是否支持 SSE2
 * @return Bool 支持返回 true
 */
public func SDL_HasSSE2_cj(): Bool {
    return unsafe {
        SDL_HasSSE2()
    }
}

/**
 * @brief 判断 CPU 是否支持 SSE3
 * @return Bool 支持返回 true
 */
public func SDL_HasSSE3_cj(): Bool {
    return unsafe {
        SDL_HasSSE3()
    }
}

/**
 * @brief 判断 CPU 是否支持 SSE4.1
 * @return Bool 支持返回 true
 */
public func SDL_HasSSE41_cj(): Bool {
    return unsafe {
        SDL_HasSSE41()
    }
}

/**
 * @brief 判断 CPU 是否支持 SSE4.2
 * @return Bool 支持返回 true
 */
public func SDL_HasSSE42_cj(): Bool {
    return unsafe {
        SDL_HasSSE42()
    }
}

/**
 * @brief 判断 CPU 是否支持 AVX
 * @return Bool 支持返回 true
 */
public func SDL_HasAVX_cj(): Bool {
    return unsafe {
        SDL_HasAVX()
    }
}

/**
 * @brief 判断 CPU 是否支持 AVX2
 * @return Bool 支持返回 true
 */
public func SDL_HasAVX2_cj(): Bool {
    return unsafe {
        SDL_HasAVX2()
    }
}

/**
 * @brief 判断 CPU 是否支持 AVX-512F
 * @return Bool 支持返回 true
 */
public func SDL_HasAVX512F_cj(): Bool {
    return unsafe {
        SDL_HasAVX512F()
    }
}

/**
 * @brief 判断 CPU 是否支持 ARM SIMD
 * @return Bool 支持返回 true
 */
public func SDL_HasARMSIMD_cj(): Bool {
    return unsafe {
        SDL_HasARMSIMD()
    }
}

/**
 * @brief 判断 CPU 是否支持 NEON
 * @return Bool 支持返回 true
 */
public func SDL_HasNEON_cj(): Bool {
    return unsafe {
        SDL_HasNEON()
    }
}

/**
 * @brief 判断 CPU 是否支持 SVE2
 * @return Bool 支持返回 true
 */
public func SDL_HasSVE2_cj(): Bool {
    return unsafe {
        SDL_HasSVE2()
    }
}

/**
 * @brief 判断 CPU 是否支持 LSX（龙芯）
 * @return Bool 支持返回 true
 */
public func SDL_HasLSX_cj(): Bool {
    return unsafe {
        SDL_HasLSX()
    }
}

/**
 * @brief 判断 CPU 是否支持 LASX（龙芯）
 * @return Bool 支持返回 true
 */
public func SDL_HasLASX_cj(): Bool {
    return unsafe {
        SDL_HasLASX()
    }
}

/**
 * @brief 获取系统内存大小
 * @return Int32 内存大小（MB）
 */
public func SDL_GetSystemRAM_cj(): Int32 {
    return unsafe {
        SDL_GetSystemRAM()
    }
}

/**
 * @brief 获取 SIMD 对齐要求
 * @return UIntNative 对齐字节数
 */
public func SDL_GetSIMDAlignment_cj(): UIntNative {
    return unsafe {
        SDL_GetSIMDAlignment()
    }
}

/**
 * @brief 获取系统页大小
 * @return Int32 页大小（字节）
 */
public func SDL_GetSystemPageSize_cj(): Int32 {
    return unsafe {
        SDL_GetSystemPageSize()
    }
}

// =============================================================================
// 电源（SDL_power.h）
// =============================================================================

/**
 * @brief 获取电源状态
 * @param seconds 输出剩余秒数指针（-1 表示未知）
 * @param percent 输出电量百分比指针（-1 表示未知）
 * @return UInt32 电源状态（SDL_PowerState）
 */
public func SDL_GetPowerInfo_cj(seconds: CPointer<Int32>, percent: CPointer<Int32>): UInt32 {
    return unsafe {
        SDL_GetPowerInfo(seconds, percent)
    }
}

// =============================================================================
// 剪贴板（SDL_clipboard.h）
// =============================================================================

/**
 * @brief 设置剪贴板文本
 * @param text 文本内容
 * @return Bool 成功返回 true
 */
public func SDL_SetClipboardText_cj(text: CString): Bool {
    return unsafe {
        SDL_SetClipboardText(text)
    }
}

/**
 * @brief 获取剪贴板文本
 * @return CString 文本内容（可用 .toString() 转 String，用完用 LibC.free 释放）
 */
public func SDL_GetClipboardText_cj(): CString {
    return unsafe {
        SDL_GetClipboardText()
    }
}

/**
 * @brief 判断剪贴板是否有文本
 * @return Bool 有文本返回 true
 */
public func SDL_HasClipboardText_cj(): Bool {
    return unsafe {
        SDL_HasClipboardText()
    }
}

/**
 * @brief 设置主选择区文本（X11）
 * @param text 文本内容
 * @return Bool 成功返回 true
 */
public func SDL_SetPrimarySelectionText_cj(text: CString): Bool {
    return unsafe {
        SDL_SetPrimarySelectionText(text)
    }
}

/**
 * @brief 获取主选择区文本（X11）
 * @return CString 文本内容（可用 .toString() 转 String，用完用 LibC.free 释放）
 */
public func SDL_GetPrimarySelectionText_cj(): CString {
    return unsafe {
        SDL_GetPrimarySelectionText()
    }
}

/**
 * @brief 判断主选择区是否有文本（X11）
 * @return Bool 有文本返回 true
 */
public func SDL_HasPrimarySelectionText_cj(): Bool {
    return unsafe {
        SDL_HasPrimarySelectionText()
    }
}

// =============================================================================
// 消息框（SDL_messagebox.h）
// =============================================================================

/**
 * @brief 显示简单消息框
 * @param flags 消息框标志（SDL_MESSAGEBOX_*，传 0 为普通信息框）
 * @param title 标题
 * @param message 消息内容
 * @param window 父窗口（可为 null）
 * @return Bool 成功返回 true
 */
public func SDL_ShowSimpleMessageBox_cj(flags: UInt32, title: CString, message: CString, window: SDL_Window): Bool {
    return unsafe {
        SDL_ShowSimpleMessageBox(flags, title, message, window)
    }
}

// =============================================================================
// 文件系统（SDL_filesystem.h）
// =============================================================================

/**
 * @brief 获取应用基路径
 * @return CString 路径（可用 .toString() 转 String，用完用 LibC.free 释放）
 */
public func SDL_GetBasePath_cj(): CString {
    return unsafe {
        SDL_GetBasePath()
    }
}

/**
 * @brief 获取应用偏好路径
 * @param org 组织名
 * @param app 应用名
 * @return CString 路径（可用 .toString() 转 String，用完用 LibC.free 释放）
 */
public func SDL_GetPrefPath_cj(org: CString, app: CString): CString {
    return unsafe {
        SDL_GetPrefPath(org, app)
    }
}

/**
 * @brief 获取用户文件夹路径
 * @param folder 文件夹类型（SDL_Folder）
 * @return CString 路径（可用 .toString() 转 String）
 */
public func SDL_GetUserFolder_cj(folder: UInt32): CString {
    return unsafe {
        SDL_GetUserFolder(folder)
    }
}

/**
 * @brief 创建目录
 * @param path 目录路径
 * @return Bool 成功返回 true
 */
public func SDL_CreateDirectory_cj(path: CString): Bool {
    return unsafe {
        SDL_CreateDirectory(path)
    }
}

/**
 * @brief 删除文件或目录
 * @param path 路径
 * @return Bool 成功返回 true
 */
public func SDL_RemovePath_cj(path: CString): Bool {
    return unsafe {
        SDL_RemovePath(path)
    }
}

/**
 * @brief 重命名文件或目录
 * @param oldpath 原路径
 * @param newpath 新路径
 * @return Bool 成功返回 true
 */
public func SDL_RenamePath_cj(oldpath: CString, newpath: CString): Bool {
    return unsafe {
        SDL_RenamePath(oldpath, newpath)
    }
}

/**
 * @brief 复制文件
 * @param oldpath 源路径
 * @param newpath 目标路径
 * @return Bool 成功返回 true
 */
public func SDL_CopyFile_cj(oldpath: CString, newpath: CString): Bool {
    return unsafe {
        SDL_CopyFile(oldpath, newpath)
    }
}

// =============================================================================
// 杂项（SDL_misc.h）
// =============================================================================

/**
 * @brief 打开 URL（系统默认浏览器）
 * @param url URL 地址
 * @return Bool 成功返回 true
 */
public func SDL_OpenURL_cj(url: CString): Bool {
    return unsafe {
        SDL_OpenURL(url)
    }
}

// =============================================================================
// GUID（SDL_guid.h）
// =============================================================================

/**
 * @brief 将 GUID 转为字符串
 * @param guid GUID
 * @param pszGUID 输出字符串缓冲指针
 * @param cbGUID 缓冲大小（至少 33 字节）
 */
public func SDL_GUIDToString_cj(guid: SDL_GUID, pszGUID: CPointer<UInt8>, cbGUID: Int32): Unit {
    unsafe {
        SDL_GUIDToString(guid, pszGUID, cbGUID)
    }
}

/**
 * @brief 从字符串解析 GUID
 * @param pchGUID 字符串
 * @return SDL_GUID 解析结果
 */
public func SDL_StringToGUID_cj(pchGUID: CString): SDL_GUID {
    return unsafe {
        SDL_StringToGUID(pchGUID)
    }
}

// =============================================================================
// 时间（SDL_time.h）
// =============================================================================

/**
 * @brief 获取指定月份的天数
 * @param year 年份
 * @param month 月份（1-12）
 * @return Int32 天数（无效输入返回 -1）
 */
public func SDL_GetDaysInMonth_cj(year: Int32, month: Int32): Int32 {
    return unsafe {
        SDL_GetDaysInMonth(year, month)
    }
}

/**
 * @brief 获取指定日期在一年中的第几天
 * @param year 年份
 * @param month 月份（1-12）
 * @param day 日（1-31）
 * @return Int32 一年中的第几天（1-366，无效输入返回 -1）
 */
public func SDL_GetDayOfYear_cj(year: Int32, month: Int32, day: Int32): Int32 {
    return unsafe {
        SDL_GetDayOfYear(year, month, day)
    }
}

/**
 * @brief 获取指定日期是星期几
 * @param year 年份
 * @param month 月份（1-12）
 * @param day 日（1-31）
 * @return Int32 星期几（0=周日，1=周一，...，无效输入返回 -1）
 */
public func SDL_GetDayOfWeek_cj(year: Int32, month: Int32, day: Int32): Int32 {
    return unsafe {
        SDL_GetDayOfWeek(year, month, day)
    }
}
