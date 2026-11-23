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
 * @file[zh-cn] core_dsa_lrucache 定容量 LRU 缓存 LruCache 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 LruCache<LuaValue, LuaValue> 实例化（LuaValue 已实现 Hashable &
 * Equatable<LuaValue>，满足 K 约束），键与值均为任意 Lua 值
 * @explain[zh-cn] LuaValue 在 three.script.vm 中实现了 Hashable / Equatable<LuaValue> /
 * Comparable<LuaValue>（数值语义：Number 与 Integer 按数值判等/哈希，Object/Table/Function
 * 按携带 id/ref 身份），因此带 Hashable & Equatable 约束的泛型类可用此"any 通道"绑定。
 * 覆盖构造（new / capacity+overwrite 可选）、只读属性（capacity/size/hits/misses/evictions）
 * 与全部公共方法（get/peek/contains/put/remove/clear/isEmpty/setCapacity/resetStats）。
 * 返回值型 get/peek/remove：Some→直接回传元素，None→nil。
 *
 * @file[en] core_dsa_lrucache  Lua binding of the fixed-capacity LRU cache LruCache (three.script.prebind)
 * @brief[en] Binds three.core.dsa.LruCache instantiated as LruCache<LuaValue, LuaValue>
 * (LuaValue implements Hashable & Equatable<LuaValue>, satisfying the K constraint);
 * both keys and values are arbitrary Lua values
 * @explain[en] LuaValue implements Hashable / Equatable<LuaValue> / Comparable<LuaValue> in
 * three.script.vm (numeric semantics: Number/Integer equal by value, Object/Table/Function by
 * carried id/ref identity), so generics constrained by Hashable & Equatable can be bound through
 * this "any" channel. Covers construction (new/capacity), read-only props
 * (capacity/size/hits/misses/evictions) and all public methods
 * (get/peek/contains/put/remove/clear/isEmpty/setCapacity/resetStats). Value-returning
 * get/peek/remove: Some→the element itself, None→nil.
 */
package three.script.prebind

import three.core.dsa.LruCache
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LruCache 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.LruCache）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LruCache
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.LruCache)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLruCache(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.LruCache")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size > 0) {
            LruCache<LuaValue, LuaValue>(args[0].intValue())
        } else {
            LruCache<LuaValue, LuaValue>()
        }
    }
    // ===== 属性 =====
    b.property("capacity", getter: Some({ref => LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().capacity)}))
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().size)}))
    b.property("hits", getter: Some({ref => LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().hits)}))
    b.property("misses", getter: Some({ref => LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().misses)}))
    b.property("evictions", getter: Some({ref => LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().evictions)}))
    // ===== 方法 =====
    b.method("setCapacity") {
        ref, args =>
            ref.cast<LruCache<LuaValue, LuaValue>>().setCapacity(args[0].intValue())
            []
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().isEmpty())]
    }
    b.method("get") {
        ref, args => match (ref.cast<LruCache<LuaValue, LuaValue>>().get(args[0])) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("peek") {
        ref, args => match (ref.cast<LruCache<LuaValue, LuaValue>>().peek(args[0])) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("contains") {
        ref, args => [LuaValue.of(ref.cast<LruCache<LuaValue, LuaValue>>().contains(args[0]))]
    }
    b.method("put") {
        ref, args =>
            ref.cast<LruCache<LuaValue, LuaValue>>().put(args[0], args[1])
            []
    }
    b.method("remove") {
        ref, args => match (ref.cast<LruCache<LuaValue, LuaValue>>().remove(args[0])) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<LruCache<LuaValue, LuaValue>>().clear()
            []
    }
    b.method("resetStats") {
        ref, _ =>
            ref.cast<LruCache<LuaValue, LuaValue>>().resetStats()
            []
    }
    b.install(vm)
}
