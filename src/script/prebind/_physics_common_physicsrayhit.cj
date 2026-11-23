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
 * @file[zh-cn] physics_interfaces_physicsrayhit 物理查询结果与句柄的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 PhysicsRayHit / PhysicsPointHit / PhysicsShapeHit / PhysicsContactEvent /
 * PhysicsBodyHandle 绑定为 Lua 类型
 * @explain[zh-cn] 三个命中结果类均为可变数据对象：无参构造 + 全字段可读写属性，
 * 作为查询输出容器使用（raycast 就地填充 hit，raycastAll 等返回对象数组）。
 * 向量字段（point / normal）返回 Vector3 对象并接受 Vector3 赋值。
 * PhysicsContactEvent（Added=0 / Persisted=1 / Removed=2）无 value()，按 0 基序号绑定为
 * 常量命名空间。PhysicsBodyHandle 为结构体值对象：new(bodyID?)、静态 INVALID、isValid()、
 * 只读 bodyID。
 *
 * @file[en] physics_interfaces_physicsrayhit  Lua bindings of query results and handles
 * (three.script.prebind)
 * @brief[en] Binds PhysicsRayHit / PhysicsPointHit / PhysicsShapeHit / PhysicsContactEvent /
 * PhysicsBodyHandle as Lua types
 * @explain[en] The three hit-result classes are mutable data objects: a parameterless
 * constructor plus read-write properties for every field, used as query output containers
 * (raycast fills a hit in place; raycastAll et al. return object arrays). Vector fields
 * (point / normal) return Vector3 objects and accept Vector3 assignment.
 * PhysicsContactEvent (Added=0 / Persisted=1 / Removed=2) has no value() and is bound as a
 * constant namespace by 0-based ordinal. PhysicsBodyHandle is a struct value object:
 * new(bodyID?), static INVALID, isValid(), read-only bodyID.
 */
package three.script.prebind

import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 把刚体句柄注册为 Lua 值对象
 * @param[zh-cn] h 刚体句柄
 * @return[zh-cn] Lua 对象值
 *
 * @brief[en] Registers a body handle as a Lua value object
 * @param[en] h The body handle
 * @return[en] The Lua object value
 */
internal func physicsBodyHandleToLua(h: PhysicsBodyHandle): LuaValue {
    return prebindRegister(h, "three.physics.common.PhysicsBodyHandle")
}

/**
 * @brief[zh-cn] 接触事件枚举值到 0 基序号
 * @param[zh-cn] e 接触事件
 * @return[zh-cn] 0 基序号（Added=0 / Persisted=1 / Removed=2）
 *
 * @brief[en] Maps a contact event to its 0-based ordinal
 * @param[en] e The contact event
 * @return[en] The 0-based ordinal (Added=0 / Persisted=1 / Removed=2)
 */
internal func physicsContactEventValue(e: PhysicsContactEvent): Int64 {
    match (e) {
        case PhysicsContactEvent.Added => 0
        case PhysicsContactEvent.Persisted => 1
        case PhysicsContactEvent.Removed => 2
    }
}

/**
 * @brief[zh-cn] 0 基序号转接触事件（越界回退 Added）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 接触事件
 *
 * @brief[en] Converts a 0-based ordinal to the contact event (out-of-range falls back to Added)
 * @param[en] i The 0-based ordinal
 * @return[en] The contact event
 */
internal func physicsContactEventFrom(i: Int64): PhysicsContactEvent {
    match (i) {
        case 1 => PhysicsContactEvent.Persisted
        case 2 => PhysicsContactEvent.Removed
        case _ => PhysicsContactEvent.Added
    }
}

/**
 * @brief[zh-cn] 安装 PhysicsContactEvent 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsContactEvent (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsContactEvent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsContactEvent")
    b.staticMethod("Added") {_ => [LuaValue.of(physicsContactEventValue(PhysicsContactEvent.Added))]}
    b.staticMethod("Persisted") {_ => [LuaValue.of(physicsContactEventValue(PhysicsContactEvent.Persisted))]}
    b.staticMethod("Removed") {_ => [LuaValue.of(physicsContactEventValue(PhysicsContactEvent.Removed))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsContactEventValue(physicsContactEventFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsBodyHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsBodyHandle
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsBodyHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsBodyHandle")
    b.constructor {
        args => PhysicsBodyHandle(bodyID: UInt32(prebindInt(args, 0, default: 0) & 0xFFFFFFFF))
    }
    b.staticMethod("INVALID") {_ => [physicsBodyHandleToLua(PhysicsBodyHandle.INVALID)]}
    b.property("bodyID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsBodyHandle>().bodyID))}))
    b.method("isValid") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsBodyHandle>().isValid())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsRayHit 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsRayHit
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsRayHit(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsRayHit")
    b.constructor {_ => PhysicsRayHit()}
    b.property("bodyID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsRayHit>().bodyID))}),
        setter: Some({ref, v => ref.cast<PhysicsRayHit>().bodyID = UInt32(v.intValue() & 0xFFFFFFFF)}))
    b.property("fraction", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsRayHit>().fraction))}),
        setter: Some({ref, v => ref.cast<PhysicsRayHit>().fraction = Float32(v.numberValue())}))
    b.property("point", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsRayHit>().point, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<PhysicsRayHit>().point = prebindAsValue<Vector3>(v)}))
    b.property("normal", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsRayHit>().normal, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<PhysicsRayHit>().normal = prebindAsValue<Vector3>(v)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsPointHit 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsPointHit
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsPointHit(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsPointHit")
    b.constructor {_ => PhysicsPointHit()}
    b.property("bodyID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsPointHit>().bodyID))}),
        setter: Some({ref, v => ref.cast<PhysicsPointHit>().bodyID = UInt32(v.intValue() & 0xFFFFFFFF)}))
    b.property("subShapeID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsPointHit>().subShapeID))}),
        setter: Some({
            ref, v => ref.cast<PhysicsPointHit>().subShapeID = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsShapeHit 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsShapeHit
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsShapeHit(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsShapeHit")
    b.constructor {_ => PhysicsShapeHit()}
    b.property("bodyID", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsShapeHit>().bodyID))}),
        setter: Some({ref, v => ref.cast<PhysicsShapeHit>().bodyID = UInt32(v.intValue() & 0xFFFFFFFF)}))
    b.property("fraction", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsShapeHit>().fraction))}),
        setter: Some({ref, v => ref.cast<PhysicsShapeHit>().fraction = Float32(v.numberValue())}))
    b.property("point", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsShapeHit>().point, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<PhysicsShapeHit>().point = prebindAsValue<Vector3>(v)}))
    b.property("normal", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsShapeHit>().normal, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<PhysicsShapeHit>().normal = prebindAsValue<Vector3>(v)}))
    b.property("penetrationDepth",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsShapeHit>().penetrationDepth))}), setter: Some({
            ref, v => ref.cast<PhysicsShapeHit>().penetrationDepth = Float32(v.numberValue())
        }))
    b.property("subShapeID1", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsShapeHit>().subShapeID1))}),
        setter: Some({
            ref, v => ref.cast<PhysicsShapeHit>().subShapeID1 = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("subShapeID2", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsShapeHit>().subShapeID2))}),
        setter: Some({
            ref, v => ref.cast<PhysicsShapeHit>().subShapeID2 = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("isBackFaceHit", getter: Some({ref => LuaValue.of(ref.cast<PhysicsShapeHit>().isBackFaceHit)}),
        setter: Some({ref, v => ref.cast<PhysicsShapeHit>().isBackFaceHit = v.boolValue()}))
    b.install(vm)
}
