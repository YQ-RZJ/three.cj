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
 * @file[zh-cn] core_event_eventmanager 事件总线的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.event.EventManager 绑定为 Lua 类型 three.core.event.EventManager
 * @explain[zh-cn] 覆盖构造（new/可选对象池容量）、只读属性（listenerCount）、
 * send（name，可带目标对象过滤；data 为 Array<Object> 无 Lua 通道，缺省空数组）、
 * remove/removeByNameAndTarget/removeList/clear/countByName。
 * addEvent/addEventOnce 跳过：回调签名为 (Array<Object>) -> Unit，发送数据为任意引擎
 * 对象的数组，无法安全转换为 LuaValue（未知绑定类名会破坏 userdata 元表解析）。
 *
 * @file[en] core_event_eventmanager  Lua binding of the event bus (three.script.prebind)
 * @brief[en] Binds three.core.event.EventManager as the Lua type three.core.event.EventManager
 * @explain[en] Covers construction (new / optional pool capacity), the read-only prop
 * (listenerCount), send (name, with optional target-object filter; data is Array<Object> with
 * no Lua channel so it defaults to an empty array), remove/removeByNameAndTarget/removeList/
 * clear/countByName. addEvent/addEventOnce are omitted: their callback takes (Array<Object>)
 * whose payload is an array of arbitrary engine objects that cannot be safely transported to
 * Lua (unknown bound class names would break userdata metatable resolution).
 */
package three.script.prebind

import std.collection.*
import three.core.event.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EventManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.event.EventManager）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EventManager
 * @param[en] vm The target virtual machine (class table installed at three.core.event.EventManager)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEventManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.event.EventManager")
    // ===== 构造 =====
    b.constructor { args =>
        if (args.size >= 1) { EventManager(args[0].intValue()) } else { EventManager() }
    }
    // ===== 属性 =====
    b.property("listenerCount", getter: Some({ ref => LuaValue.of(ref.cast<EventManager>().listenerCount) }))
    // ===== 分发 =====
    b.method("send") { ref, args =>
        var targetOpt: ?Object = None
        if (args.size >= 2 && args[1].isObject) {
            targetOpt = Some(LuaObjectRegistry.getAs<Object>(args[1].objectId()))
        }
        ref.cast<EventManager>().send(prebindStr(args, 0), target: targetOpt)
        []
    }
    // ===== 移除 =====
    b.method("remove") { ref, args =>
        ref.cast<EventManager>().remove(prebindAs<EventRecord>(args, 0))
        []
    }
    b.method("removeByNameAndTarget") { ref, args =>
        ref.cast<EventManager>().removeByNameAndTarget(prebindStr(args, 0), prebindAs<Object>(args, 1))
        []
    }
    b.method("removeList") { ref, args =>
        ref.cast<EventManager>().removeList(prebindAs<Object>(args, 0))
        []
    }
    b.method("clear") { ref, _ =>
        ref.cast<EventManager>().clear()
        []
    }
    // ===== 查询 =====
    b.method("countByName") { ref, args =>
        [LuaValue.of(ref.cast<EventManager>().countByName(prebindStr(args, 0)))]
    }
    b.install(vm)
}