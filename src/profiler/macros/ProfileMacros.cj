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
 * @file[zh-cn] ProfileMacros.cj — three.profiler 宏自动化侵入（THREE_PROFILER 链路门控）
 * @brief[zh-cn] @Zone/@FrameMark/@FrameStart/@FrameEnd/@Plot/@PlotI64/@Message/
 *               @Fiber/@MemAlloc/@MemFree/@GpuZone/@LockTrack 属性宏
 * @macro-package three.profiler.macros
 *
 * @explain[zh-cn] ## 设计思想
 * 宏在**编译期（宏展开进程）读取环境变量 THREE_PROFILER**，与属性声明的**链路**
 * （如 "three.test.aaa.bbb"）做**段级前缀匹配**：
 * - 未命中 → 宏原样返回输入 Tokens（**零侵入**）；
 * - 命中 → 重写为 try{}finally{} 包裹（**侵入**，异常安全）。
 *
 * ## 链路匹配规则（段级前缀，按 '.' 分段）
 * 设属性链路 L = "three.test.aaa.bbb"（无属性时默认 "three"）：
 * - THREE_PROFILER="three" / "three.test" / "three.test.aaa" → 命中
 * - THREE_PROFILER="three.bbb" → **不命中**（"bbb" 不是 L 的段边界前缀）
 * - 逗号分隔多链路："three,utils.render" 任一命中即侵入
 * - 未设置 / "off" → 全部零侵入；"all"/"on"/"full" → 全部侵入
 *
 * ## 两种调用形态
 * 1. **函数级**（@Zone）：修饰函数声明，函数体重写为 try{}finally{} 包裹；
 * 2. **区间/表达式级**（全部宏）：`@X[链路]( 代码 )` 括号包裹任意代码，
 *    - 区间宏（@Zone/@Fiber/@GpuZone/@LockTrack/@FrameStart）展开为
 *      `let r = XxxScope(...); try { 代码 } finally { r.close() }`
 *      或 `try { enter; 代码 } finally { leave }`（语句/表达式位置均可用）；
 *    - 值透传宏（@Plot/@PlotI64/@Message/@MemAlloc/@MemFree）展开为
 *      `try { let v = (代码); 上报(v); v } finally {}`，原值照常参与外层运算；
 *    - 标记宏（@FrameMark/@FrameEnd）：`代码; Frame.mark()` 顺序插桩。
 *
 * ## 用法 / Usage:
 * ```
 * import three.profiler.macros.*
 *
 * // 函数级
 * \@Zone[three.render.shadow] func renderShadow(): Unit { ... }
 *
 * // 区间级（括号内任意代码）
 * @Zone[three.render.culling]( cullPass() )
 * @Fiber[three.jobs.worker]( workerLoop() )
 * @GpuZone[three.gpu.pass, context=0]( recordPass() )
 * @LockTrack[three.lock.registry]( registry.mutate() )
 * @FrameStart[three.frame.render]( renderScene() )
 * @FrameEnd[three.frame.render]( present() )
 * @FrameMark( stepSimulation() )          // 代码后打主帧标记
 *
 * // 值透传（表达式位置，原值照常参与运算）
 * let fps = @Plot[three.plot.fps]( computeFps() )
 * let n = @PlotI64[three.plot.batch]( batchCount() )
 * let s = @Message[three.msg.state, severity=debug]( currentState() )
 * let p = @MemAlloc[three.pool.geo, size=n*64]( pool.alloc(n) )
 * @MemFree[three.pool.geo]( pool.free(p) )
 * ```
 *
 * @file[en] ProfileMacros.cj — auto instrumentation macros gated by THREE_PROFILER
 * @brief[en] @Zone/@FrameMark/@FrameStart/@FrameEnd/@Plot/@PlotI64/@Message/
 *            @Fiber/@MemAlloc/@MemFree/@GpuZone/@LockTrack attribute macros
 * @explain[en] Macros read env THREE_PROFILER at expansion time and match the
 * attribute link path with segment-level prefix matching: on miss tokens pass
 * through untouched (zero intrusion); on hit code is rewritten into
 * try{}finally{} wrappers (exception-safe). Function-level (@Zone on decls) and
 * expression/statement-level (@X[link]( code )) forms are both supported.
 */
macro package three.profiler.macros

import std.ast.*
import std.env.*
import std.collection.*

// 注意：宏展开代码引用门面类型（ProfZone/ProfFrame/ProfPlot/ProfMessage/ProfFiber/
// ProfMemory/ProfGpu*/ProfLock* 等），宏包自身不（也无法）import 门面包——
// 使用方必须自行 `import three.profiler.*` 补齐（门面类带 Prof 前缀，与宏名不冲突）。

// =============================================================================
// THREE_PROFILER 解析与链路匹配（宏展开期执行）
// =============================================================================

/**
 * @brief[zh-cn] 宏展开期读取一次 THREE_PROFILER（宏进程内缓存）
 *
 * @brief[en] Read THREE_PROFILER once at macro-expansion time (cached within
 *            the macro process)
 */
internal let COMPILE_PROFILER: String = {=> (getVariable("THREE_PROFILER") ?? "off").trimAscii() }()

/**
 * @brief[zh-cn] 环境变量是否为全局开（all/on/full）
 *
 * @brief[en] Whether the env value is a global on switch (all/on/full)
 */
private func isGlobalOn(cfg: String): Bool {
    return cfg == "all" || cfg == "on" || cfg == "full"
}

/**
 * @brief[zh-cn] 链路段级前缀匹配：a 是否是 b 的段边界前缀
 *               （"three.b" 不是 "three.bbb" 的前缀）
 *
 * @brief[en] Segment-level prefix match: whether a is a segment-boundary
 *            prefix of b ("three.b" is NOT a prefix of "three.bbb")
 */
private func isSegmentPrefix(prefix: String, path: String): Bool {
    if (prefix == path) {
        return true
    }
    // prefix 短：必须是 path 的前缀且下一字符是 '.'（String 索引返回 String）
    // prefix shorter: must be a prefix of path with '.' at the boundary
    if (path.size > prefix.size && path[0..prefix.size] == prefix && path[prefix.size..prefix.size + 1] == ".") {
        return true
    }
    // prefix 长：path 必须是 prefix 的段边界前缀（粗放全开场景）
    // prefix longer: path must be a segment-boundary prefix of prefix
    if (prefix.size > path.size && prefix[0..path.size] == path && prefix[path.size..path.size + 1] == ".") {
        return true
    }
    return false
}

/**
 * @brief[zh-cn] 属性链路 L 是否被 THREE_PROFILER 配置命中；
 *               cfg 为逗号分隔的多个链路
 *
 * @brief[en] Whether the attribute link L is enabled by the THREE_PROFILER
 *            config; cfg is a comma-separated list of links
 */
private func linkEnabled(link: String, cfg: String): Bool {
    if (cfg == "" || cfg == "off") {
        return false
    }
    if (isGlobalOn(cfg)) {
        return true
    }
    for (seg in cfg.split(",")) {
        let item = seg.trimAscii()
        if (item != "" && isSegmentPrefix(item, link)) {
            return true
        }
    }
    return false
}

/**
 * @brief[zh-cn] 解析属性 Tokens 为 (链路, k=v 参数表)：
 *               - "three.render.shadow" → ("three.render.shadow", [])
 *               - "pool.geo, size=n*64" → ("pool.geo", [("size","n*64")])
 *               - 空属性 → ("three", [])
 *
 * @brief[en] Parse attribute tokens into (link, k=v table):
 *            - "three.render.shadow" -> ("three.render.shadow", [])
 *            - "pool.geo, size=n*64" -> ("pool.geo", [("size","n*64")])
 *            - empty attribute -> ("three", [])
 */
private func parseAttr(attrTokens: Tokens): (String, ArrayList<(String, String)>) {
    let link = ArrayList<String>()
    let kvs = ArrayList<(String, String)>()
    if (attrTokens.size == 0) {
        return ("three", kvs)
    }
    // 按顶层逗号切分（值可能是字符串/数字/表达式，无需考虑嵌套括号）
    // Split on top-level commas (values may be strings/numbers/expressions)
    let parts = attrTokens.toString().split(",")
    for (p in parts) {
        let seg = p.trimAscii()
        if (seg == "") {
            continue
        }
        let eq = seg.indexOf("=")
        if (let Some(i) <- eq) {
            let k = seg[0..i].trimAscii()
            let v = seg[(i + 1)..].trimAscii()
            kvs.add((k, v))
        } else {
            link.add(seg)
        }
    }
    var chosen = "three"
    if (link.size > 0) {
        chosen = link[0]
    }
    return (chosen, kvs)
}

/**
 * @brief[zh-cn] 通用门控：返回 Some(link) 表示侵入（link 为属性链路），
 *               None 表示零侵入。零侵入时静默透传，等价于宏不存在。
 *
 * @brief[en] Common gate: Some(link) means instrument (link is the attribute
 *            path), None means zero intrusion (tokens pass through silently,
 *            as if the macro did not exist).
 */
private func gate(attrTokens: Tokens): ?String {
    let (link, _) = parseAttr(attrTokens)
    let cfg = COMPILE_PROFILER
    if (!linkEnabled(link, cfg)) {
        return None<String>
    }
    return Some(link)
}

/**
 * @brief[zh-cn] 从链路取末段作为显示名："three.test.aaa.bbb" → "bbb"
 *
 * @brief[en] Take the last segment of a link as display name:
 *            "three.test.aaa.bbb" -> "bbb"
 */
private func lastSegment(link: String): String {
    let segs = link.split(".")
    return segs[segs.size - 1].trimAscii()
}

/**
 * @brief[zh-cn] 剥离输入外层 { }（用户可写 @X[l]({...}) 或 @X[l](stmt1; stmt2)）
 *
 * @brief[en] Strip the outer braces of the input (users may write
 *            @X[l]({...}) or @X[l](stmt1; stmt2))
 */
private func stripBraces(input: Tokens): Tokens {
    if (input.size >= 2 && input[0].kind == TokenKind.LCURL &&
        input[input.size - 1].kind == TokenKind.RCURL) {
        return input[1..input.size - 1]
    }
    return input
}

/**
 * @brief[zh-cn] 取 k=v 属性值（无则返回缺省）
 *
 * @brief[en] Look up a k=v attribute value (returns fallback when absent)
 */
private func kvValue(kvs: ArrayList<(String, String)>, key: String, fallback: String): String {
    for ((k, v) in kvs) {
        if (k == key) {
            return v
        }
    }
    return fallback
}
// =============================================================================
// @Zone — 函数级 + 区间级耗时区间
// =============================================================================

/**
 * @brief[zh-cn] @Zone — Tracy zone 自动包裹（THREE_PROFILER 链路门控）
 * @explain[zh-cn] 双形态：
 * 1. 函数级：`\@Zone[链路] func f(): Unit {...}` → 函数体重写为
 *    try{}finally{} 包裹的 zone（异常/return 都正确结束计时）；
 * 2. 区间级：`@Zone[链路]( 代码 )` → `let z = Zone(...); try { 代码 }
 *    finally { z.close() }`，语句/表达式位置均可用。
 * 显示名取链路末段；可选 `color=0xAABBGGRR`。未命中时零侵入。
 *
 * @brief[en] @Zone — auto-wrap in a Tracy zone (dual form: function decl or
 * @Zone[link]( code ) block), gated by THREE_PROFILER link matching.
 */
public macro Zone(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let colorKv = parseAttr(attrTokens)[1]
            var colorTok: Tokens = quote(0)   // 0 = Tracy 默认配色
            for ((k, v) in colorKv) {
                if (k == "color") {
                    // 属性值保持用户写法（0xAABBGGRR 字面量直接透传）
                    colorTok = quote($(v))
                }
            }
            if (inputTokens.size > 0 && inputTokens[0].kind == TokenKind.FUNC) {
                // ---- 函数级形态：注入方法体 {} 内部，签名原样保留 ----
                // 定位函数体：第一个深度 0 的 LCURL 与其配对 RCURL
                var bodyStart = -1
                var bodyEnd = -1
                var depth = 0
                for (i in 0..inputTokens.size) {
                    let k = inputTokens[i].kind
                    if (k == TokenKind.LCURL) {
                        if (depth == 0 && bodyStart < 0) {
                            bodyStart = i
                        }
                        depth += 1
                    } else if (k == TokenKind.RCURL) {
                        depth -= 1
                        if (depth == 0 && bodyEnd < 0) {
                            bodyEnd = i
                        }
                    }
                }
                if (bodyStart < 0 || bodyEnd < 0) {
                    diagReport(DiagReportLevel.ERROR, inputTokens,
                        "@Zone: cannot locate function body braces", "")
                    return inputTokens
                }
                let head = inputTokens[0..bodyStart + 1]   // 签名 + "{"
                let body = inputTokens[bodyStart + 1..bodyEnd]
                let tail = inputTokens[bodyEnd..]          // "}" 及尾部
                let funcName = name
                // 源位置：宏展开期从输入首 Token 取（fileID 是数字 id，line 是真行号；
                // 宏进程拿不到文件名字符串，用 "f<fileID>" 充当 Tracy 文件列）
                let p0 = inputTokens[0].pos
                let fileMark = "f${p0.fileID}"
                let lineTok = quote($(p0.line))
                return quote(
                    $(head)
                        let __tracyZone = ProfZone($(name), $(colorTok), $(fileMark), $(lineTok), $(funcName))
                        try {
                            $(body)
                        }
                        finally {
                            __tracyZone.close()
                        }
                    $(tail)
                )
            } else {
                // ---- 区间级形态：@Zone[link]( code ) ----
                let p0 = inputTokens[0].pos
                let fileMark = "f${p0.fileID}"
                let lineTok = quote($(p0.line))
                let body = stripBraces(inputTokens)
                return quote(
                    let __tz = ProfZone($(name), $(colorTok), $(fileMark), $(lineTok))
                    try {
                        $(body)
                    }
                    finally {
                        __tz.close()
                    }
                )
            }
    }
}

// =============================================================================
// @FrameMark / @FrameStart / @FrameEnd — 帧标记
// =============================================================================

/**
 * @brief[zh-cn] @FrameMark — 代码后打主帧标记（THREE_PROFILER 门控）
 * @explain[zh-cn] `@FrameMark( 代码 )` → `代码; Frame.mark()`。带属性时按
 * 命名帧流打标（Frame.mark(name)）。适合包裹主循环体的最后一段代码。
 *
 * @brief[en] @FrameMark — emits Frame.mark() after the wrapped code.
 */
public macro FrameMark(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let body = stripBraces(inputTokens)
            let name = lastSegment(link)
            return quote(
                $(body)
                ProfFrame.mark($(name))
            )
    }
}

/**
 * @brief[zh-cn] @FrameStart — 命名帧流开始标记（代码前插 Frame.start）
 * @brief[en] @FrameStart — emits Frame.start(name) before the wrapped code.
 */
public macro FrameStart(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let body = stripBraces(inputTokens)
            let name = lastSegment(link)
            return quote(
                ProfFrame.start($(name))
                $(body)
            )
    }
}

/**
 * @brief[zh-cn] @FrameEnd — 命名帧流结束标记（代码后插 Frame.finish）
 * @brief[en] @FrameEnd — emits Frame.finish(name) after the wrapped code.
 */
public macro FrameEnd(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let body = stripBraces(inputTokens)
            let name = lastSegment(link)
            return quote(
                $(body)
                ProfFrame.finish($(name))
            )
    }
}

// =============================================================================
// @Plot / @PlotI64 — 值透传曲线
// =============================================================================

/**
 * @brief[zh-cn] @Plot — 表达式求值并上报 Float64 曲线点，原值透传
 * @explain[zh-cn] `let fps = @Plot[three.plot.fps]( computeFps() )` →
 * `try { let v = (computeFps()); Plot.point(name, v); v } finally {}`。
 * 表达式必须可隐式转换为 Float64。
 *
 * @brief[en] @Plot — evaluates the expression, reports a Float64 plot point,
 * passes the value through.
 */
public macro Plot(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let body = stripBraces(inputTokens)
            return quote(
                try {
                    let __tpv = ($(body))
                    ProfPlot.point($(name), __tpv)
                    __tpv
                }
                finally {
                }
            )
    }
}

/**
 * @brief[zh-cn] @PlotI64 — 同 @Plot，表达式为 Int64（批次数/队列深度等）
 * @brief[en] @PlotI64 — like @Plot for Int64 expressions.
 */
public macro PlotI64(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let body = stripBraces(inputTokens)
            return quote(
                try {
                    let __tpv = ($(body))
                    ProfPlot.pointI64($(name), __tpv)
                    __tpv
                }
                finally {
                }
            )
    }
}

// =============================================================================
// @Message — 值透传消息
// =============================================================================

/**
 * @brief[zh-cn] @Message — 表达式求值并上报为消息，原值透传
 * @explain[zh-cn] `let s = @Message[three.msg.state]( currentState() )` →
 * 求值 → `Message.logInfo("${v}")` → 透传 v。可选 `severity=trace|debug|info|
 * warning|error|fatal`（默认 info）。表达式类型需实现 ToString。
 *
 * @brief[en] @Message — evaluates the expression, reports it as a message,
 * passes the value through. Optional severity=trace|debug|info|warning|error|fatal.
 */
public macro Message(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let kvs = parseAttr(attrTokens)[1]
            let sev = kvValue(kvs, "severity", "info")
            let logCall = match (sev) {
                case "trace" => quote(ProfMessage.logTrace("${__tpv}"))
                case "debug" => quote(ProfMessage.logDebug("${__tpv}"))
                case "warning" => quote(ProfMessage.logWarning("${__tpv}"))
                case "error" => quote(ProfMessage.logError("${__tpv}"))
                case "fatal" => quote(ProfMessage.logFatal("${__tpv}"))
                case _ => quote(ProfMessage.logInfo("${__tpv}"))
            }
            let body = stripBraces(inputTokens)
            return quote(
                try {
                    let __tpv = ($(body))
                    $(logCall)
                    __tpv
                }
                finally {
                }
            )
    }
}

// =============================================================================
// @Fiber — 纤维执行流包裹
// =============================================================================

/**
 * @brief[zh-cn] @Fiber — 纤维执行流包裹（THREE_PROFILER 门控）
 * @explain[zh-cn] `@Fiber[three.jobs.worker]( 代码 )` →
 * `try { Fiber.enter(name); 代码 } finally { Fiber.leave() }`。
 * 区间内事件归属到该逻辑执行流。
 *
 * @brief[en] @Fiber — wraps code in Fiber.enter/leave pair.
 */
public macro Fiber(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let body = stripBraces(inputTokens)
            return quote(
                ProfFiber.enter($(name))
                try {
                    $(body)
                }
                finally {
                    ProfFiber.leave()
                }
            )
    }
}

// =============================================================================
// @MemAlloc / @MemFree — 内存事件
// =============================================================================

/**
 * @brief[zh-cn] @MemAlloc — 表达式求值（指针）并上报分配事件，指针透传
 * @explain[zh-cn] `let p = @MemAlloc[three.pool.geo, size=n*64]( pool.alloc(n) )`
 * → 求值 → `Memory.alloc(ptr, size, name)` → 透传 ptr。size 为可选 k=v
 * （默认 0，Tracy 曲线仍按次数统计）。表达式须为 CPointer。
 *
 * @brief[en] @MemAlloc — evaluates a pointer expression, reports an alloc
 * event, passes the pointer through. Optional size= k/v (default 0).
 */
public macro MemAlloc(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let kvs = parseAttr(attrTokens)[1]
            // size= 为任意表达式 tokens（cangjieLex 还原，保持用户写法）
            let sizeTok = cangjieLex(kvValue(kvs, "size", "0"))
            let body = stripBraces(inputTokens)
            // __tmp 保持表达式原始类型（透传保值），仅上报调用点以
            // CPointer<Unit>(...) 重解释为 FFI 形参类型
            return quote(
                try {
                    let __tmp = ($(body))
                    ProfMemory.alloc(CPointer<Unit>(__tmp), $(sizeTok), $(name))
                    __tmp
                }
                finally {
                }
            )
    }
}

/**
 * @brief[zh-cn] @MemFree — 表达式求值（指针）并上报释放事件，指针透传
 * @brief[en] @MemFree — evaluates a pointer expression, reports a free event,
 * passes the pointer through.
 */
public macro MemFree(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let body = stripBraces(inputTokens)
            // __tmp 保持原始类型透传，上报调用点重解释为 CPointer<Unit>
            return quote(
                try {
                    let __tmp = ($(body))
                    ProfMemory.free(CPointer<Unit>(__tmp), $(name))
                    __tmp
                }
                finally {
                }
            )
    }
}

// =============================================================================
// @GpuZone — GPU 命令区间
// =============================================================================

/**
 * @brief[zh-cn] @GpuZone — GPU 命令录制区间包裹（THREE_PROFILER 门控）
 * @explain[zh-cn] `@GpuZone[three.gpu.pass, context=0]( 代码 )` →
 * `let gz = GpuZone(name, ctx, file, line); try { 代码 } finally { gz.close() }`。
 * gpuZoneBegin/End 自动配对；时间戳仍由渲染 backend 在 fence 回读后用
 * Gpu.time(gpuTime, gz.query, gz.ctx) 上报。可选 `context=<表达式>`（默认 0）。
 *
 * @brief[en] @GpuZone — wraps GPU command recording in a GpuZone scope
 * (begin/end pair auto-emitted); timestamps reported later via Gpu.time.
 */
public macro GpuZone(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let kvs = parseAttr(attrTokens)[1]
            let ctxTok = cangjieLex(kvValue(kvs, "context", "0"))
            let p0 = inputTokens[0].pos
            let fileMark = "f${p0.fileID}"
            let lineTok = quote($(p0.line))
            let body = stripBraces(inputTokens)
            return quote(
                let __tgz = ProfGpuZone($(name), $(ctxTok), $(fileMark), $(lineTok))
                try {
                    $(body)
                }
                finally {
                    __tgz.close()
                }
            )
    }
}

// =============================================================================
// @LockTrack — 临界区锁时间线
// =============================================================================

/**
 * @brief[zh-cn] @LockTrack — 临界区包装为 Tracy 锁时间线（THREE_PROFILER 门控）
 * @explain[zh-cn] `@LockTrack[three.lock.registry]( 代码 )` →
 * `let lz = LockZone(name, file, line); try { 代码 } finally { lz.close() }`。
 * 进入即视为持有、退出上报 afterUnlock（作用域锁语义）；真正的 lock/unlock
 * 粒度请用 three.profiler.Lock 静态 API 手写。
 *
 * @brief[en] @LockTrack — wraps a critical section into the Tracy lock
 * timeline (scope-lock semantics; fine-grained lock/unlock via Lock API).
 */
public macro LockTrack(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    match (gate(attrTokens)) {
        case None => return inputTokens
        case Some(link) =>
            let name = lastSegment(link)
            let p0 = inputTokens[0].pos
            let fileMark = "f${p0.fileID}"
            let lineTok = quote($(p0.line))
            let body = stripBraces(inputTokens)
            return quote(
                let __tlz = ProfLockZone($(name), $(fileMark), $(lineTok))
                try {
                    $(body)
                }
                finally {
                    __tlz.close()
                }
            )
    }
}
