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
 * @file[zh-cn] renderers_helpers_constrainthelper ConstraintHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.ConstraintHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（world / desc / bodyA / bodyB / color；四个前置参数均为已绑定具体类，
 * 缺任一项时降级为无参构造，避免 Lua 侧 new 崩溃）、属性（world / desc / bodyA / bodyB /
 * anchorA / anchorB / connection / axisArrow / color）与方法 update，以及 Object3D 与
 * IReleasable 成员。物理世界、约束描述、刚体、锚点、连线、箭头均以已绑定类型往返；
 * color 为 UInt32 十六进制值。Lua 类表没有继承，本类绑定在 b.install 之前复用 Object3D 与
 * IReleasable 成员。跳过成员：无。
 *
 * @file[en] renderers_helpers_constrainthelper  Lua binding of ConstraintHelper
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.ConstraintHelper as a Lua type
 * @explain[en] Binds the constructor (world / desc / bodyA / bodyB / color; all four leading
 * parameters are bound concrete classes and the no-arg constructor is used when any is missing, so
 * a Lua-side new never crashes), the properties (world / desc / bodyA / bodyB / anchorA / anchorB /
 * connection / axisArrow / color) and update, plus the Object3D and IReleasable members. The
 * physics world, constraint description, rigid bodies, anchors, connection line and arrow
 * round-trip as bound types; color is a UInt32 hex value. Lua class tables have no inheritance, so
 * the Object3D and IReleasable members are reused before b.install. Skipped: none.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.scene.entity.*
import three.core.math.*
import three.physics.world.PhysicsWorld
import three.physics.body.RigidBody
import three.physics._interfaces.*
import three.physics.common.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ConstraintHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.ConstraintHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ConstraintHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.ConstraintHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installConstraintHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.ConstraintHelper")
    // ===== 构造：world / desc / bodyA / bodyB / color（参数不完整时降级为无参构造） =====
    b.constructor {
        args => if (args.size >= 4 && args[0].isObject && args[1].isObject && args[2].isObject && args[3].isObject) {
            ConstraintHelper(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsConstraintDesc>(args, 1),
                prebindAs<RigidBody>(args, 2), prebindAs<RigidBody>(args, 3),
                color: _prebindHlpHexArg(args, 4, default: 0xffaa00))
        } else {
            ConstraintHelper()
        }
    }
    // ===== 继承成员：Object3D → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 约束自有成员 =====
    b.property("world", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().world, "three.physics.world.PhysicsWorld")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().world = prebindAsValue<PhysicsWorld>(v)
    }))
    b.property("desc", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().desc, "three.physics.common.PhysicsConstraintDesc")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().desc = prebindAsValue<PhysicsConstraintDesc>(v)
    }))
    b.property("bodyA", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().bodyA, "three.physics.body.RigidBody")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().bodyA = prebindAsValue<RigidBody>(v)
    }))
    b.property("bodyB", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().bodyB, "three.physics.body.RigidBody")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().bodyB = prebindAsValue<RigidBody>(v)
    }))
    b.property("anchorA", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().anchorA, "three.renderers.helpers.PointLightHelper")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().anchorA = prebindAsValue<PointLightHelper>(v)
    }))
    b.property("anchorB", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().anchorB, "three.renderers.helpers.PointLightHelper")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().anchorB = prebindAsValue<PointLightHelper>(v)
    }))
    b.property("connection", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().connection, "three.scene.entity.Line")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().connection = prebindAsValue<Line>(v)
    }))
    b.property("axisArrow", getter: Some({
        ref => prebindRegister(ref.cast<ConstraintHelper>().axisArrow, "three.renderers.helpers.ArrowHelper")
    }), setter: Some({
        ref, v => ref.cast<ConstraintHelper>().axisArrow = prebindAsValue<ArrowHelper>(v)
    }))
    b.property("color", getter: Some({ref => LuaValue.of(Float64(ref.cast<ConstraintHelper>().color))}),
        setter: Some({ref, v => ref.cast<ConstraintHelper>().color = UInt32(v.intValue())}))
    b.method("update") {
        ref, _ =>
            ref.cast<ConstraintHelper>().update()
            []
    }
    b.install(vm)
}
