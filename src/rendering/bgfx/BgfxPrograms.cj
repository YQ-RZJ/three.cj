/**
 * @file[zh-cn] bgfx 着色器程序管理
 * @brief[zh-cn] 替代 WebGLPrograms，管理着色器程序的创建、缓存和获取
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLPrograms.js。WebGLPrograms 管理所有着色器程序的缓存和参数获取。bgfx 版本同样管理程序缓存，但着色器编译方式不同。
 *
 * @file[en] bgfx Shader Program Management
 * @brief[en] Replaces WebGLPrograms, manages shader program creation, caching and retrieval
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLPrograms.js. WebGLPrograms manages shader program caching and parameter retrieval. The bgfx version also manages program caching, but shader compilation differs.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 着色器程序管理
 * @explain[zh-cn] 对照 WebGLPrograms，管理着色器程序的创建、缓存和获取。维护程序列表和参数映射，避免重复创建相同参数的程序。
 *
 * @brief[en] bgfx shader program management
 * @explain[en] Corresponds to WebGLPrograms, manages shader program creation, caching and retrieval. Maintains program list and parameter mapping to avoid creating programs with same parameters.
 */
public class BgfxPrograms {
    /**
     * @brief[zh-cn] 程序列表
     *
     * @brief[en] Program list
     */
    private var programs: ArrayList<BgfxProgramData>
    /**
     * @brief[zh-cn] 程序映射（参数哈希 -> 程序数据）
     *
     * @brief[en] Program map (parameter hash -> program data)
     */
    private var programsMap: HashMap<String, BgfxProgramData>
    /**
     * @brief[zh-cn] 着色器程序创建器
     *
     * @brief[en] Shader program creator
     */
    private var program: BgfxProgram
    /**
     * @brief[zh-cn] 着色器缓存
     *
     * @brief[en] Shader cache
     */
    private var shaderCache: BgfxShaderCache
    /**
     * @brief[zh-cn] 着色器编译器
     *
     * @brief[en] Shader compiler
     */
    private var shader: BgfxShader

    public init(program!: BgfxProgram, shaderCache!: BgfxShaderCache, shader!: BgfxShader) {
        this.programs = ArrayList<BgfxProgramData>()
        this.programsMap = HashMap<String, BgfxProgramData>()
        this.program = program
        this.shaderCache = shaderCache
        this.shader = shader
    }

    /**
     * @brief[zh-cn] 获取或创建着色器程序
     * @explain[zh-cn] 对照 WebGLPrograms.getProgram()
     * @param[zh-cn] paramKey 参数哈希键
     * vertexShader 顶点着色器句柄
     * fragmentShader 片段着色器句柄
     * name 程序名称
     * @return[zh-cn] 程序数据
     *
     * @brief[en] Gets or creates shader program
     * @explain[en] Corresponds to WebGLPrograms.getProgram()
     * @param[en] paramKey Parameter hash key
     * vertexShader Vertex shader handle
     * fragmentShader Fragment shader handle
     * name Program name
     * @return[en] Program data
     */
    public func getProgram(paramKey: String, vertexShader: ShaderHandle, fragmentShader: ShaderHandle, name: String): BgfxProgramData {
        match (programsMap.get(paramKey)) {
            case Some(data) =>
                data.usedTimes += 1
                return data
            case None =>
                let data = program.createProgram(vertexShader, fragmentShader, name)
                data.usedTimes = 1
                programs.add(data)
                programsMap.add(paramKey, data)
                return data
        }
    }

    /**
     * @brief[zh-cn] 释放程序
     * @explain[zh-cn] 对照 WebGLPrograms.releaseProgram()
     * @param[zh-cn] data 程序数据
     *
     * @brief[en] Releases program
     * @explain[en] Corresponds to WebGLPrograms.releaseProgram()
     * @param[en] data Program data
     */
    public func releaseProgram(data: BgfxProgramData): Unit {
        data.usedTimes -= 1
        if (data.usedTimes <= 0) {
            program.destroyProgram(data)
            // 从列表中移除
            var idx: Int64 = -1
            for (i in 0..programs.size) {
                if (refEq(programs[i], data)) {
                    idx = i
                    break
                }
            }
            if (idx >= 0) {
                programs.remove(at: idx)
            }
            // 从映射中移除
            for ((key, value) in programsMap) {
                if (refEq(value, data)) {
                    programsMap.remove(key)
                    break
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 释放所有着色器程序
     *
     * @brief[en] Disposes all shader programs
     */
    public func dispose(): Unit {
        for (data in programs) {
            program.destroyProgram(data)
        }
        programs = ArrayList<BgfxProgramData>()
        programsMap = HashMap<String, BgfxProgramData>()
    }

    /**
     * @brief[zh-cn] 获取程序数量
     * @return[zh-cn] 程序数量
     *
     * @brief[en] Gets program count
     * @return[en] Program count
     */
    public func size(): Int64 {
        return programs.size
    }
}
