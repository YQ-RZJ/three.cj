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
 * @file[zh-cn] scene_ecs_ecsobject ECS 生命周期基类的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.ecs.EcsObject 绑定为 Lua 类型 three.scene.ecs.EcsObject
 * @explain[zh-cn] 暴露 constructed 只读属性与 construct / restruct / destruct 三个生命周期入口；
 * onConstruct / onDestruct 为 protected 钩子，不绑定（Lua 侧请使用 resources/lua/three/scene/ecs.lua
 * 提供的装饰器式组件/实体/系统工厂）。NUM_NONE 以静态方法 NUM_NONE() 暴露。
 *
 * @file[en] scene_ecs_ecsobject  Lua binding of the ECS lifecycle base (three.script.prebind)
 * @brief[en] Binds three.scene.ecs.EcsObject as the Lua type three.scene.ecs.EcsObject
 * @explain[en] Exposes the read-only constructed property and the three lifecycle entry points
 * construct / restruct / destruct; the protected onConstruct / onDestruct hooks are not bound
 * (use the decorator-style component/entity/system factories in
 * resources/lua/three/scene/ecs.lua from Lua). NUM_NONE is exposed as the static method NUM_NONE().
 */
package three.script.prebind

import three.scene.ecs.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EcsObject 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.ecs.EcsObject）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EcsObject
 * @param[en] vm The target virtual machine (class table installed at three.scene.ecs.EcsObject)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEcsObject(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.ecs.EcsObject")
    b.staticMethod("NUM_NONE") {_ => [LuaValue.of(NUM_NONE)]}
    b.property("constructed", getter: Some({ref => LuaValue.of(ref.cast<EcsObject>().constructed)}))
    b.method("construct") {
        ref, _ =>
            ref.cast<EcsObject>().construct()
            Array<LuaValue>()
    }
    b.method("restruct") {
        ref, _ =>
            ref.cast<EcsObject>().restruct()
            Array<LuaValue>()
    }
    b.method("destruct") {
        ref, _ =>
            ref.cast<EcsObject>().destruct()
            Array<LuaValue>()
    }
    b.install(vm)
}
