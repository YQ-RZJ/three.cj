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
 * @file[zh-cn] renderers_cameras_stereocamera StereoCamera 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.StereoCamera 绑定为 Lua 类型
 * @explain[zh-cn] 绑定无参构造、属性（kind/aspect/eyeSep/cameraL/cameraR）与方法
 * update(camera)。cameraL/cameraR 为 PerspectiveCamera，经 prebindRegister 注册、setter 经
 * prebindAsValue 取回。StereoCamera 不继承 Object3D，自身即全部成员。无跳过成员；私有缓存
 * 字段与偏移矩阵不属于 public API，不绑定。
 *
 * @file[en] renderers_cameras_stereocamera  Lua binding of StereoCamera (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.StereoCamera as a Lua type
 * @explain[en] Binds the no-arg constructor, properties (kind/aspect/eyeSep/cameraL/cameraR) and
 * the update(camera) method. cameraL/cameraR are PerspectiveCamera values registered via
 * prebindRegister and fetched by setters via prebindAsValue. StereoCamera does not derive from
 * Object3D, so it owns all of its members. No members are skipped; the private cache fields and
 * offset matrices are not public API and are not bound.
 */
package three.script.prebind

import three.renderers.cameras.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 StereoCamera 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.StereoCamera）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of StereoCamera
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.StereoCamera)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installStereoCamera(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.StereoCamera")
    // ===== 构造 =====
    b.constructor {_ => StereoCamera()}
    // ===== 属性 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<StereoCamera>().kind)}),
        setter: Some({ref, v => ref.cast<StereoCamera>().kind = v.stringValue()}))
    b.property("aspect", getter: Some({ref => LuaValue.of(ref.cast<StereoCamera>().aspect)}),
        setter: Some({ref, v => ref.cast<StereoCamera>().aspect = v.numberValue()}))
    b.property("eyeSep", getter: Some({ref => LuaValue.of(ref.cast<StereoCamera>().eyeSep)}),
        setter: Some({ref, v => ref.cast<StereoCamera>().eyeSep = v.numberValue()}))
    b.property("cameraL", getter: Some({
        ref => prebindRegister(ref.cast<StereoCamera>().cameraL, "three.renderers.cameras.PerspectiveCamera")
    }), setter: Some({
        ref, v => ref.cast<StereoCamera>().cameraL = prebindAsValue<PerspectiveCamera>(v)
    }))
    b.property("cameraR", getter: Some({
        ref => prebindRegister(ref.cast<StereoCamera>().cameraR, "three.renderers.cameras.PerspectiveCamera")
    }), setter: Some({
        ref, v => ref.cast<StereoCamera>().cameraR = prebindAsValue<PerspectiveCamera>(v)
    }))
    // ===== 同步主相机 =====
    b.method("update") {
        ref, args =>
            ref.cast<StereoCamera>().update(prebindAs<PerspectiveCamera>(args, 0))
            []
    }
    b.install(vm)
}
