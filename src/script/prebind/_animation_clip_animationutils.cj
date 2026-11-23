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
 * @file[zh-cn] animation_clip_animationutils 动画工具 AnimationUtils 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.clip.AnimationUtils 绑定为 Lua 命名空间
 * three.animation.clip.AnimationUtils（纯静态，无 new）
 * @explain[zh-cn] 绑定 getKeyframeOrder（Lua 表 → 索引数组）、sortedArray、
 * subclip（返回新 AnimationClip）、makeClipAdditive（就地修改并返回目标剪辑）。
 * 跳过 flattenJSON：参数为 Array<HashMap<String, Any>> 与 ArrayList<Float64> 输出，
 * 当前无「Lua 表 ↔ HashMap」通道。
 *
 * @file[en] animation_clip_animationutils  Lua binding of the animation utilities AnimationUtils
 * (three.script.prebind)
 * @brief[en] Binds three.animation.clip.AnimationUtils as the Lua namespace
 * three.animation.clip.AnimationUtils (pure static, no `new`)
 * @explain[en] Binds getKeyframeOrder (Lua table → index array), sortedArray, subclip
 * (returns a new AnimationClip) and makeClipAdditive (modifies in place and returns the
 * target clip). flattenJSON is skipped: it takes Array<HashMap<String, Any>> and outputs
 * ArrayList<Float64>, and there is no "Lua table ↔ HashMap" channel yet.
 */
package three.script.prebind

import three.animation.clip.AnimationUtils
import three.animation.clip.AnimationClip
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取 Lua 参数为 Int64 数组（元素经 intValue 转换）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 整数数组（非数组/表返回空）
 *
 * @brief[en] Reads a Lua argument as an Int64 array (elements via intValue)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The integer array (empty when not an array/table)
 */
private func _prebindIntArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Int64> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<Int64>(n, {_ => 0})
    for (i in 0..n) {
        out[i] = elems[i].intValue()
    }
    return out
}

/**
 * @brief[zh-cn] 安装 AnimationUtils 的 Lua 绑定（纯静态类，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.animation.clip.AnimationUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationUtils (a pure static class; no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.animation.clip.AnimationUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.clip.AnimationUtils")
    // ===== 关键帧排序 =====
    b.staticMethod("getKeyframeOrder") {
        args => [LuaValue.of(AnimationUtils.getKeyframeOrder(prebindFloatArray(vm, args, 0)))]
    }
    b.staticMethod("sortedArray") {
        args => [LuaValue.of(
            AnimationUtils.sortedArray(prebindFloatArray(vm, args, 0), prebindInt(args, 1, default: 1),
                _prebindIntArray(vm, args, 2)))]
    }
    // ===== 剪辑派生 =====
    b.staticMethod("subclip") {
        args => [prebindRegister(
            AnimationUtils.subclip(prebindAs<AnimationClip>(args, 0), prebindStr(args, 1), prebindInt(args, 2),
                prebindInt(args, 3), fps: prebindNum(args, 4, default: 30.0)), "three.animation.clip.AnimationClip")]
    }
    b.staticMethod("makeClipAdditive") {
        args =>
            let target = prebindAs<AnimationClip>(args, 0)
            // 可选 referenceClip：缺省或 nil 时沿用目标剪辑自身（与源码默认参数一致）
            let referenceClip = if (args.size > 2 && !args[2].isNil) {
                prebindAs<AnimationClip>(args, 2)
            } else {
                target
            }
            AnimationUtils.makeClipAdditive(target, referenceFrame: prebindInt(args, 1), referenceClip: referenceClip,
                fps: prebindNum(args, 3, default: 30.0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.install(vm)
}
