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
 * @file[zh-cn] core_dsa_circularqueue 循环队列 CircularQueue 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 CircularQueue<LuaValue> 实例化（泛型"any 方式"）绑定为 Lua 类型
 * three.core.dsa.CircularQueue，元素入参/出参均为任意 Lua 值
 * @explain[zh-cn] 覆盖构造（new / 空或指定初始容量）、只读属性（size）与全部公共方法
 * （add/remove/peek/next/isEmpty/clear/toArray）。返回 ?T 的 remove/peek/next：
 * Some→直接回传元素（本就是 LuaValue），None→nil；toArray 以 Lua 数组回传。
 *
 * @file[en] core_dsa_circularqueue  Lua binding of the circular queue (three.script.prebind)
 * @brief[en] Binds three.core.dsa.CircularQueue instantiated as CircularQueue<LuaValue> (the
 * generics "any" style) into the Lua type three.core.dsa.CircularQueue; elements are
 * arbitrary Lua values in both directions
 * @explain[en] Covers construction (new / empty or initial capacity), read-only prop (size)
 * and all public methods (add/remove/peek/next/isEmpty/clear/toArray). ?T returns:
 * Some→element passed straight back (already a LuaValue), None→nil; toArray is returned as
 * a Lua array.
 */
package three.script.prebind

import three.core.dsa.CircularQueue
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CircularQueue 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.CircularQueue）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CircularQueue
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.CircularQueue)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCircularQueue(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.CircularQueue")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 1) {
            CircularQueue<LuaValue>(args[0].intValue())
        } else {
            CircularQueue<LuaValue>()
        }
    }
    // ===== 属性 =====
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<CircularQueue<LuaValue>>().size)}))
    // ===== 方法 =====
    b.method("add") {
        ref, args =>
            ref.cast<CircularQueue<LuaValue>>().add(args[0])
            []
    }
    b.method("remove") {
        ref, _ => match (ref.cast<CircularQueue<LuaValue>>().remove()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("peek") {
        ref, _ => match (ref.cast<CircularQueue<LuaValue>>().peek()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("next") {
        ref, _ => match (ref.cast<CircularQueue<LuaValue>>().next()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<CircularQueue<LuaValue>>().isEmpty())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<CircularQueue<LuaValue>>().clear()
            []
    }
    b.method("toArray") {
        ref, _ => [LuaValue.of(ref.cast<CircularQueue<LuaValue>>().toArray())]
    }
    b.install(vm)
}
