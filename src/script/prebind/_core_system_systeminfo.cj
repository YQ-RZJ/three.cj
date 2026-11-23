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
 * @file[zh-cn] core_system_systeminfo 系统信息工具 SystemInfo 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.system.SystemInfo 绑定为 Lua 命名空间 three.core.system.SystemInfo，
 * 并将枚举 PowerState / Folder 注册为常量命名空间（供 getPowerInfo/getUserFolder 传参）
 * @explain[zh-cn] SystemInfo 为纯静态类（无构造器），只注册 staticMethod 不安装 new：
 * CPU 信息（核心数/缓存行/内存/SIMD 对齐/页大小/指令集支持）、电源（getPowerInfo 以
 * [电源状态, 剩余秒, 电量百分比] 数组返回）、剪贴板、文件系统（路径/目录/文件操作）、
 * 杂项（openURL）与日期工具；Int32 返回值装箱为 Lua 整数，UIntNative 装箱为 Lua number。
 * showSimpleMessageBox 跳过：参数含 SDL_Window 原生句柄（无 Lua 通道）。PowerState /
 * Folder 枚举以 getter 式静态常量 + fromValue 暴露数值。
 *
 * @file[en] core_system_systeminfo  Lua binding of the system information utility SystemInfo
 * (three.script.prebind)
 * @brief[en] Binds three.core.system.SystemInfo as the Lua namespace three.core.system.SystemInfo,
 * and registers the enums PowerState / Folder as constant namespaces (for getPowerInfo /
 * getUserFolder arguments)
 * @explain[en] SystemInfo is a pure static class (no constructor); only staticMethods are
 * registered without `new`: CPU info (core count/cache line/RAM/SIMD alignment/page size/
 * feature flags), power (getPowerInfo returns [state, remainingSeconds, percent] as an
 * array), clipboard, file system (paths/dirs/files), misc (openURL) and date utilities;
 * Int32 results are boxed as Lua integers, UIntNative as Lua numbers. showSimpleMessageBox
 * is omitted: it takes an SDL_Window native handle (no Lua channel). PowerState / Folder are
 * exposed as getter-style static constants plus fromValue.
 */
package three.script.prebind

import three.core.system.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SystemInfo 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.core.system.SystemInfo）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SystemInfo (a pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.core.system.SystemInfo)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSystemInfo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.system.SystemInfo")
    // ===== CPU（SDL_cpuinfo.h） =====
    b.staticMethod("getNumLogicalCPUCores") {
        _ => [LuaValue.of(Int64(SystemInfo.getNumLogicalCPUCores()))]
    }
    b.staticMethod("getCPUCacheLineSize") {
        _ => [LuaValue.of(Int64(SystemInfo.getCPUCacheLineSize()))]
    }
    b.staticMethod("getSystemRAM") {
        _ => [LuaValue.of(Int64(SystemInfo.getSystemRAM()))]
    }
    b.staticMethod("getSIMDAlignment") {
        _ => [LuaValue.of(Float64(SystemInfo.getSIMDAlignment()))]
    }
    b.staticMethod("getSystemPageSize") {
        _ => [LuaValue.of(Int64(SystemInfo.getSystemPageSize()))]
    }
    b.staticMethod("hasAltiVec") {_ => [LuaValue.of(SystemInfo.hasAltiVec())]}
    b.staticMethod("hasMMX") {_ => [LuaValue.of(SystemInfo.hasMMX())]}
    b.staticMethod("hasSSE") {_ => [LuaValue.of(SystemInfo.hasSSE())]}
    b.staticMethod("hasSSE2") {_ => [LuaValue.of(SystemInfo.hasSSE2())]}
    b.staticMethod("hasSSE3") {_ => [LuaValue.of(SystemInfo.hasSSE3())]}
    b.staticMethod("hasSSE41") {_ => [LuaValue.of(SystemInfo.hasSSE41())]}
    b.staticMethod("hasSSE42") {_ => [LuaValue.of(SystemInfo.hasSSE42())]}
    b.staticMethod("hasAVX") {_ => [LuaValue.of(SystemInfo.hasAVX())]}
    b.staticMethod("hasAVX2") {_ => [LuaValue.of(SystemInfo.hasAVX2())]}
    b.staticMethod("hasAVX512F") {_ => [LuaValue.of(SystemInfo.hasAVX512F())]}
    b.staticMethod("hasARMSIMD") {_ => [LuaValue.of(SystemInfo.hasARMSIMD())]}
    b.staticMethod("hasNEON") {_ => [LuaValue.of(SystemInfo.hasNEON())]}
    b.staticMethod("hasSVE2") {_ => [LuaValue.of(SystemInfo.hasSVE2())]}
    b.staticMethod("hasLSX") {_ => [LuaValue.of(SystemInfo.hasLSX())]}
    b.staticMethod("hasLASX") {_ => [LuaValue.of(SystemInfo.hasLASX())]}
    // ===== 电源（SDL_power.h；返回 [状态, 剩余秒, 电量百分比]） =====
    b.staticMethod("getPowerInfo") {
        _ =>
            let (state, seconds, percent) = SystemInfo.getPowerInfo()
            [LuaValue.of(Int64(state.value())), LuaValue.of(Int64(seconds)), LuaValue.of(Int64(percent))]
    }
    // ===== 剪贴板（SDL_clipboard.h） =====
    b.staticMethod("setClipboardText") {
        args => [LuaValue.of(SystemInfo.setClipboardText(prebindStr(args, 0)))]
    }
    b.staticMethod("getClipboardText") {
        _ => [LuaValue.of(SystemInfo.getClipboardText())]
    }
    b.staticMethod("hasClipboardText") {
        _ => [LuaValue.of(SystemInfo.hasClipboardText())]
    }
    // ==== 文件系统（SDL_filesystem.h） ====
    b.staticMethod("getBasePath") {
        _ => [LuaValue.of(SystemInfo.getBasePath())]
    }
    b.staticMethod("getPrefPath") {
        args => [LuaValue.of(SystemInfo.getPrefPath(prebindStr(args, 0), prebindStr(args, 1)))]
    }
    b.staticMethod("getUserFolder") {
        args => [LuaValue.of(SystemInfo.getUserFolder(Folder.fromValue(UInt32(args[0].intValue()))))]
    }
    b.staticMethod("createDirectory") {
        args => [LuaValue.of(SystemInfo.createDirectory(prebindStr(args, 0)))]
    }
    b.staticMethod("removePath") {
        args => [LuaValue.of(SystemInfo.removePath(prebindStr(args, 0)))]
    }
    b.staticMethod("renamePath") {
        args => [LuaValue.of(SystemInfo.renamePath(prebindStr(args, 0), prebindStr(args, 1)))]
    }
    b.staticMethod("copyFile") {
        args => [LuaValue.of(SystemInfo.copyFile(prebindStr(args, 0), prebindStr(args, 1)))]
    }
    // ===== 杂项（SDL_misc.h） =====
    b.staticMethod("openURL") {
        args => [LuaValue.of(SystemInfo.openURL(prebindStr(args, 0)))]
    }
    // ===== 日期（SDL_time.h） =====
    b.staticMethod("getDaysInMonth") {
        args => [LuaValue.of(Int64(SystemInfo.getDaysInMonth(Int32(args[0].intValue()), Int32(args[1].intValue()))))]
    }
    b.staticMethod("getDayOfYear") {
        args => [LuaValue.of(
            Int64(SystemInfo.getDayOfYear(Int32(args[0].intValue()), Int32(args[1].intValue()),
                Int32(args[2].intValue()))))]
    }
    b.staticMethod("getDayOfWeek") {
        args => [LuaValue.of(
            Int64(SystemInfo.getDayOfWeek(Int32(args[0].intValue()), Int32(args[1].intValue()),
                Int32(args[2].intValue()))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PowerState 枚举的 Lua 绑定（常量命名空间，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.core.system.PowerState）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 常量值为 UInt32（经 Float64 装箱为 Lua number），与 getPowerInfo 返回的
 * 状态字段一致；fromValue 反向转换并返回其数值。
 *
 * @brief[en] Installs the Lua binding of the PowerState enum (constant namespace, no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at three.core.system.PowerState)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] Constant values are UInt32 (boxed as Lua numbers via Float64), matching the
 * state field returned by getPowerInfo; fromValue converts back and returns its value.
 */
public func installPowerState(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.system.PowerState")
    b.staticMethod("Error") {_ => [LuaValue.of(Float64(PowerState.Error.value()))]}
    b.staticMethod("Unknown") {_ => [LuaValue.of(Float64(PowerState.Unknown.value()))]}
    b.staticMethod("OnBattery") {_ => [LuaValue.of(Float64(PowerState.OnBattery.value()))]}
    b.staticMethod("NoBattery") {_ => [LuaValue.of(Float64(PowerState.NoBattery.value()))]}
    b.staticMethod("Charging") {_ => [LuaValue.of(Float64(PowerState.Charging.value()))]}
    b.staticMethod("Charged") {_ => [LuaValue.of(Float64(PowerState.Charged.value()))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(Float64(PowerState.fromValue(UInt32(args[0].intValue())).value()))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Folder 枚举的 Lua 绑定（常量命名空间，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.core.system.Folder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 常量为 UInt32（经 Float64 装箱为 Lua number），供
 * SystemInfo.getUserFolder 传参；fromValue 反向转换并返回其数值。
 *
 * @brief[en] Installs the Lua binding of the Folder enum (constant namespace, no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at three.core.system.Folder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] Constants are UInt32 (boxed as Lua numbers via Float64), for passing to
 * SystemInfo.getUserFolder; fromValue converts back and returns its value.
 */
public func installFolder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.system.Folder")
    b.staticMethod("Home") {_ => [LuaValue.of(Float64(Folder.Home.value()))]}
    b.staticMethod("Desktop") {_ => [LuaValue.of(Float64(Folder.Desktop.value()))]}
    b.staticMethod("Documents") {_ => [LuaValue.of(Float64(Folder.Documents.value()))]}
    b.staticMethod("Downloads") {_ => [LuaValue.of(Float64(Folder.Downloads.value()))]}
    b.staticMethod("Music") {_ => [LuaValue.of(Float64(Folder.Music.value()))]}
    b.staticMethod("Pictures") {_ => [LuaValue.of(Float64(Folder.Pictures.value()))]}
    b.staticMethod("PublicShare") {_ => [LuaValue.of(Float64(Folder.PublicShare.value()))]}
    b.staticMethod("SavedGames") {_ => [LuaValue.of(Float64(Folder.SavedGames.value()))]}
    b.staticMethod("Screenshots") {_ => [LuaValue.of(Float64(Folder.Screenshots.value()))]}
    b.staticMethod("Templates") {_ => [LuaValue.of(Float64(Folder.Templates.value()))]}
    b.staticMethod("Videos") {_ => [LuaValue.of(Float64(Folder.Videos.value()))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(Float64(Folder.fromValue(UInt32(args[0].intValue())).value()))]
    }
    b.install(vm)
}
