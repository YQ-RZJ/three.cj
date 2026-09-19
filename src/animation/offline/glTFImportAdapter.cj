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
 * @file[zh-cn] GltfImportAdapter
 * @brief[zh-cn] glTF 解析结果 → ozz 离线数据（RawSkeleton/RawAnimation）适配器
 * @explain[zh-cn] GltfLoader 将 skins/animations 解析为 GltfSkinData/GltfAnimationData
 *                  并连同 nodes/accessors/bufferViews/buffers 暴露在 Group.userData 中。
 *                  本适配器负责：
 *                  1. buildRawSkeleton：按 skin.joints 建立关节层级，从节点 matrix/TRS
 *                     提取局部休息姿势（平移、旋转、缩放）；
 *                  2. buildRawAnimation：将动画通道按目标关节映射到轨道，读取 accessor
 *                     二进制数据（含交错 stride、CUBICSPLINE 中间值取值），生成关键帧。
 *                  后续由 SkeletonBuilder/AnimationBuilder 压缩为运行时数据。
 *
 * @file[en] GltfImportAdapter
 * @brief[en] Adapter from glTF parse results to ozz offline data (RawSkeleton/RawAnimation)
 * @explain[en] GltfLoader parses skins/animations into GltfSkinData/GltfAnimationData and
 *              exposes nodes/accessors/bufferViews/buffers via Group.userData. This adapter:
 *              1. buildRawSkeleton: builds the joint hierarchy from skin.joints and extracts
 *                 local rest pose (translation, rotation, scale) from node matrix/TRS;
 *              2. buildRawAnimation: maps animation channels to per-joint tracks, reads
 *                 accessor binary data (including interleaved stride and CUBICSPLINE middle
 *                 values), and produces keyframes.
 *              SkeletonBuilder/AnimationBuilder then compress them into runtime data.
 */
package three.animation.offline

import std.collection.*
import std.math.*
import three.core.math.*
import three.resource.loader.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] glTF → 离线骨骼/动画数据适配器（全部为静态方法）
 *
 * @brief[en] glTF to offline skeleton/animation data adapter (all static methods)
 */
public class GltfImportAdapter {

    /**
     * @brief[zh-cn] 由 glTF skin 与节点数据构建离线骨骼
     * @param[zh-cn] skinData glTF skin 解析结果（关节节点索引、名称等）
     * @param[zh-cn] nodes glTF 节点数组（元素为 HashMap<String, Any>）
     * @return[zh-cn] 填充好层级与局部休息姿势的 RawSkeleton
     *
     * @brief[en] Build offline skeleton from glTF skin and node data
     * @param[en] skinData Parsed glTF skin (joint node indices, name, etc.)
     * @param[en] nodes glTF node array (elements are HashMap<String, Any>)
     * @return[en] RawSkeleton with hierarchy and local rest poses filled
     */
    public static func buildRawSkeleton(skinData: GltfSkinData, nodes: Array<Any>): RawSkeleton {
        let raw = RawSkeleton()
        let numJoints = skinData.joints.size

        // 第一遍：建立节点索引 → 关节索引映射
        let nodeToJoint = HashMap<Int64, Int>()
        for (i in 0..numJoints) {
            nodeToJoint.add(Int64(skinData.joints[i]), i)
        }

        // 第二遍：按正确父关节顺序添加关节（addJoint 接受 parentIdx 参数）
        for (i in 0..numJoints) {
            let nodeIdx = skinData.joints[i]
            let name = GltfImportAdapter.nodeName(nodes, nodeIdx, "joint_${i}")
            let parentIdx = GltfImportAdapter.findParentJoint(nodeIdx, nodes, nodeToJoint)
            let joint = raw.addJoint(name, parentIdx)
            match (GltfImportAdapter.getNode(nodes, nodeIdx)) {
                case Some(node) =>
                    GltfImportAdapter.applyNodeLocalTransform(node, joint)
                    if (i == 2 || i == 10 || i == 16) {
                        @LogDebug(["glTFImportAdapter", "buildRawSkel joint${i} node=${nodeIdx} parent=${parentIdx} t=[${joint.localTranslation.x},${joint.localTranslation.y},${joint.localTranslation.z}]"])
                    }
                case None =>
                    @LogWarn(["glTFImportAdapter", "buildRawSkel joint${i} node=${nodeIdx} getNode=None!"])
            }
        }

        raw
    }

    /**
     * @brief[zh-cn] 由 glTF animation 与 skin 构建离线动画
     * @param[zh-cn] animData glTF 动画解析结果（通道、采样器）
     * @param[zh-cn] skinData 关联的 skin（用于节点索引→关节索引映射）
     * @param[zh-cn] accessors glTF accessor 数组
     * @param[zh-cn] bufferViews glTF bufferView 数组
     * @param[zh-cn] loadedBuffers 已加载的二进制缓冲列表
     * @return[zh-cn] 填充好关键帧的 RawAnimation（已按时间排序）
     *
     * @brief[en] Build offline animation from glTF animation and skin
     * @param[en] animData Parsed glTF animation (channels, samplers)
     * @param[en] skinData Associated skin (for node-index to joint-index mapping)
     * @param[en] accessors glTF accessor array
     * @param[en] bufferViews glTF bufferView array
     * @param[en] loadedBuffers Loaded binary buffer list
     * @return[en] RawAnimation with keyframes filled (sorted by time)
     */
    public static func buildRawAnimation(
        animData: GltfAnimationData,
        skinData: GltfSkinData,
        accessors: Array<Any>,
        bufferViews: Array<Any>,
        loadedBuffers: ArrayList<Array<UInt8>>,
        rawSkeleton!: ?RawSkeleton = None
    ): RawAnimation {
        let raw = RawAnimation()
        raw.name = animData.name
        let numJoints = skinData.joints.size
        raw.initTracks(numJoints)

        let nodeToJoint = HashMap<Int64, Int>()
        for (i in 0..numJoints) {
            nodeToJoint.add(Int64(skinData.joints[i]), i)
        }

        var maxTime: Float32 = 0.0f32
        for (channel in animData.channels) {
            let jointIdxOpt = nodeToJoint.get(Int64(channel.targetNode))
            match (jointIdxOpt) {
                case Some(jointIdx) =>
                    if (channel.sampler < 0 || channel.sampler >= animData.samplers.size) { continue }
                    let sampler = animData.samplers[channel.sampler]

                    let times = GltfImportAdapter.readAccessorFloats(
                        sampler.input, accessors, bufferViews, loadedBuffers)
                    let values = GltfImportAdapter.readAccessorFloats(
                        sampler.output, accessors, bufferViews, loadedBuffers)
                    if (times.size == 0) { continue }

                    // 旋转通道分量数为 4（四元数），平移/缩放为 3
                    let comp = if (channel.targetPath == "rotation") { 4 } else { 3 }
                    // CUBICSPLINE 每关键帧输出 3 组分量（入切线、值、出切线），取中间的值组
                    let cubic = sampler.interpolation == "CUBICSPLINE"
                    let groupStride = if (cubic) { comp * 3 } else { comp }
                    let valueOffset = if (cubic) { comp } else { 0 }

                    for (ki in 0..times.size) {
                        let t = times[ki]
                        let base = ki * groupStride + valueOffset
                        if (base + comp > values.size) { break }

                        if (channel.targetPath == "translation") {
                            raw.addTranslationKeyframe(jointIdx, t,
                                Vector3F(values[base], values[base + 1], values[base + 2]))
                        } else if (channel.targetPath == "scale") {
                            raw.addScaleKeyframe(jointIdx, t,
                                Vector3F(values[base], values[base + 1], values[base + 2]))
                        } else if (channel.targetPath == "rotation") {
                            raw.addRotationKeyframe(jointIdx, t,
                                values[base], values[base + 1], values[base + 2], values[base + 3])
                        }
                        if (t > maxTime) { maxTime = t }
                    }
                case None => ()  // 目标节点不是关节，跳过
            }
        }

        // 为没有动画通道的关节填充 rest pose 关键帧（避免 BlendingJob 用零值覆盖 rest pose）
        // 按通道分别检查：translation/rotation/scale 缺失时分别填充
        match (rawSkeleton) {
            case Some(skel) =>
                for (ji in 0..numJoints) {
                    let joint = skel.joints[ji]
                    if (ji < raw.translations.size && raw.translations[ji].size == 0) {
                        raw.addTranslationKeyframe(ji, 0.0f32, joint.localTranslation)
                    }
                    if (ji < raw.rotations.size && raw.rotations[ji].size == 0) {
                        raw.addRotationKeyframe(ji, 0.0f32, joint.localRotation.x, joint.localRotation.y, joint.localRotation.z, joint.localRotation.w)
                    }
                    if (ji < raw.scales.size && raw.scales[ji].size == 0) {
                        raw.addScaleKeyframe(ji, 0.0f32, joint.localScale)
                    }
                }
            case None => ()
        }

        raw.duration = maxTime
        raw.sortKeyframes()
        raw.recalcDuration()
        raw
    }

    // =========================================================================
    // 内部辅助
    // =========================================================================

    /**
     * @brief[zh-cn] 取节点 HashMap，越界或类型不符返回 None
     *
     * @brief[en] Gets the node HashMap; returns None when out of range or of the wrong type
     */
    private static func getNode(nodes: Array<Any>, nodeIdx: Int): ?HashMap<String, Any> {
        if (nodeIdx < 0 || nodeIdx >= nodes.size) { return None }
        match (nodes[nodeIdx]) {
            case hm: HashMap<String, Any> => Some(hm)
            case _ => None
        }
    }

    /**
     * @brief[zh-cn] 取节点名称，缺失时使用 fallback
     *
     * @brief[en] Gets the node name, falling back to the given value when missing
     */
    private static func nodeName(nodes: Array<Any>, nodeIdx: Int, fallback: String): String {
        match (GltfImportAdapter.getNode(nodes, nodeIdx)) {
            case Some(node) =>
                match (node.get("name")) {
                    case Some(n) => match (n) {
                        case s: String => s
                        case _ => fallback
                    }
                    case None => fallback
                }
            case None => fallback
        }
    }

    /**
     * @brief[zh-cn] 在节点数组中查找某关节节点的父关节
     * @explain[zh-cn] 遍历所有节点的 children，找到包含 nodeIdx 的父节点；
     *                  父节点本身必须也是关节（在 nodeToJoint 中），否则返回 -1（根关节）。
     *
     * @brief[en] Finds the parent joint of a joint node in the node array
     * @explain[en] Iterates over all nodes' children to find the parent node containing
     *                  nodeIdx; the parent node itself must also be a joint (present in
     *                  nodeToJoint), otherwise -1 (root joint) is returned.
     */
    private static func findParentJoint(
        nodeIdx: Int,
        nodes: Array<Any>,
        nodeToJoint: HashMap<Int64, Int>
    ): Int {
        for (n in 0..nodes.size) {
            match (nodes[n]) {
                case node: HashMap<String, Any> =>
                    match (node.get("children")) {
                        case Some(childrenVal) =>
                            let children = GltfImportAdapter.asArray(childrenVal)
                            for (c in children) {
                                if (GltfImportAdapter.asInt(c) == nodeIdx) {
                                    // 父节点须也是关节
                                    match (nodeToJoint.get(Int64(n))) {
                                        case Some(parentJoint) => return parentJoint
                                        case None => return -1
                                    }
                                }
                            }
                        case None => ()
                    }
                case _ => ()
            }
        }
        -1
    }

    /**
     * @brief[zh-cn] 将节点的局部变换（matrix 或 TRS）写入 RawJoint
     * @explain[zh-cn] 优先使用 matrix（列主序 16 元素）：平移取 [12][13][14]，
     *                  缩放取三个列向量长度，旋转用 Shepperd 方法从正交化后的
     *                  3x3 旋转部分提取四元数；无 matrix 时直接读 translation/
     *                  rotation/scale（glTF 标准 TRS）。
     *
     * @brief[en] Writes the node's local transform (matrix or TRS) into a RawJoint
     * @explain[en] Prefers matrix (column-major 16 elements): translation is taken from
     *                  [12][13][14], scale from the column-vector lengths, and rotation is
     *                  extracted with the Shepperd method from the orthonormalized 3x3
     *                  rotation part. Without a matrix, translation/rotation/scale (standard
     *                  glTF TRS) are read directly.
     */
    private static func applyNodeLocalTransform(node: HashMap<String, Any>, joint: RawJoint): Unit {
        match (node.get("matrix")) {
            case Some(matrixVal) =>
                let arr = GltfImportAdapter.asArray(matrixVal)
                if (arr.size >= 16) {
                    let m = Array<Float64>(16, { i => GltfImportAdapter.asFloat64(arr[i]) })

                    // 列主序：列 c 行 r 的元素在 m[c*4+r]
                    let r00 = m[0]; let r10 = m[1]; let r20 = m[2]
                    let r01 = m[4]; let r11 = m[5]; let r21 = m[6]
                    let r02 = m[8]; let r12 = m[9]; let r22 = m[10]

                    // 缩放 = 各列向量长度
                    let sx = sqrt(r00 * r00 + r10 * r10 + r20 * r20)
                    let sy = sqrt(r01 * r01 + r11 * r11 + r21 * r21)
                    let sz = sqrt(r02 * r02 + r12 * r12 + r22 * r22)
                    joint.localScale.set(Float32(sx), Float32(sy), Float32(sz))

                    // 平移
                    joint.localTranslation.set(Float32(m[12]), Float32(m[13]), Float32(m[14]))

                    // 旋转：归一化列得到纯旋转矩阵后提取四元数
                    let q = GltfImportAdapter.rotationMatrixToQuaternion(
                        r00, r01, r02,
                        r10, r11, r12,
                        r20, r21, r22,
                        sx, sy, sz
                    )
                    joint.localRotation.set(q.x, q.y, q.z, q.w)
                    return
                }
            case None => ()
        }

        // TRS 路径
        match (node.get("translation")) {
            case Some(t) =>
                let arr = GltfImportAdapter.asArray(t)
                if (arr.size >= 3) {
                    joint.localTranslation.set(
                        GltfImportAdapter.asFloat32(arr[0]),
                        GltfImportAdapter.asFloat32(arr[1]),
                        GltfImportAdapter.asFloat32(arr[2]))
                }
            case None => ()
        }
        match (node.get("rotation")) {
            case Some(r) =>
                let arr = GltfImportAdapter.asArray(r)
                if (arr.size >= 4) {
                    joint.localRotation.set(
                        GltfImportAdapter.asFloat32(arr[0]),
                        GltfImportAdapter.asFloat32(arr[1]),
                        GltfImportAdapter.asFloat32(arr[2]),
                        GltfImportAdapter.asFloat32(arr[3]))
                    joint.localRotation.normalize()
                }
            case None => ()
        }
        match (node.get("scale")) {
            case Some(s) =>
                let arr = GltfImportAdapter.asArray(s)
                if (arr.size >= 3) {
                    joint.localScale.set(
                        GltfImportAdapter.asFloat32(arr[0]),
                        GltfImportAdapter.asFloat32(arr[1]),
                        GltfImportAdapter.asFloat32(arr[2]))
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 从 3x3 旋转部分（列主序传入）用 Shepperd 方法提取四元数
     * @explain[zh-cn] 入参为 matrix 的 9 个旋转元素（先行后列：r00 r01 r02 / r10 r11 r12 /
     *                  r20 r21 r22）与三个列长度（缩放）。先按列归一化去除缩放，再用
     *                  Shepperd 数值稳定分支提取，最后归一化。
     *
     * @brief[en] Extracts a quaternion from the 3x3 rotation part (passed column-major) with the Shepperd method
     * @explain[en] The arguments are the 9 rotation elements of the matrix (row-major:
     *                  r00 r01 r02 / r10 r11 r12 / r20 r21 r22) and the three column
     *                  lengths (scale). Columns are normalized to remove scale, then the
     *                  numerically stable Shepperd branch is used, and the result is
     *                  normalized.
     */
    private static func rotationMatrixToQuaternion(
        r00in: Float64, r01in: Float64, r02in: Float64,
        r10in: Float64, r11in: Float64, r12in: Float64,
        r20in: Float64, r21in: Float64, r22in: Float64,
        sx: Float64, sy: Float64, sz: Float64
    ): QuaternionF {
        // 按列归一化，去除缩放分量（防 0 除）
        let invSx = if (sx > 1e-10) { 1.0 / sx } else { 1.0 }
        let invSy = if (sy > 1e-10) { 1.0 / sy } else { 1.0 }
        let invSz = if (sz > 1e-10) { 1.0 / sz } else { 1.0 }
        let r00 = r00in * invSx
        let r10 = r10in * invSx
        let r20 = r20in * invSx
        let r01 = r01in * invSy
        let r11 = r11in * invSy
        let r21 = r21in * invSy
        let r02 = r02in * invSz
        let r12 = r12in * invSz
        let r22 = r22in * invSz

        var qx = 0.0
        var qy = 0.0
        var qz = 0.0
        var qw = 1.0
        let trace = r00 + r11 + r22

        if (trace > 0.0) {
            let s = sqrt(trace + 1.0) * 2.0  // s = 4*qw
            qw = 0.25 * s
            qx = (r21 - r12) / s
            qy = (r02 - r20) / s
            qz = (r10 - r01) / s
        } else if (r00 > r11 && r00 > r22) {
            let s = sqrt(1.0 + r00 - r11 - r22) * 2.0  // s = 4*qx
            qw = (r21 - r12) / s
            qx = 0.25 * s
            qy = (r01 + r10) / s
            qz = (r02 + r20) / s
        } else if (r11 > r22) {
            let s = sqrt(1.0 + r11 - r00 - r22) * 2.0  // s = 4*qy
            qw = (r02 - r20) / s
            qx = (r01 + r10) / s
            qy = 0.25 * s
            qz = (r12 + r21) / s
        } else {
            let s = sqrt(1.0 + r22 - r00 - r11) * 2.0  // s = 4*qz
            qw = (r10 - r01) / s
            qx = (r02 + r20) / s
            qy = (r12 + r21) / s
            qz = 0.25 * s
        }

        let q = QuaternionF(Float32(qx), Float32(qy), Float32(qz), Float32(qw))
        q.normalize()
        q
    }

    /**
     * @brief[zh-cn] 读取 accessor 全部数据并转为 Float32 数组
     * @explain[zh-cn] 支持 componentType 5120(BYTE)/5121(UBYTE)/5122(SHORT)/5123(USHORT)/
     *                  5125(UINT)/5126(FLOAT)，支持 SCALAR/VEC2/VEC3/VEC4 分量数与
     *                  bufferView.byteStride 交错布局。
     *
     * @brief[en] Reads all accessor data and converts it to a Float32 array
     * @explain[en] Supports componentType 5120 (BYTE) / 5121 (UBYTE) / 5122 (SHORT) /
     *                  5123 (USHORT) / 5125 (UINT) / 5126 (FLOAT), SCALAR/VEC2/VEC3/VEC4
     *                  component counts, and interleaved layouts via bufferView.byteStride.
     */
    private static func readAccessorFloats(
        accessorIdx: Int,
        accessors: Array<Any>,
        bufferViews: Array<Any>,
        loadedBuffers: ArrayList<Array<UInt8>>
    ): Array<Float32> {
        let empty = Array<Float32>(0, { _ => 0.0f32 })
        if (accessorIdx < 0 || accessorIdx >= accessors.size) { return empty }
        let accessor = match (accessors[accessorIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return empty
        }

        let componentType = GltfImportAdapter.asIntOpt(accessor.get("componentType"))
        let count = GltfImportAdapter.asIntOpt(accessor.get("count"))
        let typeStr = match (accessor.get("type")) {
            case Some(s) => match (s) {
                case str: String => str
                case _ => "SCALAR"
            }
            case None => "SCALAR"
        }
        let numComponents = match (typeStr) {
            case "SCALAR" => 1
            case "VEC2" => 2
            case "VEC3" => 3
            case "VEC4" => 4
            case _ => 1
        }

        let bufferViewIdx = GltfImportAdapter.asIntOpt(accessor.get("bufferView"))
        if (bufferViewIdx < 0 || bufferViewIdx >= bufferViews.size) { return empty }
        let bufferView = match (bufferViews[bufferViewIdx]) {
            case hm: HashMap<String, Any> => hm
            case _ => return empty
        }

        let bufferIdx = GltfImportAdapter.asIntOpt(bufferView.get("buffer"))
        if (bufferIdx < 0 || bufferIdx >= loadedBuffers.size) { return empty }
        let bufferData = loadedBuffers[bufferIdx]

        let componentSize = match (componentType) {
            case 5120 => 1
            case 5121 => 1
            case 5122 => 2
            case 5123 => 2
            case 5125 => 4
            case 5126 => 4
            case _ => 4
        }
        let bvByteOffset = GltfImportAdapter.asIntOpt(bufferView.get("byteOffset"))
        let accessorByteOffset = GltfImportAdapter.asIntOpt(accessor.get("byteOffset"))
        let bvByteStride = GltfImportAdapter.asIntOpt(bufferView.get("byteStride"))
        let stride = if (bvByteStride > 0) { bvByteStride } else { numComponents * componentSize }
        let start = bvByteOffset + accessorByteOffset

        let result = Array<Float32>(count * numComponents, { _ => 0.0f32 })
        for (i in 0..count) {
            for (c in 0..numComponents) {
                let bytePos = start + i * stride + c * componentSize
                if (bytePos < 0 || bytePos + componentSize > bufferData.size) { continue }
                let outIdx = i * numComponents + c
                match (componentType) {
                    case 5126 =>
                        // Float32：4 字节小端 → 位模式 → Float32
                        let bits = UInt32(bufferData[bytePos]) |
                            (UInt32(bufferData[bytePos + 1]) << 8) |
                            (UInt32(bufferData[bytePos + 2]) << 16) |
                            (UInt32(bufferData[bytePos + 3]) << 24)
                        result[outIdx] = Float32.fromBits(bits)
                    case 5125 =>
                        // UInt32
                        let bits = UInt32(bufferData[bytePos]) |
                            (UInt32(bufferData[bytePos + 1]) << 8) |
                            (UInt32(bufferData[bytePos + 2]) << 16) |
                            (UInt32(bufferData[bytePos + 3]) << 24)
                        result[outIdx] = Float32(bits)
                    case 5123 =>
                        // UInt16
                        let bits = UInt32(bufferData[bytePos]) | (UInt32(bufferData[bytePos + 1]) << 8)
                        result[outIdx] = Float32(bits)
                    case 5122 =>
                        // Int16
                        let bits = UInt32(bufferData[bytePos]) | (UInt32(bufferData[bytePos + 1]) << 8)
                        result[outIdx] = Float32(Int16(bits))
                    case 5121 =>
                        // UInt8
                        result[outIdx] = Float32(bufferData[bytePos])
                    case 5120 =>
                        // Int8
                        result[outIdx] = Float32(Int8(bufferData[bytePos]))
                    case _ => ()
                }
            }
        }
        result
    }

    /**
     * @brief[zh-cn] Any → Array<Any>，类型不符返回空数组
     *
     * @brief[en] Any → Array<Any>; returns an empty array when the type mismatches
     */
    private static func asArray(v: Any): Array<Any> {
        match (v) {
            case a: Array<Any> => a
            case al: ArrayList<Any> =>
                Array<Any>(al.size, { i => al[i] })
            case _ => Array<Any>()
        }
    }

    /**
     * @brief[zh-cn] Any(Option) → Int，JSON 整数为 Int64
     *
     * @brief[en] Any(Option) → Int; JSON integers are Int64
     */
    private static func asIntOpt(v: Option<Any>): Int {
        match (v) {
            case Some(x) => GltfImportAdapter.asInt(x)
            case None => 0
        }
    }

    /**
     * @brief[zh-cn] Any → Int，支持 Int64/Int/Float64
     *
     * @brief[en] Any → Int; supports Int64/Int/Float64
     */
    private static func asInt(v: Any): Int {
        match (v) {
            case i: Int64 => i
            case f: Float64 => Int64(f)
            case f: Float32 => Int64(f)
            case _ => 0
        }
    }

    /**
     * @brief[zh-cn] Any → Float32，支持 Int64/Int/Float64/Float32
     *
     * @brief[en] Any → Float32; supports Int64/Int/Float64/Float32
     */
    private static func asFloat32(v: Any): Float32 {
        match (v) {
            case f: Float64 => Float32(f)
            case f: Float32 => f
            case i: Int64 => Float32(i)
            case _ => 0.0f32
        }
    }

    /**
     * @brief[zh-cn] Any → Float64，支持 Int64/Int/Float64/Float32
     *
     * @brief[en] Any → Float64; supports Int64/Int/Float64/Float32
     */
    private static func asFloat64(v: Any): Float64 {
        match (v) {
            case f: Float64 => f
            case f: Float32 => Float64(f)
            case i: Int64 => Float64(i)
            case _ => 0.0
        }
    }
}
