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
 * @file[zh-cn] core_event_eventfactory 事件记录与对象池的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.event.EventRecord / EventFactory 绑定为 Lua 类型
 * three.core.event.EventRecord / EventFactory
 * @explain[zh-cn] EventRecord 绑定构造与可读字段属性（id/name/once；target/callback 无
 * Lua 通道——target 为任意 Object 引用、callback 为函数类型）；EventFactory 绑定构造
 * （new/可选预热容量）、allocate（返回注册的 EventRecord）、recycle、只读属性
 * （allocatedCount/freeCount）与 clear。
 *
 * @file[en] core_event_eventfactory  Lua binding of the event record and object pool (three.script.prebind)
 * @brief[en] Binds three.core.event.EventRecord / EventFactory as Lua types
 * three.core.event.EventRecord / EventFactory
 * @explain[en] EventRecord binds construction and readable field props (id/name/once; target/
 * callback have no Lua channel — target is an arbitrary Object reference, callback a function
 * type); EventFactory binds construction (new / optional warm-up capacity), allocate (returns
 * a registered EventRecord), recycle, read-only props (allocatedCount/freeCount) and clear.
 */
package three.script.prebind

import three.core.event.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EventRecord 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.event.EventRecord）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EventRecord
 * @param[en] vm The target virtual machine (class table installed at three.core.event.EventRecord)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEventRecord(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.event.EventRecord")
    // ===== 构造 =====
    b.constructor { _ => EventRecord() }
    // ===== 属性（target/callback 无 Lua 通道，不绑定） =====
    b.property("id",
        getter: Some({ ref => LuaValue.of(ref.cast<EventRecord>().id) }),
        setter: Some({ ref, v => ref.cast<EventRecord>().id = v.intValue() }))
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<EventRecord>().name) }),
        setter: Some({ ref, v => ref.cast<EventRecord>().name = v.stringValue() }))
    b.property("once",
        getter: Some({ ref => LuaValue.of(ref.cast<EventRecord>().once) }),
        setter: Some({ ref, v => ref.cast<EventRecord>().once = v.boolValue() }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 EventFactory 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.event.EventFactory）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EventFactory
 * @param[en] vm The target virtual machine (class table installed at three.core.event.EventFactory)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEventFactory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.event.EventFactory")
    // ===== 构造 =====
    b.constructor { args =>
        if (args.size >= 1) { EventFactory(args[0].intValue()) } else { EventFactory() }
    }
    // ===== 方法 =====
    b.method("allocate") { ref, _ =>
        [prebindRegister(ref.cast<EventFactory>().allocate(), "three.core.event.EventRecord")]
    }
    b.method("recycle") { ref, args =>
        ref.cast<EventFactory>().recycle(prebindAs<EventRecord>(args, 0))
        []
    }
    // ===== 属性 =====
    b.property("allocatedCount", getter: Some({ ref => LuaValue.of(ref.cast<EventFactory>().allocatedCount) }))
    b.property("freeCount", getter: Some({ ref => LuaValue.of(ref.cast<EventFactory>().freeCount) }))
    b.method("clear") { ref, _ =>
        ref.cast<EventFactory>().clear()
        []
    }
    b.install(vm)
}