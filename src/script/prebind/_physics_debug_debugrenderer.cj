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
 * @file[zh-cn] physics_debug_debugrenderer 物理调试渲染的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 PhysicsDebugLine / PhysicsDebugTriangle / PhysicsDebugRenderer 绑定为
 * Lua 类型
 * @explain[zh-cn] 线段与三角形为结构体值对象：构造按位置传参（line: from/to/color，
 * triangle: v1/v2/v3/color），字段为只读属性（结构体按值注册，无法就地修改）。
 * 调试渲染器提供 releasable / lineCount / drawBodies(world, wireframe?) /
 * drawConstraints(world) / nextFrame / clear / release。
 *
 * @file[en] physics_debug_debugrenderer  Lua bindings of the physics debug renderer
 * (three.script.prebind)
 * @brief[en] Binds PhysicsDebugLine / PhysicsDebugTriangle / PhysicsDebugRenderer as Lua types
 * @explain[en] Lines and triangles are struct value objects: the constructor takes positional
 * arguments (line: from/to/color; triangle: v1/v2/v3/color) and fields are read-only properties
 * (structs are registered by value and cannot be mutated in place). The debug renderer offers
 * releasable / lineCount / drawBodies(world, wireframe?) / drawConstraints(world) /
 * nextFrame / clear / release.
 */
package three.script.prebind

import three.physics.debug.*
import three.physics.world.PhysicsWorld
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsDebugLine 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsDebugLine
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsDebugLine(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.debug.PhysicsDebugLine")
    b.constructor {
        args =>
            var line = PhysicsDebugLine()
            line.from = prebindAs<Vector3>(args, 0)
            line.to = prebindAs<Vector3>(args, 1)
            line.color = UInt32(prebindInt(args, 2, default: 0xFFFFFFFF) & 0xFFFFFFFF)
            line
    }
    b.property("from", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsDebugLine>().from, "three.core.math.Vector3")
    }))
    b.property("to", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsDebugLine>().to, "three.core.math.Vector3")
    }))
    b.property("color", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsDebugLine>().color))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsDebugTriangle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsDebugTriangle
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsDebugTriangle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.debug.PhysicsDebugTriangle")
    b.constructor {
        args =>
            var tri = PhysicsDebugTriangle()
            tri.v1 = prebindAs<Vector3>(args, 0)
            tri.v2 = prebindAs<Vector3>(args, 1)
            tri.v3 = prebindAs<Vector3>(args, 2)
            tri.color = UInt32(prebindInt(args, 3, default: 0xFFFFFFFF) & 0xFFFFFFFF)
            tri
    }
    b.property("v1", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsDebugTriangle>().v1, "three.core.math.Vector3")
    }))
    b.property("v2", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsDebugTriangle>().v2, "three.core.math.Vector3")
    }))
    b.property("v3", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsDebugTriangle>().v3, "three.core.math.Vector3")
    }))
    b.property("color", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsDebugTriangle>().color))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsDebugRenderer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsDebugRenderer
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsDebugRenderer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.debug.PhysicsDebugRenderer")
    b.constructor {_ => PhysicsDebugRenderer()}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsDebugRenderer>().releasable)}))
    b.property("lineCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsDebugRenderer>().lineCount)}))
    b.method("drawBodies") {
        ref, args =>
            ref
                .cast<PhysicsDebugRenderer>()
                .drawBodies(prebindAs<PhysicsWorld>(args, 0), wireframe: prebindBool(args, 1, default: true))
            Array<LuaValue>()
    }
    b.method("drawConstraints") {
        ref, args =>
            ref.cast<PhysicsDebugRenderer>().drawConstraints(prebindAs<PhysicsWorld>(args, 0))
            Array<LuaValue>()
    }
    b.method("nextFrame") {
        ref, _ =>
            ref.cast<PhysicsDebugRenderer>().nextFrame()
            Array<LuaValue>()
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<PhysicsDebugRenderer>().clear()
            Array<LuaValue>()
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsDebugRenderer>().release())]
    }
    b.install(vm)
}
