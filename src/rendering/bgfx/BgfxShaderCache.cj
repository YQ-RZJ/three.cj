/**
 * @file[zh-cn] bgfx 着色器缓存
 * @brief[zh-cn] 替代 WebGLShaderCache，管理着色器的复用和引用计数
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLShaderCache.js。WebGLShaderCache 通过代码哈希缓存着色器阶段，避免重复编译。bgfx 版本同样缓存 ShaderHandle，通过引用计数管理生命周期。
 *
 * @file[en] bgfx Shader Cache
 * @brief[en] Replaces WebGLShaderCache, manages shader reuse and reference counting
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLShaderCache.js. WebGLShaderCache caches shader stages by code hash to avoid recompilation. The bgfx version also caches ShaderHandle and manages lifetime via reference counting.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] bgfx 着色器缓存
 * @explain[zh-cn] 对照 WebGLShaderCache，管理着色器的复用和引用计数。相同代码的着色器只编译一次，通过 usedTimes 跟踪引用
 *
 * @brief[en] bgfx shader cache
 * @explain[en] Corresponds to WebGLShaderCache, manages shader reuse and reference counting. Shaders with the same code are compiled only once, tracked via usedTimes
 */
public class BgfxShaderCache {
    /**
     * @brief[zh-cn] 着色器代码到 ShaderStage 的映射
     *
     * @brief[en] Shader code to ShaderStage mapping
     */
    private var shaderCache: HashMap<String, ShaderStage>
    /**
     * @brief[zh-cn] 材质 ID 到已使用的着色器阶段集合的映射
     *
     * @brief[en] Material ID to used shader stage set mapping
     */
    private var materialCache: HashMap<Int64, HashSet<String>>

    public init() {
        this.shaderCache = HashMap<String, ShaderStage>()
        this.materialCache = HashMap<Int64, HashSet<String>>()
    }

    /**
     * @brief[zh-cn] 更新材质的着色器引用
     * @explain[zh-cn] 对照 WebGLShaderCache.update()
     * @param[zh-cn] materialId 材质 ID
     * vertexCode 顶点着色器代码
     * fragmentCode 片段着色器代码
     *
     * @brief[en] Update shader references for a material
     * @explain[en] Corresponds to WebGLShaderCache.update()
     * @param[en] materialId Material ID
     * vertexCode Vertex shader code
     * fragmentCode Fragment shader code
     */
    public func update(materialId: Int64, vertexCode: String, fragmentCode: String): Unit {
        match (materialCache.get(materialId)) {
            case Some(shaders) =>
                // 顶点着色器
                if (!shaders.contains(vertexCode)) {
                    shaders.add(vertexCode)
                    match (shaderCache.get(vertexCode)) {
                        case Some(stage) => stage.usedTimes += 1
                        case None => ()
                    }
                }
                // 片段着色器
                if (!shaders.contains(fragmentCode)) {
                    shaders.add(fragmentCode)
                    match (shaderCache.get(fragmentCode)) {
                        case Some(stage) => stage.usedTimes += 1
                        case None => ()
                    }
                }
            case None =>
                let shaders = HashSet<String>()
                shaders.add(vertexCode)
                shaders.add(fragmentCode)
                materialCache.add(materialId, shaders)
        }
    }

    /**
     * @brief[zh-cn] 移除材质的着色器引用
     * @explain[zh-cn] 对照 WebGLShaderCache.remove()
     * @param[zh-cn] materialId 材质 ID
     *
     * @brief[en] Remove shader references for a material
     * @explain[en] Corresponds to WebGLShaderCache.remove()
     * @param[en] materialId Material ID
     */
    public func remove(materialId: Int64): Unit {
        match (materialCache.get(materialId)) {
            case Some(shaders) =>
                for (code in shaders) {
                    match (shaderCache.get(code)) {
                        case Some(stage) =>
                            stage.usedTimes -= 1
                            if (stage.usedTimes <= 0) {
                                shaderCache.remove(code)
                            }
                        case None => ()
                    }
                }
                materialCache.remove(materialId)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 获取或创建着色器阶段
     * @explain[zh-cn] 对照 WebGLShaderCache._getShaderStage()
     * @param[zh-cn] code 着色器代码
     * shader 着色器编译器
     * mem 着色器数据内存
     * name 着色器名称
     * @return[zh-cn] 着色器阶段
     *
     * @brief[en] Get or create shader stage
     * @explain[en] Corresponds to WebGLShaderCache._getShaderStage()
     * @param[en] code Shader code
     * shader Shader compiler
     * mem Shader data memory
     * name Shader name
     * @return[en] Shader stage
     */
    public func getShaderStage(code: String, shader: BgfxShader, mem: BgfxMemory, name: String): ShaderStage {
        match (shaderCache.get(code)) {
            case Some(stage) =>
                return stage
            case None =>
                let stage = ShaderStage()
                stage.code = code
                stage.handle = shader.compileShader(mem, name)
                stage.usedTimes = 1
                shaderCache.add(code, stage)
                return stage
        }
    }

    /**
     * @brief[zh-cn] 获取顶点着色器阶段
     * @explain[zh-cn] 对照 WebGLShaderCache.getVertexShaderStage()
     * @param[zh-cn] materialId 材质 ID
     * code 着色器代码
     * shader 着色器编译器
     * mem 着色器数据内存
     * @return[zh-cn] 着色器阶段
     *
     * @brief[en] Get vertex shader stage
     * @explain[en] Corresponds to WebGLShaderCache.getVertexShaderStage()
     * @param[en] materialId Material ID
     * code Shader code
     * shader Shader compiler
     * mem Shader data memory
     * @return[en] Shader stage
     */
    public func getVertexShaderStage(materialId: Int64, code: String, shader: BgfxShader, mem: BgfxMemory): ShaderStage {
        return getShaderStage(code, shader, mem, "vs_${materialId}")
    }

    /**
     * @brief[zh-cn] 获取片段着色器阶段
     * @explain[zh-cn] 对照 WebGLShaderCache.getFragmentShaderStage()
     * @param[zh-cn] materialId 材质 ID
     * code 着色器代码
     * shader 着色器编译器
     * mem 着色器数据内存
     * @return[zh-cn] 着色器阶段
     *
     * @brief[en] Get fragment shader stage
     * @explain[en] Corresponds to WebGLShaderCache.getFragmentShaderStage()
     * @param[en] materialId Material ID
     * code Shader code
     * shader Shader compiler
     * mem Shader data memory
     * @return[en] Shader stage
     */
    public func getFragmentShaderStage(materialId: Int64, code: String, shader: BgfxShader, mem: BgfxMemory): ShaderStage {
        return getShaderStage(code, shader, mem, "fs_${materialId}")
    }

    /**
     * @brief[zh-cn] 释放所有缓存
     *
     * @brief[en] Dispose all caches
     */
    public func dispose(): Unit {
        shaderCache = HashMap<String, ShaderStage>()
        materialCache = HashMap<Int64, HashSet<String>>()
    }
}
