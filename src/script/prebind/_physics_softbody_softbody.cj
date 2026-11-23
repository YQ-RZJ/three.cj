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
 * @file[zh-cn] physics_softbody_softbody 软体的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 PhysicsSoftBodyDesc / PhysicsSoftBody / PhysicsSoftBodyFactory 绑定为
 * Lua 类型
 * @explain[zh-cn] 描述字段（vertices / indices / compliance / bendType / pressure /
 * linearDamping / friction / restitution / gravityFactor / vertexRadius / numIterations /
 * pinnedVertices / layer）全部可读写；vertices 为 Vector3 对象数组，indices /
 * pinnedVertices 为数值数组。运行时对象暴露 releasable / bodyID / release；
 * 工厂在物理线程内创建软体。
 * 注：jolt4cj 未导出软体顶点读取 FFI，运行时顶点数据不可读（渲染侧自行维护）。
 *
 * @file[en] physics_softbody_softbody  Lua bindings of the soft body (three.script.prebind)
 * @brief[en] Binds PhysicsSoftBodyDesc / PhysicsSoftBody / PhysicsSoftBodyFactory as Lua types
 * @explain[en] Description fields (vertices / indices / compliance / bendType / pressure /
 * linearDamping / friction / restitution / gravityFactor / vertexRadius / numIterations /
 * pinnedVertices / layer) are all read-write; vertices is a Vector3 object array and
 * indices / pinnedVertices are number arrays. The runtime object exposes releasable /
 * bodyID / release; the factory builds the soft body on the physics thread.
 * Note: jolt4cj does not export the soft-body vertex-reading FFI, so runtime vertices are not
 * readable (the render side maintains them itself).
 */
package three.script.prebind

import three.physics.softbody.*
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsSoftBodyDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsSoftBodyDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsSoftBodyDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.softbody.PhysicsSoftBodyDesc")
    b.constructor {_ => PhysicsSoftBodyDesc()}
    b.property(
        "vertices",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<PhysicsSoftBodyDesc>().vertices
                    var out = Array<LuaValue>(src.size, {
                        i => prebindRegister(src[i], "three.core.math.Vector3")
                    })
                    LuaValue.Array(out)
            }
        ),
        setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().vertices = prebindObjList<Vector3>(vm, [v], 0)
        })
    )
    b.property("indices", getter: Some({ref => prebindU32ListToLua(ref.cast<PhysicsSoftBodyDesc>().indices)}),
        setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().indices = prebindU32List(vm, [v], 0)
        }))
    b.property("compliance", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().compliance)}),
        setter: Some({ref, v => ref.cast<PhysicsSoftBodyDesc>().compliance = v.numberValue()}))
    b.property("bendType", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsSoftBodyDesc>().bendType))}),
        setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().bendType = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("pressure", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().pressure)}),
        setter: Some({ref, v => ref.cast<PhysicsSoftBodyDesc>().pressure = v.numberValue()}))
    b.property("linearDamping", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().linearDamping)}),
        setter: Some({ref, v => ref.cast<PhysicsSoftBodyDesc>().linearDamping = v.numberValue()}))
    b.property("friction", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().friction)}),
        setter: Some({ref, v => ref.cast<PhysicsSoftBodyDesc>().friction = v.numberValue()}))
    b.property("restitution", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().restitution)}),
        setter: Some({ref, v => ref.cast<PhysicsSoftBodyDesc>().restitution = v.numberValue()}))
    b.property("gravityFactor", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().gravityFactor)}),
        setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().gravityFactor = v.numberValue()
        }))
    b.property("vertexRadius", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBodyDesc>().vertexRadius)}),
        setter: Some({ref, v => ref.cast<PhysicsSoftBodyDesc>().vertexRadius = v.numberValue()}))
    b.property("numIterations",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsSoftBodyDesc>().numIterations))}), setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().numIterations = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("pinnedVertices",
        getter: Some({ref => prebindI64ListToLua(ref.cast<PhysicsSoftBodyDesc>().pinnedVertices)}), setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().pinnedVertices = prebindI64List(vm, [v], 0)
        }))
    b.property("layer", getter: Some({ref => LuaValue.of(physicsLayerValue(ref.cast<PhysicsSoftBodyDesc>().layer))}),
        setter: Some({
            ref, v => ref.cast<PhysicsSoftBodyDesc>().layer = physicsLayerFrom(v.intValue())
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsSoftBody 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsSoftBody
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsSoftBody(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.softbody.PhysicsSoftBody")
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSoftBody>().releasable)}))
    b.property("bodyID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsSoftBody>().bodyID))}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsSoftBody>().release())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsSoftBodyFactory 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsSoftBodyFactory
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsSoftBodyFactory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.softbody.PhysicsSoftBodyFactory")
    b.constructor {
        args => PhysicsSoftBodyFactory(desc: prebindAs<PhysicsSoftBodyDesc>(args, 0))
    }
    b.method("createSoftBody") {
        ref, args => [prebindRegister(
            ref.cast<PhysicsSoftBodyFactory>().createSoftBody(prebindAs<PhysicsWorld>(args, 0)),
            "three.physics.softbody.PhysicsSoftBody")]
    }
    b.install(vm)
}
