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
 * @file[zh-cn] KTXLoader Khronos Texture 压缩纹理加载器
 * @brief[zh-cn] Khronos Texture (KTX) 压缩纹理加载器的仓颉侧实现
 * @explain[zh-cn] Khronos Texture (KTX) 压缩纹理加载器。仓颉侧复用 bgfx4cj.bimg 子包的 bimg_image_parse_ktx_cj 解析 KTX 字节流，提取宽度/高度/格式/各 mip 层数据。
 *
 * @file[en] KTXLoader  Khronos Texture compressed texture loader
 * @brief[en] Cangjie implementation of Khronos Texture (KTX) compressed texture loader
 * @explain[en] Khronos Texture (KTX) compressed texture loader. Cangjie side reuses bgfx4cj.bimg's bimg_image_parse_ktx_cj to parse KTX byte streams, extracting width/height/format/mipmap data.
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
 * @brief[zh-cn] KTX 压缩纹理加载器
 * @explain[zh-cn] 继承 CompressedTextureLoader。通过 bimg 解析 KTX 文件（支持 ETC1/ETC2/ASTC 等格式）。
 *
 * @brief[en] KTX compressed texture loader
 * @explain[en] Extends CompressedTextureLoader. Parses KTX files via bimg (supports ETC1/ETC2/ASTC etc.).
 *
 * @extends CompressedTextureLoader
 */
public class KTXLoader <: CompressedTextureLoader {
    public init(manager: LoadingManager) {
        super(manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] buffer KTX 文件字节
     * @param[zh-cn] isCubemap 是否按立方体贴图解析
     * @return[zh-cn] texData（width/height/format/mipmaps/mipmapCount）
     *
     * @param[en] buffer KTX file bytes
     * @param[en] isCubemap Whether to parse as cubemap
     * @return[en] texData (width/height/format/mipmaps/mipmapCount)
     *
     * 解析 KTX 字节数据
     * 仓颉侧基于 bgfx4cj.bimg 的 parse_ktx 解析（复用 DDSLoader 的容器提取逻辑）。
     */
    public override func parse(buffer: Array<UInt8>, isCubemap: Bool): HashMap<String, Any> {
        let texData = HashMap<String, Any>()

        
        if (buffer.size < 12) { return texData }
        let magic = UInt32(buffer[0]) | (UInt32(buffer[1]) << 8) | (UInt32(buffer[2]) << 16) | (UInt32(buffer[3]) << 24)
        if (magic != 0xAB4B5458u32) {
            @LogDebug(["KTXLoader", "invalid magic"])
            return texData
        }

        // 基于 bgfx4cj.bimg：解析 KTX 到 ImageContainer
        let allocator = bimg_get_default_allocator_cj()
        let dataPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(buffer.size)) })
        let dataPtr = dataPtrHolder.get()
        unsafe {
            for (i in 0..buffer.size) { (dataPtr + i).write(buffer[i]) }
        }
        let ic = bimg_image_parse_ktx_cj(allocator, unsafe { CPointer<Unit>(dataPtr) }, UInt32(buffer.size), CPointer<BimgError>())
        dataPtrHolder.dispose()
        if (ic.isNull()) {
            @LogDebug(["KTXLoader", "parse_ktx failed"])
            return texData
        }

        let result = _containerToCompressedTexData(ic, isCubemap)
        
        bimg_image_free_cj(ic)
        return result
    }
}
