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
 * @file[zh-cn] physics_vehicle_vehicle 载具的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 PhysicsVehicleWheelDesc / PhysicsVehicleEngineDesc / PhysicsVehicleDesc /
 * PhysicsVehicle / PhysicsVehicleFactory 绑定为 Lua 类型
 * @explain[zh-cn] 三个描述类均为纯数据：字段全部可读写（wheels / drivenWheels /
 * gearRatios / reverseGearRatios 在 Lua 侧为数组）。PhysicsVehicle 暴露 releasable /
 * chassis（刚体句柄）/ wheelCount / setDriverInput(forward, steer, brake?, handBrake?) /
 * getWheelWorldTransform(index) / release；工厂在物理线程内创建载具。
 *
 * @file[en] physics_vehicle_vehicle  Lua bindings of the vehicle (three.script.prebind)
 * @brief[en] Binds PhysicsVehicleWheelDesc / PhysicsVehicleEngineDesc / PhysicsVehicleDesc /
 * PhysicsVehicle / PhysicsVehicleFactory as Lua types
 * @explain[en] All three description classes are pure data with read-write fields
 * (wheels / drivenWheels / gearRatios / reverseGearRatios are arrays on the Lua side).
 * PhysicsVehicle exposes releasable / chassis (body handle) / wheelCount /
 * setDriverInput(forward, steer, brake?, handBrake?) / getWheelWorldTransform(index) /
 * release; the factory builds the vehicle on the physics thread.
 */
package three.script.prebind

import three.physics.vehicle.*
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsVehicleWheelDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsVehicleWheelDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsVehicleWheelDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.vehicle.PhysicsVehicleWheelDesc")
    b.constructor {
        args => PhysicsVehicleWheelDesc(position: prebindVec3(args, 0))
    }
    b.property("position", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsVehicleWheelDesc>().position, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().position = prebindAsValue<Vector3>(v)
    }))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().radius)}),
        setter: Some({ref, v => ref.cast<PhysicsVehicleWheelDesc>().radius = v.numberValue()}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().width)}),
        setter: Some({ref, v => ref.cast<PhysicsVehicleWheelDesc>().width = v.numberValue()}))
    b.property("suspensionMinLength", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().suspensionMinLength)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().suspensionMinLength = v.numberValue()
    }))
    b.property("suspensionMaxLength", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().suspensionMaxLength)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().suspensionMaxLength = v.numberValue()
    }))
    b.property("suspensionFrequency", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().suspensionFrequency)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().suspensionFrequency = v.numberValue()
    }))
    b.property("suspensionDamping", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().suspensionDamping)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().suspensionDamping = v.numberValue()
    }))
    b.property("maxSteerAngle", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().maxSteerAngle)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleWheelDesc>().maxSteerAngle = v.numberValue()
        }))
    b.property("maxBrakeTorque", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().maxBrakeTorque)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleWheelDesc>().maxBrakeTorque = v.numberValue()
        }))
    b.property("maxHandBrakeTorque", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().maxHandBrakeTorque)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().maxHandBrakeTorque = v.numberValue()
    }))
    b.property("lateralFriction",
        getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().lateralFriction)}), setter: Some({
            ref, v => ref.cast<PhysicsVehicleWheelDesc>().lateralFriction = v.numberValue()
        }))
    b.property("longitudinalFriction", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().longitudinalFriction)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleWheelDesc>().longitudinalFriction = v.numberValue()
    }))
    b.property("inertia", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().inertia)}),
        setter: Some({ref, v => ref.cast<PhysicsVehicleWheelDesc>().inertia = v.numberValue()}))
    b.property("angularDamping", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleWheelDesc>().angularDamping)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleWheelDesc>().angularDamping = v.numberValue()
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsVehicleEngineDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsVehicleEngineDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsVehicleEngineDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.vehicle.PhysicsVehicleEngineDesc")
    b.constructor {_ => PhysicsVehicleEngineDesc()}
    b.property("maxTorque", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().maxTorque)}),
        setter: Some({ref, v => ref.cast<PhysicsVehicleEngineDesc>().maxTorque = v.numberValue()}))
    b.property("minRPM", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().minRPM)}),
        setter: Some({ref, v => ref.cast<PhysicsVehicleEngineDesc>().minRPM = v.numberValue()}))
    b.property("maxRPM", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().maxRPM)}),
        setter: Some({ref, v => ref.cast<PhysicsVehicleEngineDesc>().maxRPM = v.numberValue()}))
    b.property("gearRatios", getter: Some({
        ref => prebindF64ListToLua(ref.cast<PhysicsVehicleEngineDesc>().gearRatios)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleEngineDesc>().gearRatios = prebindF64List(vm, [v], 0)
    }))
    b.property("reverseGearRatios", getter: Some({
        ref => prebindF64ListToLua(ref.cast<PhysicsVehicleEngineDesc>().reverseGearRatios)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleEngineDesc>().reverseGearRatios = prebindF64List(vm, [v], 0)
    }))
    b.property("shiftUpRPM", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().shiftUpRPM)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleEngineDesc>().shiftUpRPM = v.numberValue()
        }))
    b.property("shiftDownRPM", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().shiftDownRPM)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleEngineDesc>().shiftDownRPM = v.numberValue()
        }))
    b.property("switchLatency", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().switchLatency)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleEngineDesc>().switchLatency = v.numberValue()
        }))
    b.property("switchTime", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().switchTime)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleEngineDesc>().switchTime = v.numberValue()
        }))
    b.property("clutchStrength", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicleEngineDesc>().clutchStrength)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleEngineDesc>().clutchStrength = v.numberValue()
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsVehicleDesc 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsVehicleDesc
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsVehicleDesc(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.vehicle.PhysicsVehicleDesc")
    b.constructor {
        args => PhysicsVehicleDesc(chassisDesc: prebindAs<PhysicsBodyDesc>(args, 0))
    }
    b.property("chassisDesc", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsVehicleDesc>().chassisDesc, "three.physics.common.PhysicsBodyDesc")
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleDesc>().chassisDesc = prebindAsValue<PhysicsBodyDesc>(v)
    }))
    b.property(
        "wheels",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<PhysicsVehicleDesc>().wheels
                    var out = Array<LuaValue>(src.size, {
                        i => prebindRegister(src[i], "three.physics.vehicle.PhysicsVehicleWheelDesc")
                    })
                    LuaValue.Array(out)
            }
        ),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleDesc>().wheels = prebindObjList<PhysicsVehicleWheelDesc>(vm, [v], 0)
        })
    )
    b.property("engine", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsVehicleDesc>().engine, "three.physics.vehicle.PhysicsVehicleEngineDesc")
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleDesc>().engine = prebindAsValue<PhysicsVehicleEngineDesc>(v)
    }))
    b.property("drivenWheels", getter: Some({ref => prebindI64ListToLua(ref.cast<PhysicsVehicleDesc>().drivenWheels)}),
        setter: Some({
            ref, v => ref.cast<PhysicsVehicleDesc>().drivenWheels = prebindI64List(vm, [v], 0)
        }))
    b.property("maxPitchRollAngle", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsVehicleDesc>().maxPitchRollAngle)
    }), setter: Some({
        ref, v => ref.cast<PhysicsVehicleDesc>().maxPitchRollAngle = v.numberValue()
    }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsVehicle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsVehicle
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsVehicle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.vehicle.PhysicsVehicle")
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicle>().releasable)}))
    b.property("chassis", getter: Some({ref => physicsBodyHandleToLua(ref.cast<PhysicsVehicle>().chassis)}))
    b.property("wheelCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsVehicle>().wheelCount)}))
    b.method("setDriverInput") {
        ref, args =>
            ref
                .cast<PhysicsVehicle>()
                .setDriverInput(prebindNum(args, 0), prebindNum(args, 1), brake: prebindNum(args, 2),
                    handBrake: prebindNum(args, 3))
            Array<LuaValue>()
    }
    b.method("getWheelWorldTransform") {
        ref, args => [prebindRegister(ref.cast<PhysicsVehicle>().getWheelWorldTransform(prebindInt(args, 0)),
            "three.core.math.Matrix4")]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsVehicle>().release())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsVehicleFactory 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsVehicleFactory
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsVehicleFactory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.vehicle.PhysicsVehicleFactory")
    b.constructor {
        args => PhysicsVehicleFactory(desc: prebindAs<PhysicsVehicleDesc>(args, 0))
    }
    b.method("createVehicle") {
        ref, args => [prebindRegister(ref.cast<PhysicsVehicleFactory>().createVehicle(prebindAs<PhysicsWorld>(args, 0)),
            "three.physics.vehicle.PhysicsVehicle")]
    }
    b.install(vm)
}
