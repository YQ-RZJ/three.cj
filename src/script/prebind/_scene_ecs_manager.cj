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
 * @file[zh-cn] scene_ecs_manager ECS 各管理器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 EntityManager / ComponentManager / SystemManager /
 * ArrSysEtyMapManager / TreeSysEtyMapManager 绑定为 Lua 类型
 * @explain[zh-cn] EntityManager：size / addEntity / removeEntity / delEntity / getEntity /
 * clear，附加 getEntities() 返回全部实体数组（不暴露 HashMap）。
 * ComponentManager：createComponent(cptId)（泛型适配为基类 Component）/ recycle / clear。
 * SystemManager：构造（实体管理器 + 映射管理器）、updateOrder / size / systems 计数、
 * addSystem / delSystemById / onUpdate / clear，附加 getSystems() 返回全部系统数组。
 * ArrSysEtyMapManager / TreeSysEtyMapManager：addSystem / delSystem / addEntity / delEntity /
 * changeEntity(oldMask 字节数组, entity) / getSystemEntitys（返回 数量 + 实体数组，适配迭代器）/ clear。
 * bind(systems, entitys) 需要 HashMap 直传，不绑定。
 * 接口 ISysEtyMapManager 本身不绑定。
 *
 * @file[en] scene_ecs_manager  Lua bindings of the ECS managers (three.script.prebind)
 * @brief[en] Binds EntityManager / ComponentManager / SystemManager / ArrSysEtyMapManager /
 * TreeSysEtyMapManager as Lua types
 * @explain[en] EntityManager: size / addEntity / removeEntity / delEntity / getEntity / clear,
 * plus getEntities() returning all entities as an array (without exposing the HashMap).
 * ComponentManager: createComponent(cptId) (generic adapted to the base Component) / recycle / clear.
 * SystemManager: construction (entity manager + mapping manager), updateOrder / size / systems
 * count, addSystem / delSystemById / onUpdate / clear, plus getSystems() returning all systems.
 * ArrSysEtyMapManager / TreeSysEtyMapManager: addSystem / delSystem / addEntity / delEntity /
 * changeEntity(oldMask byte array, entity) / getSystemEntitys (returns count + entity array,
 * adapting the iterator) / clear. bind(systems, entitys) requires HashMaps and is not bound.
 * The ISysEtyMapManager interface itself is not bound.
 */
package three.script.prebind

import three.scene.ecs.*
import three.core._interfaces.ISysEtyMapManager
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/// 把实体迭代器转成 Lua 对象数组
private func _ecsEntitiesToLua(it: Iterator<Entity>): LuaValue {
    let arr = ArrayList<LuaValue>()
    var cur = it.next()
    while (let Some(e) <- cur) {
        arr.add(prebindRegister(e, "three.scene.ecs.Entity"))
        cur = it.next()
    }
    return LuaValue.Array(arr.toArray())
}

/**
 * @brief[zh-cn] 安装 EntityManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EntityManager
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEntityManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.EntityManager")
    b.constructor {_ => EntityManager()}
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<EntityManager>().size)}))
    b.method("addEntity") {
        ref, args => [LuaValue.of(ref.cast<EntityManager>().addEntity(prebindAs<Entity>(args, 0)))]
    }
    b.method("removeEntity") {
        ref, args => match (ref.cast<EntityManager>().removeEntity(prebindInt(args, 0))) {
            case Some(e) => [prebindRegister(e, "three.scene.ecs.Entity")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("delEntity") {
        ref, args => match (ref.cast<EntityManager>().delEntity(prebindInt(args, 0))) {
            case Some(e) => [prebindRegister(e, "three.scene.ecs.Entity")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getEntity") {
        ref, args => match (ref.cast<EntityManager>().getEntity(prebindInt(args, 0))) {
            case Some(e) => [prebindRegister(e, "three.scene.ecs.Entity")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getEntities") {
        ref, _ =>
            let arr = ArrayList<LuaValue>()
            for ((_, e) in ref.cast<EntityManager>().entitys) {
                arr.add(prebindRegister(e, "three.scene.ecs.Entity"))
            }
            [LuaValue.Array(arr.toArray())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<EntityManager>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ComponentManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ComponentManager
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installComponentManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.ComponentManager")
    b.constructor {_ => ComponentManager()}
    b.method("createComponent") {
        ref, args => match (ref.cast<ComponentManager>().createComponent<Component>(prebindInt(args, 0))) {
            case Some(c) => [prebindRegister(c, "three.scene.ecs.Component")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("recycle") {
        ref, args =>
            var ok = false
            try {
                ref.cast<ComponentManager>().recycle(prebindAs<Component>(args, 0))
                ok = true
            } catch (_: Exception) {
                // 组件仍挂在实体上：返回 false
            }
            [LuaValue.Boolean(ok)]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<ComponentManager>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 SystemManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SystemManager
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSystemManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.SystemManager")
    b.constructor {
        args => SystemManager(prebindAs<EntityManager>(args, 0), prebindAs<ISysEtyMapManager<System, Entity>>(args, 1))
    }
    b.property("updateOrder", getter: Some({ref => prebindI64ListToLua(ref.cast<SystemManager>().updateOrder)}))
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<SystemManager>().size)}))
    b.method("addSystem") {
        ref, args => [LuaValue.of(ref.cast<SystemManager>().addSystem(prebindAs<System>(args, 0)))]
    }
    b.method("delSystemById") {
        ref, args => match (ref.cast<SystemManager>().delSystemById(prebindInt(args, 0))) {
            case Some(s) => [prebindRegister(s, "three.scene.ecs.System")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getSystems") {
        ref, _ =>
            let arr = ArrayList<LuaValue>()
            for ((_, s) in ref.cast<SystemManager>().systems) {
                arr.add(prebindRegister(s, "three.scene.ecs.System"))
            }
            [LuaValue.Array(arr.toArray())]
    }
    b.method("onUpdate") {
        ref, args =>
            ref.cast<SystemManager>().onUpdate(prebindNum(args, 0))
            Array<LuaValue>()
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<SystemManager>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ArrSysEtyMapManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ArrSysEtyMapManager
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installArrSysEtyMapManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.ArrSysEtyMapManager")
    b.constructor {_ => ArrSysEtyMapManager()}
    b.method("addSystem") {
        ref, args =>
            ref.cast<ArrSysEtyMapManager>().addSystem(prebindAs<System>(args, 0))
            Array<LuaValue>()
    }
    b.method("delSystem") {
        ref, args =>
            ref.cast<ArrSysEtyMapManager>().delSystem(prebindAs<System>(args, 0))
            Array<LuaValue>()
    }
    b.method("addEntity") {
        ref, args =>
            ref.cast<ArrSysEtyMapManager>().addEntity(prebindAs<Entity>(args, 0))
            Array<LuaValue>()
    }
    b.method("delEntity") {
        ref, args =>
            ref.cast<ArrSysEtyMapManager>().delEntity(prebindAs<Entity>(args, 0))
            Array<LuaValue>()
    }
    b.method("changeEntity") {
        ref, args =>
            ref.cast<ArrSysEtyMapManager>().changeEntity(prebindBytes(vm, args, 0), prebindAs<Entity>(args, 1))
            Array<LuaValue>()
    }
    b.method("getSystemEntitys") {
        ref, args =>
            let (n, it) = ref.cast<ArrSysEtyMapManager>().getSystemEntitys(prebindAs<System>(args, 0))
            [LuaValue.of(n), _ecsEntitiesToLua(it)]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<ArrSysEtyMapManager>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TreeSysEtyMapManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TreeSysEtyMapManager
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTreeSysEtyMapManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.TreeSysEtyMapManager")
    b.constructor {_ => TreeSysEtyMapManager()}
    b.method("addSystem") {
        ref, args =>
            ref.cast<TreeSysEtyMapManager>().addSystem(prebindAs<System>(args, 0))
            Array<LuaValue>()
    }
    b.method("delSystem") {
        ref, args =>
            ref.cast<TreeSysEtyMapManager>().delSystem(prebindAs<System>(args, 0))
            Array<LuaValue>()
    }
    b.method("addEntity") {
        ref, args =>
            ref.cast<TreeSysEtyMapManager>().addEntity(prebindAs<Entity>(args, 0))
            Array<LuaValue>()
    }
    b.method("delEntity") {
        ref, args =>
            ref.cast<TreeSysEtyMapManager>().delEntity(prebindAs<Entity>(args, 0))
            Array<LuaValue>()
    }
    b.method("changeEntity") {
        ref, args =>
            ref.cast<TreeSysEtyMapManager>().changeEntity(prebindBytes(vm, args, 0), prebindAs<Entity>(args, 1))
            Array<LuaValue>()
    }
    b.method("getSystemEntitys") {
        ref, args =>
            let (n, it) = ref.cast<TreeSysEtyMapManager>().getSystemEntitys(prebindAs<System>(args, 0))
            [LuaValue.of(n), _ecsEntitiesToLua(it)]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<TreeSysEtyMapManager>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}
