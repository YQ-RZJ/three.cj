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
 * @file[zh-cn] renderers_postprocessing_cubetexturepass 立方体贴图 pass CubeTexturePass 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.CubeTexturePass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(camera, cubeTex[, opacity])，绑定 camera / cubeTex / opacity 属性与
 * 常量 CUBE_VIEW_ID（按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * camera 为 three.renderers.cameras.Camera、cubeTex 为 three.renderers.textures.CubeTexture，
 * 两者均已绑定，可直接往返。
 * 使用前提：cube 纹理上传与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成 bgfx 初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 VB/IB/layout/program/纹理句柄缓存与 _ensureCubeMesh 为内部实现（bgfx 句柄无 Lua 通道）。
 *
 * @file[en] renderers_postprocessing_cubetexturepass  Lua binding of the cube texture pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.CubeTexturePass as a Lua type
 * @explain[en] Constructor new(camera, cubeTex[, opacity]); binds the camera / cubeTex / opacity
 * properties and the CUBE_VIEW_ID constant (read as a function), and reuses _prebindPpPassMembers
 * for the Pass base members. camera is three.renderers.cameras.Camera and cubeTex is
 * three.renderers.textures.CubeTexture; both are already bound and round-trip directly.
 * Precondition: cube texture upload and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private VB/IB/layout/program/texture handle caches and _ensureCubeMesh are implementation
 *   details (bgfx handles have no Lua channel).
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.renderers.cameras.Camera
import three.renderers.textures.CubeTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CubeTexturePass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.CubeTexturePass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CubeTexturePass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.CubeTexturePass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCubeTexturePass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.CubeTexturePass")
    b.constructor {
        args => CubeTexturePass(prebindAs<Camera>(args, 0), prebindAs<CubeTexture>(args, 1),
            opacity: prebindNum(args, 2, default: 1.0))
    }
    _prebindPpPassMembers(b, vm)
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<CubeTexturePass>().camera, "three.renderers.cameras.Camera")
    }))
    b.property("cubeTex", getter: Some({
        ref => prebindRegister(ref.cast<CubeTexturePass>().cubeTex, "three.renderers.textures.CubeTexture")
    }), setter: Some({
        ref, v => ref.cast<CubeTexturePass>().cubeTex = prebindAsValue<CubeTexture>(v)
    }))
    b.property("opacity", getter: Some({ref => LuaValue.of(ref.cast<CubeTexturePass>().opacity)}),
        setter: Some({ref, v => ref.cast<CubeTexturePass>().opacity = v.numberValue()}))
    b.staticMethod("CUBE_VIEW_ID") {
        _ => [LuaValue.of(Int64(CubeTexturePass.CUBE_VIEW_ID))]
    }
    b.install(vm)
}
