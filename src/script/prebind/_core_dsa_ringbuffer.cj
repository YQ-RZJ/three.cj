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
 * @file[zh-cn] core_dsa_ringbuffer 环形缓冲区 RingBuffer 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 RingBuffer<LuaValue> 实例化（泛型"any 方式"）绑定为 Lua 类型
 * three.core.dsa.RingBuffer，元素入参/出参均为任意 Lua 值
 * @explain[zh-cn] 覆盖构造（new / capacity+overwrite 可选）、只读属性（size/capacity）与
 * 全部公共方法（add/remove/peek/peekLast/isEmpty/isFull/clear/get/toArray）。
 * 返回 ?T 的 remove/peek/peekLast/get：Some→直接回传元素（本就是 LuaValue），None→nil；
 * toArray 以 Lua 数组回传。iterator()（返回 Iterator，无 Lua 通道）不绑定。
 *
 * @file[en] core_dsa_ringbuffer  Lua binding of the ring buffer RingBuffer (three.script.prebind)
 * @brief[en] Binds three.core.dsa.RingBuffer instantiated as RingBuffer<LuaValue> (the
 * generics "any" style) into the Lua type three.core.dsa.RingBuffer; elements are arbitrary
 * Lua values in both directions
 * @explain[en] Covers construction (new / capacity+overwrite optional), read-only props
 * (size/capacity) and all public methods (add/remove/peek/peekLast/isEmpty/isFull/clear/
 * get/toArray). ?T returns: Some→element passed straight back (already a LuaValue), None→nil;
 * toArray is returned as a Lua array. iterator() (returns Iterator, no Lua channel) is not bound.
 */
package three.script.prebind

import three.core.dsa.RingBuffer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RingBuffer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.RingBuffer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RingBuffer
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.RingBuffer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRingBuffer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.RingBuffer")
    // ===== 构造 =====
    b.constructor {
        args => RingBuffer<LuaValue>(prebindInt(args, 0, default: 16), overwrite: prebindBool(args, 1, default: true))
    }
    // ===== 属性 =====
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<RingBuffer<LuaValue>>().size)}))
    b.property("capacity", getter: Some({ref => LuaValue.of(ref.cast<RingBuffer<LuaValue>>().capacity)}))
    // ===== 方法 =====
    b.method("add") {
        ref, args => [LuaValue.of(ref.cast<RingBuffer<LuaValue>>().add(args[0]))]
    }
    b.method("remove") {
        ref, _ => match (ref.cast<RingBuffer<LuaValue>>().remove()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("peek") {
        ref, _ => match (ref.cast<RingBuffer<LuaValue>>().peek()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("peekLast") {
        ref, _ => match (ref.cast<RingBuffer<LuaValue>>().peekLast()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<RingBuffer<LuaValue>>().isEmpty())]
    }
    b.method("isFull") {
        ref, _ => [LuaValue.of(ref.cast<RingBuffer<LuaValue>>().isFull())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<RingBuffer<LuaValue>>().clear()
            []
    }
    b.method("get") {
        ref, args => match (ref.cast<RingBuffer<LuaValue>>().get(args[0].intValue())) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("toArray") {
        ref, _ => [LuaValue.of(ref.cast<RingBuffer<LuaValue>>().toArray())]
    }
    b.install(vm)
}
