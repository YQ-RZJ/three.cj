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
 * @file[zh-cn] physics_binding_physicsbinding PhysicsBinding 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.physics.binding.PhysicsBinding 绑定为 Lua 类型
 * three.physics.binding.PhysicsBinding
 * @explain[zh-cn] PhysicsBinding 为纯静态工具类：bind（通用绑定）与
 * meshBox / meshSphere / meshCapsule / meshCylinder（从渲染几何自动派生碰撞形状）、
 * ground（静态地面）与 unbind。object3d / mesh 参数为 three.scene 对象；场景绑定建立后
 * 即可直接传 Lua 侧 Mesh。
 *
 * @file[en] physics_binding_physicsbinding  Lua binding of PhysicsBinding
 * (three.script.prebind)
 * @brief[en] Binds three.physics.binding.PhysicsBinding as the Lua type
 * three.physics.binding.PhysicsBinding
 * @explain[en] PhysicsBinding is a pure static utility: bind (generic binding) plus
 * meshBox / meshSphere / meshCapsule / meshCylinder (deriving collider shapes from render
 * geometry), ground (static ground) and unbind. The object3d / mesh parameters are
 * three.scene objects; once scene bindings exist, Lua-side Meshes can be passed directly.
 */
package three.script.prebind

import three.physics.binding.PhysicsBinding
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.scene.objects.Object3D
import three.scene.entity.Mesh
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsBinding 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsBinding
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsBinding(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.binding.PhysicsBinding")
    b.staticMethod("bind") {
        args => [prebindRegister(
            PhysicsBinding.bind(prebindAs<PhysicsWorld>(args, 0), prebindAs<Object3D>(args, 1),
                prebindAs<PhysicsShape>(args, 2), motionType: physicsMotionTypeFrom(prebindInt(args, 3, default: 2)),
                friction: prebindNum(args, 4, default: 0.2), restitution: prebindNum(args, 5, default: 0.0),
                syncToObj: prebindBool(args, 6, default: true), isSensor: prebindBool(args, 7, default: false)),
            "three.physics.body.RigidBody")]
    }
    b.staticMethod("meshBox") {
        args => [prebindRegister(
            PhysicsBinding.meshBox(prebindAs<PhysicsWorld>(args, 0), prebindAs<Mesh>(args, 1),
                motionType: physicsMotionTypeFrom(prebindInt(args, 2, default: 2)),
                friction: prebindNum(args, 3, default: 0.2), restitution: prebindNum(args, 4, default: 0.0)),
            "three.physics.body.RigidBody")]
    }
    b.staticMethod("meshSphere") {
        args => [prebindRegister(
            PhysicsBinding.meshSphere(prebindAs<PhysicsWorld>(args, 0), prebindAs<Mesh>(args, 1),
                motionType: physicsMotionTypeFrom(prebindInt(args, 2, default: 2)),
                friction: prebindNum(args, 3, default: 0.2), restitution: prebindNum(args, 4, default: 0.0)),
            "three.physics.body.RigidBody")]
    }
    b.staticMethod("meshCapsule") {
        args => [prebindRegister(
            PhysicsBinding.meshCapsule(prebindAs<PhysicsWorld>(args, 0), prebindAs<Mesh>(args, 1),
                motionType: physicsMotionTypeFrom(prebindInt(args, 2, default: 2)),
                friction: prebindNum(args, 3, default: 0.2), restitution: prebindNum(args, 4, default: 0.0)),
            "three.physics.body.RigidBody")]
    }
    b.staticMethod("meshCylinder") {
        args => [prebindRegister(
            PhysicsBinding.meshCylinder(prebindAs<PhysicsWorld>(args, 0), prebindAs<Mesh>(args, 1),
                motionType: physicsMotionTypeFrom(prebindInt(args, 2, default: 2)),
                friction: prebindNum(args, 3, default: 0.2), restitution: prebindNum(args, 4, default: 0.0)),
            "three.physics.body.RigidBody")]
    }
    b.staticMethod("ground") {
        args => [prebindRegister(
            PhysicsBinding.ground(prebindAs<PhysicsWorld>(args, 0), prebindAs<Mesh>(args, 1),
                yPosition: prebindNum(args, 2)), "three.physics.body.RigidBody")]
    }
    b.staticMethod("unbind") {
        args =>
            PhysicsBinding.unbind(prebindAs<PhysicsWorld>(args, 0), prebindAs<Object3D>(args, 1))
            Array<LuaValue>()
    }
    b.install(vm)
}
