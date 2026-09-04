/**
 * @file[zh-cn] EXRLoader OpenEXR 高清浮点纹理加载器
 * @brief[zh-cn] OpenEXR 高清浮点纹理加载器的仓颉侧实现
 * @explain[zh-cn] OpenEXR 高清浮点纹理加载器。JS 侧内置完整的 EXR 解析器（Huffman/RLE/ZIP 解压）；仓颉侧复用 bgfx4cj.tinyexr 子包的内存加载 API（ParseEXRHeaderFromMemory + LoadEXRImageFromMemory），将 planar 通道交织为 Float32 RGBA，输出 texData。
 *
 * @file[en] EXRLoader  OpenEXR HDR float texture loader
 * @brief[en] Cangjie implementation of OpenEXR HDR float texture loader
 * @explain[en] OpenEXR HDR float texture loader. JS side has a built-in EXR parser (Huffman/RLE/ZIP decompression); Cangjie side reuses bgfx4cj.tinyexr's memory loading API (ParseEXRHeaderFromMemory + LoadEXRImageFromMemory), interleave planar channels to Float32 RGBA, outputting texData.
 */
package three.resource.loader

import three.utils.constants.*
import three.rendering.textures.*
import three.rendering.geometry.DataUtils
import three.utils.log.Logger
import three.utils.memory.AutoFreePtr
import bgfx4cj.tinyexr.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] EXR 加载器，加载 OpenEXR 格式的 HDR 纹理
 * @explain[zh-cn] 继承 DataTextureLoader。通过 tinyexr 解析内存中的 EXR 字节流，输出 Float32 RGBA texData。
 *
 * @brief[en] EXR loader, loads OpenEXR format HDR textures
 * @explain[en] Extends DataTextureLoader. Parses EXR byte streams in memory via tinyexr, outputting Float32 RGBA texData.
 *
 * @extends DataTextureLoader
 */
public class EXRLoader <: DataTextureLoader {
    /** 输出数据类型（默认 FloatType；JS 侧支持 FloatType/HalfFloatType） */
    public var `type`: Int64

    public init(manager: LoadingManager) {
        super(manager)
        this.`type` = FloatType
    }

    public init() {
        super()
        this.`type` = FloatType
    }

    /**
     * @param[zh-cn] value FloatType 或 HalfFloatType
     * @return[zh-cn] 自身引用
     *
     * @param[en] value FloatType or HalfFloatType
     * @return[en] Self reference
     *
     * 设置纹理数据类型
     */
    public func setDataType(value: Int64): EXRLoader {
        this.`type` = value
        return this
    }

    /**
     * @param[zh-cn] buffer .exr 文件字节
     * @return[zh-cn] texData（width/height/data/type），解析失败返回空 HashMap
     *
     * @param[en] buffer .exr file bytes
     * @return[en] texData (width/height/data/type), returns empty HashMap on parse failure
     *
     * 解析 EXR 字节数据
     * 仓颉侧基于 bgfx4cj.tinyexr：
     * ParseEXRHeaderFromMemory_cj 解析头 → 请求 FLOAT 像素类型 →
     * LoadEXRImageFromMemory_cj 加载图像 → 各 planar 通道交织为 RGBA → Free* 释放。
     */
    public override func parse(buffer: Array<UInt8>): HashMap<String, Any> {
        let texData = HashMap<String, Any>()
        if (buffer.size < 8) { return texData }
        
        let magic = UInt32(buffer[0]) | (UInt32(buffer[1]) << 8) | (UInt32(buffer[2]) << 16) | (UInt32(buffer[3]) << 24)
        if (magic != 0x013f2a76u32) {
            Logger.debug(["EXRLoader", "invalid magic"])
            return texData
        }

        // 分配 tinyexr 输入/输出结构
        let headerHolder = AutoFreePtr<EXRHeader>(unsafe { LibC.malloc<EXRHeader>() })
        let versionHolder = AutoFreePtr<EXRVersion>(unsafe { LibC.malloc<EXRVersion>() })
        let imageHolder = AutoFreePtr<EXRImage>(unsafe { LibC.malloc<EXRImage>() })
        let errHolder = AutoFreePtr<CString>(unsafe { LibC.malloc<CString>() })
        let dataHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(buffer.size)) })
        let dataPtr = dataHolder.get()
        unsafe {
            for (i in 0..buffer.size) { (dataPtr + i).write(buffer[i]) }
        }
        unsafe {
            headerHolder.get().write(EXRHeader())
            versionHolder.get().write(EXRVersion())
            imageHolder.get().write(EXRImage())
        }

        // 1. 解析头部
        let ret1 = ParseEXRHeaderFromMemory_cj(
            CPointer<EXRHeader>(headerHolder.get()),
            CPointer<EXRVersion>(versionHolder.get()),
            CPointer<UInt8>(dataPtr),
            UIntNative(buffer.size),
            CPointer<CString>(errHolder.get())
        )
        if (ret1 != 0) {
            _freeEXRError(errHolder.get())
            dataHolder.dispose(); headerHolder.dispose(); versionHolder.dispose(); imageHolder.dispose(); errHolder.dispose()
            return texData
        }

        // 2. 请求 FLOAT 像素类型（对照 tinyexr 示例：requested_pixel_types 全设 FLOAT）
        let headerRef = unsafe { headerHolder.get().read() }
        let numChannels = headerRef.num_channels
        if (numChannels <= 0) {
            dataHolder.dispose(); headerHolder.dispose(); versionHolder.dispose(); imageHolder.dispose(); errHolder.dispose()
            return texData
        }
        let reqTypesHolder = AutoFreePtr<Int32>(unsafe { LibC.malloc<Int32>(count: Int64(numChannels)) })
        unsafe {
            let reqPtr = reqTypesHolder.get()
            for (i in 0..Int64(numChannels)) { (reqPtr + i).write(TINYEXR_PIXELTYPE_FLOAT) }
            // 写入 header.requested_pixel_types（先 read 到 var 再 write 回填）
            var hdr = CPointer<EXRHeader>(headerHolder.get()).read()
            hdr.requested_pixel_types = reqPtr
            CPointer<EXRHeader>(headerHolder.get()).write(hdr)
        }

        // 3. 初始化 image 并加载
        InitEXRImage_cj(CPointer<EXRImage>(imageHolder.get()))
        let ret2 = LoadEXRImageFromMemory_cj(
            CPointer<EXRImage>(imageHolder.get()),
            CPointer<EXRHeader>(headerHolder.get()),
            CPointer<UInt8>(dataPtr),
            UIntNative(buffer.size),
            CPointer<CString>(errHolder.get())
        )
        dataHolder.dispose()
        if (ret2 != 0) {
            _freeEXRError(errHolder.get())
            FreeEXRHeader_cj(CPointer<EXRHeader>(headerHolder.get()))
            reqTypesHolder.dispose(); headerHolder.dispose(); versionHolder.dispose(); imageHolder.dispose(); errHolder.dispose()
            return texData
        }

        let img = unsafe { imageHolder.get().read() }
        let w = Int64(img.width)
        let h = Int64(img.height)
        let channels = Int64(img.num_channels)
        if (w <= 0 || h <= 0 || channels <= 0 || img.images.isNull()) {
            FreeEXRImage_cj(CPointer<EXRImage>(imageHolder.get()))
            FreeEXRHeader_cj(CPointer<EXRHeader>(headerHolder.get()))
            reqTypesHolder.dispose(); headerHolder.dispose(); versionHolder.dispose(); imageHolder.dispose(); errHolder.dispose()
            return texData
        }

        // 4. planar 通道交织为 RGBA（对照 JS EXRLoader 输出 Float32 RGBA）
        let numPixels = w * h
        // 只取前 4 通道（R/G/B/A），超出部分忽略
        let comps = if (channels >= 4) { 4 } else { channels }
        let floatData = Array<Float32>(numPixels * 4, { _ => 0.0f32 })
        unsafe {
            for (c in 0..comps) {
                let chanPtr = (img.images + c).read()
                if (!chanPtr.isNull()) {
                    let fPtr = CPointer<Float32>(CPointer<Unit>(chanPtr))
                    for (i in 0..numPixels) {
                        floatData[i * 4 + c] = (fPtr + i).read()
                    }
                }
            }
            // 缺失通道补默认值：RGB 缺失补 0，Alpha 缺失补 1
            if (comps == 3) {
                for (i in 0..numPixels) { floatData[i * 4 + 3] = 1.0f32 }
            }
        }

        // 5. 释放 tinyexr 资源
        FreeEXRImage_cj(CPointer<EXRImage>(imageHolder.get()))
        FreeEXRHeader_cj(CPointer<EXRHeader>(headerHolder.get()))
        reqTypesHolder.dispose(); headerHolder.dispose(); versionHolder.dispose(); imageHolder.dispose(); errHolder.dispose()

        // 按 type 转换：FloatType 直接输出 F32 字节；HalfFloatType 转半精度
        var data = Array<UInt8>()
        if (this.`type` == HalfFloatType) {
            data = Array<UInt8>(numPixels * 4 * 2, { _ => 0u8 })
            for (i in 0..(numPixels * 4)) {
                _writeUInt16LE(data, i * 2, DataUtils.toHalfFloat(Float64(floatData[i])))
            }
        } else {
            data = Array<UInt8>(numPixels * 4 * 4, { _ => 0u8 })
            for (i in 0..(numPixels * 4)) {
                _writeFloat32LE(data, i * 4, floatData[i])
            }
        }

        
        texData.add("width", w)
        texData.add("height", h)
        texData.add("data", data)
        texData.add("type", this.`type`)
        texData.add("colorSpace", LinearSRGBColorSpace)
        texData.add("minFilter", LinearFilter)
        texData.add("magFilter", LinearFilter)
        texData.add("generateMipmaps", false)
        texData.add("flipY", false)
        return texData
    }
}

// 释放 tinyexr 错误消息（如有）
internal func _freeEXRError(errPtr: CPointer<CString>): Unit {
    let msg = unsafe { errPtr.read() }
    if (!msg.isNull()) {
        FreeEXRErrorMessage_cj(msg)
    }
}
