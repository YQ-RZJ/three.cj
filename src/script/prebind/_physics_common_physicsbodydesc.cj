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
 * @file[zh-cn] physics_interfaces_physicsbodydesc 刚体描述与运动相关枚举的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 PhysicsMotionType / PhysicsActivation / PhysicsLayer / PhysicsBodyDesc
 * 绑定为 Lua 类型
 * @explain[zh-cn] 三个枚举均无 value()，绑定为常量命名空间：变体以 staticMethod 返回 0 基
 * 序号（PhysicsMotionType: Static=0/Kinematic=1/Dynamic=2；PhysicsActivation:
 * Activate=0/DontActivate=1；PhysicsLayer: NonMoving=0/Moving=1），fromValue 反向转换。
 * PhysicsBodyDesc 的 14 个公开字段全部映射为可读写属性；构造按仓颉位置顺序：
 * new(shape, position?, rotation?, motionType?, layer?, activation?, friction?,
 *     restitution?, autoSync?, mass?, gravityFactor?, linearDamping?, angularDamping?,
 *     isSensor?)
 * 本文件同时提供枚举值与刚体描述转换工具（internal），供其余物理绑定复用。
 *
 * @file[en] physics_interfaces_physicsbodydesc  Lua bindings of the body description and
 * motion-related enums (three.script.prebind)
 * @brief[en] Binds PhysicsMotionType / PhysicsActivation / PhysicsLayer / PhysicsBodyDesc as
 * Lua types
 * @explain[en] None of the three enums defines value(), so each is bound as a constant
 * namespace: variants are staticMethods returning 0-based ordinals (PhysicsMotionType:
 * Static=0/Kinematic=1/Dynamic=2; PhysicsActivation: Activate=0/DontActivate=1;
 * PhysicsLayer: NonMoving=0/Moving=1) and fromValue converts back.
 * All 14 public PhysicsBodyDesc fields map to read-write properties; the constructor follows
 * the Cangjie positional order:
 * new(shape, position?, rotation?, motionType?, layer?, activation?, friction?,
 *     restitution?, autoSync?, mass?, gravityFactor?, linearDamping?, angularDamping?,
 *     isSensor?)
 * This file also provides internal enum/descriptor conversion helpers reused by other
 * physics bindings.
 */
package three.script.prebind

import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 运动类型枚举值到 0 基序号
 * @param[zh-cn] t 运动类型
 * @return[zh-cn] 0 基序号（Static=0 / Kinematic=1 / Dynamic=2）
 *
 * @brief[en] Maps a motion type to its 0-based ordinal
 * @param[en] t The motion type
 * @return[en] The 0-based ordinal (Static=0 / Kinematic=1 / Dynamic=2)
 */
internal func physicsMotionTypeValue(t: PhysicsMotionType): Int64 {
    match (t) {
        case PhysicsMotionType.Static => 0
        case PhysicsMotionType.Kinematic => 1
        case PhysicsMotionType.Dynamic => 2
    }
}

/**
 * @brief[zh-cn] 0 基序号转运动类型（越界回退 Dynamic）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 运动类型
 *
 * @brief[en] Converts a 0-based ordinal to the motion type (out-of-range falls back to Dynamic)
 * @param[en] i The 0-based ordinal
 * @return[en] The motion type
 */
internal func physicsMotionTypeFrom(i: Int64): PhysicsMotionType {
    match (i) {
        case 0 => PhysicsMotionType.Static
        case 1 => PhysicsMotionType.Kinematic
        case _ => PhysicsMotionType.Dynamic
    }
}

/**
 * @brief[zh-cn] 激活策略枚举值到 0 基序号
 * @param[zh-cn] a 激活策略
 * @return[zh-cn] 0 基序号（Activate=0 / DontActivate=1）
 *
 * @brief[en] Maps an activation policy to its 0-based ordinal
 * @param[en] a The activation policy
 * @return[en] The 0-based ordinal (Activate=0 / DontActivate=1)
 */
internal func physicsActivationValue(a: PhysicsActivation): Int64 {
    match (a) {
        case PhysicsActivation.Activate => 0
        case PhysicsActivation.DontActivate => 1
    }
}

/**
 * @brief[zh-cn] 0 基序号转激活策略（越界回退 Activate）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 激活策略
 *
 * @brief[en] Converts a 0-based ordinal to the activation policy (out-of-range falls back to Activate)
 * @param[en] i The 0-based ordinal
 * @return[en] The activation policy
 */
internal func physicsActivationFrom(i: Int64): PhysicsActivation {
    if (i == 1) {
        PhysicsActivation.DontActivate
    } else {
        PhysicsActivation.Activate
    }
}

/**
 * @brief[zh-cn] 物理层枚举值到 0 基序号
 * @param[zh-cn] l 物理层
 * @return[zh-cn] 0 基序号（NonMoving=0 / Moving=1）
 *
 * @brief[en] Maps a physics layer to its 0-based ordinal
 * @param[en] l The physics layer
 * @return[en] The 0-based ordinal (NonMoving=0 / Moving=1)
 */
internal func physicsLayerValue(l: PhysicsLayer): Int64 {
    match (l) {
        case PhysicsLayer.NonMoving => 0
        case PhysicsLayer.Moving => 1
    }
}

/**
 * @brief[zh-cn] 0 基序号转物理层（越界回退 Moving）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 物理层
 *
 * @brief[en] Converts a 0-based ordinal to the physics layer (out-of-range falls back to Moving)
 * @param[en] i The 0-based ordinal
 * @return[en] The physics layer
 */
internal func physicsLayerFrom(i: Int64): PhysicsLayer {
    if (i == 0) {
        PhysicsLayer.NonMoving
    } else {
        PhysicsLayer.Moving
    }
}

/**
 * @brief[zh-cn] 安装 PhysicsMotionType 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsMotionType (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsMotionType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsMotionType")
    b.staticMethod("Static") {_ => [LuaValue.of(physicsMotionTypeValue(PhysicsMotionType.Static))]}
    b.staticMethod("Kinematic") {_ => [LuaValue.of(physicsMotionTypeValue(PhysicsMotionType.Kinematic))]}
    b.staticMethod("Dynamic") {_ => [LuaValue.of(physicsMotionTypeValue(PhysicsMotionType.Dynamic))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsMotionTypeValue(physicsMotionTypeFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsActivation 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsActivation (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsActivation(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsActivation")
    b.staticMethod("Activate") {_ => [LuaValue.of(physicsActivationValue(PhysicsActivation.Activate))]}
    b.staticMethod("DontActivate") {_ => [LuaValue.of(physicsActivationValue(PhysicsActivation.DontActivate))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsActivationValue(physicsActivationFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsLayer 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsLayer (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsLayer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsLayer")
    b.staticMethod("NonMoving") {_ => [LuaValue.of(physicsLayerValue(PhysicsLayer.NonMoving))]}
    b.staticMethod("Moving") {_ => [LuaValue.of(physicsLayerValue(PhysicsLayer.Moving))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsLayerValue(physicsLayerFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsBodyDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsBodyDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsBodyDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsBodyDesc")
    // ===== 构造 =====
    b.constructor {
        args => PhysicsBodyDesc(shape: prebindAs<PhysicsShape>(args, 0), position: prebindVec3(args, 1),
            rotation: prebindQuat(args, 2), motionType: physicsMotionTypeFrom(prebindInt(args, 3, default: 2)),
            layer: physicsLayerFrom(prebindInt(args, 4, default: 1)),
            activation: physicsActivationFrom(prebindInt(args, 5, default: 0)),
            friction: prebindNum(args, 6, default: 0.2), restitution: prebindNum(args, 7, default: 0.0),
            autoSync: prebindBool(args, 8, default: true), mass: prebindNum(args, 9, default: -1.0),
            gravityFactor: prebindNum(args, 10, default: 1.0), linearDamping: prebindNum(args, 11, default: 0.05),
            angularDamping: prebindNum(args, 12, default: 0.05), isSensor: prebindBool(args, 13, default: false))
    }
    // ===== 形状 =====
    b.property("shape", getter: Some({ref => physicsShapeToLua(ref.cast<PhysicsBodyDesc>().shape)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().shape = prebindAsValue<PhysicsShape>(v)}))
    b.property("position", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsBodyDesc>().position, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().position = prebindAsValue<Vector3>(v)}))
    b.property("rotation", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsBodyDesc>().rotation, "three.core.math.Quaternion")
    }), setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().rotation = prebindAsValue<Quaternion>(v)}))
    // ===== 枚举字段 =====
    b.property("motionType",
        getter: Some({ref => LuaValue.of(physicsMotionTypeValue(ref.cast<PhysicsBodyDesc>().motionType))}),
        setter: Some({
            ref, v => ref.cast<PhysicsBodyDesc>().motionType = physicsMotionTypeFrom(v.intValue())
        }))
    b.property("layer", getter: Some({ref => LuaValue.of(physicsLayerValue(ref.cast<PhysicsBodyDesc>().layer))}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().layer = physicsLayerFrom(v.intValue())}))
    b.property("activation",
        getter: Some({ref => LuaValue.of(physicsActivationValue(ref.cast<PhysicsBodyDesc>().activation))}),
        setter: Some({
            ref, v => ref.cast<PhysicsBodyDesc>().activation = physicsActivationFrom(v.intValue())
        }))
    // ===== 物理参数 =====
    b.property("friction", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().friction)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().friction = v.numberValue()}))
    b.property("restitution", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().restitution)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().restitution = v.numberValue()}))
    b.property("autoSync", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().autoSync)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().autoSync = v.boolValue()}))
    b.property("mass", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().mass)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().mass = v.numberValue()}))
    b.property("gravityFactor", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().gravityFactor)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().gravityFactor = v.numberValue()}))
    b.property("linearDamping", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().linearDamping)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().linearDamping = v.numberValue()}))
    b.property("angularDamping", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().angularDamping)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().angularDamping = v.numberValue()}))
    b.property("isSensor", getter: Some({ref => LuaValue.of(ref.cast<PhysicsBodyDesc>().isSensor)}),
        setter: Some({ref, v => ref.cast<PhysicsBodyDesc>().isSensor = v.boolValue()}))
    b.install(vm)
}
