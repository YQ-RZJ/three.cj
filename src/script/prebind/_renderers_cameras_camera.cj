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
 * @file[zh-cn] renderers_cameras_camera Camera 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.Camera 绑定为 Lua 类型并导出子类共用的成员安装函数
 * @explain[zh-cn] 绑定 Camera 的可映射成员：视矩阵逆（matrixWorldInverse）、投影矩阵及其逆
 * （projectionMatrix / projectionMatrixInverse）、近远裁剪面（near / far）、坐标系
 * （coordinateSystem）与反向深度开关（reversedDepth）。矩阵属性经 prebindRegister 注册、
 * setter 经 prebindAsValue 取回。Lua 类表没有继承，所有 Camera 子类的绑定都必须在
 * b.install 之前调用 prebindInstallObject3DMembers 与本文件的 _prebindCamCameraMembers。
 * 跳过成员及原因：
 * - getWorldDirection / updateMatrixWorld / updateWorldMatrix / copy / clone：Camera 仅重写
 *   Object3D 的实现，未新增 Lua 名称，重复登记会让同名方法的分发不确定，统一由 Object3D
 *   绑定经虚函数分派覆盖；
 * - ICamera 接口：接口不是可构造类，不生成 Lua 类表。
 *
 * @file[en] renderers_cameras_camera  Lua binding of Camera (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.Camera and exports the shared subclass member installer
 * @explain[en] Binds the mappable members of Camera: inverse view matrix (matrixWorldInverse),
 * projection matrix and its inverse (projectionMatrix / projectionMatrixInverse), near/far
 * clipping planes, coordinate system (coordinateSystem) and the reversed-depth switch
 * (reversedDepth). Matrix properties are registered via prebindRegister and fetched by setters
 * via prebindAsValue. Lua class tables have no inheritance, so every Camera subclass binding must
 * call prebindInstallObject3DMembers and _prebindCamCameraMembers from this file before b.install.
 * Skipped members and reasons:
 * - getWorldDirection / updateMatrixWorld / updateWorldMatrix / copy / clone: Camera only
 *   overrides the Object3D implementations and adds no new Lua name; duplicate registration would
 *   make dispatch nondeterministic, so the Object3D bindings cover them via virtual dispatch;
 * - the ICamera interface: an interface is not a constructible class, so no Lua class table is
 *   generated.
 */
package three.script.prebind

import three.renderers.cameras.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将可选相机视口配置转为 Lua 值（Some 注册对象，None 返回 nil）
 * @param[zh-cn] view 可选相机视口配置
 * @return[zh-cn] Lua 值
 *
 * @brief[en] Converts an optional camera view into a Lua value (Some registers, None is nil)
 * @param[en] view The optional camera view
 * @return[en] The Lua value
 */
internal func _prebindCamViewToLua(view: Option<CameraView>): LuaValue {
    match (view) {
        case Some(v) => prebindRegister(v, "three.renderers.cameras.CameraView")
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 将 Lua 值转为可选相机视口配置（nil/非对象返回 None）
 * @param[zh-cn] v Lua 值
 * @return[zh-cn] 可选相机视口配置
 *
 * @brief[en] Converts a Lua value into an optional camera view (nil/non-object yields None)
 * @param[en] v The Lua value
 * @return[en] The optional camera view
 */
internal func _prebindCamViewFromLua(v: LuaValue): Option<CameraView> {
    if (v.isNil || !v.isObject) {
        return None
    }
    return Some(prebindAsValue<CameraView>(v))
}

/**
 * @brief[zh-cn] 为绑定器安装 Camera 的成员（构造与 Object3D 成员除外）
 * @explain[zh-cn] Lua 类表没有继承，所有 Camera 子类的绑定都必须在 b.install 之前调用本函数，
 * 否则子类实例只能看到自己新增的成员。所有回调按 Camera 强转后经虚函数分派。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Camera members (except the constructor and Object3D members) on a binder
 * @explain[en] Lua class tables have no inheritance, so every Camera subclass binding must call this
 * before b.install; otherwise instances only expose their own extra members. Callbacks cast to
 * Camera and rely on virtual dispatch.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindCamCameraMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 矩阵 =====
    b.property("matrixWorldInverse", getter: Some({
        ref => prebindRegister(ref.cast<Camera>().matrixWorldInverse, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<Camera>().matrixWorldInverse = prebindAsValue<Matrix4>(v)
    }))
    b.property("projectionMatrix", getter: Some({
        ref => prebindRegister(ref.cast<Camera>().projectionMatrix, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<Camera>().projectionMatrix = prebindAsValue<Matrix4>(v)
    }))
    b.property("projectionMatrixInverse", getter: Some({
        ref => prebindRegister(ref.cast<Camera>().projectionMatrixInverse, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<Camera>().projectionMatrixInverse = prebindAsValue<Matrix4>(v)
    }))
    // ===== 裁剪面 / 坐标系 =====
    b.property("near", getter: Some({ref => LuaValue.of(ref.cast<Camera>().near)}),
        setter: Some({ref, v => ref.cast<Camera>().near = v.numberValue()}))
    b.property("far", getter: Some({ref => LuaValue.of(ref.cast<Camera>().far)}),
        setter: Some({ref, v => ref.cast<Camera>().far = v.numberValue()}))
    b.property("coordinateSystem", getter: Some({ref => LuaValue.of(ref.cast<Camera>().coordinateSystem)}),
        setter: Some({ref, v => ref.cast<Camera>().coordinateSystem = v.intValue()}))
    b.property("reversedDepth", getter: Some({ref => LuaValue.of(ref.cast<Camera>().reversedDepth)}),
        setter: Some({ref, v => ref.cast<Camera>().reversedDepth = v.boolValue()}))
}

/**
 * @brief[zh-cn] 安装 Camera 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.Camera）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Camera
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.Camera)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCamera(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.Camera")
    // ===== 构造 =====
    b.constructor {
        args => Camera(near: prebindNum(args, 0, default: 0.1), far: prebindNum(args, 1, default: 2000.0))
    }
    // ===== Object3D 继承成员 =====
    prebindInstallObject3DMembers(b, vm)
    // ===== Camera 自有成员 =====
    _prebindCamCameraMembers(b, vm)
    b.install(vm)
}
