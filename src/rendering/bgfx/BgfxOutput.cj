/**
 * @file[zh-cn] bgfx 输出处理
 * @brief[zh-cn] 替代 WebGLOutput，处理输出色调映射和颜色空间转换
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLOutput.js。WebGLOutput 负责色调映射和颜色空间转换。bgfx 通过着色器实现色调映射，此处提供配置接口。
 *
 * @file[en] bgfx Output Processing
 * @brief[en] Replaces WebGLOutput, handles output tone mapping and color space conversion
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLOutput.js. WebGLOutput handles tone mapping and color space conversion. bgfx implements tone mapping through shaders; this class provides configuration interfaces.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 输出处理
 * @explain[zh-cn] 对照 WebGLOutput，处理色调映射和颜色空间转换。bgfx 通过着色器实现色调映射，此处提供配置接口。
 *
 * @brief[en] bgfx output processing
 * @explain[en] Corresponds to WebGLOutput, handles tone mapping and color space conversion. bgfx implements tone mapping through shaders; this class provides configuration interfaces.
 */
public class BgfxOutput {
    /**
     * @brief[zh-cn] 当前色调映射模式（0=无, 1=线性, 2=Reinhard, 3=Cineon, 4=ACES, 5=AgX, 6=Neutral）
     *
     * @brief[en] Current tone mapping mode (0=None, 1=Linear, 2=Reinhard, 3=Cineon, 4=ACES, 5=AgX, 6=Neutral)
     */
    private var toneMapping: Int64 = 0
    /**
     * @brief[zh-cn] 当前输出颜色空间
     *
     * @brief[en] Current output color space
     */
    private var outputColorSpace: Int64 = 0
    /**
     * @brief[zh-cn] 当前色调映射是否已编码到着色器
     *
     * @brief[en] Whether tone mapping is currently encoded in shader
     */
    private var toneMappingInShader: Bool = true

    public init() {}

    /**
     * @brief[zh-cn] 设置色调映射模式
     * @param[zh-cn] value 色调映射模式值
     *
     * @brief[en] Sets tone mapping mode
     * @param[en] value Tone mapping mode value
     */
    public func setToneMapping(value: Int64): Unit {
        toneMapping = value
    }

    /**
     * @brief[zh-cn] 获取色调映射模式
     * @return[zh-cn] 色调映射模式值
     *
     * @brief[en] Gets tone mapping mode
     * @return[en] Tone mapping mode value
     */
    public func getToneMapping(): Int64 {
        return toneMapping
    }

    /**
     * @brief[zh-cn] 设置输出颜色空间
     * @param[zh-cn] value 颜色空间值
     *
     * @brief[en] Sets output color space
     * @param[en] value Color space value
     */
    public func setOutputColorSpace(value: Int64): Unit {
        outputColorSpace = value
    }

    /**
     * @brief[zh-cn] 获取输出颜色空间
     * @return[zh-cn] 颜色空间值
     *
     * @brief[en] Gets output color space
     * @return[en] Color space value
     */
    public func getOutputColorSpace(): Int64 {
        return outputColorSpace
    }

    /**
     * @brief[zh-cn] 检查是否需要色调映射
     * @return[zh-cn] 是否需要色调映射
     *
     * @brief[en] Checks if tone mapping is needed
     * @return[en] Whether tone mapping is needed
     */
    public func needsToneMapping(): Bool {
        return toneMapping != 0
    }
}
