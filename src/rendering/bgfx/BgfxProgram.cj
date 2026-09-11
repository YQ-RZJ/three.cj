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
 * @file[zh-cn] bgfx 着色器程序
 * @brief[zh-cn] 替代 WebGLProgram，使用 bgfx ProgramHandle 管理着色器程序
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLProgram.js。在 WebGL 中通过 gl.createProgram/gl.attachShader/gl.linkProgram 管理程序，在 bgfx 中通过 bgfx_create_program_cj 创建程序。
 *
 * @file[en] bgfx Shader Program
 * @brief[en] Replaces WebGLProgram, manages shader programs using bgfx ProgramHandle
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLProgram.js. In WebGL, programs are managed via gl.createProgram/gl.attachShader/gl.linkProgram; in bgfx, programs are created via bgfx_create_program_cj.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] 着色器程序缓存数据
 * @explain[zh-cn] 对照 WebGLProgram 中缓存的 uniform 和 attribute 信息
 *
 * @brief[en] Shader program cache data
 * @explain[en] Corresponds to cached uniform and attribute info in WebGLProgram
 */
public class BgfxProgramData {
    /**
     * @brief[zh-cn] bgfx 程序句柄
     *
     * @brief[en] bgfx program handle
     */
    public var program: ProgramHandle = ProgramHandle()
    /**
     * @brief[zh-cn] 顶点着色器句柄
     *
     * @brief[en] Vertex shader handle
     */
    public var vertexShader: ShaderHandle = ShaderHandle()
    /**
     * @brief[zh-cn] 片段着色器句柄
     *
     * @brief[en] Fragment shader handle
     */
    public var fragmentShader: ShaderHandle = ShaderHandle()
    /**
     * @brief[zh-cn] 程序 ID
     *
     * @brief[en] Program ID
     */
    public var id: Int64 = 0
    /**
     * @brief[zh-cn] 程序名称
     *
     * @brief[en] Program name
     */
    public var name: String = ""
    /**
     * @brief[zh-cn] 是否已销毁
     *
     * @brief[en] Whether destroyed
     */
    public var destroyed: Bool = false
    /**
     * @brief[zh-cn] 使用次数
     *
     * @brief[en] Usage count
     */
    public var usedTimes: Int64 = 0

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 着色器程序
 * @explain[zh-cn] 对照 WebGLProgram，封装着色器程序的创建和管理。bgfx 使用 bgfx_create_program_cj 将顶点和片段着色器链接为程序。
 *
 * @brief[en] bgfx shader program
 * @explain[en] Corresponds to WebGLProgram, wraps shader program creation and management. bgfx uses bgfx_create_program_cj to link vertex and fragment shaders into a program.
 */
public class BgfxProgram {
    /**
     * @brief[zh-cn] 程序 ID 计数器
     *
     * @brief[en] Program ID counter
     */
    private static var programIdCount: Int64 = 0
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
     * @brief[zh-cn] 创建着色器程序
     * @explain[zh-cn] 对照 WebGLProgram() 中的 gl.createProgram/gl.attachShader/gl.linkProgram
     * @param[zh-cn] vertexShader 顶点着色器句柄
     * fragmentShader 片段着色器句柄
     * name 程序名称
     * @return[zh-cn] 程序数据
     *
     * @brief[en] Creates shader program
     * @explain[en] Corresponds to gl.createProgram/gl.attachShader/gl.linkProgram in WebGLProgram()
     * @param[en] vertexShader Vertex shader handle
     * fragmentShader Fragment shader handle
     * name Program name
     * @return[en] Program data
     */
    public func createProgram(vertexShader: ShaderHandle, fragmentShader: ShaderHandle, name: String): BgfxProgramData {
        programIdCount += 1
        let programHandle = bgfx_create_program_cj(vertexShader, fragmentShader, true)
        let data = BgfxProgramData()
        data.program = programHandle
        data.vertexShader = vertexShader
        data.fragmentShader = fragmentShader
        data.id = programIdCount
        data.name = name
        data.destroyed = false
        data.usedTimes = 0
        info.memory.programs += 1
        return data
    }

    /**
     * @brief[zh-cn] 销毁着色器程序
     * @explain[zh-cn] 对照 gl.deleteProgram()
     * @param[zh-cn] data 程序数据
     *
     * @brief[en] Destroys shader program
     * @explain[en] Corresponds to gl.deleteProgram()
     * @param[en] data Program data
     */
    public func destroyProgram(data: BgfxProgramData): Unit {
        if (!data.destroyed) {
            if (data.program.idx != 0xFFFFu16) {
                bgfx_destroy_program_cj(data.program)
            }
            data.destroyed = true
            info.memory.programs -= 1
        }
    }

    /**
     * @brief[zh-cn] 获取下一个程序 ID
     * @return[zh-cn] 程序 ID
     *
     * @brief[en] Gets next program ID
     * @return[en] Program ID
     */
    public static func nextProgramId(): Int64 {
        programIdCount += 1
        return programIdCount
    }
}
