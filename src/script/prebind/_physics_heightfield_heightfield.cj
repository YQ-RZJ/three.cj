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
 * @file[zh-cn] physics_heightfield_heightfield 高度场地形的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 PhysicsHeightFieldDesc / PhysicsHeightField / PhysicsHeightFieldFactory
 * 绑定为 Lua 类型
 * @explain[zh-cn] 描述（samples / sampleCount / sizeX / sizeZ / center / friction /
 * restitution 全部可读写；samples 在 Lua 侧为数值数组）；运行时对象暴露 releasable /
 * bodyID / sampleCount / projectOntoSurface(x, z) / release；工厂在物理线程内创建地形。
 *
 * @file[en] physics_heightfield_heightfield  Lua bindings of the height-field terrain
 * (three.script.prebind)
 * @brief[en] Binds PhysicsHeightFieldDesc / PhysicsHeightField / PhysicsHeightFieldFactory as
 * Lua types
 * @explain[en] The description (samples / sampleCount / sizeX / sizeZ / center / friction /
 * restitution all read-write; samples is a Lua number array); the runtime object exposes
 * releasable / bodyID / sampleCount / projectOntoSurface(x, z) / release; the factory builds
 * the terrain on the physics thread.
 */
package three.script.prebind

import three.physics.heightfield.*
import three.physics.world.PhysicsWorld
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsHeightFieldDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsHeightFieldDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsHeightFieldDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.heightfield.PhysicsHeightFieldDesc")
    b.constructor {_ => PhysicsHeightFieldDesc()}
    b.property("samples", getter: Some({ref => prebindF64ListToLua(ref.cast<PhysicsHeightFieldDesc>().samples)}),
        setter: Some({
            ref, v => ref.cast<PhysicsHeightFieldDesc>().samples = prebindF64List(vm, [v], 0)
        }))
    b.property("sampleCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightFieldDesc>().sampleCount)}),
        setter: Some({ref, v => ref.cast<PhysicsHeightFieldDesc>().sampleCount = v.intValue()}))
    b.property("sizeX", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightFieldDesc>().sizeX)}),
        setter: Some({ref, v => ref.cast<PhysicsHeightFieldDesc>().sizeX = v.numberValue()}))
    b.property("sizeZ", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightFieldDesc>().sizeZ)}),
        setter: Some({ref, v => ref.cast<PhysicsHeightFieldDesc>().sizeZ = v.numberValue()}))
    b.property("center", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsHeightFieldDesc>().center, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsHeightFieldDesc>().center = prebindAsValue<Vector3>(v)
    }))
    b.property("friction", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightFieldDesc>().friction)}),
        setter: Some({ref, v => ref.cast<PhysicsHeightFieldDesc>().friction = v.numberValue()}))
    b.property("restitution", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightFieldDesc>().restitution)}),
        setter: Some({ref, v => ref.cast<PhysicsHeightFieldDesc>().restitution = v.numberValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsHeightField 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsHeightField
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsHeightField(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.heightfield.PhysicsHeightField")
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightField>().releasable)}))
    b.property("bodyID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsHeightField>().bodyID))}))
    b.property("sampleCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsHeightField>().sampleCount)}))
    b.method("projectOntoSurface") {
        ref, args => [prebindRegister(
            ref.cast<PhysicsHeightField>().projectOntoSurface(prebindNum(args, 0), prebindNum(args, 1)),
            "three.core.math.Vector3")]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsHeightField>().release())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsHeightFieldFactory 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsHeightFieldFactory
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsHeightFieldFactory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.heightfield.PhysicsHeightFieldFactory")
    b.constructor {
        args => PhysicsHeightFieldFactory(desc: prebindAs<PhysicsHeightFieldDesc>(args, 0))
    }
    b.method("createHeightField") {
        ref, args => [prebindRegister(
            ref.cast<PhysicsHeightFieldFactory>().createHeightField(prebindAs<PhysicsWorld>(args, 0)),
            "three.physics.heightfield.PhysicsHeightField")]
    }
    b.install(vm)
}
