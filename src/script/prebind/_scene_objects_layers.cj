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
 * @file[zh-cn] scene_objects_layers Layers 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.objects.Layers 绑定为 Lua 类型 three.scene.objects.Layers
 * @explain[zh-cn] 绑定构造、mask 属性（UInt32 位掩码，Lua 侧以 Float64 呈现）与
 * set/enable/enableAll/toggle/disable/disableAll/test/isEnabled 全部 public 方法。
 * 图层编号参数按 UInt32 收窄（取低 32 位）；无跳过成员。
 *
 * @file[en] scene_objects_layers  Lua binding of Layers (three.script.prebind)
 * @brief[en] Binds three.scene.objects.Layers as the Lua type three.scene.objects.Layers
 * @explain[en] Binds the constructor, the mask property (UInt32 bitmask, presented as Float64
 * on the Lua side) and every public method: set/enable/enableAll/toggle/disable/disableAll/
 * test/isEnabled. Layer indices are narrowed to UInt32 (low 32 bits). No members are skipped.
 */
package three.script.prebind

import three.scene.objects.*
import three.script.vm.*
import three.script.binding.*

/// 读取图层编号参数（UInt32，取低 32 位）
private func _prebindLayer(args: Array<LuaValue>, idx: Int64): UInt32 {
    return UInt32(prebindInt(args, idx) & 0xFFFFFFFF)
}

/**
 * @brief[zh-cn] 安装 Layers 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.objects.Layers）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Layers
 * @param[en] vm The target virtual machine (class table installed at three.scene.objects.Layers)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLayers(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.objects.Layers")
    // ===== 构造 =====
    b.constructor {_ => Layers()}
    // ===== 位掩码 =====
    b.property("mask", getter: Some({ref => LuaValue.of(Float64(ref.cast<Layers>().mask))}),
        setter: Some({ref, v => ref.cast<Layers>().mask = UInt32(v.intValue() & 0xFFFFFFFF)}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Layers>().set(_prebindLayer(args, 0))
            []
    }
    b.method("enable") {
        ref, args =>
            ref.cast<Layers>().enable(_prebindLayer(args, 0))
            []
    }
    b.method("enableAll") {
        ref, _ =>
            ref.cast<Layers>().enableAll()
            []
    }
    b.method("toggle") {
        ref, args =>
            ref.cast<Layers>().toggle(_prebindLayer(args, 0))
            []
    }
    b.method("disable") {
        ref, args =>
            ref.cast<Layers>().disable(_prebindLayer(args, 0))
            []
    }
    b.method("disableAll") {
        ref, _ =>
            ref.cast<Layers>().disableAll()
            []
    }
    // ===== 测试 =====
    b.method("test") {
        ref, args => [LuaValue.of(ref.cast<Layers>().test(prebindAs<Layers>(args, 0)))]
    }
    b.method("isEnabled") {
        ref, args => [LuaValue.of(ref.cast<Layers>().isEnabled(_prebindLayer(args, 0)))]
    }
    b.install(vm)
}
