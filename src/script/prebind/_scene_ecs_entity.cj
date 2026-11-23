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
 * @file[zh-cn] scene_ecs_entity Entity 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.ecs.Entity 绑定为 Lua 类型 three.scene.ecs.Entity
 * @explain[zh-cn] 覆盖构造（new 即分配实例 ID）、etyId / cptMask / constructed 只读属性、
 * getComponent(cptId) / hasComponent / addComponent / removeComponentById /
 * removeAllComponents / construct / restruct / destruct。
 * 适配说明：
 * - 泛型 getComponent<T> 无法由 Lua 指定类型参数，绑定为 getComponent(cptId)，
 *   返回已注册的 Component 对象或 nil；
 * - monitorComponentChanges 为仓颉闭包字段，不绑定（World.addEntity 自动挂接）；
 * - components HashMap 不直接暴露，额外提供 componentCount 便于脚本调试。
 * 生命周期与宏：实例 ID 分配/回收由基类 init/destruct 完成，与 @Entity 宏校验无关；
 * Lua 侧装饰器式实体请使用 resources/lua/three/scene/ecs.lua 的 Entity(cls) 工厂。
 *
 * @file[en] scene_ecs_entity  Lua binding of Entity (three.script.prebind)
 * @brief[en] Binds three.scene.ecs.Entity as the Lua type three.scene.ecs.Entity
 * @explain[en] Covers construction (new allocates the instance ID), the read-only etyId /
 * cptMask / constructed properties, getComponent(cptId) / hasComponent / addComponent /
 * removeComponentById / removeAllComponents / construct / restruct / destruct.
 * Adaptation notes:
 * - The generic getComponent<T> cannot take a Lua type argument, so it is bound as
 *   getComponent(cptId) returning a registered Component object or nil;
 * - monitorComponentChanges is a Cangjie closure field and is not bound (World.addEntity
 *   hooks it automatically);
 * - the components HashMap is not exposed directly; componentCount is provided for debugging.
 * Lifecycle and macros: instance ID allocation/release is handled by the base init/destruct,
 * independent of the @Entity macro validation; for decorator-style Lua entities use the
 * Entity(cls) factory in resources/lua/three/scene/ecs.lua.
 */
package three.script.prebind

import three.scene.ecs.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Entity 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.ecs.Entity）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Entity
 * @param[en] vm The target virtual machine (class table installed at three.scene.ecs.Entity)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEntity(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.Entity")
    b.constructor {_ => Entity()}
    b.property("etyId", getter: Some({ref => LuaValue.of(ref.cast<Entity>().etyId)}))
    b.property("cptMask", getter: Some({
        ref => prebindRegister(ref.cast<Entity>().cptMask, "three.core.dsa.BitArray")
    }))
    b.property("constructed", getter: Some({ref => LuaValue.of(ref.cast<Entity>().constructed)}))
    b.property("componentCount", getter: Some({ref => LuaValue.of(ref.cast<Entity>().components.size)}))
    b.method("getComponent") {
        ref, args => match (ref.cast<Entity>().components.get(prebindInt(args, 0))) {
            case Some(c) => [prebindRegister(c, "three.scene.ecs.Component")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("hasComponent") {
        ref, args => [LuaValue.of(ref.cast<Entity>().hasComponent(prebindInt(args, 0)))]
    }
    b.method("addComponent") {
        ref, args =>
            var ok = false
            try {
                ref.cast<Entity>().addComponent(prebindAs<Component>(args, 0))
                ok = true
            } catch (_: Exception) {
                // 组件未登记 / 同类型重复：返回 false（不向 Lua 抛错）
            }
            [LuaValue.Boolean(ok)]
    }
    b.method("removeComponentById") {
        ref, args => match (ref.cast<Entity>().removeComponentById(prebindInt(args, 0))) {
            case Some(c) => [prebindRegister(c, "three.scene.ecs.Component")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("removeAllComponents") {
        ref, _ =>
            ref.cast<Entity>().removeAllComponents()
            Array<LuaValue>()
    }
    b.method("construct") {
        ref, _ =>
            ref.cast<Entity>().construct()
            Array<LuaValue>()
    }
    b.method("restruct") {
        ref, _ =>
            ref.cast<Entity>().restruct()
            Array<LuaValue>()
    }
    b.method("destruct") {
        ref, _ =>
            ref.cast<Entity>().destruct()
            Array<LuaValue>()
    }
    b.install(vm)
}
