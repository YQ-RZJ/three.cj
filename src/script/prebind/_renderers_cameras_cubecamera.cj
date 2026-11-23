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
 * @file[zh-cn] renderers_cameras_cubecamera CubeCamera 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.cameras.CubeCamera 绑定为 Lua 类型
 * @explain[zh-cn] 绑定无参构造、属性（coordinateSystem 以 nil 表示 None / activeMipmapLevel）
 * 与方法 updateCoordinateSystem。CubeCamera 继承 Object3D（非 PerspectiveCamera），Lua 类表
 * 没有继承，因此在 b.install 之前复用 Object3D 的全部成员；6 个子相机通过 children 访问。
 * 跳过成员及原因：
 * - renderTarget（?IRenderTarget）：接口实例无 Lua 映射通道；
 * - init(near, far, renderTarget: ?IRenderTarget)：第三个参数为接口实例，无法从 Lua 构造，
 *   仅暴露无参构造（near/far 为默认 0.1/2000）；
 * - update(renderer: IRenderer, scene: IScene)：两个参数均为接口实例，无 Lua 映射通道。
 *
 * @file[en] renderers_cameras_cubecamera  Lua binding of CubeCamera (three.script.prebind)
 * @brief[en] Binds three.renderers.cameras.CubeCamera as a Lua type
 * @explain[en] Binds the no-arg constructor, properties (coordinateSystem with nil for None /
 * activeMipmapLevel) and the updateCoordinateSystem method. CubeCamera derives from Object3D (not
 * PerspectiveCamera); since Lua class tables have no inheritance, every Object3D member is reused
 * before b.install; the six sub-cameras are reachable through children.
 * Skipped members and reasons:
 * - renderTarget (?IRenderTarget): interface instances have no Lua mapping channel;
 * - init(near, far, renderTarget: ?IRenderTarget): the third parameter is an interface instance
 *   that cannot be constructed from Lua, so only the no-arg constructor is exposed (near/far
 *   default to 0.1/2000);
 * - update(renderer: IRenderer, scene: IScene): both parameters are interface instances with no
 *   Lua mapping channel.
 */
package three.script.prebind

import three.renderers.cameras.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CubeCamera 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.cameras.CubeCamera）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CubeCamera
 * @param[en] vm The target virtual machine (class table at three.renderers.cameras.CubeCamera)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCubeCamera(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.cameras.CubeCamera")
    // ===== 构造：无参（near/far 取默认值） =====
    b.constructor {_ => CubeCamera()}
    // ===== Object3D 继承成员 =====
    prebindInstallObject3DMembers(b, vm)
    // ===== 立方体相机自有成员 =====
    b.property("coordinateSystem", getter: Some({
        ref => match (ref.cast<CubeCamera>().coordinateSystem) {
            case Some(s) => LuaValue.of(s)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<CubeCamera>().coordinateSystem = if (v.isNil) {
            None
        } else {
            Some(v.intValue())
        }
    }))
    b.property("activeMipmapLevel", getter: Some({ref => LuaValue.of(ref.cast<CubeCamera>().activeMipmapLevel)}),
        setter: Some({ref, v => ref.cast<CubeCamera>().activeMipmapLevel = v.intValue()}))
    b.method("updateCoordinateSystem") {
        ref, _ =>
            ref.cast<CubeCamera>().updateCoordinateSystem()
            []
    }
    b.install(vm)
}
