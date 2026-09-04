/**
 * @file[zh-cn] HDRLoader Radiance RGBE HDR 加载器
 * @brief[zh-cn] Radiance RGBE HDR 加载器的仓颉侧实现
 * @explain[zh-cn] Radiance RGBE HDR 格式加载器。解析流程：RGBE_ReadHeader → RGBE_ReadPixels_RLE → RGBEByteToRGBFloat/Half。输出 texData，由 DataTextureLoader 应用。
 *
 * @file[en] HDRLoader  Radiance RGBE HDR loader
 * @brief[en] Cangjie implementation of Radiance RGBE HDR loader
 * @explain[en] Radiance RGBE HDR format loader. Parse flow: RGBE_ReadHeader → RGBE_ReadPixels_RLE → RGBEByteToRGBFloat/Half. Outputs texData applied by DataTextureLoader.
 */
package three.resource.loader

import three.utils.constants.*
import three.rendering.textures.*
import three.rendering.geometry.DataUtils
import three.utils.log.Logger
import three.utils.memory.AutoFreePtr
import std.collection.*
import std.convert.*
import std.fs.*
import std.io.*
import std.math.*

/**
 * @brief[zh-cn] Radiance RGBE HDR 加载器
 * @explain[zh-cn] 继承 DataTextureLoader。支持 32-bit_rle_rgbe 格式的 RLE 与 flat 两种编码。
 *
 * @brief[en] Radiance RGBE HDR loader
 * @explain[en] Extends DataTextureLoader (formerly RGBELoader). Supports 32-bit_rle_rgbe format with RLE and flat encoding.
 *
 * @extends DataTextureLoader
 */
public open class HDRLoader <: DataTextureLoader {
    /** 输出纹理数据类型（默认 FloatType；JS 默认 HalfFloatType，仓颉侧 DataTexture 用 Float64 字节流承载） */
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
    public func setDataType(value: Int64): HDRLoader {
        this.`type` = value
        return this
    }

    /**
     * @param[zh-cn] buffer .hdr 文件字节
     * @return[zh-cn] texData（width/height/data/header/gamma/exposure/type/colorSpace/filters）
     *
     * @param[en] buffer .hdr file bytes
     * @return[en] texData (width/height/data/header/gamma/exposure/type/colorSpace/filters)
     *
     * 解析 RGBE HDR 字节数据
     */
    public override func parse(buffer: Array<UInt8>): HashMap<String, Any> {
        let texData = HashMap<String, Any>()
        var pos = 0

        
        let firstLine = _readLine(buffer, pos)
        match (firstLine) {
            case Some((line, nextPos)) =>
                pos = nextPos
                if (!line.startsWith("#?")) {
                    LoggerWarn("THREE.HDRLoader: bad initial token")
                    return texData
                }
            case None =>
                LoggerWarn("THREE.HDRLoader: no header found")
                return texData
        }

        
        var gamma = 1.0
        var exposure = 1.0
        var formatOk = false
        var dimOk = false
        var width = 0
        var height = 0
        while (pos < buffer.size) {
            let lineRes = _readLine(buffer, pos)
            match (lineRes) {
                case Some((line, nextPos)) =>
                    pos = nextPos
                    // 注释行：跳过
                    if (line.startsWith("#")) {
                        ()
                    } else if (line.startsWith("GAMMA=")) {
                        
                        gamma = _parseFloatOpt(line[6..].trimAscii())
                    } else if (line.startsWith("EXPOSURE=")) {
                        
                        exposure = _parseFloatOpt(line[9..].trimAscii())
                    } else if (line.startsWith("FORMAT=")) {
                        
                        formatOk = true
                    } else if (line.startsWith("-Y")) {
                        
                        let parts = _splitWhitespaceHDR(line)
                        if (parts.size >= 4) {
                            height = _parseIntOpt(parts[1])
                            width = _parseIntOpt(parts[3])
                            dimOk = true
                        }
                    }
                case None => break
            }
            
            if (formatOk && dimOk) { break }
        }

        if (!formatOk || !dimOk) {
            LoggerWarn("THREE.HDRLoader: missing format or image size specifier")
            return texData
        }

        
        let rgba = _readPixelsRLE(buffer, pos, width, height)
        if (rgba.size == 0) { return texData }

        
        let numElements = rgba.size / 4
        var data = Array<UInt8>()
        if (this.`type` == FloatType) {
            // FloatType：每像素 4 个 Float32（对照 JS Float32Array）→ 按字节承载
            data = Array<UInt8>(numElements * 4 * 4, { _ => 0u8 })
            for (j in 0..numElements) {
                let e = Float64(rgba[j * 4 + 3])
                let scale = pow(2.0, e - 128.0) / 255.0
                let r = Float32(Float64(rgba[j * 4 + 0]) * scale)
                let g = Float32(Float64(rgba[j * 4 + 1]) * scale)
                let b = Float32(Float64(rgba[j * 4 + 2]) * scale)
                let a = 1.0f32
                _writeFloat32LE(data, j * 4 * 4, r)
                _writeFloat32LE(data, j * 4 * 4 + 4, g)
                _writeFloat32LE(data, j * 4 * 4 + 8, b)
                _writeFloat32LE(data, j * 4 * 4 + 12, a)
            }
        } else {
            // HalfFloatType：每像素 4 个 UInt16 半精度
            data = Array<UInt8>(numElements * 4 * 2, { _ => 0u8 })
            for (j in 0..numElements) {
                let e = Float64(rgba[j * 4 + 3])
                let scale = pow(2.0, e - 128.0) / 255.0
                let r = min(Float64(rgba[j * 4 + 0]) * scale, 65504.0)
                let g = min(Float64(rgba[j * 4 + 1]) * scale, 65504.0)
                let b = min(Float64(rgba[j * 4 + 2]) * scale, 65504.0)
                _writeUInt16LE(data, j * 4 * 2, DataUtils.toHalfFloat(r))
                _writeUInt16LE(data, j * 4 * 2 + 2, DataUtils.toHalfFloat(g))
                _writeUInt16LE(data, j * 4 * 2 + 4, DataUtils.toHalfFloat(b))
                _writeUInt16LE(data, j * 4 * 2 + 6, DataUtils.toHalfFloat(1.0))
            }
        }

        
        texData.add("width", Int64(width))
        texData.add("height", Int64(height))
        texData.add("data", data)
        texData.add("gamma", gamma)
        texData.add("exposure", exposure)
        texData.add("type", this.`type`)
        texData.add("colorSpace", LinearSRGBColorSpace)
        texData.add("minFilter", LinearFilter)
        texData.add("magFilter", LinearFilter)
        texData.add("generateMipmaps", false)
        texData.add("flipY", true)
        return texData
    }

    
    private func _readPixelsRLE(buffer: Array<UInt8>, start: Int64, w: Int64, h: Int64): Array<UInt8> {
        var pos = start
        
        let scanlineWidth = w
        let notRLE = (scanlineWidth < 8 || scanlineWidth > 0x7fff) ||
            (pos + 4 > buffer.size) ||
            (buffer[pos] != 2u8 || buffer[pos + 1] != 2u8 || (buffer[pos + 2] & 0x80u8) != 0u8)
        if (notRLE) {
            // 平坦数据：直接返回剩余字节
            let len = buffer.size - Int64(pos)
            let flatPos = pos
            return Array<UInt8>(len, { i => buffer[flatPos + i] })
        }

        
        let encWidth = (Int64(buffer[pos + 2]) << 8) | Int64(buffer[pos + 3])
        if (encWidth != scanlineWidth) {
            LoggerWarn("THREE.HDRLoader: wrong scanline width")
            return Array<UInt8>()
        }
        pos += 4

        let dataRGBA = Array<UInt8>(4 * w * h, { _ => 0u8 })
        let ptrEnd = 4 * scanlineWidth
        let scanlineBuffer = Array<UInt8>(ptrEnd, { _ => 0u8 })
        var numScanlines = h
        var offset = 0

        while ((numScanlines > 0) && (pos < buffer.size)) {
            if (pos + 4 > buffer.size) { return Array<UInt8>() }
            let s0 = buffer[pos]; let s1 = buffer[pos + 1]; let s2 = buffer[pos + 2]; let s3 = buffer[pos + 3]
            pos += 4
            if (s0 != 2u8 || s1 != 2u8 || (((Int64(s2) << 8) | Int64(s3)) != scanlineWidth)) {
                LoggerWarn("THREE.HDRLoader: bad rgbe scanline format")
                return Array<UInt8>()
            }

            var ptr = 0
            while ((ptr < ptrEnd) && (pos < buffer.size)) {
                var count = Int64(buffer[pos]); pos += 1
                let isEncodedRun = count > 128
                if (isEncodedRun) { count -= 128 }
                if (count == 0 || ptr + count > ptrEnd) {
                    LoggerWarn("THREE.HDRLoader: bad scanline data")
                    return Array<UInt8>()
                }
                if (isEncodedRun) {
                    let byteValue = buffer[pos]; pos += 1
                    for (i in 0..count) {
                        scanlineBuffer[ptr] = byteValue
                        ptr += 1
                    }
                } else {
                    for (i in 0..count) {
                        if (pos >= buffer.size) { return Array<UInt8>() }
                        scanlineBuffer[ptr] = buffer[pos]
                        ptr += 1
                        pos += 1
                    }
                }
            }

            
            let l = scanlineWidth
            for (i in 0..l) {
                dataRGBA[offset] = scanlineBuffer[i]
                dataRGBA[offset + 1] = scanlineBuffer[i + scanlineWidth]
                dataRGBA[offset + 2] = scanlineBuffer[i + scanlineWidth * 2]
                dataRGBA[offset + 3] = scanlineBuffer[i + scanlineWidth * 3]
                offset += 4
            }
            numScanlines -= 1
        }
        return dataRGBA
    }
}

// ===== 辅助函数 =====

// 读取一行（\n 结尾），返回 (行内容, 下一位置)；无更多行返回 None
internal func _readLine(buffer: Array<UInt8>, start: Int64): Option<(String, Int64)> {
    if (start >= buffer.size) { return None }
    var end = start
    while (end < buffer.size && buffer[end] != 10u8) { end += 1 }
    let lineBytes = Array<UInt8>(end - start, { i => buffer[start + i] })
    let line = String.fromUtf8(lineBytes)
    return Some((line, end + 1))
}

internal func LoggerWarn(msg: String): Unit {
    Logger.warn([msg])
}

// 按空白分割（HDR 头尺寸行用）
internal func _splitWhitespaceHDR(s: String): ArrayList<String> {
    let result = ArrayList<String>()
    var cur = ""
    var inToken = false
    for (ch in s.toRuneArray()) {
        if (ch == r' ' || ch == r'\t') {
            if (inToken) { result.add(cur); cur = ""; inToken = false }
        } else {
            cur = cur + ch.toString()
            inToken = true
        }
    }
    if (inToken) { result.add(cur) }
    return result
}

internal func _parseFloatOpt(s: String): Float64 {
    let t = s.trimAscii()
    if (t == "") { return 0.0 }
    try { return Float64.parse(t) } catch (_: Exception) { return 0.0 }
}

internal func _parseIntOpt(s: String): Int64 {
    let t = s.trimAscii()
    if (t == "") { return 0 }
    try { return Int64.parse(t) } catch (_: Exception) { return 0 }
}

// 写入小端 Float32 位模式
internal func _writeFloat32LE(dst: Array<UInt8>, offset: Int64, v: Float32): Unit {
    let bits = unsafe {
        let holder = AutoFreePtr<Float32>(LibC.malloc<Float32>())
        holder.get().write(v)
        let u32 = CPointer<UInt32>(holder.get()).read()
        holder.dispose()
        u32
    }
    for (i in 0..4) {
        dst[offset + i] = UInt8((bits >> (i * 8)) & 0xFFu32)
    }
}

// 写入小端 UInt16
internal func _writeUInt16LE(dst: Array<UInt8>, offset: Int64, v: UInt16): Unit {
    dst[offset] = UInt8(v & 0xFFu16)
    dst[offset + 1] = UInt8((v >> 8) & 0xFFu16)
}
