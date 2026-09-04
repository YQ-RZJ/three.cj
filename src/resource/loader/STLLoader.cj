/**
 * @file[zh-cn] STLLoader STL 格式加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/STLLoader.js 的仓颉侧实现
 * @explain[zh-cn] STL 格式加载器：支持二进制 STL 与 ASCII STL，输出 BufferGeometry（position/normal，可选顶点色）。仓颉侧使用 std 字节/字符串解析，无浏览器依赖。
 *
 * @file[en] STLLoader  STL format loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/STLLoader.js
 * @explain[en] STL format loader: supports binary STL and ASCII STL, outputting BufferGeometry (position/normal, optional vertex colors). Cangjie side uses std byte/string parsing with no browser dependency.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.rendering.buffer.*
import three.rendering.geometry.BufferGeometry
import three.rendering.geometry.DataUtils
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.utils.memory.AutoFreePtr
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] STL 加载器，加载 STL（STereoLithography）格式的 3D 模型
 * @explain[zh-cn] parse(data) 返回 BufferGeometry。
 *
 * @brief[en] STL loader, loads STL (STereoLithography) format 3D models
 * @explain[en] parse(data) returns BufferGeometry.
 *
 * @extends Loader
 */
public class STLLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @brief[zh-cn] 开始加载 STL 文件
     * @explain[zh-cn] 加载 STL 文件，使用 FileLoader 读取后调用 parse 解析
     * @param[zh-cn] url 模型文件路径
     * onLoad 加载完成回调，参数为 BufferGeometry
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading STL file
     * @explain[en] Loads STL file, reads via FileLoader then calls parse
     * @param[en] url Model file path
     * onLoad Load complete callback, parameter is BufferGeometry
     * onProgress Progress callback
     * onError Error callback
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        try {
            this.manager.itemStart(url)
            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = Path(fullPath)
            let bytes = File.readFrom(filePath)
            let geometry = this.parse(bytes)
            this.manager.itemEnd(url)
            onLoad(geometry)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @brief[zh-cn] 解析 STL 字节数据为 BufferGeometry
     * @explain[zh-cn] 解析 STL 字节数据，自动识别二进制/ASCII 格式
     * @param[zh-cn] data STL 文件字节
     * @return[zh-cn] BufferGeometry
     *
     * @brief[en] Parse STL byte data into BufferGeometry
     * @explain[en] Parses STL byte data, auto-detects binary/ASCII format
     * @param[en] data STL file bytes
     * @return[en] BufferGeometry
     */
    public func parse(data: Array<UInt8>): BufferGeometry {
        if (isBinary(data)) {
            return parseBinary(data)
        }
        return parseASCII(data)
    }

    /**
     * 判断是否为二进制 STL，按字节长度精确匹配或检查 "solid" 前缀
     */
    private func isBinary(data: Array<UInt8>): Bool {
        if (data.size >= 84) {
            
            // 注意：ASCII STL 的 80 字节头后是文本（如 "solid"），其字节解释为 UInt32 会很大，
            //       需先转 Int64 再乘，避免 UInt32 乘法溢出。
            let nFaces = Int64(_readUInt32LE(data, 80))
            let expect = 84 + nFaces * 50
            if (expect == Int64(data.size)) {
                return true
            }
        }
        
        for (off in 0..5) {
            if (off + 5 > data.size) { break }
            if (data[off] == 115u8 && data[off + 1] == 111u8 && data[off + 2] == 108u8 && data[off + 3] == 105u8 && data[off + 4] == 100u8) {
                return false
            }
        }
        return true
    }

    /**
     * 解析二进制 STL
     * 头 80 字节：文件信息（可能含 "COLOR=rgba" 默认色），随后 4 字节面数，
     * 每面 50 字节（12 个 Float32LE + 2 字节属性，属性高位可能含面颜色）。
     */
    private func parseBinary(data: Array<UInt8>): BufferGeometry {
        let faces = _readUInt32LE(data, 80)

        
        var hasColors = false
        var defaultR = 1.0
        var defaultG = 1.0
        var defaultB = 1.0
        let headerLen = if (data.size < 80) { data.size } else { 80 }
        for (index in 0..(headerLen - 10)) {
            if (index + 10 > headerLen) { break }
            
            if (data[index] == 0x43u8 && data[index + 1] == 0x4Fu8 && data[index + 2] == 0x4Cu8 && data[index + 3] == 0x4Fu8 &&
                data[index + 4] == 0x52u8 && data[index + 5] == 0x3Du8) {
                hasColors = true
                defaultR = Float64(data[index + 6]) / 255.0
                defaultG = Float64(data[index + 7]) / 255.0
                defaultB = Float64(data[index + 8]) / 255.0
            }
        }

        let dataOffset = 84
        let faceLength = 50

        let vertices = ArrayList<Float64>()
        let normals = ArrayList<Float64>()
        let colors = ArrayList<Float64>()

        for (face in 0..Int64(faces)) {
            let start = dataOffset + face * faceLength
            if (start + 50 > data.size) { break }
            // 法线
            let nx = _readFloat32LE(data, start)
            let ny = _readFloat32LE(data, start + 4)
            let nz = _readFloat32LE(data, start + 8)
            // 3 个顶点
            for (vi in 0..3) {
                let vBase = start + 12 + vi * 12
                let px = _readFloat32LE(data, vBase)
                let py = _readFloat32LE(data, vBase + 4)
                let pz = _readFloat32LE(data, vBase + 8)
                vertices.add(Float64(px))
                vertices.add(Float64(py))
                vertices.add(Float64(pz))
                normals.add(Float64(nx))
                normals.add(Float64(ny))
                normals.add(Float64(nz))
            }
            
            if (hasColors) {
                let attr = _readUInt16LE(data, start + 48)
                var r: Float64
                var g: Float64
                var b: Float64
                if ((attr & 0x8000u16) == 0u16) {
                    r = Float64(attr & 0x1Fu16) / 31.0
                    g = Float64((attr >> 5) & 0x1Fu16) / 31.0
                    b = Float64((attr >> 10) & 0x1Fu16) / 31.0
                } else {
                    r = defaultR
                    g = defaultG
                    b = defaultB
                }
                for (_ in 0..3) {
                    colors.add(r)
                    colors.add(g)
                    colors.add(b)
                }
            }
        }

        return _buildGeometry(vertices, normals, colors)
    }

    /**
     * 解析 ASCII STL，解析 solid/facet normal/vertex/endfacet 结构
     */
    private func parseASCII(data: Array<UInt8>): BufferGeometry {
        let text = String.fromUtf8(data)
        let vertices = ArrayList<Float64>()
        let normals = ArrayList<Float64>()

        let lines = text.split("\n")
        for (line in lines) {
            let t = line.trimAscii()
            if (t.startsWith("facet normal")) {
                let parts = _splitWhitespace(t)
                if (parts.size >= 5) {
                    let nx = _parseFloat(parts[2])
                    let ny = _parseFloat(parts[3])
                    let nz = _parseFloat(parts[4])
                    normals.add(nx); normals.add(ny); normals.add(nz)
                    normals.add(nx); normals.add(ny); normals.add(nz)
                    normals.add(nx); normals.add(ny); normals.add(nz)
                }
            } else if (t.startsWith("vertex")) {
                let parts = _splitWhitespace(t)
                if (parts.size >= 4) {
                    vertices.add(_parseFloat(parts[1]))
                    vertices.add(_parseFloat(parts[2]))
                    vertices.add(_parseFloat(parts[3]))
                }
            }
        }

        return _buildGeometry(vertices, normals, ArrayList<Float64>())
    }

    /**
     * 构建 BufferGeometry，设置 position/normal/color 属性
     */
    private func _buildGeometry(vertices: ArrayList<Float64>, normals: ArrayList<Float64>, colors: ArrayList<Float64>): BufferGeometry {
        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        if (normals.size > 0) {
            geometry.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        }
        if (colors.size > 0) {
            geometry.setAttribute("color", BufferAttribute(colors.toArray(), 3))
        }
        return geometry
    }
}

// ===== 二进制读取辅助（小端） =====

internal func _readUInt32LE(data: Array<UInt8>, offset: Int64): UInt32 {
    if (offset + 4 > data.size) { return 0 }
    return UInt32(data[offset]) |
        (UInt32(data[offset + 1]) << 8) |
        (UInt32(data[offset + 2]) << 16) |
        (UInt32(data[offset + 3]) << 24)
}

internal func _readUInt16LE(data: Array<UInt8>, offset: Int64): UInt16 {
    if (offset + 2 > data.size) { return 0 }
    return UInt16(data[offset]) | (UInt16(data[offset + 1]) << 8)
}

// 读取小端 Float32（按 IEEE 754 位模式解释）
internal func _readFloat32LE(data: Array<UInt8>, offset: Int64): Float32 {
    if (offset + 4 > data.size) { return 0.0f32 }
    let bits = UInt32(data[offset]) |
        (UInt32(data[offset + 1]) << 8) |
        (UInt32(data[offset + 2]) << 16) |
        (UInt32(data[offset + 3]) << 24)
    // 通过内存 reinterpret 将 UInt32 位模式转为 Float32
    // 对照 extras/DataUtils.cj 的 toFloat32 内存转换范式
    return unsafe {
        let holder = AutoFreePtr<UInt32>(LibC.malloc<UInt32>())
        holder.get().write(bits)
        let f32 = CPointer<Float32>(holder.get()).read()
        holder.dispose()
        f32
    }
}
