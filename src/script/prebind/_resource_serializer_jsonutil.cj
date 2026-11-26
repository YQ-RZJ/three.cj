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
 * @file[zh-cn] resource_serializer_jsonutil JSON 动态编解码的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将引擎 JSON 能力（cjfast_json 的 JsonUtil / JsonStreamReader / JsonStreamWriter）
 * 桥接为 Lua 命名空间 three.resource.serializer.JsonUtil
 * @explain[zh-cn] 引擎侧已具备完整的 JSON 词法/语法与格式化实现（three.resource.serializer 重导出
 * cjfast_json）。本绑定把「Lua 值 ↔ JSON」的动态通道补上，供 Lua 模块（如
 * resources/lua/three/resource/serializer.lua）复用，避免在 Lua 侧重复手写 JSON 语法解析。
 *
 * 公开成员（均为静态方法）：
 * - parse(text, nullValue?)：JSON 文本 → Lua 值。对象 → 表，数组 → 数组表，数字 → number，
 *   null → nullValue（缺省 nil）。嵌套 null 同样替换为 nullValue，便于上层用哨兵区分「显式 null」
 *   与「字段缺失」。解析失败或存在尾随内容时抛错。
 * - isValid(text)：JSON 文本是否可解析（不抛错，返回布尔）。
 * - stringify(value, opts?)：Lua 值 → JSON 文本。opts：
 *     pretty    boolean|number  美化输出（true 为 2 空格；数字为缩进空格数）
 *     indent    string          自定义缩进串（优先于 pretty）
 *     sortKeys  boolean         对象键按字典序输出
 *     ignoreNull boolean        对象字段值为 nil 或 nullValue 时不输出（数组内保留 null）
 *     maxDepth  number          最大嵌套深度（缺省 256，超出抛错）
 *     nullValue any             视为 JSON null 的哨兵值（如 Lua 侧的 S.null）
 *   数组判定：键恰为 1..n 连续整数的表按数组输出；空表按对象输出，但若表 metatable 的
 *   __jsonArray 字段为真（Lua 侧 serializer.array 的标记）则按数组输出 []。
 *
 * @note[zh-cn] 仅接受纯数据表；带业务 metatable 的对象（如 Lua 侧 Adapter 实例）应先由
 * Lua 侧转换为普通表再调用（serializer.lua 的 plainify 已处理）。
 *
 * @file[en] resource_serializer_jsonutil  Lua binding of dynamic JSON encode/decode
 * (three.script.prebind)
 * @brief[en] Bridges the engine JSON stack (cjfast_json's JsonUtil / JsonStreamReader /
 * JsonStreamWriter) as the Lua namespace three.resource.serializer.JsonUtil
 * @explain[en] The engine already ships a complete JSON lexer/parser/formatter
 * (three.resource.serializer re-exports cjfast_json). This binding adds the missing
 * "Lua value <-> JSON" dynamic channel so Lua modules (e.g.
 * resources/lua/three/resource/serializer.lua) can reuse it instead of hand-writing a
 * JSON grammar in Lua.
 *
 * Public members (all static):
 * - parse(text, nullValue?): JSON text -> Lua value. Objects -> tables, arrays -> array
 *   tables, numbers -> number, null -> nullValue (nil by default). Nested nulls are also
 *   replaced by nullValue so callers can distinguish explicit null from a missing field.
 *   Throws on parse errors or trailing content.
 * - isValid(text): whether the text is parsable (no throw; returns a boolean).
 * - stringify(value, opts?): Lua value -> JSON text. opts:
 *     pretty     boolean|number  pretty print (true = two spaces; number = indent width)
 *     indent     string          custom indent unit (takes precedence over pretty)
 *     sortKeys   boolean         output object keys in lexicographic order
 *     ignoreNull boolean         omit object fields that are nil or nullValue
 *                                (nulls inside arrays are kept)
 *     maxDepth   number          maximum nesting depth (default 256; exceeding it throws)
 *     nullValue  any             sentinel treated as JSON null (e.g. S.null on the Lua side)
 *   Array detection: a table whose keys are exactly the consecutive integers 1..n is
 *   emitted as an array; an empty table is emitted as an object unless its metatable has a
 *   truthy __jsonArray field (the marker set by serializer.array), in which case it is
 *   emitted as [].
 *
 * @note[en] Only plain data tables are accepted; objects with business metatables
 * (e.g. Lua Adapter instances) must be converted to plain tables first
 * (serializer.lua's plainify already does this).
 */
package three.script.prebind

import std.collection.*
import std.io.*
import three._vendor.luajit4cj.luajit.*
import three.script.vm.*
import three.script.binding.*
import three.resource.serializer.JsonUtil
import three.resource.serializer.JsonStreamReader
import three.resource.serializer.JsonStreamWriter
import three.resource.serializer.WriteConfig

/** 默认最大嵌套深度（与 Lua 侧 serializer 的 maxDepth 缺省值一致） */
private const JSON_DEFAULT_MAX_DEPTH: Int64 = 256

/**
 * @brief[zh-cn] stringify 的选项（由 Lua 侧 opts 表解析而来）
 *
 * @brief[en] Options of stringify (parsed from the Lua opts table)
 */
private class JsonWriteOpts {
    /** 缩进单元（空串表示紧凑输出） */
    var indentUnit: String = ""
    /** 对象键是否排序 */
    var sortKeys: Bool = false
    /** 对象字段为 nil/null 时是否跳过 */
    var ignoreNull: Bool = false
    /** 最大嵌套深度 */
    var maxDepth: Int64 = JSON_DEFAULT_MAX_DEPTH
    /** null 哨兵在 Lua 栈上的绝对索引（0 表示未提供） */
    var nullIndex: Int32 = 0
}

/**
 * @brief[zh-cn] 安装 JsonUtil 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.resource.serializer.JsonUtil）
 *
 * @brief[en] Installs the Lua binding of JsonUtil (static-only class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.resource.serializer.JsonUtil)
 */
public func installJsonUtil(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.serializer.JsonUtil")
    // ===== JSON 文本 → Lua 值（null 用调用方提供的哨兵表示） =====
    b.staticMethod("parse") { args => [_jsonParse(vm, args)] }
    // ===== JSON 文本是否合法 =====
    b.staticMethod("isValid") { args => [LuaValue.Boolean(_jsonIsValid(args))] }
    // ===== Lua 值 → JSON 文本 =====
    b.staticMethod("stringify") { args => [LuaValue.Str(_jsonStringify(vm, args))] }
    b.install(vm)
}

// =============================================================================
// 解码：JSON 文本 → Lua 值
// =============================================================================

/**
 * @brief[zh-cn] 解析 JSON 文本为 Lua 值
 * @param[zh-cn] vm 目标虚拟机（构造返回表需要）
 * @param[zh-cn] args 参数（0 = 文本，1 = 可选 null 哨兵）
 * @return[zh-cn] Lua 值（对象/数组为表，null 为哨兵）
 *
 * @brief[en] Parses JSON text into a Lua value
 * @param[en] vm The target virtual machine (needed to build returned tables)
 * @param[en] args Arguments (0 = text, 1 = optional null sentinel)
 * @return[en] The Lua value (objects/arrays are tables; null is the sentinel)
 */
private func _jsonParse(vm: LuaVM, args: Array<LuaValue>): LuaValue {
    let text = prebindStr(args, 0)
    let nullValue = if (args.size > 1) { args[1] } else { LuaValue.Nil }
    return _jsonAnyToLua(vm, _jsonReadAny(text), nullValue, 0)
}

/**
 * @brief[zh-cn] 用引擎 JSON 读取器解析任意 JSON 文本
 * @param[zh-cn] text JSON 文本
 * @return[zh-cn] 解析结果（HashMap / ArrayList / 基本值；null 为 Option None）
 * @throws[zh-cn] Exception 文本非法或存在尾随内容
 *
 * @brief[en] Parses arbitrary JSON text with the engine JSON reader
 * @param[en] text JSON text
 * @return[en] The parsed value (HashMap / ArrayList / primitives; null is Option None)
 * @throws[en] Exception On invalid text or trailing content
 */
private func _jsonReadAny(text: String): Any {
    if (!_jsonStructureOk(text) || !_jsonTopLevelStartOk(text)) {
        throw Exception("invalid JSON text")
    }
    let reader = JsonStreamReader(ByteBuffer(text.toArray()))
    let value = JsonUtil.streamFromJsonForAny(reader)
    if (let Some(_token) <- reader.peek()) {
        throw Exception("trailing characters after JSON value")
    }
    return value
}

/**
 * @brief[zh-cn] 首个非空白字符必须是合法 JSON 值的起始字符
 * @explain[zh-cn] 引擎读取器把无法识别的首位字符回退为「无引号字符串」，为与严格 JSON 语义一致，
 * 这里只放行 { [ " t f n - 与数字。
 * @param[zh-cn] text JSON 文本
 * @return[zh-cn] true 表示起始字符合法
 *
 * @brief[en] The first non-whitespace character must start a legal JSON value
 * @explain[en] The engine reader falls back to an "unquoted string" for unrecognized leading
 * characters; to keep strict JSON semantics, only { [ " t f n - and digits are accepted.
 * @param[en] text JSON text
 * @return[en] true when the leading character is legal
 */
private func _jsonTopLevelStartOk(text: String): Bool {
    let bytes = text.toArray()
    let n = bytes.size
    var i: Int64 = 0
    while (i < n && bytes[i] <= 32u8) {
        i += 1
    }
    if (i >= n) {
        return false
    }
    let b = bytes[i]
    return b == b'{' || b == b'[' || b == b'"' || b == b't' || b == b'f' || b == b'n' ||
        b == b'-' || (b >= b'0' && b <= b'9')
}

/**
 * @brief[zh-cn] 结构完整性预检（括号配对、字符串闭合、非空内容）
 * @explain[zh-cn] 引擎读取器对截断输入较宽容（如 "[" 会被当作空数组结束），因此在交给读取器
 * 之前先做一次廉价的括号/字符串扫描：不校验取值合法性（那仍由引擎完成），只拒绝截断与括号错配，
 * 使 isValid / decode 的行为与严格 JSON 语义一致。
 * @param[zh-cn] text JSON 文本
 * @return[zh-cn] true 表示结构完整
 *
 * @brief[en] Cheap structural pre-check (bracket pairing, string termination, non-empty content)
 * @explain[en] The engine reader is lenient about truncated input (e.g. "[" is treated as an
 * empty array), so a cheap bracket/string scan runs before handing the text to the reader. It
 * does not validate value syntax (the engine still does) — it only rejects truncation and
 * mismatched brackets so isValid / decode match strict JSON semantics.
 * @param[en] text JSON text
 * @return[en] true when the structure is complete
 */
private func _jsonStructureOk(text: String): Bool {
    let bytes = text.toArray()
    let n = bytes.size
    let stack = ArrayList<UInt8>()
    var hasValue = false
    var i: Int64 = 0
    while (i < n) {
        let b = bytes[i]
        if (b == b'"') {
            hasValue = true
            i += 1
            var closed = false
            while (i < n) {
                let c = bytes[i]
                if (c == b'\\') {
                    i += 2
                    continue
                }
                if (c == b'"') {
                    closed = true
                    i += 1
                    break
                }
                i += 1
            }
            if (!closed) {
                return false
            }
            continue
        }
        if (b == b'{' || b == b'[') {
            hasValue = true
            stack.add(b)
        } else if (b == b'}' || b == b']') {
            if (stack.isEmpty()) {
                return false
            }
            let open = stack.remove(at: stack.size - 1)
            if ((b == b'}' && open != b'{') || (b == b']' && open != b'[')) {
                return false
            }
        } else if (b > 32u8) {
            hasValue = true
        }
        i += 1
    }
    return hasValue && stack.isEmpty()
}

/**
 * @brief[zh-cn] 判断 JSON 文本是否可解析
 * @param[zh-cn] args 参数（0 = 文本）
 * @return[zh-cn] true 表示可解析
 *
 * @brief[en] Checks whether the JSON text is parsable
 * @param[en] args Arguments (0 = text)
 * @return[en] true when parsable
 */
private func _jsonIsValid(args: Array<LuaValue>): Bool {
    try {
        _jsonReadAny(prebindStr(args, 0))
        return true
    } catch (_: Exception) {
        return false
    }
}

/**
 * @brief[zh-cn] 递归把引擎动态 JSON 值转换为 Lua 值
 * @param[zh-cn] vm 目标虚拟机（构造表需要）
 * @param[zh-cn] v 引擎动态值（HashMap / ArrayList / Bool / Int64 / Float64 / String / None）
 * @param[zh-cn] nullValue null 的 Lua 表示
 * @param[zh-cn] depth 当前嵌套深度
 * @return[zh-cn] 对应的 Lua 值
 * @throws[zh-cn] Exception 嵌套过深
 *
 * @brief[en] Recursively converts an engine dynamic JSON value into a Lua value
 * @param[en] vm The target virtual machine (needed to build tables)
 * @param[en] v The engine dynamic value (HashMap / ArrayList / Bool / Int64 / Float64 /
 *            String / None)
 * @param[en] nullValue The Lua representation of null
 * @param[en] depth Current nesting depth
 * @return[en] The corresponding Lua value
 * @throws[en] Exception When nesting is too deep
 */
private func _jsonAnyToLua(vm: LuaVM, v: Any, nullValue: LuaValue, depth: Int64): LuaValue {
    if (depth > JSON_DEFAULT_MAX_DEPTH) {
        throw Exception("json decode depth exceeded")
    }
    match (v) {
        case b: Bool => return LuaValue.Boolean(b)
        case i: Int64 => return LuaValue.Integer(i)
        case f: Float64 => return LuaValue.Number(f)
        case s: String => return LuaValue.Str(s)
        case list: ArrayList<Any> =>
            let n = list.size
            var elems = Array<LuaValue>(n, { _ => LuaValue.Nil })
            var i: Int64 = 0
            for (item in list) {
                elems[i] = _jsonAnyToLua(vm, item, nullValue, depth + 1)
                i += 1
            }
            return LuaValue.Array(elems)
        case map: HashMap<String, Any> =>
            let table = LuaTable.create(vm, nrec: Int32(map.size))
            for ((key, item) in map) {
                table.set(key, _jsonAnyToLua(vm, item, nullValue, depth + 1))
            }
            return LuaValue.Table(Int64(table.ref))
        case _ =>
            // Option None（JSON null）以及其它无法映射的类型统一按 null 处理
            return nullValue
    }
}

// =============================================================================
// 编码：Lua 值 → JSON 文本
// =============================================================================

/**
 * @brief[zh-cn] 把 Lua 值序列化为 JSON 文本
 * @param[zh-cn] vm 目标虚拟机（读取 Lua 表需要）
 * @param[zh-cn] args 参数（0 = 值，1 = 可选 opts 表）
 * @return[zh-cn] JSON 文本
 * @throws[zh-cn] Exception 值类型不支持或嵌套过深
 *
 * @brief[en] Serializes a Lua value into JSON text
 * @param[en] vm The target virtual machine (needed to read Lua tables)
 * @param[en] args Arguments (0 = value, 1 = optional opts table)
 * @return[en] JSON text
 * @throws[en] Exception On unsupported value types or excessive nesting
 */
private func _jsonStringify(vm: LuaVM, args: Array<LuaValue>): String {
    let L = vm.handle()
    if (lua_checkstack_cj(L, 32) == 0) {
        throw Exception("json encode: Lua stack overflow")
    }
    let baseTop = lua_gettop_cj(L)
    let opts = _jsonReadOpts(vm, L, args)
    let value = if (args.size > 0) { args[0] } else { LuaValue.Nil }
    LuaVM.pushValue(L, value)
    let stream = ByteBuffer()
    let writer = JsonStreamWriter(stream)
    if (!opts.indentUnit.isEmpty()) {
        var cfg = WriteConfig.compact
        cfg.newline = "\n"
        cfg.indent = opts.indentUnit
        cfg.useSpaceAfterSeparators = true
        writer.writeConfig = cfg
    }
    try {
        _jsonWriteAt(L, writer, opts, -1, 0)
        writer.flush()
    } finally {
        lua_settop_cj(L, baseTop)
    }
    return String.fromUtf8(readToEnd(stream))
}

/**
 * @brief[zh-cn] 读取 Lua 侧 opts 表
 * @param[zh-cn] vm 目标虚拟机（读取表需要）
 * @param[zh-cn] L 底层 lua_State 句柄（null 哨兵需压栈以做身份比较）
 * @param[zh-cn] args 参数（1 = opts 表）
 * @return[zh-cn] 解析后的选项；无 opts 时返回缺省配置
 *
 * @brief[en] Reads the Lua opts table
 * @param[en] vm The target virtual machine (needed to read tables)
 * @param[en] L The underlying lua_State handle (the null sentinel is pushed for identity
 *            comparison)
 * @param[en] args Arguments (1 = opts table)
 * @return[en] The parsed options; defaults when no opts table is given
 */
private func _jsonReadOpts(vm: LuaVM, L: CPointer<Unit>, args: Array<LuaValue>): JsonWriteOpts {
    let opts = JsonWriteOpts()
    if (args.size < 2 || !args[1].isTable) {
        return opts
    }
    let table = LuaTable(vm: vm, ref: Int32(args[1].refId()))
    let pretty = table.get("pretty")
    if (pretty.isBool && pretty.boolValue()) {
        opts.indentUnit = "  "
    } else if (pretty.isNumber) {
        let width = pretty.intValue()
        if (width > 0) {
            opts.indentUnit = String(Array<Rune>(width, { _ => r' ' }))
        }
    }
    let indent = table.get("indent")
    if (indent.isString && !indent.stringValue().isEmpty()) {
        opts.indentUnit = indent.stringValue()
    }
    let sortKeys = table.get("sortKeys")
    opts.sortKeys = sortKeys.isBool && sortKeys.boolValue()
    let ignoreNull = table.get("ignoreNull")
    opts.ignoreNull = ignoreNull.isBool && ignoreNull.boolValue()
    let maxDepth = table.get("maxDepth")
    if (maxDepth.isNumber && maxDepth.intValue() > 0) {
        opts.maxDepth = maxDepth.intValue()
    }
    let nullValue = table.get("nullValue")
    if (!nullValue.isNil) {
        LuaVM.pushValue(L, nullValue)
        opts.nullIndex = lua_gettop_cj(L)
    }
    return opts
}

/**
 * @brief[zh-cn] 把栈上 idx 处的 Lua 值写入 JSON 输出
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] writer JSON 流写入器
 * @param[zh-cn] opts 输出选项
 * @param[zh-cn] idx 值所在的栈索引（可为相对索引）
 * @param[zh-cn] depth 当前嵌套深度
 * @throws[zh-cn] Exception 类型不支持 / 嵌套过深 / Lua 栈不足
 *
 * @brief[en] Writes the Lua value at stack index idx into the JSON output
 * @param[en] L The underlying lua_State handle
 * @param[en] writer The JSON stream writer
 * @param[en] opts Output options
 * @param[en] idx The stack index of the value (relative indices allowed)
 * @param[en] depth Current nesting depth
 * @throws[en] Exception On unsupported types / excessive nesting / Lua stack shortage
 */
private func _jsonWriteAt(L: CPointer<Unit>, writer: JsonStreamWriter, opts: JsonWriteOpts, idx: Int32,
                          depth: Int64): Unit {
    if (depth > opts.maxDepth) {
        throw Exception("json encode depth exceeded (cycle?)")
    }
    if (lua_checkstack_cj(L, 8) == 0) {
        throw Exception("json encode: Lua stack overflow")
    }
    // null 哨兵按 JSON null 输出
    if (opts.nullIndex != 0 && lua_rawequal_cj(L, idx, opts.nullIndex) != 0) {
        writer.writeNullValue()
        return
    }
    match (lua_type_cj(L, idx)) {
        case 0 => writer.writeNullValue()                                    // nil
        case 1 => writer.writeValue<Bool>(lua_toboolean_cj(L, idx) != 0)     // boolean
        case 3 =>                                                            // number
            let n = lua_tonumber_cj(L, idx)
            let i = lua_tointeger_cj(L, idx)
            if (Float64(i) == n) {
                writer.writeValue<Int64>(i)
            } else {
                writer.writeValue<Float64>(n)
            }
        case 4 => writer.writeValue<String>(_jsonStackString(L, idx))         // string
        case 5 =>                                                            // table
            if (_jsonIsArray(L, idx)) {
                _jsonWriteArray(L, writer, opts, idx, depth)
            } else {
                _jsonWriteObject(L, writer, opts, idx, depth)
            }
        case _ => throw Exception("cannot encode value (Lua type ${lua_type_cj(L, idx)})")
    }
}

/**
 * @brief[zh-cn] 判断栈上表是否按数组输出
 * @explain[zh-cn] 优先看 metatable.__jsonArray 标记（serializer.array）；否则要求键恰为
 * 1..n 连续整数（n 为长度）。
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] idx 表所在栈索引
 * @return[zh-cn] true 表示数组
 *
 * @brief[en] Decides whether the table on the stack is emitted as an array
 * @explain[en] The metatable __jsonArray marker (set by serializer.array) wins; otherwise the
 * keys must be exactly the consecutive integers 1..n (n = length).
 * @param[en] L The underlying lua_State handle
 * @param[en] idx The stack index of the table
 * @return[en] true when it is an array
 */
private func _jsonIsArray(L: CPointer<Unit>, idx: Int32): Bool {
    if (lua_getmetatable_cj(L, idx) != 0) {
        _jsonPushString(L, "__jsonArray")
        lua_rawget_cj(L, -2)
        let marked = lua_type_cj(L, -1) != 0
        lua_settop_cj(L, -3)
        if (marked) {
            return true
        }
    }
    let tableIdx = _jsonAbsIndex(L, idx)
    let n = Int64(lua_objlen_cj(L, tableIdx))
    if (n == 0) {
        return false
    }
    var count: Int64 = 0
    var isSequence = true
    lua_pushnil_cj(L)
    while (lua_next_cj(L, tableIdx) != 0) {
        count += 1
        if (lua_type_cj(L, -2) == 3) {
            let number = lua_tonumber_cj(L, -2)
            let integer = lua_tointeger_cj(L, -2)
            if (Float64(integer) != number || integer < 1 || integer > n) {
                isSequence = false
            }
        } else {
            isSequence = false
        }
        lua_settop_cj(L, -2)
    }
    return isSequence && count == n
}

/**
 * @brief[zh-cn] 按数组输出栈上的表（元素为 nil 时输出 null）
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] writer JSON 流写入器
 * @param[zh-cn] opts 输出选项
 * @param[zh-cn] idx 表所在栈索引
 * @param[zh-cn] depth 当前嵌套深度
 *
 * @brief[en] Writes the table on the stack as an array (nil elements become null)
 * @param[en] L The underlying lua_State handle
 * @param[en] writer The JSON stream writer
 * @param[en] opts Output options
 * @param[en] idx The stack index of the table
 * @param[en] depth Current nesting depth
 */
private func _jsonWriteArray(L: CPointer<Unit>, writer: JsonStreamWriter, opts: JsonWriteOpts, idx: Int32,
                             depth: Int64): Unit {
    let tableIdx = _jsonAbsIndex(L, idx)
    let n = Int64(lua_objlen_cj(L, tableIdx))
    writer.startArray()
    var i: Int64 = 1
    while (i <= n) {
        lua_rawgeti_cj(L, tableIdx, Int32(i))
        _jsonWriteAt(L, writer, opts, -1, depth + 1)
        lua_settop_cj(L, -2)
        i += 1
    }
    writer.endArray()
}

/**
 * @brief[zh-cn] 按对象输出栈上的表（键按字符串写出）
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] writer JSON 流写入器
 * @param[zh-cn] opts 输出选项
 * @param[zh-cn] idx 表所在栈索引
 * @param[zh-cn] depth 当前嵌套深度
 *
 * @brief[en] Writes the table on the stack as an object (keys are written as strings)
 * @param[en] L The underlying lua_State handle
 * @param[en] writer The JSON stream writer
 * @param[en] opts Output options
 * @param[en] idx The stack index of the table
 * @param[en] depth Current nesting depth
 */
private func _jsonWriteObject(L: CPointer<Unit>, writer: JsonStreamWriter, opts: JsonWriteOpts, idx: Int32,
                              depth: Int64): Unit {
    let tableIdx = _jsonAbsIndex(L, idx)
    writer.startObject()
    if (opts.sortKeys) {
        _jsonWriteObjectSorted(L, writer, opts, tableIdx, depth)
    } else {
        lua_pushnil_cj(L)
        while (lua_next_cj(L, tableIdx) != 0) {
            // 键在 -2，值在 -1
            let keyType = lua_type_cj(L, -2)
            if ((keyType != 3 && keyType != 4) || _jsonSkipEntry(L, opts, -1)) {
                lua_settop_cj(L, -2)
                continue
            }
            let name = if (keyType == 4) { _jsonStackString(L, -2) } else { _jsonNumberKey(L, -2) }
            writer.writeName(name)
            _jsonWriteAt(L, writer, opts, -1, depth + 1)
            lua_settop_cj(L, -2)
        }
    }
    writer.endObject()
}

/**
 * @brief[zh-cn] 按键字典序输出对象（先收集键再排序写值）
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] writer JSON 流写入器
 * @param[zh-cn] opts 输出选项
 * @param[zh-cn] tableIdx 表在栈上的绝对索引
 * @param[zh-cn] depth 当前嵌套深度
 *
 * @brief[en] Writes an object with keys sorted lexicographically (collect keys first)
 * @param[en] L The underlying lua_State handle
 * @param[en] writer The JSON stream writer
 * @param[en] opts Output options
 * @param[en] tableIdx The absolute stack index of the table
 * @param[en] depth Current nesting depth
 */
private func _jsonWriteObjectSorted(L: CPointer<Unit>, writer: JsonStreamWriter, opts: JsonWriteOpts,
                                    tableIdx: Int32, depth: Int64): Unit {
    let names = ArrayList<String>()
    let intKeys = ArrayList<Int64>()
    let isIntegers = ArrayList<Bool>()
    lua_pushnil_cj(L)
    while (lua_next_cj(L, tableIdx) != 0) {
        let keyType = lua_type_cj(L, -2)
        if (keyType == 4) {
            names.add(_jsonStackString(L, -2))
            intKeys.add(0)
            isIntegers.add(false)
        } else if (keyType == 3) {
            let number = lua_tonumber_cj(L, -2)
            let integer = lua_tointeger_cj(L, -2)
            names.add(if (Float64(integer) == number) { integer.toString() } else { number.toString() })
            intKeys.add(integer)
            isIntegers.add(Float64(integer) == number)
        }
        lua_settop_cj(L, -2)
    }
    // 插入排序：按显示名字典序（键数量通常很小）
    let total = names.size
    let order = ArrayList<Int64>()
    for (k in 0..total) {
        order.add(k)
    }
    var a: Int64 = 1
    while (a < total) {
        let current = order[a]
        var b = a - 1
        while (b >= 0 && names[order[b]] > names[current]) {
            order[b + 1] = order[b]
            b -= 1
        }
        order[b + 1] = current
        a += 1
    }
    for (k in 0..total) {
        let i = order[k]
        if (isIntegers[i]) {
            lua_pushinteger_cj(L, intKeys[i])
        } else {
            _jsonPushString(L, names[i])
        }
        lua_rawget_cj(L, tableIdx)
        if (_jsonSkipEntry(L, opts, -1)) {
            lua_settop_cj(L, -2)
            continue
        }
        writer.writeName(names[i])
        _jsonWriteAt(L, writer, opts, -1, depth + 1)
        lua_settop_cj(L, -2)
    }
}

/**
 * @brief[zh-cn] 判断对象字段是否应跳过（ignoreNull 且值为 nil/null 哨兵）
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] opts 输出选项
 * @param[zh-cn] idx 值所在栈索引
 * @return[zh-cn] true 表示跳过
 *
 * @brief[en] Decides whether an object field should be skipped (ignoreNull and the value is
 * nil or the null sentinel)
 * @param[en] L The underlying lua_State handle
 * @param[en] opts Output options
 * @param[en] idx The stack index of the value
 * @return[en] true when it should be skipped
 */
private func _jsonSkipEntry(L: CPointer<Unit>, opts: JsonWriteOpts, idx: Int32): Bool {
    if (!opts.ignoreNull) {
        return false
    }
    if (lua_type_cj(L, idx) == 0) {
        return true
    }
    return opts.nullIndex != 0 && lua_rawequal_cj(L, idx, opts.nullIndex) != 0
}

/**
 * @brief[zh-cn] 读取栈上数字键的显示名
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] idx 键所在栈索引
 * @return[zh-cn] 键的字符串形式（整数不带小数）
 *
 * @brief[en] Reads the display name of a numeric key on the stack
 * @param[en] L The underlying lua_State handle
 * @param[en] idx The stack index of the key
 * @return[en] The string form of the key (integers without a decimal part)
 */
private func _jsonNumberKey(L: CPointer<Unit>, idx: Int32): String {
    let number = lua_tonumber_cj(L, idx)
    let integer = lua_tointeger_cj(L, idx)
    if (Float64(integer) == number) {
        return integer.toString()
    }
    return number.toString()
}

/**
 * @brief[zh-cn] 读取栈上字符串值
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] idx 值所在栈索引
 * @return[zh-cn] 字符串（转换失败返回空串）
 *
 * @brief[en] Reads a string value from the stack
 * @param[en] L The underlying lua_State handle
 * @param[en] idx The stack index of the value
 * @return[en] The string (empty when conversion fails)
 */
private func _jsonStackString(L: CPointer<Unit>, idx: Int32): String {
    let cs = lua_tolstring_cj(L, idx, CPointer<UIntNative>())
    if (cs.isNull()) {
        return ""
    }
    return unsafe { cs.toString() }
}

/**
 * @brief[zh-cn] 计算栈索引的绝对位置
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] idx 栈索引（正数为绝对索引，负数为相对索引）
 * @return[zh-cn] 绝对索引
 *
 * @brief[en] Computes the absolute position of a stack index
 * @param[en] L The underlying lua_State handle
 * @param[en] idx The stack index (positive = absolute, negative = relative)
 * @return[en] The absolute index
 */
private func _jsonAbsIndex(L: CPointer<Unit>, idx: Int32): Int32 {
    if (idx > 0) {
        return idx
    }
    return lua_gettop_cj(L) + idx + 1
}

/**
 * @brief[zh-cn] 把仓颉字符串压入 Lua 栈
 * @param[zh-cn] L 底层 lua_State 句柄
 * @param[zh-cn] s 待压入的字符串
 *
 * @brief[en] Pushes a Cangjie string onto the Lua stack
 * @param[en] L The underlying lua_State handle
 * @param[en] s The string to push
 */
private func _jsonPushString(L: CPointer<Unit>, s: String): Unit {
    let cs = unsafe { LibC.mallocCString(s) }
    lua_pushstring_cj(L, cs)
    unsafe { LibC.free(cs) }
}
