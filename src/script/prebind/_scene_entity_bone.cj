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
 * @file[zh-cn] scene_entity_bone Bone 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.Bone 绑定为 Lua 类型 three.scene.entity.Bone
 * @explain[zh-cn] Bone 仅有无参构造，全部行为继承自 Object3D；本绑定只注册类型表与
 * .new 构造，供 Skeleton.bones / getBoneByName 等通道回传骨节点。跳过：无。
 *
 * @file[en] scene_entity_bone  Lua binding of Bone (three.script.prebind)
 * @brief[en] Binds three.scene.entity.Bone as the Lua type three.scene.entity.Bone
 * @explain[en] Bone only has a parameterless constructor and inherits all behavior from
 * Object3D; this binding registers just the type table and .new so bone nodes can round-trip
 * through Skeleton.bones / getBoneByName. Skipped: none.
 */
package three.script.prebind

import three.scene.entity.Bone
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Bone 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.Bone）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Bone
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.Bone)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBone(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.Bone")
    // ===== 构造 =====
    b.constructor {_ => Bone()}
    b.install(vm)
}
