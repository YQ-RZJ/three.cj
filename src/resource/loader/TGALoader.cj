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
 * @file[zh-cn] TGALoader Targa 图片加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/TGALoader.js 的仓颉侧实现
 * @explain[zh-cn] Targa (TGA) 图片加载器：支持索引色/RGB/灰度及其 RLE 变体，8/16/24/32 位像素深度，输出 DataTexture（RGBA8）。仓颉侧使用 std 字节解析，无浏览器依赖。
 *
 * @file[en] TGALoader  Targa image loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/TGALoader.js
 * @explain[en] Targa (TGA) image loader: supports indexed/RGB/grayscale and their RLE variants, 8/16/24/32-bit pixel depth, outputting DataTexture (RGBA8). Cangjie side uses std byte parsing with no browser dependency.
 */
package three.resource.loader

import three.utils.constants.*
import three.rendering.textures.*
import std.collection.*
import std.fs.*
import std.io.*

// TGA 常量（对照 JS: TGALoader.js）
// 注意：必须用 const 声明 —— Cangjie 的 match 常量模式要求编译期常量，
//       let 常量会被当作变量绑定模式（无条件匹配第一个 case）。
internal const TGA_TYPE_NO_DATA = 0
internal const TGA_TYPE_INDEXED = 1
internal const TGA_TYPE_RGB = 2
internal const TGA_TYPE_GREY = 3
internal const TGA_TYPE_RLE_INDEXED = 9
internal const TGA_TYPE_RLE_RGB = 10
internal const TGA_TYPE_RLE_GREY = 11
internal const TGA_ORIGIN_MASK = 0x30
internal const TGA_ORIGIN_SHIFT = 0x04
internal const TGA_ORIGIN_BL = 0x00
internal const TGA_ORIGIN_BR = 0x01
internal const TGA_ORIGIN_UL = 0x02
internal const TGA_ORIGIN_UR = 0x03

/**
 * @brief[zh-cn] TGA 加载器，加载 Targa 格式图片为 DataTexture
 * @explain[zh-cn] 继承 DataTextureLoader，parse(buffer) 返回 texData。
 *
 * @brief[en] TGA loader, loads Targa format images as DataTexture
 * @explain[en] Extends DataTextureLoader, parse(buffer) returns texData.
 *
 * @extends DataTextureLoader
 */
public class TGALoader <: DataTextureLoader {
    public init(manager: LoadingManager) {
        super(manager)
    }

    public init() {
        super()
    }

    /**
     * @brief[zh-cn] 解析 TGA 字节数据
     * @explain[zh-cn] 解析 TGA 字节流，流程：读 18 字节头 → 校验 → RLE/调色板解析 → 按位深提取像素 → 返回 RGBA8。
     * @param[zh-cn] buffer .tga 文件字节
     * @return[zh-cn] texData（data=RGBA8/width/height/flipY/generateMipmaps/minFilter）
     *
     * @brief[en] Parse TGA byte data
     * @explain[en] Parses TGA byte stream. Flow: read 18-byte header → validate → RLE/palette parse → extract pixels by bit depth → return RGBA8.
     * @param[en] buffer .tga file bytes
     * @return[en] texData (data=RGBA8/width/height/flipY/generateMipmaps/minFilter)
     */
    public override func parse(buffer: Array<UInt8>): HashMap<String, Any> {
        let texData = HashMap<String, Any>()
        
        if (buffer.size < 19) {
            LoggerWarn("THREE.TGALoader: Not enough data to contain header.")
            return texData
        }

        
        var offset = 0
        let idLength = Int64(buffer[offset]); offset += 1
        let colormapType = Int64(buffer[offset]); offset += 1
        let imageType = Int64(buffer[offset]); offset += 1
        // colormap_index / colormap_length / origin / width / height（小端 16 位）
        let colormapIndex = _le16(buffer, offset); offset += 2
        let colormapLength = _le16(buffer, offset); offset += 2
        let colormapSize = Int64(buffer[offset]); offset += 1
        let originX = _le16(buffer, offset); offset += 2
        let originY = _le16(buffer, offset); offset += 2
        let width = _le16(buffer, offset); offset += 2
        let height = _le16(buffer, offset); offset += 2
        let pixelSize = Int64(buffer[offset]); offset += 1
        let flags = Int64(buffer[offset]); offset += 1

        
        // 注意：仓颉 match 的常量模式对顶层常量不可靠（可能被当作变量绑定），
        //       故改用 if-else 值比较，确保按 imageType 精确分发。
        if (imageType == TGA_TYPE_INDEXED || imageType == TGA_TYPE_RLE_INDEXED) {
            if (colormapLength > 256 || colormapSize != 24 || colormapType != 1) {
                LoggerWarn("THREE.TGALoader: Invalid type colormap data for indexed type.")
                return texData
            }
        } else if (imageType == TGA_TYPE_RGB || imageType == TGA_TYPE_GREY ||
                   imageType == TGA_TYPE_RLE_RGB || imageType == TGA_TYPE_RLE_GREY) {
            if (colormapType != 0) {
                LoggerWarn("THREE.TGALoader: Invalid type colormap data for colormap type.")
                return texData
            }
        } else if (imageType == TGA_TYPE_NO_DATA) {
            LoggerWarn("THREE.TGALoader: No data.")
            return texData
        } else {
            LoggerWarn("THREE.TGALoader: Invalid type " + imageType.toString())
            return texData
        }
        if (width <= 0 || height <= 0) {
            LoggerWarn("THREE.TGALoader: Invalid image size.")
            return texData
        }
        if (pixelSize != 8 && pixelSize != 16 && pixelSize != 24 && pixelSize != 32) {
            LoggerWarn("THREE.TGALoader: Invalid pixel size " + pixelSize.toString())
            return texData
        }

        // 跳过 id 段
        if (idLength + offset > buffer.size) {
            LoggerWarn("THREE.TGALoader: No data.")
            return texData
        }
        offset += idLength

        
        var useRle = false
        var usePal = false
        var useGrey = false
        if (imageType == TGA_TYPE_RLE_INDEXED) { useRle = true; usePal = true }
        else if (imageType == TGA_TYPE_INDEXED) { usePal = true }
        else if (imageType == TGA_TYPE_RLE_RGB) { useRle = true }
        else if (imageType == TGA_TYPE_RGB) { () }
        else if (imageType == TGA_TYPE_RLE_GREY) { useRle = true; useGrey = true }
        else if (imageType == TGA_TYPE_GREY) { useGrey = true }
        else { () }

        
        let pixelBytes = pixelSize >> 3
        let pixelTotal = width * height * pixelBytes

        var palettes = Array<UInt8>()
        if (usePal) {
            let palLen = colormapLength * (colormapSize >> 3)
            if (offset + palLen <= buffer.size) {
                let palStart = offset
                palettes = Array<UInt8>(palLen, { i => buffer[palStart + i] })
                offset += palLen
            }
        }

        // 像素数据（RLE 展开或原始拷贝）
        var pixelData = Array<UInt8>()
        if (useRle) {
            pixelData = Array<UInt8>(pixelTotal, { _ => 0u8 })
            var shift = 0
            let tmp = Array<UInt8>(pixelBytes, { _ => 0u8 })
            while (shift < pixelTotal && offset < buffer.size) {
                let c = Int64(buffer[offset]); offset += 1
                var count = (c & 0x7f) + 1
                if ((c & 0x80) != 0) {
                    // RLE 重复像素
                    for (i in 0..pixelBytes) {
                        if (offset < buffer.size) { tmp[i] = buffer[offset]; offset += 1 }
                    }
                    for (i in 0..count) {
                        for (j in 0..pixelBytes) {
                            if (shift + i * pixelBytes + j < pixelTotal) {
                                pixelData[shift + i * pixelBytes + j] = tmp[j]
                            }
                        }
                    }
                    shift += pixelBytes * count
                } else {
                    // 原始像素
                    count *= pixelBytes
                    for (i in 0..count) {
                        if (offset < buffer.size && shift + i < pixelTotal) {
                            pixelData[shift + i] = buffer[offset]
                        }
                        offset += 1
                    }
                    shift += count
                }
            }
        } else {
            let len = if (usePal) { width * height } else { pixelTotal }
            if (offset + len <= buffer.size) {
                let rawStart = offset
                pixelData = Array<UInt8>(len, { i => buffer[rawStart + i] })
            }
        }

        
        let imageData = Array<UInt8>(width * height * 4, { _ => 0u8 })
        let originMode = (flags & TGA_ORIGIN_MASK) >> TGA_ORIGIN_SHIFT

        var xStart = 0; var xStep = 1; var xEnd = width
        var yStart = 0; var yStep = 1; var yEnd = height
        match (originMode) {
            case TGA_ORIGIN_UL => ()
            case TGA_ORIGIN_BL => yStart = height - 1; yStep = -1; yEnd = -1
            case TGA_ORIGIN_UR => xStart = width - 1; xStep = -1; xEnd = -1
            case TGA_ORIGIN_BR => xStart = width - 1; xStep = -1; xEnd = -1; yStart = height - 1; yStep = -1; yEnd = -1
            case _ => ()
        }

        // 按位深提取（对照 JS: tgaGetImageDataXXbits）
        var i = 0
        if (useGrey) {
            if (pixelSize == 8) {
                for (y in _yIter(yStart, yStep, yEnd)) {
                    for (x in _xIter(xStart, xStep, xEnd)) {
                        let color = pixelData[i]; i += 1
                        let base = (x + width * y) * 4
                        if (base + 3 < imageData.size) {
                            imageData[base] = color
                            imageData[base + 1] = color
                            imageData[base + 2] = color
                            imageData[base + 3] = 255u8
                        }
                    }
                }
            } else if (pixelSize == 16) {
                for (y in _yIter(yStart, yStep, yEnd)) {
                    for (x in _xIter(xStart, xStep, xEnd)) {
                        let base = (x + width * y) * 4
                        if (base + 3 < imageData.size && i + 1 < pixelData.size) {
                            imageData[base] = pixelData[i]
                            imageData[base + 1] = pixelData[i]
                            imageData[base + 2] = pixelData[i]
                            imageData[base + 3] = pixelData[i + 1]
                        }
                        i += 2
                    }
                }
            }
        } else {
            if (pixelSize == 8 && usePal) {
                for (y in _yIter(yStart, yStep, yEnd)) {
                    for (x in _xIter(xStart, xStep, xEnd)) {
                        let colorIdx = Int64(pixelData[i]); i += 1
                        let base = (x + width * y) * 4
                        if (base + 3 < imageData.size) {
                            imageData[base] = palettes[colorIdx * 3 + 2]
                            imageData[base + 1] = palettes[colorIdx * 3 + 1]
                            imageData[base + 2] = palettes[colorIdx * 3 + 0]
                            imageData[base + 3] = 255u8
                        }
                    }
                }
            } else if (pixelSize == 16) {
                for (y in _yIter(yStart, yStep, yEnd)) {
                    for (x in _xIter(xStart, xStep, xEnd)) {
                        let color = Int64(pixelData[i]) + (Int64(pixelData[i + 1]) << 8); i += 2
                        let base = (x + width * y) * 4
                        if (base + 3 < imageData.size) {
                            imageData[base] = UInt8((color & 0x7C00) >> 7)
                            imageData[base + 1] = UInt8((color & 0x03E0) >> 2)
                            imageData[base + 2] = UInt8((color & 0x001F) << 3)
                            imageData[base + 3] = if ((color & 0x8000) != 0) { 0u8 } else { 255u8 }
                        }
                    }
                }
            } else if (pixelSize == 24) {
                for (y in _yIter(yStart, yStep, yEnd)) {
                    for (x in _xIter(xStart, xStep, xEnd)) {
                        let base = (x + width * y) * 4
                        if (base + 3 < imageData.size && i + 2 < pixelData.size) {
                            // TGA 像素存储顺序为 BGR
                            imageData[base] = pixelData[i + 2]
                            imageData[base + 1] = pixelData[i + 1]
                            imageData[base + 2] = pixelData[i + 0]
                            imageData[base + 3] = 255u8
                        }
                        i += 3
                    }
                }
            } else if (pixelSize == 32) {
                for (y in _yIter(yStart, yStep, yEnd)) {
                    for (x in _xIter(xStart, xStep, xEnd)) {
                        let base = (x + width * y) * 4
                        if (base + 3 < imageData.size && i + 3 < pixelData.size) {
                            // BGRA 顺序 → RGBA
                            imageData[base] = pixelData[i + 2]
                            imageData[base + 1] = pixelData[i + 1]
                            imageData[base + 2] = pixelData[i + 0]
                            imageData[base + 3] = pixelData[i + 3]
                        }
                        i += 4
                    }
                }
            }
        }

        
        texData.add("data", imageData)
        texData.add("width", Int64(width))
        texData.add("height", Int64(height))
        texData.add("flipY", true)
        texData.add("generateMipmaps", true)
        texData.add("minFilter", LinearMipmapLinearFilter)
        return texData
    }
}

// 读取小端 16 位
internal func _le16(data: Array<UInt8>, offset: Int64): Int64 {
    if (offset + 2 > data.size) { return 0 }
    return Int64(data[offset]) | (Int64(data[offset + 1]) << 8)
}

// Y 方向迭代序列（可能是递减）
internal func _yIter(start: Int64, step: Int64, end: Int64): Array<Int64> {
    let result = ArrayList<Int64>()
    var v = start
    if (step > 0) {
        while (v < end) { result.add(v); v += step }
    } else {
        while (v > end) { result.add(v); v += step }
    }
    return result.toArray()
}

// X 方向迭代序列
internal func _xIter(start: Int64, step: Int64, end: Int64): Array<Int64> {
    let result = ArrayList<Int64>()
    var v = start
    if (step > 0) {
        while (v < end) { result.add(v); v += step }
    } else {
        while (v > end) { result.add(v); v += step }
    }
    return result.toArray()
}
