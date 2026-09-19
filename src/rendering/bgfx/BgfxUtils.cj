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
 * @file[zh-cn] bgfx 工具函数
 * @brief[zh-cn] 替代 WebGLUtils，提供 three.js 常量到 bgfx 格式的转换
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLUtils.js。在 WebGL 中需要将 three.js 的像素格式/类型转换为 WebGL 常量，在 bgfx 中使用 TextureFormat 枚举替代。
 *
 * @file[en] bgfx Utility Functions
 * @brief[en] Replaces WebGLUtils, provides three.js constant to bgfx format conversion
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLUtils.js. In WebGL, three.js pixel formats/types need conversion to WebGL constants; in bgfx, TextureFormat enum is used instead.
 */
package three.rendering.bgfx

import three.utils.constants.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 工具类，提供格式转换和能力查询
 * @explain[zh-cn] 对照 WebGLUtils，将 three.js 的像素格式和类型转换为 bgfx 的 TextureFormat。bgfx 内部处理跨平台差异，不需要像 WebGL 那样查询扩展
 *
 * @brief[en] bgfx utility class providing format conversion and capability queries
 * @explain[en] Corresponds to WebGLUtils, converts three.js pixel formats and types to bgfx TextureFormat. bgfx handles cross-platform differences internally, no need to query extensions like WebGL
 */
public class BgfxUtils {

    /**
     * @brief[zh-cn] 将 three.js 像素格式转换为 bgfx TextureFormat
     * @explain[zh-cn] 对照 WebGLUtils.convert()，bgfx 使用统一的纹理格式枚举，不需要像 WebGL 那样查询扩展支持
     * @param[zh-cn] format three.js 像素格式常量
     * colorSpace 颜色空间（用于确定 sRGB 变体）
     * @return[zh-cn] bgfx TextureFormat 值，不支持时返回 None
     *
     * @brief[en] Convert three.js pixel format to bgfx TextureFormat
     * @explain[en] Corresponds to WebGLUtils.convert(). bgfx uses unified texture format enum, no need to query extension support like WebGL
     * @param[en] format three.js pixel format constant
     * colorSpace Color space (used to determine sRGB variant)
     * @return[en] bgfx TextureFormat value, returns None when unsupported
     */
    public static func convert(format: Int64, colorSpace: String): Option<UInt32> {
        // 基础类型
        if (format == UnsignedByteType) { return Some(TextureFormat.RGBA8.value()) }
        if (format == HalfFloatType) { return Some(TextureFormat.RGBA16F.value()) }
        if (format == FloatType) { return Some(TextureFormat.RGBA32F.value()) }
        if (format == UnsignedShortType) { return Some(TextureFormat.R16.value()) }
        if (format == UnsignedIntType) { return Some(TextureFormat.R32U.value()) }
        if (format == IntType) { return Some(TextureFormat.R32I.value()) }
        if (format == ByteType) { return Some(TextureFormat.R8.value()) }
        if (format == ShortType) { return Some(TextureFormat.R16I.value()) }

        // 像素格式
        if (format == RGBAFormat) {
            if (colorSpace == SRGBTransfer) { return Some(TextureFormat.RGBA8.value()) }
            return Some(TextureFormat.RGBA8.value())
        }
        if (format == RGBFormat) { return Some(TextureFormat.RGB9E5F.value()) }
        if (format == RedFormat) { return Some(TextureFormat.R8.value()) }
        if (format == RGFormat) { return Some(TextureFormat.RG8.value()) }
        // D24S8 而非 D24：新版 bgfx D3D11 后端中 D24 无 DSV 格式，DepthFormat 纹理常作为 RT 深度附件
        if (format == DepthFormat) { return Some(TextureFormat.D24S8.value()) }
        if (format == DepthStencilFormat) { return Some(TextureFormat.D24S8.value()) }
        if (format == AlphaFormat) { return Some(TextureFormat.A8.value()) }
        if (format == RedIntegerFormat) { return Some(TextureFormat.R32I.value()) }
        if (format == RGIntegerFormat) { return Some(TextureFormat.RG32I.value()) }
        if (format == RGBAIntegerFormat) { return Some(TextureFormat.RGBA32I.value()) }

        // 压缩纹理格式 - S3TC/BC
        if (format == RGB_S3TC_DXT1_Format) { return Some(TextureFormat.BC1.value()) }
        if (format == RGBA_S3TC_DXT1_Format) { return Some(TextureFormat.BC1.value()) }
        if (format == RGBA_S3TC_DXT3_Format) { return Some(TextureFormat.BC2.value()) }
        if (format == RGBA_S3TC_DXT5_Format) { return Some(TextureFormat.BC3.value()) }

        // BPTC
        if (format == RGBA_BPTC_Format) { return Some(TextureFormat.BC7.value()) }
        if (format == RGB_BPTC_UNSIGNED_Format) { return Some(TextureFormat.BC6H.value()) }
        if (format == RGB_BPTC_SIGNED_Format) { return Some(TextureFormat.BC6H.value()) }

        // RGTC
        if (format == RED_RGTC1_Format) { return Some(TextureFormat.BC4.value()) }
        if (format == SIGNED_RED_RGTC1_Format) { return Some(TextureFormat.BC4.value()) }
        if (format == RED_GREEN_RGTC2_Format) { return Some(TextureFormat.BC5.value()) }
        if (format == SIGNED_RED_GREEN_RGTC2_Format) { return Some(TextureFormat.BC5.value()) }

        // ETC
        if (format == RGB_ETC1_Format) { return Some(TextureFormat.ETC1.value()) }
        if (format == RGB_ETC2_Format) { return Some(TextureFormat.ETC2.value()) }
        if (format == RGBA_ETC2_EAC_Format) { return Some(TextureFormat.ETC2A.value()) }

        // ASTC - bgfx 使用大写 X 命名（ASTC4X4 而非 ASTC4x4）
        if (format == RGBA_ASTC_4x4_Format) { return Some(TextureFormat.ASTC4X4.value()) }
        if (format == RGBA_ASTC_5x4_Format) { return Some(TextureFormat.ASTC5X4.value()) }
        if (format == RGBA_ASTC_5x5_Format) { return Some(TextureFormat.ASTC5X5.value()) }
        if (format == RGBA_ASTC_6x5_Format) { return Some(TextureFormat.ASTC6X5.value()) }
        if (format == RGBA_ASTC_6x6_Format) { return Some(TextureFormat.ASTC6X6.value()) }
        if (format == RGBA_ASTC_8x5_Format) { return Some(TextureFormat.ASTC8X5.value()) }
        if (format == RGBA_ASTC_8x6_Format) { return Some(TextureFormat.ASTC8X6.value()) }
        if (format == RGBA_ASTC_8x8_Format) { return Some(TextureFormat.ASTC8X8.value()) }
        if (format == RGBA_ASTC_10x5_Format) { return Some(TextureFormat.ASTC10X5.value()) }
        if (format == RGBA_ASTC_10x6_Format) { return Some(TextureFormat.ASTC10X6.value()) }
        if (format == RGBA_ASTC_10x8_Format) { return Some(TextureFormat.ASTC10X8.value()) }
        if (format == RGBA_ASTC_10x10_Format) { return Some(TextureFormat.ASTC10X10.value()) }
        if (format == RGBA_ASTC_12x10_Format) { return Some(TextureFormat.ASTC12X10.value()) }
        if (format == RGBA_ASTC_12x12_Format) { return Some(TextureFormat.ASTC12X12.value()) }

        // PVRTC - bgfx 不直接支持 PVRTC，返回 None
        // EAC - bgfx 没有 ETC2R/ETC2RG，使用 ETC2 近似
        if (format == R11_EAC_Format) { return Some(TextureFormat.ETC2.value()) }
        if (format == SIGNED_R11_EAC_Format) { return Some(TextureFormat.ETC2.value()) }
        if (format == RG11_EAC_Format) { return Some(TextureFormat.ETC2A.value()) }
        if (format == SIGNED_RG11_EAC_Format) { return Some(TextureFormat.ETC2A.value()) }

        return None
    }

    /**
     * @brief[zh-cn] 将 three.js 绘制模式转换为 bgfx 图元类型
     * @param[zh-cn] mode 绘制模式常量
     * @return[zh-cn] bgfx 图元类型标志位
     *
     * @brief[en] Convert three.js draw mode to bgfx primitive type
     * @param[en] mode Draw mode constant
     * @return[en] bgfx primitive type flag
     */
    public static func convertDrawMode(mode: Int64): UInt64 {
        if (mode == TrianglesDrawMode) { return 0u64 }  // 三角形列表（默认）
        if (mode == TriangleStripDrawMode) { return STATE_PT_TRISTRIP }
        if (mode == 3) { return STATE_PT_LINES }         // LinesDrawMode
        if (mode == 4) { return STATE_PT_LINESTRIP }     // LineStripDrawMode
        if (mode == 5) { return STATE_PT_POINTS }        // PointsDrawMode
        return 0u64
    }
}
