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
 * @file[zh-cn] bgfx 着色器编译
 * @brief[zh-cn] 替代 WebGLShader，使用 bgfx ShaderHandle 编译着色器
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLShader.js。在 WebGL 中通过 gl.createShader/gl.shaderSource/gl.compileShader 编译着色器，在 bgfx 中通过 bgfx_create_shader_cj 编译着色器。
 *
 * @file[en] bgfx Shader Compilation
 * @brief[en] Replaces WebGLShader, compiles shaders using bgfx ShaderHandle
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLShader.js. In WebGL, shaders are compiled via gl.createShader/gl.shaderSource/gl.compileShader; in bgfx, shaders are compiled via bgfx_create_shader_cj.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*
import bgfx4cj.bx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] 着色器阶段信息
 * @explain[zh-cn] 对照 WebGLShaderCache 中的 ShaderStage，存储着色器代码、句柄和引用计数
 *
 * @brief[en] Shader stage information
 * @explain[en] Corresponds to ShaderStage in WebGLShaderCache, stores shader code, handle and reference count
 */
public class ShaderStage {
    /**
     * @brief[zh-cn] 着色器代码
     *
     * @brief[en] Shader code
     */
    public var code: String = ""
    /**
     * @brief[zh-cn] bgfx 着色器句柄
     *
     * @brief[en] bgfx shader handle
     */
    public var handle: ShaderHandle = ShaderHandle()
    /**
     * @brief[zh-cn] 使用次数
     *
     * @brief[en] Usage count
     */
    public var usedTimes: Int64 = 0

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 着色器编译
 * @explain[zh-cn] 对照 WebGLShader，封装着色器的编译和销毁。bgfx 使用 bgfx_create_shader_cj 从内存编译着色器二进制
 *
 * @brief[en] bgfx shader compilation
 * @explain[en] Corresponds to WebGLShader, encapsulates shader compilation and destruction. bgfx uses bgfx_create_shader_cj to compile shader binary from memory
 */
public class BgfxShader {
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.info = info
    }

    /**
     * @brief[zh-cn] 编译着色器
     * @explain[zh-cn] 对照 WebGLShader() 中的 gl.createShader/gl.shaderSource/gl.compileShader
     * @param[zh-cn] code 着色器代码（BgfxMemory，内部取指针）
     * name 着色器名称（用于调试）
     * @return[zh-cn] 着色器句柄
     *
     * @brief[en] Compile shader
     * @explain[en] Corresponds to gl.createShader/gl.shaderSource/gl.compileShader in WebGLShader()
     * @param[en] code Shader code (BgfxMemory, internal pointer)
     * name Shader name (for debugging)
     * @return[en] Shader handle
     */
    public func compileShader(code: BgfxMemory, name: String): ShaderHandle {
        let handle = bgfx_create_shader_cj(code.get())
        if (handle.idx != 0xFFFFu16) {
            // 设置着色器名称（调试用）
            let cName = unsafe { LibC.mallocCString(name) }
            let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
            bgfx_set_shader_name_cj(handle, cName, Int32(name.size))
            cNameHolder.dispose()
            info.memory.shaders += 1
        }
        return handle
    }

    /**
     * @brief[zh-cn] 销毁着色器
     * @explain[zh-cn] 对照 gl.deleteShader()
     * @param[zh-cn] handle 着色器句柄
     *
     * @brief[en] Destroy shader
     * @explain[en] Corresponds to gl.deleteShader()
     * @param[en] handle Shader handle
     */
    public func destroyShader(handle: ShaderHandle): Unit {
        if (handle.idx != 0xFFFFu16) {
            bgfx_destroy_shader_cj(handle)
            info.memory.shaders -= 1
        }
    }
}
