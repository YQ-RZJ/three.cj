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
 * @file[zh-cn] core_dsa_stack 动态栈 Stack 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 Stack<LuaEquatableItem> 实例化（泛型"any 方式"；LuaEquatableItem 为
 * 透明包装，满足 T <: Equatable<T> 约束）绑定为 Lua 类型 three.core.dsa.Stack
 * @explain[zh-cn] 覆盖构造（new / 空或指定初始容量）、只读属性（size）与全部公共方法
 * （add/remove/peek/contains/isEmpty/clear/toArray）。返回 ?T 的 remove/peek：
 * Some→解包装直接回传元素（本就是 LuaValue），None→nil；contains 元素按 LuaValue
 * 结构相等比较；toArray 解包装后以 Lua 数组回传。iterator()（返回 Iterator，无 Lua
 * 通道）不绑定。
 *
 * @file[en] core_dsa_stack  Lua binding of the dynamic stack Stack (three.script.prebind)
 * @brief[en] Binds three.core.dsa.Stack instantiated as Stack<LuaEquatableItem> (the
 * generics "any" style; LuaEquatableItem is a transparent wrapper satisfying the
 * T <: Equatable<T> bound) into the Lua type three.core.dsa.Stack
 * @explain[en] Covers construction (new / empty or initial capacity), read-only prop (size)
 * and all public methods (add/remove/peek/contains/isEmpty/clear/toArray). ?T returns:
 * Some→element unwrapped straight back (already a LuaValue), None→nil; contains compares
 * elements by LuaValue structural equality; toArray is unwrapped and returned as a Lua
 * array. iterator() (returns Iterator, no Lua channel) is not bound.
 */
package three.script.prebind

import three.core.dsa.Stack
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Stack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.Stack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Stack
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.Stack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installStack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.Stack")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 1) {
            Stack<LuaEquatableItem>(args[0].intValue())
        } else {
            Stack<LuaEquatableItem>()
        }
    }
    // ===== 属性 =====
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<Stack<LuaEquatableItem>>().size)}))
    // ===== 方法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Stack<LuaEquatableItem>>().add(LuaEquatableItem(args[0]))
            []
    }
    b.method("remove") {
        ref, _ => match (ref.cast<Stack<LuaEquatableItem>>().remove()) {
            case Some(v) => [v.value]
            case None => [LuaValue.Nil]
        }
    }
    b.method("peek") {
        ref, _ => match (ref.cast<Stack<LuaEquatableItem>>().peek()) {
            case Some(v) => [v.value]
            case None => [LuaValue.Nil]
        }
    }
    b.method("contains") {
        ref, args => [LuaValue.of(ref.cast<Stack<LuaEquatableItem>>().contains(LuaEquatableItem(args[0])))]
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<Stack<LuaEquatableItem>>().isEmpty())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<Stack<LuaEquatableItem>>().clear()
            []
    }
    b.method("toArray") {
        ref, _ =>
            let items = ref.cast<Stack<LuaEquatableItem>>().toArray()
            let values = Array<LuaValue>(items.size, {i => items[i].value})
            [LuaValue.of(values)]
    }
    b.install(vm)
}
