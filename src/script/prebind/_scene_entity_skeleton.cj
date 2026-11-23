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
 * @file[zh-cn] scene_entity_skeleton Skeleton 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.Skeleton 绑定为 Lua 类型 three.scene.entity.Skeleton
 * @explain[zh-cn] 绑定构造（可选 bones/boneInverses）、属性（bones/boneInverses/
 * boneMatrices/boneTexture/kind/uuid）、getUuid、calculateInverses、pose、update、
 * computeBoneTexture、clone、getBoneByName、release 与 syncFromSkeletonData。
 * Option 字段（boneMatrices/boneTexture）Some 注册、None 返回 nil；ArrayList 走 Lua 数组。
 * 跳过：fromJSON（参数为 HashMap<String, Any> 与 HashMap<String, Bone>，绑定层无 Any 映射通道）。
 *
 * @file[en] scene_entity_skeleton  Lua binding of Skeleton (three.script.prebind)
 * @brief[en] Binds three.scene.entity.Skeleton as the Lua type three.scene.entity.Skeleton
 * @explain[en] Binds construction (optional bones/boneInverses), props (bones/boneInverses/
 * boneMatrices/boneTexture/kind/uuid), getUuid, calculateInverses, pose, update,
 * computeBoneTexture, clone, getBoneByName, release and syncFromSkeletonData.
 * Option fields (boneMatrices/boneTexture) register when Some and return nil when None;
 * ArrayList fields use Lua arrays. Skipped: fromJSON (takes HashMap<String, Any> and
 * HashMap<String, Bone>; the binding layer has no Any mapping channel).
 */
package three.script.prebind

import three.scene.entity.Skeleton
import three.scene.entity.Bone
import three.core.math.Matrix4
import three.renderers.textures.DataTexture
import three.animation.skeletal.SkeletonData
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 将 Bone 列表转为 Lua 对象数组
 * @param[zh-cn] items 骨节点列表
 * @return[zh-cn] Lua 数组值（元素注册为 three.scene.entity.Bone）
 *
 * @brief[en] Converts the Bone list into a Lua object array
 * @param[en] items The bone list
 * @return[en] Lua array value (elements registered as three.scene.entity.Bone)
 */
private func _prebindSkeletonBonesToLua(items: ArrayList<Bone>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.entity.Bone")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将 Matrix4 列表转为 Lua 对象数组
 * @param[zh-cn] items 矩阵列表
 * @return[zh-cn] Lua 数组值（元素注册为 three.core.math.Matrix4）
 *
 * @brief[en] Converts the Matrix4 list into a Lua object array
 * @param[en] items The matrix list
 * @return[en] Lua array value (elements registered as three.core.math.Matrix4)
 */
private func _prebindSkeletonMatricesToLua(items: ArrayList<Matrix4>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.core.math.Matrix4")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 Skeleton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.Skeleton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Skeleton
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.Skeleton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkeleton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.Skeleton")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Skeleton(bones: prebindObjList<Bone>(vm, args, 0), boneInverses: prebindObjList<Matrix4>(vm, args, 1))
        } else if (args.size >= 1) {
            Skeleton(bones: prebindObjList<Bone>(vm, args, 0))
        } else {
            Skeleton()
        }
    }
    // ===== 属性 =====
    b.property("bones", getter: Some({
        ref => _prebindSkeletonBonesToLua(ref.cast<Skeleton>().bones)
    }), setter: Some({
        ref, v => ref.cast<Skeleton>().bones = prebindObjList<Bone>(vm, [v], 0)
    }))
    b.property("boneInverses", getter: Some({
        ref => _prebindSkeletonMatricesToLua(ref.cast<Skeleton>().boneInverses)
    }), setter: Some({
        ref, v => ref.cast<Skeleton>().boneInverses = prebindObjList<Matrix4>(vm, [v], 0)
    }))
    b.property("boneMatrices", getter: Some({
        ref => match (ref.cast<Skeleton>().boneMatrices) {
            case Some(arr) => LuaValue.of(arr)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil) {
            ref.cast<Skeleton>().boneMatrices = None
        } else {
            ref.cast<Skeleton>().boneMatrices = Some(prebindFloatArray(vm, [v], 0))
        }
    }))
    b.property("boneTexture", getter: Some({
        ref => match (ref.cast<Skeleton>().boneTexture) {
            case Some(tex) => prebindRegister(tex, "three.renderers.textures.DataTexture")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Skeleton>().boneTexture = Some(prebindAsValue<DataTexture>(v))
        } else {
            ref.cast<Skeleton>().boneTexture = None
        }
    }))
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<Skeleton>().kind)}),
        setter: Some({ref, v => ref.cast<Skeleton>().kind = v.stringValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<Skeleton>().uuid)}),
        setter: Some({ref, v => ref.cast<Skeleton>().uuid = v.stringValue()}))
    // ===== 查询 =====
    b.method("getUuid") {
        ref, _ => [LuaValue.of(ref.cast<Skeleton>().getUuid())]
    }
    // ===== 逆矩阵/姿势/更新 =====
    b.method("calculateInverses") {
        ref, _ =>
            try {
                ref.cast<Skeleton>().calculateInverses()
            } catch (_) {
                ()
            }
            []
    }
    b.method("pose") {
        ref, _ =>
            try {
                ref.cast<Skeleton>().pose()
            } catch (_) {
                ()
            }
            []
    }
    b.method("update") {
        ref, _ =>
            try {
                ref.cast<Skeleton>().update()
            } catch (_) {
                ()
            }
            []
    }
    b.method("computeBoneTexture") {
        ref, _ =>
            try {
                ref.cast<Skeleton>().computeBoneTexture()
            } catch (_) {
                ()
            }
            []
    }
    // ===== 复制/查找 =====
    b.method("clone") {
        ref, _ =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<Skeleton>().clone(), "three.scene.entity.Skeleton")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.method("getBoneByName") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                match (ref.cast<Skeleton>().getBoneByName(prebindStr(args, 0))) {
                    case Some(bone) => out = prebindRegister(bone, "three.scene.entity.Bone")
                    case None => out = LuaValue.Nil
                }
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 释放 =====
    b.method("release") {
        ref, _ =>
            var out = LuaValue.of(false)
            try {
                out = LuaValue.of(ref.cast<Skeleton>().release())
            } catch (_) {
                out = LuaValue.of(false)
            }
            [out]
    }
    // ===== 从 SkeletonData 同步 =====
    b.method("syncFromSkeletonData") {
        ref, args =>
            try {
                ref.cast<Skeleton>().syncFromSkeletonData(prebindAs<SkeletonData>(args, 0))
            } catch (_) {
                ()
            }
            []
    }
    b.install(vm)
}
