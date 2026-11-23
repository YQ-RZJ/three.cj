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
 * otherwise be required by Sections 4(a), 4(b), 4(d) of the License.
 *
 * @file[zh-cn] animation_skeletal_skeleton 运行时骨骼数据 SkeletonData 与骨骼工具
 * SkeletonUtils 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.skeletal.SkeletonData 与 SkeletonUtils 绑定为 Lua 类型
 * @explain[zh-cn] SkeletonData 只绑定无参构造与只读查询（numJoints / numSoaJoints /
 * jointParent / jointName / findJointIndex）；全参构造依赖 SoaTransform 数组（未绑定）、
 * jointRestPoses 返回 Array<SoaTransform>，故均跳过。SkeletonUtils 全部为静态方法，
 * 参数为 SkeletonData，返回整数 / 整数数组 / 字符串，走整数数组通道。
 *
 * @file[en] animation_skeletal_skeleton  Lua bindings of the runtime skeleton data SkeletonData and
 * the skeleton utilities SkeletonUtils (three.script.prebind)
 * @brief[en] Binds three.animation.skeletal.SkeletonData and SkeletonUtils as Lua types
 * @explain[en] SkeletonData binds only the parameterless constructor and read-only queries
 * (numJoints / numSoaJoints / jointParent / jointName / findJointIndex); the full constructor
 * needs SoaTransform arrays (unbound) and jointRestPoses returns Array<SoaTransform>, so both
 * are skipped. SkeletonUtils is entirely static, takes a SkeletonData and returns integers /
 * integer arrays / strings through the integer-array channel.
 */
package three.script.prebind

import three.animation.skeletal.SkeletonData
import three.animation.skeletal.SkeletonUtils
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 把整数容器转为 Lua 数值数组
 * @param[zh-cn] items 整数序列
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts an integer container into a Lua number array
 * @param[en] items The integer sequence
 * @return[en] The Lua array value
 */
private func _prebindIntsToLua(items: ArrayList<Int64>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(items[i])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 把整数数组转为 Lua 数值数组
 * @param[zh-cn] items 整数数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts an integer array into a Lua number array
 * @param[en] items The integer array
 * @return[en] The Lua array value
 */
private func _prebindIntArrToLua(items: Array<Int64>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(items[i])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 把 Int 容器复制为 Int64 容器（供 Lua 数组输出）
 * @param[zh-cn] items Int 容器
 * @return[zh-cn] Int64 容器
 *
 * @brief[en] Copies an Int container into an Int64 container (for Lua array output)
 * @param[en] items The Int container
 * @return[en] The Int64 container
 */
private func _prebindIntsToI64(items: ArrayList<Int>): ArrayList<Int64> {
    let out = ArrayList<Int64>()
    for (v in items) {
        out.add(Int64(v))
    }
    return out
}

/**
 * @brief[zh-cn] 安装 SkeletonData 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.SkeletonData）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SkeletonData
 * @param[en] vm The target virtual machine (class table installed at three.animation.skeletal.SkeletonData)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkeletonData(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.SkeletonData")
    // ===== 构造（仅无参；全参构造依赖 SoaTransform 数组，未绑定） =====
    b.constructor {_ => SkeletonData()}
    b.staticMethod("MAX_JOINTS") {_ => [LuaValue.of(Int64(SkeletonData.MAX_JOINTS))]}
    b.staticMethod("MAX_SOA_JOINTS") {_ => [LuaValue.of(Int64(SkeletonData.MAX_SOA_JOINTS))]}
    b.staticMethod("NO_PARENT") {_ => [LuaValue.of(Int64(SkeletonData.NO_PARENT))]}
    // ===== 查询 =====
    b.method("numJoints") {
        ref, _ => [LuaValue.of(Int64(ref.cast<SkeletonData>().numJoints()))]
    }
    b.method("numSoaJoints") {
        ref, _ => [LuaValue.of(Int64(ref.cast<SkeletonData>().numSoaJoints()))]
    }
    b.method("jointParent") {
        ref, args => [LuaValue.of(Int64(ref.cast<SkeletonData>().jointParent(Int64(prebindInt(args, 0)))))]
    }
    b.method("jointName") {
        ref, args => [LuaValue.of(ref.cast<SkeletonData>().jointName(Int64(prebindInt(args, 0))))]
    }
    b.method("findJointIndex") {
        ref, args => [LuaValue.of(Int64(ref.cast<SkeletonData>().findJointIndex(prebindStr(args, 0))))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 SkeletonUtils 的 Lua 绑定（纯静态类，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.animation.skeletal.SkeletonUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SkeletonUtils (a pure static class; no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.animation.skeletal.SkeletonUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkeletonUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.SkeletonUtils")
    b.staticMethod("findJointIndex") {
        args => [LuaValue.of(Int64(SkeletonUtils.findJointIndex(prebindAs<SkeletonData>(args, 0), prebindStr(args, 1))))]
    }
    b.staticMethod("getJointDepth") {
        args => [LuaValue.of(
            Int64(SkeletonUtils.getJointDepth(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)))))]
    }
    b.staticMethod("getChildren") {
        args => [_prebindIntsToLua(
            _prebindIntsToI64(SkeletonUtils.getChildren(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)))))]
    }
    b.staticMethod("getPathToJoint") {
        args =>
            let path = SkeletonUtils.getPathToJoint(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)))
            [_prebindIntArrToLua(Array<Int64>(path.size, {i => Int64(path[i])}))]
    }
    b.staticMethod("getSubtree") {
        args =>
            let subtree = SkeletonUtils.getSubtree(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)))
            [_prebindIntArrToLua(Array<Int64>(subtree.size, {i => Int64(subtree[i])}))]
    }
    b.staticMethod("getRootJoints") {
        args => [_prebindIntsToLua(_prebindIntsToI64(SkeletonUtils.getRootJoints(prebindAs<SkeletonData>(args, 0))))]
    }
    b.staticMethod("getAncestors") {
        args => [_prebindIntsToLua(
            _prebindIntsToI64(SkeletonUtils.getAncestors(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)))))]
    }
    b.staticMethod("isAncestor") {
        args => [LuaValue.of(
            SkeletonUtils.isAncestor(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)),
                Int64(prebindInt(args, 2))))]
    }
    b.staticMethod("getLowestCommonAncestor") {
        args => [LuaValue.of(
            Int64(SkeletonUtils.getLowestCommonAncestor(prebindAs<SkeletonData>(args, 0), Int64(prebindInt(args, 1)),
                Int64(prebindInt(args, 2)))))]
    }
    b.staticMethod("getStats") {
        args => [LuaValue.of(SkeletonUtils.getStats(prebindAs<SkeletonData>(args, 0)))]
    }
    b.install(vm)
}
