/**
 * @file sdl4cj 系统信息 CFFI 函数声明
 * @brief SDL3 CPU 信息 / 电源 / 剪贴板 / 消息框 / 文件系统 / 杂项 / GUID / 时间 模块
 * @explain 本文件包含上述模块的 foreign 函数声明（包级私有）。
 *         外部调用请使用 `ffi_system_exports.cj` 中的 `_cj` 包装。
 * @note 枚举参数/返回值使用 UInt32 底层表示。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// CPU 信息（SDL_cpuinfo.h）
// =============================================================================

@FastNative
foreign func SDL_GetNumLogicalCPUCores(): Int32
@FastNative
foreign func SDL_GetCPUCacheLineSize(): Int32
@FastNative
foreign func SDL_HasAltiVec(): Bool
@FastNative
foreign func SDL_HasMMX(): Bool
@FastNative
foreign func SDL_HasSSE(): Bool
@FastNative
foreign func SDL_HasSSE2(): Bool
@FastNative
foreign func SDL_HasSSE3(): Bool
@FastNative
foreign func SDL_HasSSE41(): Bool
@FastNative
foreign func SDL_HasSSE42(): Bool
@FastNative
foreign func SDL_HasAVX(): Bool
@FastNative
foreign func SDL_HasAVX2(): Bool
@FastNative
foreign func SDL_HasAVX512F(): Bool
@FastNative
foreign func SDL_HasARMSIMD(): Bool
@FastNative
foreign func SDL_HasNEON(): Bool
@FastNative
foreign func SDL_HasSVE2(): Bool
@FastNative
foreign func SDL_HasLSX(): Bool
@FastNative
foreign func SDL_HasLASX(): Bool
@FastNative
foreign func SDL_GetSystemRAM(): Int32
@FastNative
foreign func SDL_GetSIMDAlignment(): UIntNative
@FastNative
foreign func SDL_GetSystemPageSize(): Int32

// =============================================================================
// 电源（SDL_power.h）
// =============================================================================

@FastNative
foreign func SDL_GetPowerInfo(seconds: CPointer<Int32>, percent: CPointer<Int32>): UInt32

// =============================================================================
// 剪贴板（SDL_clipboard.h）
// =============================================================================

@FastNative
foreign func SDL_SetClipboardText(text: CString): Bool
@FastNative
foreign func SDL_GetClipboardText(): CString
@FastNative
foreign func SDL_HasClipboardText(): Bool
@FastNative
foreign func SDL_SetPrimarySelectionText(text: CString): Bool
@FastNative
foreign func SDL_GetPrimarySelectionText(): CString
@FastNative
foreign func SDL_HasPrimarySelectionText(): Bool

// =============================================================================
// 消息框（SDL_messagebox.h）
// =============================================================================

foreign func SDL_ShowSimpleMessageBox(flags: UInt32, title: CString, message: CString, window: SDL_Window): Bool

// =============================================================================
// 文件系统（SDL_filesystem.h）
// =============================================================================

@FastNative
foreign func SDL_GetBasePath(): CString
@FastNative
foreign func SDL_GetPrefPath(org: CString, app: CString): CString
@FastNative
foreign func SDL_GetUserFolder(folder: UInt32): CString
@FastNative
foreign func SDL_CreateDirectory(path: CString): Bool
@FastNative
foreign func SDL_RemovePath(path: CString): Bool
@FastNative
foreign func SDL_RenamePath(oldpath: CString, newpath: CString): Bool
@FastNative
foreign func SDL_CopyFile(oldpath: CString, newpath: CString): Bool

// =============================================================================
// 杂项（SDL_misc.h）
// =============================================================================

@FastNative
foreign func SDL_OpenURL(url: CString): Bool

// =============================================================================
// GUID（SDL_guid.h）
// =============================================================================

@FastNative
foreign func SDL_GUIDToString(guid: SDL_GUID, pszGUID: CPointer<UInt8>, cbGUID: Int32): Unit
@FastNative
foreign func SDL_StringToGUID(pchGUID: CString): SDL_GUID

// =============================================================================
// 时间（SDL_time.h）
// =============================================================================

@FastNative
foreign func SDL_GetDaysInMonth(year: Int32, month: Int32): Int32
@FastNative
foreign func SDL_GetDayOfYear(year: Int32, month: Int32, day: Int32): Int32
@FastNative
foreign func SDL_GetDayOfWeek(year: Int32, month: Int32, day: Int32): Int32
