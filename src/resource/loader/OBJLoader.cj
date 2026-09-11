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
 * @file[zh-cn] OBJLoader Wavefront OBJ 格式加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/OBJLoader.js 的仓颉侧实现
 * @explain[zh-cn] Wavefront OBJ 格式加载器：解析 v/vt/vn/f/o/g/usemtl/mtllib/s 指令，生成 Group 包含的 Mesh 列表（position/normal/uv/color 属性）。仓颉侧使用 std 字符串解析，无浏览器依赖。
 *
 * @file[en] OBJLoader  Wavefront OBJ format loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/OBJLoader.js
 * @explain[en] Wavefront OBJ format loader: parses v/vt/vn/f/o/g/usemtl/mtllib/s directives, generates Group containing Mesh list (position/normal/uv/color attributes). Cangjie side uses std string parsing with no browser dependency.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.rendering.buffer.*
import three.rendering.geometry.BufferGeometry
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.core.math.*
import std.collection.*
import std.convert.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] OBJ 加载器，加载 Wavefront OBJ 格式的 3D 模型
 * @explain[zh-cn] parse(text) 返回 Group，可配合 MTLLoader 设置材质。
 *
 * @brief[en] OBJ model loader
 * @explain[en] parse(text) returns Group, can be used with MTLLoader to set materials.
 *
 * @extends Loader
 */
public class OBJLoader <: Loader {
    /**
     * @brief[zh-cn] 材质创建器（由 MTLLoader 提供），None 时使用默认材质
     *
     * @brief[en] Material creator (provided by MTLLoader); default materials are used when None
     */
    public var materials: Option<MaterialCreator>

    public init(manager: LoadingManager) {
        super(manager: manager)
        this.materials = None
    }

    public init() {
        super()
        this.materials = None
    }

    /**
     * @brief[zh-cn] 开始加载 OBJ 文件
     * @explain[zh-cn] 加载 OBJ 文件，使用 FileLoader 读取后调用 parse 解析
     * @param[zh-cn] url 模型文件路径
     * onLoad 加载完成回调，参数为 Group
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading OBJ file
     * @explain[en] Loads OBJ file, reads via FileLoader then calls parse
     * @param[en] url Model file path
     * onLoad Load complete callback, parameter is Group
     * onProgress Progress callback
     * onError Error callback
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        try {
            this.manager.itemStart(url)
            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = Path(fullPath)
            let bytes = File.readFrom(filePath)
            let text = String.fromUtf8(bytes)
            let group = this.parse(text)
            this.manager.itemEnd(url)
            onLoad(group)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @brief[zh-cn] 设置材质创建器
     * @explain[zh-cn] 设置材质创建器
     * @param[zh-cn] materials 材质创建器
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set material creator
     * @explain[en] Sets material creator
     * @param[en] materials Material creator
     * @return[en] Self reference
     */
    public func setMaterials(materials: MaterialCreator): OBJLoader {
        this.materials = Some(materials)
        return this
    }

    /**
     * @brief[zh-cn] 解析 OBJ 文本为 Group
     * @explain[zh-cn] 解析 OBJ 文本为 Group。支持指令：v/vt/vn（顶点/UV/法线）、f（面）、l（线）、p（点）、o/g（对象/组）、usemtl（材质）、mtllib（材质库）、s（平滑组）。
     * @param[zh-cn] text OBJ 文本内容
     * @return[zh-cn] Group 包含解析出的 Mesh
     *
     * @brief[en] Parse OBJ text into Group
     * @explain[en] Parses OBJ text into Group. Supports directives: v/vt/vn (vertex/UV/normal), f (face), l (line), p (point), o/g (object/group), usemtl (material), mtllib (material library), s (smoothing group).
     * @param[en] text OBJ text content
     * @return[en] Group containing parsed Meshes
     */
    public func parse(text: String): Group {
        
        var src = text
        if (src.contains("\r\n")) {
            src = src.replace("\r\n", "\n")
        }
        if (src.contains("\\\n")) {
            src = src.replace("\\\n", "")
        }

        let state = _ObjParserState()
        let lines = src.split("\n")

        for (line0 in lines) {
            var line = line0
            
            var startIdx = 0
            let lineRunes = line.toRuneArray()
            while (startIdx < lineRunes.size && (lineRunes[startIdx] == r' ' || lineRunes[startIdx] == r'\t')) { startIdx += 1 }
            if (startIdx > 0) { line = line[startIdx..] }
            if (line.size == 0) { continue }

            let firstChar = line.toRuneArray()[0]
            if (firstChar == r'#') { continue }

            if (firstChar == r'v') {
                let data = _splitWhitespace(line)
                if (data.size == 0) { continue }
                match (data[0]) {
                    case "v" =>
                        if (data.size >= 4) {
                            state.vertices.add(_parseFloat(data[1]))
                            state.vertices.add(_parseFloat(data[2]))
                            state.vertices.add(_parseFloat(data[3]))
                            
                            if (data.size >= 7) {
                                state.colors.add(_parseFloat(data[4]))
                                state.colors.add(_parseFloat(data[5]))
                                state.colors.add(_parseFloat(data[6]))
                            } else {
                                state.colors.add(0.0)
                                state.colors.add(0.0)
                                state.colors.add(0.0)
                            }
                        }
                    case "vn" =>
                        if (data.size >= 4) {
                            state.normals.add(_parseFloat(data[1]))
                            state.normals.add(_parseFloat(data[2]))
                            state.normals.add(_parseFloat(data[3]))
                        }
                    case "vt" =>
                        if (data.size >= 3) {
                            state.uvs.add(_parseFloat(data[1]))
                            state.uvs.add(_parseFloat(data[2]))
                        }
                    case _ => ()
                }
            } else if (firstChar == r'f') {
                
                let lineData = line[1..].trimAscii()
                let vertexData = _splitWhitespace(lineData)
                let faceVertices = ArrayList<Array<String>>()
                for (v in vertexData) {
                    if (v.size > 0) {
                        faceVertices.add(v.split("/"))
                    }
                }
                if (faceVertices.size < 3) { continue }
                let v1 = faceVertices[0]
                for (j in 1..(faceVertices.size - 1)) {
                    let v2 = faceVertices[j]
                    let v3 = faceVertices[j + 1]
                    state.addFace(
                        _getPart(v1, 0), _getPart(v2, 0), _getPart(v3, 0),
                        _getPart(v1, 1), _getPart(v2, 1), _getPart(v3, 1),
                        _getPart(v1, 2), _getPart(v2, 2), _getPart(v3, 2)
                    )
                }
            } else if (firstChar == r'o' || firstChar == r'g') {
                
                let name = line[1..].trimAscii()
                state.startObject(name)
            } else if (line.startsWith("usemtl")) {
                
                state.startMaterial(line[7..].trimAscii())
            } else if (line.startsWith("mtllib")) {
                
                state.materialLibraries.add(line[7..].trimAscii())
            } else if (firstChar == r's') {
                
                let result = _splitWhitespace(line)
                if (result.size > 1) {
                    let value = result[1].toAsciiLower()
                    state.objectSmooth = (value != "0" && value != "off")
                } else {
                    state.objectSmooth = true
                }
            } else if (firstChar == r'l') {
                
                let lineData = line[1..].trimAscii()
                let parts = _splitWhitespace(lineData)
                let lineVertices = ArrayList<String>()
                if (!line.contains("/")) {
                    for (p in parts) { lineVertices.add(p) }
                } else {
                    for (p in parts) {
                        let sub = p.split("/")
                        if (sub.size > 0 && sub[0] != "") { lineVertices.add(sub[0]) }
                    }
                }
                state.addLineGeometry(lineVertices)
            } else if (firstChar == r'p') {
                
                let lineData = line[1..].trimAscii()
                let parts = _splitWhitespace(lineData)
                state.addPointGeometry(parts)
            } else {
                if (line == "\u{0}") { continue }
            }
        }

        
        state.finalize()

        let container = Group()
        container.materialLibraries = state.materialLibraries.toArray()

        let hasPrimitives = !(state.objects.size == 1 && state.objects[0].vertices.size == 0)
        if (hasPrimitives) {
            for (obj in state.objects) {
                if (obj.vertices.size == 0) { continue }
                let geometry = BufferGeometry()
                geometry.setAttribute("position", BufferAttribute(obj.vertices.toArray(), 3))
                if (obj.normals.size > 0) {
                    geometry.setAttribute("normal", BufferAttribute(obj.normals.toArray(), 3))
                }
                if (obj.hasUVIndices) {
                    geometry.setAttribute("uv", BufferAttribute(obj.uvs.toArray(), 2))
                }
                let hasVertexColors = obj.colors.size > 0
                if (hasVertexColors) {
                    geometry.setAttribute("color", BufferAttribute(obj.colors.toArray(), 3))
                }

                
                let createdMaterials = ArrayList<Material>()
                if (obj.materials.size == 0) {
                    
                    let defaultMat = MeshPhongMaterial()
                    defaultMat.name = ""
                    defaultMat.flatShading = true
                    defaultMat.vertexColors = hasVertexColors
                    createdMaterials.add(defaultMat)
                } else {
                    for (mi in 0..obj.materials.size) {
                        let srcMat = obj.materials[mi]
                        var material: Option<Material> = None
                        match (this.materials) {
                            case Some(mc) => material = mc.create(srcMat.name)
                            case None => ()
                        }
                        if (material.isNone()) {
                            
                            let defaultMat = MeshPhongMaterial()
                            defaultMat.name = srcMat.name
                            defaultMat.flatShading = !srcMat.smooth
                            defaultMat.vertexColors = hasVertexColors
                            material = Some(defaultMat)
                        }
                        match (material) {
                            case Some(m) => createdMaterials.add(m)
                            case None => ()
                        }
                    }
                }

                
                if (createdMaterials.size > 1) {
                    for (mi in 0..obj.materials.size) {
                        let srcMat = obj.materials[mi]
                        let sub = BufferGeometry()
                        let vStart = srcMat.groupStart
                        let vCount = srcMat.groupCount
                        if (vCount <= 0) { continue }
                        sub.setAttribute("position", BufferAttribute(_slice(obj.vertices, vStart, vCount), 3))
                        if (obj.normals.size > 0) {
                            sub.setAttribute("normal", BufferAttribute(_slice(obj.normals, vStart, vCount), 3))
                        }
                        if (obj.hasUVIndices) {
                            sub.setAttribute("uv", BufferAttribute(_slice(obj.uvs, vStart, vCount), 2))
                        }
                        if (hasVertexColors) {
                            sub.setAttribute("color", BufferAttribute(_slice(obj.colors, vStart, vCount), 3))
                        }
                        let mesh = Mesh(geometry: sub, material: createdMaterials[mi])
                        mesh.name = obj.name
                        container.add(mesh)
                    }
                } else {
                    let mesh = Mesh(geometry: geometry, material: createdMaterials[0])
                    mesh.name = obj.name
                    container.add(mesh)
                }
            }
        } else {
            
            if (state.vertices.size > 0) {
                let material = PointsMaterial()
                material.size = 1.0
                let geometry = BufferGeometry()
                geometry.setAttribute("position", BufferAttribute(state.vertices.toArray(), 3))
                let points = Points(geometry: geometry, material: material)
                container.add(points)
            }
        }

        return container
    }
}

/**
 * @brief[zh-cn] OBJ 解析状态机
 * @explain[zh-cn] OBJ 解析过程中的状态管理，跟踪顶点/法线/UV/颜色/对象/材质等数据
 *
 * @brief[en] OBJ parser state machine
 * @explain[en] State management during OBJ parsing, tracking vertex/normal/UV/color/object/material data
 */
public class _ObjParserState {
    public var vertices: ArrayList<Float64>
    public var normals: ArrayList<Float64>
    public var uvs: ArrayList<Float64>
    public var colors: ArrayList<Float64>
    public var objects: ArrayList<_ObjParseObject>
    public var materialLibraries: ArrayList<String>
    public var objectSmooth: Bool

    public init() {
        this.vertices = ArrayList<Float64>()
        this.normals = ArrayList<Float64>()
        this.uvs = ArrayList<Float64>()
        this.colors = ArrayList<Float64>()
        this.objects = ArrayList<_ObjParseObject>()
        this.materialLibraries = ArrayList<String>()
        this.objectSmooth = true
        this.startObject("", fromDeclaration: false)
    }

    /**
     * 开始新对象（o/g 声明时调用）
     */
    public func startObject(name: String, fromDeclaration!: Bool = true): Unit {
        // 对象切换时，当前对象不再接收面数据（finalize 由后续逻辑处理）
        let obj = _ObjParseObject(name)
        this.objects.add(obj)
        if (fromDeclaration) {
            // 新对象默认开启新材质段
            obj.startMaterial("", this.materialLibraries)
        }
    }

    /**
     * 开始新材质段（usemtl 声明时调用）
     */
    public func startMaterial(name: String): Unit {
        if (this.objects.size == 0) { return }
        let obj = this.objects[this.objects.size - 1]
        if (obj.materials.size > 0) {
            let prev = obj.materials[obj.materials.size - 1]
            prev.groupCount = obj.vertices.size - prev.groupStart
        }
        obj.startMaterial(name, this.materialLibraries)
    }

    /**
     * 添加三角面，解析顶点/UV/法线索引并累积到当前对象
     */
    public func addFace(a: String, b: String, c: String, ua: String, ub: String, uc: String, na: String, nb: String, nc: String): Unit {
        if (this.objects.size == 0) { return }
        let obj = this.objects[this.objects.size - 1]
        let vLen = this.vertices.size
        let ia = this.parseVertexIndex(a, vLen)
        let ib = this.parseVertexIndex(b, vLen)
        let ic = this.parseVertexIndex(c, vLen)

        // 顶点
        obj.vertices.add(this.vertices[ia]); obj.vertices.add(this.vertices[ia + 1]); obj.vertices.add(this.vertices[ia + 2])
        obj.vertices.add(this.vertices[ib]); obj.vertices.add(this.vertices[ib + 1]); obj.vertices.add(this.vertices[ib + 2])
        obj.vertices.add(this.vertices[ic]); obj.vertices.add(this.vertices[ic + 1]); obj.vertices.add(this.vertices[ic + 2])

        // 顶点色
        if (ia < this.colors.size) {
            obj.colors.add(this.colors[ia]); obj.colors.add(this.colors[ia + 1]); obj.colors.add(this.colors[ia + 2])
        }
        if (ib < this.colors.size) {
            obj.colors.add(this.colors[ib]); obj.colors.add(this.colors[ib + 1]); obj.colors.add(this.colors[ib + 2])
        }
        if (ic < this.colors.size) {
            obj.colors.add(this.colors[ic]); obj.colors.add(this.colors[ic + 1]); obj.colors.add(this.colors[ic + 2])
        }

        // 法线
        if (na != "") {
            let nLen = this.normals.size
            let nia = this.parseNormalIndex(na, nLen)
            let nib = this.parseNormalIndex(nb, nLen)
            let nic = this.parseNormalIndex(nc, nLen)
            obj.normals.add(this.normals[nia]); obj.normals.add(this.normals[nia + 1]); obj.normals.add(this.normals[nia + 2])
            obj.normals.add(this.normals[nib]); obj.normals.add(this.normals[nib + 1]); obj.normals.add(this.normals[nib + 2])
            obj.normals.add(this.normals[nic]); obj.normals.add(this.normals[nic + 1]); obj.normals.add(this.normals[nic + 2])
        } else {
            
            let vA = Vector3(this.vertices[ia], this.vertices[ia + 1], this.vertices[ia + 2])
            let vB = Vector3(this.vertices[ib], this.vertices[ib + 1], this.vertices[ib + 2])
            let vC = Vector3(this.vertices[ic], this.vertices[ic + 1], this.vertices[ic + 2])
            let cb = Vector3()
            cb.subVectors(vC, vB)
            let ab = Vector3()
            ab.subVectors(vA, vB)
            cb.cross(ab)
            cb.normalize()
            for (_ in 0..3) {
                obj.normals.add(cb.x); obj.normals.add(cb.y); obj.normals.add(cb.z)
            }
        }

        // UV
        if (ua != "") {
            let uvLen = this.uvs.size
            let uia = this.parseUVIndex(ua, uvLen)
            let uib = this.parseUVIndex(ub, uvLen)
            let uic = this.parseUVIndex(uc, uvLen)
            obj.uvs.add(this.uvs[uia]); obj.uvs.add(this.uvs[uia + 1])
            obj.uvs.add(this.uvs[uib]); obj.uvs.add(this.uvs[uib + 1])
            obj.uvs.add(this.uvs[uic]); obj.uvs.add(this.uvs[uic + 1])
            obj.hasUVIndices = true
        } else {
            
            for (_ in 0..3) {
                obj.uvs.add(0.0); obj.uvs.add(0.0)
            }
        }

        // 更新当前材质段顶点数
        if (obj.materials.size > 0) {
            let cur = obj.materials[obj.materials.size - 1]
            cur.groupCount = obj.vertices.size - cur.groupStart
        }
    }

    /**
     * 解析顶点索引（支持正/负索引）
     */
    public func parseVertexIndex(value: String, len: Int64): Int64 {
        let index = _parseInt(value)
        return if (index >= 0) { (index - 1) * 3 } else { (index + len / 3) * 3 }
    }

    /**
     * 解析法线索引（支持正/负索引）
     */
    public func parseNormalIndex(value: String, len: Int64): Int64 {
        let index = _parseInt(value)
        return if (index >= 0) { (index - 1) * 3 } else { (index + len / 3) * 3 }
    }

    /**
     * 解析 UV 索引（支持正/负索引）
     */
    public func parseUVIndex(value: String, len: Int64): Int64 {
        let index = _parseInt(value)
        return if (index >= 0) { (index - 1) * 2 } else { (index + len / 2) * 2 }
    }

    /**
     * 添加线几何数据
     */
    public func addLineGeometry(vertices: ArrayList<String>): Unit {
        if (this.objects.size == 0) { return }
        let obj = this.objects[this.objects.size - 1]
        obj.isLine = true
        let vLen = this.vertices.size
        for (v in vertices) {
            let index = this.parseVertexIndex(v, vLen)
            obj.vertices.add(this.vertices[index])
            obj.vertices.add(this.vertices[index + 1])
            obj.vertices.add(this.vertices[index + 2])
        }
        // 线几何同样记录材质段
        if (obj.materials.size > 0) {
            let cur = obj.materials[obj.materials.size - 1]
            cur.groupCount = obj.vertices.size - cur.groupStart
        }
    }

    /**
     * 添加点几何数据
     */
    public func addPointGeometry(vertices: ArrayList<String>): Unit {
        if (this.objects.size == 0) { return }
        let obj = this.objects[this.objects.size - 1]
        obj.isPoints = true
        let vLen = this.vertices.size
        for (v in vertices) {
            if (v == "") { continue }
            let index = this.parseVertexIndex(v, vLen)
            obj.vertices.add(this.vertices[index])
            obj.vertices.add(this.vertices[index + 1])
            obj.vertices.add(this.vertices[index + 2])
        }
        if (obj.materials.size > 0) {
            let cur = obj.materials[obj.materials.size - 1]
            cur.groupCount = obj.vertices.size - cur.groupStart
        }
    }

    /**
     * 完成解析，更新最后一个材质段的顶点计数
     */
    public func finalize(): Unit {
        if (this.objects.size > 0) {
            let obj = this.objects[this.objects.size - 1]
            if (obj.materials.size > 0) {
                let last = obj.materials[obj.materials.size - 1]
                last.groupCount = obj.vertices.size - last.groupStart
            }
        }
    }
}

/**
 * @brief[zh-cn] OBJ 解析对象（对应一个 o/g 声明）
 *
 * @brief[en] OBJ parse object (corresponding to an o/g declaration)
 */
public class _ObjParseObject {
    public var name: String
    public var vertices: ArrayList<Float64>
    public var normals: ArrayList<Float64>
    public var uvs: ArrayList<Float64>
    public var colors: ArrayList<Float64>
    public var materials: ArrayList<_ObjSourceMaterial>
    public var hasUVIndices: Bool
    public var isLine: Bool
    public var isPoints: Bool

    public init(name: String) {
        this.name = name
        this.vertices = ArrayList<Float64>()
        this.normals = ArrayList<Float64>()
        this.uvs = ArrayList<Float64>()
        this.colors = ArrayList<Float64>()
        this.materials = ArrayList<_ObjSourceMaterial>()
        this.hasUVIndices = false
        this.isLine = false
        this.isPoints = false
    }

    /**
     * 开始新材质段
     */
    public func startMaterial(name: String, libraries: ArrayList<String>): Unit {
        let material = _ObjSourceMaterial(name)
        material.smooth = true
        material.groupStart = this.vertices.size
        material.groupCount = 0
        this.materials.add(material)
    }
}

/**
 * @brief[zh-cn] OBJ 源材质段（usemtl 切分信息）
 *
 * @brief[en] OBJ source material segment (usemtl split info)
 */
public class _ObjSourceMaterial {
    public var name: String
    public var smooth: Bool
    public var groupStart: Int64
    public var groupCount: Int64

    public init(name: String) {
        this.name = name
        this.smooth = true
        this.groupStart = 0
        this.groupCount = 0
    }
}

// ===== 辅助函数 =====

// 按空白字符分割字符串（对照 JS: split(/\s+/)，含空格/Tab/换行/回车）
internal func _splitWhitespace(s: String): ArrayList<String> {
    let result = ArrayList<String>()
    var cur = ""
    var inToken = false
    for (ch in s.toRuneArray()) {
        if (ch == r' ' || ch == r'\t' || ch == r'\n' || ch == r'\r') {
            if (inToken) {
                result.add(cur)
                cur = ""
                inToken = false
            }
        } else {
            cur = cur + ch.toString()
            inToken = true
        }
    }
    if (inToken) { result.add(cur) }
    return result
}

// 解析浮点数（对照 JS: parseFloat，失败返回 0）
internal func _parseFloat(s: String): Float64 {
    let t = s.trimAscii()
    if (t == "") { return 0.0 }
    try {
        return Float64.parse(t)
    } catch (_: Exception) {
        return 0.0
    }
}

// 解析整数（对照 JS: parseInt，失败返回 0）
internal func _parseInt(s: String): Int64 {
    let t = s.trimAscii()
    if (t == "") { return 0 }
    try {
        return Int64.parse(t)
    } catch (_: Exception) {
        return 0
    }
}

// 取面顶点分量的字符串值（越界返回空串）
internal func _getPart(parts: Array<String>, idx: Int64): String {
    if (idx < parts.size) { return parts[idx] }
    return ""
}

// 从源数组按 [start, start+count) 切片
internal func _slice(src: ArrayList<Float64>, start: Int64, count: Int64): Array<Float64> {
    let end = start + count
    let n = if (end > src.size) { src.size - start } else { count }
    if (n < 0) { return Array<Float64>() }
    return Array<Float64>(n, { i => src[start + i] })
}
