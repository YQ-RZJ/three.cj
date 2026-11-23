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
 * @file[zh-cn] IShaderProgram 着色器程序接口
 * @brief[zh-cn] 着色器程序接口，解耦 materials/postprocessing 与 shaders 的具体类型依赖
 * @explain[zh-cn] 原为解耦 materials 与 shaders 包级循环依赖的标记接口
 * （Material.onBeforeCompile(shaderobject, renderer) 回调参数 shaderobject）。
 * 现升级为功能接口：后处理 pass 也以本接口持有着色器程序引用，不再直接依赖 bgfx 包的
 * 具体 ShaderProgram 类型。方法集由 pass 实际调用面决定：
 * - compile() / compile(extraDefines!)：编译着色器（后者带变体 #define）
 * - resetHandles()：重置已编译句柄（下次 compile 强制重编译）
 * - gfxProgramHandle：抽象层程序句柄，供 FullScreenQuad.submit 等提交路径取用
 * materials 侧仍仅把本接口作为回调参数类型持有（不调用其方法），行为不变。
 *
 * @file[en] IShaderProgram Shader program interface
 * @brief[en] Shader program interface, decoupling materials/postprocessing from concrete shader types
 * @explain[en] Originally a marker interface decoupling the materials/shaders package cycle
 * (Material.onBeforeCompile(shaderobject, renderer) callback parameter shaderobject).
 * It is now a functional interface: post-processing passes also hold shader programs by this
 * interface instead of depending on the concrete ShaderProgram type in the bgfx package.
 * The method set is derived from the actual pass call sites:
 * - compile() / compile(extraDefines!): compile the shader (the latter with variant #defines)
 * - resetHandles(): reset compiled handles (force a recompile on the next compile)
 * - gfxProgramHandle: abstraction-layer program handle, used by FullScreenQuad.submit etc.
 * The materials side still only holds this interface as a callback parameter type (without
 * calling its methods), so its behavior is unchanged.
 *
 * @protected package three.renderers._interfaces
 */
protected package three.renderers._interfaces

import three.renderers._gfx.GfxProgramHandle

/**
 * @brief[zh-cn] 着色器程序接口：Material.onBeforeCompile 回调的 shaderobject 参数类型，
 * 亦供后处理 pass 持有 / 编译 / 取提交句柄
 *
 * @brief[en] Shader program interface: shaderobject parameter type for Material.onBeforeCompile callback,
 * also held / compiled / handle-accessed by post-processing passes
 */
public interface IShaderProgram {
    /**
     * @brief[zh-cn] 编译着色器程序（无额外变体 #define）
     *
     * @brief[en] Compiles the shader program (no extra variant #define)
     */
    func compile(): Unit

    /**
     * @param[zh-cn] extraDefines 额外的变体 #define 标志数组（如 "USE_MAP=1"）
     *
     * @brief[zh-cn] 编译着色器程序（带变体 #define）
     *
     * @param[en] extraDefines Extra variant #define flag array (e.g. "USE_MAP=1")
     *
     * @brief[en] Compiles the shader program (with variant #defines)
     */
    func compile(extraDefines!: Array<String>): Unit

    /**
     * @brief[zh-cn] 重置已编译句柄，使下一次 compile 强制重编译
     *
     * @brief[en] Resets compiled handles so the next compile forces a recompile
     */
    func resetHandles(): Unit

    /**
     * @brief[zh-cn] 抽象层程序句柄（供 FullScreenQuad.submit 等提交路径取用）
     *
     * @brief[en] Abstraction-layer program handle (used by FullScreenQuad.submit etc.)
     */
    prop gfxProgramHandle: GfxProgramHandle
}
