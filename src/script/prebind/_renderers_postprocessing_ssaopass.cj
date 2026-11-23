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
 * @file[zh-cn] renderers_postprocessing_ssaopass SSAO pass 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.SSAOPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera)，绑定 kernelRadius / minDistance / maxDistance 属性与
 * 常量 SSAO_VIEW_ID_BASE（按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员
 * （含 setSize / release）。
 * 使用前提：法线/深度/SSAO/blur 各 RT 的创建与多次场景提交都触达 bgfx，必须由引擎完成 bgfx
 * 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/噪声纹理/program 句柄、半球采样 kernel、几何体缓存与 _createRTs 等为内部实现。
 *
 * @file[en] renderers_postprocessing_ssaopass  Lua binding of the SSAO pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.SSAOPass as a Lua type
 * @explain[en] Constructor new(scene, camera); binds the kernelRadius / minDistance / maxDistance
 * properties and the SSAO_VIEW_ID_BASE constant (read as a function), and reuses
 * _prebindPpPassMembers for the Pass base members (including setSize / release).
 * Precondition: creation of the normal/depth/SSAO/blur RTs and the multiple scene submissions reach
 * bgfx and only take effect after bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/noise-texture/program handles, hemisphere kernel, geometry caches and
 *   _createRTs are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SSAOPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.SSAOPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SSAOPass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.SSAOPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSSAOPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.SSAOPass")
    b.constructor {
        args => SSAOPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
    }
    _prebindPpPassMembers(b, vm)
    b.property("kernelRadius", getter: Some({ref => LuaValue.of(ref.cast<SSAOPass>().kernelRadius)}),
        setter: Some({ref, v => ref.cast<SSAOPass>().kernelRadius = v.numberValue()}))
    b.property("minDistance", getter: Some({ref => LuaValue.of(ref.cast<SSAOPass>().minDistance)}),
        setter: Some({ref, v => ref.cast<SSAOPass>().minDistance = v.numberValue()}))
    b.property("maxDistance", getter: Some({ref => LuaValue.of(ref.cast<SSAOPass>().maxDistance)}),
        setter: Some({ref, v => ref.cast<SSAOPass>().maxDistance = v.numberValue()}))
    b.staticMethod("SSAO_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(SSAOPass.SSAO_VIEW_ID_BASE))]
    }
    b.install(vm)
}
