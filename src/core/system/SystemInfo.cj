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
 * @file[zh-cn] SystemInfo
 * @brief[zh-cn] 系统信息：CPU / 电源 / 剪贴板 / 消息框 / 文件系统 / 杂项 / 日期 查询
 * @explain[zh-cn] 基于 sdl4cj 库做高级封装（对应 SDL_cpuinfo / SDL_power / SDL_clipboard / SDL_messagebox / SDL_filesystem / SDL_misc / SDL_time）。全部为静态方法，无需实例化；部分查询（剪贴板/文件系统）无需窗口即可使用。
 *
 * @file[en] SystemInfo
 * @brief[en] System information: CPU / power / clipboard / message box / file system / misc / date queries
 * @explain[en] High-level wrapper based on the sdl4cj library (corresponding to SDL_cpuinfo / SDL_power / SDL_clipboard / SDL_messagebox / SDL_filesystem / SDL_misc / SDL_time). All methods are static, no instantiation needed; some queries (clipboard/file system) work without a window.
 */
package three.core.system

import std.core.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 电源状态枚举
 *
 * @brief[en] Power state enumeration
 */
public enum PowerState {
    /**
     * @brief[zh-cn] 无法确定电源状态（C 端为 -1）
     *
     * @brief[en] Unable to determine power state (-1 on the C side)
     */
    | Error
    /**
     * @brief[zh-cn] 无法确定电源状态
     *
     * @brief[en] Unable to determine power state
     */
    | Unknown
    /**
     * @brief[zh-cn] 未插电，使用电池
     *
     * @brief[en] Not plugged in, running on battery
     */
    | OnBattery
    /**
     * @brief[zh-cn] 已插电，无电池
     *
     * @brief[en] Plugged in, no battery
     */
    | NoBattery
    /**
     * @brief[zh-cn] 已插电，充电中
     *
     * @brief[en] Plugged in, charging
     */
    | Charging
    /**
     * @brief[zh-cn] 已插电，电池已充满
     *
     * @brief[en] Plugged in, battery fully charged
     */
    | Charged

    /**
     * @brief[zh-cn] 转换为 UInt32（Error 为 -1 的补码）
     * @return[zh-cn] 枚举值对应的 UInt32
     *
     * @brief[en] Convert to UInt32 (Error is the two's complement of -1)
     * @return[en] UInt32 value corresponding to the enumeration
     */
    public func value(): UInt32 {
        match (this) {
            case Error => 0xFFFFFFFF
            case Unknown => 0
            case OnBattery => 1
            case NoBattery => 2
            case Charging => 3
            case Charged => 4
        }
    }

    /**
     * @brief[zh-cn] 从 UInt32 转换回枚举值
     * @param[zh-cn] v UInt32 值
     * @return[zh-cn] 对应的 PowerState 枚举值
     *
     * @brief[en] Convert from UInt32 back to enumeration value
     * @param[en] v UInt32 value
     * @return[en] Corresponding PowerState enumeration value
     */
    public static func fromValue(v: UInt32): PowerState {
        match (v) {
            case 0 => Unknown
            case 1 => OnBattery
            case 2 => NoBattery
            case 3 => Charging
            case 4 => Charged
            case _ => Error
        }
    }
}

/**
 * @brief[zh-cn] 用户文件夹类型枚举（对应 SDL_GetUserFolder 可查询的文件夹）
 *
 * @brief[en] User folder type enumeration (corresponding to folders queryable by SDL_GetUserFolder)
 */
public enum Folder {
    /**
     * @brief[zh-cn] 主目录
     *
     * @brief[en] Home directory
     */
    | Home
    /**
     * @brief[zh-cn] 桌面
     *
     * @brief[en] Desktop
     */
    | Desktop
    /**
     * @brief[zh-cn] 文档
     *
     * @brief[en] Documents
     */
    | Documents
    /**
     * @brief[zh-cn] 下载
     *
     * @brief[en] Downloads
     */
    | Downloads
    /**
     * @brief[zh-cn] 音乐
     *
     * @brief[en] Music
     */
    | Music
    /**
     * @brief[zh-cn] 图片
     *
     * @brief[en] Pictures
     */
    | Pictures
    /**
     * @brief[zh-cn] 公共共享目录
     *
     * @brief[en] Public share directory
     */
    | PublicShare
    /**
     * @brief[zh-cn] 保存游戏目录
     *
     * @brief[en] Saved games directory
     */
    | SavedGames
    /**
     * @brief[zh-cn] 截图目录
     *
     * @brief[en] Screenshots directory
     */
    | Screenshots
    /**
     * @brief[zh-cn] 模板目录
     *
     * @brief[en] Templates directory
     */
    | Templates
    /**
     * @brief[zh-cn] 视频目录
     *
     * @brief[en] Videos directory
     */
    | Videos

    /**
     * @brief[zh-cn] 转换为 UInt32
     * @return[zh-cn] 枚举值对应的 UInt32
     *
     * @brief[en] Convert to UInt32
     * @return[en] UInt32 value corresponding to the enumeration
     */
    public func value(): UInt32 {
        match (this) {
            case Home => 0
            case Desktop => 1
            case Documents => 2
            case Downloads => 3
            case Music => 4
            case Pictures => 5
            case PublicShare => 6
            case SavedGames => 7
            case Screenshots => 8
            case Templates => 9
            case Videos => 10
        }
    }

    /**
     * @brief[zh-cn] 从 UInt32 转换回枚举值
     * @param[zh-cn] v UInt32 值
     * @return[zh-cn] 对应的 Folder 枚举值
     *
     * @brief[en] Convert from UInt32 back to enumeration value
     * @param[en] v UInt32 value
     * @return[en] Corresponding Folder enumeration value
     */
    public static func fromValue(v: UInt32): Folder {
        match (v) {
            case 0 => Home
            case 1 => Desktop
            case 2 => Documents
            case 3 => Downloads
            case 4 => Music
            case 5 => Pictures
            case 6 => PublicShare
            case 7 => SavedGames
            case 8 => Screenshots
            case 9 => Templates
            case 10 => Videos
            case _ => Home
        }
    }
}

/**
 * @brief[zh-cn] 系统信息查询工具（静态方法）
 * @explain[zh-cn] 基于 sdl4cj 库做高级封装（对应 SDL_cpuinfo / SDL_power / SDL_clipboard / SDL_messagebox / SDL_filesystem / SDL_misc / SDL_time）。全部为静态方法，无需实例化。
 *
 * @brief[en] System information query utility (static methods)
 * @explain[en] High-level wrapper based on the sdl4cj library (corresponding to SDL_cpuinfo / SDL_power / SDL_clipboard / SDL_messagebox / SDL_filesystem / SDL_misc / SDL_time). All methods are static, no instantiation needed.
 */
public class SystemInfo {
    // =========================================================================
    // CPU（SDL_cpuinfo.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取逻辑 CPU 核心数
     * @return[zh-cn] 逻辑 CPU 核心数
     *
     * @brief[en] Get the number of logical CPU cores
     * @return[en] Number of logical CPU cores
     */
    public static func getNumLogicalCPUCores(): Int32 {
        return SDL_GetNumLogicalCPUCores_cj()
    }

    /**
     * @brief[zh-cn] 获取 CPU 缓存行大小（字节）
     * @return[zh-cn] CPU 缓存行大小（字节）
     *
     * @brief[en] Get CPU cache line size in bytes
     * @return[en] CPU cache line size in bytes
     */
    public static func getCPUCacheLineSize(): Int32 {
        return SDL_GetCPUCacheLineSize_cj()
    }

    /**
     * @brief[zh-cn] 获取系统内存大小（MB）
     * @return[zh-cn] 系统内存大小（MB）
     *
     * @brief[en] Get system RAM size in MB
     * @return[en] System RAM size in MB
     */
    public static func getSystemRAM(): Int32 {
        return SDL_GetSystemRAM_cj()
    }

    /**
     * @brief[zh-cn] 获取 SIMD 对齐要求（字节）
     * @return[zh-cn] SIMD 对齐要求（字节）
     *
     * @brief[en] Get SIMD alignment requirement in bytes
     * @return[en] SIMD alignment requirement in bytes
     */
    public static func getSIMDAlignment(): UIntNative {
        return SDL_GetSIMDAlignment_cj()
    }

    /**
     * @brief[zh-cn] 获取系统页大小（字节）
     * @return[zh-cn] 系统页大小（字节）
     *
     * @brief[en] Get system page size in bytes
     * @return[en] System page size in bytes
     */
    public static func getSystemPageSize(): Int32 {
        return SDL_GetSystemPageSize_cj()
    }

    /**
     * @brief[zh-cn] CPU 是否支持 AltiVec
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports AltiVec
     * @return[en] true if supported
     */
    public static func hasAltiVec(): Bool { return SDL_HasAltiVec_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 MMX
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports MMX
     * @return[en] true if supported
     */
    public static func hasMMX(): Bool { return SDL_HasMMX_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 SSE
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports SSE
     * @return[en] true if supported
     */
    public static func hasSSE(): Bool { return SDL_HasSSE_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 SSE2
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports SSE2
     * @return[en] true if supported
     */
    public static func hasSSE2(): Bool { return SDL_HasSSE2_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 SSE3
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports SSE3
     * @return[en] true if supported
     */
    public static func hasSSE3(): Bool { return SDL_HasSSE3_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 SSE4.1
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports SSE4.1
     * @return[en] true if supported
     */
    public static func hasSSE41(): Bool { return SDL_HasSSE41_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 SSE4.2
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports SSE4.2
     * @return[en] true if supported
     */
    public static func hasSSE42(): Bool { return SDL_HasSSE42_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 AVX
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports AVX
     * @return[en] true if supported
     */
    public static func hasAVX(): Bool { return SDL_HasAVX_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 AVX2
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports AVX2
     * @return[en] true if supported
     */
    public static func hasAVX2(): Bool { return SDL_HasAVX2_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 AVX-512F
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports AVX-512F
     * @return[en] true if supported
     */
    public static func hasAVX512F(): Bool { return SDL_HasAVX512F_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 ARM SIMD
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports ARM SIMD
     * @return[en] true if supported
     */
    public static func hasARMSIMD(): Bool { return SDL_HasARMSIMD_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 NEON
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports NEON
     * @return[en] true if supported
     */
    public static func hasNEON(): Bool { return SDL_HasNEON_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 SVE2
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports SVE2
     * @return[en] true if supported
     */
    public static func hasSVE2(): Bool { return SDL_HasSVE2_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 LSX（龙芯）
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports LSX (Loongson)
     * @return[en] true if supported
     */
    public static func hasLSX(): Bool { return SDL_HasLSX_cj() }

    /**
     * @brief[zh-cn] CPU 是否支持 LASX（龙芯）
     * @return[zh-cn] 支持返回 true
     *
     * @brief[en] Whether CPU supports LASX (Loongson)
     * @return[en] true if supported
     */
    public static func hasLASX(): Bool { return SDL_HasLASX_cj() }

    // =========================================================================
    // 电源（SDL_power.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取电源状态
     * @return[zh-cn] (电源状态, 剩余秒数, 电量百分比)，秒数和百分比为 -1 表示未知
     *
     * @brief[en] Get power status
     * @return[en] (power state, remaining seconds, battery percentage), -1 means unknown for seconds and percentage
     */
    public static func getPowerInfo(): (PowerState, Int32, Int32) {
        let secPtr = unsafe { LibC.malloc<Int32>() }
        let pctPtr = unsafe { LibC.malloc<Int32>() }
        unsafe { secPtr.write(-1); pctPtr.write(-1) }
        let state = SDL_GetPowerInfo_cj(secPtr, pctPtr)
        let seconds = unsafe { secPtr.read() }
        let percent = unsafe { pctPtr.read() }
        unsafe { LibC.free(secPtr); LibC.free(pctPtr) }
        return (PowerState.fromValue(state), seconds, percent)
    }

    // =========================================================================
    // 剪贴板（SDL_clipboard.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 设置剪贴板文本
     * @param[zh-cn] text 要设置的文本
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Set clipboard text
     * @param[en] text Text to set
     * @return[en] Whether successful
     */
    public static func setClipboardText(text: String): Bool {
        let cs = unsafe { LibC.mallocCString(text) }
        let ok = SDL_SetClipboardText_cj(cs)
        unsafe { LibC.free(cs) }
        return ok
    }

    /**
     * @brief[zh-cn] 获取剪贴板文本（无内容返回空串）
     * @return[zh-cn] 剪贴板文本
     *
     * @brief[en] Get clipboard text (returns empty string if no content)
     * @return[en] Clipboard text
     */
    public static func getClipboardText(): String {
        let cs = SDL_GetClipboardText_cj()
        return if (cs.isNull()) { "" } else { unsafe { cs.toString() } }
    }

    /**
     * @brief[zh-cn] 剪贴板是否包含文本
     * @return[zh-cn] 包含返回 true
     *
     * @brief[en] Whether clipboard contains text
     * @return[en] true if clipboard contains text
     */
    public static func hasClipboardText(): Bool {
        return SDL_HasClipboardText_cj()
    }

    // =========================================================================
    // 消息框（SDL_messagebox.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 显示简单消息框
     * @param[zh-cn] flags 消息框标志（SDL_MESSAGEBOX_*，传 0 为普通信息框）
     * title 标题
     * message 消息内容
     * window 父窗口句柄（可为 null）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Show a simple message box
     * @param[en] flags Message box flags (SDL_MESSAGEBOX_*, pass 0 for normal info box)
     * title Title
     * message Message content
     * window Parent window handle (can be null)
     * @return[en] Whether successful
     */
    public static func showSimpleMessageBox(flags: UInt32, title: String, message: String, window: SDL_Window): Bool {
        let titleCs = unsafe { LibC.mallocCString(title) }
        let msgCs = unsafe { LibC.mallocCString(message) }
        let ok = SDL_ShowSimpleMessageBox_cj(flags, titleCs, msgCs, window)
        unsafe { LibC.free(titleCs); LibC.free(msgCs) }
        return ok
    }

    // =========================================================================
    // 文件系统（SDL_filesystem.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取应用基路径（可执行文件所在目录，末尾带分隔符）
     * @return[zh-cn] 基路径字符串
     *
     * @brief[en] Get application base path (directory of the executable, with trailing separator)
     * @return[en] Base path string
     */
    public static func getBasePath(): String {
        let cs = SDL_GetBasePath_cj()
        return if (cs.isNull()) { "" } else { unsafe { cs.toString() } }
    }

    /**
     * @brief[zh-cn] 获取应用偏好路径（org/app 组成的目录，末尾带分隔符）
     * @param[zh-cn] org 组织名
     * app 应用名
     * @return[zh-cn] 偏好路径字符串
     *
     * @brief[en] Get application preference path (directory composed of org/app, with trailing separator)
     * @param[en] org Organization name
     * app Application name
     * @return[en] Preference path string
     */
    public static func getPrefPath(org: String, app: String): String {
        let orgCs = unsafe { LibC.mallocCString(org) }
        let appCs = unsafe { LibC.mallocCString(app) }
        let cs = SDL_GetPrefPath_cj(orgCs, appCs)
        unsafe { LibC.free(orgCs); LibC.free(appCs) }
        return if (cs.isNull()) { "" } else { unsafe { cs.toString() } }
    }

    /**
     * @brief[zh-cn] 获取用户文件夹路径
     * @param[zh-cn] folder 用户文件夹类型枚举
     * @return[zh-cn] 文件夹路径字符串
     *
     * @brief[en] Get user folder path
     * @param[en] folder User folder type enumeration
     * @return[en] Folder path string
     */
    public static func getUserFolder(folder: Folder): String {
        let cs = SDL_GetUserFolder_cj(folder.value())
        return if (cs.isNull()) { "" } else { unsafe { cs.toString() } }
    }

    /**
     * @brief[zh-cn] 创建目录（含父目录）
     * @param[zh-cn] path 目录路径
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Create directory (including parent directories)
     * @param[en] path Directory path
     * @return[en] Whether successful
     */
    public static func createDirectory(path: String): Bool {
        let cs = unsafe { LibC.mallocCString(path) }
        let ok = SDL_CreateDirectory_cj(cs)
        unsafe { LibC.free(cs) }
        return ok
    }

    /**
     * @brief[zh-cn] 删除文件或目录（目录需为空）
     * @param[zh-cn] path 路径
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Remove file or directory (directory must be empty)
     * @param[en] path Path
     * @return[en] Whether successful
     */
    public static func removePath(path: String): Bool {
        let cs = unsafe { LibC.mallocCString(path) }
        let ok = SDL_RemovePath_cj(cs)
        unsafe { LibC.free(cs) }
        return ok
    }

    /**
     * @brief[zh-cn] 重命名/移动文件或目录
     * @param[zh-cn] oldpath 原路径
     * newpath 新路径
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Rename/move file or directory
     * @param[en] oldpath Original path
     * newpath New path
     * @return[en] Whether successful
     */
    public static func renamePath(oldpath: String, newpath: String): Bool {
        let oldCs = unsafe { LibC.mallocCString(oldpath) }
        let newCs = unsafe { LibC.mallocCString(newpath) }
        let ok = SDL_RenamePath_cj(oldCs, newCs)
        unsafe { LibC.free(oldCs); LibC.free(newCs) }
        return ok
    }

    /**
     * @brief[zh-cn] 复制文件
     * @param[zh-cn] oldpath 源文件路径
     * newpath 目标文件路径
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Copy file
     * @param[en] oldpath Source file path
     * newpath Destination file path
     * @return[en] Whether successful
     */
    public static func copyFile(oldpath: String, newpath: String): Bool {
        let oldCs = unsafe { LibC.mallocCString(oldpath) }
        let newCs = unsafe { LibC.mallocCString(newpath) }
        let ok = SDL_CopyFile_cj(oldCs, newCs)
        unsafe { LibC.free(oldCs); LibC.free(newCs) }
        return ok
    }

    // =========================================================================
    // 杂项（SDL_misc.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 打开 URL（默认浏览器）
     * @param[zh-cn] url 要打开的 URL
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Open URL (default browser)
     * @param[en] url URL to open
     * @return[en] Whether successful
     */
    public static func openURL(url: String): Bool {
        let cs = unsafe { LibC.mallocCString(url) }
        let ok = SDL_OpenURL_cj(cs)
        unsafe { LibC.free(cs) }
        return ok
    }

    // =========================================================================
    // 日期（SDL_time.h）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取指定月份的天数
     * @param[zh-cn] year 年份
     * month 月份（1~12）
     * @return[zh-cn] 天数
     *
     * @brief[en] Get the number of days in the specified month
     * @param[en] year Year
     * month Month (1~12)
     * @return[en] Number of days
     */
    public static func getDaysInMonth(year: Int32, month: Int32): Int32 {
        return SDL_GetDaysInMonth_cj(year, month)
    }

    /**
     * @brief[zh-cn] 获取指定日期在一年中的第几天（1~366）
     * @param[zh-cn] year 年份
     * month 月份
     * day 日
     * @return[zh-cn] 一年中的第几天
     *
     * @brief[en] Get the day of the year for the specified date (1~366)
     * @param[en] year Year
     * month Month
     * day Day
     * @return[en] Day of the year
     */
    public static func getDayOfYear(year: Int32, month: Int32, day: Int32): Int32 {
        return SDL_GetDayOfYear_cj(year, month, day)
    }

    /**
     * @brief[zh-cn] 获取指定日期是星期几（0=周日，1=周一，...，6=周六）
     * @param[zh-cn] year 年份
     * month 月份
     * day 日
     * @return[zh-cn] 星期几（0=周日，6=周六）
     *
     * @brief[en] Get the day of the week for the specified date (0=Sunday, 1=Monday, ..., 6=Saturday)
     * @param[en] year Year
     * month Month
     * day Day
     * @return[en] Day of week (0=Sunday, 6=Saturday)
     */
    public static func getDayOfWeek(year: Int32, month: Int32, day: Int32): Int32 {
        return SDL_GetDayOfWeek_cj(year, month, day)
    }
}
