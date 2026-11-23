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
 * @file[zh-cn] core_event_eventdispatcher 事件分发器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.event.Event / ListenerHandle / EventDispatcher 绑定为
 * Lua 类型 three.core.event.Event / ListenerHandle / EventDispatcher
 * @explain[zh-cn] Event 绑定构造（type）、属性（type/target，target 为可空的分发器引用）；
 * ListenerHandle 仅注册类型表（callback 为函数类型字段，Lua 侧不可构造），供
 * addEventListener/on 返回的句柄回传与精确移除；EventDispatcher 绑定构造、
 * addEventListener/on（Lua 函数监听器经 LuaCallback 包装，回调收到注册的 Event 对象）、
 * removeEventListener/hasEventListener（含 1/2 参数两种重载）、dispatchEvent/emit。
 * 包装回调保持注册表引用不释放（与绑定框架参数读取行为一致），保证持久监听可用；
 * 移除监听后 Lua 侧函数引用仍驻留注册表（随 VM 关闭整体回收）。
 *
 * @file[en] core_event_eventdispatcher  Lua binding of the event dispatcher (three.script.prebind)
 * @brief[en] Binds three.core.event.Event / ListenerHandle / EventDispatcher as Lua types
 * three.core.event.Event / ListenerHandle / EventDispatcher
 * @explain[en] Event binds construction (type) and props (type/target, a nullable dispatcher
 * reference); ListenerHandle only registers its type table (its callback field is a function
 * type and not constructible from Lua), so handles returned by addEventListener/on round-trip
 * for precise removal; EventDispatcher binds construction, addEventListener/on (Lua function
 * listeners are wrapped via LuaCallback and receive a registered Event), removeEventListener/
 * hasEventListener (1- and 2-arg overloads) and dispatchEvent/emit. The wrapped callback keeps
 * its registry ref (consistent with the binding framework's arg reading) for persistent
 * listeners; registry refs released together with the VM on shutdown.
 */
package three.script.prebind

import std.collection.*
import three.core.event.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Event 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.event.Event）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Event
 * @param[en] vm The target virtual machine (class table installed at three.core.event.Event)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.event.Event")
    // ===== 构造 =====
    b.constructor { args => Event(args[0].stringValue()) }
    // ===== 属性 =====
    b.property("type",
        getter: Some({ ref => LuaValue.of(ref.cast<Event>().`type`) }),
        setter: Some({ ref, v => ref.cast<Event>().`type` = v.stringValue() }))
    b.property("target",
        getter: Some({ ref =>
            match (ref.cast<Event>().target) {
                case Some(t) => prebindRegister(t, "three.core.event.EventDispatcher")
                case None => LuaValue.Nil
            }
        }),
        setter: Some({ ref, v =>
            if (v.isObject) {
                ref.cast<Event>().target = Some(LuaObjectRegistry.getAs<EventDispatcher>(v.objectId()))
            } else {
                ref.cast<Event>().target = None
            }
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ListenerHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.event.ListenerHandle）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 仅为不透明句柄注册类型表（无 new / 方法 / 属性），使 addEventListener/
 * on 返回的句柄可安全回传 Lua 并用于 removeEventListener/hasEventListener 精确移除。
 *
 * @brief[en] Installs the Lua binding of ListenerHandle
 * @param[en] vm The target virtual machine (class table installed at three.core.event.ListenerHandle)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] Registers only the type table for the opaque handle (no new/method/property),
 * so handles returned by addEventListener/on round-trip into Lua for precise removal.
 */
public func installListenerHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.event.ListenerHandle")
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 EventDispatcher 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.event.EventDispatcher）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EventDispatcher
 * @param[en] vm The target virtual machine (class table installed at three.core.event.EventDispatcher)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEventDispatcher(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.event.EventDispatcher")
    // ===== 构造 =====
    b.constructor { _ => EventDispatcher() }
    // ===== 监听注册（Lua 函数经 LuaCallback 包装） =====
    b.method("addEventListener") { ref, args =>
        let typeName = prebindStr(args, 0)
        let listener = args[1]
        let handle = ref.cast<EventDispatcher>().addEventListener(typeName, { ev: Event =>
            let cb = LuaCallback.fromValue(vm, listener)
            if (let Some(c) <- cb) {
                c.call(args: [LuaValue.Object(LuaObjectRegistry.register(ev, "three.core.event.Event"))])
            }
        })
        [prebindRegister(handle, "three.core.event.ListenerHandle")]
    }
    b.method("on") { ref, args =>
        let typeName = prebindStr(args, 0)
        let listener = args[1]
        let handle = ref.cast<EventDispatcher>().on(typeName, { ev: Event =>
            let cb = LuaCallback.fromValue(vm, listener)
            if (let Some(c) <- cb) {
                c.call(args: [LuaValue.Object(LuaObjectRegistry.register(ev, "three.core.event.Event"))])
            }
        })
        [prebindRegister(handle, "three.core.event.ListenerHandle")]
    }
    // ===== 移除（1/2 参数两种重载） =====
    b.method("removeEventListener") { ref, args =>
        if (args.size >= 2) {
            ref.cast<EventDispatcher>().removeEventListener(prebindStr(args, 0), prebindAs<ListenerHandle>(args, 1))
        } else {
            ref.cast<EventDispatcher>().removeEventListener(prebindStr(args, 0))
        }
        []
    }
    b.method("off") { ref, args =>
        ref.cast<EventDispatcher>().off(prebindStr(args, 0), prebindAs<ListenerHandle>(args, 1))
        []
    }
    // ===== 查询（1/2 参数两种重载） =====
    b.method("hasEventListener") { ref, args =>
        if (args.size >= 2) {
            [LuaValue.of(ref.cast<EventDispatcher>().hasEventListener(prebindStr(args, 0), prebindAs<ListenerHandle>(args, 1)))]
        } else {
            [LuaValue.of(ref.cast<EventDispatcher>().hasEventListener(prebindStr(args, 0)))]
        }
    }
    // ===== 分发 =====
    b.method("dispatchEvent") { ref, args =>
        ref.cast<EventDispatcher>().dispatchEvent(prebindAs<Event>(args, 0))
        []
    }
    b.method("emit") { ref, args =>
        ref.cast<EventDispatcher>().emit(prebindStr(args, 0), prebindAs<Event>(args, 1))
        []
    }
    b.install(vm)
}