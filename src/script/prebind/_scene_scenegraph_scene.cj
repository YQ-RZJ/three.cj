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
 * @file[zh-cn] scene_scenegraph_scene Scene 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.scenegraph.Scene 绑定为 Lua 类型 three.scene.scenegraph.Scene
 * @explain[zh-cn] 绑定构造、fog/fogExp2（可空，Some 注册 / None nil）、background（可空，
 * Color 与 Texture 按具体类型注册，其余接口实现返回 nil）、environment（可空 Texture）、
 * backgroundBlurriness/backgroundIntensity/environmentIntensity、backgroundRotation/
 * environmentRotation（Euler）、getBackground()，并通过 prebindInstallObject3DMembers 复用
 * Object3D 全部成员（add/remove/attach/traverse/updateMatrixWorld/lookAt/position 等）。
 * 跳过成员及原因：
 * - fogJson / fogExp2Json / backgroundJson / environmentJson / overrideMaterialJson：
 *   fastjson 序列化辅助属性（JSON 字符串往返），非脚本接口；
 * - environmentNode：Option<Any>，由 NodeManager 运行时注入，非脚本接口；
 * - overrideMaterial：Option<Material>，Material 类尚未提供 Lua 绑定，无法安全暴露；
 * - backgroundNode：protected 字段，不可访问。
 * background/environment 的 Texture 目标类型（three.renderers.textures.Texture）本批次未绑定，
 * Lua 侧只能持有并回传该 userdata，无法读取其属性。
 *
 * @file[en] scene_scenegraph_scene  Lua binding of Scene (three.script.prebind)
 * @brief[en] Binds three.scene.scenegraph.Scene as the Lua type three.scene.scenegraph.Scene
 * @explain[en] Binds the constructor, fog/fogExp2 (nullable: Some registered / None nil),
 * background (nullable: Color and Texture are registered by concrete type, other interface
 * implementations yield nil), environment (nullable Texture), backgroundBlurriness/
 * backgroundIntensity/environmentIntensity, backgroundRotation/environmentRotation (Euler) and
 * getBackground(), and reuses every Object3D member through prebindInstallObject3DMembers
 * (add/remove/attach/traverse/updateMatrixWorld/lookAt/position, etc.).
 * Skipped members and reasons:
 * - fogJson / fogExp2Json / backgroundJson / environmentJson / overrideMaterialJson:
 *   fastjson serialization shims (JSON string round-trip), not script APIs;
 * - environmentNode: Option<Any>, injected by NodeManager at runtime, not a script API;
 * - overrideMaterial: Option<Material>; Material has no Lua binding yet, so it cannot be
 *   exposed safely;
 * - backgroundNode: protected field, not accessible.
 * The Texture target type of background/environment (three.renderers.textures.Texture) is not
 * bound in this batch, so Lua can only hold and pass that userdata back, not read its fields.
 */
package three.script.prebind

import three.core._interfaces.IBackground
import three.core.math.*
import three.renderers.textures.*
import three.scene.objects.*
import three.scene.scenegraph.*
import three.script.vm.*
import three.script.binding.*

/// 背景值转 Lua：Color/Texture 按具体类型注册，其余（或空）返回 nil
private func _prebindBackgroundToLua(value: Option<IBackground>): LuaValue {
    match (value) {
        case Some(bg) => match (bg) {
            case c: Color => prebindRegister(c, "three.core.math.Color")
            case t: Texture => prebindRegister(t, "three.renderers.textures.Texture")
            case _ => LuaValue.Nil
        }
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 安装 Scene 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.scenegraph.Scene）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Scene
 * @param[en] vm The target virtual machine (class table installed at three.scene.scenegraph.Scene)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installScene(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.scenegraph.Scene")
    // ===== 构造 =====
    b.constructor {_ => Scene()}
    // ===== Object3D 继承成员 =====
    prebindInstallObject3DMembers(b, vm)
    // ===== 雾 =====
    b.property("fog", getter: Some({
        ref => match (ref.cast<Scene>().fog) {
            case Some(f) => prebindRegister(f, "three.scene.scenegraph.Fog")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Scene>().fog = Some(LuaObjectRegistry.getAs<Fog>(v.objectId()))
        } else {
            ref.cast<Scene>().fog = None
        }
    }))
    b.property("fogExp2", getter: Some({
        ref => match (ref.cast<Scene>().fogExp2) {
            case Some(f) => prebindRegister(f, "three.scene.scenegraph.FogExp2")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Scene>().fogExp2 = Some(LuaObjectRegistry.getAs<FogExp2>(v.objectId()))
        } else {
            ref.cast<Scene>().fogExp2 = None
        }
    }))
    // ===== 背景 / 环境贴图 =====
    b.property(
        "background",
        getter: Some({ref => _prebindBackgroundToLua(ref.cast<Scene>().background)}),
        setter: Some(
            {
                ref, v =>
                    let sc = ref.cast<Scene>()
                    if (v.isObject) {
                        match (LuaObjectRegistry.get(v.objectId())) {
                            case Some(o) => match (o) {
                                case c: Color => sc.background = Some(c)
                                case t: Texture => sc.background = Some(t)
                                case _ => sc.background = None
                            }
                            case None => sc.background = None
                        }
                    } else {
                        sc.background = None
                    }
            }
        )
    )
    b.property("environment", getter: Some({
        ref => match (ref.cast<Scene>().environment) {
            case Some(t) => prebindRegister(t, "three.renderers.textures.Texture")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Scene>().environment = Some(LuaObjectRegistry.getAs<Texture>(v.objectId()))
        } else {
            ref.cast<Scene>().environment = None
        }
    }))
    // ===== 背景 / 环境参数 =====
    b.property("backgroundBlurriness", getter: Some({ref => LuaValue.of(ref.cast<Scene>().backgroundBlurriness)}),
        setter: Some({ref, v => ref.cast<Scene>().backgroundBlurriness = v.numberValue()}))
    b.property("backgroundIntensity", getter: Some({ref => LuaValue.of(ref.cast<Scene>().backgroundIntensity)}),
        setter: Some({ref, v => ref.cast<Scene>().backgroundIntensity = v.numberValue()}))
    b.property("backgroundRotation",
        getter: Some({ref => prebindRegister(ref.cast<Scene>().backgroundRotation, "three.core.math.Euler")}),
        setter: Some({ref, v => ref.cast<Scene>().backgroundRotation = prebindAsValue<Euler>(v)}))
    b.property("environmentIntensity", getter: Some({ref => LuaValue.of(ref.cast<Scene>().environmentIntensity)}),
        setter: Some({ref, v => ref.cast<Scene>().environmentIntensity = v.numberValue()}))
    b.property("environmentRotation",
        getter: Some({ref => prebindRegister(ref.cast<Scene>().environmentRotation, "three.core.math.Euler")}),
        setter: Some({ref, v => ref.cast<Scene>().environmentRotation = prebindAsValue<Euler>(v)}))
    // ===== IScene 接口 =====
    b.method("getBackground") {
        ref, _ => [_prebindBackgroundToLua(ref.cast<Scene>().getBackground())]
    }
    b.install(vm)
}
