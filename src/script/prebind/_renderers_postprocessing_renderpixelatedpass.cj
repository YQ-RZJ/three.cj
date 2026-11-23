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
 * @file[zh-cn] renderers_postprocessing_renderpixelatedpass 像素化 pass RenderPixelatedPass 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.RenderPixelatedPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(pixelSize, scene, camera[, normalEdgeStrength[, depthEdgeStrength]])
 * （后两个默认 0.3 / 0.4），绑定 pixelSize / normalEdgeStrength / depthEdgeStrength 属性、
 * setPixelSize(pixelSize) 方法与常量 PIXELATED_VIEW_ID_BASE（按函数取值），并复用
 * _prebindPpPassMembers 安装 Pass 基类成员（含 setSize / release）。
 * 使用前提：内部低分辨率 RT 的创建/销毁、beauty/深度/法线场景提交与合成都触达 bgfx，必须由引擎
 * 完成 bgfx 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄、几何体缓存与 _createRTs 等为内部实现。
 *
 * @file[en] renderers_postprocessing_renderpixelatedpass  Lua binding of the pixelated render pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.RenderPixelatedPass as a Lua type
 * @explain[en] Constructor new(pixelSize, scene, camera[, normalEdgeStrength[, depthEdgeStrength]])
 * (the optional pair defaults to 0.3 / 0.4); binds the pixelSize / normalEdgeStrength /
 * depthEdgeStrength properties, the setPixelSize(pixelSize) method and the PIXELATED_VIEW_ID_BASE
 * constant (read as a function), and reuses _prebindPpPassMembers for the Pass base members
 * (including setSize / release).
 * Precondition: creation/destruction of the low-resolution RTs and the beauty/depth/normal scene
 * submissions plus compositing reach bgfx and only take effect after bgfx initialization.
 * Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles, geometry caches and _createRTs are implementation
 *   details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RenderPixelatedPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.RenderPixelatedPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RenderPixelatedPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.RenderPixelatedPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRenderPixelatedPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.RenderPixelatedPass")
    b.constructor {
        args => RenderPixelatedPass(prebindInt(args, 0), prebindAs<Scene>(args, 1), prebindAs<Camera>(args, 2),
            normalEdgeStrength: prebindNum(args, 3, default: 0.3), depthEdgeStrength: prebindNum(args, 4, default: 0.4))
    }
    _prebindPpPassMembers(b, vm)
    b.property("pixelSize", getter: Some({ref => LuaValue.of(ref.cast<RenderPixelatedPass>().pixelSize)}),
        setter: Some({ref, v => ref.cast<RenderPixelatedPass>().pixelSize = v.intValue()}))
    b.property("normalEdgeStrength", getter: Some({
        ref => LuaValue.of(ref.cast<RenderPixelatedPass>().normalEdgeStrength)
    }), setter: Some({
        ref, v => ref.cast<RenderPixelatedPass>().normalEdgeStrength = v.numberValue()
    }))
    b.property("depthEdgeStrength", getter: Some({
        ref => LuaValue.of(ref.cast<RenderPixelatedPass>().depthEdgeStrength)
    }), setter: Some({
        ref, v => ref.cast<RenderPixelatedPass>().depthEdgeStrength = v.numberValue()
    }))
    b.method("setPixelSize") {
        ref, args =>
            ref.cast<RenderPixelatedPass>().setPixelSize(prebindInt(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("PIXELATED_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(RenderPixelatedPass.PIXELATED_VIEW_ID_BASE))]
    }
    b.install(vm)
}
