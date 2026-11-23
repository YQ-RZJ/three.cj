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
 * @file[zh-cn] scene_ecs_component Component 与组件注册表的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.ecs.Component / ComponentRegistry 绑定为 Lua 类型
 * @explain[zh-cn] Component：无参构造、cptId 只读属性、entity（所属实体，可空可写）。
 * ComponentRegistry：
 * - count / idOf(key) 直接映射；
 * - registerAlloc 的工厂参数是仓颉闭包，Lua 无法表达，改为绑定层便利方法
 *   registerType(uniqueKey)：以「基类 Component 实例」为占位工厂登记并返回类 ID，
 *   供 Lua 侧装饰器为纯 Lua 组件分配全局唯一 ID（与仓颉组件共用同一 ID 空间）；
 * - factoryOf 返回仓颉闭包，不绑定。
 * 宏注入的 typeId() 属于编译期展开，Lua 侧由 resources/lua/three/scene/ecs.lua 的
 * 装饰器等价实现：Component(cls) 为该类表盖 cptId 印章并提供 typeId()。
 *
 * @file[en] scene_ecs_component  Lua bindings of Component and the component registry
 * (three.script.prebind)
 * @brief[en] Binds three.scene.ecs.Component / ComponentRegistry as Lua types
 * @explain[en] Component: no-arg construction, the read-only cptId property and entity (owning
 * entity; nullable and writable).
 * ComponentRegistry:
 * - count / idOf(key) map directly;
 * - registerAlloc takes Cangjie closure factories that Lua cannot express, so the
 *   binding-level convenience registerType(uniqueKey) registers a placeholder factory
 *   returning a base Component and returns the class ID, letting Lua decorators allocate
 *   globally unique IDs for pure-Lua components in the same ID space as Cangjie components;
 * - factoryOf returns a Cangjie closure and is not bound.
 * The macro-injected typeId() is a compile-time expansion; the Lua side implements it
 * equivalently in resources/lua/three/scene/ecs.lua: Component(cls) stamps cptId and provides typeId().
 */
package three.script.prebind

import three.scene.ecs.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Component 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.ecs.Component）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Component
 * @param[en] vm The target virtual machine (class table installed at three.scene.ecs.Component)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installComponent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.Component")
    b.constructor {_ => Component()}
    b.property("cptId", getter: Some({ref => LuaValue.of(ref.cast<Component>().cptId)}))
    b.property("entity", getter: Some({
        ref => match (ref.cast<Component>().entity) {
            case Some(e) => prebindRegister(e, "three.scene.ecs.Entity")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil) {
            ref.cast<Component>().entity = None
        } else {
            ref.cast<Component>().entity = Some(prebindAsValue<Entity>(v))
        }
    }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ComponentRegistry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.ecs.ComponentRegistry）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ComponentRegistry
 * @param[en] vm The target virtual machine (class table installed at three.scene.ecs.ComponentRegistry)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installComponentRegistry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.ComponentRegistry")
    b.staticMethod("count") {_ => [LuaValue.of(ComponentRegistry.count)]}
    b.staticMethod("idOf") {
        args => match (ComponentRegistry.idOf(prebindStr(args, 0))) {
            case Some(id) => [LuaValue.of(id)]
            case None => [LuaValue.Nil]
        }
    }
    b.staticMethod("registerType") {
        args => [LuaValue.of(ComponentRegistry.registerAlloc(prebindStr(args, 0), {=> Component()}))]
    }
    b.install(vm)
}
