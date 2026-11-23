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
 * @file[zh-cn] renderers_materials_shadermaterial 自定义着色器材质 ShaderMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.ShaderMaterial 绑定为 Lua 类型并导出子类共用的成员安装函数
 * @explain[zh-cn] 绑定 vertexShader/fragmentShader 属性；构造支持无参与
 * (vertexShader, fragmentShader) 两参形式（uniforms 为 HashMap，无法从 Lua 传入，使用默认空表）。
 * 导出 _prebindMatShaderMaterialMembers 供 RawShaderMaterial 复用（内部先安装 Material 基类成员）。
 * 跳过成员及原因：
 * - uniforms：HashMap<String, Any> 任意值容器无 Lua 通道；
 * - copy(source: ShaderMaterial, recursive!)：与基类 copy 同名，统一由 Material 级 copy 覆盖。
 *
 * @file[en] renderers_materials_shadermaterial  Lua binding of ShaderMaterial (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.ShaderMaterial and exports the shared subclass installer
 * @explain[en] Binds the vertexShader/fragmentShader properties; the constructor supports both the
 * zero-argument form and the (vertexShader, fragmentShader) form (uniforms is a HashMap that cannot
 * be passed from Lua, so it defaults to an empty map). Exports _prebindMatShaderMaterialMembers for
 * RawShaderMaterial; it installs the Material base members first.
 * Skipped members and reasons:
 * - uniforms: HashMap<String, Any> arbitrary-value container has no Lua channel;
 * - copy(source: ShaderMaterial, recursive!): it shares the Lua name with the base copy, which the
 *   Material-level copy covers.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为绑定器安装 ShaderMaterial 的成员（构造除外）
 * @explain[zh-cn] 先调用 _prebindMatMaterialMembers 安装 Material 基类成员，再补充着色器源码属性。
 * RawShaderMaterial 的绑定复用本函数（Lua 类表没有继承）。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the ShaderMaterial members (except the constructor) on a class binder
 * @explain[en] Calls _prebindMatMaterialMembers first for the Material base members, then adds the
 * shader source properties. The RawShaderMaterial binding reuses this function (Lua class tables have
 * no inheritance).
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindMatShaderMaterialMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    _prebindMatMaterialMembers(b, vm)
    b.property("vertexShader", getter: Some({ref => LuaValue.of(ref.cast<ShaderMaterial>().vertexShader)}),
        setter: Some({ref, v => ref.cast<ShaderMaterial>().vertexShader = v.stringValue()}))
    b.property("fragmentShader", getter: Some({ref => LuaValue.of(ref.cast<ShaderMaterial>().fragmentShader)}),
        setter: Some({ref, v => ref.cast<ShaderMaterial>().fragmentShader = v.stringValue()}))
}

/**
 * @brief[zh-cn] 安装 ShaderMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.ShaderMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ShaderMaterial
 * @param[en] vm The target virtual machine (class table at three.renderers.materials.ShaderMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShaderMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.ShaderMaterial")
    b.constructor {
        args => if (args.size >= 2) {
            ShaderMaterial(prebindStr(args, 0), prebindStr(args, 1))
        } else {
            ShaderMaterial()
        }
    }
    _prebindMatShaderMaterialMembers(b, vm)
    b.install(vm)
}
