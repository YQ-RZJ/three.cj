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
 * @file[zh-cn] PVRLoader PowerVR 压缩纹理加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/PVRLoader.js 的仓颉侧实现
 * @explain[zh-cn] PowerVR (PVR) 压缩纹理加载器。仓颉侧复用 bgfx4cj.bimg 子包的 bimg_image_parse_pvr3_cj 解析 PVR v3 字节流，提取宽度/高度/格式/各 mip 层数据。
 *
 * @file[en] PVRLoader  PowerVR compressed texture loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/PVRLoader.js
 * @explain[en] PowerVR (PVR) compressed texture loader. Cangjie side reuses bgfx4cj.bimg's bimg_image_parse_pvr3_cj to parse PVR v3 byte streams, extracting width/height/format/mipmap data.
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
 * @brief[zh-cn] PVR 压缩纹理加载器
 * @explain[zh-cn] 继承 CompressedTextureLoader，通过 bimg 解析 PVR v3 文件（支持 PVRTC1/PVRTC2 等格式）。
 *
 * @brief[en] PVR compressed texture loader
 * @explain[en] Extends CompressedTextureLoader. Parses PVR v3 files via bimg (supports PVRTC1/PVRTC2 etc.).
 *
 * @extends CompressedTextureLoader
 */
public class PVRLoader <: CompressedTextureLoader {
    public init(manager: LoadingManager) {
        super(manager)
    }

    public init() {
        super()
    }

    /**
     * @brief[zh-cn] 解析 PVR 字节数据
     * @explain[zh-cn] 基于 bgfx4cj.bimg 的 parse_pvr3 解析（复用 DDSLoader 的容器提取逻辑），返回 TexData。
     * @param[zh-cn] buffer PVR 文件字节
     * isCubemap 是否按立方体贴图解析
     * @return[zh-cn] texData（width/height/format/mipmaps/mipmapCount）
     *
     * @brief[en] Parse PVR byte data
     * @explain[en] Parses via bgfx4cj.bimg's parse_pvr3 (reusing DDSLoader's container extraction logic), returns TexData.
     * @param[en] buffer PVR file bytes
     * isCubemap Whether to parse as cubemap
     * @return[en] texData (width/height/format/mipmaps/mipmapCount)
     */
    public override func parse(buffer: Array<UInt8>, isCubemap: Bool): HashMap<String, Any> {
        let texData = HashMap<String, Any>()

        
        if (buffer.size < 4) { return texData }
        let version = UInt32(buffer[0]) | (UInt32(buffer[1]) << 8) | (UInt32(buffer[2]) << 16) | (UInt32(buffer[3]) << 24)
        if (version != 0x03525650u32) {
            @LogDebug(["PVRLoader", "invalid version"])
            return texData
        }

        // 基于 bgfx4cj.bimg：解析 PVR v3 到 ImageContainer
        let allocator = bimg_get_default_allocator_cj()
        let dataPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(buffer.size)) })
        let dataPtr = dataPtrHolder.get()
        unsafe {
            for (i in 0..buffer.size) { (dataPtr + i).write(buffer[i]) }
        }
        let ic = bimg_image_parse_pvr3_cj(allocator, unsafe { CPointer<Unit>(dataPtr) }, UInt32(buffer.size), CPointer<BimgError>())
        dataPtrHolder.dispose()
        if (ic.isNull()) {
            @LogDebug(["PVRLoader", "parse_pvr3 failed"])
            return texData
        }

        let result = _containerToCompressedTexData(ic, isCubemap)
        
        bimg_image_free_cj(ic)
        return result
    }
}
