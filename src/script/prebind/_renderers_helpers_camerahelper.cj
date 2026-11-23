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
 * @file[zh-cn] renderers_helpers_camerahelper CameraHelper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.CameraHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 camera：首参为 Camera 对象时走带参构造，缺省走无参构造）、
 * 属性 camera（Camera）、方法 setColors（视锥/锥体/上方向/目标/十字五色，返回自身）与 update，
 * 以及继承自 LineSegments/Line/Object3D 的全部成员和 releasable / release。Lua 类表没有继承，
 * 本类绑定在 b.install 之前依次复用 Object3D、LineSegments（含 Line）与 IReleasable 成员。
 * 跳过成员：pointMap（HashMap<String, ArrayList<Int64>>，绑定层无映射通道）。
 *
 * @file[en] renderers_helpers_camerahelper  Lua binding of CameraHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.CameraHelper as a Lua type
 * @explain[en] Binds the constructor (optional camera: a Camera first argument selects the
 * parameterized overload, otherwise the no-arg one), the camera property, setColors (frustum /
 * cone / up / target / cross colors, returns self) and update, plus every inherited
 * LineSegments/Line/Object3D member and releasable / release. Lua class tables have no inheritance,
 * so the Object3D, LineSegments (including Line) and IReleasable members are reused before
 * b.install. Skipped: pointMap (HashMap<String, ArrayList<Int64>>, no binding channel).
 */
package three.script.prebind

import three.renderers.helpers.*
import three.renderers.cameras.*
import three.scene.objects.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CameraHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.CameraHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CameraHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.CameraHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCameraHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.CameraHelper")
    // ===== 构造：可选 camera（缺省走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            CameraHelper(prebindAs<Camera>(args, 0))
        } else {
            CameraHelper()
        }
    }
    // ===== 继承成员：Object3D → Line → LineSegments → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineSegmentsMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 相机视锥自有成员 =====
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<CameraHelper>().camera, "three.renderers.cameras.Camera")
    }), setter: Some({
        ref, v => ref.cast<CameraHelper>().camera = prebindAsValue<Camera>(v)
    }))
    b.method("setColors") {
        ref, args =>
            ref
                .cast<CameraHelper>()
                .setColors(_prebindHlpColorArg(args, 0, default: Color(0xffaa00)),
                    _prebindHlpColorArg(args, 1, default: Color(0xff0000)),
                    _prebindHlpColorArg(args, 2, default: Color(0x00aaff)),
                    _prebindHlpColorArg(args, 3, default: Color(0xffffff)),
                    _prebindHlpColorArg(args, 4, default: Color(0x333333)))
            [LuaValue.Object(ref.id)]
    }
    b.method("update") {
        ref, _ =>
            ref.cast<CameraHelper>().update()
            []
    }
    b.install(vm)
}
