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
 * @file[zh-cn] scene_ecs_world World 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.ecs.World 绑定为 Lua 类型 three.scene.ecs.World
 * @explain[zh-cn] 覆盖构造（默认映射管理器）、entityMgr / componentMgr / systemMgr 只读属性、
 * createEntity / addEntity / removeEntity / delEntity / getEntity、
 * createComponent(cptId)（泛型适配为基类 Component）/ recycle、
 * updateOrder（Lua 数值数组）、addSystem / delSystemById / onUpdate / clear。
 * 附加绑定层便利：getEntities() 返回全部实体数组（避免暴露 HashMap），
 * setUpdateOrder(list) 写入系统遍历顺序。
 * 自定义映射管理器的构造重载接受接口实例，Lua 无法表达，不绑定；需要时可用
 * ArrSysEtyMapManager / TreeSysEtyMapManager 配合 SystemManager 自行组装。
 *
 * @file[en] scene_ecs_world  Lua binding of World (three.script.prebind)
 * @brief[en] Binds three.scene.ecs.World as the Lua type three.scene.ecs.World
 * @explain[en] Covers construction (default mapping manager), the read-only entityMgr /
 * componentMgr / systemMgr properties, createEntity / addEntity / removeEntity / delEntity /
 * getEntity, createComponent(cptId) (generic adapted to the base Component) / recycle,
 * updateOrder (Lua number array), addSystem / delSystemById / onUpdate / clear.
 * Binding-level conveniences: getEntities() returns all entities as an array (avoiding the
 * HashMap) and setUpdateOrder(list) writes the system traversal order.
 * The custom mapping-manager constructor overload takes an interface instance that Lua cannot
 * express, so it is not bound; compose ArrSysEtyMapManager / TreeSysEtyMapManager with
 * SystemManager manually when needed.
 */
package three.script.prebind

import three.scene.ecs.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 安装 World 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.ecs.World）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of World
 * @param[en] vm The target virtual machine (class table installed at three.scene.ecs.World)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installWorld(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.World")
    b.constructor {_ => World()}
    // ===== 管理器 =====
    b.property("entityMgr", getter: Some({
        ref => prebindRegister(ref.cast<World>().entityMgr, "three.scene.ecs.EntityManager")
    }))
    b.property("componentMgr", getter: Some({
        ref => prebindRegister(ref.cast<World>().componentMgr, "three.scene.ecs.ComponentManager")
    }))
    b.property("systemMgr", getter: Some({
        ref => prebindRegister(ref.cast<World>().systemMgr, "three.scene.ecs.SystemManager")
    }))
    // ===== 实体 =====
    b.method("createEntity") {
        ref, _ => [prebindRegister(ref.cast<World>().createEntity(), "three.scene.ecs.Entity")]
    }
    b.method("addEntity") {
        ref, args => [LuaValue.of(ref.cast<World>().addEntity(prebindAs<Entity>(args, 0)))]
    }
    b.method("removeEntity") {
        ref, args =>
            ref.cast<World>().removeEntity(prebindInt(args, 0))
            Array<LuaValue>()
    }
    b.method("delEntity") {
        ref, args =>
            ref.cast<World>().delEntity(prebindInt(args, 0))
            Array<LuaValue>()
    }
    b.method("getEntity") {
        ref, args => match (ref.cast<World>().getEntity(prebindInt(args, 0))) {
            case Some(e) => [prebindRegister(e, "three.scene.ecs.Entity")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getEntities") {
        ref, _ =>
            let arr = ArrayList<LuaValue>()
            for ((_, e) in ref.cast<World>().entityMgr.entitys) {
                arr.add(prebindRegister(e, "three.scene.ecs.Entity"))
            }
            [LuaValue.Array(arr.toArray())]
    }
    // ===== 组件 =====
    b.method("createComponent") {
        ref, args => match (ref.cast<World>().createComponent<Component>(prebindInt(args, 0))) {
            case Some(c) => [prebindRegister(c, "three.scene.ecs.Component")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("recycle") {
        ref, args =>
            var ok = false
            try {
                ref.cast<World>().recycle(prebindAs<Component>(args, 0))
                ok = true
            } catch (_: Exception) {
                // 组件仍挂在实体上：返回 false
            }
            [LuaValue.Boolean(ok)]
    }
    // ===== 系统 =====
    b.property("updateOrder", getter: Some({
        ref => prebindI64ListToLua(ref.cast<World>().updateOrder)
    }))
    b.method("setUpdateOrder") {
        ref, args =>
            let order = prebindI64List(vm, args, 0)
            let target = ref.cast<World>().updateOrder
            target.clear()
            for (id in order) {
                target.add(id)
            }
            Array<LuaValue>()
    }
    b.method("addSystem") {
        ref, args => [LuaValue.of(ref.cast<World>().addSystem(prebindAs<System>(args, 0)))]
    }
    b.method("delSystemById") {
        ref, args =>
            ref.cast<World>().delSystemById(prebindInt(args, 0))
            Array<LuaValue>()
    }
    b.method("onUpdate") {
        ref, args =>
            ref.cast<World>().onUpdate(prebindNum(args, 0))
            Array<LuaValue>()
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<World>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}
