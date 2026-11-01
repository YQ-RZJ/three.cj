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
 * @file[zh-cn] GltfLoader glTF 加载器
 * @brief[zh-cn] 加载 glTF 格式的 3D 模型
 * @explain[zh-cn] 完整解析 glTF 的核心功能：顶点属性、索引缓冲、材质（PBR Metallic-Roughness）、纹理贴图、场景层级、多网格多图元。
 *
 * @file[en] GltfLoader  glTF loader
 * @brief[en] Loads glTF format 3D models
 * @explain[en] Fully parses glTF core features: vertex attributes, index buffers, materials (PBR Metallic-Roughness), texture maps, scene hierarchy, multi-mesh multi-primitive.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import std.collection.*
import std.fs.*
import std.io.*
import std.math.*
import three.rendering.buffer.*
import three.rendering.geometry.BufferGeometry
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.textures.*
import three.scene.scenegraph.*
import three.scene.entity.*
import bgfx4cj.bimg.*
import fastjson.*
import fastjson.stream.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.AutoFreePtr

/**
 * @brief[zh-cn] glTF 加载器，加载 .gltf / .glb 格式的 3D 模型
 * @explain[zh-cn] 解析 glTF JSON 为 Group，包含网格和材质。
 *
 * @brief[en] glTF loader, loads .gltf / .glb format 3D models
 * @explain[en] Parses glTF JSON into a Group containing meshes and materials.
 *
 * @extends Loader
 */
/**
 * @brief[zh-cn] glTF 加载器，加载 .gltf / .glb 格式的 3D 模型
 * @explain[zh-cn] 解析 glTF JSON 为 Group，包含网格和材质。
 *
 * @brief[en] glTF loader, loads .gltf / .glb format 3D models
 * @explain[en] Parses glTF JSON into a Group containing meshes and materials.
 *
 * @extends Loader
 */
public class GltfLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 模型文件 URL
     * @param[zh-cn] onLoad 加载完成回调，参数为 Scene
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Model file URL
     * @param[en] onLoad Load complete callback, parameter is Scene
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载 glTF 模型
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        try {
            this.manager.itemStart(url)
            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = Path(fullPath)
            let bytes = File.readFrom(filePath)

            // 判断文件类型
            let nameStr = fullPath
            let ext = if (nameStr.contains(".")) {
                nameStr[nameStr.lastIndexOf(".").getOrThrow() + 1..]
            } else { "" }
            let jsonData: HashMap<String, Any>
            let binData: Array<UInt8>
            let basePath: String

            if (ext == "glb") {
                let (json, bin) = parseGlb(bytes)
                jsonData = json
                binData = bin
                basePath = getBasePath(nameStr)
            } else {
                let jsonStr = String.fromUtf8(bytes)
                jsonData = this.parseJsonToHashMap(jsonStr)
                binData = Array<UInt8>()
                basePath = getBasePath(nameStr)
            }

            // 完整解析 glTF JSON 为 Group
            let modelGroup = this.parse(jsonData, binData, basePath)

            this.manager.itemEnd(url)
            onLoad(modelGroup)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    // =========================================================================
    // 辅助函数
    // =========================================================================

    private func toArrayAny(v: Any): Array<Any> {
        match (v) {
            case arr: Array<Any> => arr
            case al: ArrayList<Any> =>
                let result = Array<Any>(al.size, { i => al[i] })
                result
            case _ => Array<Any>()
        }
    }

    private func getBasePath(nameStr: String): String {
        if (nameStr.contains("/") || nameStr.contains("\\")) {
            let idx1 = nameStr.lastIndexOf("/")
            let idx2 = nameStr.lastIndexOf("\\")
            let lastSep = if (idx1.isSome() && idx2.isSome()) {
                if (idx1.getOrThrow() > idx2.getOrThrow()) { idx1.getOrThrow() } else { idx2.getOrThrow() }
            } else if (idx1.isSome()) { idx1.getOrThrow() } else { idx2.getOrThrow() }
            nameStr[0..lastSep]
        } else { "." }
    }

    // =========================================================================
    // 主解析入口
    // =========================================================================

    /**
     * @param[zh-cn] json glTF JSON 数据
     * @param[zh-cn] binData GLB 文件的二进制块数据
     * @param[zh-cn] basePath 基础路径
     * @return[zh-cn] Group 包含加载的网格
     *
     * @param[en] json glTF JSON data
     * @param[en] binData GLB file binary chunk data
     * @param[en] basePath Base path
     * @return[en] Group containing loaded meshes
     *
     * 解析 glTF JSON 为 Group（包含所有网格和材质）
     */
    public func parse(json: HashMap<String, Any>, binData: Array<UInt8>, basePath: String): Group {
        let accessors = json.get("accessors")
        let bufferViews = json.get("bufferViews")
        let buffers = json.get("buffers")
        let meshes = json.get("meshes")
        let materials = json.get("materials")
        let textures = json.get("textures")
        let images = json.get("images")
        let samplers = json.get("samplers")

        let loadedBuffers = loadBuffers(buffers, binData, basePath)
        let parsedMaterials = parseMaterials(materials, textures, images, bufferViews, samplers, binData, basePath)

        // 解析 skins（骨骼蒙皮数据）
        let skinsOpt = json.get("skins")
        let nodesOpt = json.get("nodes")
        let parsedSkins = parseSkins(skinsOpt, nodesOpt, accessors, bufferViews, loadedBuffers)

        // 解析 animations（骨骼动画数据）
        let animationsOpt = json.get("animations")
        let parsedAnimations = parseAnimations(animationsOpt, accessors, bufferViews, loadedBuffers)

        let result = Group()
        result.name = "GLTFModel"

        // 构建 meshMap：meshIdx -> 该 mesh 的所有 primitive Mesh 列表（供 buildNodes 层级挂载）
        let meshMap = HashMap<Int64, ArrayList<Mesh>>()
        if (let Some(m) <- meshes) {
            let meshArr = toArrayAny(m)
            for (mi in 0..meshArr.size) {
                let meshObj = match (meshArr[mi]) {
                    case hm: HashMap<String, Any> => hm
                    case _ => continue
                }
                let primitives = if (let Some(p) <- meshObj.get("primitives")) { toArrayAny(p) } else { continue }
                let primMeshes = ArrayList<Mesh>()
                for (pi in 0..primitives.size) {
                    let prim = match (primitives[pi]) {
                        case hm: HashMap<String, Any> => hm
                        case _ => continue
                    }
                    let geom = buildGeometry(prim, accessors, bufferViews, loadedBuffers)
                    let mat = if (let Some(matIdx) <- prim.get("material")) {
                        let idx = getInt(matIdx)
                        parsedMaterials.get(idx)
                    } else {
                        let emptyNone: Option<Material> = None
                        emptyNone
                    }
                    let material = if (let Some(m) <- mat) {
                        m
                    } else {
                        let defaultMat = MeshBasicMaterial()
                        defaultMat.color = Color(0xcccccc)
                        defaultMat
                    }
                    let meshNode = Mesh(geometry: geom, material: material)
                    meshNode.name = "mesh_${mi}_prim_${pi}"
                    primMeshes.add(meshNode)
                }
                meshMap.add(Int64(mi), primMeshes)
            }
        }

        // 层级应用：优先走 scenes -> nodes 路径（应用节点变换矩阵/TRS 与层级），
        //   无 scenes/nodes 时回退平铺（兼容简单模型）；nodesOpt 复用上方 L206 的绑定
        let scenesOpt = json.get("scenes")
        var appliedHierarchy = false
        if (let Some(scenesVal) <- scenesOpt) {
            let scenesArr = toArrayAny(scenesVal)
            if (scenesArr.size > 0) {
                let sceneObj = match (scenesArr[0]) {
                    case hm: HashMap<String, Any> => hm
                    case _ => HashMap<String, Any>()
                }
                if (let Some(rootNodes) <- sceneObj.get("nodes")) {
                    let rootArr = toArrayAny(rootNodes)
                    let identity = Array<Float64>(16, { i => if (i % 5 == 0) { 1.0 } else { 0.0 } })
                    for (ri in 0..rootArr.size) {
                        let rootIdx = getInt(Some(rootArr[ri]))
                        let obj = buildNodes(rootIdx, nodesOpt, meshMap, identity, 0)
                        if (let Some(o) <- obj) { result.add(o) }
                    }
                    appliedHierarchy = true
                }
            }
        }

        // 回退：无 scenes/nodes 时，将所有 mesh 平铺到 Group（保持旧行为）
        if (!appliedHierarchy) {
            for ((mi, primMeshes) in meshMap) {
                for (meshNode in primMeshes) {
                    result.add(meshNode)
                }
            }
        }

        // 暴露骨骼/动画解析数据到 userData，供上层（如 GltfImportAdapter）构建运行时骨骼动画：
        //   gltfSkins/gltfAnimations 为结构化解析结果；
        //   gltfNodes/gltfAccessors/gltfBufferViews 为 JSON 原始 Any 数组；
        //   gltfBuffers 为已加载的二进制缓冲列表。
        let nodesArr = if (let Some(n) <- nodesOpt) { toArrayAny(n) } else { Array<Any>() }
        let accessorsArr = if (let Some(a) <- accessors) { toArrayAny(a) } else { Array<Any>() }
        let bufferViewsArr = if (let Some(bv) <- bufferViews) { toArrayAny(bv) } else { Array<Any>() }
        result.userData.add("gltfSkins", parsedSkins)
        result.userData.add("gltfAnimations", parsedAnimations)
        result.userData.add("gltfNodes", nodesArr)
        result.userData.add("gltfAccessors", accessorsArr)
        result.userData.add("gltfBufferViews", bufferViewsArr)
        result.userData.add("gltfBuffers", loadedBuffers)

        return result
    }

    // =========================================================================
    // 材质解析
    // =========================================================================

    private func parseMaterials(materialsOpt: Option<Any>, texturesOpt: Option<Any>, imagesOpt: Option<Any>, bufferViewsOpt: Option<Any>, samplersOpt: Option<Any>, binData: Array<UInt8>, basePath: String): HashMap<Int64, Material> {
        let result = HashMap<Int64, Material>()
        let materials = if (let Some(m) <- materialsOpt) { toArrayAny(m) } else { return result }
        for (i in 0..materials.size) {
            let matObj = match (materials[i]) {
                case hm: HashMap<String, Any> => hm
                case _ => continue
            }
            let material = buildMaterial(matObj, texturesOpt, imagesOpt, bufferViewsOpt, samplersOpt, binData, basePath)
            result.add(Int64(i), material)
        }
        return result
    }

    private func buildMaterial(matObj: HashMap<String, Any>, texturesOpt: Option<Any>, imagesOpt: Option<Any>, bufferViewsOpt: Option<Any>, samplersOpt: Option<Any>, binData: Array<UInt8>, basePath: String): Material {
        let material = MeshStandardMaterial()
        material.name = if (let Some(n) <- matObj.get("name")) {
            match (n) { case s: String => s; case _ => "material" }
        } else { "material" }

        // 解析 PBR Metallic-Roughness
        if (let Some(pbr) <- matObj.get("pbrMetallicRoughness")) {
            let pbrObj = match (pbr) { case hm: HashMap<String, Any> => hm; case _ => return material }
            // baseColorFactor
            if (let Some(factors) <- pbrObj.get("baseColorFactor")) {
                let arr = match (factors) { case a: Array<Any> => a; case _ => Array<Any>() }
                if (arr.size >= 3) {
                    let r = getFloat(Some(arr[0])); let g = getFloat(Some(arr[1]))
                    let b = getFloat(Some(arr[2])); let a = if (arr.size >= 4) { getFloat(Some(arr[3])) } else { 1.0 }
                    material.color = Color(r, g, b)
                    material.opacity = a
                    if (a < 1.0) { material.transparent = true }
                }
            }
            // metallicFactor / roughnessFactor
            // 参照 glTF 规范惯例：metallicFactor 默认 1.0, roughnessFactor 默认 1.0
            if (let Some(v) <- pbrObj.get("metallicFactor")) {
                material.metalness = getFloat(v)
            } else {
                material.metalness = 1.0  // glTF 默认金属度为 1.0
            }
            if (let Some(v) <- pbrObj.get("roughnessFactor")) {
                material.roughness = getFloat(v)
            } else {
                material.roughness = 1.0  // glTF 默认粗糙度为 1.0
            }
            // baseColorTexture
            if (let Some(texInfo) <- pbrObj.get("baseColorTexture")) {
                match (texInfo) {
                    case hm: HashMap<String, Any> =>
                        let tex = loadTexture(hm, texturesOpt, imagesOpt, bufferViewsOpt, samplersOpt, binData, basePath)
                        if (let Some(t) <- tex) { material.map = Some(t) }
                    case _ => ()
                }
            }
            // metallicRoughnessTexture
            if (let Some(texInfo) <- pbrObj.get("metallicRoughnessTexture")) {
                match (texInfo) {
                    case hm: HashMap<String, Any> =>
                        let tex = loadTexture(hm, texturesOpt, imagesOpt, bufferViewsOpt, samplersOpt, binData, basePath)
                        if (let Some(t) <- tex) {
                            material.metalnessMap = Some(t)
                            material.roughnessMap = Some(t)
                        }
                    case _ => ()
                }
            }
        }

        // normalTexture
        if (let Some(texInfo) <- matObj.get("normalTexture")) {
            match (texInfo) {
                case hm: HashMap<String, Any> =>
                    let tex = loadTexture(hm, texturesOpt, imagesOpt, bufferViewsOpt, samplersOpt, binData, basePath)
                    if (let Some(t) <- tex) { material.normalMap = Some(t) }
                case _ => ()
            }
        }
        // occlusionTexture
        if (let Some(texInfo) <- matObj.get("occlusionTexture")) {
            match (texInfo) {
                case hm: HashMap<String, Any> =>
                    let tex = loadTexture(hm, texturesOpt, imagesOpt, bufferViewsOpt, samplersOpt, binData, basePath)
                    if (let Some(t) <- tex) { material.aoMap = Some(t) }
                case _ => ()
            }
        }
        // emissiveTexture
        if (let Some(texInfo) <- matObj.get("emissiveTexture")) {
            match (texInfo) {
                case hm: HashMap<String, Any> =>
                    let tex = loadTexture(hm, texturesOpt, imagesOpt, bufferViewsOpt, samplersOpt, binData, basePath)
                    if (let Some(t) <- tex) { material.emissiveMap = Some(t) }
                case _ => ()
            }
        }
        // emissiveFactor
        if (let Some(factors) <- matObj.get("emissiveFactor")) {
            let arr = match (factors) { case a: Array<Any> => a; case _ => Array<Any>() }
            if (arr.size >= 3) {
                let r = getFloat(Some(arr[0])); let g = getFloat(Some(arr[1])); let b = getFloat(Some(arr[2]))
                material.emissive = Color(r, g, b)
            }
        }
        // alphaMode
        if (let Some(mode) <- matObj.get("alphaMode")) {
            let modeStr = match (mode) { case s: String => s; case _ => "" }
            if (modeStr == "BLEND") { material.transparent = true }
            else if (modeStr == "MASK") { material.transparent = true }
        }
        // doubleSided
        if (let Some(ds) <- matObj.get("doubleSided")) {
            match (ds) {
                case b: Bool => if (b) { material.side = 2 } // DoubleSide
                case _ => ()
            }
        }

        return material
    }

    private func loadTexture(texInfo: HashMap<String, Any>, texturesOpt: Option<Any>, imagesOpt: Option<Any>, bufferViewsOpt: Option<Any>, samplersOpt: Option<Any>, binData: Array<UInt8>, basePath: String): Option<Texture> {
        // 获取纹理索引
        let texIdx = getInt(texInfo.get("index"))
        let textures = if (let Some(t) <- texturesOpt) { toArrayAny(t) } else { return None }
        if (texIdx < 0 || texIdx >= textures.size) { return None }
        let texDef = match (textures[texIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return None
        }
        // 获取图像源索引
        let sourceIdx = getInt(texDef.get("source"))
        let images = if (let Some(img) <- imagesOpt) { toArrayAny(img) } else { return None }
        if (sourceIdx < 0 || sourceIdx >= images.size) { return None }
        let imgDef = match (images[sourceIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return None
        }
        // 读取 bufferView 中的图像数据
        let bvIdx = getInt(imgDef.get("bufferView"))
        let bufferViews = if (let Some(bv) <- bufferViewsOpt) { toArrayAny(bv) } else { return None }
        if (bvIdx < 0 || bvIdx >= bufferViews.size) { return None }
        let bv = match (bufferViews[bvIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return None
        }
        let bvByteOffset = getInt(bv.get("byteOffset"))
        let bvByteLength = getInt(bv.get("byteLength"))
        let start = bvByteOffset
        let end = start + bvByteLength
        if (start < 0 || end > Int64(binData.size)) { return None }
        // 提取原始图像数据（PNG 字节）
        let imgBytes = Array<UInt8>(bvByteLength, { i => binData[start + i] })
        // 使用 bimg 解码 PNG 到 RGBA8
        let allocator = bimg_get_default_allocator_cj()
        let dataPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: bvByteLength) })
        let dataPtr = dataPtrHolder.get()
        unsafe {
            for (i in 0..bvByteLength) { (dataPtr + i).write(imgBytes[i]) }
        }
        // 解析并解码图像到 RGBA8 格式（bimg 的 TextureFormat 枚举与 bgfx 对齐，RGBA8=74；
        // 注意旧版 bimg 的 67 在新版中是 RG32F，不可再用魔法数字）
        let dstFormat: UInt32 = TextureFormat.RGBA8.value()
        let ic = bimg_image_parse_decode_cj(allocator, unsafe { CPointer<Unit>(dataPtr) }, UInt32(bvByteLength), dstFormat, CPointer<BimgError>())
        dataPtrHolder.dispose()
        if (ic.isNull()) {
            return None
        }
        // 获取解码后的图像信息
        let imgWidth = bimg_ic_get_width_cj(ic)
        let imgHeight = bimg_ic_get_height_cj(ic)
        let imgData = bimg_ic_get_data_cj(ic)
        let imgSize = bimg_ic_get_size_cj(ic)
        @LogDebug(["tex", "loaded: idx=${texIdx} w=${imgWidth.toString()} h=${imgHeight.toString()} size=${imgSize.toString()}"])
        if (imgWidth == 0u32 || imgHeight == 0u32 || imgSize == 0u32) {
            bimg_image_free_cj(ic)
            return None
        }
        // 复制 RGBA 像素数据到仓颉数组
        let rgbaData = Array<UInt8>(Int64(imgSize), { i =>
            unsafe { (CPointer<UInt8>(imgData) + i).read() }
        })
        // 释放 ImageContainer
        bimg_image_free_cj(ic)
        // 创建 DataTexture
        let texture = DataTexture(rgbaData, Int64(imgWidth), Int64(imgHeight))
        texture.name = if (let Some(n) <- texDef.get("name")) {
            match (n) { case s: String => s; case _ => "texture_${texIdx}" }
        } else { "texture_${texIdx}" }
        texture.flipY = false
        // 应用采样器设置
        if (let Some(samplerIdx) <- texDef.get("sampler")) {
            let samplers = if (let Some(s) <- samplersOpt) { toArrayAny(s) } else { Array<Any>() }
            let sIdx = getInt(samplerIdx)
            if (sIdx >= 0 && sIdx < samplers.size) {
                match (samplers[sIdx]) {
                    case hm: HashMap<String, Any> =>
                        if (let Some(v) <- hm.get("magFilter")) { texture.magFilter = getInt(v) }
                        if (let Some(v) <- hm.get("minFilter")) { texture.minFilter = getInt(v) }
                        if (let Some(v) <- hm.get("wrapS")) { texture.wrapS = getInt(v) }
                        if (let Some(v) <- hm.get("wrapT")) { texture.wrapT = getInt(v) }
                    case _ => ()
                }
            }
        }
        return Some(texture)
    }

    // =========================================================================
    // 场景层级构建
    // =========================================================================

    private func buildNodes(nodeIdx: Int64, nodesOpt: Option<Any>, meshMap: HashMap<Int64, ArrayList<Mesh>>, parentMatrix: Array<Float64>, depth: Int64): Option<Object3D> {
        let nodes = if (let Some(n) <- nodesOpt) { toArrayAny(n) } else { return None }
        if (nodeIdx < 0 || nodeIdx >= nodes.size) { return None }
        let node = match (nodes[nodeIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return None
        }
        let group = Group()
        group.name = if (let Some(n) <- node.get("name")) {
            match (n) { case s: String => s; case _ => "node_${nodeIdx}" }
        } else { "node_${nodeIdx}" }

        // 解析变换矩阵
        let matrix = Array<Float64>(16, { i => if (i % 5 == 0) { 1.0 } else { 0.0 } })
        if (let Some(m) <- node.get("matrix")) {
            let arr = match (m) { case a: Array<Any> => a; case _ => Array<Any>() }
            if (arr.size >= 16) {
                for (i in 0..16) {
                    matrix[i] = getFloat(Some(arr[i]))
                }
            }
        } else {
            // 解析 TRS
            if (let Some(t) <- node.get("translation")) {
                let arr = match (t) { case a: Array<Any> => a; case _ => Array<Any>() }
                if (arr.size >= 3) {
                    matrix[12] = getFloat(Some(arr[0]))
                    matrix[13] = getFloat(Some(arr[1]))
                    matrix[14] = getFloat(Some(arr[2]))
                }
            }
            if (let Some(r) <- node.get("rotation")) {
                let arr = match (r) { case a: Array<Any> => a; case _ => Array<Any>() }
                if (arr.size >= 4) {
                    let qx = getFloat(Some(arr[0])); let qy = getFloat(Some(arr[1]))
                    let qz = getFloat(Some(arr[2])); let qw = getFloat(Some(arr[3]))
                    let quat = Quaternion(qx, qy, qz, qw)
                    let rotMat = Matrix4().makeRotationFromQuaternion(quat)
                    let me = rotMat.elements
                    for (i in 0..3) {
                        matrix[i] = me[i]; matrix[4 + i] = me[4 + i]; matrix[8 + i] = me[8 + i]
                    }
                }
            }
            if (let Some(s) <- node.get("scale")) {
                let arr = match (s) { case a: Array<Any> => a; case _ => Array<Any>() }
                if (arr.size >= 3) {
                    let sx = getFloat(Some(arr[0])); let sy = getFloat(Some(arr[1])); let sz = getFloat(Some(arr[2]))
                    for (i in 0..3) {
                        matrix[i] *= sx; matrix[4 + i] *= sy; matrix[8 + i] *= sz
                    }
                }
            }
        }

        // 设置局部矩阵
        group.matrix.fromArray(matrix)
        group.matrixAutoUpdate = false

        // 添加 Mesh
        if (let Some(meshIdx) <- node.get("mesh")) {
            let idx = getInt(meshIdx)
            if (let Some(meshes) <- meshMap.get(idx)) {
                for (m in meshes) {
                    group.add(m)
                }
            }
        }

        // 递归子节点
        if (let Some(children) <- node.get("children")) {
            let childArr = toArrayAny(children)
            for (ci in 0..childArr.size) {
                let childIdx = getInt(Some(childArr[ci]))
                let childObj = buildNodes(childIdx, nodesOpt, meshMap, matrix, depth + 1)
                if (let Some(o) <- childObj) { group.add(o) }
            }
        }

        return Some(group)
    }

    // =========================================================================
    // 几何体构建
    // =========================================================================

    private func buildGeometry(prim: HashMap<String, Any>, accessorsOpt: Option<Any>, bufferViewsOpt: Option<Any>, loadedBuffers: ArrayList<Array<UInt8>>): BufferGeometry {
        let geom = BufferGeometry()

        if (let Some(idxAccessorIdx) <- prim.get("indices")) {
            let idx = getInt(idxAccessorIdx)
            let idxData = readAccessorData(idx, accessorsOpt, bufferViewsOpt, loadedBuffers)
            if (let Some(data) <- idxData) { geom.setIndex(BufferAttribute(data, 1)) }
        }

        if (let Some(attrVal) <- prim.get("attributes")) {
            let attrs = match (attrVal) {
                case hm: HashMap<String, Any> => hm
                case _ => return geom
            }
            if (let Some(v) <- attrs.get("POSITION")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("position", BufferAttribute(d, 3)) }
            }
            if (let Some(v) <- attrs.get("NORMAL")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("normal", BufferAttribute(d, 3)) }
            }
            if (let Some(v) <- attrs.get("TEXCOORD_0")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("uv", BufferAttribute(d, 2)) }
            }
            if (let Some(v) <- attrs.get("COLOR_0")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("color", BufferAttribute(d, 3)) }
            }
            if (let Some(v) <- attrs.get("TANGENT")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("tangent", BufferAttribute(d, 4)) }
            }
            if (let Some(v) <- attrs.get("TEXCOORD_1")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("uv2", BufferAttribute(d, 2)) }
            }
            if (let Some(v) <- attrs.get("JOINTS_0")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("skinIndex", BufferAttribute(d, 4)) }
            }
            if (let Some(v) <- attrs.get("WEIGHTS_0")) {
                let accIdx = getInt(v)
                let data = readAccessorData(accIdx, accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(d) <- data) { geom.setAttribute("skinWeight", BufferAttribute(d, 4)) }
            }
        }
        return geom
    }

    // =========================================================================
    // 访问器数据读取
    // =========================================================================

    private func readAccessorData(accessorIdx: Int64, accessorsOpt: Option<Any>, bufferViewsOpt: Option<Any>, loadedBuffers: ArrayList<Array<UInt8>>): Option<Array<Float64>> {
        let accessors = if (let Some(a) <- accessorsOpt) {
            let arr = toArrayAny(a)
            if (arr.size == 0) { return None }
            arr
        } else { return None }
        if (accessorIdx < 0 || accessorIdx >= accessors.size) { return None }
        let accessor = match (accessors[accessorIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return None
        }
        let bufferViewIdx = getInt(accessor.get("bufferView"))
        let byteOffset = getInt(accessor.get("byteOffset"))
        let componentType = getInt(accessor.get("componentType"))
        let count = getInt(accessor.get("count"))
        let typeStr = if (let Some(s) <- accessor.get("type")) {
            match (s) { case str: String => str; case _ => "SCALAR" }
        } else { "SCALAR" }
        let numComponents = match (typeStr) {
            case "SCALAR" => 1; case "VEC2" => 2; case "VEC3" => 3; case "VEC4" => 4
            case "MAT2" => 4; case "MAT3" => 9; case "MAT4" => 16
            case _ => 1
        }

        let bufferViews = if (let Some(b) <- bufferViewsOpt) {
            let arr = toArrayAny(b)
            if (arr.size == 0) { return None }
            arr
        } else { return None }
        if (bufferViewIdx < 0 || bufferViewIdx >= bufferViews.size) { return None }
        let bv = match (bufferViews[bufferViewIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return None
        }
        let bufferIdx = getInt(bv.get("buffer"))
        let bvByteOffset = getInt(bv.get("byteOffset"))
        let bvByteLength = getInt(bv.get("byteLength"))

        if (bufferIdx < 0 || bufferIdx >= loadedBuffers.size) { return None }
        let bufferData = loadedBuffers[bufferIdx]

        let componentSize = match (componentType) {
            case 5120 => 1; case 5121 => 1; case 5122 => 2
            case 5123 => 2; case 5125 => 4; case 5126 => 4
            case _ => 4
        }
        // 支持 interleaved bufferView：若 bufferView 显式声明 byteStride，以其为步长
        //（GLB 顶点属性常共享 bufferView，紧凑 stride 会导致数据错位）
        let bvByteStride = getInt(bv.get("byteStride"))
        let stride = if (bvByteStride > 0) { bvByteStride } else { numComponents * componentSize }
        let start = bvByteOffset + byteOffset
        let result = Array<Float64>(count * numComponents, { _ => 0.0 })

        if (componentType == 5126) {
            // Float32：一次性分配 raw 缓冲区批量转换（避免每分量 malloc/free，
            // LittlestTokyo 127 万顶点场景下每分量 malloc 会卡死解析）
            let total = count * numComponents
            let rawHolder = AutoFreePtr<UInt32>(unsafe { LibC.malloc<UInt32>(count: total) })
            let rawPtr = rawHolder.get()
            for (i in 0..count) {
                for (c in 0..numComponents) {
                    let bytePos = start + i * stride + c * componentSize
                    if (bytePos + componentSize > bufferData.size) { continue }
                    let b0 = UInt32(bufferData[bytePos]); let b1 = UInt32(bufferData[bytePos + 1])
                    let b2 = UInt32(bufferData[bytePos + 2]); let b3 = UInt32(bufferData[bytePos + 3])
                    let raw = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
                    unsafe { (rawPtr + i * numComponents + c).write(raw) }
                }
            }
            let fPtr = CPointer<Float32>(CPointer<Unit>(rawPtr))
            for (i in 0..total) {
                result[i] = Float64(unsafe { (fPtr + i).read() })
            }
            rawHolder.dispose()
        } else {
            // 其他 componentType：逐分量转换（小数据量，无需批量优化）
            for (i in 0..count) {
                for (c in 0..numComponents) {
                    let bytePos = start + i * stride + c * componentSize
                    if (bytePos + componentSize > bufferData.size) { continue }
                    if (componentType == 5123) {
                        let val = UInt32(bufferData[bytePos]) | (UInt32(bufferData[bytePos + 1]) << 8)
                        result[i * numComponents + c] = Float64(val)
                    } else if (componentType == 5125) {
                        let val = UInt32(bufferData[bytePos]) | (UInt32(bufferData[bytePos + 1]) << 8) | (UInt32(bufferData[bytePos + 2]) << 16) | (UInt32(bufferData[bytePos + 3]) << 24)
                        result[i * numComponents + c] = Float64(val)
                    } else if (componentType == 5122) {
                        let val = Int16(UInt32(bufferData[bytePos]) | (UInt32(bufferData[bytePos + 1]) << 8))
                        result[i * numComponents + c] = Float64(val)
                    } else if (componentType == 5120) {
                        let val = Int8(bufferData[bytePos])
                        result[i * numComponents + c] = Float64(val)
                    } else if (componentType == 5121) {
                        result[i * numComponents + c] = Float64(bufferData[bytePos])
                    } else {
                        result[i * numComponents + c] = 0.0
                    }
                }
            }
        }
        return Some(result)
    }

    // =========================================================================
    // GLB 解析
    // =========================================================================

    public func parseGlb(data: Array<UInt8>): (HashMap<String, Any>, Array<UInt8>) {
        if (data.size < 12) { return (HashMap<String, Any>(), Array<UInt8>()) }
        let magic = UInt32(data[0]) | (UInt32(data[1]) << 8) | (UInt32(data[2]) << 16) | (UInt32(data[3]) << 24)
        if (magic != 0x46546C67u32) { return (HashMap<String, Any>(), Array<UInt8>()) }
        var jsonResult = HashMap<String, Any>()
        var binResult = Array<UInt8>()
        var offset = Int64(12)
        while (offset < Int64(data.size)) {
            if (offset + 8 > Int64(data.size)) { break }
            let chunkLen = Int64(UInt32(data[offset]) | (UInt32(data[offset + 1]) << 8) | (UInt32(data[offset + 2]) << 16) | (UInt32(data[offset + 3]) << 24))
            let chunkType = UInt32(data[offset + 4]) | (UInt32(data[offset + 5]) << 8) | (UInt32(data[offset + 6]) << 16) | (UInt32(data[offset + 7]) << 24)
            offset += 8
            if (offset + chunkLen > Int64(data.size)) { break }
            if (chunkType == 0x4E4F534A) {
                let curOffset = offset
                let jsonBytes = Array<UInt8>(chunkLen, { i => data[curOffset + i] })
                let jsonStr = String.fromUtf8(jsonBytes)
                jsonResult = this.parseJsonToHashMap(jsonStr)
            } else if (chunkType == 0x004E4942) {
                let curOffset = offset
                binResult = Array<UInt8>(chunkLen, { i => data[curOffset + i] })
            }
            offset += chunkLen
        }
        return (jsonResult, binResult)
    }

    // =========================================================================
    // 缓冲加载
    // =========================================================================

    private func loadBuffers(buffersOpt: Option<Any>, binData: Array<UInt8>, basePath: String): ArrayList<Array<UInt8>> {
        let result = ArrayList<Array<UInt8>>()
        let buffers = if (let Some(b) <- buffersOpt) {
            let arr = toArrayAny(b)
            if (arr.size == 0) { return result }
            arr
        } else { return result }
        for (i in 0..buffers.size) {
            let buf = match (buffers[i]) {
                case hm: HashMap<String, Any> => hm
                case _ => continue
            }
            let byteLength = getInt(buf.get("byteLength"))
            if (let Some(uriVal) <- buf.get("uri")) {
                let uri = match (uriVal) { case s: String => s; case _ => continue }
                if (uri.startsWith("data:")) {
                    result.add(Array<UInt8>(byteLength, { _ => 0u8 }))
                } else {
                    let binPath = Path(basePath).join(uri)
                    try {
                        let binBytes = File.readFrom(binPath)
                        result.add(binBytes)
                    } catch (_: Exception) {
                        result.add(Array<UInt8>(byteLength, { _ => 0u8 }))
                    }
                }
            } else {
                result.add(binData)
            }
        }
        return result
    }

    // =========================================================================
    // glTF Skins 解析
    // =========================================================================

    /**
     * @brief[zh-cn] 解析 glTF skins 数组
     * @explain[zh-cn] 从 glTF JSON 中提取每个 skin 的 inverseBindMatrices、skeleton root 和 joints 列表。
     *
     * @brief[en] Parse glTF skins array
     * @explain[en] Extracts inverseBindMatrices, skeleton root, and joints list for each skin from glTF JSON.
     */
    private func parseSkins(skinsOpt: Option<Any>, nodesOpt: Option<Any>, accessorsOpt: Option<Any>, bufferViewsOpt: Option<Any>, loadedBuffers: ArrayList<Array<UInt8>>): ArrayList<GltfSkinData> {
        let result = ArrayList<GltfSkinData>()
        let skins = if (let Some(s) <- skinsOpt) { toArrayAny(s) } else { return result }

        let accessors = if (let Some(a) <- accessorsOpt) { toArrayAny(a) } else { return result }
        let bufferViews = if (let Some(bv) <- bufferViewsOpt) { toArrayAny(bv) } else { return result }

        for (si in 0..skins.size) {
            let skinObj = match (skins[si]) {
                case hm: HashMap<String, Any> => hm
                case _ => continue
            }

            // 解析 inverseBindMatrices accessor（MAT4，Float32，每矩阵 64 字节）
            var inverseBindMatrices = ArrayList<Array<Float64>>()
            if (let Some(ibmIdxVal) <- skinObj.get("inverseBindMatrices")) {
                let flatData = readAccessorData(getInt(Some(ibmIdxVal)), accessorsOpt, bufferViewsOpt, loadedBuffers)
                if (let Some(data) <- flatData) {
                    let count = data.size / 16
                    for (m in 0..count) {
                        let base = m * 16
                        let mat = Array<Float64>(16, { i => data[base + i] })
                        inverseBindMatrices.add(mat)
                    }
                }
            }

            // 解析 skeleton root node index
            var skeletonRoot = -1
            if (let Some(skelIdx) <- skinObj.get("skeleton")) { skeletonRoot = getInt(Some(skelIdx)) }

            // 解析 joints 数组
            let joints = ArrayList<Int>()
            if (let Some(jointsVal) <- skinObj.get("joints")) {
                let jointsArr = toArrayAny(jointsVal)
                for (ji in 0..jointsArr.size) {
                    joints.add(getInt(Some(jointsArr[ji])))
                }
            }

            // 解析 name
            var skinName = "skin_${si}"
            if (let Some(n) <- skinObj.get("name")) { skinName = match (n) { case s: String => s; case _ => skinName } }

            let ibmFinal = inverseBindMatrices
            result.add(GltfSkinData(
                skinName,
                Array<Array<Float64>>(ibmFinal.size, { i => ibmFinal[i] }),
                skeletonRoot,
                Array<Int>(joints.size, { i => joints[i] })
            ))
        }

        return result
    }

    // =========================================================================
    // glTF Animations 解析
    // =========================================================================

    /**
     * @brief[zh-cn] 解析 glTF animations 数组
     * @explain[zh-cn] 从 glTF JSON 中提取每个动画的 channels 和 samplers。
     *                  channels 定义目标节点和属性路径（translation/rotation/scale），
     *                  samplers 定义输入（时间）和输出（值）的 accessor 索引及插值方式。
     *
     * @brief[en] Parses the glTF animations array
     * @explain[en] Extracts the channels and samplers of each animation from the glTF JSON.
     *                  channels define the target node and property path (translation/rotation/scale);
     *                  samplers define the accessor indices and interpolation mode for input (time) and output (values).
     */
    private func parseAnimations(animationsOpt: Option<Any>, accessorsOpt: Option<Any>, bufferViewsOpt: Option<Any>, loadedBuffers: ArrayList<Array<UInt8>>): ArrayList<GltfAnimationData> {
        let result = ArrayList<GltfAnimationData>()
        let animations = if (let Some(a) <- animationsOpt) { toArrayAny(a) } else { return result }

        for (ai in 0..animations.size) {
            let animObj = match (animations[ai]) {
                case hm: HashMap<String, Any> => hm
                case _ => continue
            }

            // 解析 name
            var animName = "animation_${ai}"
            if (let Some(n) <- animObj.get("name")) { animName = match (n) { case s: String => s; case _ => animName } }

            // 解析 channels
            let channels = ArrayList<GltfAnimationChannel>()
            if (let Some(channelsVal) <- animObj.get("channels")) {
                let channelsArr = toArrayAny(channelsVal)
                for (ci in 0..channelsArr.size) {
                    let chObj = match (channelsArr[ci]) {
                        case hm: HashMap<String, Any> => hm
                        case _ => continue
                    }
                    let samplerIdx = getInt(chObj.get("sampler"))
                    var targetNode = -1
                    var targetPath = ""
                    if (let Some(targetVal) <- chObj.get("target")) {
                        let targetObj = match (targetVal) {
                            case hm: HashMap<String, Any> => hm
                            case _ => continue
                        }
                        targetNode = getInt(targetObj.get("node"))
                        if (let Some(p) <- targetObj.get("path")) { targetPath = match (p) { case s: String => s; case _ => "" } }
                    }
                    channels.add(GltfAnimationChannel(samplerIdx, targetNode, targetPath))
                }
            }

            // 解析 samplers
            let samplers = ArrayList<GltfAnimationSampler>()
            if (let Some(samplersVal) <- animObj.get("samplers")) {
                let samplersArr = toArrayAny(samplersVal)
                for (si in 0..samplersArr.size) {
                    let spObj = match (samplersArr[si]) {
                        case hm: HashMap<String, Any> => hm
                        case _ => continue
                    }
                    let inputIdx = getInt(spObj.get("input"))
                    let outputIdx = getInt(spObj.get("output"))
                    var interpolation = "LINEAR"
                    if (let Some(interp) <- spObj.get("interpolation")) { interpolation = match (interp) { case s: String => s; case _ => "LINEAR" } }
                    samplers.add(GltfAnimationSampler(inputIdx, outputIdx, interpolation))
                }
            }

            result.add(GltfAnimationData(animName, Array<GltfAnimationChannel>(channels.size, { i => channels[i] }), Array<GltfAnimationSampler>(samplers.size, { i => samplers[i] })))
        }

        return result
    }

    // =========================================================================
    // 值提取
    // =========================================================================

    private func getInt(v: Option<Any>): Int64 {
        if (let Some(val) <- v) {
            match (val) {
                case i: Int64 => i
                case f: Float64 => Int64(f)
                case _ => 0
            }
        } else { 0 }
    }

    private func getFloat(v: Option<Any>): Float64 {
        if (let Some(val) <- v) {
            match (val) {
                case f: Float64 => f
                case i: Int64 => Float64(i)
                case _ => 0.0
            }
        } else { 0.0 }
    }

    // =========================================================================
    // JSON 解析
    // =========================================================================

    public func parseJsonToHashMap(jsonStr: String): HashMap<String, Any> {
        try {
            let reader = JsonStreamReader(ByteBuffer(jsonStr.toArray()))
            return JsonUtil.streamFromJsonForHashMapAny(reader)
        } catch (_: Exception) {
            return HashMap<String, Any>()
        }
    }
}