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
 * @file[zh-cn] renderers_cameras_orthographiccamera OrthographicCamera 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.OrthographicCamera 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（left/right/top/bottom/near/far）、属性（left/right/top/bottom/
 * zoom/view）与方法（setViewOffset/clearViewOffset/updateProjectionMatrix）。view 为
 * Option<CameraView>，None 用 nil 表示。Lua 类表没有继承，本类绑定在 b.install 之前依次复用
 * Object3D 与 Camera 的成员；OrthographicCamera 没有子类，成员直接在本文件登记。
 * 跳过成员及原因：
 * - copy：仅重写 Object3D 的 copy，未新增 Lua 名称，由 Object3D 绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_cameras_orthographiccamera  Lua binding of OrthographicCamera
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.OrthographicCamera as a Lua type
 * @explain[en] Binds the constructor (left/right/top/bottom/near/far), properties
 * (left/right/top/bottom/zoom/view) and methods (setViewOffset/clearViewOffset/
 * updateProjectionMatrix). view is Option<CameraView> with nil for None. Lua class tables have no
 * inheritance, so this binding reuses the Object3D and Camera members before b.install;
 * OrthographicCamera has no subclasses, so its own members are registered in this file.
 * Skipped members and reasons:
 * - copy: only an override of Object3D.copy with no new Lua name, covered by the Object3D
 *   binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.cameras.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 OrthographicCamera 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.OrthographicCamera）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of OrthographicCamera
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.OrthographicCamera)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installOrthographicCamera(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.OrthographicCamera")
    // ===== 构造 =====
    b.constructor {
        args => OrthographicCamera(left: prebindNum(args, 0, default: -1.0), right: prebindNum(args, 1, default: 1.0),
            top: prebindNum(args, 2, default: 1.0), bottom: prebindNum(args, 3, default: -1.0),
            near: prebindNum(args, 4, default: 0.1), far: prebindNum(args, 5, default: 2000.0))
    }
    // ===== 继承成员：Object3D → Camera =====
    prebindInstallObject3DMembers(b, vm)
    _prebindCamCameraMembers(b, vm)
    // ===== 视锥边界 =====
    b.property("left", getter: Some({ref => LuaValue.of(ref.cast<OrthographicCamera>().left)}),
        setter: Some({ref, v => ref.cast<OrthographicCamera>().left = v.numberValue()}))
    b.property("right", getter: Some({ref => LuaValue.of(ref.cast<OrthographicCamera>().right)}),
        setter: Some({ref, v => ref.cast<OrthographicCamera>().right = v.numberValue()}))
    b.property("top", getter: Some({ref => LuaValue.of(ref.cast<OrthographicCamera>().top)}),
        setter: Some({ref, v => ref.cast<OrthographicCamera>().top = v.numberValue()}))
    b.property("bottom", getter: Some({ref => LuaValue.of(ref.cast<OrthographicCamera>().bottom)}),
        setter: Some({ref, v => ref.cast<OrthographicCamera>().bottom = v.numberValue()}))
    b.property("zoom", getter: Some({ref => LuaValue.of(ref.cast<OrthographicCamera>().zoom)}),
        setter: Some({ref, v => ref.cast<OrthographicCamera>().zoom = v.numberValue()}))
    // ===== 多视口裁剪 =====
    b.property("view", getter: Some({ref => _prebindCamViewToLua(ref.cast<OrthographicCamera>().view)}),
        setter: Some({
            ref, v => ref.cast<OrthographicCamera>().view = _prebindCamViewFromLua(v)
        }))
    // ===== 视口偏移 / 投影矩阵 =====
    b.method("setViewOffset") {
        ref, args =>
            ref
                .cast<OrthographicCamera>()
                .setViewOffset(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindNum(args, 5))
            []
    }
    b.method("clearViewOffset") {
        ref, _ =>
            ref.cast<OrthographicCamera>().clearViewOffset()
            []
    }
    b.method("updateProjectionMatrix") {
        ref, _ =>
            ref.cast<OrthographicCamera>().updateProjectionMatrix()
            []
    }
    b.install(vm)
}
