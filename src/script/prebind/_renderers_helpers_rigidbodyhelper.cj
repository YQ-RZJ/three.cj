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
 * @file[zh-cn] renderers_helpers_rigidbodyhelper RigidBodyHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.RigidBodyHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 body / shape / color：body 为 RigidBody 对象时走带参构造，否则
 * 降级为无参构造，避免 Lua 侧 new 崩溃）、属性（body / shape / shapeLines / velocityArrow /
 * angularVelocityArrow / color）、方法 setShape（返回自身）与 update，以及 Object3D 与
 * IReleasable 成员。PhysicsShape 为已绑定具体类，shape 可读写；color 为 UInt32 十六进制值。
 * Lua 类表没有继承，本类绑定在 b.install 之前复用 Object3D 与 IReleasable 成员。跳过成员：无。
 *
 * @file[en] renderers_helpers_rigidbodyhelper  Lua binding of RigidBodyHelper
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.RigidBodyHelper as a Lua type
 * @explain[en] Binds the constructor (optional body / shape / color: a RigidBody first argument
 * selects the parameterized overload, otherwise it degrades to the no-arg constructor so a Lua-side
 * new never crashes), the properties (body / shape / shapeLines / velocityArrow /
 * angularVelocityArrow / color), setShape (returns self) and update, plus the Object3D and
 * IReleasable members. PhysicsShape is a bound concrete class, so shape is read-write; color is a
 * UInt32 hex value. Lua class tables have no inheritance, so the Object3D and IReleasable members
 * are reused before b.install. Skipped: none.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.scene.entity.*
import three.core.math.*
import three.physics.body.RigidBody
import three.physics._interfaces.*
import three.physics.common.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RigidBodyHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.RigidBodyHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RigidBodyHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.RigidBodyHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRigidBodyHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.RigidBodyHelper")
    // ===== 构造：可选 body / shape / color（无 body 时降级为无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            if (args.size > 1 && args[1].isObject) {
                RigidBodyHelper(prebindAs<RigidBody>(args, 0), shape: prebindAs<PhysicsShape>(args, 1),
                    color: _prebindHlpHexArg(args, 2, default: 0x00ff00))
            } else {
                RigidBodyHelper(prebindAs<RigidBody>(args, 0), color: _prebindHlpHexArg(args, 1, default: 0x00ff00))
            }
        } else {
            RigidBodyHelper()
        }
    }
    // ===== 继承成员：Object3D → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 刚体辅助自有成员 =====
    b.property("body", getter: Some({
        ref => prebindRegister(ref.cast<RigidBodyHelper>().body, "three.physics.body.RigidBody")
    }), setter: Some({
        ref, v => ref.cast<RigidBodyHelper>().body = prebindAsValue<RigidBody>(v)
    }))
    b.property("shape", getter: Some({
        ref => prebindRegister(ref.cast<RigidBodyHelper>().shape, "three.physics.common.PhysicsShape")
    }), setter: Some({
        ref, v => ref.cast<RigidBodyHelper>().shape = prebindAsValue<PhysicsShape>(v)
    }))
    b.property("shapeLines", getter: Some({
        ref => prebindRegister(ref.cast<RigidBodyHelper>().shapeLines, "three.scene.entity.LineSegments")
    }), setter: Some({
        ref, v => ref.cast<RigidBodyHelper>().shapeLines = prebindAsValue<LineSegments>(v)
    }))
    b.property("velocityArrow", getter: Some({
        ref => prebindRegister(ref.cast<RigidBodyHelper>().velocityArrow, "three.renderers.helpers.ArrowHelper")
    }), setter: Some({
        ref, v => ref.cast<RigidBodyHelper>().velocityArrow = prebindAsValue<ArrowHelper>(v)
    }))
    b.property("angularVelocityArrow", getter: Some({
        ref => prebindRegister(ref.cast<RigidBodyHelper>().angularVelocityArrow, "three.renderers.helpers.ArrowHelper")
    }), setter: Some({
        ref, v => ref.cast<RigidBodyHelper>().angularVelocityArrow = prebindAsValue<ArrowHelper>(v)
    }))
    b.property("color", getter: Some({ref => LuaValue.of(Float64(ref.cast<RigidBodyHelper>().color))}),
        setter: Some({ref, v => ref.cast<RigidBodyHelper>().color = UInt32(v.intValue())}))
    b.method("setShape") {
        ref, args =>
            ref.cast<RigidBodyHelper>().setShape(prebindAs<PhysicsShape>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("update") {
        ref, _ =>
            ref.cast<RigidBodyHelper>().update()
            []
    }
    b.install(vm)
}
