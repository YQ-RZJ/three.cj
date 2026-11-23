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
 * @file[zh-cn] animation_blend_animationobjectgroup 动画对象组 AnimationObjectGroup 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.blend.AnimationObjectGroup 绑定为 Lua 类型
 * three.animation.blend.AnimationObjectGroup
 * @explain[zh-cn] 覆盖构造（可选初始对象数组）、属性 uuid，以及 add / remove / uncache
 * 三个对象数组方法（走 prebindObjList 对象数组通道）。
 * 跳过：stats（HashMap<String, Any>）。
 *
 * @file[en] animation_blend_animationobjectgroup  Lua binding of the animation object group
 * AnimationObjectGroup (three.script.prebind)
 * @brief[en] Binds three.animation.blend.AnimationObjectGroup as the Lua type
 * three.animation.blend.AnimationObjectGroup
 * @explain[en] Covers construction (optional initial object array), the uuid property and the
 * three object-array methods add / remove / uncache (through the prebindObjList channel).
 * Skipped: stats (HashMap<String, Any>).
 */
package three.script.prebind

import three.animation.blend.AnimationObjectGroup
import three.scene.objects.Object3D
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AnimationObjectGroup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.blend.AnimationObjectGroup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationObjectGroup
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.blend.AnimationObjectGroup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationObjectGroup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.blend.AnimationObjectGroup")
    // ===== 构造（可选初始对象数组） =====
    b.constructor {
        args => AnimationObjectGroup(objects: prebindObjList<Object3D>(vm, args, 0).toArray())
    }
    // ===== 属性 =====
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<AnimationObjectGroup>().uuid)}))
    // ===== 对象增删 =====
    b.method("add") {
        ref, args =>
            ref.cast<AnimationObjectGroup>().add(prebindObjList<Object3D>(vm, args, 0).toArray())
            [LuaValue.Object(ref.id)]
    }
    b.method("remove") {
        ref, args =>
            ref.cast<AnimationObjectGroup>().remove(prebindObjList<Object3D>(vm, args, 0).toArray())
            [LuaValue.Object(ref.id)]
    }
    b.method("uncache") {
        ref, args =>
            ref.cast<AnimationObjectGroup>().uncache(prebindObjList<Object3D>(vm, args, 0).toArray())
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
