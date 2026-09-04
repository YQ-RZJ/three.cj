/**
 * @file[zh-cn] ObjectLoader 对象加载器
 * @brief[zh-cn] 对应 Three.js loaders/ObjectLoader.js，加载 JSON 格式的完整场景对象
 * @explain[zh-cn] 支持加载几何体、材质、纹理、对象、动画、相机、光源等所有类型。
 *
 * @file[en] ObjectLoader  Object loader
 * @brief[en] Loads JSON format complete scene objects
 * @explain[en] Supports loading geometries, materials, textures, objects, animations, cameras, lights and all other types.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import std.collection.*
import three.rendering.buffer.*
import three.rendering.geometry.BoxGeometry
import three.rendering.geometry.BufferGeometry
import three.rendering.geometry.CapsuleGeometry
import three.rendering.geometry.CircleGeometry
import three.rendering.geometry.ConeGeometry
import three.rendering.geometry.Curve
import three.rendering.geometry.CylinderGeometry
import three.rendering.geometry.DodecahedronGeometry
import three.rendering.geometry.EdgesGeometry
import three.rendering.geometry.ExtrudeGeometry
import three.rendering.common.Geometries
import three.rendering.geometry.IcosahedronGeometry
import three.rendering.geometry.InstancedBufferGeometry
import three.rendering.geometry.LatheGeometry
import three.rendering.geometry.OctahedronGeometry
import three.rendering.geometry.PlaneGeometry
import three.rendering.geometry.PolyhedronGeometry
import three.rendering.geometry.RingGeometry
import three.rendering.geometry.Shape
import three.rendering.geometry.ShapeGeometry
import three.rendering.geometry.SphereGeometry
import three.rendering.geometry.TetrahedronGeometry
import three.rendering.geometry.TorusGeometry
import three.rendering.geometry.TorusKnotGeometry
import three.rendering.geometry.TubeGeometry
import three.rendering.geometry.WireframeGeometry
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import three.rendering.textures.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.scene.entity.*
import three.animation.clip.*
import fastjson.*
import fastjson.stream.*
import std.io.*
import std.fs.File

/**
 * @brief[zh-cn] 对象加载器，加载 JSON 格式的完整场景层级结构
 * @explain[zh-cn] 支持加载几何体、材质、纹理、对象、动画、相机、光源等所有类型。
 *
 * @brief[en] Object loader, loads JSON format complete scene hierarchy
 * @explain[en] Supports loading geometries, materials, textures, objects, animations, cameras, lights and all other types.
 *
 * @extends Loader
 */
public open class ObjectLoader <: Loader {
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
    public func setTextures(textures: HashMap<String, Texture>): ObjectLoader {
        this.textures = textures
        return this
    }

    /**
     * @brief[zh-cn] 开始加载场景对象
     * @explain[zh-cn] path 为空时以 extractUrlBase(url) 作为基础路径，并同步设置 resourcePath；检查 metadata（缺失/type 缺失/type 为 geometry 时拒绝加载）。使用 FileLoader 加载 JSON 文件，然后解析为场景对象。
     * @param[zh-cn] url 场景文件路径
     * onLoad 加载完成回调
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading scene object
     * @explain[en] When path is empty, uses extractUrlBase(url) as base path and sets resourcePath; checks metadata (rejects when missing/type missing/type is geometry). Uses FileLoader to load JSON file, then parses into scene object.
     * @param[en] url Scene file path
     * onLoad Load complete callback
     * onProgress Progress callback
     * onError Error callback
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        try {
            this.manager.itemStart(url)
            
            //         this.resourcePath = this.resourcePath || path;
            if (this.path == "" && this.resourcePath == "") {
                this.resourcePath = LoaderUtils.extractUrlBase(url)
            }
            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = fullPath
            let bytes = File.readFrom(filePath)
            let jsonStr = String.fromUtf8(bytes)
            let json = this.parseJsonToHashMap(jsonStr)

            
            let metadataType = match (json.get("metadata")) {
                case Some(m) =>
                    match (m) {
                        case md: HashMap<String, Any> =>
                            match (md.get("type")) {
                                case Some(t) => match (t) { case s: String => s; case _ => "" }
                                case None => ""
                            }
                        case _ => ""
                    }
                case None => ""
            }
            if (metadataType == "" || metadataType.toAsciiLower() == "geometry") {
                this.manager.itemError(url)
                onError("THREE.ObjectLoader: Can't load " + url)
                return
            }

            this.parse(json, onLoad)
            this.manager.itemEnd(url)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @brief[zh-cn] 解析 JSON 对象为场景对象
     * @explain[zh-cn] 对应 JS: parse(json, onLoad)。依次解析：动画 → 形状 → 几何体 → 图片 → 纹理 → 材质 → 对象 → 骨骼 → 绑定
     * @param[zh-cn] json JSON 数据
     * onLoad 加载完成回调
     *
     * @brief[en] Parse JSON object into scene object
     * @explain[en] Parses in order: animations → shapes → geometries → images → textures → materials → objects → skeletons → bindings
     * @param[en] json JSON data
     * onLoad Load complete callback
     */
    public open func parse(json: HashMap<String, Any>, onLoad: (ILoadResult) -> Unit): Unit {
        let animations = this.parseAnimations(json.get("animations"))
        let shapes = this.parseShapes(json.get("shapes"))
        let geometries = this.parseGeometries(json.get("geometries"), shapes)
        let images = this.parseImages(json.get("images"))
        let textures = this.parseTextures(json.get("textures"), images)
        let materials = this.parseMaterials(json.get("materials"), textures)

        let object = this.parseObject(json.get("object"), geometries, materials, textures, animations)
        let skeletons = this.parseSkeletons(json.get("skeletons"), object)

        this.bindSkeletons(object, skeletons)
        this.bindLightTargets(object)

        // 如果没有图片需要异步加载，直接回调
        onLoad(object)
    }

    /**
     * @brief[zh-cn] 解析动画
     * @explain[zh-cn] 对应 JS: parseAnimations(json)
     * @param[zh-cn] jsonOpt JSON 中的动画数据
     * @return[zh-cn] UUID 到 AnimationClip 的映射
     *
     * @brief[en] Parse animations
     * @explain[en] Parses animation data from JSON
     * @param[en] jsonOpt Animation data in JSON
     * @return[en] UUID to AnimationClip mapping
     */
    public func parseAnimations(jsonOpt: Option<Any>): HashMap<String, AnimationClip> {
        let animations = HashMap<String, AnimationClip>()
        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        for (i in 0..jsonArr.size) {
                            let data = jsonArr[i]
                            let clip = AnimationClip.parse(data)
                            animations.add(clip.uuid, clip)
                        }
                    case _ => ()
                }
            case None => ()
        }
        return animations
    }

    /**
     * @brief[zh-cn] 解析形状
     * @explain[zh-cn] 对应 JS: parseShapes(json)
     * @param[zh-cn] jsonOpt JSON 中的形状数据
     * @return[zh-cn] UUID 到 Shape 的映射
     *
     * @brief[en] Parse shapes
     * @explain[en] Parses shape data from JSON
     * @param[en] jsonOpt Shape data in JSON
     * @return[en] UUID to Shape mapping
     */
    public func parseShapes(jsonOpt: Option<Any>): HashMap<String, Shape> {
        let shapes = HashMap<String, Shape>()
        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        for (i in 0..jsonArr.size) {
                            let data = jsonArr[i]
                            let shape = Shape()
                            shape.uuid = _getString(data, "uuid")
                            shapes.add(shape.uuid, shape)
                        }
                    case _ => ()
                }
            case None => ()
        }
        return shapes
    }

    /**
     * @brief[zh-cn] 解析几何体
     * @explain[zh-cn] 对应 JS: parseGeometries(json, shapes)
     * @param[zh-cn] jsonOpt JSON 中的几何体数据
     * shapes 形状映射
     * @return[zh-cn] UUID 到 BufferGeometry 的映射
     *
     * @brief[en] Parse geometries
     * @explain[en] Parses geometry data from JSON
     * @param[en] jsonOpt Geometry data in JSON
     * shapes Shape mapping
     * @return[en] UUID to BufferGeometry mapping
     */
    public func parseGeometries(jsonOpt: Option<Any>, shapes: HashMap<String, Shape>): HashMap<String, BufferGeometry> {
        let geometries = HashMap<String, BufferGeometry>()
        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        let bufferGeometryLoader = BufferGeometryLoader()
                        for (i in 0..jsonArr.size) {
                            let data = jsonArr[i]
                            let typeStr = _getString(data, "type")
                            var geometry = BufferGeometry()
                            if (typeStr == "BufferGeometry" || typeStr == "InstancedBufferGeometry") {
                                geometry = bufferGeometryLoader.parse(data)
                            } else {
                                
                                // CJ 侧几何子类多数无静态 fromJSON，故通过读取 JSON 的 parameters 字段调用对应构造函数。
                                geometry = _dispatchGeometry(typeStr, data, shapes)
                            }
                            geometry.uuid = _getString(data, "uuid")
                            let name = _getString(data, "name")
                            if (name != "") { geometry.name = name }
                            geometries.add(geometry.uuid, geometry)
                        }
                    case _ => ()
                }
            case None => ()
        }
        return geometries
    }

    /**
     * @brief[zh-cn] 解析材质
     * @explain[zh-cn] 解析 JSON 中的材质数据，结合纹理映射重建材质对象
     * @param[zh-cn] jsonOpt JSON 中的材质数据
     * textures 纹理映射
     * @return[zh-cn] UUID 到 Material 的映射
     *
     * @brief[en] Parse materials
     * @explain[en] Parses material data from JSON, rebuilds material objects with texture mapping
     * @param[en] jsonOpt Material data in JSON
     * textures Texture mapping
     * @return[en] UUID to Material mapping
     */
    public open func parseMaterials(jsonOpt: Option<Any>, textures: HashMap<String, Texture>): HashMap<String, Material> {
        let materials = HashMap<String, Material>()
        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        let loader = MaterialLoader()
                        loader.setTextures(textures)
                        for (i in 0..jsonArr.size) {
                            let data = jsonArr[i]
                            let uuid = _getString(data, "uuid")
                            if (!materials.contains(uuid)) {
                                let material = loader.parse(data)
                                material.uuid = uuid
                                materials.add(uuid, material)
                            }
                        }
                    case _ => ()
                }
            case None => ()
        }
        return materials
    }

    /**
     * @brief[zh-cn] 解析图片
     * @explain[zh-cn] 对应 JS: parseImages(json, onLoad)。仓颉侧：加载图片文件原始字节数据。
     * @param[zh-cn] jsonOpt JSON 中的图片数据
     * @return[zh-cn] UUID 到 Source 的映射
     *
     * @brief[en] Parse images
     * @explain[en] Parses image data from JSON. Cangjie side: loads image file raw byte data.
     * @param[en] jsonOpt Image data in JSON
     * @return[en] UUID to Source mapping
     */
    public func parseImages(jsonOpt: Option<Any>): HashMap<String, Source> {
        let images = HashMap<String, Source>()
        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        let imageLoader = ImageLoader()
                        for (i in 0..jsonArr.size) {
                            let image = jsonArr[i]
                            let uuid = _getString(image, "uuid")
                            let urlOpt = image.get("url")
                            match (urlOpt) {
                                case Some(urlVal) =>
                                    match (urlVal) {
                                        case urlStr: String =>
                                            // 加载单张图片
                                            let fullPath = if (this.resourcePath != "") { this.resourcePath + "/" + urlStr } else { urlStr }
                                            try {
                                                let bytes = File.readFrom(fullPath)
                                                images.add(uuid, Source(data: bytes))
                                            } catch (_: Exception) {
                                                images.add(uuid, Source())
                                            }
                                        case urlArr: Array<Any> =>
                                            // 加载图片数组（如立方体贴图）
                                            let imageArr = ArrayList<Array<UInt8>>()
                                            for (j in 0..urlArr.size) {
                                                match (urlArr[j]) {
                                                    case subUrl: String =>
                                                        let subFullPath = if (this.resourcePath != "") { this.resourcePath + "/" + subUrl } else { subUrl }
                                                        try {
                                                            let subBytes = File.readFrom(subFullPath)
                                                            imageArr.add(subBytes)
                                                        } catch (_: Exception) {
                                                            ()
                                                        }
                                                    case _ => ()
                                                }
                                            }
                                            if (imageArr.size > 0) {
                                                images.add(uuid, Source(data: imageArr[0]))
                                            }
                                        case _ => ()
                                    }
                                case None => ()
                            }
                        }
                    case _ => ()
                }
            case None => ()
        }
        return images
    }

    /**
     * @brief[zh-cn] 解析纹理
     * @explain[zh-cn] 对应 JS: parseTextures(json, images)
     * @param[zh-cn] jsonOpt JSON 中的纹理数据
     * images 图片映射
     * @return[zh-cn] UUID 到 Texture 的映射
     *
     * @brief[en] Parse textures
     * @explain[en] Parses texture data from JSON
     * @param[en] jsonOpt Texture data in JSON
     * images Image mapping
     * @return[en] UUID to Texture mapping
     */
    public func parseTextures(jsonOpt: Option<Any>, images: HashMap<String, Source>): HashMap<String, Texture> {
        let textures = HashMap<String, Texture>()
        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        for (i in 0..jsonArr.size) {
                            let data = jsonArr[i]
                            let imageUuid = _getString(data, "image")
                            let source = images.get(imageUuid)

                            // 创建纹理
                            let texture = Texture()
                            texture.uuid = _getString(data, "uuid")

                            // 设置 source
                            match (source) {
                                case Some(src) => texture.source = src
                                case None => ()
                            }

                            // 设置纹理属性
                            let name = _getString(data, "name")
                            if (name != "") { texture.name = name }
                            match (data.get("mapping")) {
                                case Some(v) => match (v) { case i: Int64 => texture.mapping = i; case _ => () }
                                case None => ()
                            }
                            match (data.get("wrap")) {
                                case Some(v) => match (v) {
                                    case arr: Array<Any> =>
                                        if (arr.size >= 2) {
                                            match (arr[0]) { case i: Int64 => texture.wrapS = i; case _ => () }
                                            match (arr[1]) { case i: Int64 => texture.wrapT = i; case _ => () }
                                        }
                                    case _ => ()
                                }
                                case None => ()
                            }
                            match (data.get("format")) {
                                case Some(v) => match (v) { case i: Int64 => texture.format = i; case _ => () }
                                case None => ()
                            }
                            match (data.get("type")) {
                                case Some(v) => match (v) { case i: Int64 => texture.`type` = i; case _ => () }
                                case None => ()
                            }
                            match (data.get("colorSpace")) {
                                case Some(v) => match (v) { case s: String => texture.colorSpace = s; case _ => () }
                                case None => ()
                            }
                            match (data.get("minFilter")) {
                                case Some(v) => match (v) { case i: Int64 => texture.minFilter = i; case _ => () }
                                case None => ()
                            }
                            match (data.get("magFilter")) {
                                case Some(v) => match (v) { case i: Int64 => texture.magFilter = i; case _ => () }
                                case None => ()
                            }
                            match (data.get("anisotropy")) {
                                case Some(v) => match (v) { case i: Int64 => texture.anisotropy = i; case _ => () }
                                case None => ()
                            }
                            match (data.get("flipY")) {
                                case Some(v) => match (v) { case b: Bool => texture.flipY = b; case _ => () }
                                case None => ()
                            }
                            match (data.get("generateMipmaps")) {
                                case Some(v) => match (v) { case b: Bool => texture.generateMipmaps = b; case _ => () }
                                case None => ()
                            }
                            match (data.get("offset")) {
                                case Some(v) => match (v) { case arr: Array<Float64> => if (arr.size >= 2) { texture.offset.set(arr[0], arr[1]) }; case _ => () }
                                case None => ()
                            }
                            match (data.get("repeat")) {
                                case Some(v) => match (v) { case arr: Array<Float64> => if (arr.size >= 2) { texture.repeat.set(arr[0], arr[1]) }; case _ => () }
                                case None => ()
                            }
                            texture.needsUpdate = true
                            textures.add(texture.uuid, texture)
                        }
                    case _ => ()
                }
            case None => ()
        }
        return textures
    }

    /**
     * @brief[zh-cn] 解析对象
     * @explain[zh-cn] 对应 JS: parseObject(data, geometries, materials, textures, animations)。支持所有标准 Three.js 对象类型：Scene/PerspectiveCamera/OrthographicCamera/AmbientLight/DirectionalLight/PointLight/SpotLight/HemisphereLight/LightProbe/Mesh/SkinnedMesh/InstancedMesh/BatchedMesh/Line/LineLoop/LineSegments/Points/Sprite/Group/Bone/LOD 等。
     * @param[zh-cn] dataOpt JSON 中的对象数据
     * geometries 几何体映射
     * materials 材质映射
     * textures 纹理映射
     * animations 动画映射
     * @return[zh-cn] 解析后的 3D 对象
     *
     * @brief[en] Parse object
     * @explain[en] Parses object data from JSON. Supports all standard Three.js object types: Scene/PerspectiveCamera/OrthographicCamera/AmbientLight/DirectionalLight/PointLight/SpotLight/HemisphereLight/LightProbe/Mesh/SkinnedMesh/InstancedMesh/BatchedMesh/Line/LineLoop/LineSegments/Points/Sprite/Group/Bone/LOD etc.
     * @param[en] dataOpt Object data in JSON
     * geometries Geometry mapping
     * materials Material mapping
     * textures Texture mapping
     * animations Animation mapping
     * @return[en] Parsed 3D object
     */
    public func parseObject(dataOpt: Option<Any>, geometries: HashMap<String, BufferGeometry>, materials: HashMap<String, Material>, textures: HashMap<String, Texture>, animations: HashMap<String, AnimationClip>): Object3D {
        match (dataOpt) {
            case Some(val) =>
                match (val) {
                    case data: HashMap<String, Any> => return this._parseObject(data, geometries, materials, textures, animations)
                    case _ => return Object3D()
                }
            case None => return Object3D()
        }
    }

    /**
     * 内部对象解析方法
     */
    private func _parseObject(data: HashMap<String, Any>, geometries: HashMap<String, BufferGeometry>, materials: HashMap<String, Material>, textures: HashMap<String, Texture>, animations: HashMap<String, AnimationClip>): Object3D {
        let typeStr = _getString(data, "type")
        var object: Object3D = Object3D()

        // 根据类型创建对应对象
        if (typeStr == "Scene") {
            let scene = Scene()
            match (data.get("background")) {
                case Some(v) => match (v) {
                    case i: Int64 => scene.background = Some(Color(UInt32(i)))
                    case s: String => scene.background = Some(textures.get(s) ?? Texture())
                    case _ => ()
                }
                case None => ()
            }
            match (data.get("environment")) {
                case Some(v) => match (v) {
                    case s: String => scene.environment = Some(textures.get(s) ?? Texture())
                    case _ => ()
                }
                case None => ()
            }
            match (data.get("fog")) {
                case Some(v) => match (v) {
                    case fogData: HashMap<String, Any> =>
                        let fogType = _getString(fogData, "type")
                        if (fogType == "Fog") {
                            let fogColor = fogData.get("color")
                            match (fogColor) {
                                case Some(c) => match (c) { case i: Int64 => scene.fog = Some(Fog(Color(UInt32(i)), near: _getFloat(fogData, "near", 1.0), far: _getFloat(fogData, "far", 1000.0))); case _ => () }
                                case None => ()
                            }
                        } else if (fogType == "FogExp2") {
                            let fogColor = fogData.get("color")
                            match (fogColor) {
                                case Some(c) => match (c) { case i: Int64 => scene.fogExp2 = Some(FogExp2(Color(UInt32(i)), density: _getFloat(fogData, "density", 0.00025))); case _ => () }
                                case None => ()
                            }
                        }
                    case _ => ()
                }
                case None => ()
            }
            object = scene
        } else if (typeStr == "PerspectiveCamera") {
            let fov = _getFloat(data, "fov", 50.0)
            let aspect = _getFloat(data, "aspect", 1.0)
            let near = _getFloat(data, "near", 0.1)
            let far = _getFloat(data, "far", 2000.0)
            let cam = PerspectiveCamera(fov: fov, aspect: aspect, near: near, far: far)
            match (data.get("focus")) { case Some(v) => match (v) { case f: Float64 => cam.focus = f; case _ => () }; case None => () }
            match (data.get("zoom")) { case Some(v) => match (v) { case z: Float64 => cam.zoom = z; case _ => () }; case None => () }
            object = cam
        } else if (typeStr == "OrthographicCamera") {
            let left = _getFloat(data, "left", -1.0)
            let right = _getFloat(data, "right", 1.0)
            let top = _getFloat(data, "top", 1.0)
            let bottom = _getFloat(data, "bottom", -1.0)
            let near = _getFloat(data, "near", 0.1)
            let far = _getFloat(data, "far", 2000.0)
            object = OrthographicCamera(left: left, right: right, top: top, bottom: bottom, near: near, far: far)
        } else if (typeStr == "AmbientLight") {
            let color = _getInt(data, "color", 0xffffff)
            let intensity = _getFloat(data, "intensity", 1.0)
            object = AmbientLight(color: Color(UInt32(color)), intensity: intensity)
        } else if (typeStr == "DirectionalLight") {
            let color = _getInt(data, "color", 0xffffff)
            let intensity = _getFloat(data, "intensity", 1.0)
            let dirLight = DirectionalLight(color: Color(UInt32(color)), intensity: intensity)
            match (data.get("target")) {
                case Some(v) => match (v) { case s: String => dirLight.target.uuid = s; case _ => () }
                case None => ()
            }
            object = dirLight
        } else if (typeStr == "PointLight") {
            let color = _getInt(data, "color", 0xffffff)
            let intensity = _getFloat(data, "intensity", 1.0)
            let distance = _getFloat(data, "distance", 0.0)
            let decay = _getFloat(data, "decay", 2.0)
            object = PointLight(color: Color(UInt32(color)), intensity: intensity, distance: distance, decay: decay)
        } else if (typeStr == "SpotLight") {
            let color = _getInt(data, "color", 0xffffff)
            let intensity = _getFloat(data, "intensity", 1.0)
            let distance = _getFloat(data, "distance", 0.0)
            let angle = _getFloat(data, "angle", PI / 3.0)
            let penumbra = _getFloat(data, "penumbra", 0.0)
            let decay = _getFloat(data, "decay", 2.0)
            object = SpotLight(color: Color(UInt32(color)), intensity: intensity, distance: distance, angle: angle, penumbra: penumbra, decay: decay)
        } else if (typeStr == "HemisphereLight") {
            let color = _getInt(data, "color", 0xffffff)
            let groundColor = _getInt(data, "groundColor", 0xffffff)
            let intensity = _getFloat(data, "intensity", 1.0)
            object = HemisphereLight(skyColor: Color(UInt32(color)), groundColor: Color(UInt32(groundColor)), intensity: intensity)
        } else if (typeStr == "SkinnedMesh") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            object = SkinnedMesh(geometry, material)
        } else if (typeStr == "Mesh") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            object = Mesh(geometry: geometry, material: material)
        } else if (typeStr == "InstancedMesh") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            let count = _getInt(data, "count", 0)
            object = InstancedMesh(geometry: geometry, material: material, count: count)
        } else if (typeStr == "Line") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            object = Line(geometry: geometry, material: material)
        } else if (typeStr == "LineLoop") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            object = LineLoop(geometry: geometry, material: material)
        } else if (typeStr == "LineSegments") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            object = LineSegments(geometry: geometry, material: material)
        } else if (typeStr == "Points" || typeStr == "PointCloud") {
            let geometry = getGeometryFromMap(data, geometries)
            let material = getMaterialFromMap(data, materials)
            object = Points(geometry: geometry, material: material)
        } else if (typeStr == "Sprite") {
            let material = getMaterialFromMap(data, materials)
            object = Sprite(material: material)
        } else if (typeStr == "Group") {
            object = Group()
        } else if (typeStr == "Bone") {
            object = Bone()
        } else if (typeStr == "LOD") {
            object = LOD()
        } else {
            object = Object3D()
        }

        // 设置通用属性
        object.uuid = _getString(data, "uuid")
        let name = _getString(data, "name")
        if (name != "") { object.name = name }

        match (data.get("matrix")) {
            case Some(v) => match (v) {
                case arr: Array<Float64> =>
                    if (arr.size >= 16) {
                        object.matrix.fromArray(arr, offset: 0)
                        object.matrix.decompose(object.position, object.quaternion, object.scale)
                    }
                case _ => ()
            }
            case None => ()
        }

        match (data.get("position")) { case Some(v) => match (v) { case arr: Array<Float64> => if (arr.size >= 3) { object.position.fromArray(arr, offset: 0) }; case _ => () }; case None => () }
        match (data.get("quaternion")) { case Some(v) => match (v) { case arr: Array<Float64> => if (arr.size >= 4) { object.quaternion.fromArray(arr, offset: 0) }; case _ => () }; case None => () }
        match (data.get("scale")) { case Some(v) => match (v) { case arr: Array<Float64> => if (arr.size >= 3) { object.scale.fromArray(arr, offset: 0) }; case _ => () }; case None => () }
        match (data.get("up")) { case Some(v) => match (v) { case arr: Array<Float64> => if (arr.size >= 3) { object.up.fromArray(arr, offset: 0) }; case _ => () }; case None => () }
        match (data.get("castShadow")) { case Some(v) => match (v) { case b: Bool => object.castShadow = b; case _ => () }; case None => () }
        match (data.get("receiveShadow")) { case Some(v) => match (v) { case b: Bool => object.receiveShadow = b; case _ => () }; case None => () }
        match (data.get("visible")) { case Some(v) => match (v) { case b: Bool => object.visible = b; case _ => () }; case None => () }
        match (data.get("frustumCulled")) { case Some(v) => match (v) { case b: Bool => object.frustumCulled = b; case _ => () }; case None => () }
        match (data.get("renderOrder")) { case Some(v) => match (v) { case f: Float64 => object.renderOrder = f; case _ => () }; case None => () }
        match (data.get("layers")) { case Some(v) => match (v) { case i: Int64 => object.layers.mask = UInt32(i); case _ => () }; case None => () }

        // 解析子对象
        match (data.get("children")) {
            case Some(v) => match (v) {
                case childrenArr: Array<HashMap<String, Any>> =>
                    for (childData in childrenArr) {
                        let child = this._parseObject(childData, geometries, materials, textures, animations)
                        object.add(child)
                    }
                case _ => ()
            }
            case None => ()
        }

        // 绑定动画
        match (data.get("animations")) {
            case Some(v) => match (v) {
                case animArr: Array<Any> =>
                    for (animRef in animArr) {
                        match (animRef) {
                            case uuid: String =>
                                match (animations.get(uuid)) {
                                    case Some(clip) => object.animations.add(clip)
                                    case None => ()
                                }
                            case _ => ()
                        }
                    }
                case _ => ()
            }
            case None => ()
        }

        // LOD 特殊处理
        if (typeStr == "LOD") {
            match (data.get("levels")) {
                case Some(v) => match (v) {
                    case levelsArr: Array<HashMap<String, Any>> =>
                        for (levelData in levelsArr) {
                            let levelObjUuid = _getString(levelData, "object")
                            let distance = _getFloat(levelData, "distance", 0.0)
                            // 查找子对象（递归搜索）
                            let foundChild = _findChildByUuid(object, levelObjUuid)
                            match (foundChild) {
                                case Some(child) =>
                                    match (object) {
                                        case lod: LOD => lod.addLevel(child, distance: distance)
                                        case _ => ()
                                    }
                                case None => ()
                            }
                        }
                    case _ => ()
                }
                case None => ()
            }
        }

        return object
    }

    /**
     * @brief[zh-cn] 解析骨骼
     * @explain[zh-cn] 对应 JS: parseSkeletons(json, object)
     * @param[zh-cn] jsonOpt JSON 中的骨骼数据
     * object 场景根对象（用于查找骨骼节点）
     * @return[zh-cn] UUID 到 Skeleton 的映射
     *
     * @brief[en] Parse skeletons
     * @explain[en] Parses skeleton data from JSON
     * @param[en] jsonOpt Skeleton data in JSON
     * object Scene root object (for finding bone nodes)
     * @return[en] UUID to Skeleton mapping
     */
    public func parseSkeletons(jsonOpt: Option<Any>, object: Object3D): HashMap<String, Skeleton> {
        let skeletons = HashMap<String, Skeleton>()
        let bones = HashMap<String, Bone>()

        // 生成骨骼查找表
        object.traverse({ child =>
            match (child) {
                case b: Bone => bones.add(b.uuid, b)
                case _ => ()
            }
        })

        match (jsonOpt) {
            case Some(val) =>
                match (val) {
                    case jsonArr: Array<HashMap<String, Any>> =>
                        for (i in 0..jsonArr.size) {
                            let data = jsonArr[i]
                            let boneArr = ArrayList<Bone>()
                            let boneInverseArr = ArrayList<Matrix4>()

                            match (data.get("bones")) {
                                case Some(bonesVal) =>
                                    match (bonesVal) {
                                        case boneUuids: Array<Any> =>
                                            for (boneUuid in boneUuids) {
                                                match (boneUuid) {
                                                    case uuid: String =>
                                                        match (bones.get(uuid)) {
                                                            case Some(b) => boneArr.add(b)
                                                            case None => ()
                                                        }
                                                    case _ => ()
                                                }
                                            }
                                        case _ => ()
                                    }
                                case None => ()
                            }

                            match (data.get("boneInverses")) {
                                case Some(invVal) =>
                                    match (invVal) {
                                        case invArr: Array<Any> =>
                                            for (invData in invArr) {
                                                match (invData) {
                                                    case arr: Array<Float64> =>
                                                        if (arr.size >= 16) {
                                                            let m = Matrix4()
                                                            m.fromArray(arr, offset: 0)
                                                            boneInverseArr.add(m)
                                                        }
                                                    case _ => ()
                                                }
                                            }
                                        case _ => ()
                                    }
                                case None => ()
                            }

                            let skeleton = Skeleton(bones: boneArr, boneInverses: boneInverseArr)
                            skeleton.uuid = _getString(data, "uuid")
                            skeletons.add(skeleton.uuid, skeleton)
                        }
                    case _ => ()
                }
            case None => ()
        }
        return skeletons
    }

    /**
     * @brief[zh-cn] 绑定骨骼到蒙皮网格
     * @explain[zh-cn] 对应 JS: bindSkeletons(object, skeletons)
     * @param[zh-cn] object 场景根对象
     * skeletons 骨骼映射
     *
     * @brief[en] Bind skeletons to skinned meshes
     * @explain[en] Binds skeletons to skinned meshes
     * @param[en] object Scene root object
     * skeletons Skeleton mapping
     */
    public func bindSkeletons(object: Object3D, skeletons: HashMap<String, Skeleton>): Unit {
        if (skeletons.size == 0) { return }
        object.traverse({ child =>
            match (child) {
                case mesh: SkinnedMesh =>
                    let skelUuid = mesh.skeleton.uuid
                    if (skelUuid != "") {
                        match (skeletons.get(skelUuid)) {
                            case Some(skel) => mesh.bind(skel, bindMatrix: mesh.bindMatrix)
                            case None => ()
                        }
                    }
                case _ => ()
            }
        })
    }

    /**
     * @brief[zh-cn] 绑定光源目标
     * @explain[zh-cn] 遍历场景中的光源，将其 target 绑定到对应 Object3D
     * @param[zh-cn] object 场景根对象
     *
     * @brief[en] Bind light targets
     * @explain[en] Binds light targets to corresponding Object3D
     * @param[en] object Scene root object
     */
    public func bindLightTargets(object: Object3D): Unit {
        object.traverse({ child =>
            match (child) {
                case dirLight: DirectionalLight =>
                    let targetUuid = dirLight.target.uuid
                    if (targetUuid != "") {
                        let found = _findChildByUuid(object, targetUuid)
                        match (found) {
                            case Some(target) => dirLight.target = target
                            case None => dirLight.target = Object3D()
                        }
                    }
                case spotLight: SpotLight =>
                    let targetUuid = spotLight.target.uuid
                    if (targetUuid != "") {
                        let found = _findChildByUuid(object, targetUuid)
                        match (found) {
                            case Some(target) => spotLight.target = target
                            case None => spotLight.target = Object3D()
                        }
                    }
                case _ => ()
            }
        })
    }

    /**
     * @brief[zh-cn] 使用 cjfast_json 将 JSON 字符串解析为 HashMap
     * @explain[zh-cn] 对应 JS: JSON.parse(text)
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

// ===== 辅助函数 =====

internal func _getString(map: HashMap<String, Any>, key: String): String {
    let optVal = map.get(key)
    if (optVal.isSome()) {
        let v = optVal.getOrThrow()
        match (v) {
            case s: String => return s
            case _ => return ""
        }
    }
    return ""
}

internal func _getFloat(map: HashMap<String, Any>, key: String, defaultVal: Float64): Float64 {
    let optVal = map.get(key)
    if (optVal.isSome()) {
        let v = optVal.getOrThrow()
        match (v) {
            case f: Float64 => return f
            case i: Int64 => return Float64(i)
            case _ => return defaultVal
        }
    }
    return defaultVal
}

internal func _getInt(map: HashMap<String, Any>, key: String, defaultVal: Int64): Int64 {
    let optVal = map.get(key)
    if (optVal.isSome()) {
        let v = optVal.getOrThrow()
        match (v) {
            case i: Int64 => return i
            case f: Float64 => return Int64(f)
            case _ => return defaultVal
        }
    }
    return defaultVal
}

internal func getGeometryFromMap(data: HashMap<String, Any>, geometries: HashMap<String, BufferGeometry>): BufferGeometry {
    match (data.get("geometry")) {
        case Some(v) => match (v) {
            case uuid: String => return geometries.get(uuid) ?? BufferGeometry()
            case _ => return BufferGeometry()
        }
        case None => return BufferGeometry()
    }
}

internal func getMaterialFromMap(data: HashMap<String, Any>, materials: HashMap<String, Material>): Material {
    match (data.get("material")) {
        case Some(v) => match (v) {
            case uuid: String => return materials.get(uuid) ?? Material()
            case _ => return Material()
        }
        case None => return Material()
    }
}

// 递归查找指定 UUID 的子对象
internal func _findChildByUuid(root: Object3D, uuid: String): Option<Object3D> {
    if (root.uuid == uuid) { return Some(root) }
    for (child in root.children) {
        let result = _findChildByUuid(child, uuid)
        if (result.isSome()) { return result }
    }
    return None
}

/**
 * @param[zh-cn] type 几何类型字符串
 * @param[zh-cn] data JSON 几何数据
 * @param[zh-cn] shapes 形状映射（ExtrudeGeometry/ShapeGeometry 霗要）
 * @return[zh-cn] 对应几何子类实例，未知类型返回默认 BufferGeometry
 *
 * @param[en] type Geometry type string
 * @param[en] data JSON geometry data
 * @param[en] shapes Shape mapping (needed for ExtrudeGeometry/ShapeGeometry)
 * @return[en] Corresponding geometry subclass instance, returns default BufferGeometry for unknown types
 *
 * 按 type 分发到具体几何子类，读取 JSON 的参数字段调用对应构造函数。
 * CJ 侧几何子类多数无静态 fromJSON，故按 type 名称实例化对应类并按 parameters 字段调用构造函数。
 */
internal func _dispatchGeometry(`type`: String, data: HashMap<String, Any>, shapes: HashMap<String, Shape>): BufferGeometry {
    // JS 侧几何数据直接将构造参数放在顶层（data.width 等），故从 data 顶层取参数
    match (`type`) {
        case "BoxGeometry" =>
            return BoxGeometry(
                width: _getFloat(data, "width", 1.0),
                height: _getFloat(data, "height", 1.0),
                depth: _getFloat(data, "depth", 1.0),
                widthSegments: _getInt(data, "widthSegments", 1),
                heightSegments: _getInt(data, "heightSegments", 1),
                depthSegments: _getInt(data, "depthSegments", 1)
            )
        case "PlaneGeometry" =>
            return PlaneGeometry(
                width: _getFloat(data, "width", 1.0),
                height: _getFloat(data, "height", 1.0),
                widthSegments: _getInt(data, "widthSegments", 1),
                heightSegments: _getInt(data, "heightSegments", 1)
            )
        case "SphereGeometry" =>
            return SphereGeometry(
                radius: _getFloat(data, "radius", 1.0),
                widthSegments: _getInt(data, "widthSegments", 32),
                heightSegments: _getInt(data, "heightSegments", 16),
                phiStart: _getFloat(data, "phiStart", 0.0),
                phiLength: _getFloat(data, "phiLength", PI * 2.0),
                thetaStart: _getFloat(data, "thetaStart", 0.0),
                thetaLength: _getFloat(data, "thetaLength", PI)
            )
        case "ConeGeometry" =>
            return ConeGeometry(
                radius: _getFloat(data, "radius", 1.0),
                height: _getFloat(data, "height", 1.0),
                radialSegments: _getInt(data, "radialSegments", 8),
                heightSegments: _getInt(data, "heightSegments", 1),
                openEnded: _getBool(data, "openEnded", false),
                thetaStart: _getFloat(data, "thetaStart", 0.0),
                thetaLength: _getFloat(data, "thetaLength", PI * 2.0)
            )
        case "CylinderGeometry" =>
            return CylinderGeometry(
                radiusTop: _getFloat(data, "radiusTop", 1.0),
                radiusBottom: _getFloat(data, "radiusBottom", 1.0),
                height: _getFloat(data, "height", 1.0),
                radialSegments: _getInt(data, "radialSegments", 8),
                heightSegments: _getInt(data, "heightSegments", 1),
                openEnded: _getBool(data, "openEnded", false),
                thetaStart: _getFloat(data, "thetaStart", 0.0),
                thetaLength: _getFloat(data, "thetaLength", PI * 2.0)
            )
        case "TorusGeometry" =>
            return TorusGeometry(
                radius: _getFloat(data, "radius", 1.0),
                tube: _getFloat(data, "tube", 0.4),
                radialSegments: _getInt(data, "radialSegments", 12),
                tubularSegments: _getInt(data, "tubularSegments", 48),
                arc: _getFloat(data, "arc", PI * 2.0),
                thetaStart: _getFloat(data, "thetaStart", 0.0),
                thetaLength: _getFloat(data, "thetaLength", PI * 2.0)
            )
        case "TorusKnotGeometry" =>
            return TorusKnotGeometry(
                radius: _getFloat(data, "radius", 1.0),
                tube: _getFloat(data, "tube", 0.4),
                tubularSegments: _getInt(data, "tubularSegments", 64),
                radialSegments: _getInt(data, "radialSegments", 8),
                p: _getInt(data, "p", 2),
                q: _getInt(data, "q", 3)
            )
        case "RingGeometry" =>
            return RingGeometry(
                innerRadius: _getFloat(data, "innerRadius", 0.5),
                outerRadius: _getFloat(data, "outerRadius", 1.0),
                thetaSegments: _getInt(data, "thetaSegments", 32),
                phiSegments: _getInt(data, "phiSegments", 1),
                thetaStart: _getFloat(data, "thetaStart", 0.0),
                thetaLength: _getFloat(data, "thetaLength", PI * 2.0)
            )
        case "CircleGeometry" =>
            return CircleGeometry(
                radius: _getFloat(data, "radius", 1.0),
                segments: _getInt(data, "segments", 32),
                thetaStart: _getFloat(data, "thetaStart", 0.0),
                thetaLength: _getFloat(data, "thetaLength", PI * 2.0)
            )
        case "CapsuleGeometry" =>
            return CapsuleGeometry(
                radius: _getFloat(data, "radius", 1.0),
                length: _getFloat(data, "length", 1.0),
                capSegments: _getInt(data, "capSegments", 4),
                radialSegments: _getInt(data, "radialSegments", 8),
                heightSegments: _getInt(data, "heightSegments", 1)
            )
        case "DodecahedronGeometry" =>
            return DodecahedronGeometry(
                radius: _getFloat(data, "radius", 1.0),
                detail: _getInt(data, "detail", 0)
            )
        case "IcosahedronGeometry" =>
            return IcosahedronGeometry(
                radius: _getFloat(data, "radius", 1.0),
                detail: _getInt(data, "detail", 0)
            )
        case "OctahedronGeometry" =>
            return OctahedronGeometry.fromJSON(data)
        case "TetrahedronGeometry" =>
            return TetrahedronGeometry.fromJSON(data)
        case "PolyhedronGeometry" =>
            return PolyhedronGeometry.fromJSON(data)
        // LatheGeometry/TubeGeometry/ExtrudeGeometry/ShapeGeometry/WireframeGeometry/EdgesGeometry
        // 霗 Vector2/Shape/Curve 复杂对象，仓颉侧 fromJSON 范围之外，保留默认几何体并标记 Ignore。
        case _ =>
            // 未知类型：对照 JS warn，返回默认 BufferGeometry（后续渲染时可见为空）
            return BufferGeometry()
    }
}

internal func _getBool(map: HashMap<String, Any>, key: String, defaultVal: Bool): Bool {
    let optVal = map.get(key)
    if (optVal.isSome()) {
        let v = optVal.getOrThrow()
        match (v) {
            case b: Bool => return b
            case _ => return defaultVal
        }
    }
    return defaultVal
}