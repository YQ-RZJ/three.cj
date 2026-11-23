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
 * @file[zh-cn] animation_offline_rawskeleton 离线骨骼 RawJoint / RawSkeleton 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.offline.RawJoint 与 RawSkeleton 绑定为 Lua 类型
 * @explain[zh-cn] RawJoint：构造（name, parentIndex）与全部 public 属性（name /
 * parentIndex / localTranslation / localRotation / localScale，后三个为 Vector3F /
 * QuaternionF 对象属性，读写经对象桥接）。
 * RawSkeleton：无参构造、addJoint（返回并注册新的 RawJoint）、numJoints、validate；
 * MAX_JOINTS 以静态方法暴露；joints（ArrayList<RawJoint>）暂不绑定（无嵌套容器通道）。
 *
 * @file[en] animation_offline_rawskeleton  Lua bindings of the offline skeleton RawJoint / RawSkeleton
 * (three.script.prebind)
 * @brief[en] Binds three.animation.offline.RawJoint and RawSkeleton as Lua types
 * @explain[en] RawJoint: construction (name, parentIndex) and all public properties
 * (name / parentIndex / localTranslation / localRotation / localScale; the last three are
 * Vector3F / QuaternionF object properties read/written through the object bridge).
 * RawSkeleton: the parameterless constructor, addJoint (returns and registers a fresh
 * RawJoint), numJoints, validate; MAX_JOINTS is exposed as a static method; joints
 * (ArrayList<RawJoint>) stays unbound (no nested-container channel).
 */
package three.script.prebind

import three.animation.offline.RawJoint
import three.animation.offline.RawSkeleton
import three.core.math.Vector3F
import three.core.math.QuaternionF
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RawJoint 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.RawJoint）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawJoint
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.RawJoint)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawJoint(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawJoint")
    b.constructor { args => RawJoint(prebindStr(args, 0), Int64(prebindInt(args, 1))) }
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<RawJoint>().name) }),
        setter: Some({ ref, v => ref.cast<RawJoint>().name = v.stringValue() }))
    b.property("parentIndex",
        getter: Some({ ref => LuaValue.of(Int64(ref.cast<RawJoint>().parentIndex)) }),
        setter: Some({ ref, v => ref.cast<RawJoint>().parentIndex = Int64(v.intValue()) }))
    b.property("localTranslation",
        getter: Some({ ref => prebindRegister(ref.cast<RawJoint>().localTranslation, "three.core.math.Vector3F") }),
        setter: Some({ ref, v =>
            ref.cast<RawJoint>().localTranslation = LuaObjectRegistry.getAs<Vector3F>(v.objectId())
        }))
    b.property("localRotation",
        getter: Some({ ref => prebindRegister(ref.cast<RawJoint>().localRotation, "three.core.math.QuaternionF") }),
        setter: Some({ ref, v =>
            ref.cast<RawJoint>().localRotation = LuaObjectRegistry.getAs<QuaternionF>(v.objectId())
        }))
    b.property("localScale",
        getter: Some({ ref => prebindRegister(ref.cast<RawJoint>().localScale, "three.core.math.Vector3F") }),
        setter: Some({ ref, v =>
            ref.cast<RawJoint>().localScale = LuaObjectRegistry.getAs<Vector3F>(v.objectId())
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RawSkeleton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.RawSkeleton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawSkeleton
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.RawSkeleton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawSkeleton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawSkeleton")
    b.constructor { _ => RawSkeleton() }
    b.staticMethod("MAX_JOINTS") { _ => [LuaValue.of(Int64(RawSkeleton.MAX_JOINTS))] }
    b.method("addJoint") { ref, args =>
        let joint = ref.cast<RawSkeleton>().addJoint(prebindStr(args, 0), Int64(prebindInt(args, 1)))
        [prebindRegister(joint, "three.animation.offline.RawJoint")]
    }
    b.method("numJoints") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<RawSkeleton>().numJoints()))]
    }
    b.method("validate") { ref, _ =>
        [LuaValue.of(ref.cast<RawSkeleton>().validate())]
    }
    b.install(vm)
}

