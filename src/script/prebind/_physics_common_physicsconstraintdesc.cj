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
 * @file[zh-cn] physics_interfaces_physicsconstraintdesc 约束相关类型的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 PhysicsConstraintType / PhysicsMotorState / PhysicsConstraintSpace /
 * PhysicsConstraintDesc / PhysicsConstraintHandle 绑定为 Lua 类型
 * @explain[zh-cn] PhysicsConstraintType（Fixed=0 … Gear=8）与 PhysicsConstraintSpace
 * （LocalToBodyCOM=0 / WorldSpace=1）无 value()，按 0 基序号绑定为常量命名空间；
 * PhysicsMotorState 自带 value()（Off=0/Velocity=1/Position=2），同样以数值暴露。
 * PhysicsConstraintDesc 的 11 个字段全部映射为可读写属性，构造按仓颉位置顺序：
 * new(constraintType, space?, anchor1?, anchor2?, axis1?, axis2?, planeAxis?,
 *     limitMin?, limitMax?, enabled?, userData?)
 * PhysicsConstraintHandle 为结构体值对象：new(constraintID?)、静态 INVALID、
 * isValid() 与只读属性 constraintID。
 *
 * @file[en] physics_interfaces_physicsconstraintdesc  Lua bindings of the constraint types
 * (three.script.prebind)
 * @brief[en] Binds PhysicsConstraintType / PhysicsMotorState / PhysicsConstraintSpace /
 * PhysicsConstraintDesc / PhysicsConstraintHandle as Lua types
 * @explain[en] PhysicsConstraintType (Fixed=0 … Gear=8) and PhysicsConstraintSpace
 * (LocalToBodyCOM=0 / WorldSpace=1) have no value(), so they are bound as constant namespaces
 * by 0-based ordinal; PhysicsMotorState defines value() (Off=0/Velocity=1/Position=2) and is
 * also exposed numerically.
 * All 11 PhysicsConstraintDesc fields map to read-write properties with the Cangjie positional
 * constructor order:
 * new(constraintType, space?, anchor1?, anchor2?, axis1?, axis2?, planeAxis?,
 *     limitMin?, limitMax?, enabled?, userData?)
 * PhysicsConstraintHandle is a struct value object: new(constraintID?), static INVALID,
 * isValid() and the read-only constraintID property.
 */
package three.script.prebind

import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 约束类型枚举值到 0 基序号
 * @param[zh-cn] t 约束类型
 * @return[zh-cn] 0 基序号（Fixed=0 … Gear=8）
 *
 * @brief[en] Maps a constraint type to its 0-based ordinal
 * @param[en] t The constraint type
 * @return[en] The 0-based ordinal (Fixed=0 … Gear=8)
 */
internal func physicsConstraintTypeValue(t: PhysicsConstraintType): Int64 {
    match (t) {
        case PhysicsConstraintType.Fixed => 0
        case PhysicsConstraintType.Point => 1
        case PhysicsConstraintType.Hinge => 2
        case PhysicsConstraintType.Slider => 3
        case PhysicsConstraintType.Distance => 4
        case PhysicsConstraintType.Cone => 5
        case PhysicsConstraintType.SwingTwist => 6
        case PhysicsConstraintType.SixDOF => 7
        case PhysicsConstraintType.Gear => 8
    }
}

/**
 * @brief[zh-cn] 0 基序号转约束类型（越界回退 Fixed）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 约束类型
 *
 * @brief[en] Converts a 0-based ordinal to the constraint type (out-of-range falls back to Fixed)
 * @param[en] i The 0-based ordinal
 * @return[en] The constraint type
 */
internal func physicsConstraintTypeFrom(i: Int64): PhysicsConstraintType {
    match (i) {
        case 1 => PhysicsConstraintType.Point
        case 2 => PhysicsConstraintType.Hinge
        case 3 => PhysicsConstraintType.Slider
        case 4 => PhysicsConstraintType.Distance
        case 5 => PhysicsConstraintType.Cone
        case 6 => PhysicsConstraintType.SwingTwist
        case 7 => PhysicsConstraintType.SixDOF
        case 8 => PhysicsConstraintType.Gear
        case _ => PhysicsConstraintType.Fixed
    }
}

/**
 * @brief[zh-cn] 电机状态枚举值到序号
 * @param[zh-cn] s 电机状态
 * @return[zh-cn] 序号（Off=0 / Velocity=1 / Position=2）
 *
 * @brief[en] Maps a motor state to its ordinal
 * @param[en] s The motor state
 * @return[en] The ordinal (Off=0 / Velocity=1 / Position=2)
 */
internal func physicsMotorStateValue(s: PhysicsMotorState): Int64 {
    return Int64(s.value())
}

/**
 * @brief[zh-cn] 序号转电机状态（越界回退 Off）
 * @param[zh-cn] i 序号
 * @return[zh-cn] 电机状态
 *
 * @brief[en] Converts an ordinal to the motor state (out-of-range falls back to Off)
 * @param[en] i The ordinal
 * @return[en] The motor state
 */
internal func physicsMotorStateFrom(i: Int64): PhysicsMotorState {
    match (i) {
        case 1 => PhysicsMotorState.Velocity
        case 2 => PhysicsMotorState.Position
        case _ => PhysicsMotorState.Off
    }
}

/**
 * @brief[zh-cn] 约束空间枚举值到 0 基序号
 * @param[zh-cn] s 约束空间
 * @return[zh-cn] 0 基序号（LocalToBodyCOM=0 / WorldSpace=1）
 *
 * @brief[en] Maps a constraint space to its 0-based ordinal
 * @param[en] s The constraint space
 * @return[en] The 0-based ordinal (LocalToBodyCOM=0 / WorldSpace=1)
 */
internal func physicsConstraintSpaceValue(s: PhysicsConstraintSpace): Int64 {
    match (s) {
        case PhysicsConstraintSpace.LocalToBodyCOM => 0
        case PhysicsConstraintSpace.WorldSpace => 1
    }
}

/**
 * @brief[zh-cn] 0 基序号转约束空间（越界回退 WorldSpace）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 约束空间
 *
 * @brief[en] Converts a 0-based ordinal to the constraint space (out-of-range falls back to WorldSpace)
 * @param[en] i The 0-based ordinal
 * @return[en] The constraint space
 */
internal func physicsConstraintSpaceFrom(i: Int64): PhysicsConstraintSpace {
    if (i == 0) {
        PhysicsConstraintSpace.LocalToBodyCOM
    } else {
        PhysicsConstraintSpace.WorldSpace
    }
}

/**
 * @brief[zh-cn] 把约束句柄注册为 Lua 值对象
 * @param[zh-cn] h 约束句柄
 * @return[zh-cn] Lua 对象值
 *
 * @brief[en] Registers a constraint handle as a Lua value object
 * @param[en] h The constraint handle
 * @return[en] The Lua object value
 */
internal func physicsConstraintHandleToLua(h: PhysicsConstraintHandle): LuaValue {
    return prebindRegister(h, "three.physics.common.PhysicsConstraintHandle")
}

/**
 * @brief[zh-cn] 安装 PhysicsConstraintType 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsConstraintType (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsConstraintType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsConstraintType")
    b.staticMethod("Fixed") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Fixed))]}
    b.staticMethod("Point") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Point))]}
    b.staticMethod("Hinge") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Hinge))]}
    b.staticMethod("Slider") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Slider))]}
    b.staticMethod("Distance") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Distance))]}
    b.staticMethod("Cone") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Cone))]}
    b.staticMethod("SwingTwist") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.SwingTwist))]}
    b.staticMethod("SixDOF") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.SixDOF))]}
    b.staticMethod("Gear") {_ => [LuaValue.of(physicsConstraintTypeValue(PhysicsConstraintType.Gear))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsConstraintTypeValue(physicsConstraintTypeFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsMotorState 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsMotorState (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsMotorState(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsMotorState")
    b.staticMethod("Off") {_ => [LuaValue.of(physicsMotorStateValue(PhysicsMotorState.Off))]}
    b.staticMethod("Velocity") {_ => [LuaValue.of(physicsMotorStateValue(PhysicsMotorState.Velocity))]}
    b.staticMethod("Position") {_ => [LuaValue.of(physicsMotorStateValue(PhysicsMotorState.Position))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsMotorStateValue(physicsMotorStateFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsConstraintSpace 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsConstraintSpace (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsConstraintSpace(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsConstraintSpace")
    b.staticMethod("LocalToBodyCOM") {
        _ => [LuaValue.of(physicsConstraintSpaceValue(PhysicsConstraintSpace.LocalToBodyCOM))]
    }
    b.staticMethod("WorldSpace") {
        _ => [LuaValue.of(physicsConstraintSpaceValue(PhysicsConstraintSpace.WorldSpace))]
    }
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsConstraintSpaceValue(physicsConstraintSpaceFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsConstraintDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsConstraintDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsConstraintDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsConstraintDesc")
    // ===== 构造 =====
    b.constructor {
        args => PhysicsConstraintDesc(constraintType: physicsConstraintTypeFrom(prebindInt(args, 0)),
            space: physicsConstraintSpaceFrom(prebindInt(args, 1, default: 1)), anchor1: prebindVec3(args, 2),
            anchor2: prebindVec3(args, 3), axis1: prebindVec3(args, 4, default: Vector3(0.0, 1.0, 0.0)),
            axis2: prebindVec3(args, 5, default: Vector3(0.0, 1.0, 0.0)),
            planeAxis: prebindVec3(args, 6, default: Vector3(1.0, 0.0, 0.0)), limitMin: prebindNum(args, 7),
            limitMax: prebindNum(args, 8), enabled: prebindBool(args, 9, default: true),
            userData: UInt64(prebindInt(args, 10)))
    }
    // ===== 类型 / 空间 =====
    b.property("constraintType", getter: Some({
        ref => LuaValue.of(physicsConstraintTypeValue(ref.cast<PhysicsConstraintDesc>().constraintType))
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().constraintType = physicsConstraintTypeFrom(v.intValue())
    }))
    b.property("space", getter: Some({
        ref => LuaValue.of(physicsConstraintSpaceValue(ref.cast<PhysicsConstraintDesc>().space))
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().space = physicsConstraintSpaceFrom(v.intValue())
    }))
    // ===== 锚点 / 轴 =====
    b.property("anchor1", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsConstraintDesc>().anchor1, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().anchor1 = prebindAsValue<Vector3>(v)
    }))
    b.property("anchor2", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsConstraintDesc>().anchor2, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().anchor2 = prebindAsValue<Vector3>(v)
    }))
    b.property("axis1", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsConstraintDesc>().axis1, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().axis1 = prebindAsValue<Vector3>(v)
    }))
    b.property("axis2", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsConstraintDesc>().axis2, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().axis2 = prebindAsValue<Vector3>(v)
    }))
    b.property("planeAxis", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsConstraintDesc>().planeAxis, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsConstraintDesc>().planeAxis = prebindAsValue<Vector3>(v)
    }))
    // ===== 限位 / 开关 / 用户数据 =====
    b.property("limitMin", getter: Some({ref => LuaValue.of(ref.cast<PhysicsConstraintDesc>().limitMin)}),
        setter: Some({ref, v => ref.cast<PhysicsConstraintDesc>().limitMin = v.numberValue()}))
    b.property("limitMax", getter: Some({ref => LuaValue.of(ref.cast<PhysicsConstraintDesc>().limitMax)}),
        setter: Some({ref, v => ref.cast<PhysicsConstraintDesc>().limitMax = v.numberValue()}))
    b.property("enabled", getter: Some({ref => LuaValue.of(ref.cast<PhysicsConstraintDesc>().enabled)}),
        setter: Some({ref, v => ref.cast<PhysicsConstraintDesc>().enabled = v.boolValue()}))
    b.property("userData", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsConstraintDesc>().userData))}),
        setter: Some({
            ref, v => ref.cast<PhysicsConstraintDesc>().userData = UInt64(v.intValue())
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsConstraintHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsConstraintHandle
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsConstraintHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsConstraintHandle")
    b.constructor {
        args => PhysicsConstraintHandle(constraintID: UInt32(prebindInt(args, 0, default: 0xFFFFFFFF) & 0xFFFFFFFF))
    }
    b.staticMethod("INVALID") {
        _ => [physicsConstraintHandleToLua(PhysicsConstraintHandle.INVALID)]
    }
    b.property("constraintID", getter: Some({
        ref => LuaValue.of(Float64(ref.cast<PhysicsConstraintHandle>().constraintID))
    }))
    b.method("isValid") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsConstraintHandle>().isValid())]
    }
    b.install(vm)
}
