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
 * @file[zh-cn] scene_ecs_system System 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.ecs.System 绑定为 Lua 类型 three.scene.ecs.System
 * @explain[zh-cn] 覆盖构造（new 即分配实例 ID）、sysId / constructed 只读属性、
 * isActive 可读写、cptMask 只读（返回 BitArray 对象）、construct / restruct / destruct。
 * collectCptMask 为 protected 且由 @System 宏注入，不绑定；Lua 侧由
 * resources/lua/three/scene/ecs.lua 的 System(cls, cpts) 装饰器等价实现
 * （记录所需组件 id，并按继承链叠加父系统掩码）。
 *
 * @file[en] scene_ecs_system  Lua binding of System (three.script.prebind)
 * @brief[en] Binds three.scene.ecs.System as the Lua type three.scene.ecs.System
 * @explain[en] Covers construction (new allocates the instance ID), the read-only sysId /
 * constructed properties, read-write isActive, read-only cptMask (a BitArray object) and
 * construct / restruct / destruct.
 * collectCptMask is protected and injected by the @System macro, so it is not bound; the Lua
 * side implements it equivalently in resources/lua/three/scene/ecs.lua's
 * System(cls, cpts) decorator (records required component ids and stacks the parent mask
 * along the inheritance chain).
 */
package three.script.prebind

import three.scene.ecs.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 System 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.ecs.System）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of System
 * @param[en] vm The target virtual machine (class table installed at three.scene.ecs.System)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSystem(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.System")
    b.constructor {_ => System()}
    b.property("sysId", getter: Some({ref => LuaValue.of(ref.cast<System>().sysId)}))
    b.property("constructed", getter: Some({ref => LuaValue.of(ref.cast<System>().constructed)}))
    b.property("isActive", getter: Some({ref => LuaValue.of(ref.cast<System>().isActive)}),
        setter: Some({ref, v => ref.cast<System>().isActive = v.boolValue()}))
    b.property("cptMask", getter: Some({
        ref => prebindRegister(ref.cast<System>().cptMask, "three.core.dsa.BitArray")
    }))
    b.method("construct") {
        ref, _ =>
            ref.cast<System>().construct()
            Array<LuaValue>()
    }
    b.method("restruct") {
        ref, _ =>
            ref.cast<System>().restruct()
            Array<LuaValue>()
    }
    b.method("destruct") {
        ref, _ =>
            ref.cast<System>().destruct()
            Array<LuaValue>()
    }
    b.install(vm)
}
