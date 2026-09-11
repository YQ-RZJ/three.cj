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
 * @file[zh-cn] MaterialLoader 材质加载器
 * @brief[zh-cn] 对应 Three.js loaders/MaterialLoader.js，加载 JSON 格式的材质
 * @explain[zh-cn] 材质加载器，从 JSON 数据解析并创建 Material 对象。支持通过类型名分发创建对应材质子类实例，并由 Material.fromJSON 反序列化属性。
 *
 * @file[en] MaterialLoader  Material loader
 * @brief[en] Loads JSON format materials
 * @explain[en] Material loader, parses and creates Material objects from JSON data. Supports dispatching to material subclass constructors by type name, with Material.fromJSON deserializing properties.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import std.collection.*
import three.rendering.buffer.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*
import three.rendering.textures.*
import fastjson.*
import fastjson.stream.*
import std.io.*
import std.fs.*

/**
 * @brief[zh-cn] 材质加载器，加载 JSON 格式的材质数据
 * @explain[zh-cn] 从 JSON 数据解析并创建对应类型的 Material 子类实例。
 *
 * @brief[en] Material loader, loads JSON format materials
 * @explain[en] Parses JSON data and creates corresponding Material subclass instances.
 *
 * @extends Loader
 */
public open class MaterialLoader <: Loader {
    private var textures: HashMap<String, Texture>

    public init(manager: LoadingManager) {
        super(manager: manager)
        this.textures = HashMap<String, Texture>()
    }

    public init() {
        super()
        this.textures = HashMap<String, Texture>()
    }

    /**
     * @brief[zh-cn] 设置纹理映射
     * @param[zh-cn] textures 纹理映射表
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set texture mapping
     * @param[en] textures Texture mapping table
     * @return[en] Self reference
     */
    public func setTextures(textures: HashMap<String, Texture>): MaterialLoader {
        this.textures = textures
        return this
    }

    /**
     * @brief[zh-cn] 开始加载材质
     * @param[zh-cn] url 材质文件 URL
     * onLoad 加载完成回调
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading material
     * @param[en] url Material file URL
     * onLoad Load complete callback
     * onProgress Progress callback
     * onError Error callback
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        // 使用 FileLoader 加载 JSON 文件，然后解析为 Material
        try {
            this.manager.itemStart(url)
            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = Path(fullPath)
            let bytes = File.readFrom(filePath)
            let jsonStr = String.fromUtf8(bytes)
            let json = this.parseJsonToHashMap(jsonStr)
            let material = this.parse(json)
            this.manager.itemEnd(url)
            onLoad(material)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @brief[zh-cn] 解析 JSON 对象为 Material
     * @explain[zh-cn] 根据 json.type 调用 createMaterialFromType 创建材质，然后调用 fromJSON 反序列化属性。
     * @param[zh-cn] json JSON 数据
     * @return[zh-cn] 材质对象
     *
     * @brief[en] Parse JSON object into Material
     * @explain[en] Creates material via createMaterialFromType based on json.type, then calls fromJSON to deserialize properties.
     * @param[en] json JSON data
     * @return[en] Material object
     */
    public open func parse(json: HashMap<String, Any>): Material {
        let material = this.createMaterialFromType(_getString(json, "type"))
        let m = match (material) {
            case mat: Material => mat
            case _ => MeshBasicMaterial()
        }
        
        m.fromJSON(json, this.textures)
        return m
    }

    /**
     * @brief[zh-cn] 根据类型名创建材质实例
     * @explain[zh-cn] materialLib[type] 分发，未知类型返回 Material
     * @param[zh-cn] type 材质类型名
     * @return[zh-cn] 创建的材质实例
     *
     * @brief[en] Create material instance by type name
     * @explain[en] materialLib[type] dispatch, unknown types return Material
     * @param[en] type Material type name
     * @return[en] Created material instance
     */
    public open func createMaterialFromType(`type`: String): Material {
        
        // 仓颉侧复用 Material.createFromJSON 的类型分发逻辑（MeshDistanceMaterial 在此补充）
        // 2026-08-20 去 Any：Three.js 侧返回 Material 具体类型，所有 match 分支均为 Material 子类
        match (`type`) {
            case "MeshDistanceMaterial" => return MeshDistanceMaterial()
            case "Material" => return Material()
            case _ =>
                let json = HashMap<String, Any>()
                json.add("type", `type`)
                match (Material.createFromJSON(json, this.textures)) {
                    case Some(m) => return m
                    case None => return Material()
                }
        }
    }

    /**
     * @brief[zh-cn] 使用 cjfast_json 将 JSON 字符串解析为 HashMap
     * @explain[zh-cn] 使用 cjfast_json 将 JSON 字符串解析为 HashMap
     * @param[zh-cn] jsonStr JSON 字符串
     * @return[zh-cn] 解析后的 HashMap
     *
     * @brief[en] Parse JSON string into HashMap using cjfast_json
     * @explain[en] Parses JSON string into HashMap using cjfast_json
     * @param[en] jsonStr JSON string
     * @return[en] Parsed HashMap
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