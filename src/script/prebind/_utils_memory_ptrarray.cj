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
 * @file[zh-cn] utils_memory_ptrarray PtrArray 泛型容器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 PtrArray<T> 按常用元素类型实例化绑定为 Lua 类型
 * @explain[zh-cn] PtrArray<T> 的 T 受 CType 约束、无法由 Lua 指定类型参数，
 * 因此按元素类型逐个实例化，Lua 侧类型名带元素后缀：
 * - three.utils.memory.PtrArrayInt32
 * - three.utils.memory.PtrArrayFloat32
 * - three.utils.memory.PtrArrayFloat64
 * - three.utils.memory.PtrArrayUInt8
 * - three.utils.memory.PtrArrayUInt16
 * - three.utils.memory.PtrArrayUInt32
 * 构造支持两种形态：new(size) 分配清零内存；new({v1, v2, ...}) 由数组值拷贝。
 * 除 Cangjie 的 size/get/set/toArray/release 外，额外提供绑定层便利成员：
 * - value：单元素便捷读写（等价 get(0)/set(0, v)）；
 * - values：整体数组读写（等价 toArray() / 由数组重建内容）；
 * - length：元素个数（只读）。
 * 绑定层成员标注为便利接口，语义与 Cangjie 成员一致。
 *
 * @file[en] utils_memory_ptrarray  Lua binding of the PtrArray generic container (three.script.prebind)
 * @brief[en] Instantiates and binds PtrArray<T> for the common element types
 * @explain[en] PtrArray<T> constrains T to CType, so Lua cannot pick the type argument; each
 * element type is instantiated explicitly and the Lua type name carries the element suffix:
 * - three.utils.memory.PtrArrayInt32
 * - three.utils.memory.PtrArrayFloat32
 * - three.utils.memory.PtrArrayFloat64
 * - three.utils.memory.PtrArrayUInt8
 * - three.utils.memory.PtrArrayUInt16
 * - three.utils.memory.PtrArrayUInt32
 * Construction accepts two forms: new(size) for a zeroed allocation, or new({v1, v2, ...})
 * to copy values from a Lua array. Besides the Cangjie size/get/set/toArray/release members,
 * binding-layer conveniences are provided: value (single-element convenience read/write),
 * values (whole-array read/write) and length (element count, read-only). These are marked
 * as convenience members and keep the Cangjie semantics.
 */
package three.script.prebind

import std.collection.*
import three.utils.memory.PtrArray
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取构造参数：数组值形态或元素个数
 * @param[zh-cn] args Lua 参数数组
 * @return[zh-cn] 元素个数（数组值形态返回数组长度，数字形态返回该数字，缺省为 1）
 *
 * @brief[en] Reads the construction argument: array values or element count
 * @param[en] args The Lua argument array
 * @return[en] Element count (array length for the array form, the number itself otherwise, 1 by default)
 */
private func _prebindPtrArraySize(args: Array<LuaValue>): Int64 {
    if (args.isEmpty()) {
        return 1
    }
    let v = args[0]
    if (v.isArray) {
        return Int64(v.arrayValues().size)
    }
    if (v.isTable) {
        return 1
    }
    let n = v.intValue(default: 1)
    return if (n > 0) {
        n
    } else {
        1
    }
}

/**
 * @brief[zh-cn] 判断构造参数是否为数组值形态
 * @param[zh-cn] args Lua 参数数组
 * @return[zh-cn] true 表示按数组值拷贝构造
 *
 * @brief[en] Whether the construction argument is the array-values form
 * @param[en] args The Lua argument array
 * @return[en] true when constructing by copying array values
 */
private func _prebindPtrArrayFromValues(args: Array<LuaValue>): Bool {
    if (args.isEmpty()) {
        return false
    }
    return args[0].isArray || args[0].isTable
}

/**
 * @brief[zh-cn] 安装 PtrArray<Int32> 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.PtrArrayInt32）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PtrArray<Int32>
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.PtrArrayInt32)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPtrArrayInt32(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.PtrArrayInt32")
    b.constructor {
        args => if (_prebindPtrArrayFromValues(args)) {
            let src = prebindArray(vm, args, 0)
            var values = Array<Int32>(src.size, {_ => 0})
            for (i in 0..src.size) {
                values[i] = Int32(src[i].intValue())
            }
            PtrArray<Int32>(values)
        } else {
            PtrArray<Int32>(_prebindPtrArraySize(args))
        }
    }
    b.method("size") {ref, _ => [LuaValue.of(ref.cast<PtrArray<Int32>>().size())]}
    b.method("get") {
        ref, args => [LuaValue.of(Int64(ref.cast<PtrArray<Int32>>().get(prebindInt(args, 0))))]
    }
    b.method("set") {
        ref, args =>
            ref.cast<PtrArray<Int32>>().set(prebindInt(args, 0), Int32(prebindInt(args, 1)))
            []
    }
    b.method("toArray") {
        ref, _ =>
            let n = ref.cast<PtrArray<Int32>>().size()
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(Int64(ref.cast<PtrArray<Int32>>().get(Int64(i))))
            }
            [LuaValue.Array(out)]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<PtrArray<Int32>>().release())]}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Int32>>().releasable)}))
    b.property("length", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Int32>>().size())}))
    b.property("value", getter: Some({ref => LuaValue.of(Int64(ref.cast<PtrArray<Int32>>().get(0)))}),
        setter: Some({ref, v => ref.cast<PtrArray<Int32>>().set(0, Int32(v.intValue()))}))
    b.property(
        "values",
        getter: Some(
            {
                ref =>
                    let n = ref.cast<PtrArray<Int32>>().size()
                    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
                    for (i in 0..n) {
                        out[i] = LuaValue.of(Int64(ref.cast<PtrArray<Int32>>().get(Int64(i))))
                    }
                    LuaValue.Array(out)
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let arr = ref.cast<PtrArray<Int32>>()
                    let values = prebindArray(vm, [v], 0)
                    let n = if (Int64(values.size) < arr.size()) {
                        Int64(values.size)
                    } else {
                        arr.size()
                    }
                    for (i in 0..n) {
                        arr.set(Int64(i), Int32(values[i].intValue()))
                    }
            }
        )
    )
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PtrArray<Float32> 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.PtrArrayFloat32）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PtrArray<Float32>
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.PtrArrayFloat32)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPtrArrayFloat32(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.PtrArrayFloat32")
    b.constructor {
        args => if (_prebindPtrArrayFromValues(args)) {
            let src = prebindArray(vm, args, 0)
            var values = Array<Float32>(src.size, {_ => 0.0f32})
            for (i in 0..src.size) {
                values[i] = Float32(src[i].numberValue())
            }
            PtrArray<Float32>(values)
        } else {
            PtrArray<Float32>(_prebindPtrArraySize(args))
        }
    }
    b.method("size") {ref, _ => [LuaValue.of(ref.cast<PtrArray<Float32>>().size())]}
    b.method("get") {
        ref, args => [LuaValue.of(Float64(ref.cast<PtrArray<Float32>>().get(prebindInt(args, 0))))]
    }
    b.method("set") {
        ref, args =>
            ref.cast<PtrArray<Float32>>().set(prebindInt(args, 0), Float32(prebindNum(args, 1)))
            []
    }
    b.method("toArray") {
        ref, _ =>
            let n = ref.cast<PtrArray<Float32>>().size()
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(Float64(ref.cast<PtrArray<Float32>>().get(Int64(i))))
            }
            [LuaValue.Array(out)]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<PtrArray<Float32>>().release())]}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Float32>>().releasable)}))
    b.property("length", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Float32>>().size())}))
    b.property("value", getter: Some({ref => LuaValue.of(Float64(ref.cast<PtrArray<Float32>>().get(0)))}),
        setter: Some({
            ref, v => ref.cast<PtrArray<Float32>>().set(0, Float32(v.numberValue()))
        }))
    b.property(
        "values",
        getter: Some(
            {
                ref =>
                    let n = ref.cast<PtrArray<Float32>>().size()
                    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
                    for (i in 0..n) {
                        out[i] = LuaValue.of(Float64(ref.cast<PtrArray<Float32>>().get(Int64(i))))
                    }
                    LuaValue.Array(out)
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let arr = ref.cast<PtrArray<Float32>>()
                    let values = prebindArray(vm, [v], 0)
                    let n = if (Int64(values.size) < arr.size()) {
                        Int64(values.size)
                    } else {
                        arr.size()
                    }
                    for (i in 0..n) {
                        arr.set(Int64(i), Float32(values[i].numberValue()))
                    }
            }
        )
    )
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PtrArray<Float64> 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.PtrArrayFloat64）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PtrArray<Float64>
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.PtrArrayFloat64)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPtrArrayFloat64(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.PtrArrayFloat64")
    b.constructor {
        args => if (_prebindPtrArrayFromValues(args)) {
            let src = prebindArray(vm, args, 0)
            var values = Array<Float64>(src.size, {_ => 0.0})
            for (i in 0..src.size) {
                values[i] = src[i].numberValue()
            }
            PtrArray<Float64>(values)
        } else {
            PtrArray<Float64>(_prebindPtrArraySize(args))
        }
    }
    b.method("size") {ref, _ => [LuaValue.of(ref.cast<PtrArray<Float64>>().size())]}
    b.method("get") {
        ref, args => [LuaValue.of(ref.cast<PtrArray<Float64>>().get(prebindInt(args, 0)))]
    }
    b.method("set") {
        ref, args =>
            ref.cast<PtrArray<Float64>>().set(prebindInt(args, 0), prebindNum(args, 1))
            []
    }
    b.method("toArray") {
        ref, _ =>
            let n = ref.cast<PtrArray<Float64>>().size()
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(ref.cast<PtrArray<Float64>>().get(Int64(i)))
            }
            [LuaValue.Array(out)]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<PtrArray<Float64>>().release())]}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Float64>>().releasable)}))
    b.property("length", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Float64>>().size())}))
    b.property("value", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<Float64>>().get(0))}),
        setter: Some({ref, v => ref.cast<PtrArray<Float64>>().set(0, v.numberValue())}))
    b.property(
        "values",
        getter: Some(
            {
                ref =>
                    let n = ref.cast<PtrArray<Float64>>().size()
                    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
                    for (i in 0..n) {
                        out[i] = LuaValue.of(ref.cast<PtrArray<Float64>>().get(Int64(i)))
                    }
                    LuaValue.Array(out)
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let arr = ref.cast<PtrArray<Float64>>()
                    let values = prebindArray(vm, [v], 0)
                    let n = if (Int64(values.size) < arr.size()) {
                        Int64(values.size)
                    } else {
                        arr.size()
                    }
                    for (i in 0..n) {
                        arr.set(Int64(i), values[i].numberValue())
                    }
            }
        )
    )
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PtrArray<UInt8> 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.PtrArrayUInt8）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PtrArray<UInt8>
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.PtrArrayUInt8)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPtrArrayUInt8(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.PtrArrayUInt8")
    b.constructor {
        args => if (_prebindPtrArrayFromValues(args)) {
            let src = prebindArray(vm, args, 0)
            var values = Array<UInt8>(src.size, {_ => 0u8})
            for (i in 0..src.size) {
                values[i] = UInt8(src[i].intValue() & 0xFF)
            }
            PtrArray<UInt8>(values)
        } else {
            PtrArray<UInt8>(_prebindPtrArraySize(args))
        }
    }
    b.method("size") {ref, _ => [LuaValue.of(ref.cast<PtrArray<UInt8>>().size())]}
    b.method("get") {
        ref, args => [LuaValue.of(Int64(ref.cast<PtrArray<UInt8>>().get(prebindInt(args, 0))))]
    }
    b.method("set") {
        ref, args =>
            ref.cast<PtrArray<UInt8>>().set(prebindInt(args, 0), UInt8(prebindInt(args, 1) & 0xFF))
            []
    }
    b.method("toArray") {
        ref, _ =>
            let n = ref.cast<PtrArray<UInt8>>().size()
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(Int64(ref.cast<PtrArray<UInt8>>().get(Int64(i))))
            }
            [LuaValue.Array(out)]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<PtrArray<UInt8>>().release())]}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<UInt8>>().releasable)}))
    b.property("length", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<UInt8>>().size())}))
    b.property("value", getter: Some({ref => LuaValue.of(Int64(ref.cast<PtrArray<UInt8>>().get(0)))}),
        setter: Some({ref, v => ref.cast<PtrArray<UInt8>>().set(0, UInt8(v.intValue() & 0xFF))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PtrArray<UInt16> 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.PtrArrayUInt16）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PtrArray<UInt16>
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.PtrArrayUInt16)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPtrArrayUInt16(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.PtrArrayUInt16")
    b.constructor {
        args => if (_prebindPtrArrayFromValues(args)) {
            let src = prebindArray(vm, args, 0)
            var values = Array<UInt16>(src.size, {_ => 0u16})
            for (i in 0..src.size) {
                values[i] = UInt16(src[i].intValue() & 0xFFFF)
            }
            PtrArray<UInt16>(values)
        } else {
            PtrArray<UInt16>(_prebindPtrArraySize(args))
        }
    }
    b.method("size") {ref, _ => [LuaValue.of(ref.cast<PtrArray<UInt16>>().size())]}
    b.method("get") {
        ref, args => [LuaValue.of(Int64(ref.cast<PtrArray<UInt16>>().get(prebindInt(args, 0))))]
    }
    b.method("set") {
        ref, args =>
            ref.cast<PtrArray<UInt16>>().set(prebindInt(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF))
            []
    }
    b.method("toArray") {
        ref, _ =>
            let n = ref.cast<PtrArray<UInt16>>().size()
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(Int64(ref.cast<PtrArray<UInt16>>().get(Int64(i))))
            }
            [LuaValue.Array(out)]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<PtrArray<UInt16>>().release())]}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<UInt16>>().releasable)}))
    b.property("length", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<UInt16>>().size())}))
    b.property("value", getter: Some({ref => LuaValue.of(Int64(ref.cast<PtrArray<UInt16>>().get(0)))}), setter: Some({
        ref, v => ref.cast<PtrArray<UInt16>>().set(0, UInt16(v.intValue() & 0xFFFF))
    }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PtrArray<UInt32> 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.PtrArrayUInt32）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PtrArray<UInt32>
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.PtrArrayUInt32)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPtrArrayUInt32(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.PtrArrayUInt32")
    b.constructor {
        args => if (_prebindPtrArrayFromValues(args)) {
            let src = prebindArray(vm, args, 0)
            var values = Array<UInt32>(src.size, {_ => 0u32})
            for (i in 0..src.size) {
                values[i] = UInt32(src[i].intValue() & 0xFFFFFFFF)
            }
            PtrArray<UInt32>(values)
        } else {
            PtrArray<UInt32>(_prebindPtrArraySize(args))
        }
    }
    b.method("size") {ref, _ => [LuaValue.of(ref.cast<PtrArray<UInt32>>().size())]}
    b.method("get") {
        ref, args => [LuaValue.of(Int64(ref.cast<PtrArray<UInt32>>().get(prebindInt(args, 0))))]
    }
    b.method("set") {
        ref, args =>
            ref.cast<PtrArray<UInt32>>().set(prebindInt(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF))
            []
    }
    b.method("toArray") {
        ref, _ =>
            let n = ref.cast<PtrArray<UInt32>>().size()
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(Int64(ref.cast<PtrArray<UInt32>>().get(Int64(i))))
            }
            [LuaValue.Array(out)]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<PtrArray<UInt32>>().release())]}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<UInt32>>().releasable)}))
    b.property("length", getter: Some({ref => LuaValue.of(ref.cast<PtrArray<UInt32>>().size())}))
    b.property("value", getter: Some({ref => LuaValue.of(Int64(ref.cast<PtrArray<UInt32>>().get(0)))}), setter: Some({
        ref, v => ref.cast<PtrArray<UInt32>>().set(0, UInt32(v.intValue() & 0xFFFFFFFF))
    }))
    b.install(vm)
}
