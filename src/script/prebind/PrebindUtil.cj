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
 * @file[zh-cn] prebind_util 绑定层内部工具（three.script.prebind）
 * @brief[zh-cn] prebind 各绑定文件共用的小工具（参数安全读取、对象注册为 Lua 值）
 * @explain[zh-cn] 本文件不绑定任何引擎类，仅提供内部（非 public）辅助函数，
 * 供 core_math_* 等绑定文件复用：带默认值的数值/整数读取、按 id 强转对象、
 * 新对象注册（clone 等返回新实例时使用）、可选参数安全下标。
 *
 * @file[en] prebind_util  Internal helpers for the binding layer (three.script.prebind)
 * @brief[en] Small shared helpers for prebind files (safe arg access, object→LuaValue)
 * @explain[en] This file binds no engine class; it only provides internal (non-public)
 * helpers reused by core_math_* binding files: defaulted number/int reads, object cast
 * by id, fresh-object registration (used when methods return new instances like clone)
 * and safe optional-argument indexing.
 */
package three.script.prebind

import three.script.vm.*
import three.script.binding.*
import three.core.math.*
import std.collection.*

/// 安全读取可选数值参数（越界或类型不对返回默认值）
internal func prebindNum(args: Array<LuaValue>, idx: Int64, default!: Float64 = 0.0): Float64 {
    if (args.size > idx) {
        return args[idx].numberValue(default: default)
    }
    return default
}

/// 安全读取可选整数参数（越界或类型不对返回默认值）
internal func prebindInt(args: Array<LuaValue>, idx: Int64, default!: Int64 = 0): Int64 {
    if (args.size > idx) {
        return args[idx].intValue(default: default)
    }
    return default
}

/// 安全读取可选布尔参数
internal func prebindBool(args: Array<LuaValue>, idx: Int64, default!: Bool = false): Bool {
    if (args.size > idx) {
        return args[idx].boolValue(default: default)
    }
    return default
}

/// 安全读取可选字符串参数
internal func prebindStr(args: Array<LuaValue>, idx: Int64, default!: String = ""): String {
    if (args.size > idx) {
        return args[idx].stringValue(default: default)
    }
    return default
}

/// 按对象 id 强转为 T（缺失或类型不符抛异常 → Lua 侧报错）
internal func prebindAs<T>(args: Array<LuaValue>, idx: Int64): T {
    return LuaObjectRegistry.getAs<T>(args[idx].objectId())
}

/// 按 LuaValue 携带的对象 id 强转为 T（属性 setter 等已持有单值场景）
internal func prebindAsValue<T>(v: LuaValue): T {
    return LuaObjectRegistry.getAs<T>(v.objectId())
}

/// 将新创建的仓颉对象注册到注册表并包装为 LuaValue.Object（clone/运算符等返回新实例场景）
internal func prebindRegister(obj: Any, className: String): LuaValue {
    return LuaValue.Object(LuaObjectRegistry.register(obj, className))
}

/// 读取 Lua 参数为元素数组：支持 Array 变体（直接取）与 Table 变体（经 LuaTable.getValues 读数组段）；
/// 其余类型返回空。
internal func prebindArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<LuaValue> {
    if (args.size <= idx) {
        return Array<LuaValue>()
    }
    let v = args[idx]
    if (v.isArray) {
        return v.arrayValues()
    }
    if (v.isTable) {
        let t = LuaTable(vm: vm, ref: Int32(v.refId()))
        return t.getValues()
    }
    return Array<LuaValue>()
}

/// 读取 Lua 数组参数为 UInt8 字节数组（元素经 intValue 取低 8 位；非数组/表返回空）
internal func prebindBytes(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<UInt8> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<UInt8>(n, {_ => 0u8})
    for (i in 0..n) {
        out[i] = UInt8(elems[i].intValue() & 0xFF)
    }
    return out
}

/// 读取 Lua 数组参数为 Float64 原生数组（元素经 numberValue 转换；非数组/表返回空）
internal func prebindFloatArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Float64> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<Float64>(n, {_ => 0.0})
    for (i in 0..n) {
        out[i] = elems[i].numberValue()
    }
    return out
}

/// 读取 Lua 数组参数为对象列表（元素须为已注册 Object，逐一 getAs<T> 转换）；
/// 非数组返回空。用于 setFromPoints(ArrayList<Vector3>) 类容器参数方法。
internal func prebindObjList<T>(vm: LuaVM, args: Array<LuaValue>, idx: Int64): ArrayList<T> {
    let out = ArrayList<T>()
    for (elem in prebindArray(vm, args, idx)) {
        if (elem.isObject) {
            out.add(LuaObjectRegistry.getAs<T>(elem.objectId()))
        }
    }
    return out
}

/// 将字节数组转为 Lua 数值数组（元素按 0~255 的整数呈现）
internal func prebindBytesToLua(src: Array<UInt8>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(Int64(src[i]))
    }
    return LuaValue.Array(out)
}

/// 将 Float32 数组转为 Lua 数值数组（元素按 Float64 呈现）
internal func prebindF32ArrayToLua(src: Array<Float32>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(Float64(src[i]))
    }
    return LuaValue.Array(out)
}

/// 读取 Lua 数组参数为 Float32 数组（元素经 numberValue 转换；非数组/表返回空）
internal func prebindF32Array(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Float32> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<Float32>(n, {_ => 0.0f32})
    for (i in 0..n) {
        out[i] = Float32(elems[i].numberValue())
    }
    return out
}

/// 读取可选回调参数（缺省 / nil / 非函数 → None；不抛异常，避免 lua_error 的 longjmp）
internal func prebindOptCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Option<LuaCallback> {
    if (args.size <= idx) {
        return None
    }
    return LuaCallback.fromValue(vm, args[idx])
}

/// 读取单个 LuaValue 为可选回调（非函数 → None）
internal func prebindOptCallbackOf(vm: LuaVM, v: LuaValue): Option<LuaCallback> {
    if (v.isNil) {
        return None
    }
    return LuaCallback.fromValue(vm, v)
}

/// 安全读取可选 Vector3 参数（缺失 / nil / 非对象返回默认值）
internal func prebindVec3(args: Array<LuaValue>, idx: Int64, default!: Vector3 = Vector3()): Vector3 {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return default
    }
    return LuaObjectRegistry.getAs<Vector3>(args[idx].objectId())
}

/// 安全读取可选 Quaternion 参数（缺失 / nil / 非对象返回默认值）
internal func prebindQuat(args: Array<LuaValue>, idx: Int64, default!: Quaternion = Quaternion()): Quaternion {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return default
    }
    return LuaObjectRegistry.getAs<Quaternion>(args[idx].objectId())
}

/// 读取 Lua 数组参数为 UInt32 数组（元素经 intValue 取低 32 位；非数组/表返回空）
internal func prebindU32Array(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<UInt32> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<UInt32>(n, {_ => 0u32})
    for (i in 0..n) {
        out[i] = UInt32(elems[i].intValue() & 0xFFFFFFFF)
    }
    return out
}

/// 将 UInt32 数组转为 Lua 数值数组（元素按 Float64 呈现）
internal func prebindU32ArrayToLua(src: Array<UInt32>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(Float64(src[i]))
    }
    return LuaValue.Array(out)
}

/// 读取 Lua 数组参数为 ArrayList<UInt32>（非数组/表返回空）
internal func prebindU32List(vm: LuaVM, args: Array<LuaValue>, idx: Int64): ArrayList<UInt32> {
    let out = ArrayList<UInt32>()
    for (v in prebindU32Array(vm, args, idx)) {
        out.add(v)
    }
    return out
}

/// 读取 Lua 数组参数为 ArrayList<Int64>（非数组/表返回空）
internal func prebindI64List(vm: LuaVM, args: Array<LuaValue>, idx: Int64): ArrayList<Int64> {
    let out = ArrayList<Int64>()
    for (v in prebindArray(vm, args, idx)) {
        out.add(v.intValue())
    }
    return out
}

/// 读取 Lua 数组参数为 ArrayList<Float64>（非数组/表返回空）
internal func prebindF64List(vm: LuaVM, args: Array<LuaValue>, idx: Int64): ArrayList<Float64> {
    let out = ArrayList<Float64>()
    for (v in prebindArray(vm, args, idx)) {
        out.add(v.numberValue())
    }
    return out
}

/// 将 ArrayList<UInt32> 转为 Lua 数值数组
internal func prebindU32ListToLua(src: ArrayList<UInt32>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(Float64(src[i]))
    }
    return LuaValue.Array(out)
}

/// 将 ArrayList<Int64> 转为 Lua 数值数组
internal func prebindI64ListToLua(src: ArrayList<Int64>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(src[i])
    }
    return LuaValue.Array(out)
}

/// 将 ArrayList<Float64> 转为 Lua 数值数组
internal func prebindF64ListToLua(src: ArrayList<Float64>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(src[i])
    }
    return LuaValue.Array(out)
}
