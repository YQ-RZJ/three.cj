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
 * @file[zh-cn] physics_character_character 角色控制器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 PhysicsCharacterDesc / PhysicsCharacterFactory / PhysicsCharacter /
 * PhysicsCharacterVirtual 绑定为 Lua 类型
 * @explain[zh-cn] 角色描述（shape 只读，position / rotation / layer / mass / maxSlopeAngle
 * 可读写）；工厂（createCharacter / createVirtualCharacter）在物理线程内创建角色；
 * 刚体角色提供 addToPhysicsSystem / removeFromPhysicsSystem / postSimulation /
 * 速度与位置读写 / isOnGround / getGroundState / release；虚拟角色提供
 * update（带重力参数）/ 速度与位置 / isOnGround / getGroundState / release。
 * 两个角色类均实现 IReleasable，暴露 releasable。
 *
 * @file[en] physics_character_character  Lua bindings of the character controllers
 * (three.script.prebind)
 * @brief[en] Binds PhysicsCharacterDesc / PhysicsCharacterFactory / PhysicsCharacter /
 * PhysicsCharacterVirtual as Lua types
 * @explain[en] Character description (shape read-only; position / rotation / layer / mass /
 * maxSlopeAngle read-write); the factory (createCharacter / createVirtualCharacter) builds
 * characters on the physics thread; the rigid-body character exposes addToPhysicsSystem /
 * removeFromPhysicsSystem / postSimulation / velocity and position access / isOnGround /
 * getGroundState / release; the virtual character exposes update (with a gravity argument) /
 * velocity and position / isOnGround / getGroundState / release.
 * Both character classes implement IReleasable and expose releasable.
 */
package three.script.prebind

import three.physics.character.*
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsCharacterDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsCharacterDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsCharacterDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.character.PhysicsCharacterDesc")
    b.constructor {
        args => PhysicsCharacterDesc(shape: prebindAs<PhysicsShape>(args, 0), position: prebindVec3(args, 1),
            rotation: prebindQuat(args, 2), layer: UInt32(prebindInt(args, 3, default: 1) & 0xFFFFFFFF),
            mass: Float32(prebindNum(args, 4, default: 70.0)),
            maxSlopeAngle: Float32(prebindNum(args, 5, default: 0.7853982)))
    }
    b.property("shape", getter: Some({ref => physicsShapeToLua(ref.cast<PhysicsCharacterDesc>().shape)}))
    b.property("position", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsCharacterDesc>().position, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsCharacterDesc>().position = prebindAsValue<Vector3>(v)
    }))
    b.property("rotation", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsCharacterDesc>().rotation, "three.core.math.Quaternion")
    }), setter: Some({
        ref, v => ref.cast<PhysicsCharacterDesc>().rotation = prebindAsValue<Quaternion>(v)
    }))
    b.property("layer", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsCharacterDesc>().layer))}),
        setter: Some({
            ref, v => ref.cast<PhysicsCharacterDesc>().layer = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("mass", getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsCharacterDesc>().mass))}),
        setter: Some({ref, v => ref.cast<PhysicsCharacterDesc>().mass = Float32(v.numberValue())}))
    b.property("maxSlopeAngle",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<PhysicsCharacterDesc>().maxSlopeAngle))}), setter: Some({
            ref, v => ref.cast<PhysicsCharacterDesc>().maxSlopeAngle = Float32(v.numberValue())
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsCharacterFactory 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsCharacterFactory
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsCharacterFactory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.character.PhysicsCharacterFactory")
    b.constructor {
        args => PhysicsCharacterFactory(desc: prebindAs<PhysicsCharacterDesc>(args, 0))
    }
    b.method("createCharacter") {
        ref, args => [prebindRegister(
            ref.cast<PhysicsCharacterFactory>().createCharacter(prebindAs<PhysicsWorld>(args, 0)),
            "three.physics.character.PhysicsCharacter")]
    }
    b.method("createVirtualCharacter") {
        ref, args => [prebindRegister(
            ref.cast<PhysicsCharacterFactory>().createVirtualCharacter(prebindAs<PhysicsWorld>(args, 0)),
            "three.physics.character.PhysicsCharacterVirtual")]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsCharacter 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsCharacter
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsCharacter(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.character.PhysicsCharacter")
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsCharacter>().releasable)}))
    b.method("addToPhysicsSystem") {
        ref, args =>
            ref
                .cast<PhysicsCharacter>()
                .addToPhysicsSystem(activation: physicsActivationFrom(prebindInt(args, 0, default: 0)))
            Array<LuaValue>()
    }
    b.method("removeFromPhysicsSystem") {
        ref, _ =>
            ref.cast<PhysicsCharacter>().removeFromPhysicsSystem()
            Array<LuaValue>()
    }
    b.method("postSimulation") {
        ref, args =>
            ref
                .cast<PhysicsCharacter>()
                .postSimulation(maxSeparationDistance: Float32(prebindNum(args, 0, default: 0.05)))
            Array<LuaValue>()
    }
    b.method("setLinearVelocity") {
        ref, args =>
            ref.cast<PhysicsCharacter>().setLinearVelocity(prebindAs<Vector3>(args, 0))
            Array<LuaValue>()
    }
    b.method("getLinearVelocity") {
        ref, _ => [prebindRegister(ref.cast<PhysicsCharacter>().getLinearVelocity(), "three.core.math.Vector3")]
    }
    b.method("getPosition") {
        ref, _ => [prebindRegister(ref.cast<PhysicsCharacter>().getPosition(), "three.core.math.Vector3")]
    }
    b.method("setPosition") {
        ref, args =>
            ref
                .cast<PhysicsCharacter>()
                .setPosition(prebindAs<Vector3>(args, 0),
                    activation: physicsActivationFrom(prebindInt(args, 1, default: 0)))
            Array<LuaValue>()
    }
    b.method("isOnGround") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsCharacter>().isOnGround())]
    }
    b.method("getGroundState") {
        ref, _ => [LuaValue.of(Float64(ref.cast<PhysicsCharacter>().getGroundState()))]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsCharacter>().release())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsCharacterVirtual 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsCharacterVirtual
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsCharacterVirtual(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.character.PhysicsCharacterVirtual")
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsCharacterVirtual>().releasable)}))
    b.method("update") {
        ref, args =>
            let gravity = if (args.size >= 2) {
                prebindAs<Vector3>(args, 1)
            } else {
                Vector3(0.0, -9.81, 0.0)
            }
            ref.cast<PhysicsCharacterVirtual>().update(Float32(prebindNum(args, 0)), gravity: gravity)
            Array<LuaValue>()
    }
    b.method("setLinearVelocity") {
        ref, args =>
            ref.cast<PhysicsCharacterVirtual>().setLinearVelocity(prebindAs<Vector3>(args, 0))
            Array<LuaValue>()
    }
    b.method("getLinearVelocity") {
        ref, _ => [prebindRegister(ref.cast<PhysicsCharacterVirtual>().getLinearVelocity(), "three.core.math.Vector3")]
    }
    b.method("getPosition") {
        ref, _ => [prebindRegister(ref.cast<PhysicsCharacterVirtual>().getPosition(), "three.core.math.Vector3")]
    }
    b.method("setPosition") {
        ref, args =>
            ref.cast<PhysicsCharacterVirtual>().setPosition(prebindAs<Vector3>(args, 0))
            Array<LuaValue>()
    }
    b.method("isOnGround") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsCharacterVirtual>().isOnGround())]
    }
    b.method("getGroundState") {
        ref, _ => [LuaValue.of(Float64(ref.cast<PhysicsCharacterVirtual>().getGroundState()))]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsCharacterVirtual>().release())]
    }
    b.install(vm)
}
