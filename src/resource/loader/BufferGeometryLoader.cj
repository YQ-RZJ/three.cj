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
 * @file[zh-cn] BufferGeometryLoader 几何体加载器
 * @brief[zh-cn] 加载 JSON 格式的几何体
 * @explain[zh-cn] 解析 JSON 格式的 BufferGeometry 数据，支持 index、attributes（含 InterleavedBufferAttribute/InstancedBufferAttribute）、morphAttributes、morphTargetsRelative、groups、boundingSphere、name/userData 等字段。
 *
 * @file[en] BufferGeometryLoader  Buffer geometry loader
 * @brief[en] Loads JSON-format geometries
 * @explain[en] Parses JSON-format BufferGeometry data, supporting index, attributes (including InterleavedBufferAttribute/InstancedBufferAttribute), morphAttributes, morphTargetsRelative, groups, boundingSphere, name/userData fields.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import std.collection.*
import three.rendering.buffer.*
import three.rendering.geometry.BufferGeometry
import three.rendering.geometry.InstancedBufferGeometry
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import fastjson.*
import fastjson.stream.*
import std.io.*
import std.fs.*

/**
 * @brief[zh-cn] 几何体加载器，加载 JSON 格式的 BufferGeometry 数据
 * @explain[zh-cn] 解析 JSON 数据为 BufferGeometry，支持 InterleavedBufferAttribute 和 InstancedBufferAttribute。
 *
 * @brief[en] Buffer geometry loader, loads JSON-format BufferGeometry data
 * @explain[en] Parses JSON data into BufferGeometry, supporting InterleavedBufferAttribute and InstancedBufferAttribute.
 *
 * @extends Loader
 */
public class BufferGeometryLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 几何体文件 URL
     * @param[zh-cn] onLoad 加载完成回调，参数为 BufferGeometry
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Geometry file URL
     * @param[en] onLoad Load complete callback, parameter is BufferGeometry
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载几何体
     * 对应 JS: onLoad( scope.parse( JSON.parse( text ) ) );
     * 仓颉侧：使用 cjfast_json 将加载到的 JSON 文本解析为 HashMap<String, Any>
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        // 使用 FileLoader 加载 JSON 文件，然后解析为 BufferGeometry
        try {
            this.manager.itemStart(url)
            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = Path(fullPath)
            let bytes = File.readFrom(filePath)
            let jsonStr = String.fromUtf8(bytes)
            let json = this.parseJsonToHashMap(jsonStr)
            let geometry = this.parse(json)
            this.manager.itemEnd(url)
            onLoad(geometry)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @param[zh-cn] json JSON 数据
     * @return[zh-cn] BufferGeometry
     *
     * @param[en] json JSON data
     * @return[en] BufferGeometry
     *
     * 解析 JSON 对象为 BufferGeometry
     * 解析 JSON 几何体数据
     * 依次解析：index → attributes（含 InterleavedBufferAttribute/InstancedBufferAttribute）
     * → morphAttributes → morphTargetsRelative → groups → boundingSphere → name/userData
     */
    public func parse(json: HashMap<String, Any>): BufferGeometry {
        
        let isInstanced = _getBool(json, "isInstancedBufferGeometry", false)
        let geometry = if (isInstanced) { InstancedBufferGeometry() } else { BufferGeometry() }

        
        match (json.get("data")) {
            case Some(d) =>
                match (d) {
                    case data: HashMap<String, Any> =>
                        
                        match (data.get("index")) {
                            case Some(idxVal) =>
                                match (idxVal) {
                                    case idx: HashMap<String, Any> =>
                                        match (idx.get("array")) {
                                            case Some(arrVal) =>
                                                let typed = _toFloat64Array(arrVal)
                                                geometry.setIndex(BufferAttribute(typed, 1))
                                            case None => ()
                                        }
                                    case _ => ()
                                }
                            case None => ()
                        }

                        
                        match (data.get("attributes")) {
                            case Some(attrsVal) =>
                                match (attrsVal) {
                                    case attrs: HashMap<String, Any> =>
                                        for ((name, attrVal) in attrs) {
                                            match (attrVal) {
                                                case attr: HashMap<String, Any> =>
                                                    
                                                    if (_getBool(attr, "isInterleavedBufferAttribute", false)) {
                                                        
                                                        let ibUuid = _getString(attr, "data")
                                                        let ib = _getInterleavedBuffer(data, ibUuid)
                                                        match (ib) {
                                                            case Some(interleavedBuffer) =>
                                                                let itemSize = _getInt(attr, "itemSize", 1)
                                                                let offset = _getInt(attr, "offset", 0)
                                                                let normalized = _getBool(attr, "normalized", false)
                                                                // 仓颉侧 BufferGeometry.attributes 仅接受 BufferAttribute（对照 JS:
                                                                // InterleavedBufferAttribute 继承 BufferAttribute），故按 JS
                                                                // InterleavedBufferAttribute.toJSON() 无 data 时解交错为普通 BufferAttribute。
                                                                let count = interleavedBuffer.array.size / interleavedBuffer.stride
                                                                let deinterleaved = Array<Float64>(count * itemSize, { _ => 0.0 })
                                                                for (i in 0..count) {
                                                                    let base = i * interleavedBuffer.stride + offset
                                                                    for (j in 0..itemSize) {
                                                                        deinterleaved[i * itemSize + j] = interleavedBuffer.array[base + j]
                                                                    }
                                                                }
                                                                let bufferAttribute = BufferAttribute(deinterleaved, itemSize, normalized: normalized)
                                                                let aName = _getString(attr, "name")
                                                                if (aName != "") { bufferAttribute.name = aName }
                                                                geometry.setAttribute(name, bufferAttribute)
                                                            case None => ()
                                                        }
                                                    } else {
                                                        
                                                        let typed = match (attr.get("array")) {
                                                            case Some(arrVal) => _toFloat64Array(arrVal)
                                                            case None => Array<Float64>()
                                                        }
                                                        let itemSize = _getInt(attr, "itemSize", 1)
                                                        let normalized = _getBool(attr, "normalized", false)
                                                        
                                                        let bufferAttribute: BufferAttribute = if (_getBool(attr, "isInstancedBufferAttribute", false)) {
                                                            InstancedBufferAttribute(typed, itemSize, normalized: normalized)
                                                        } else {
                                                            BufferAttribute(typed, itemSize, normalized: normalized)
                                                        }
                                                        let aName = _getString(attr, "name")
                                                        if (aName != "") { bufferAttribute.name = aName }
                                                        let usage = _getInt(attr, "usage", -1)
                                                        if (usage != -1) { bufferAttribute.setUsage(usage) }
                                                        geometry.setAttribute(name, bufferAttribute)
                                                    }
                                                case _ => ()
                                            }
                                        }
                                    case _ => ()
                                }
                            case None => ()
                        }

                        
                        match (data.get("morphAttributes")) {
                            case Some(morphVal) =>
                                match (morphVal) {
                                    case morphs: HashMap<String, Any> =>
                                        for ((key, attrArrVal) in morphs) {
                                            let list = ArrayList<BufferAttribute>()
                                            match (attrArrVal) {
                                                case attrArr: Array<Any> =>
                                                    for (a in attrArr) {
                                                        match (a) {
                                                            case attr: HashMap<String, Any> =>
                                                                let typed = match (attr.get("array")) {
                                                                    case Some(arrVal) => _toFloat64Array(arrVal)
                                                                    case None => Array<Float64>()
                                                                }
                                                                let itemSize = _getInt(attr, "itemSize", 1)
                                                                let normalized = _getBool(attr, "normalized", false)
                                                                list.add(BufferAttribute(typed, itemSize, normalized: normalized))
                                                            case _ => ()
                                                        }
                                                    }
                                                case _ => ()
                                            }
                                            if (list.size > 0) {
                                                geometry.morphAttributes.add(key, list)
                                            }
                                        }
                                    case _ => ()
                                }
                            case None => ()
                        }

                        
                        if (_getBool(data, "morphTargetsRelative", false)) {
                            geometry.morphTargetsRelative = true
                        }

                        
                        var groupsVal = data.get("groups")
                        if (groupsVal.isNone()) { groupsVal = data.get("drawcalls") }
                        if (groupsVal.isNone()) { groupsVal = data.get("offsets") }
                        match (groupsVal) {
                            case Some(gVal) =>
                                // fastjson 解析数组可能为 Array<Any> 或 ArrayList<Any>，两者都支持
                                var groupList = ArrayList<Any>()
                                match (gVal) {
                                    case groupsArr: Array<Any> =>
                                        for (g in groupsArr) { groupList.add(g) }
                                    case groupsList: ArrayList<Any> =>
                                        for (g in groupsList) { groupList.add(g) }
                                    case _ => ()
                                }
                                for (g in groupList) {
                                    match (g) {
                                        case group: HashMap<String, Any> =>
                                            let start = _getInt(group, "start", 0)
                                            let count = _getInt(group, "count", 0)
                                            let materialIndex = _getInt(group, "materialIndex", 0)
                                            geometry.addGroup(start, count, materialIndex: materialIndex)
                                        case _ => ()
                                    }
                                }
                            case None => ()
                        }

                        
                        match (data.get("boundingSphere")) {
                            case Some(bsVal) =>
                                match (bsVal) {
                                    case bs: HashMap<String, Any> =>
                                        let sphere = Sphere()
                                        sphere.fromJSON(bs)
                                        geometry.boundingSphere = Some(sphere)
                                    case _ => ()
                                }
                            case None => ()
                        }
                    case _ => ()
                }
            case None => ()
        }

        
        let name = _getString(json, "name")
        if (name != "") { geometry.name = name }
        match (json.get("userData")) {
            case Some(v) =>
                match (v) {
                    case m: HashMap<String, Any> =>
                        for ((k, val) in m) { geometry.userData.add(k, val) }
                    case _ => ()
                }
            case None => ()
        }

        return geometry
    }

    /**
     * @param[zh-cn] data 几何体 data 字典
     * @param[zh-cn] uuid 交错缓冲区 UUID
     * @return[zh-cn] InterleavedBuffer（未找到时返回 None）
     *
     * @param[en] data Geometry data dictionary
     * @param[en] uuid Interleaved buffer UUID
     * @return[en] InterleavedBuffer (returns None if not found)
     *
     * 获取或创建交错缓冲区
     * 从 json.data 的 interleavedBuffers/arrayBuffers 构建 InterleavedBuffer
     */
    private func _getInterleavedBuffer(data: HashMap<String, Any>, uuid: String): Option<InterleavedBuffer> {
        match (data.get("interleavedBuffers")) {
            case Some(ibVal) =>
                match (ibVal) {
                    case ibs: HashMap<String, Any> =>
                        match (ibs.get(uuid)) {
                            case Some(ibEntryVal) =>
                                match (ibEntryVal) {
                                    case ibEntry: HashMap<String, Any> =>
                                        
                                        let bufferUuid = _getString(ibEntry, "buffer")
                                        let arrayBuf = match (data.get("arrayBuffers")) {
                                            case Some(abVal) =>
                                                match (abVal) {
                                                    case abs: HashMap<String, Any> =>
                                                        match (abs.get(bufferUuid)) {
                                                            case Some(ab) => _toFloat64Array(ab)
                                                            case None => Array<Float64>()
                                                        }
                                                    case _ => Array<Float64>()
                                                }
                                            case None => Array<Float64>()
                                        }
                                        let stride = _getInt(ibEntry, "stride", 1)
                                        let interleavedBuffer = InterleavedBuffer(arrayBuf, stride)
                                        
                                        return Some(interleavedBuffer)
                                    case _ => return None
                                }
                            case None => return None
                        }
                    case _ => return None
                }
            case None => return None
        }
    }

    /**
     * @param[zh-cn] jsonStr JSON 字符串
     * @return[zh-cn] 解析后的 HashMap<String, Any>
     *
     * @param[en] jsonStr JSON string
     * @return[en] Parsed HashMap<String, Any>
     *
     * 使用 cjfast_json 将 JSON 字符串解析为 HashMap<String, Any>
     * 对应 JS: JSON.parse(text)
     */
    public func parseJsonToHashMap(jsonStr: String): HashMap<String, Any> {
        try {
            let reader = JsonStreamReader(ByteBuffer(jsonStr.toArray()))
            return JsonUtil.streamFromJsonForHashMapAny(reader)
        } catch (_: Exception) {
            // 解析失败时返回空 HashMap
            return HashMap<String, Any>()
        }
    }
}

// 将 fastjson 解析出的任意数值数组（Array<Float64>/Array<Int64>/ArrayList<Any>）统一转成 Array<Float64>

internal func _toFloat64Array(v: Any): Array<Float64> {
    match (v) {
        case arr: Array<Float64> => return arr
        case arr: Array<Int64> =>
            let result = Array<Float64>(arr.size, { _ => 0.0 })
            for (i in 0..arr.size) { result[i] = Float64(arr[i]) }
            return result
        case arr: Array<UInt8> =>
            let result = Array<Float64>(arr.size, { _ => 0.0 })
            for (i in 0..arr.size) { result[i] = Float64(arr[i]) }
            return result
        case list: ArrayList<Any> =>
            let result = Array<Float64>(list.size, { _ => 0.0 })
            for (i in 0..list.size) {
                match (list[i]) {
                    case f: Float64 => result[i] = f
                    case n: Int64 => result[i] = Float64(n)
                    case b: UInt8 => result[i] = Float64(b)
                    case _ => ()
                }
            }
            return result
        case arr: Array<Any> =>
            let result = Array<Float64>(arr.size, { _ => 0.0 })
            for (i in 0..arr.size) {
                match (arr[i]) {
                    case f: Float64 => result[i] = f
                    case n: Int64 => result[i] = Float64(n)
                    case b: UInt8 => result[i] = Float64(b)
                    case _ => ()
                }
            }
            return result
        case _ => return Array<Float64>()
    }
}