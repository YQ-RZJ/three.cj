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
 * @file[zh-cn] PLYLoader Stanford PLY 格式加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/PLYLoader.js 的仓颉侧实现
 * @explain[zh-cn] Stanford PLY 格式加载器：支持 ASCII / binary_little_endian / binary_big_endian，解析 vertex/face 元素，输出 BufferGeometry（position/normal/uv/color + index）。仓颉侧使用 std 字节/文本解析，无浏览器依赖。
 *
 * @file[en] PLYLoader  Stanford PLY format loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/PLYLoader.js
 * @explain[en] Stanford PLY format loader: supports ASCII / binary_little_endian / binary_big_endian, parses vertex/face elements, outputs BufferGeometry (position/normal/uv/color + index). Cangjie side uses std byte/text parsing with no browser dependency.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.rendering.buffer.*
import three.rendering.geometry.BufferGeometry
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.utils.memory.AutoFreePtr
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] PLY 加载器，加载 Stanford PLY 格式的点云/网格
 * @explain[zh-cn] parse(data) 返回 BufferGeometry。
 *
 * @brief[en] PLY loader, loads Stanford PLY format point clouds/meshes
 * @explain[en] parse(data) returns BufferGeometry.
 *
 * @extends Loader
 */
public class PLYLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @brief[zh-cn] 开始加载 PLY 文件
     * @explain[zh-cn] 加载 PLY 文件，使用 FileLoader 读取后调用 parse 解析
     * @param[zh-cn] url 模型文件路径
     * onLoad 加载完成回调，参数为 BufferGeometry
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading PLY file
     * @explain[en] Loads PLY file, reads via FileLoader then calls parse
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
     * @brief[zh-cn] 解析 PLY 字节数据为 BufferGeometry
     * @explain[zh-cn] 头部解析 → ASCII/Binary 数据解析 → 组装几何体
     * @param[zh-cn] data PLY 文件字节
     * @return[zh-cn] BufferGeometry
     *
     * @brief[en] Parse PLY byte data into BufferGeometry
     * @explain[en] Header parsing → ASCII/Binary data parsing → assemble geometry
     * @param[en] data PLY file bytes
     * @return[en] BufferGeometry
     */
    public func parse(data: Array<UInt8>): BufferGeometry {
        
        let header = this.parseHeader(data)
        if (header.format == "") {
            return BufferGeometry()
        }

        // 定位 body 起始位置（end_header 之后）
        let headerText = header.rawHeader
        let endIdx = headerText.indexOf("end_header")
        var bodyStart = 0
        match (endIdx) {
            case Some(idx) =>
                // end_header 行结束（\n 之后）
                var p = idx + 10
                while (p < headerText.size && headerText[p] != 10u8) { p += 1 }
                bodyStart = p + 1
            case None => bodyStart = 0
        }
        // 注意：headerText 是从原始字节解码的，但二进制 body 必须按原始字节偏移读取。
        // 改用扫描原始字节找 end_header 行尾。
        bodyStart = this._findBodyStart(data)

        match (header.format) {
            case "ascii" => return this.parseASCII(data, header, bodyStart)
            case "binary_little_endian" => return this.parseBinary(data, header, bodyStart, true)
            case "binary_big_endian" => return this.parseBinary(data, header, bodyStart, false)
            case _ => return BufferGeometry()
        }
    }

    // 扫描原始字节找 end_header 行结束位置
    private func _findBodyStart(data: Array<UInt8>): Int64 {
        // 在文本区内查找 "end_header" 序列（ASCII）
        for (i in 0..(data.size - 10)) {
            if (data[i] == 101u8 && data[i + 1] == 110u8 && data[i + 2] == 100u8 &&
                data[i + 3] == 95u8 && data[i + 4] == 104u8 && data[i + 5] == 101u8 &&
                data[i + 6] == 97u8 && data[i + 7] == 100u8 && data[i + 8] == 101u8 && data[i + 9] == 114u8) {
                var p = i + 10
                while (p < data.size && data[p] != 10u8 && data[p] != 13u8) { p += 1 }
                if (p < data.size && data[p] == 13u8) { p += 1 }
                if (p < data.size && data[p] == 10u8) { p += 1 }
                return p
            }
        }
        return 0
    }

    /**
     * 解析 PLY 头部，读取 format/elements（vertex/face 及属性）
     */
    private func parseHeader(data: Array<UInt8>): _PlyHeader {
        let header = _PlyHeader()
        let text = String.fromUtf8(data)
        let lines = text.split("\n")

        for (line0 in lines) {
            let line = line0.trimAscii()
            if (line == "") { continue }
            let parts = _splitWhitespace(line)
            if (parts.size == 0) { continue }
            let lineType = parts[0]

            match (lineType) {
                case "ply" => ()
                case "format" =>
                    if (parts.size >= 3) {
                        header.format = parts[1]
                        header.version = parts[2]
                    }
                case "comment" => header.comments.add(line)
                case "element" =>
                    if (parts.size >= 3) {
                        let element = _PlyElement()
                        element.name = parts[1]
                        element.count = _parseIntOpt(parts[2])
                        header.elements.add(element)
                    }
                case "property" =>
                    if (header.elements.size > 0) {
                        let element = header.elements[header.elements.size - 1]
                        let `prop` = _PlyProperty()
                        if (parts.size >= 4 && parts[1] == "list") {
                            `prop`.isList = true
                            `prop`.countType = parts[2]
                            `prop`.itemType = parts[3]
                            `prop`.name = parts[4]
                        } else if (parts.size >= 3) {
                            `prop`.isList = false
                            `prop`.`type` = parts[1]
                            `prop`.name = parts[2]
                        }
                        element.properties.add(`prop`)
                    }
                case "obj_info" => ()
                case "end_header" => break
                case _ => ()
            }
        }
        return header
    }

    /**
     * 解析 ASCII PLY，逐 token 读取各元素
     */
    private func parseASCII(data: Array<UInt8>, header: _PlyHeader, bodyStart: Int64): BufferGeometry {
        let text = String.fromUtf8(data)
        let body = if (bodyStart < text.size) { text[bodyStart..] } else { "" }
        let tokens = _splitWhitespace(body)
        var ti = 0

        let buffer = _PlyBuffer()
        for (elementDesc in header.elements) {
            let descriptor = _getAttributeDescriptor(elementDesc.properties)
            buffer.descriptors.add(elementDesc.name, descriptor)
            for (_ in 0..elementDesc.count) {
                if (ti >= tokens.size) { break }
                let element = _parseASCIIElement(elementDesc.properties, tokens, ti, ti)
                ti = element.nextToken
                _handleElement(buffer, elementDesc.name, element, descriptor)
            }
        }
        return _postProcess(buffer)
    }

    // 解析单个 ASCII 元素（属性值 + list）
    private func _parseASCIIElement(properties: ArrayList<_PlyProperty>, tokens: ArrayList<String>, startToken: Int64, _unused: Int64): _PlyElementData {
        let element = _PlyElementData()
        var ti = startToken
        for (`prop` in properties) {
            if (ti >= tokens.size) { break }
            if (`prop`.isList) {
                let count = _parseIntOpt(tokens[ti]); ti += 1
                let list = ArrayList<Float64>()
                for (_ in 0..count) {
                    if (ti >= tokens.size) { break }
                    list.add(_parseFloatOpt(tokens[ti])); ti += 1
                }
                element.listValues.add(`prop`.name, list)
            } else {
                element.scalarValues.add(`prop`.name, _parseFloatOpt(tokens[ti])); ti += 1
            }
        }
        element.nextToken = ti
        return element
    }

    /**
     * 解析二进制 PLY，按属性类型读取（支持大小端）
     */
    private func parseBinary(data: Array<UInt8>, header: _PlyHeader, bodyStart: Int64, littleEndian: Bool): BufferGeometry {
        let buffer = _PlyBuffer()
        var loc = bodyStart

        for (elementDesc in header.elements) {
            let descriptor = _getAttributeDescriptor(elementDesc.properties)
            buffer.descriptors.add(elementDesc.name, descriptor)
            for (_ in 0..elementDesc.count) {
                let result = _binaryReadElement(data, loc, elementDesc.properties, littleEndian)
                loc = result.nextOffset
                _handleElement(buffer, elementDesc.name, result.element, descriptor)
                if (loc >= data.size) { break }
            }
        }
        return _postProcess(buffer)
    }

    // 读取一个二进制元素
    private func _binaryReadElement(data: Array<UInt8>, at: Int64, properties: ArrayList<_PlyProperty>, littleEndian: Bool): _PlyBinaryResult {
        let element = _PlyElementData()
        var read = at
        for (`prop` in properties) {
            if (`prop`.isList) {
                let n = _readBinaryValue(data, read, `prop`.countType, littleEndian)
                read += _typeSize(`prop`.countType)
                let list = ArrayList<Float64>()
                for (_ in 0..Int64(n)) {
                    list.add(_readBinaryValue(data, read, `prop`.itemType, littleEndian))
                    read += _typeSize(`prop`.itemType)
                }
                element.listValues.add(`prop`.name, list)
            } else {
                element.scalarValues.add(`prop`.name, _readBinaryValue(data, read, `prop`.`type`, littleEndian))
                read += _typeSize(`prop`.`type`)
            }
        }
        let result = _PlyBinaryResult()
        result.element = element
        result.nextOffset = read
        return result
    }

    // 组装 BufferGeometry
    
    private func _postProcess(buffer: _PlyBuffer): BufferGeometry {
        let geometry = BufferGeometry()
        if (buffer.indices.size > 0) {
            geometry.setIndex(BufferAttribute(buffer.indices.toArray(), 1))
        }
        if (buffer.vertices.size > 0) {
            geometry.setAttribute("position", BufferAttribute(buffer.vertices.toArray(), 3))
        }
        if (buffer.normals.size > 0) {
            geometry.setAttribute("normal", BufferAttribute(buffer.normals.toArray(), 3))
        }
        if (buffer.uvs.size > 0) {
            geometry.setAttribute("uv", BufferAttribute(buffer.uvs.toArray(), 2))
        }
        if (buffer.colors.size > 0) {
            geometry.setAttribute("color", BufferAttribute(buffer.colors.toArray(), 3))
        }
        if (buffer.faceVertexUvs.size > 0) {
            geometry.setAttribute("uv", BufferAttribute(buffer.faceVertexUvs.toArray(), 2))
        }
        if (buffer.faceVertexColors.size > 0) {
            geometry.setAttribute("color", BufferAttribute(buffer.faceVertexColors.toArray(), 3))
        }
        return geometry
    }
}

// ===== PLY 辅助结构 =====

internal class _PlyHeader {
    public var format: String
    public var version: String
    public var comments: ArrayList<String>
    public var elements: ArrayList<_PlyElement>
    public var rawHeader: String

    public init() {
        this.format = ""
        this.version = ""
        this.comments = ArrayList<String>()
        this.elements = ArrayList<_PlyElement>()
        this.rawHeader = ""
    }
}

internal class _PlyElement {
    public var name: String
    public var count: Int64
    public var properties: ArrayList<_PlyProperty>

    public init() {
        this.name = ""
        this.count = 0
        this.properties = ArrayList<_PlyProperty>()
    }
}

internal class _PlyProperty {
    public var name: String
    public var `type`: String
    public var isList: Bool
    public var countType: String
    public var itemType: String

    public init() {
        this.name = ""
        this.`type` = ""
        this.isList = false
        this.countType = ""
        this.itemType = ""
    }
}

// 属性名 → 语义的映射描述（position/normal/uv/color）
internal class _PlyAttributeDescriptor {
    public var positionNameX: String
    public var positionNameY: String
    public var positionNameZ: String
    public var positionUsage: Bool
    public var normalNameX: String
    public var normalNameY: String
    public var normalNameZ: String
    public var normalUsage: Bool
    public var uvNameS: String
    public var uvNameT: String
    public var uvUsage: Bool
    public var colorNameR: String
    public var colorNameG: String
    public var colorNameB: String
    public var colorUsage: Bool
    public var colorScale: Float64

    public init() {
        this.positionNameX = "x"; this.positionNameY = "y"; this.positionNameZ = "z"; this.positionUsage = false
        this.normalNameX = "nx"; this.normalNameY = "ny"; this.normalNameZ = "nz"; this.normalUsage = false
        this.uvNameS = "s"; this.uvNameT = "t"; this.uvUsage = false
        this.colorNameR = "red"; this.colorNameG = "green"; this.colorNameB = "blue"; this.colorUsage = false
        this.colorScale = 1.0 / 255.0
    }
}

// 单个元素的解析结果
internal class _PlyElementData {
    public var scalarValues: HashMap<String, Float64>
    public var listValues: HashMap<String, ArrayList<Float64>>
    public var nextToken: Int64

    public init() {
        this.scalarValues = HashMap<String, Float64>()
        this.listValues = HashMap<String, ArrayList<Float64>>()
        this.nextToken = 0
    }

    public func getScalar(name: String): Float64 {
        match (this.scalarValues.get(name)) {
            case Some(v) => return v
            case None => return 0.0
        }
    }

    public func getList(name: String): ArrayList<Float64> {
        match (this.listValues.get(name)) {
            case Some(v) => return v
            case None => return ArrayList<Float64>()
        }
    }
}

internal class _PlyBinaryResult {
    public var element: _PlyElementData
    public var nextOffset: Int64

    public init() {
        this.element = _PlyElementData()
        this.nextOffset = 0
    }
}

// 数据累积缓冲（对照 JS: createBuffer）
internal class _PlyBuffer {
    public var vertices: ArrayList<Float64>
    public var normals: ArrayList<Float64>
    public var uvs: ArrayList<Float64>
    public var colors: ArrayList<Float64>
    public var indices: ArrayList<Float64>
    public var faceVertexUvs: ArrayList<Float64>
    public var faceVertexColors: ArrayList<Float64>
    public var descriptors: HashMap<String, _PlyAttributeDescriptor>

    public init() {
        this.vertices = ArrayList<Float64>()
        this.normals = ArrayList<Float64>()
        this.uvs = ArrayList<Float64>()
        this.colors = ArrayList<Float64>()
        this.indices = ArrayList<Float64>()
        this.faceVertexUvs = ArrayList<Float64>()
        this.faceVertexColors = ArrayList<Float64>()
        this.descriptors = HashMap<String, _PlyAttributeDescriptor>()
    }
}

// 从属性列表构建语义描述

internal func _getAttributeDescriptor(properties: ArrayList<_PlyProperty>): _PlyAttributeDescriptor {
    let desc = _PlyAttributeDescriptor()

    func findName(names: Array<String>): String {
        for (n in names) {
            for (`p` in properties) {
                if (p.name == n) { return n }
            }
        }
        return ""
    }

    let x = findName(["x", "px", "posx"])
    let y = findName(["y", "py", "posy"])
    let z = findName(["z", "pz", "posz"])
    if (x != "" && y != "" && z != "") {
        desc.positionNameX = x; desc.positionNameY = y; desc.positionNameZ = z; desc.positionUsage = true
    }
    let nx = findName(["nx", "normalx"])
    let ny = findName(["ny", "normaly"])
    let nz = findName(["nz", "normalz"])
    if (nx != "" && ny != "" && nz != "") {
        desc.normalNameX = nx; desc.normalNameY = ny; desc.normalNameZ = nz; desc.normalUsage = true
    }
    let s = findName(["s", "u", "texture_u", "tx"])
    let t = findName(["t", "v", "texture_v", "ty"])
    if (s != "" && t != "") {
        desc.uvNameS = s; desc.uvNameT = t; desc.uvUsage = true
    }
    let r = findName(["red", "diffuse_red", "r", "diffuse_r"])
    let g = findName(["green", "diffuse_green", "g", "diffuse_g"])
    let b = findName(["blue", "diffuse_blue", "b", "diffuse_b"])
    if (r != "" && g != "" && b != "") {
        desc.colorNameR = r; desc.colorNameG = g; desc.colorNameB = b; desc.colorUsage = true
        // 颜色缩放：uchar 1/255，float 1
        var scale = 1.0 / 255.0
        for (`p` in properties) {
            if (`p`.name == r && (`p`.`type` == "float" || `p`.`type` == "float32" || `p`.`type` == "double" || `p`.`type` == "float64")) {
                scale = 1.0
            }
        }
        desc.colorScale = scale
    }
    return desc
}

// 处理元素数据（vertex → 属性；face → 索引）

internal func _handleElement(buffer: _PlyBuffer, elementName: String, element: _PlyElementData, desc: _PlyAttributeDescriptor): Unit {
    if (elementName == "vertex") {
        if (desc.positionUsage) {
            buffer.vertices.add(element.getScalar(desc.positionNameX))
            buffer.vertices.add(element.getScalar(desc.positionNameY))
            buffer.vertices.add(element.getScalar(desc.positionNameZ))
        }
        if (desc.normalUsage) {
            buffer.normals.add(element.getScalar(desc.normalNameX))
            buffer.normals.add(element.getScalar(desc.normalNameY))
            buffer.normals.add(element.getScalar(desc.normalNameZ))
        }
        if (desc.uvUsage) {
            buffer.uvs.add(element.getScalar(desc.uvNameS))
            buffer.uvs.add(element.getScalar(desc.uvNameT))
        }
        if (desc.colorUsage) {
            let scale = desc.colorScale
            buffer.colors.add(element.getScalar(desc.colorNameR) * scale)
            buffer.colors.add(element.getScalar(desc.colorNameG) * scale)
            buffer.colors.add(element.getScalar(desc.colorNameB) * scale)
        }
    } else if (elementName == "face") {
        let vertexIndices = element.getList("vertex_indices")
        if (vertexIndices.size == 0) {
            let alt = element.getList("vertex_index")
            for (v in alt) { buffer.indices.add(v) }
        } else {
            for (v in vertexIndices) { buffer.indices.add(v) }
        }
        let texcoord = element.getList("texcoord")
        if (texcoord.size == 6) {
            // 每个面 3 个顶点 × 2 UV
            for (v in texcoord) { buffer.faceVertexUvs.add(v) }
        }
    }
}

// 读取二进制标量值（按类型 + 端序）

internal func _readBinaryValue(data: Array<UInt8>, at: Int64, `type`: String, littleEndian: Bool): Float64 {
    match (`type`) {
        case "int8" => if (at < data.size) { return Float64(_readInt8(data, at)) } else { return 0.0 }
        case "char" => if (at < data.size) { return Float64(_readInt8(data, at)) } else { return 0.0 }
        case "uint8" => if (at < data.size) { return Float64(data[at]) } else { return 0.0 }
        case "uchar" => if (at < data.size) { return Float64(data[at]) } else { return 0.0 }
        case "int16" => return Float64(_readInt16(data, at, littleEndian))
        case "short" => return Float64(_readInt16(data, at, littleEndian))
        case "uint16" => return Float64(_readUInt16(data, at, littleEndian))
        case "ushort" => return Float64(_readUInt16(data, at, littleEndian))
        case "int32" => return Float64(_readInt32(data, at, littleEndian))
        case "int" => return Float64(_readInt32(data, at, littleEndian))
        case "uint32" => return Float64(_readUInt32(data, at, littleEndian))
        case "uint" => return Float64(_readUInt32(data, at, littleEndian))
        case "float32" => return Float64(_readFloat32(data, at, littleEndian))
        case "float" => return Float64(_readFloat32(data, at, littleEndian))
        case "float64" => return _readFloat64(data, at, littleEndian)
        case "double" => return _readFloat64(data, at, littleEndian)
        case _ => return 0.0
    }
}

internal func _typeSize(`type`: String): Int64 {
    match (`type`) {
        case "int8" => return 1
        case "char" => return 1
        case "uint8" => return 1
        case "uchar" => return 1
        case "int16" => return 2
        case "short" => return 2
        case "uint16" => return 2
        case "ushort" => return 2
        case "int32" => return 4
        case "int" => return 4
        case "uint32" => return 4
        case "uint" => return 4
        case "float32" => return 4
        case "float" => return 4
        case "float64" => return 8
        case "double" => return 8
        case _ => return 4
    }
}

internal func _readInt8(data: Array<UInt8>, at: Int64): Int8 {
    if (at >= data.size) { return 0 }
    return Int8(data[at])
}

internal func _readInt16(data: Array<UInt8>, at: Int64, le: Bool): Int16 {
    if (at + 2 > data.size) { return 0 }
    let u = _readUInt16(data, at, le)
    return Int16(u)
}

internal func _readUInt16(data: Array<UInt8>, at: Int64, le: Bool): UInt16 {
    if (at + 2 > data.size) { return 0 }
    if (le) {
        return UInt16(data[at]) | (UInt16(data[at + 1]) << 8)
    }
    return UInt16(data[at + 1]) | (UInt16(data[at]) << 8)
}

internal func _readInt32(data: Array<UInt8>, at: Int64, le: Bool): Int32 {
    return Int32(_readUInt32(data, at, le))
}

internal func _readUInt32(data: Array<UInt8>, at: Int64, le: Bool): UInt32 {
    if (at + 4 > data.size) { return 0 }
    if (le) {
        return UInt32(data[at]) | (UInt32(data[at + 1]) << 8) | (UInt32(data[at + 2]) << 16) | (UInt32(data[at + 3]) << 24)
    }
    return UInt32(data[at + 3]) | (UInt32(data[at + 2]) << 8) | (UInt32(data[at + 1]) << 16) | (UInt32(data[at]) << 24)
}

internal func _readFloat32(data: Array<UInt8>, at: Int64, le: Bool): Float32 {
    let bits = _readUInt32(data, at, le)
    return unsafe {
        let holder = AutoFreePtr<UInt32>(LibC.malloc<UInt32>())
        holder.get().write(bits)
        let f32 = CPointer<Float32>(holder.get()).read()
        holder.dispose()
        f32
    }
}

internal func _readFloat64(data: Array<UInt8>, at: Int64, le: Bool): Float64 {
    if (at + 8 > data.size) { return 0.0 }
    var lo: UInt64 = 0
    var hi: UInt64 = 0
    if (le) {
        lo = UInt64(data[at]) | (UInt64(data[at + 1]) << 8) | (UInt64(data[at + 2]) << 16) | (UInt64(data[at + 3]) << 24)
        hi = UInt64(data[at + 4]) | (UInt64(data[at + 5]) << 8) | (UInt64(data[at + 6]) << 16) | (UInt64(data[at + 7]) << 24)
    } else {
        lo = UInt64(data[at + 4]) | (UInt64(data[at + 5]) << 8) | (UInt64(data[at + 6]) << 16) | (UInt64(data[at + 7]) << 24)
        hi = UInt64(data[at]) | (UInt64(data[at + 1]) << 8) | (UInt64(data[at + 2]) << 16) | (UInt64(data[at + 3]) << 24)
    }
    let bits = lo | (hi << 32)
    return unsafe {
        let holder = AutoFreePtr<UInt64>(LibC.malloc<UInt64>())
        holder.get().write(bits)
        let f64 = CPointer<Float64>(holder.get()).read()
        holder.dispose()
        f64
    }
}
