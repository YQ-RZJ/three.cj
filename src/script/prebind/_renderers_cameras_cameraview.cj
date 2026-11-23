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
 * @file[zh-cn] renderers_cameras_cameraview CameraView 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.CameraView 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（enabled/fullWidth/fullHeight/offsetX/offsetY/width/height，全部
 * 位置参数，缺省值与无参构造一致）、属性（同名 7 个字段，均可读写）与 clone（返回注册的新
 * CameraView）。跳过成员及原因：
 * - toHashMap()：返回 HashMap<String, Any>，任意值无法安全映射为 Lua 值。
 *
 * @file[en] renderers_cameras_cameraview  Lua binding of CameraView (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.CameraView as a Lua type
 * @explain[en] Binds the constructor (enabled/fullWidth/fullHeight/offsetX/offsetY/width/height,
 * all positional, with the same defaults as the no-arg constructor), the seven matching
 * read-write properties, and clone (returns a newly registered CameraView).
 * Skipped members and reasons:
 * - toHashMap(): returns HashMap<String, Any>, whose arbitrary values cannot be mapped safely.
 */
package three.script.prebind

import three.renderers.cameras.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CameraView 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.CameraView）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CameraView
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.CameraView)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCameraView(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.CameraView")
    // ===== 构造：缺省值手工传入以保留无参语义 =====
    b.constructor {
        args => CameraView(prebindBool(args, 0), prebindNum(args, 1, default: 1.0), prebindNum(args, 2, default: 1.0),
            prebindNum(args, 3, default: 0.0), prebindNum(args, 4, default: 0.0), prebindNum(args, 5, default: 1.0),
            prebindNum(args, 6, default: 1.0))
    }
    // ===== 属性 =====
    b.property("enabled", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().enabled)}),
        setter: Some({ref, v => ref.cast<CameraView>().enabled = v.boolValue()}))
    b.property("fullWidth", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().fullWidth)}),
        setter: Some({ref, v => ref.cast<CameraView>().fullWidth = v.numberValue()}))
    b.property("fullHeight", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().fullHeight)}),
        setter: Some({ref, v => ref.cast<CameraView>().fullHeight = v.numberValue()}))
    b.property("offsetX", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().offsetX)}),
        setter: Some({ref, v => ref.cast<CameraView>().offsetX = v.numberValue()}))
    b.property("offsetY", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().offsetY)}),
        setter: Some({ref, v => ref.cast<CameraView>().offsetY = v.numberValue()}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().width)}),
        setter: Some({ref, v => ref.cast<CameraView>().width = v.numberValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<CameraView>().height)}),
        setter: Some({ref, v => ref.cast<CameraView>().height = v.numberValue()}))
    // ===== 深拷贝 =====
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<CameraView>().clone(), "three.renderers.cameras.CameraView")]
    }
    b.install(vm)
}
