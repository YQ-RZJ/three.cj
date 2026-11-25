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
 * @file[zh-cn] LuaValue Lua 值类型（three.script.vm 子包）
 * @brief[zh-cn] Lua 基础值类型，统一表示 Lua 侧的基础值
 * @explain[zh-cn] 统一表示 Lua 侧的基础值（nil/boolean/number/integer/string），供 LuaVM 压栈/读取
 * 与函数参数/返回值使用。表（LuaTable）与函数（LuaFunction）是引用类型，使用独立类封装
 * （内部经 luaL_ref 注册表引用保持有效），不放进本类型。
 *
 * 实现形态：以「public struct + 内部 LuaVariant 枚举」代替单枚举，使 LuaValue 既能保持
 * 全部历史构造语法（LuaValue.Nil / LuaValue.Boolean(b) / ...，现为静态工厂与静态属性），
 * 又能携带可变成员（IHeapNode 的堆内索引 mut prop index），从而可作为 BinaryHeap 等
 * 约束了 IHeapNode 的泛型容器的元素（"any" 通道）。Hashable / Equatable / Comparable
 * 接口支持 LuaValue 作为 HashMap / HashSet / 排序容器的键值。
 *
 * @file[en] LuaValue  Lua value type (three.script.vm sub-package)
 * @brief[en] Lua base value type unifying Lua-side primitive values
 * @explain[en] Represents Lua-side primitive values (nil/boolean/number/integer/string) used for
 * stack push/read and function arguments/results in LuaVM. Tables (LuaTable) and functions
 * (LuaFunction) are reference types wrapped by dedicated classes (kept alive via the
 * luaL_ref registry reference) and therefore are not part of this type.
 *
 * Implementation shape: a "public struct + internal LuaVariant enum" replaces the single enum,
 * preserving every historical construction syntax (LuaValue.Nil / LuaValue.Boolean(b) / ...,
 * now static factories and a static property) while carrying mutable members (the heap index
 * mut prop index required by IHeapNode), so LuaValue can be used as the element type of
 * generics constrained by IHeapNode (the "any" channel, e.g. BinaryHeap). Hashable /
 * Equatable / Comparable enable using LuaValue as keys/values in HashMap / HashSet / sorted
 * containers.
 */
package three.script.vm

import three._vendor.luajit4cj.luajit.*
import std.core.Ordering
import three.core.dsa.IHeapNode
import three.utils.memory.VoidPtr

/**
 * @brief[zh-cn] LuaValue 内部变体（包内可见，外部勿直接依赖）
 * @explain[zh-cn] 保持全部历史变体：Nil/Boolean/Number/Integer/Str/Object/Array/Table/Function。
 * LuaValue struct 承载本变体，并提供同名静态工厂以保持构造语法兼容。
 *
 * @brief[en] Internal variant of LuaValue (package-visible; do not depend on it directly)
 * @explain[en] Keeps every historical variant: Nil/Boolean/Number/Integer/Str/Object/Array/
 * Table/Function. The LuaValue struct carries this variant and exposes same-named static
 * factories to keep construction syntax compatible.
 */
public enum LuaVariant {
    /**
     * @brief[zh-cn] nil（空值）
     *
     * @brief[en] nil (no value)
     */
    | Nil
    /**
     * @brief[zh-cn] 布尔值
     *
     * @brief[en] Boolean value
     */
    | Boolean(Bool)
    /**
     * @brief[zh-cn] 浮点数（Lua number）
     *
     * @brief[en] Float number (Lua number)
     */
    | Number(Float64)
    /**
     * @brief[zh-cn] 整数（LuaJIT 支持 64 位整数）
     *
     * @brief[en] Integer (LuaJIT supports 64-bit integers)
     */
    | Integer(Int64)
    /**
     * @brief[zh-cn] 字符串
     *
     * @brief[en] String
     */
    | Str(String)

    /**
     * @brief[zh-cn] 引擎对象引用（绑定到仓颉对象的 userdata）
     * @explain[zh-cn] id 为全局对象注册表索引（见 three.script.binding.LuaObjectRegistry）；
     * 绑定层负责 push/userdata 与读取。LuaValue 只承载 id，不直接持有仓颉对象。
     *
     * @brief[en] Engine object reference (userdata bound to a Cangjie object)
     * @explain[en] id is an index into the global object registry
     * (see three.script.binding.LuaObjectRegistry); the binding layer is responsible for
     * userdata push/read. LuaValue only carries the id and never owns the Cangjie object.
     */
    | Object(Int64)

    /**
     * @brief[zh-cn] 数组值（仓颉侧承载；压栈时转换为 1-based Lua table）
     * @explain[zh-cn] 元素为任意 LuaValue（可嵌套）；读取 Lua table 时经 LuaTable 访问，
     * 本变体用于仓颉 → Lua 方向的数组传参/传值。
     *
     * @brief[en] Array value (carried Cangjie-side; pushed as a 1-based Lua table)
     * @explain[en] Elements are arbitrary LuaValues (nested arrays allowed); Lua tables are
     * accessed via LuaTable on read, and this variant is used for Cangjie → Lua array
     * arguments/values.
     */
    | Array(Array<LuaValue>)

    /**
     * @brief[zh-cn] Lua 表引用（注册表 ref id）
     * @explain[zh-cn] refId 由 VM 读栈时经 luaL_ref 创建；使用者应在不再需要时调用
     * unrefValue(L) 成对释放（与 LuaTable 封装的 ref 同样管理）。
     *
     * @brief[en] Lua table reference (registry ref id)
     * @explain[en] refId is created by the VM via luaL_ref when reading the stack; callers
     * should pair it with unrefValue(L) when no longer needed (managed the same way as
     * LuaTable's ref).
     */
    | Table(Int64)

    /**
     * @brief[zh-cn] Lua 函数引用（注册表 ref id）
     * @explain[zh-cn] refId 由 VM 读栈时经 luaL_ref 创建；可经 LuaCallback.fromValue 包装后调用，
     * 不再需要时调用 unrefValue(L) 成对释放。
     *
     * @brief[en] Lua function reference (registry ref id)
     * @explain[en] refId is created by the VM via luaL_ref when reading the stack; can be wrapped
     * via LuaCallback.fromValue for calling, and paired with unrefValue(L) when no longer needed.
     */
    | Function(Int64)
}

/**
 * @brief[zh-cn] Lua 值类型
 * @explain[zh-cn] 覆盖 nil、布尔、浮点、整数、字符串、数组、表引用与函数引用。表（Table）
 * 与函数（Function）承载注册表引用（内部经 luaL_ref 保持有效，见 LuaTable/LuaFunction
 * 封装）；Array 为仓颉侧数组值（压栈时转换为 1-based Lua table）。
 *
 * 除全部历史变体构造语法外，还实现 IHeapNode（携带堆内索引 mut prop index），使本类型
 * 满足 BinaryHeap<T> where T <: IHeapNode 一类的泛型约束；Hashable / Equatable /
 * Comparable 供键值容器与排序使用。
 *
 * @brief[en] Lua value type
 * @explain[en] Covers nil, boolean, float, integer, string, array, table and function
 * references. Table/Function carry registry references (kept alive via luaL_ref, see
 * LuaTable/LuaFunction); Array is a Cangjie-side array value (pushed as a 1-based Lua table).
 *
 * Besides every historical variant constructor, it implements IHeapNode (carrying the mutable
 * heap index mut prop index) so the type satisfies generics constrained by
 * `where T <: IHeapNode` (e.g. BinaryHeap); Hashable / Equatable / Comparable serve keyed
 * containers and sorting.
 */
public struct LuaValue <: Hashable & Equatable<LuaValue> & Comparable<LuaValue> & IHeapNode {
    /** 内部变体 */
    private var _variant: LuaVariant
    /** IHeapNode：堆内索引，-1 表示不在堆中 */
    private var _heapIndex: Int64 = -1

    /**
     * @brief[zh-cn] 构造为空值（Nil）
     *
     * @brief[en] Constructs the nil value
     */
    public init() {
        _variant = LuaVariant.Nil
    }

    /**
     * @brief[zh-cn] 由内部变体构造（静态工厂内部使用）
     * @param[zh-cn] variant 内部变体
     *
     * @brief[en] Constructs from an internal variant (used by the static factories)
     * @param[en] variant The internal variant
     */
    private init(variant: LuaVariant) {
        _variant = variant
    }

    // ===== IHeapNode 实现 =====
    /**
     * @brief[zh-cn] 在堆中的索引（IHeapNode），-1 表示不在堆中
     *
     * @brief[en] Index in the heap (IHeapNode), -1 means not in the heap
     */
    public mut prop index: Int64 {
        get() { _heapIndex }
        set(v) { _heapIndex = v }
    }

    /**
     * @brief[zh-cn] 与另一个堆节点比较（IHeapNode）
     * @param[zh-cn] other 另一节点
     * @return[zh-cn] this 比 other 更优先（compare 为 LT）；other 非 LuaValue 时返回 false
     *
     * @brief[en] Compares with another heap node (IHeapNode)
     * @param[en] other The other node
     * @return[en] true when this has higher priority than other (compare is LT); false when other is not a LuaValue
     */
    public func lessThan(other: IHeapNode): Bool {
        if (other is LuaValue) {
            return this.compare((other as LuaValue).getOrThrow()) == Ordering.LT
        }
        return false
    }

    // ===== 变体构造（保持历史语法兼容） =====
    /**
     * @brief[zh-cn] nil（空值）
     *
     * @brief[en] nil (no value)
     */
    public static prop Nil: LuaValue {
        get() { LuaValue(LuaVariant.Nil) }
    }

    /**
     * @brief[zh-cn] 布尔值
     *
     * @brief[en] Boolean value
     */
    public static func Boolean(b: Bool): LuaValue {
        return LuaValue(LuaVariant.Boolean(b))
    }

    /**
     * @brief[zh-cn] 浮点数（Lua number）
     *
     * @brief[en] Float number (Lua number)
     */
    public static func Number(n: Float64): LuaValue {
        return LuaValue(LuaVariant.Number(n))
    }

    /**
     * @brief[zh-cn] 整数（LuaJIT 支持 64 位整数）
     *
     * @brief[en] Integer (LuaJIT supports 64-bit integers)
     */
    public static func Integer(i: Int64): LuaValue {
        return LuaValue(LuaVariant.Integer(i))
    }

    /**
     * @brief[zh-cn] 字符串
     *
     * @brief[en] String
     */
    public static func Str(s: String): LuaValue {
        return LuaValue(LuaVariant.Str(s))
    }

    /**
     * @brief[zh-cn] 引擎对象引用（绑定到仓颉对象的 userdata）
     * @param[zh-cn] id 全局对象注册表索引
     *
     * @brief[en] Engine object reference (userdata bound to a Cangjie object)
     * @param[en] id Index into the global object registry
     */
    public static func Object(id: Int64): LuaValue {
        return LuaValue(LuaVariant.Object(id))
    }

    /**
     * @brief[zh-cn] 数组值（仓颉侧承载；压栈时转换为 1-based Lua table）
     * @param[zh-cn] elems 任意 LuaValue 数组（可嵌套）
     *
     * @brief[en] Array value (carried Cangjie-side; pushed as a 1-based Lua table)
     * @param[en] elems Arbitrary LuaValue array (nested arrays allowed)
     */
    public static func Array(elems: Array<LuaValue>): LuaValue {
        return LuaValue(LuaVariant.Array(elems))
    }

    /**
     * @brief[zh-cn] Lua 表引用（注册表 ref id）
     * @param[zh-cn] ref 注册表引用
     *
     * @brief[en] Lua table reference (registry ref id)
     * @param[en] ref The registry reference
     */
    public static func Table(ref: Int64): LuaValue {
        return LuaValue(LuaVariant.Table(ref))
    }

    /**
     * @brief[zh-cn] Lua 函数引用（注册表 ref id）
     * @param[zh-cn] ref 注册表引用
     *
     * @brief[en] Lua function reference (registry ref id)
     * @param[en] ref The registry reference
     */
    public static func Function(ref: Int64): LuaValue {
        return LuaValue(LuaVariant.Function(ref))
    }

    /**
     * @brief[zh-cn] 类型名称（对应 lua_typename：nil/boolean/number/string/userdata/table/function）
     *
     * @brief[en] Type name (matching lua_typename: nil/boolean/number/string/userdata/table/function)
     */
    public prop typeName: String {
        get() {
            match (_variant) {
                case LuaVariant.Nil => "nil"
                case LuaVariant.Boolean(_) => "boolean"
                case LuaVariant.Number(_) | LuaVariant.Integer(_) => "number"
                case LuaVariant.Str(_) => "string"
                case LuaVariant.Object(_) => "userdata"
                case LuaVariant.Array(_) | LuaVariant.Table(_) => "table"
                case LuaVariant.Function(_) => "function"
            }
        }
    }

    /**
     * @brief[zh-cn] 便捷构造：从 Bool 装箱
     * @param[zh-cn] b 布尔值
     * @return[zh-cn] 对应的布尔类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes a Bool
     * @param[en] b The boolean value
     * @return[en] The corresponding boolean LuaValue
     */
    public static func of(b: Bool): LuaValue {
        return LuaValue.Boolean(b)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 Float64 装箱
     * @param[zh-cn] n 浮点值
     * @return[zh-cn] 对应的浮点类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes a Float64
     * @param[en] n The float value
     * @return[en] The corresponding number LuaValue
     */
    public static func of(n: Float64): LuaValue {
        return LuaValue.Number(n)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 Int64 装箱（整数）
     * @param[zh-cn] n 整数值
     * @return[zh-cn] 对应的整数类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes an Int64 (integer)
     * @param[en] n The integer value
     * @return[en] The corresponding integer LuaValue
     */
    public static func of(n: Int64): LuaValue {
        return LuaValue.Integer(n)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 String 装箱
     * @param[zh-cn] s 字符串
     * @return[zh-cn] 对应的字符串类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes a String
     * @param[en] s The string
     * @return[en] The corresponding string LuaValue
     */
    public static func of(s: String): LuaValue {
        return LuaValue.Str(s)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 Float64 数组装箱（→ Array 变体）
     * @param[zh-cn] arr 浮点数组
     * @return[zh-cn] 对应的数组类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes an Array<Float64> (→ Array variant)
     * @param[en] arr The float array
     * @return[en] The corresponding array LuaValue
     */
    public static func of(arr: Array<Float64>): LuaValue {
        let n = arr.size
        var out = Array<LuaValue>(n, { _ => LuaValue.Nil })
        for (i in 0..n) {
            out[i] = LuaValue.Number(arr[i])
        }
        return LuaValue.Array(out)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 Int64 数组装箱（→ Array 变体）
     * @param[zh-cn] arr 整数数组
     * @return[zh-cn] 对应的数组类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes an Array<Int64> (→ Array variant)
     * @param[en] arr The integer array
     * @return[en] The corresponding array LuaValue
     */
    public static func of(arr: Array<Int64>): LuaValue {
        let n = arr.size
        var out = Array<LuaValue>(n, { _ => LuaValue.Nil })
        for (i in 0..n) {
            out[i] = LuaValue.Integer(arr[i])
        }
        return LuaValue.Array(out)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 String 数组装箱（→ Array 变体）
     * @param[zh-cn] arr 字符串数组
     * @return[zh-cn] 对应的数组类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes an Array<String> (→ Array variant)
     * @param[en] arr The string array
     * @return[en] The corresponding array LuaValue
     */
    public static func of(arr: Array<String>): LuaValue {
        let n = arr.size
        var out = Array<LuaValue>(n, { _ => LuaValue.Nil })
        for (i in 0..n) {
            out[i] = LuaValue.Str(arr[i])
        }
        return LuaValue.Array(out)
    }

    /**
     * @brief[zh-cn] 便捷构造：从 LuaValue 数组装箱（→ Array 变体）
     * @param[zh-cn] arr 任意 LuaValue 数组
     * @return[zh-cn] 对应的数组类型 LuaValue
     *
     * @brief[en] Convenience constructor: boxes an Array<LuaValue> (→ Array variant)
     * @param[en] arr The LuaValue array
     * @return[en] The corresponding array LuaValue
     */
    public static func of(arr: Array<LuaValue>): LuaValue {
        return LuaValue.Array(arr)
    }

    /**
     * @brief[zh-cn] 尝试取布尔值（非 Boolean 返回 default）
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 布尔值或默认值
     *
     * @brief[en] Tries to read the boolean value (returns default when not a Boolean)
     * @param[en] default Fallback value when the type does not match
     * @return[en] The boolean value or the default
     */
    public func boolValue(default!: Bool = false): Bool {
        match (_variant) {
            case LuaVariant.Boolean(b) => b
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 尝试取浮点值（Number 直接取，Integer 转换，其余返回 default）
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 浮点值或默认值
     *
     * @brief[en] Tries to read the float value (Number taken directly, Integer converted, otherwise default)
     * @param[en] default Fallback value when the type does not match
     * @return[en] The float value or the default
     */
    public func numberValue(default!: Float64 = 0.0): Float64 {
        match (_variant) {
            case LuaVariant.Number(n) => n
            case LuaVariant.Integer(i) => Float64(i)
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 尝试取整数值（Integer 直接取，Number 截断，其余返回 default）
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 整数值或默认值
     *
     * @brief[en] Tries to read the integer value (Integer taken directly, Number truncated, otherwise default)
     * @param[en] default Fallback value when the type does not match
     * @return[en] The integer value or the default
     */
    public func intValue(default!: Int64 = 0): Int64 {
        match (_variant) {
            case LuaVariant.Integer(i) => i
            case LuaVariant.Number(n) => Int64(n)
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 尝试取字符串值（非 Str 返回 default）
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 字符串值或默认值
     *
     * @brief[en] Tries to read the string value (returns default when not a Str)
     * @param[en] default Fallback value when the type does not match
     * @return[en] The string value or the default
     */
    public func stringValue(default!: String = ""): String {
        match (_variant) {
            case LuaVariant.Str(s) => s
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 尝试取对象注册表 id（非 Object 返回 default）
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 对象注册表 id 或默认值
     *
     * @brief[en] Tries to read the object registry id (returns default when not an Object)
     * @param[en] default Fallback value when the type does not match
     * @return[en] The object registry id or the default
     */
    public func objectId(default!: Int64 = 0): Int64 {
        match (_variant) {
            case LuaVariant.Object(id) => id
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 是否为引擎对象引用
     *
     * @brief[en] Whether the value is an engine object reference
     */
    public prop isObject: Bool {
        get() {
            match (_variant) {
                case LuaVariant.Object(_) => true
                case _ => false
            }
        }
    }

    /**
     * @brief[zh-cn] 是否为 nil
     *
     * @brief[en] Whether the value is nil
     */
    public prop isNil: Bool {
        get() {
            match (_variant) {
                case LuaVariant.Nil => true
                case _ => false
            }
        }
    }

    /**
     * @brief[zh-cn] 是否为表引用（Table 变体）
     *
     * @brief[en] Whether the value is a table reference (Table variant)
     */
    public prop isTable: Bool {
        get() {
            match (_variant) {
                case LuaVariant.Table(_) => true
                case _ => false
            }
        }
    }

    /**
     * @brief[zh-cn] 是否为函数引用（Function 变体）
     *
     * @brief[en] Whether the value is a function reference (Function variant)
     */
    public prop isFunction: Bool {
        get() {
            match (_variant) {
                case LuaVariant.Function(_) => true
                case _ => false
            }
        }
    }

    /**
     * @brief[zh-cn] 取注册表引用 id（Table/Function 变体）；其余返回 default
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 注册表 ref id 或默认值
     *
     * @brief[en] Reads the registry reference id (Table/Function variants); otherwise returns default
     * @param[en] default Fallback value when the type does not match
     * @return[en] The registry ref id or the default
     */
    public func refId(default!: Int64 = 0): Int64 {
        match (_variant) {
            case LuaVariant.Table(ref) => ref
            case LuaVariant.Function(ref) => ref
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 取数组元素（Array 变体）；其余返回 default
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 数组元素或默认值
     *
     * @brief[en] Reads the array elements (Array variant); otherwise returns default
     * @param[en] default Fallback value when the type does not match
     * @return[en] The array elements or the default
     */
    public func arrayValues(default!: Array<LuaValue> = []): Array<LuaValue> {
        match (_variant) {
            case LuaVariant.Array(elems) => elems
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 数组转 Float64 原生数组（元素经 numberValue 转换，非数值取 0.0）
     * @return[zh-cn] 浮点数组；非 Array 变体返回空数组
     *
     * @brief[en] Converts the array to a native Float64 array (elements via numberValue, non-numbers become 0.0)
     * @return[en] The float array; empty when not an Array variant
     */
    public func toArrayFloat(): Array<Float64> {
        match (_variant) {
            case LuaVariant.Array(elems) =>
                let n = elems.size
                var out = Array<Float64>(n, { _ => 0.0 })
                for (i in 0..n) {
                    out[i] = elems[i].numberValue()
                }
                return out
            case _ => Array<Float64>()
        }
    }

    /**
     * @brief[zh-cn] 数组转 Int64 原生数组（元素经 intValue 转换，非整数值取 0）
     * @return[zh-cn] 整数数组；非 Array 变体返回空数组
     *
     * @brief[en] Converts the array to a native Int64 array (elements via intValue, non-integers become 0)
     * @return[en] The integer array; empty when not an Array variant
     */
    public func toArrayInt(): Array<Int64> {
        match (_variant) {
            case LuaVariant.Array(elems) =>
                let n = elems.size
                var out = Array<Int64>(n, { _ => 0 })
                for (i in 0..n) {
                    out[i] = elems[i].intValue()
                }
                return out
            case _ => Array<Int64>()
        }
    }

    /**
     * @brief[zh-cn] 数组转 String 原生数组（元素经 stringValue 转换，非字符串取 ""）
     * @return[zh-cn] 字符串数组；非 Array 变体返回空数组
     *
     * @brief[en] Converts the array to a native String array (elements via stringValue, non-strings become "")
     * @return[en] The string array; empty when not an Array variant
     */
    public func toArrayString(): Array<String> {
        match (_variant) {
            case LuaVariant.Array(elems) =>
                let n = elems.size
                var out = Array<String>(n, { _ => "" })
                for (i in 0..n) {
                    out[i] = elems[i].stringValue()
                }
                return out
            case _ => Array<String>()
        }
    }

    /**
     * @brief[zh-cn] 释放 Table/Function 变体的注册表引用（luaL_unref）
     * @explain[zh-cn] 仅当变体携带有效 ref（>0）时执行；非引用变体或 ref<=0 时无操作。
     * 与 VM 读栈时 luaL_ref 成对使用。
     * @param[zh-cn] L 底层 lua_State 句柄
     *
     * @brief[en] Releases the registry reference of a Table/Function variant (luaL_unref)
     * @explain[en] Only runs when the variant carries a valid ref (>0); no-op otherwise or
     * when ref<=0. Pairs with the luaL_ref created when the VM read the stack.
     * @param[en] L The underlying lua_State handle
     */
    public func unrefValue(L: VoidPtr): Unit {
        let lv = L.value
        if (lv.isNull()) { return }
        match (_variant) {
            case LuaVariant.Table(ref) =>
                if (ref > 0) {
                    luaL_unref_cj(lv, LUA_REGISTRYINDEX, Int32(ref))
                }
            case LuaVariant.Function(ref) =>
                if (ref > 0) {
                    luaL_unref_cj(lv, LUA_REGISTRYINDEX, Int32(ref))
                }
            case _ => () // 其他变体无引用可释放
        }
    }

    // =====================================================================
    // 接口实现：Hashable / Equatable<LuaValue> / Comparable<LuaValue>
    // =====================================================================
    /**
     * @brief[zh-cn] 计算哈希值（Hashable）
     * @explain[zh-cn] Number 与 Integer 按数值语义对齐（数值相同的键必得相同哈希）；
     * Object/Table/Function 按携带的整数 id / ref 参与散列；Array 递归散列。
     *
     * @brief[en] Computes the hash value (Hashable)
     * @explain[en] Number and Integer share one numeric-key semantics (numeric-equal keys
     * give the same hash); Object/Table/Function hash by their carried integer id/ref;
     * Array is hashed recursively.
     */
    public func hashCode(): Int64 {
        match (_variant) {
            case LuaVariant.Nil => 0
            case LuaVariant.Boolean(b) => if (b) { 1 } else { 2 }
            case LuaVariant.Number(n) => _luaNumberHash(n)
            case LuaVariant.Integer(i) => _luaNumberHash(Float64(i))
            case LuaVariant.Str(s) => _luaStrHash(s)
            case LuaVariant.Object(id) => 7 + id               // 注册表 id 全局唯一
            case LuaVariant.Array(elems) => _luaArrHash(elems)
            case LuaVariant.Table(ref) => 1009 + ref           // Lua 注册表 ref
            case LuaVariant.Function(ref) => 2003 + ref
        }
    }

    /**
     * @brief[zh-cn] 判等（Equatable<LuaValue>）
     * @explain[zh-cn] Number 与 Integer 按数值相等；Array 递归等长逐元素比较；
     * Object/Table/Function 按 id/ref 身份比较；其余变体按自身值比较。
     *
     * @brief[en] Equality (Equatable<LuaValue>)
     * @explain[en] Number and Integer compare numerically; Array compares length and
     * element-wise recursively; Object/Table/Function compare by id/ref identity;
     * the rest compare by their own value.
     */
    public operator func ==(rhs: LuaValue): Bool {
        match (_variant) {
            case LuaVariant.Nil => rhs.isNil
            case LuaVariant.Boolean(a) => rhs.isBool && rhs.boolValue() == a
            case LuaVariant.Number(a) => rhs.isNumber && rhs.numberValue() == a
            case LuaVariant.Integer(a) => rhs.isNumber && rhs.numberValue() == Float64(a)
            case LuaVariant.Str(a) => rhs.isString && rhs.stringValue() == a
            case LuaVariant.Object(a) => rhs.isObject && rhs.objectId() == a
            case LuaVariant.Array(a) => rhs.isArray && _luaArrEq(a, rhs.arrayValues())
            case LuaVariant.Table(a) => rhs.isTable && rhs.refId() == a
            case LuaVariant.Function(a) => rhs.isFunction && rhs.refId() == a
        }
    }

    /**
     * @brief[zh-cn] 判不等（Equatable<LuaValue>）
     *
     * @brief[en] Inequality (Equatable<LuaValue>)
     */
    public operator func !=(rhs: LuaValue): Bool {
        !(this == rhs)
    }

    /**
     * @brief[zh-cn] 比较序（Comparable<LuaValue>）
     * @explain[zh-cn] 定义全偏序：类型优先级 Nil<Bool<Number(含 Integer)<Str<Object<Array<Table<Function；
     * 同类型按值比较；Number/Integer 按数值；Array 逐元素。供堆/排序类泛型约束使用。
     *
     * @brief[en] Comparison order (Comparable<LuaValue>)
     * @explain[en] Defines a total order: rank Nil<Bool<Number(incl Integer)<Str<Object<Array<
     * Table<Function; equal-rank variants compare by value, Number/Integer numerically,
     * Array element-wise. Used by heap/sorting generic constraints.
     */
    public func compare(that: LuaValue): Ordering {
        let ra = this._luaRank()
        let rb = that._luaRank()
        if (ra != rb) {
            return if (ra < rb) { Ordering.LT } else { Ordering.GT }
        }
        match (_variant) {
            case LuaVariant.Nil => Ordering.EQ
            case LuaVariant.Boolean(a) =>
                let b = that.boolValue()
                if (a == b) { Ordering.EQ } else if (a) { Ordering.GT } else { Ordering.LT }
            case LuaVariant.Number(a) => _luaNumCompare(a, that.numberValue())
            case LuaVariant.Integer(a) => _luaNumCompare(Float64(a), that.numberValue())
            case LuaVariant.Str(a) =>
                let b = that.stringValue()
                if (a == b) { Ordering.EQ } else if (a < b) { Ordering.LT } else { Ordering.GT }
            case LuaVariant.Object(a) => _luaIntCompare(a, that.objectId())
            case LuaVariant.Array(a) => _luaArrCompare(a, that.arrayValues())
            case LuaVariant.Table(a) => _luaIntCompare(a, that.refId())
            case LuaVariant.Function(a) => _luaIntCompare(a, that.refId())
        }
    }

    /// 类型优先级（compare 用）
    private func _luaRank(): Int64 {
        match (_variant) {
            case LuaVariant.Nil => 0
            case LuaVariant.Boolean(_) => 1
            case LuaVariant.Number(_) | LuaVariant.Integer(_) => 2
            case LuaVariant.Str(_) => 3
            case LuaVariant.Object(_) => 4
            case LuaVariant.Array(_) => 5
            case LuaVariant.Table(_) => 6
            case LuaVariant.Function(_) => 7
        }
    }

    /// 是否为布尔变体
    public prop isBool: Bool {
        get() { match (_variant) { case LuaVariant.Boolean(_) => true; case _ => false } }
    }
    /// 是否为数值变体（Number/Integer）
    public prop isNumber: Bool {
        get() { match (_variant) { case LuaVariant.Number(_) | LuaVariant.Integer(_) => true; case _ => false } }
    }
    /// 是否为整数变体（Integer）
    public prop isInteger: Bool {
        get() { match (_variant) { case LuaVariant.Integer(_) => true; case _ => false } }
    }
    /// 是否为字符串变体
    public prop isString: Bool {
        get() { match (_variant) { case LuaVariant.Str(_) => true; case _ => false } }
    }
    /// 是否为数组变体
    public prop isArray: Bool {
        get() { match (_variant) { case LuaVariant.Array(_) => true; case _ => false } }
    }
}

// =============================================================================
// LuaValue 接口实现辅助（包内 private，Hashable/Equatable/Comparable 支撑）
// =============================================================================

/** Number/Integer 数值哈希：按 Float64 打散后取整（数值相等的键哈希一致） */
private func _luaNumberHash(n: Float64): Int64 {
    let scaled = n * 1000003.0
    return if (scaled >= 0.0) { Int64(scaled) } else { -Int64(-scaled) }
}

/** FNV-1a 64 位字符串哈希（与热更新实现一致，溢出回绕） */
@OverflowWrapping
private func _luaStrHash(s: String): Int64 {
    var h: UInt64 = 0xcbf29ce484222325
    for (c in s) {
        let b = UInt64(UInt32(c) & 0xFFu32)
        h = (h ^ b) * 0x100000001b3u64
    }
    return Int64(h)
}

/**
 * @brief[zh-cn] Array 变体递归哈希（溢出回绕）
 *
 * @brief[en] Recursive hash for the Array variant (with overflow wrapping)
 */
@OverflowWrapping
private func _luaArrHash(elems: Array<LuaValue>): Int64 {
    var h: Int64 = 17
    for (v in elems) {
        h = h * 31 + v.hashCode()
    }
    return h
}

/** Array 变体递归判等 */
private func _luaArrEq(a: Array<LuaValue>, b: Array<LuaValue>): Bool {
    if (a.size != b.size) {
        return false
    }
    for (i in 0..a.size) {
        if (!(a[i] == b[i])) {
            return false
        }
    }
    return true
}

/** Array 变体递归比较 */
private func _luaArrCompare(a: Array<LuaValue>, b: Array<LuaValue>): Ordering {
    let n = if (a.size < b.size) { a.size } else { b.size }
    for (i in 0..n) {
        let c = a[i].compare(b[i])
        if (c != Ordering.EQ) {
            return c
        }
    }
    return _luaIntCompare(a.size, b.size)
}

/** Float64 比较 */
private func _luaNumCompare(a: Float64, b: Float64): Ordering {
    if (a == b) {
        return Ordering.EQ
    }
    return if (a < b) { Ordering.LT } else { Ordering.GT }
}

/** Int64 比较 */
private func _luaIntCompare(a: Int64, b: Int64): Ordering {
    if (a == b) {
        return Ordering.EQ
    }
    return if (a < b) { Ordering.LT } else { Ordering.GT }
}