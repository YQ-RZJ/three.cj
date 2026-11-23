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
 * @file[zh-cn] renderers_postprocessing_outlinepass 描边 pass OutlinePass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.OutlinePass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(resolution, scene, camera, selectedObjects)（后两者为位置参数：
 * resolve 为 Vector2、selectedObjects 为 Object3D 数组），绑定 renderScene / renderCamera /
 * selectedObjects（ArrayList<Object3D> ↔ Lua 数组）/ visibleEdgeColor / hiddenEdgeColor /
 * edgeGlow / usePatternTexture / patternTexture（Option<Texture>）/ edgeThickness / edgeStrength /
 * downSampleRatio / pulsePeriod / resolution 属性与常量 OUTLINE_VIEW_ID_BASE（按函数取值），
 * 并复用 _prebindPpPassMembers 安装 Pass 基类成员（含 setSize / release）。
 * 使用前提：内部 7+ 个 RT 的创建/销毁与多次场景提交都触达 bgfx，必须由引擎完成 bgfx 初始化后
 * 才会真正执行（setSize 尤其如此）。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄、几何体缓存与 _renderSceneToMask / _createRTs 等为内部实现。
 *
 * @file[en] renderers_postprocessing_outlinepass  Lua binding of the outline pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.OutlinePass as a Lua type
 * @explain[en] Constructor new(resolution, scene, camera, selectedObjects) (the last two are
 * positional: resolution is a Vector2 and selectedObjects an Object3D array); binds renderScene /
 * renderCamera / selectedObjects (ArrayList<Object3D> <-> Lua array) / visibleEdgeColor /
 * hiddenEdgeColor / edgeGlow / usePatternTexture / patternTexture (Option<Texture>) /
 * edgeThickness / edgeStrength / downSampleRatio / pulsePeriod / resolution and the
 * OUTLINE_VIEW_ID_BASE constant (read as a function), and reuses _prebindPpPassMembers for the Pass
 * base members (including setSize / release).
 * Precondition: creation/destruction of the internal 7+ RTs and the multiple scene submissions
 * reach bgfx and only take effect after bgfx initialization (especially setSize). Construction and
 * property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles, geometry caches and _renderSceneToMask / _createRTs are
 *   implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.core.math.{Vector2, Color}
import three.renderers.textures.Texture
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.scene.objects.Object3D
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 OutlinePass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.OutlinePass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of OutlinePass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.OutlinePass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installOutlinePass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.OutlinePass")
    b.constructor {
        args => OutlinePass(_prebindPpVec2(args, 0), prebindAs<Scene>(args, 1), prebindAs<Camera>(args, 2),
            prebindObjList<Object3D>(vm, args, 3))
    }
    _prebindPpPassMembers(b, vm)
    b.property("renderScene", getter: Some({
        ref => prebindRegister(ref.cast<OutlinePass>().renderScene, "three.scene.scenegraph.Scene")
    }))
    b.property("renderCamera", getter: Some({
        ref => prebindRegister(ref.cast<OutlinePass>().renderCamera, "three.renderers.cameras.Camera")
    }))
    b.property("selectedObjects", getter: Some({
        ref => _prebindPpObj3DListToLua(ref.cast<OutlinePass>().selectedObjects)
    }), setter: Some({
        ref, v => ref.cast<OutlinePass>().selectedObjects = prebindObjList<Object3D>(vm, [v], 0)
    }))
    b.property("visibleEdgeColor", getter: Some({
        ref => prebindRegister(ref.cast<OutlinePass>().visibleEdgeColor, "three.core.math.Color")
    }), setter: Some({
        ref, v => ref.cast<OutlinePass>().visibleEdgeColor = prebindAsValue<Color>(v)
    }))
    b.property("hiddenEdgeColor", getter: Some({
        ref => prebindRegister(ref.cast<OutlinePass>().hiddenEdgeColor, "three.core.math.Color")
    }), setter: Some({
        ref, v => ref.cast<OutlinePass>().hiddenEdgeColor = prebindAsValue<Color>(v)
    }))
    b.property("edgeGlow", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().edgeGlow)}),
        setter: Some({ref, v => ref.cast<OutlinePass>().edgeGlow = v.numberValue()}))
    b.property("usePatternTexture", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().usePatternTexture)}),
        setter: Some({ref, v => ref.cast<OutlinePass>().usePatternTexture = v.boolValue()}))
    b.property("patternTexture", getter: Some({
        ref => match (ref.cast<OutlinePass>().patternTexture) {
            case Some(t) => prebindRegister(t, "three.renderers.textures.Texture")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<OutlinePass>().patternTexture = if (v.isObject) {
            Some(prebindAsValue<Texture>(v))
        } else {
            None
        }
    }))
    b.property("edgeThickness", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().edgeThickness)}),
        setter: Some({ref, v => ref.cast<OutlinePass>().edgeThickness = v.numberValue()}))
    b.property("edgeStrength", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().edgeStrength)}),
        setter: Some({ref, v => ref.cast<OutlinePass>().edgeStrength = v.numberValue()}))
    b.property("downSampleRatio", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().downSampleRatio)}),
        setter: Some({ref, v => ref.cast<OutlinePass>().downSampleRatio = v.intValue()}))
    b.property("pulsePeriod", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().pulsePeriod)}),
        setter: Some({ref, v => ref.cast<OutlinePass>().pulsePeriod = v.numberValue()}))
    b.property("resolution", getter: Some({
        ref => prebindRegister(ref.cast<OutlinePass>().resolution, "three.core.math.Vector2")
    }), setter: Some({
        ref, v => ref.cast<OutlinePass>().resolution = prebindAsValue<Vector2>(v)
    }))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<OutlinePass>().releasable)}))
    b.staticMethod("OUTLINE_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(OutlinePass.OUTLINE_VIEW_ID_BASE))]
    }
    b.install(vm)
}
