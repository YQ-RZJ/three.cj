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
 * @file[zh-cn] core_dsa_queue 动态队列 Queue 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 Queue<LuaEquatableItem> 实例化（泛型"any 方式"；LuaEquatableItem 为
 * 透明包装，满足 T <: Equatable<T> 约束）绑定为 Lua 类型 three.core.dsa.Queue
 * @explain[zh-cn] 覆盖构造（new / 可选初始容量）、只读属性（size）与全部公共方法
 * （add/remove/peek/contains/isEmpty/clear/toArray）。返回 ?T 的 remove/peek：
 * Some→解包装直接回传元素（本就是 LuaValue），None→nil；contains 元素按 LuaValue
 * 结构相等比较；toArray 解包装后以 Lua 数组回传。iterator()（返回 Iterator，无 Lua
 * 通道）不绑定。
 *
 * @file[en] core_dsa_queue  Lua binding of the dynamic queue Queue (three.script.prebind)
 * @brief[en] Binds three.core.dsa.Queue instantiated as Queue<LuaEquatableItem> (the
 * generics "any" style; LuaEquatableItem is a transparent wrapper satisfying the
 * T <: Equatable<T> bound) into the Lua type three.core.dsa.Queue
 * @explain[en] Covers construction (new / optional initial capacity), read-only prop (size)
 * and all public methods (add/remove/peek/contains/isEmpty/clear/toArray). ?T returns:
 * Some→element unwrapped straight back (already a LuaValue), None→nil; contains compares
 * elements by LuaValue structural equality; toArray is unwrapped and returned as a Lua
 * array. iterator() (returns Iterator, no Lua channel) is not bound.
 */
package three.script.prebind

import three.core.dsa.Queue
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 满足 Queue/Stack 的 T <: Equatable<T> 约束的运行时透明包装
 * @explain[zh-cn] Cangjie 的 == 非通用运算符（类型须显式实现 Equatable 接口），LuaValue
 * 未实现，故以本包装作为泛型实参，并显式实现结构相等比较（按变体逐一比对，数组元素递归
 * 比较）；对 Lua 侧完全透明（入参包装、出参取 .value 还原）。Queue 与 Stack 两个绑定
 * 文件共用。
 *
 * @brief[en] Runtime-transparent wrapper satisfying the T <: Equatable<T> bound of
 * Queue/Stack
 * @explain[en] == is not a universal operator in Cangjie (types must explicitly implement
 * the Equatable interface), and LuaValue does not, so this wrapper is used as the generic
 * argument and implements structural equality explicitly (variant-by-variant comparison,
 * array elements compared recursively); fully transparent to Lua (wrapped on input,
 * unwrapped via .value on output). Shared by the Queue and Stack binding files.
 */
internal class LuaEquatableItem <: Equatable<LuaEquatableItem> {
    let value: LuaValue

    init(value: LuaValue) {
        this.value = value
    }

    public operator func ==(other: LuaEquatableItem): Bool {
        luaValueEq(this.value, other.value)
    }

    public operator func !=(other: LuaEquatableItem): Bool {
        !(this == other)
    }
}

/// 两个 LuaValue 的结构相等（委托 LuaValue 自身 Equatable 实现）
internal func luaValueEq(a: LuaValue, b: LuaValue): Bool {
    a == b
}

/// 两个 LuaValue 数组的元素逐一比较
internal func luaValueArrEq(x: Array<LuaValue>, y: Array<LuaValue>): Bool {
    if (x.size != y.size) {
        return false
    }
    for (i in 0..x.size) {
        if (!luaValueEq(x[i], y[i])) {
            return false
        }
    }
    return true
}

/**
 * @brief[zh-cn] 安装 Queue 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.Queue）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Queue
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.Queue)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installQueue(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.Queue")
    // ===== 构造 =====
    b.constructor {
        args => Queue<LuaEquatableItem>(capacity: prebindInt(args, 0, default: 16))
    }
    // ===== 属性 =====
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<Queue<LuaEquatableItem>>().size)}))
    // ===== 方法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Queue<LuaEquatableItem>>().add(LuaEquatableItem(args[0]))
            []
    }
    b.method("remove") {
        ref, _ => match (ref.cast<Queue<LuaEquatableItem>>().remove()) {
            case Some(v) => [v.value]
            case None => [LuaValue.Nil]
        }
    }
    b.method("peek") {
        ref, _ => match (ref.cast<Queue<LuaEquatableItem>>().peek()) {
            case Some(v) => [v.value]
            case None => [LuaValue.Nil]
        }
    }
    b.method("contains") {
        ref, args => [LuaValue.of(ref.cast<Queue<LuaEquatableItem>>().contains(LuaEquatableItem(args[0])))]
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<Queue<LuaEquatableItem>>().isEmpty())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<Queue<LuaEquatableItem>>().clear()
            []
    }
    b.method("toArray") {
        ref, _ =>
            let items = ref.cast<Queue<LuaEquatableItem>>().toArray()
            let values = Array<LuaValue>(items.size, {i => items[i].value})
            [LuaValue.of(values)]
    }
    b.install(vm)
}
