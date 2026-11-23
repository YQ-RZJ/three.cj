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
 * @file[zh-cn] renderers_cameras_arraycamera ArrayCamera 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.ArrayCamera 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 cameras 子相机数组）、属性（isMultiViewCamera / cameras）与方法
 * （getCameraCount / getCameraProjectionElements / getCameraMatrixWorldInverseElements）。
 * cameras 以 PerspectiveCamera 对象数组读写；两个 *Elements 方法返回 16 元素 Float64 数组
 * （列主序）。ArrayCamera 继承 PerspectiveCamera，Lua 类表没有继承，因此在 b.install 之前依次
 * 复用 Object3D、Camera 与 _prebindCamPerspectiveMembers 的成员。
 * 跳过成员及原因：
 * - IArrayCameraSource 接口：接口不是可构造类，不生成 Lua 类表（其方法已在类上绑定）。
 *
 * @file[en] renderers_cameras_arraycamera  Lua binding of ArrayCamera (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.ArrayCamera as a Lua type
 * @explain[en] Binds the constructor (optional cameras array), properties (isMultiViewCamera /
 * cameras) and methods (getCameraCount / getCameraProjectionElements /
 * getCameraMatrixWorldInverseElements). cameras is read/written as an array of PerspectiveCamera
 * objects; the two *Elements methods return 16-element Float64 arrays (column-major). ArrayCamera
 * derives from PerspectiveCamera; since Lua class tables have no inheritance, this binding reuses
 * the Object3D, Camera and _prebindCamPerspectiveMembers members before b.install.
 * Skipped members and reasons:
 * - the IArrayCameraSource interface: an interface is not a constructible class, so no Lua class
 *   table is generated (its methods are bound on the class itself).
 */
package three.script.prebind

import std.collection.*
import three.renderers.cameras.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将子相机列表转为 Lua 数组（元素注册为 PerspectiveCamera）
 * @param[zh-cn] items 子相机列表
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a sub-camera list into a Lua array (elements registered as PerspectiveCamera)
 * @param[en] items The sub-camera list
 * @return[en] The Lua array value
 */
internal func _prebindCamPerspectiveListToLua(items: ArrayList<PerspectiveCamera>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.renderers.cameras.PerspectiveCamera")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 ArrayCamera 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.ArrayCamera）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ArrayCamera
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.ArrayCamera)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installArrayCamera(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.ArrayCamera")
    // ===== 构造：可选子相机数组 =====
    b.constructor {
        args => ArrayCamera(cameras: prebindObjList<PerspectiveCamera>(vm, args, 0))
    }
    // ===== 继承成员：Object3D → Camera → PerspectiveCamera =====
    prebindInstallObject3DMembers(b, vm)
    _prebindCamCameraMembers(b, vm)
    _prebindCamPerspectiveMembers(b, vm)
    // ===== 数组相机自有成员 =====
    b.property("isMultiViewCamera", getter: Some({ref => LuaValue.of(ref.cast<ArrayCamera>().isMultiViewCamera)}),
        setter: Some({ref, v => ref.cast<ArrayCamera>().isMultiViewCamera = v.boolValue()}))
    b.property("cameras", getter: Some({
        ref => _prebindCamPerspectiveListToLua(ref.cast<ArrayCamera>().cameras)
    }), setter: Some({
        ref, v => ref.cast<ArrayCamera>().cameras = prebindObjList<PerspectiveCamera>(vm, [v], 0)
    }))
    b.method("getCameraCount") {
        ref, _ => [LuaValue.of(ref.cast<ArrayCamera>().getCameraCount())]
    }
    b.method("getCameraProjectionElements") {
        ref, args => [LuaValue.of(ref.cast<ArrayCamera>().getCameraProjectionElements(prebindInt(args, 0)))]
    }
    b.method("getCameraMatrixWorldInverseElements") {
        ref, args => [LuaValue.of(ref.cast<ArrayCamera>().getCameraMatrixWorldInverseElements(prebindInt(args, 0)))]
    }
    b.install(vm)
}
