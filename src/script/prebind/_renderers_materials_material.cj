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
 * @file[zh-cn] renderers_materials_material 材质抽象基类 Material 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.Material 绑定为 Lua 类型并导出子类共用的成员安装函数
 * @explain[zh-cn] 绑定 Material 的可映射通用渲染状态：标识（kind/uuid/id/name）、颜色与透明度、
 * 面/深度/混合/模板/多边形偏移/抖动/可见性/色调映射等标量开关、alphaTest、雾与裁剪平面、
 * 环境贴图与环境旋转、环境贴图强度；方法 dispose/clone/copy。
 * Color/Texture/Plane/Euler 等对象属性经 prebindRegister 注册、setter 经 prebindAsValue 取回；
 * Option 用 nil 表示 None；clippingPlanes 以对象数组读、逐项注册写。
 * Lua 类表没有继承，所有子类绑定必须在 b.install 之前调用 _prebindMatMaterialMembers 复用这些成员。
 * 跳过成员及原因：
 * - userData / setValues / fromJSON / createFromJSON：HashMap 任意值容器无 Lua 通道；
 * - onBeforeRender / onBeforeCompile / customProgramCacheKey：函数类型字段无 Lua 通道；
 * - 子类中参数类型为具体材质的重载 copy：与通用 copy 同名，重复注册会导致分发不确定，
 *   统一由 Material 级 copy(source: Material) 覆盖。
 *
 * @file[en] renderers_materials_material  Lua binding of the Material abstract base class
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.Material and exports the shared subclass member installer
 * @explain[en] Binds the mappable common render state of Material: identity (kind/uuid/id/name), color
 * and opacity, scalar switches for side/depth/blending/stencil/polygon offset/dither/visibility/tone
 * mapping, alphaTest, fog and clipping planes, environment map and rotation, environment intensity;
 * methods dispose/clone/copy. Object-valued properties (Color/Texture/Plane/Euler) are registered via
 * prebindRegister and fetched by setters via prebindAsValue; Option is nil for None; clippingPlanes is
 * read as an object array and written item by item. Lua class tables have no inheritance, so every
 * subclass binding must call _prebindMatMaterialMembers before b.install.
 * Skipped members and reasons:
 * - userData / setValues / fromJSON / createFromJSON: HashMap arbitrary-value containers have no Lua channel;
 * - onBeforeRender / onBeforeCompile / customProgramCacheKey: function-typed fields have no Lua channel;
 * - subclass copy overloads taking a concrete material type share the same Lua name as the generic copy;
 *   duplicate registration makes dispatch nondeterministic, so the Material-level copy covers them.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.materials.*
import three.renderers.textures.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将可选纹理转为 Lua 值（Some 注册对象，None 返回 nil）
 * @param[zh-cn] tex 可选纹理
 * @return[zh-cn] Lua 值
 *
 * @brief[en] Converts an optional texture into a Lua value (Some registers, None is nil)
 * @param[en] tex The optional texture
 * @return[en] The Lua value
 */
internal func _prebindMatTextureToLua(tex: Option<Texture>): LuaValue {
    match (tex) {
        case Some(t) => prebindRegister(t, "three.renderers.textures.Texture")
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 将 Lua 值转为可选纹理（nil/非对象返回 None）
 * @param[zh-cn] v Lua 值
 * @return[zh-cn] 可选纹理
 *
 * @brief[en] Converts a Lua value into an optional texture (nil/non-object yields None)
 * @param[en] v The Lua value
 * @return[en] The optional texture
 */
internal func _prebindMatTextureFromLua(v: LuaValue): Option<Texture> {
    if (v.isNil || !v.isObject) {
        return None
    }
    return Some(prebindAsValue<Texture>(v))
}

/**
 * @brief[zh-cn] 将颜色对象注册为 Lua 值
 * @param[zh-cn] color 颜色对象
 * @return[zh-cn] Lua 对象值
 *
 * @brief[en] Registers a color object as a Lua value
 * @param[en] color The color object
 * @return[en] The Lua object value
 */
internal func _prebindMatColorToLua(color: Color): LuaValue {
    return prebindRegister(color, "three.core.math.Color")
}

/**
 * @brief[zh-cn] 将 Lua 值取回为颜色对象
 * @param[zh-cn] v Lua 对象值
 * @return[zh-cn] 颜色对象
 *
 * @brief[en] Fetches a color object from a Lua value
 * @param[en] v The Lua object value
 * @return[en] The color object
 */
internal func _prebindMatColorFromLua(v: LuaValue): Color {
    return prebindAsValue<Color>(v)
}

/**
 * @brief[zh-cn] 将可选裁剪平面列表转为 Lua 对象数组（None 返回 nil）
 * @param[zh-cn] planes 可选裁剪平面列表
 * @return[zh-cn] Lua 值
 *
 * @brief[en] Converts an optional clipping-plane list into a Lua object array (None is nil)
 * @param[en] planes The optional clipping-plane list
 * @return[en] The Lua value
 */
internal func _prebindMatPlaneListToLua(planes: Option<ArrayList<Plane>>): LuaValue {
    match (planes) {
        case Some(list) =>
            let n = list.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = prebindRegister(list[i], "three.core.math.Plane")
            }
            LuaValue.Array(out)
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 为绑定器安装 Material 的成员（构造除外）
 * @explain[zh-cn] Lua 类表没有继承，所有 Material 子类的绑定都必须在 b.install 之前调用本函数，
 * 否则子类实例只能看到自己新增的成员。所有回调按 Material 强转后经虚函数分派。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the Material members (except the constructor) on a class binder
 * @explain[en] Lua class tables have no inheritance, so every Material subclass binding must call this
 * before b.install; otherwise instances only expose their own extra members. Callbacks cast to Material
 * and rely on virtual dispatch.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindMatMaterialMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 标识 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<Material>().kind)}),
        setter: Some({ref, v => ref.cast<Material>().kind = v.stringValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<Material>().uuid)}),
        setter: Some({ref, v => ref.cast<Material>().uuid = v.stringValue()}))
    b.property("id", getter: Some({ref => LuaValue.of(ref.cast<Material>().id)}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<Material>().name)}),
        setter: Some({ref, v => ref.cast<Material>().name = v.stringValue()}))
    b.property("version", getter: Some({ref => LuaValue.of(ref.cast<Material>().version)}),
        setter: Some({ref, v => ref.cast<Material>().version = v.intValue()}))
    // ===== 颜色 / 透明度 =====
    b.property("color", getter: Some({ref => _prebindMatColorToLua(ref.cast<Material>().color)}),
        setter: Some({ref, v => ref.cast<Material>().color = _prebindMatColorFromLua(v)}))
    b.property("opacity", getter: Some({ref => LuaValue.of(ref.cast<Material>().opacity)}),
        setter: Some({ref, v => ref.cast<Material>().opacity = v.numberValue()}))
    b.property("transparent", getter: Some({ref => LuaValue.of(ref.cast<Material>().transparent)}),
        setter: Some({ref, v => ref.cast<Material>().transparent = v.boolValue()}))
    b.property("alphaTest", getter: Some({ref => LuaValue.of(ref.cast<Material>().alphaTest)}),
        setter: Some({ref, v => ref.cast<Material>().alphaTest = v.numberValue()}))
    b.property("vertexColors", getter: Some({ref => LuaValue.of(ref.cast<Material>().vertexColors)}),
        setter: Some({ref, v => ref.cast<Material>().vertexColors = v.boolValue()}))
    // ===== 面 / 深度 =====
    b.property("side", getter: Some({ref => LuaValue.of(ref.cast<Material>().side)}),
        setter: Some({ref, v => ref.cast<Material>().side = v.intValue()}))
    b.property("shadowSide", getter: Some({
        ref => match (ref.cast<Material>().shadowSide) {
            case Some(s) => LuaValue.of(s)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<Material>().shadowSide = if (v.isNil) {
            None
        } else {
            Some(v.intValue())
        }
    }))
    b.property("depthTest", getter: Some({ref => LuaValue.of(ref.cast<Material>().depthTest)}),
        setter: Some({ref, v => ref.cast<Material>().depthTest = v.boolValue()}))
    b.property("depthWrite", getter: Some({ref => LuaValue.of(ref.cast<Material>().depthWrite)}),
        setter: Some({ref, v => ref.cast<Material>().depthWrite = v.boolValue()}))
    b.property("depthFunc", getter: Some({ref => LuaValue.of(ref.cast<Material>().depthFunc)}),
        setter: Some({ref, v => ref.cast<Material>().depthFunc = v.intValue()}))
    // ===== 混合 =====
    b.property("blending", getter: Some({ref => LuaValue.of(ref.cast<Material>().blending)}),
        setter: Some({ref, v => ref.cast<Material>().blending = v.intValue()}))
    b.property("blendSrc", getter: Some({ref => LuaValue.of(ref.cast<Material>().blendSrc)}),
        setter: Some({ref, v => ref.cast<Material>().blendSrc = v.intValue()}))
    b.property("blendDst", getter: Some({ref => LuaValue.of(ref.cast<Material>().blendDst)}),
        setter: Some({ref, v => ref.cast<Material>().blendDst = v.intValue()}))
    b.property("blendEquation", getter: Some({ref => LuaValue.of(ref.cast<Material>().blendEquation)}),
        setter: Some({ref, v => ref.cast<Material>().blendEquation = v.intValue()}))
    b.property("premultipliedAlpha", getter: Some({ref => LuaValue.of(ref.cast<Material>().premultipliedAlpha)}),
        setter: Some({ref, v => ref.cast<Material>().premultipliedAlpha = v.boolValue()}))
    // ===== 模板 =====
    b.property("stencilWriteMask", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilWriteMask)}),
        setter: Some({ref, v => ref.cast<Material>().stencilWriteMask = v.intValue()}))
    b.property("stencilFunc", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilFunc)}),
        setter: Some({ref, v => ref.cast<Material>().stencilFunc = v.intValue()}))
    b.property("stencilRef", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilRef)}),
        setter: Some({ref, v => ref.cast<Material>().stencilRef = v.intValue()}))
    b.property("stencilFuncMask", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilFuncMask)}),
        setter: Some({ref, v => ref.cast<Material>().stencilFuncMask = v.intValue()}))
    b.property("stencilFail", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilFail)}),
        setter: Some({ref, v => ref.cast<Material>().stencilFail = v.intValue()}))
    b.property("stencilZFail", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilZFail)}),
        setter: Some({ref, v => ref.cast<Material>().stencilZFail = v.intValue()}))
    b.property("stencilZPass", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilZPass)}),
        setter: Some({ref, v => ref.cast<Material>().stencilZPass = v.intValue()}))
    b.property("stencilWrite", getter: Some({ref => LuaValue.of(ref.cast<Material>().stencilWrite)}),
        setter: Some({ref, v => ref.cast<Material>().stencilWrite = v.boolValue()}))
    // ===== 光栅状态 =====
    b.property("colorWrite", getter: Some({ref => LuaValue.of(ref.cast<Material>().colorWrite)}),
        setter: Some({ref, v => ref.cast<Material>().colorWrite = v.boolValue()}))
    b.property("polygonOffset", getter: Some({ref => LuaValue.of(ref.cast<Material>().polygonOffset)}),
        setter: Some({ref, v => ref.cast<Material>().polygonOffset = v.boolValue()}))
    b.property("polygonOffsetFactor", getter: Some({ref => LuaValue.of(ref.cast<Material>().polygonOffsetFactor)}),
        setter: Some({ref, v => ref.cast<Material>().polygonOffsetFactor = v.numberValue()}))
    b.property("polygonOffsetUnits", getter: Some({ref => LuaValue.of(ref.cast<Material>().polygonOffsetUnits)}),
        setter: Some({ref, v => ref.cast<Material>().polygonOffsetUnits = v.numberValue()}))
    b.property("dithering", getter: Some({ref => LuaValue.of(ref.cast<Material>().dithering)}),
        setter: Some({ref, v => ref.cast<Material>().dithering = v.boolValue()}))
    b.property("alphaToCoverage", getter: Some({ref => LuaValue.of(ref.cast<Material>().alphaToCoverage)}),
        setter: Some({ref, v => ref.cast<Material>().alphaToCoverage = v.boolValue()}))
    b.property("forceSinglePass", getter: Some({ref => LuaValue.of(ref.cast<Material>().forceSinglePass)}),
        setter: Some({ref, v => ref.cast<Material>().forceSinglePass = v.boolValue()}))
    b.property("visible", getter: Some({ref => LuaValue.of(ref.cast<Material>().visible)}),
        setter: Some({ref, v => ref.cast<Material>().visible = v.boolValue()}))
    b.property("toneMapped", getter: Some({ref => LuaValue.of(ref.cast<Material>().toneMapped)}),
        setter: Some({ref, v => ref.cast<Material>().toneMapped = v.boolValue()}))
    b.property("wireframe", getter: Some({ref => LuaValue.of(ref.cast<Material>().wireframe)}),
        setter: Some({ref, v => ref.cast<Material>().wireframe = v.boolValue()}))
    b.property("flatShading", getter: Some({ref => LuaValue.of(ref.cast<Material>().flatShading)}),
        setter: Some({ref, v => ref.cast<Material>().flatShading = v.boolValue()}))
    // ===== 雾 / 裁剪 =====
    b.property("fog", getter: Some({ref => LuaValue.of(ref.cast<Material>().fog)}),
        setter: Some({ref, v => ref.cast<Material>().fog = v.boolValue()}))
    b.property("clippingPlanes", getter: Some({ref => _prebindMatPlaneListToLua(ref.cast<Material>().clippingPlanes)}),
        setter: Some({
            ref, v => ref.cast<Material>().clippingPlanes = if (v.isNil) {
                None
            } else {
                Some(prebindObjList<Plane>(vm, [v], 0))
            }
        }))
    b.property("clipIntersection", getter: Some({ref => LuaValue.of(ref.cast<Material>().clipIntersection)}),
        setter: Some({ref, v => ref.cast<Material>().clipIntersection = v.boolValue()}))
    b.property("clipShadows", getter: Some({ref => LuaValue.of(ref.cast<Material>().clipShadows)}),
        setter: Some({ref, v => ref.cast<Material>().clipShadows = v.boolValue()}))
    // ===== 环境贴图 =====
    b.property("envMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<Material>().envMap)}),
        setter: Some({ref, v => ref.cast<Material>().envMap = _prebindMatTextureFromLua(v)}))
    b.property("envMapRotation", getter: Some({
        ref => match (ref.cast<Material>().envMapRotation) {
            case Some(e) => prebindRegister(e, "three.core.math.Euler")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<Material>().envMapRotation = if (v.isNil || !v.isObject) {
            None
        } else {
            Some(prebindAsValue<Euler>(v))
        }
    }))
    b.property("envMapIntensity", getter: Some({ref => LuaValue.of(ref.cast<Material>().envMapIntensity)}),
        setter: Some({ref, v => ref.cast<Material>().envMapIntensity = v.numberValue()}))
    // ===== 生命周期 =====
    b.method("dispose") {
        ref, _ =>
            ref.cast<Material>().dispose()
            []
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Material>().clone(), "three.renderers.materials.Material")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Material>().copy(prebindAs<Material>(args, 0))
            [LuaValue.Object(ref.id)]
    }
}

/**
 * @brief[zh-cn] 安装 Material 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.Material）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Material
 * @param[en] vm The target virtual machine (class table at three.renderers.materials.Material)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.Material")
    b.constructor {_ => Material()}
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
