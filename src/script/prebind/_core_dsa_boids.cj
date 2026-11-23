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
 * @file[zh-cn] core_dsa_boids 鸟群算法的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.FlockConfig / Boid / Flock 绑定为 Lua 类型
 * three.core.dsa.FlockConfig / Boid / Flock
 * @explain[zh-cn] FlockConfig 为纯数据类：绑定 10 个浮点字段属性与全默认参数构造；
 * Boid 绑定 pos/vel/acc（Vector2 对象属性）、maxSpeed/maxForce 与 applyForce/
 * steerTowards/update；Flock 绑定 cfg 属性与 step/centerOfMass/averageSpeed/
 * averageNeighborDistance。对象数组参数（Boid.flock(Boid[])、Flock.boids、Flock 构造）
 * 无 Lua 通道（仅支持 Array<Float64>/Array<Int64>/Array<String>），故不绑定。
 *
 * @file[en] core_dsa_boids  Lua binding of the boids flocking algorithm (three.script.prebind)
 * @brief[en] Binds three.core.dsa.FlockConfig / Boid / Flock as Lua types
 * three.core.dsa.FlockConfig / Boid / Flock
 * @explain[en] FlockConfig is a pure data class: 10 float field props plus a fully-defaulted
 * constructor. Boid binds pos/vel/acc (Vector2 object props), maxSpeed/maxForce and
 * applyForce/steerTowards/update; Flock binds the cfg prop and step/centerOfMass/
 * averageSpeed/averageNeighborDistance. Object-array parameters (Boid.flock(Boid[]),
 * Flock.boids, the Flock constructor) have no Lua channel (only Array<Float64>/Array<Int64>/
 * Array<String> are supported) and are omitted.
 */
package three.script.prebind

import three.core.dsa.Boid
import three.core.dsa.Flock
import three.core.dsa.FlockConfig
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FlockConfig 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.FlockConfig）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FlockConfig
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.FlockConfig)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFlockConfig(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.FlockConfig")
    // ===== 构造（10 个默认参数，均可用 Lua 位置参数按序覆盖） =====
    b.constructor { args =>
        FlockConfig(
            alignRadius: prebindNum(args, 0, default: 50.0),
            cohesionRadius: prebindNum(args, 1, default: 50.0),
            separationRadius: prebindNum(args, 2, default: 25.0),
            alignWeight: prebindNum(args, 3, default: 1.0),
            cohesionWeight: prebindNum(args, 4, default: 1.0),
            separationWeight: prebindNum(args, 5, default: 1.5),
            maxSpeed: prebindNum(args, 6, default: 2.0),
            maxForce: prebindNum(args, 7, default: 0.05),
            worldWidth: prebindNum(args, 8, default: 800.0),
            worldHeight: prebindNum(args, 9, default: 600.0))
    }
    // ===== 属性（10 个浮点字段） =====
    b.property("alignRadius", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().alignRadius) }),
                              setter: Some({ ref, v => ref.cast<FlockConfig>().alignRadius = v.numberValue() }))
    b.property("cohesionRadius", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().cohesionRadius) }),
                                setter: Some({ ref, v => ref.cast<FlockConfig>().cohesionRadius = v.numberValue() }))
    b.property("separationRadius", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().separationRadius) }),
                                   setter: Some({ ref, v => ref.cast<FlockConfig>().separationRadius = v.numberValue() }))
    b.property("alignWeight", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().alignWeight) }),
                              setter: Some({ ref, v => ref.cast<FlockConfig>().alignWeight = v.numberValue() }))
    b.property("cohesionWeight", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().cohesionWeight) }),
                                setter: Some({ ref, v => ref.cast<FlockConfig>().cohesionWeight = v.numberValue() }))
    b.property("separationWeight", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().separationWeight) }),
                                   setter: Some({ ref, v => ref.cast<FlockConfig>().separationWeight = v.numberValue() }))
    b.property("maxSpeed", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().maxSpeed) }),
                           setter: Some({ ref, v => ref.cast<FlockConfig>().maxSpeed = v.numberValue() }))
    b.property("maxForce", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().maxForce) }),
                           setter: Some({ ref, v => ref.cast<FlockConfig>().maxForce = v.numberValue() }))
    b.property("worldWidth", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().worldWidth) }),
                             setter: Some({ ref, v => ref.cast<FlockConfig>().worldWidth = v.numberValue() }))
    b.property("worldHeight", getter: Some({ ref => LuaValue.of(ref.cast<FlockConfig>().worldHeight) }),
                              setter: Some({ ref, v => ref.cast<FlockConfig>().worldHeight = v.numberValue() }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Boid 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.Boid）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Boid
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.Boid)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBoid(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.Boid")
    // ===== 构造 =====
    b.constructor { args =>
        Boid(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1),
             args[2].numberValue(), args[3].numberValue())
    }
    // ===== 属性 =====
    b.property("pos",
        getter: Some({ ref => prebindRegister(ref.cast<Boid>().pos, "three.core.math.Vector2") }),
        setter: Some({ ref, v => ref.cast<Boid>().pos = LuaObjectRegistry.getAs<Vector2>(v.objectId()) }))
    b.property("vel",
        getter: Some({ ref => prebindRegister(ref.cast<Boid>().vel, "three.core.math.Vector2") }),
        setter: Some({ ref, v => ref.cast<Boid>().vel = LuaObjectRegistry.getAs<Vector2>(v.objectId()) }))
    b.property("acc",
        getter: Some({ ref => prebindRegister(ref.cast<Boid>().acc, "three.core.math.Vector2") }),
        setter: Some({ ref, v => ref.cast<Boid>().acc = LuaObjectRegistry.getAs<Vector2>(v.objectId()) }))
    b.property("maxSpeed", getter: Some({ ref => LuaValue.of(ref.cast<Boid>().maxSpeed) }),
                          setter: Some({ ref, v => ref.cast<Boid>().maxSpeed = v.numberValue() }))
    b.property("maxForce", getter: Some({ ref => LuaValue.of(ref.cast<Boid>().maxForce) }),
                          setter: Some({ ref, v => ref.cast<Boid>().maxForce = v.numberValue() }))
    // ===== 方法 =====
    b.method("applyForce") { ref, args =>
        ref.cast<Boid>().applyForce(prebindAs<Vector2>(args, 0))
        []
    }
    b.method("steerTowards") { ref, args =>
        [prebindRegister(ref.cast<Boid>().steerTowards(prebindAs<Vector2>(args, 0)), "three.core.math.Vector2")]
    }
    b.method("update") { ref, args =>
        ref.cast<Boid>().update(args[0].numberValue(), prebindAs<FlockConfig>(args, 1))
        []
    }
    // flock(boids: Array<Boid>, cfg) 跳过：Array<Boid> 对象数组无 Lua 通道
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Flock 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.Flock）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Flock
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.Flock)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFlock(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.Flock")
    // 构造跳过：init(boids: Array<Boid>, cfg) 的 Array<Boid> 无 Lua 通道
    // ===== 属性 =====
    b.property("cfg",
        getter: Some({ ref => prebindRegister(ref.cast<Flock>().cfg, "three.core.dsa.FlockConfig") }),
        setter: Some({ ref, v => ref.cast<Flock>().cfg = LuaObjectRegistry.getAs<FlockConfig>(v.objectId()) }))
    // ===== 方法 =====
    b.method("step") { ref, args =>
        ref.cast<Flock>().step(args[0].numberValue())
        []
    }
    b.method("centerOfMass") { ref, _ =>
        [prebindRegister(ref.cast<Flock>().centerOfMass(), "three.core.math.Vector2")]
    }
    b.method("averageSpeed") { ref, _ =>
        [LuaValue.of(ref.cast<Flock>().averageSpeed())]
    }
    b.method("averageNeighborDistance") { ref, _ =>
        [LuaValue.of(ref.cast<Flock>().averageNeighborDistance())]
    }
    b.install(vm)
}