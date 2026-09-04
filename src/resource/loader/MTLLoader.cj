/**
 * @file[zh-cn] MTLLoader Wavefront MTL 材质库加载器
 * @brief[zh-cn] 对应 Three.js examples/jsm/loaders/MTLLoader.js 的仓颉侧实现
 * @explain[zh-cn] Wavefront MTL 材质库加载器：解析 newmtl/Ka/Kd/Ks/Ke/Ns/d/illum/map_Kd 等指令，生成 MaterialCreator（材质字典 + create(name) 创建入口），供 OBJLoader 使用。
 *
 * @file[en] MTLLoader  Wavefront MTL material library loader
 * @brief[en] Cangjie implementation corresponding to Three.js examples/jsm/loaders/MTLLoader.js
 * @explain[en] Wavefront MTL material library loader: parses newmtl/Ka/Kd/Ks/Ke/Ns/d/illum/map_Kd directives, generates MaterialCreator (material dictionary + create(name) entry), used by OBJLoader.
 */
package three.resource.loader

import three.rendering.buffer.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.interfaces.ILoadResult
import three.rendering.materials.*
import three.rendering.textures.*
import three.core.math.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] MTL 加载器，加载 Wavefront MTL 格式的材质库
 * @explain[zh-cn] parse(text) 返回 MaterialCreator。
 *
 * @brief[en] MTL material definition loader
 * @explain[en] parse(text) returns MaterialCreator.
 *
 * @extends Loader
 */
public class MTLLoader <: Loader {
    /**
     * @brief[zh-cn] 材质选项（暂支持 None）
     */
    public var materialOptions: Option<HashMap<String, Any>>

    public init(manager: LoadingManager) {
        super(manager: manager)
        this.materialOptions = None
    }

    public init() {
        super()
        this.materialOptions = None
    }

    /**
     * @brief[zh-cn] 开始加载 MTL 文件
     * @explain[zh-cn] 加载 MTL 文件，使用 FileLoader 读取后调用 parse 解析
     * @param[zh-cn] url 材质文件路径
     * onLoad 加载完成回调，参数为 MaterialCreator
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading MTL file
     * @explain[en] Loads MTL file, reads via FileLoader then calls parse
     * @param[en] url Material file path
     * onLoad Load complete callback, parameter is MaterialCreator
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
            let creator = this.parse(text, this.resourcePath)
            this.manager.itemEnd(url)
            onLoad(creator)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @brief[zh-cn] 解析 MTL 文本为 MaterialCreator
     * @explain[zh-cn] 解析 MTL 文本为 MaterialCreator。支持指令：newmtl（新材质）、Ka/Kd/Ks/Ke（环境/漫反射/镜面/自发光色）、Ns（高光指数）、d/Tr（透明度）、illum（光照模型）、map_Kd 等纹理映射。
     * @param[zh-cn] text MTL 文本内容
     * path 资源基础路径
     * @return[zh-cn] MaterialCreator
     *
     * @brief[en] Parse MTL text into MaterialCreator
     * @explain[en] Parses MTL text into MaterialCreator. Supports directives: newmtl (new material), Ka/Kd/Ks/Ke (ambient/diffuse/specular/emissive color), Ns (shininess), d/Tr (opacity), illum (illumination model), map_Kd and other texture maps.
     * @param[en] text MTL text content
     * path Resource base path
     * @return[en] MaterialCreator
     */
    public func parse(text: String, path: String): MaterialCreator {
        
        let lines = text.split("\n")
        var info = HashMap<String, Any>()
        let materialsInfo = HashMap<String, Any>()

        for (line0 in lines) {
            let line = line0.trimAscii()
            if (line.size == 0 || line.startsWith("#")) { continue }

            let pos = line.indexOf(" ")
            let key = if (pos.isSome()) { line[0..pos.getOrThrow()].toAsciiLower() } else { line.toAsciiLower() }
            let value = if (pos.isSome()) { line[(pos.getOrThrow() + 1)..].trimAscii() } else { "" }

            if (key == "newmtl") {
                
                info = HashMap<String, Any>()
                info.add("name", value)
                materialsInfo.add(value, info)
            } else {
                if (key == "ka" || key == "kd" || key == "ks" || key == "ke") {
                    
                    let parts = _splitWhitespace(value)
                    let color = Array<Float64>(3, { _ => 0.0 })
                    if (parts.size >= 1) { color[0] = _parseFloat(parts[0]) }
                    if (parts.size >= 2) { color[1] = _parseFloat(parts[1]) }
                    if (parts.size >= 3) { color[2] = _parseFloat(parts[2]) }
                    info.add(key, color)
                } else {
                    info.add(key, value)
                }
            }
        }

        
        let baseUrl = if (this.resourcePath != "") { this.resourcePath } else { path }
        let creator = MaterialCreator(baseUrl)
        creator.setCrossOrigin(this.crossOrigin)
        creator.setManager(this.manager)
        creator.setMaterials(materialsInfo)
        return creator
    }
}

/**
 * @brief[zh-cn] 材质创建器：持有 MTL 解析出的材质信息，按名称懒创建材质
 * @explain[zh-cn] 持有 MTL 解析出的材质信息，按名称懒创建材质
 *
 * @brief[en] Material creator: holds material info parsed from MTL, lazily creates materials by name
 * @explain[en] Holds material info parsed from MTL, lazily creates materials by name
 */
public class MaterialCreator <: ILoadResult {
    /**
     * @brief[zh-cn] 资源基础路径
     */
    public var baseUrl: String
    /**
     * @brief[zh-cn] 跨域设置
     */
    public var crossOrigin: String
    /**
     * @brief[zh-cn] 加载管理器
     */
    public var manager: LoadingManager
    /**
     * @brief[zh-cn] 材质信息字典（name → info HashMap）
     */
    public var materialsInfo: HashMap<String, Any>
    /**
     * @brief[zh-cn] 已创建材质缓存（name → Material）
     */
    public var materials: HashMap<String, Material>

    public init(baseUrl: String) {
        this.baseUrl = baseUrl
        this.crossOrigin = "anonymous"
        this.manager = LoadingManager()
        this.materialsInfo = HashMap<String, Any>()
        this.materials = HashMap<String, Material>()
    }

    /**
     * @brief[zh-cn] 设置跨域
     * @explain[zh-cn] 设置跨域值
     * @param[zh-cn] value 跨域值
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set cross-origin
     * @explain[en] Sets cross-origin value
     * @param[en] value Cross-origin value
     * @return[en] Self reference
     */
    public func setCrossOrigin(value: String): MaterialCreator {
        this.crossOrigin = value
        return this
    }

    /**
     * @brief[zh-cn] 设置加载管理器
     * @explain[zh-cn] 设置加载管理器
     * @param[zh-cn] value 加载管理器
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set loading manager
     * @explain[en] Sets loading manager
     * @param[en] value Loading manager
     * @return[en] Self reference
     */
    public func setManager(value: LoadingManager): MaterialCreator {
        this.manager = value
        return this
    }

    /**
     * @brief[zh-cn] 设置材质信息字典
     * @explain[zh-cn] 设置材质信息字典
     * @param[zh-cn] materialsInfo 材质信息字典
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set material info dictionary
     * @explain[en] Sets material info dictionary
     * @param[en] materialsInfo Material info dictionary
     * @return[en] Self reference
     */
    public func setMaterials(materialsInfo: HashMap<String, Any>): MaterialCreator {
        this.materialsInfo = materialsInfo
        return this
    }

    /**
     * @brief[zh-cn] 按名称创建材质（缓存复用）
     * @explain[zh-cn] 依据 Kd/Ka/Ks/Ke/Ns/d/map_Kd 构建 MeshPhongMaterial
     * @param[zh-cn] name 材质名
     * @return[zh-cn] Option<Material>，未找到返回 None
     *
     * @brief[en] Create material by name (cached)
     * @explain[en] Builds MeshPhongMaterial from Kd/Ka/Ks/Ke/Ns/d/map_Kd
     * @param[en] name Material name
     * @return[en] Option<Material>, returns None if not found
     */
    public func create(name: String): Option<Material> {
        if (this.materials.contains(name)) {
            return Some(this.materials[name])
        }
        match (this.materialsInfo.get(name)) {
            case Some(infoVal) =>
                match (infoVal) {
                    case info: HashMap<String, Any> =>
                        
                        let material = MeshPhongMaterial()
                        material.name = name

                        
                        match (info.get("kd")) {
                            case Some(v) =>
                                match (v) {
                                    case arr: Array<Float64> =>
                                        if (arr.size >= 3) {
                                            material.color.setRGB(arr[0], arr[1], arr[2])
                                        }
                                    case _ => ()
                                }
                            case None => ()
                        }
                        
                        match (info.get("ks")) {
                            case Some(v) =>
                                match (v) {
                                    case arr: Array<Float64> =>
                                        if (arr.size >= 3) {
                                            material.specular.setRGB(arr[0], arr[1], arr[2])
                                        }
                                    case _ => ()
                                }
                            case None => ()
                        }
                        
                        match (info.get("ns")) {
                            case Some(v) =>
                                match (v) {
                                    case s: String => material.shininess = _parseFloat(s)
                                    case _ => ()
                                }
                            case None => ()
                        }
                        
                        var dVal: Float64 = 1.0
                        match (info.get("d")) {
                            case Some(v) =>
                                match (v) {
                                    case s: String => dVal = _parseFloat(s)
                                    case _ => ()
                                }
                            case None => ()
                        }
                        match (info.get("tr")) {
                            case Some(v) =>
                                match (v) {
                                    case s: String => dVal = 1.0 - _parseFloat(s)
                                    case _ => ()
                                }
                            case None => ()
                        }
                        material.opacity = dVal
                        material.transparent = (dVal < 1.0)

                        this.materials.add(name, material)
                        return Some(material)
                    case _ => return None
                }
            case None => return None
        }
    }
}
