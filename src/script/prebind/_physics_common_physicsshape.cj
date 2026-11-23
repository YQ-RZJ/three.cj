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
 * @file[zh-cn] physics_interfaces_physicsshape 物理形状类型的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.physics.common 的 PhysicsShapeType / PhysicsCompoundPart /
 * PhysicsShape 绑定为 Lua 类型
 * @explain[zh-cn] PhysicsShapeType 为无 value() 的枚举，绑定为常量命名空间：
 * 每个变体以 staticMethod 返回 0 基序号，fromValue 反向转换（越界回退 Box）。
 * PhysicsShape / PhysicsCompoundPart 为结构体，绑定层以「值对象」注册到 Lua 注册表：
 * 构造时把仓颉结构体装箱登记，读取时按 id 取回；字段为只读属性。
 * PhysicsShape 提供 box/sphere/capsule/cylinder/plane/mesh/convexHull/compound 静态工厂，
 * 参数与渲染侧 Geometry 对齐（Box 用全尺寸，其余用半高/半径）。
 * 本文件同时提供其余 physics 绑定共用的形状转换工具（internal）。
 *
 * @file[en] physics_interfaces_physicsshape  Lua bindings of the physics shape types
 * (three.script.prebind)
 * @brief[en] Binds three.physics.common PhysicsShapeType / PhysicsCompoundPart /
 * PhysicsShape as Lua types
 * @explain[en] PhysicsShapeType has no value(), so it is bound as a constant namespace: each
 * variant is a staticMethod returning its 0-based ordinal, and fromValue converts back
 * (out-of-range falls back to Box). PhysicsShape / PhysicsCompoundPart are structs exposed as
 * value objects registered in the Lua object registry: the constructor boxes the Cangjie
 * struct and getters fetch it back by id; fields are read-only properties.
 * PhysicsShape offers the box/sphere/capsule/cylinder/plane/mesh/convexHull/compound static
 * factories with parameters aligned to the render-side Geometry (Box takes full size, others
 * take half height / radius). This file also provides the internal shape conversion helpers
 * shared by the other physics bindings.
 */
package three.script.prebind

import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 形状类型枚举值到 0 基序号
 * @param[zh-cn] t 形状类型
 * @return[zh-cn] 0 基序号（Box=0 … Compound=7）
 *
 * @brief[en] Maps a shape-type enum to its 0-based ordinal
 * @param[en] t The shape type
 * @return[en] The 0-based ordinal (Box=0 … Compound=7)
 */
internal func physicsShapeTypeValue(t: PhysicsShapeType): Int64 {
    match (t) {
        case PhysicsShapeType.Box => 0
        case PhysicsShapeType.Sphere => 1
        case PhysicsShapeType.Capsule => 2
        case PhysicsShapeType.Cylinder => 3
        case PhysicsShapeType.Plane => 4
        case PhysicsShapeType.Mesh => 5
        case PhysicsShapeType.ConvexHull => 6
        case PhysicsShapeType.Compound => 7
    }
}

/**
 * @brief[zh-cn] 0 基序号转形状类型枚举（越界回退 Box）
 * @param[zh-cn] i 0 基序号
 * @return[zh-cn] 形状类型
 *
 * @brief[en] Converts a 0-based ordinal to the shape-type enum (out-of-range falls back to Box)
 * @param[en] i The 0-based ordinal
 * @return[en] The shape type
 */
internal func physicsShapeTypeFrom(i: Int64): PhysicsShapeType {
    match (i) {
        case 1 => PhysicsShapeType.Sphere
        case 2 => PhysicsShapeType.Capsule
        case 3 => PhysicsShapeType.Cylinder
        case 4 => PhysicsShapeType.Plane
        case 5 => PhysicsShapeType.Mesh
        case 6 => PhysicsShapeType.ConvexHull
        case 7 => PhysicsShapeType.Compound
        case _ => PhysicsShapeType.Box
    }
}

/**
 * @brief[zh-cn] 把形状结构体注册为 Lua 值对象
 * @param[zh-cn] shape 形状描述
 * @return[zh-cn] Lua 对象值
 *
 * @brief[en] Registers a shape struct as a Lua value object
 * @param[en] shape The shape description
 * @return[en] The Lua object value
 */
internal func physicsShapeToLua(shape: PhysicsShape): LuaValue {
    return prebindRegister(shape, "three.physics.common.PhysicsShape")
}

/**
 * @brief[zh-cn] 安装 PhysicsShapeType 的 Lua 绑定（常量命名空间）
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsShapeType (constant namespace)
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsShapeType(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsShapeType")
    b.staticMethod("Box") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Box))]}
    b.staticMethod("Sphere") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Sphere))]}
    b.staticMethod("Capsule") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Capsule))]}
    b.staticMethod("Cylinder") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Cylinder))]}
    b.staticMethod("Plane") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Plane))]}
    b.staticMethod("Mesh") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Mesh))]}
    b.staticMethod("ConvexHull") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.ConvexHull))]}
    b.staticMethod("Compound") {_ => [LuaValue.of(physicsShapeTypeValue(PhysicsShapeType.Compound))]}
    b.staticMethod("fromValue") {
        args => [LuaValue.of(physicsShapeTypeValue(physicsShapeTypeFrom(prebindInt(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsCompoundPart 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsCompoundPart
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsCompoundPart(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsCompoundPart")
    b.constructor {
        args => PhysicsCompoundPart(shape: prebindAs<PhysicsShape>(args, 0), position: prebindVec3(args, 1),
            rotation: prebindQuat(args, 2))
    }
    b.property("shape", getter: Some({ref => physicsShapeToLua(ref.cast<PhysicsCompoundPart>().shape)}))
    b.property("position", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsCompoundPart>().position, "three.core.math.Vector3")
    }))
    b.property("rotation", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsCompoundPart>().rotation, "three.core.math.Quaternion")
    }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsShape 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 构造签名按仓颉位置映射：
 * new(shapeType, halfExtent?, halfHeight?, radius?, vertices?, triangles?, parts?)。
 * 常规用法建议使用静态工厂（box/sphere/capsule/cylinder/plane/mesh/convexHull/compound）。
 *
 * @brief[en] Installs the Lua binding of PhysicsShape
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] The constructor follows the Cangjie positional mapping:
 * new(shapeType, halfExtent?, halfHeight?, radius?, vertices?, triangles?, parts?).
 * Prefer the static factories (box/sphere/capsule/cylinder/plane/mesh/convexHull/compound).
 */
public func installPhysicsShape(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.common.PhysicsShape")
    // ===== 构造 =====
    b.constructor {
        args => PhysicsShape(shapeType: physicsShapeTypeFrom(prebindInt(args, 0)), halfExtent: prebindVec3(args, 1),
            halfHeight: prebindNum(args, 2), radius: prebindNum(args, 3),
            vertices: prebindObjList<Vector3>(vm, args, 4).toArray(), triangles: prebindU32Array(vm, args, 5),
            parts: prebindObjList<PhysicsCompoundPart>(vm, args, 6).toArray())
    }
    // ===== 只读字段 =====
    b.property("shapeType",
        getter: Some({ref => LuaValue.of(physicsShapeTypeValue(ref.cast<PhysicsShape>().shapeType))}))
    b.property("halfExtent", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsShape>().halfExtent, "three.core.math.Vector3")
    }))
    b.property("halfHeight", getter: Some({ref => LuaValue.of(ref.cast<PhysicsShape>().halfHeight)}))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<PhysicsShape>().radius)}))
    b.property(
        "vertices",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<PhysicsShape>().vertices
                    var out = Array<LuaValue>(src.size, {
                        i => prebindRegister(src[i], "three.core.math.Vector3")
                    })
                    LuaValue.Array(out)
            }
        )
    )
    b.property("triangles", getter: Some({ref => prebindU32ArrayToLua(ref.cast<PhysicsShape>().triangles)}))
    b.property(
        "parts",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<PhysicsShape>().parts
                    var out = Array<LuaValue>(src.size, {
                        i => prebindRegister(src[i], "three.physics.common.PhysicsCompoundPart")
                    })
                    LuaValue.Array(out)
            }
        )
    )
    // ===== 静态工厂 =====
    b.staticMethod("box") {
        args => [physicsShapeToLua(PhysicsShape.box(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2)))]
    }
    b.staticMethod("sphere") {
        args => [physicsShapeToLua(PhysicsShape.sphere(prebindNum(args, 0)))]
    }
    b.staticMethod("capsule") {
        args => [physicsShapeToLua(PhysicsShape.capsule(prebindNum(args, 0), prebindNum(args, 1)))]
    }
    b.staticMethod("cylinder") {
        args => [physicsShapeToLua(PhysicsShape.cylinder(prebindNum(args, 0), prebindNum(args, 1)))]
    }
    b.staticMethod("plane") {
        _ => [physicsShapeToLua(PhysicsShape.plane())]
    }
    b.staticMethod("mesh") {
        args => [physicsShapeToLua(
            PhysicsShape.mesh(prebindObjList<Vector3>(vm, args, 0).toArray(), prebindU32Array(vm, args, 1)))]
    }
    b.staticMethod("convexHull") {
        args => [physicsShapeToLua(PhysicsShape.convexHull(prebindObjList<Vector3>(vm, args, 0).toArray()))]
    }
    b.staticMethod("compound") {
        args => [physicsShapeToLua(PhysicsShape.compound(prebindObjList<PhysicsCompoundPart>(vm, args, 0).toArray()))]
    }
    b.install(vm)
}
