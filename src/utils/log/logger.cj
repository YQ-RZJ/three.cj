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
 * @file[zh-cn] Logger 统一日志管理类
 * @brief[zh-cn] 提供分级日志输出，替代原有的散落 println / log / warn / error 调用
 * @explain[zh-cn] 支持五种日志等级（Trace / Debug / Info / Warn / Error），通过 setLevel 控制
 * 打印阈值。保留 THREE. 前缀风格，并保持与原有 setConsoleFunction 回调机制的兼容。
 *
 * @file[en] Logger  Unified logging manager
 * @brief[en] Provides level-based logging to replace scattered println / log / warn / error calls
 * @explain[en] Supports five log levels (Trace / Debug / Info / Warn / Error) with a
 * threshold controlled via setLevel. Keeps the THREE. prefix style and remains
 * compatible with the original setConsoleFunction callback mechanism.
 *
 * @package three.utils.log
 */
package three.utils.log

import std.collection.*
import std.deriving.*

/**
 * @brief[zh-cn] 日志等级枚举
 * @explain[zh-cn] 数值越大等级越高，越应该被打印。Trace=0, Debug=1, Info=2, Warn=3, Error=4, Off=5。
 *
 * @brief[en] Log-level enum
 * @explain[en] Higher values indicate more important levels that are more likely to be
 * printed. Trace=0, Debug=1, Info=2, Warn=3, Error=4, Off=5.
 */
@Derive[Equatable]
public enum LogLevel {
    /**
     * @brief[zh-cn] 跟踪级（最详细）
     *
     * @brief[en] Trace level (most verbose)
     */
    | Trace
    /**
     * @brief[zh-cn] 调试级
     *
     * @brief[en] Debug level
     */
    | Debug
    /**
     * @brief[zh-cn] 信息级
     *
     * @brief[en] Info level
     */
    | Info
    /**
     * @brief[zh-cn] 警告级
     *
     * @brief[en] Warn level
     */
    | Warn
    /**
     * @brief[zh-cn] 错误级
     *
     * @brief[en] Error level
     */
    | Error
    /**
     * @brief[zh-cn] 关闭日志输出
     *
     * @brief[en] Turns logging off
     */
    | Off

    /**
     * @brief[zh-cn] 将枚举值转换为 UInt32
     * @return[zh-cn] 对应的数值
     *
     * @brief[en] Converts the enum value to UInt32
     * @return[en] The corresponding numeric value
     */
    public func value(): UInt32 {
        match (this) {
            case Trace => 0
            case Debug => 1
            case Info => 2
            case Warn => 3
            case Error => 4
            case Off => 5
        }
    }

    /**
     * @brief[zh-cn] 从 UInt32 转换回枚举值
     * @param[zh-cn] v 数值
     * @return[zh-cn] 对应的枚举值（未知数值回落到 Off）
     *
     * @brief[en] Converts a UInt32 back to the enum value
     * @param[en] v The numeric value
     * @return[en] The matching enum value (unknown values fall back to Off)
     */
    public static func fromValue(v: UInt32): LogLevel {
        match (v) {
            case 0 => Trace
            case 1 => Debug
            case 2 => Info
            case 3 => Warn
            case 4 => Error
            case _ => Off
        }
    }
}

// Three.js 风格日志前缀
private let LOG_PREFIX: String = "THREE."

// 全局日志等级（默认 Trace）
private var _logLevel: LogLevel = LogLevel.Trace

// 自定义控制台函数处理器（兼容原 setConsoleFunction 机制）
private var _consoleFn: Option<(String, String) -> Unit> = None

// 仅输出一次的警告缓存
private var _warnCache: HashMap<String, Bool> = HashMap<String, Bool>()

/**
 * @brief[zh-cn] 统一日志管理类
 * @explain[zh-cn] 提供静态方法输出分级日志，支持全局日志等级控制与自定义控制台回调钩子。
 * 使用示例：
 * Logger.setLevel(LogLevel.Debug)
 * Logger.debug(["Renderer", "initialized"])
 * Logger.info(["Scene", "loaded"])
 * Logger.warn(["Mesh", "material missing"])
 * Logger.error(["Shader", "compile failed"])
 *
 * @brief[en] Unified logging manager class
 * @explain[en] Provides static methods for level-based logging, a global log-level
 * control, and a custom console callback hook. Example usage:
 * Logger.setLevel(LogLevel.Debug)
 * Logger.debug(["Renderer", "initialized"])
 * Logger.info(["Scene", "loaded"])
 * Logger.warn(["Mesh", "material missing"])
 * Logger.error(["Shader", "compile failed"])
 */
public class Logger {
    /**
     * @brief[zh-cn] 设置当前日志等级
     * @param[zh-cn] level 日志等级（低于该等级的日志不会输出）
     *
     * @brief[en] Sets the current log level
     * @param[en] level The log level (logs below this level are suppressed)
     */
    public static func setLevel(level: LogLevel): Unit {
        _logLevel = level
    }

    /**
     * @brief[zh-cn] 获取当前日志等级
     * @return[zh-cn] 当前日志等级
     *
     * @brief[en] Gets the current log level
     * @return[en] The current log level
     */
    public static func getLevel(): LogLevel {
        return _logLevel
    }

    /**
     * @brief[zh-cn] 设置自定义控制台函数
     * @param[zh-cn] fn 自定义函数，接受 (type, message) 参数，type 为 "trace"、"debug"、"info"、"warn"、"error"
     *
     * @brief[en] Sets a custom console function
     * @param[en] fn A custom function taking (type, message); type is one of
     * "trace", "debug", "info", "warn", "error"
     */
    public static func setConsoleFunction(fn: Option<(String, String) -> Unit>): Unit {
        _consoleFn = fn
    }

    /**
     * @brief[zh-cn] 获取当前自定义控制台函数
     * @return[zh-cn] 当前控制台函数（未设置时为 None）
     *
     * @brief[en] Gets the current custom console function
     * @return[en] The current console function (None if unset)
     */
    public static func getConsoleFunction(): Option<(String, String) -> Unit> {
        return _consoleFn
    }

    /**
     * @brief[zh-cn] 输出 Trace 级别日志
     * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
     *
     * @brief[en] Emits a Trace-level log message
     * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
     */
    public static func trace(params: Array<String>): Unit {
        if (_logLevel.value() > LogLevel.Trace.value()) { return }
        var msg = buildMsg(params)
        match (_consoleFn) {
            case Some(fn) => fn("trace", msg)
            case None => println(msg)
        }
    }

    /**
     * @brief[zh-cn] 输出 Debug 级别日志
     * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
     *
     * @brief[en] Emits a Debug-level log message
     * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
     */
    public static func debug(params: Array<String>): Unit {
        if (_logLevel.value() > LogLevel.Debug.value()) { return }
        var msg = buildMsg(params)
        match (_consoleFn) {
            case Some(fn) => fn("debug", msg)
            case None => println(msg)
        }
    }

    /**
     * @brief[zh-cn] 输出 Info 级别日志
     * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
     *
     * @brief[en] Emits an Info-level log message
     * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
     */
    public static func info(params: Array<String>): Unit {
        if (_logLevel.value() > LogLevel.Info.value()) { return }
        var msg = buildMsg(params)
        match (_consoleFn) {
            case Some(fn) => fn("info", msg)
            case None => println(msg)
        }
    }

    /**
     * @brief[zh-cn] 输出 Warn 级别日志
     * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
     *
     * @brief[en] Emits a Warn-level log message
     * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
     */
    public static func warn(params: Array<String>): Unit {
        if (_logLevel.value() > LogLevel.Warn.value()) { return }
        var msg = buildMsg(params)
        match (_consoleFn) {
            case Some(fn) => fn("warn", msg)
            case None => println(msg)
        }
    }

    /**
     * @brief[zh-cn] 输出 Error 级别日志
     * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
     *
     * @brief[en] Emits an Error-level log message
     * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
     */
    public static func error(params: Array<String>): Unit {
        if (_logLevel.value() > LogLevel.Error.value()) { return }
        var msg = buildMsg(params)
        match (_consoleFn) {
            case Some(fn) => fn("error", msg)
            case None => println(msg)
        }
    }

    /**
     * @brief[zh-cn] 仅输出一次 Warn 级别日志
     * @explain[zh-cn] 相同内容的消息仅在首次输出，后续调用将被缓存忽略，避免重复刷屏。
     * @param[zh-cn] params 消息参数列表
     *
     * @brief[en] Emits a Warn-level log message only once
     * @explain[en] A given message is emitted only the first time; later calls with the
     * same content are cached and ignored to avoid log spam.
     * @param[en] params Message parameters
     */
    public static func warnOnce(params: Array<String>): Unit {
        if (_logLevel.value() > LogLevel.Warn.value()) { return }
        var msg = ""
        for (i in 0..params.size) {
            if (i > 0) { msg += " " }
            msg += params[i]
        }
        if (_warnCache.contains(msg)) { return }
        _warnCache[msg] = true
        warn(params)
    }

    /**
     * @param[zh-cn] params 消息参数列表
     * @return[zh-cn] 拼接后的消息字符串
     *
     * @param[en] params Message parameters
     * @return[en] The concatenated message string
     *
     * 构建日志消息字符串
     */
    private static func buildMsg(params: Array<String>): String {
        // 空数组健壮化：宏展开 Logger.info([<elems>]) 在实参切分为空时
        // （如三参宏缺参或元素全为空白），params[0] 会越界崩溃
        //（IndexOutOfBoundsException，OHOS 实测）。退化为仅前缀。
        if (params.size == 0) {
            return LOG_PREFIX
        }
        var msg = LOG_PREFIX + params[0]
        for (i in 1..params.size) {
            msg += " " + params[i]
        }
        return msg
    }
}
