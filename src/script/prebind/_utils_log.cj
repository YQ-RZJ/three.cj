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
 * @file[zh-cn] utils_log 日志 Logger 与枚举 LogLevel 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.log.Logger 绑定为 Lua 命名空间 three.utils.log.Logger，
 * LogLevel 绑定为 three.utils.log.LogLevel
 * @explain[zh-cn] Logger 是纯静态工具类（无构造器，不安装 new）：分级日志
 * trace/debug/info/warn/error/warnOnce 接受字符串数组（Lua 侧传 table）；
 * setLevel 接收 LogLevel 的数值（0~5，经 fromValue 转回）；getLevel 返回数值。
 * LogLevel 枚举无 ctor/new，各变体以 staticMethod 返回其整数值（0~5），
 * fromValue 静态方法由数值转回枚举数值。setConsoleFunction/getConsoleFunction
 * 涉及 (String,String)->Unit 回调，跳过不绑。
 *
 * @file[en] utils_log  Lua binding of the Logger and the LogLevel enum (three.script.prebind)
 * @brief[en] Binds three.utils.log.Logger as the Lua namespace three.utils.log.Logger
 * and LogLevel as three.utils.log.LogLevel
 * @explain[en] Logger is a pure static utility class (no constructor, no `new`): the
 * level-based logs trace/debug/info/warn/error/warnOnce take a string array
 * (a Lua table); setLevel accepts a LogLevel number (0~5, converted back via
 * fromValue); getLevel returns the numeric value. The LogLevel enum has no
 * ctor/new; each variant is exposed as a staticMethod returning its integer
 * value (0~5) and fromValue converts a number back. setConsoleFunction /
 * getConsoleFunction take a (String,String)->Unit callback and are skipped.
 */
package three.script.prebind

import three.utils.log.Logger
import three.utils.log.LogLevel
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Logger 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.log.Logger）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Logger (a pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.log.Logger)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLogger(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.log.Logger")
    // ===== 等级控制 =====
    b.staticMethod("setLevel") {
        args =>
            Logger.setLevel(LogLevel.fromValue(UInt32(args[0].intValue())))
            []
    }
    b.staticMethod("getLevel") {
        _ => [LuaValue.of(Int64(Logger.getLevel().value()))]
    }
    // ===== 分级日志（字符串数组） =====
    b.staticMethod("trace") {
        args =>
            Logger.trace(args[0].toArrayString())
            []
    }
    b.staticMethod("debug") {
        args =>
            Logger.debug(args[0].toArrayString())
            []
    }
    b.staticMethod("info") {
        args =>
            Logger.info(args[0].toArrayString())
            []
    }
    b.staticMethod("warn") {
        args =>
            Logger.warn(args[0].toArrayString())
            []
    }
    b.staticMethod("error") {
        args =>
            Logger.error(args[0].toArrayString())
            []
    }
    b.staticMethod("warnOnce") {
        args =>
            Logger.warnOnce(args[0].toArrayString())
            []
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 LogLevel 枚举的 Lua 绑定（无 ctor/new，变体返回整数值）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.log.LogLevel）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the LogLevel enum (no ctor/new; variants return integer values)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.log.LogLevel)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLogLevel(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.log.LogLevel")
    b.staticMethod("Trace") {_ => [LuaValue.of(Int64(LogLevel.Trace.value()))]}
    b.staticMethod("Debug") {_ => [LuaValue.of(Int64(LogLevel.Debug.value()))]}
    b.staticMethod("Info") {_ => [LuaValue.of(Int64(LogLevel.Info.value()))]}
    b.staticMethod("Warn") {_ => [LuaValue.of(Int64(LogLevel.Warn.value()))]}
    b.staticMethod("Error") {_ => [LuaValue.of(Int64(LogLevel.Error.value()))]}
    b.staticMethod("Off") {_ => [LuaValue.of(Int64(LogLevel.Off.value()))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(Int64(LogLevel.fromValue(UInt32(args[0].intValue())).value()))]
    }
    b.install(vm)
}
