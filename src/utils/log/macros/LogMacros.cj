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
 */

/**
 * @file[zh-cn] LogMacros.cj 日志级别条件编译宏（纯宏包，零包依赖）
 * @brief[zh-cn] 表达式宏：编译期按 cfg 档位（@When[logLevel == "..."]）决定日志调用是否生成代码
 * @package three.utils.log
 *
 * @explain[zh-cn] 设计目标：release 构建零日志开销。本包是**纯宏包**（macro package），
 * 不含任何运行时代码。日志档位由**编译进程的环境变量 THREE_LOG_LEVEL** 决定——宏 DLL 在
 * cjc 展开宏时（即业务代码编译期）加载执行，包级初始化读取 THREE_LOG_LEVEL 定档：
 *
 * - 取值 off/error/warn/info/debug/trace（容忍首尾空白）；
 * - 未设置或无法识别：按 off 处理（无法识别时编译期打印提示）。
 *
 * 宏包内据此计算 COMPILE_LOG_LEVEL：
 * - 未设置或 "off"：日志宏展开为空 Tokens——调用点（含参数求值、字符串插值）
 *   不生成任何代码；
 * - "trace"/"debug"/"info"/"warn"/"error"：展开为**运行时 Logger 调用**
 *   （Logger.info/debug/warn/error/warnOnce），输出通道由 Logger 决定——
 *   默认 println，宿主可经 Logger.setConsoleFunction 挂平台 sink
 *   （Android logcat / OHOS hilog）。
 *
 * 级别序（越靠后越详细）：error < warn < info < debug < trace。
 * 形参惰性：宏展开前调用点的实参 Tokens 不会先求值，off 时字符串插值等开销为零。
 *
 * 消息格式（与 Logger 一致）：`THREE.<首参数> <其余参数空格拼接>`。
 *
 * 自定义处理器：宏支持可选的末位处理器实参（`(String, String) -> Unit`
 * 类型表达式，首参为级别字符串，次参为完整消息）。提供处理器时展开为
 * `handler("<type>", <msg>)` 调用（兼容旧用法）；未提供时展开为
 * `Logger.<level>(...)`：
 * ```
 * \@LogError("Shader", "compile failed")               // → Logger.error([...])
 * \@LogWarn("Mesh", "missing", handler)                // → handler("warn", ...)
 * ```
 *
 * 使用示例 / Usage:
 * ```
 * import three.utils.log.*
 * \@LogInfo("Renderer", "initialized")
 * ```
 */
macro package three.utils.log.macros

import std.ast.*
import std.collection.*
import std.env.*

/// 编译期日志档位（由编译进程环境变量 THREE_LOG_LEVEL 决定，宏 DLL 加载时求值固化）：
/// -1=off（默认），1=error，2=warn，3=info，4=debug，5=trace
internal let COMPILE_LOG_LEVEL: Int64 = resolveLogLevel()

/// 解析编译期环境变量 THREE_LOG_LEVEL → 档位数值；未设置按 off，无法识别按 off 并打印提示
internal func resolveLogLevel(): Int64 {
    let rawOpt = getVariable("THREE_LOG_LEVEL")
    if (rawOpt.isNone()) {
        return -1
    }
    let raw = rawOpt.getOrThrow().trimAscii()
    match (raw) {
        case "error" => return 1
        case "warn" => return 2
        case "info" => return 3
        case "debug" => return 4
        case "trace" => return 5
        case "off" => return -1
        case _ =>
            println("[LogMacros] unknown THREE_LOG_LEVEL '${raw}' (expect off/error/warn/info/debug/trace), fallback to off")
            return -1
    }
}

/// 判断给定级别当前是否允许生成代码（>= 编译期档位则允许）
internal func levelEnabled(minLevel: Int64): Bool {
    return COMPILE_LOG_LEVEL >= minLevel
}

/// 将实参 Tokens 组装为展开代码（运行时统一走 Logger，通道由 Logger 决定）：
/// - 数组元素按空格拼接，首元素即标签，整体加 "THREE." 前缀；
/// - handler 为空 → `Logger.<级别方法>([<elems>])`（Logger 内部支持运行时
///   setConsoleFunction 挂自定义 sink，如 Android logcat / OHOS hilog）；
/// - handler 非空 → 兼容旧签名，仍展开为 `(<handler>)("<type>", <join>)`。
///
/// Builds the expansion. Runtime output goes through Logger (the sink is decided
/// by Logger, e.g. Android logcat / OHOS hilog via setConsoleFunction):
/// - no handler → `Logger.<level>([<elems>])`;
/// - with handler → legacy `(<handler>)("<type>", <join>)` for compatibility.
internal func emitLog(logType: String, arrayBody: String, handler: String): Tokens {
    let elems = splitTopLevel(arrayBody)
    var join = ""
    for (i in 0..elems.size) {
        let elem = elems[i].trimAscii()
        if (i == 0) {
            join = "${elem}"
        } else {
            join += "+\" \"+(${elem})"
        }
    }
    if (handler == "") {
        return cangjieLex("Logger.${logType}([${join}])")
    }
    return cangjieLex("(${handler})(\"${logType}\",${join})")
}

/// 把 "a, b, c" 形式的元素 Tokens 按顶层逗号切成单个表达式字符串列表。
/// 按字节扫描：仅识别 ASCII 分隔符，多字节 UTF-8（中文等）永不被误切。
internal func splitTopLevel(s: String): Array<String> {
    let bytes = s.toArray()
    let parts = ArrayList<ArrayList<UInt8>>()
    var depth = 0
    var inStr = false
    var cur = ArrayList<UInt8>()
    let n = bytes.size
    var i: Int64 = 0
    while (i < n) {
        let ch = bytes[i]
        if (inStr) {
            cur.add(ch)
            if (ch == b'"' && (i == 0 || bytes[i - 1] != b'\\')) {
                inStr = false
            }
        } else {
            if (ch == b'"') {
                inStr = true
                cur.add(ch)
            } else if (ch == b'(' || ch == b'[' || ch == b'{') {
                depth += 1
                cur.add(ch)
            } else if (ch == b')' || ch == b']' || ch == b'}') {
                depth -= 1
                cur.add(ch)
            } else if (ch == b',' && depth == 0) {
                parts.add(cur)
                cur = ArrayList<UInt8>()
            } else {
                cur.add(ch)
            }
        }
        i += 1
    }
    // 末段去空白后若非空则收尾
    let trimmed = trimBytes(cur)
    if (trimmed.size > 0) {
        parts.add(trimmed)
    }
    let out = ArrayList<String>()
    for (p in parts) {
        out.add(String.fromUtf8(p.toArray()))
    }
    return out.toArray()
}

/// 去掉字节数组首尾 ASCII 空白（返回新数组；全空白返回空数组）
internal func trimBytes(b: ArrayList<UInt8>): ArrayList<UInt8> {
    var start = 0
    var end = b.size
    while (start < end && b[start] == b' ') {
        start += 1
    }
    while (end > start && b[end - 1] == b' ') {
        end -= 1
    }
    let out = ArrayList<UInt8>()
    var i = start
    while (i < end) {
        out.add(b[i])
        i += 1
    }
    return out
}

/// 去掉外层 [ ]，取数组体；并分离末位处理器实参（若存在）。
/// 返回 (数组体, 处理器Tokens或"")。字节级扫描，字符串字面量内的引号已处理。
internal func parseArgs(inputTokens: Tokens): (String, String) {
    let bytes = inputTokens.toString().toArray()
    let n = bytes.size
    // 找首个 '['
    var open = -1
    var i: Int64 = 0
    while (i < n) {
        if (bytes[i] == b'[') {
            open = i
            break
        }
        i += 1
    }
    if (open < 0) {
        return ("", "")
    }
    // 找与 [ 匹配的 ]
    var depth = 0
    var close = -1
    var inStr = false
    i = open
    while (i < n) {
        let ch = bytes[i]
        if (inStr) {
            if (ch == b'"' && (i == 0 || bytes[i - 1] != b'\\')) {
                inStr = false
            }
        } else {
            if (ch == b'"') {
                inStr = true
            } else if (ch == b'[') {
                depth += 1
            } else if (ch == b']') {
                depth -= 1
                if (depth == 0) {
                    close = i
                    break
                }
            }
        }
        i += 1
    }
    if (close < 0) {
        return ("", "")
    }
    let body = String.fromUtf8(sliceBytes(bytes, open + 1, close))
    // 数组之后若还有实参（, handler）即为处理器
    let rest = trimBytesRange(bytes, close + 1, n)
    var handler = ""
    if (rest.size > 1 && rest[0] == b',') {
        handler = String.fromUtf8(trimBytesRange(bytes, close + 2, n))
    }
    return (body, handler)
}

/// 字节切片 [start, end)
internal func sliceBytes(bytes: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
    let out = ArrayList<UInt8>()
    var i = start
    while (i < end) {
        out.add(bytes[i])
        i += 1
    }
    return out.toArray()
}

/// 字节范围 [start, end) 去首尾 ASCII 空白
internal func trimBytesRange(bytes: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
    return trimBytesRangeHelper(bytes, start, end)
}

internal func trimBytesRangeHelper(bytes: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
    var s = start
    var e = end
    while (s < e && bytes[s] == b' ') {
        s += 1
    }
    while (e > s && bytes[e - 1] == b' ') {
        e -= 1
    }
    return sliceBytes(bytes, s, e)
}

// ===== 各级别表达式宏 =====
// 展开规则：
//   允许级别 → 内联格式化 + println / 处理器调用（零包依赖）
//   不允许   → 空 Tokens（调用点整体消失，零开销）

/**
 * @brief[zh-cn] 输出 Error 级别日志
 * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
 *
 * @brief[en] Emits an Error-level log message
 * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
 */
public macro LogError(inputTokens: Tokens): Tokens {
    if (!levelEnabled(1)) {
        return cangjieLex("()")
    }
    let (body, handler) = parseArgs(inputTokens)
    return emitLog("error", body, handler)
}
/**
 * @brief[zh-cn] 输出 Warn 级别日志
 * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
 *
 * @brief[en] Emits a Warn-level log message
 * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
 */
public macro LogWarn(inputTokens: Tokens): Tokens {
    if (!levelEnabled(2)) {
        return cangjieLex("()")
    }
    let (body, handler) = parseArgs(inputTokens)
    return emitLog("warn", body, handler)
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
public macro LogWarnOnce(inputTokens: Tokens): Tokens {
    if (!levelEnabled(2)) {
        return cangjieLex("()")
    }
    let (body, handler) = parseArgs(inputTokens)
    // 无 handler 时展开为 Logger.warnOnce（一次性去重逻辑在 Logger 侧）
    if (handler == "") {
        let elems = splitTopLevel(body)
        var join = ""
        for (i in 0..elems.size) {
            let elem = elems[i].trimAscii()
            if (i == 0) {
                join = "${elem}"
            } else {
                join += "+\" \"+(${elem})"
            }
        }
        return cangjieLex("Logger.warnOnce([${join}])")
    }
    return emitLog("warn", body, handler)
}
/**
 * @brief[zh-cn] 输出 Info 级别日志
 * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
 *
 * @brief[en] Emits an Info-level log message
 * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
 */
public macro LogInfo(inputTokens: Tokens): Tokens {
    if (!levelEnabled(3)) {
        return cangjieLex("()")
    }
    let (body, handler) = parseArgs(inputTokens)
    return emitLog("info", body, handler)
}
/**
 * @brief[zh-cn] 输出 Debug 级别日志
 * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
 *
 * @brief[en] Emits a Debug-level log message
 * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
 */
public macro LogDebug(inputTokens: Tokens): Tokens {
    if (!levelEnabled(4)) {
        return cangjieLex("()")
    }
    let (body, handler) = parseArgs(inputTokens)
    return emitLog("debug", body, handler)
}
/**
 * @brief[zh-cn] 输出 Trace 级别日志
 * @param[zh-cn] params 消息参数列表（首参数为标签/模块名，自动添加前缀）
 *
 * @brief[en] Emits a Trace-level log message
 * @param[en] params Message parameters (the first is the tag/module name; a prefix is added automatically)
 */
public macro LogTrace(inputTokens: Tokens): Tokens {
    if (!levelEnabled(5)) {
        return cangjieLex("()")
    }
    let (body, handler) = parseArgs(inputTokens)
    return emitLog("trace", body, handler)
}
