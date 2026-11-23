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
 * @file[zh-cn] renderers_cameras_perspectivecamera PerspectiveCamera 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.PerspectiveCamera 绑定为 Lua 类型并导出子类共用的
 * 成员安装函数
 * @explain[zh-cn] 绑定构造（fov/aspect/near/far）、属性（fov/aspect/zoom/focus/filmGauge/
 * filmOffset/view）与方法（setFocalLength/getFocalLength/getEffectiveFOV/getFilmWidth/
 * getFilmHeight/getViewBounds/getViewSize/setViewOffset/clearViewOffset/
 * updateProjectionMatrix）。view 为 Option<CameraView>，None 用 nil 表示；
 * getViewBounds 就地写入调用者传入的 minTarget/maxTarget，getViewSize 返回传入的 target。
 * Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D、Camera 与本文件的共享成员；
 * ArrayCamera 继承 PerspectiveCamera，同样复用 _prebindCamPerspectiveMembers。
 * 跳过成员及原因：
 * - copy：仅重写 Object3D 的 copy，未新增 Lua 名称，由 Object3D 绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_cameras_perspectivecamera  Lua binding of PerspectiveCamera
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.PerspectiveCamera and exports the shared subclass
 * member installer
 * @explain[en] Binds the constructor (fov/aspect/near/far), properties (fov/aspect/zoom/focus/
 * filmGauge/filmOffset/view) and methods (setFocalLength/getFocalLength/getEffectiveFOV/
 * getFilmWidth/getFilmHeight/getViewBounds/getViewSize/setViewOffset/clearViewOffset/
 * updateProjectionMatrix). view is Option<CameraView> with nil for None; getViewBounds writes
 * into the caller-provided minTarget/maxTarget and getViewSize returns the provided target.
 * Lua class tables have no inheritance, so this binding reuses the Object3D, Camera and shared
 * members from this file before b.install; ArrayCamera derives from PerspectiveCamera and reuses
 * _prebindCamPerspectiveMembers as well.
 * Skipped members and reasons:
 * - copy: only an override of Object3D.copy with no new Lua name, covered by the Object3D
 *   binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.cameras.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为绑定器安装 PerspectiveCamera 的成员（构造与父类成员除外）
 * @explain[zh-cn] Lua 类表没有继承，所有 PerspectiveCamera 子类（如 ArrayCamera）的绑定都必须在
 * b.install 之前调用本函数。所有回调按 PerspectiveCamera 强转后经虚函数分派。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the PerspectiveCamera members (except the constructor and parent members)
 * @explain[en] Lua class tables have no inheritance, so every PerspectiveCamera subclass binding
 * (e.g. ArrayCamera) must call this before b.install. Callbacks cast to PerspectiveCamera and rely
 * on virtual dispatch.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindCamPerspectiveMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 投影参数 =====
    b.property("fov", getter: Some({ref => LuaValue.of(ref.cast<PerspectiveCamera>().fov)}),
        setter: Some({ref, v => ref.cast<PerspectiveCamera>().fov = v.numberValue()}))
    b.property("aspect", getter: Some({ref => LuaValue.of(ref.cast<PerspectiveCamera>().aspect)}),
        setter: Some({ref, v => ref.cast<PerspectiveCamera>().aspect = v.numberValue()}))
    b.property("zoom", getter: Some({ref => LuaValue.of(ref.cast<PerspectiveCamera>().zoom)}),
        setter: Some({ref, v => ref.cast<PerspectiveCamera>().zoom = v.numberValue()}))
    b.property("focus", getter: Some({ref => LuaValue.of(ref.cast<PerspectiveCamera>().focus)}),
        setter: Some({ref, v => ref.cast<PerspectiveCamera>().focus = v.numberValue()}))
    b.property("filmGauge", getter: Some({ref => LuaValue.of(ref.cast<PerspectiveCamera>().filmGauge)}),
        setter: Some({ref, v => ref.cast<PerspectiveCamera>().filmGauge = v.numberValue()}))
    b.property("filmOffset", getter: Some({ref => LuaValue.of(ref.cast<PerspectiveCamera>().filmOffset)}),
        setter: Some({ref, v => ref.cast<PerspectiveCamera>().filmOffset = v.numberValue()}))
    // ===== 多视口裁剪 =====
    b.property("view", getter: Some({ref => _prebindCamViewToLua(ref.cast<PerspectiveCamera>().view)}), setter: Some({
        ref, v => ref.cast<PerspectiveCamera>().view = _prebindCamViewFromLua(v)
    }))
    // ===== 焦距 / 视场角 =====
    b.method("setFocalLength") {
        ref, args =>
            ref.cast<PerspectiveCamera>().setFocalLength(prebindNum(args, 0))
            []
    }
    b.method("getFocalLength") {
        ref, _ => [LuaValue.of(ref.cast<PerspectiveCamera>().getFocalLength())]
    }
    b.method("getEffectiveFOV") {
        ref, _ => [LuaValue.of(ref.cast<PerspectiveCamera>().getEffectiveFOV())]
    }
    b.method("getFilmWidth") {
        ref, _ => [LuaValue.of(ref.cast<PerspectiveCamera>().getFilmWidth())]
    }
    b.method("getFilmHeight") {
        ref, _ => [LuaValue.of(ref.cast<PerspectiveCamera>().getFilmHeight())]
    }
    // ===== 视图尺寸（就地写入 target，返回该对象） =====
    b.method("getViewBounds") {
        ref, args =>
            ref
                .cast<PerspectiveCamera>()
                .getViewBounds(prebindNum(args, 0), prebindAs<Vector2>(args, 1), prebindAs<Vector2>(args, 2))
            []
    }
    b.method("getViewSize") {
        ref, args =>
            ref.cast<PerspectiveCamera>().getViewSize(prebindNum(args, 0), prebindAs<Vector2>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    // ===== 视口偏移 / 投影矩阵 =====
    b.method("setViewOffset") {
        ref, args =>
            ref
                .cast<PerspectiveCamera>()
                .setViewOffset(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindNum(args, 5))
            []
    }
    b.method("clearViewOffset") {
        ref, _ =>
            ref.cast<PerspectiveCamera>().clearViewOffset()
            []
    }
    b.method("updateProjectionMatrix") {
        ref, _ =>
            ref.cast<PerspectiveCamera>().updateProjectionMatrix()
            []
    }
}

/**
 * @brief[zh-cn] 安装 PerspectiveCamera 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.PerspectiveCamera）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PerspectiveCamera
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.PerspectiveCamera)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPerspectiveCamera(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.PerspectiveCamera")
    // ===== 构造 =====
    b.constructor {
        args => PerspectiveCamera(fov: prebindNum(args, 0, default: 50.0), aspect: prebindNum(args, 1, default: 1.0),
            near: prebindNum(args, 2, default: 0.1), far: prebindNum(args, 3, default: 2000.0))
    }
    // ===== 继承成员：Object3D → Camera → PerspectiveCamera =====
    prebindInstallObject3DMembers(b, vm)
    _prebindCamCameraMembers(b, vm)
    _prebindCamPerspectiveMembers(b, vm)
    b.install(vm)
}
