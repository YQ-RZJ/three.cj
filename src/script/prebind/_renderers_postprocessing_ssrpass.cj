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
 * @file[zh-cn] renderers_postprocessing_ssrpass 屏幕空间反射 pass SSRPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.SSRPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera)，绑定 output / opacity / maxDistance / thickness /
 * blur / distanceAttenuation / fresnel / infiniteThick / debug / selective / selects
 * （Option<ArrayList<Object3D>>，nil 表示未设置）/ groundReflector（Option<GroundReflector>）
 * 属性，rtWidth() / rtHeight() 方法与 SSR_VIEW_ID_BASE / OUTPUT_DEFAULT / OUTPUT_SSR /
 * OUTPUT_BEAUTY / OUTPUT_DEPTH / OUTPUT_NORMAL / OUTPUT_HITNORMALS 常量（按同名 staticMethod
 * 取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员（含 setSize / release）。
 * 使用前提：法线/深度/SSR/blur/金属度各 RT 的创建与多次场景提交都触达 bgfx，必须由引擎完成 bgfx
 * 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - normalTexture() / depthTexture() / ssrTexture() / blur2Texture()：返回 TextureHandle
 *   （bgfx 句柄），Lua 无通道；
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄、几何体缓存、暂存数组与 _createRTs 等为内部实现。
 *
 * @file[en] renderers_postprocessing_ssrpass  Lua binding of the screen-space reflection pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.SSRPass as a Lua type
 * @explain[en] Constructor new(scene, camera); binds the output / opacity / maxDistance / thickness /
 * blur / distanceAttenuation / fresnel / infiniteThick / debug / selective / selects
 * (Option<ArrayList<Object3D>>, nil means unset) / groundReflector (Option<GroundReflector>)
 * properties, the rtWidth() / rtHeight() methods and the SSR_VIEW_ID_BASE / OUTPUT_DEFAULT /
 * OUTPUT_SSR / OUTPUT_BEAUTY / OUTPUT_DEPTH / OUTPUT_NORMAL / OUTPUT_HITNORMALS constants (read as
 * same-named staticMethods), and reuses _prebindPpPassMembers for the Pass base members (including
 * setSize / release).
 * Precondition: creation of the normal/depth/SSR/blur/metalness RTs and the multiple scene
 * submissions reach bgfx and only take effect after bgfx initialization. Construction and property
 * access are safe.
 * Skipped members and reasons:
 * - normalTexture() / depthTexture() / ssrTexture() / blur2Texture(): return TextureHandle (bgfx
 *   handles) with no Lua channel;
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles, geometry caches, scratch arrays and _createRTs are
 *   implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.scene.objects.Object3D
import three.scene.entity.GroundReflector
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SSRPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.SSRPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SSRPass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.SSRPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSSRPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.SSRPass")
    b.constructor {
        args => SSRPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
    }
    _prebindPpPassMembers(b, vm)
    b.property("output", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().output)}),
        setter: Some({ref, v => ref.cast<SSRPass>().output = v.intValue()}))
    b.property("opacity", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().opacity)}),
        setter: Some({ref, v => ref.cast<SSRPass>().opacity = v.numberValue()}))
    b.property("maxDistance", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().maxDistance)}),
        setter: Some({ref, v => ref.cast<SSRPass>().maxDistance = v.numberValue()}))
    b.property("thickness", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().thickness)}),
        setter: Some({ref, v => ref.cast<SSRPass>().thickness = v.numberValue()}))
    b.property("blur", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().blur)}),
        setter: Some({ref, v => ref.cast<SSRPass>().blur = v.boolValue()}))
    b.property("distanceAttenuation", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().distanceAttenuation)}),
        setter: Some({
            ref, v => ref.cast<SSRPass>().distanceAttenuation = v.boolValue()
        }))
    b.property("fresnel", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().fresnel)}),
        setter: Some({ref, v => ref.cast<SSRPass>().fresnel = v.boolValue()}))
    b.property("infiniteThick", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().infiniteThick)}),
        setter: Some({ref, v => ref.cast<SSRPass>().infiniteThick = v.boolValue()}))
    b.property("debug", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().debug)}),
        setter: Some({ref, v => ref.cast<SSRPass>().debug = v.boolValue()}))
    b.property("selective", getter: Some({ref => LuaValue.of(ref.cast<SSRPass>().selective)}),
        setter: Some({ref, v => ref.cast<SSRPass>().selective = v.boolValue()}))
    b.property("selects", getter: Some({
        ref => match (ref.cast<SSRPass>().selects) {
            case Some(list) => _prebindPpObj3DListToLua(list)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<SSRPass>().selects = if (v.isNil) {
            None
        } else {
            Some(prebindObjList<Object3D>(vm, [v], 0))
        }
    }))
    b.property("groundReflector", getter: Some({
        ref => match (ref.cast<SSRPass>().groundReflector) {
            case Some(g) => prebindRegister(g, "three.scene.entity.GroundReflector")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<SSRPass>().groundReflector = if (v.isObject) {
            Some(prebindAsValue<GroundReflector>(v))
        } else {
            None
        }
    }))
    b.method("rtWidth") {
        ref, _ => [LuaValue.of(ref.cast<SSRPass>().rtWidth())]
    }
    b.method("rtHeight") {
        ref, _ => [LuaValue.of(ref.cast<SSRPass>().rtHeight())]
    }
    b.staticMethod("SSR_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(SSRPass.SSR_VIEW_ID_BASE))]
    }
    b.staticMethod("OUTPUT_DEFAULT") {_ => [LuaValue.of(SSRPass.OUTPUT_DEFAULT)]}
    b.staticMethod("OUTPUT_SSR") {_ => [LuaValue.of(SSRPass.OUTPUT_SSR)]}
    b.staticMethod("OUTPUT_BEAUTY") {_ => [LuaValue.of(SSRPass.OUTPUT_BEAUTY)]}
    b.staticMethod("OUTPUT_DEPTH") {_ => [LuaValue.of(SSRPass.OUTPUT_DEPTH)]}
    b.staticMethod("OUTPUT_NORMAL") {_ => [LuaValue.of(SSRPass.OUTPUT_NORMAL)]}
    b.staticMethod("OUTPUT_HITNORMALS") {_ => [LuaValue.of(SSRPass.OUTPUT_HITNORMALS)]}
    b.install(vm)
}
