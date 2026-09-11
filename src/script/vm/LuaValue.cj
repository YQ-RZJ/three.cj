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
 * （内部经 luaL_ref 注册表引用保持有效），不放进本枚举。
 *
 * @file[en] LuaValue  Lua value type (three.script.vm sub-package)
 * @brief[en] Lua base value type unifying Lua-side primitive values
 * @explain[en] Represents Lua-side primitive values (nil/boolean/number/integer/string) used for
 * stack push/read and function arguments/results in LuaVM. Tables (LuaTable) and functions
 * (LuaFunction) are reference types wrapped by dedicated classes (kept alive via the
 * luaL_ref registry reference) and therefore are not part of this enum.
 *
 * @example[zh-cn] 设置与读取全局变量
 * @example[en] Setting and reading a global variable
 * let v: LuaValue = LuaValue.Number(42.0)
 * vm.setGlobal("answer", v)
 * let back = vm.getGlobal("answer")   // LuaValue.Number(42.0)
 */
package three.script.vm

/**
 * @brief[zh-cn] Lua 基础值类型
 * @explain[zh-cn] 覆盖 nil、布尔、浮点、整数与字符串五种基础值，提供类型判定与取值转换工具。
 *
 * @brief[en] Lua base value type
 * @explain[en] Covers five primitive kinds (nil, boolean, float, integer and string) with
 * type checks and value conversion helpers.
 */
public enum LuaValue {
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
     * @brief[zh-cn] 类型名称（对应 lua_typename：nil/boolean/number/string）
     *
     * @brief[en] Type name (matching lua_typename: nil/boolean/number/string)
     */
    public prop typeName: String {
        get() {
            match (this) {
                case Nil => "nil"
                case Boolean(_) => "boolean"
                case Number(_) | Integer(_) => "number"
                case Str(_) => "string"
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
     * @brief[zh-cn] 尝试取布尔值（非 Boolean 返回 default）
     * @param[zh-cn] default 类型不匹配时的默认值
     * @return[zh-cn] 布尔值或默认值
     *
     * @brief[en] Tries to read the boolean value (returns default when not a Boolean)
     * @param[en] default Fallback value when the type does not match
     * @return[en] The boolean value or the default
     */
    public func boolValue(default!: Bool = false): Bool {
        match (this) {
            case Boolean(b) => b
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
        match (this) {
            case Number(n) => n
            case Integer(i) => Float64(i)
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
        match (this) {
            case Integer(i) => i
            case Number(n) => Int64(n)
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
        match (this) {
            case Str(s) => s
            case _ => default
        }
    }

    /**
     * @brief[zh-cn] 是否为 nil
     *
     * @brief[en] Whether the value is nil
     */
    public prop isNil: Bool {
        get() {
            match (this) {
                case Nil => true
                case _ => false
            }
        }
    }
}
