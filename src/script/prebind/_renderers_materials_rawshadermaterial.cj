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
 * @file[zh-cn] renderers_materials_rawshadermaterial 原始着色器材质 RawShaderMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.RawShaderMaterial 绑定为 Lua 类型
 * @explain[zh-cn] RawShaderMaterial 没有独有 public 字段；构造后复用
 * _prebindMatShaderMaterialMembers（内含 Material 基类成员 + vertexShader/fragmentShader）
 * 安装全部继承成员。Lua 类表没有继承，因此不依赖 ShaderMaterial 的类表。
 *
 * @file[en] renderers_materials_rawshadermaterial  Lua binding of RawShaderMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.RawShaderMaterial as a Lua type
 * @explain[en] RawShaderMaterial declares no own public fields; after construction it reuses
 * _prebindMatShaderMaterialMembers (Material base members plus vertexShader/fragmentShader) to install
 * all inherited members. Lua class tables have no inheritance, so it does not rely on the
 * ShaderMaterial class table.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RawShaderMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.RawShaderMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawShaderMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.RawShaderMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawShaderMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.RawShaderMaterial")
    b.constructor {_ => RawShaderMaterial()}
    _prebindMatShaderMaterialMembers(b, vm)
    b.install(vm)
}
