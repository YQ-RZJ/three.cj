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
 * @file[zh-cn] DDSLoader S3TC 压缩纹理加载器
 * @brief[zh-cn] S3TC (DDS) 压缩纹理加载器的仓颉侧实现
 * @explain[zh-cn] S3TC (DDS) 压缩纹理加载器。仓颉侧复用 bgfx4cj.bimg 子包的 bimg_image_parse_dds_cj 解析 DDS 字节流，提取宽度/高度/格式/各 mip 层数据。
 *
 * @file[en] DDSLoader  S3TC compressed texture loader
 * @brief[en] Cangjie implementation of S3TC (DDS) compressed texture loader
 * @explain[en] S3TC (DDS) compressed texture loader. Cangjie side reuses bgfx4cj.bimg's bimg_image_parse_dds_cj to parse DDS byte streams, extracting width/height/format/mipmap data.
 *
 * @extends CompressedTextureLoader
 */
package three.resource.loader

import three.utils.constants.*
import three.rendering.textures.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.AutoFreePtr
import bgfx4cj.bimg.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] S3TC 压缩纹理加载器
 * @explain[zh-cn] 继承 CompressedTextureLoader。通过 bimg 解析 DDS 文件（支持 DXT1/DXT3/DXT5/ETC1 等格式），返回 texData（width/height/format/mipmaps），由 CompressedTextureLoader.load 应用。
 *
 * @brief[en] S3TC compressed texture loader
 * @explain[en] Extends CompressedTextureLoader. Parses DDS files via bimg (supports DXT1/DXT3/DXT5/ETC1 etc.), returning texData (width/height/format/mipmaps) applied by CompressedTextureLoader.load.
 *
 * @extends CompressedTextureLoader
 */
public class DDSLoader <: CompressedTextureLoader {
    public init(manager: LoadingManager) {
        super(manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] buffer DDS 文件字节
     * @param[zh-cn] isCubemap 是否按立方体贴图解析（bimg parse_dds 自动识别 cubemap 面）
     * @return[zh-cn] texData（width/height/format/mipmaps/mipmapCount）
     *
     * @param[en] buffer DDS file bytes
     * @param[en] isCubemap Whether to parse as cubemap (bimg parse_dds auto-detects cubemap faces)
     * @return[en] texData (width/height/format/mipmaps/mipmapCount)
     *
     * 解析 DDS 字节数据
     * 仓颉侧基于 bgfx4cj.bimg 的 parse_dds 解析：
     * 复用 GltfLoader 的 bimg 调用范式（allocator → parse → 读取 ImageContainer → free）。
     */
    public override func parse(buffer: Array<UInt8>, isCubemap: Bool): HashMap<String, Any> {
        let texData = HashMap<String, Any>()

        
        if (buffer.size < 4) { return texData }
        let magic = UInt32(buffer[0]) | (UInt32(buffer[1]) << 8) | (UInt32(buffer[2]) << 16) | (UInt32(buffer[3]) << 24)
        if (magic != 0x20534444u32) {
            @LogDebug(["DDSLoader", "invalid magic"])
            return texData
        }

        // 基于 bgfx4cj.bimg：解析 DDS 到 ImageContainer
        let allocator = bimg_get_default_allocator_cj()
        let dataPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(buffer.size)) })
        let dataPtr = dataPtrHolder.get()
        unsafe {
            for (i in 0..buffer.size) { (dataPtr + i).write(buffer[i]) }
        }
        let ic = bimg_image_parse_dds_cj(allocator, unsafe { CPointer<Unit>(dataPtr) }, UInt32(buffer.size), CPointer<BimgError>())
        dataPtrHolder.dispose()
        if (ic.isNull()) {
            @LogDebug(["DDSLoader", "parse_dds failed"])
            return texData
        }

        let result = _containerToCompressedTexData(ic, isCubemap)
        
        bimg_image_free_cj(ic)
        return result
    }
}

// 将 bimg ImageContainer 提取为 texData（width/height/format/mipmaps/mipmapCount）
// 供 DDSLoader/KTXLoader/PVRLoader 等 CompressedTextureLoader 子类复用
internal func _containerToCompressedTexData(ic: CPointer<ImageContainer>, isCubemap: Bool): HashMap<String, Any> {
    let texData = HashMap<String, Any>()
    let imgWidth = bimg_ic_get_width_cj(ic)
    let imgHeight = bimg_ic_get_height_cj(ic)
    let imgFormat = bimg_ic_get_format_cj(ic)
    let numMips = bimg_ic_get_num_mips_cj(ic)
    let imgData = bimg_ic_get_data_cj(ic)
    let imgSize = bimg_ic_get_size_cj(ic)
    let isCube = bimg_ic_get_cube_map_cj(ic)

    
    texData.add("width", Int64(imgWidth))
    texData.add("height", Int64(imgHeight))
    texData.add("format", _bimgFormatToThree(imgFormat))
    texData.add("mipmapCount", Int64(numMips))
    texData.add("isCubemap", isCube || isCubemap)

    // 提取各 mip 层数据（bimg 容器内按 mip 顺序连续存放）
    let faces = if (isCube || isCubemap) { 6 } else { 1 }
    let mipmaps = ArrayList<Any>()
    let blockBytes = _blockBytesForFormat(imgFormat)
    var w = Int64(imgWidth)
    var h = Int64(imgHeight)
    var offset = 0
    for (_ in 0..Int64(numMips)) {
        // 压缩格式按 4x4 块对齐；未压缩格式按行对齐
        var mipSize = 0
        if (blockBytes > 0) {
            let bw = (w + 3) / 4
            let bh = (h + 3) / 4
            mipSize = bw * bh * blockBytes
        } else {
            mipSize = w * h * 4
        }
        // 每个面各有一份该 mip
        for (_ in 0..faces) {
            if (offset + mipSize <= Int64(imgSize)) {
                let mip = HashMap<String, Any>()
                mip.add("width", w)
                mip.add("height", h)
                let off = offset
                let data = Array<UInt8>(mipSize, { i =>
                    unsafe { (CPointer<UInt8>(imgData) + Int64(off) + i).read() }
                })
                mip.add("data", data)
                mipmaps.add(mip)
            }
            offset += mipSize
        }
        w = (w + 1) / 2
        h = (h + 1) / 2
        if (w < 1) { w = 1 }
        if (h < 1) { h = 1 }
    }
    texData.add("mipmaps", mipmaps)
    return texData
}

// bimg TextureFormat 枚举 → three 压缩格式常量
// 注意：新版 bimg 重排了 TextureFormat 枚举（插入 BC4S/BC5S/BC6HU 等），ETC1=10、ETC2=11、ETC2A=12，
// 旧映射（ETC1=7 等）已失效，统一通过 bgfx4cj.bimg.TextureFormat 枚举取值，避免魔法数字。
internal func _bimgFormatToThree(format: UInt32): Int64 {
    return match (TextureFormat.fromValue(format)) {
        case TextureFormat.BC1 => RGB_S3TC_DXT1_Format      // BC1 / DXT1
        case TextureFormat.BC2 => RGBA_S3TC_DXT3_Format     // BC2 / DXT3
        case TextureFormat.BC3 => RGBA_S3TC_DXT5_Format     // BC3 / DXT5
        case TextureFormat.ETC1 => RGB_ETC1_Format           // ETC1
        case TextureFormat.ETC2 => RGB_ETC2_Format           // ETC2
        case TextureFormat.ETC2A => RGBA_ETC2_EAC_Format      // ETC2A
        case _ => RGBAFormat                   // 未知格式回退 RGBA
    }
}

// 各压缩格式的块字节数（mip 数据大小计算用），非压缩返回 0
internal func _blockBytesForFormat(format: UInt32): Int64 {
    return match (TextureFormat.fromValue(format)) {
        case TextureFormat.BC1 => 8                           // BC1 / DXT1
        case TextureFormat.BC2 => 16                          // BC2 / DXT3
        case TextureFormat.BC3 => 16                          // BC3 / DXT5
        case TextureFormat.ETC1 => 8                          // ETC1
        case TextureFormat.ETC2 => 8                          // ETC2
        case TextureFormat.ETC2A => 16                        // ETC2A
        case _ => 0                                           // 非压缩格式
    }
}
