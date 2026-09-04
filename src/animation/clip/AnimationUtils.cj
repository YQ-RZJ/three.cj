/**
 * @file[zh-cn] 动画工具函数
 * @brief[zh-cn] 提供动画关键帧处理工具
 * @explain[zh-cn] 
 * 包含关键帧排序、数组重排、JSON 关键帧展平、子剪辑创建与加法混合格式转换等工具函数
 *
 * @file[en] Animation Utilities
 * @brief[en] Provides animation keyframe processing utilities
 * @explain[en] 
 * Contains utility functions for keyframe ordering, array reordering, JSON keyframe flattening, subclip creation and additive blend format conversion
 */
package three.animation.clip

import three.core.math.Quaternion
import three.utils.constants.*
import three.animation.blend.KeyframeTrack
import three.animation.interfaces.IKeyframeTrack
import std.collection.*

/**
 * @brief[zh-cn] 转换数组到指定类型
 * @explain[zh-cn] 如果数组为空或类型相同，直接返回原数组；否则创建新数组
 * @param[zh-cn] array 要转换的数组
 * @param[zh-cn] `type` 目标类型名称
 * @return[zh-cn] 转换后的数组
 */
internal func convertArray(array: Array<Float64>, `type`: String): Array<Float64> {
    if (array.size == 0) { return array }
    if (`type` == "Float64Array" || `type` == "" || `type` == "Array") { return array }
    // Ignore: 仓颉中无 JS TypedArray 概念，统一用 Array<Float64> 存储，此处行为与 JS 等价（无类型转换需要）。
    return array
}

/**
 * @brief[zh-cn] 返回关键帧时间的排序顺序数组
 * @param[zh-cn] times 关键帧时间数组
 * @return[zh-cn] 排序后的索引数组，按时间升序排列
 */
internal func getKeyframeOrder(times: Array<Float64>): Array<Int64> {
    let n = times.size
    let result = Array<Int64>(n, { i => i })
    // 使用冒泡排序（基于 times 值排序索引）
    for (i in 0..n) {
        for (j in (i + 1)..n) {
            if (times[result[i]] > times[result[j]]) {
                let tmp = result[i]
                result[i] = result[j]
                result[j] = tmp
            }
        }
    }
    return result
}

/**
 * @brief[zh-cn] 根据排序顺序重排数组
 * @param[zh-cn] values 原始值数组
 * @param[zh-cn] stride 步长（每个关键帧的值数量）
 * @param[zh-cn] order 排序顺序（由 getKeyframeOrder 返回）
 * @return[zh-cn] 排序后的数组
 */
internal func sortedArray(values: Array<Float64>, stride: Int64, order: Array<Int64>): Array<Float64> {
    let nValues = values.size
    let result = Array<Float64>(nValues, { _ => 0.0 })
    var dstOffset: Int64 = 0
    for (i in 0..order.size) {
        let srcOffset = order[i] * stride
        for (j in 0..stride) {
            result[dstOffset] = values[srcOffset + j]
            dstOffset += 1
        }
    }
    return result
}

/**
 * @brief[zh-cn] 解析 JSON 格式的关键帧数据（AOS 格式）
 * @explain[zh-cn] 
 * 从 JSON 键数组中提取关键帧时间和值，填充到 times 和 values 数组中
 * @param[zh-cn] jsonKeys JSON 关键帧数组
 * @param[zh-cn] times 填充关键帧时间的数组
 * @param[zh-cn] values 填充关键帧值的数组
 * @param[zh-cn] valuePropertyName 要使用的属性名
 */
internal func flattenJSON(jsonKeys: Array<HashMap<String, Any>>, times: ArrayList<Float64>, values: ArrayList<Float64>, valuePropertyName: String): Unit {
    var i = 1
    var key = jsonKeys[0]

    // 查找第一个具有 valuePropertyName 属性的键
    var found = false
    while (i <= jsonKeys.size) {
        match (key) {
            case dict: HashMap<String, Any> =>
                let val = dict.get(valuePropertyName)
                if (val.isSome()) { found = true; break }
            case _ => ()
        }
        if (i < jsonKeys.size) {
            key = jsonKeys[i]
            i += 1
        } else {
            break
        }
    }

    if (!found) { return } // 无数据

    // 获取第一个值并判断类型
    match (key) {
        case dict: HashMap<String, Any> =>
            let valOpt = dict.get(valuePropertyName)
            match (valOpt) {
                case Some(value) =>
                    match (value) {
                        case arr: Array<Any> =>
                            // 值是数组类型 — 逐个提取
                            _flattenJSONLoop(jsonKeys, i, times, values, valuePropertyName, true)
                        case _ =>
                            // 值是标量类型 — 直接添加
                            _flattenJSONLoop(jsonKeys, i, times, values, valuePropertyName, false)
                    }
                case None => ()
            }
        case _ => ()
    }
}

/**
 * @brief[zh-cn] flattenJSON 的内部循环，处理剩余的 JSON 键
 * @param[zh-cn] jsonKeys JSON 关键帧数组
 * @param[zh-cn] startIndex 起始索引
 * @param[zh-cn] times 填充关键帧时间的数组
 * @param[zh-cn] values 填充关键帧值的数组
 * @param[zh-cn] valuePropertyName 要使用的属性名
 * @param[zh-cn] isArray 值是否为数组类型
 */
internal func _flattenJSONLoop(jsonKeys: Array<HashMap<String, Any>>, startIndex: Int64, times: ArrayList<Float64>, values: ArrayList<Float64>, valuePropertyName: String, isArray: Bool): Unit {
    // 先处理 startIndex 之前的那个 key（即找到的第一个有效 key）
    // 然后从 startIndex 开始处理剩余的 key
    for (idx in 0..jsonKeys.size) {
        match (jsonKeys[idx]) {
            case k: HashMap<String, Any> =>
                let valOpt = k.get(valuePropertyName)
                match (valOpt) {
                    case Some(v) =>
                        let timeOpt = k.get("time")
                        match (timeOpt) {
                            case Some(t) =>
                                match (t) {
                                    case timeVal: Float64 =>
                                        times.add(timeVal)
                                        if (isArray) {
                                            match (v) {
                                                case arr: Array<Any> =>
                                                    for (elem in arr) {
                                                        match (elem) {
                                                            case f: Float64 => values.add(f)
                                                            case _ => ()
                                                        }
                                                    }
                                                case _ => ()
                                            }
                                        } else {
                                            match (v) {
                                                case f: Float64 => values.add(f)
                                                case _ => ()
                                            }
                                        }
                                    case _ => ()
                                }
                            case None => ()
                        }
                    case None => ()
                }
            case _ => ()
        }
    }
}

/**
 * @brief[zh-cn] 创建子剪辑 — 从原始剪辑中提取指定帧范围的新剪辑
 * @param[zh-cn] sourceClip 源剪辑
 * @param[zh-cn] name 新剪辑名称
 * @param[zh-cn] startFrame 起始帧
 * @param[zh-cn] endFrame 结束帧
 * @param[zh-cn] fps 帧率，默认 30
 * @return[zh-cn] 新的子剪辑
 */
internal func subclip(sourceClip: AnimationClip, name: String, startFrame: Int64, endFrame: Int64, fps!: Float64 = 30.0): AnimationClip {
    let clip = sourceClip.clone()
    clip.name = name
    let tracks = ArrayList<IKeyframeTrack>()

    for (i in 0..clip.tracks.size) {
        let track = clip.tracks[i]
        let valueSize = track.getValueSize()
        let times = ArrayList<Float64>()
        let values = ArrayList<Float64>()

        for (j in 0..track.times.size) {
            let frame = track.times[j] * fps
            if (frame < Float64(startFrame) || frame >= Float64(endFrame)) { continue }
            times.add(track.times[j])
            for (k in 0..valueSize) {
                values.add(track.values[j * valueSize + k])
            }
        }

        if (times.size == 0) { continue }
        track.times = convertArray(times.toArray(), "")
        track.values = convertArray(values.toArray(), "")
        tracks.add(track)
    }

    clip.tracks = tracks.toArray()

    // 找到所有轨道中最小的时间值
    var minStartTime = Float64.Inf
    for (i in 0..clip.tracks.size) {
        if (minStartTime > clip.tracks[i].times[0]) {
            minStartTime = clip.tracks[i].times[0]
        }
    }

    // 将所有轨道平移到 t=0 开始
    for (i in 0..clip.tracks.size) {
        clip.tracks[i].shift(-1.0 * minStartTime)
    }

    clip.resetDuration()
    return clip
}

/**
 * @brief[zh-cn] 将动画剪辑转换为加法混合格式
 * @param[zh-cn] targetClip 目标剪辑（将被修改为加法格式）
 * @param[zh-cn] referenceFrame 参考帧，默认 0
 * @param[zh-cn] referenceClip 参考剪辑，默认为 targetClip 自身
 * @param[zh-cn] fps 帧率，默认 30
 * @return[zh-cn] 修改后的目标剪辑（现在是加法格式）
 *
 * @brief[en] Converts an animation clip to additive blending format
 */
internal func makeClipAdditive(targetClip: AnimationClip, referenceFrame!: Int64 = 0, referenceClip!: AnimationClip = targetClip, fps!: Float64 = 30.0): AnimationClip {
    var fpsVal = if (fps <= 0.0) { 30.0 } else { fps }
    let numTracks = referenceClip.tracks.size
    let referenceTime = Float64(referenceFrame) / fpsVal

    // 使每个轨道的值相对于参考帧的值
    for (i in 0..numTracks) {
        let referenceTrack = referenceClip.tracks[i]
        let referenceTrackType = referenceTrack.ValueTypeName

        // 跳过布尔和字符串类型（非数值类型不适用加法混合）
        if (referenceTrackType == "bool" || referenceTrackType == "string") { continue }

        // 在目标剪辑中查找名称和类型匹配的轨道
        var targetTrack: Option<IKeyframeTrack> = None
        for (t in targetClip.tracks) {
            if (t.name == referenceTrack.name && t.ValueTypeName == referenceTrackType) {
                targetTrack = Some(t)
                break
            }
        }
        if (targetTrack.isNone()) { continue }
        let targetTrackVal = targetTrack.getOrThrow()

        var referenceOffset: Int64 = 0
        let referenceValueSize = referenceTrack.getValueSize()

        // 检查是否为 GLTF Cubic Spline 插值
        if (referenceTrack.createInterpolant(None).settings.isSome()) {
            let settings = referenceTrack.createInterpolant(None).settings.getOrThrow()
            let isGLTF = settings.get("isInterpolantFactoryMethodGLTFCubicSpline")
            match (isGLTF) {
                case Some(v) =>
                    match (v) {
                        case b: Bool =>
                            if (b) { referenceOffset = referenceValueSize / 3 }
                        case _ => ()
                    }
                case None => ()
            }
        }

        var targetOffset: Int64 = 0
        let targetValueSize = targetTrackVal.getValueSize()

        // 检查目标轨道是否为 GLTF Cubic Spline 插值
        if (targetTrackVal.createInterpolant(None).settings.isSome()) {
            let settings = targetTrackVal.createInterpolant(None).settings.getOrThrow()
            let isGLTF = settings.get("isInterpolantFactoryMethodGLTFCubicSpline")
            match (isGLTF) {
                case Some(v) =>
                    match (v) {
                        case b: Bool =>
                            if (b) { targetOffset = targetValueSize / 3 }
                        case _ => ()
                    }
                case None => ()
            }
        }

        let lastIndex = referenceTrack.times.size - 1
        var referenceValue: Array<Float64>

        // 找到要减去的参考值
        if (referenceTime <= referenceTrack.times[0]) {
            // 参考帧早于第一个关键帧，使用第一个关键帧
            let startIndex = referenceOffset
            let endIndex = referenceValueSize - referenceOffset
            let count = endIndex - startIndex
            referenceValue = Array<Float64>(count, { k => referenceTrack.values[startIndex + k] })
        } else if (referenceTime >= referenceTrack.times[lastIndex]) {
            // 参考帧晚于最后一个关键帧，使用最后一个关键帧
            let startIndex = lastIndex * referenceValueSize + referenceOffset
            let count = referenceValueSize - referenceOffset
            referenceValue = Array<Float64>(count, { k => referenceTrack.values[startIndex + k] })
        } else {
            // 插值到参考值
            let interpolant = referenceTrack.createInterpolant(None)
            interpolant.evaluate(referenceTime)
            let startIndex = referenceOffset
            let endIndex = referenceValueSize - referenceOffset
            let count = endIndex - startIndex
            referenceValue = Array<Float64>(count, { k => interpolant.resultBuffer[startIndex + k] })
        }

        // 四元数取共轭
        if (referenceTrackType == "quaternion") {
            let referenceQuat = Quaternion().fromArray(referenceValue, offset: 0).normalize().conjugate()
            referenceQuat.toArray(referenceValue, offset: 0)
        }

        // 从所有轨道值中减去参考值
        let numTimes = targetTrackVal.times.size
        for (j in 0..numTimes) {
            let valueStart = j * targetValueSize + targetOffset

            if (referenceTrackType == "quaternion") {
                // 四元数：乘以共轭
                Quaternion.multiplyQuaternionsFlat(
                    targetTrackVal.values, valueStart,
                    referenceValue, 0,
                    targetTrackVal.values, valueStart
                )
            } else {
                // 其他数值类型：减去参考值
                let valueEnd = targetValueSize - targetOffset * 2
                for (k in 0..valueEnd) {
                    targetTrackVal.values[valueStart + k] -= referenceValue[k]
                }
            }
        }
    }

    targetClip.blendMode = AdditiveAnimationBlendMode
    return targetClip
}

/**
 * @brief[zh-cn] 动画工具类，提供静态方法包装
 * @explain[zh-cn] 
 * 对应 Three.js AnimationUtils 类，以静态方法的形式对外暴露关键帧处理工具
 *
 * @brief[en] Animation utility class, providing static method wrappers
 * @explain[en] 
 * Corresponds to the Three.js AnimationUtils class, exposing keyframe processing utilities as static methods
 */
public class AnimationUtils {
    // 已移除：public convertArray/isTypedArray（仓颉 Array 即高性能定长数组，无 JS TypedArray
    // 概念，这两个 TypedArray 相关接口为冗余——删除；内部 internal convertArray（parse 用）保留）

    /**
     * @brief[zh-cn] 返回关键帧时间的排序顺序数组
     * @param[zh-cn] times 关键帧时间数组
     * @return[zh-cn] 排序后的索引数组，按时间升序排列
     *
     * @brief[en] Returns the sort order array of keyframe times
     * @param[en] times Keyframe time array
     * @return[en] Sorted index array in ascending time order
     */
    public static func getKeyframeOrder(times: Array<Float64>): Array<Int64> {
        // 返回按 times 值升序的索引数组（选择排序）
        let order = Array<Int64>(times.size, { i => Int64(i) })
        for (i in 0..order.size) {
            for (j in (i + 1)..order.size) {
                if (times[order[j]] < times[order[i]]) {
                    let tmp = order[i]
                    order[i] = order[j]
                    order[j] = tmp
                }
            }
        }
        return order
    }

    /**
     * @brief[zh-cn] 根据排序顺序重排数组
     * @param[zh-cn] values 原始值数组
     * stride 步长（每个关键帧的值数量）
     * order 排序顺序（由 getKeyframeOrder 返回）
     * @return[zh-cn] 排序后的数组
     *
     * @brief[en] Reorders the array according to the sort order
     * @param[en] values Original value array
     * stride Stride (number of values per keyframe)
     * order Sort order (returned by getKeyframeOrder)
     * @return[en] Sorted array
     */
    public static func sortedArray(values: Array<Float64>, stride: Int64, order: Array<Int64>): Array<Float64> {
        // 按 order 重排（stride 步长）
        let result = Array<Float64>(values.size, { _ => 0.0 })
        let n = values.size / Int64(stride)
        var j = 0
        for (i in 0..n) {
            for (k in 0..stride) {
                result[j + k] = values[Int64(order[i]) * stride + k]
            }
            j += stride
        }
        return result
    }

    /**
     * @brief[zh-cn] 展平 JSON 关键帧数据
     * @param[zh-cn] jsonKeys JSON 关键帧数组
     * times 填充关键帧时间的数组
     * values 填充关键帧值的数组
     * valuePropertyName 要使用的属性名
     *
     * @brief[en] Flattens JSON keyframe data
     * @param[en] jsonKeys JSON keyframe array
     * times Array to fill with keyframe times
     * values Array to fill with keyframe values
     * valuePropertyName Property name to use
     */
    public static func flattenJSON(jsonKeys: Array<HashMap<String, Any>>, times: ArrayList<Float64>, values: ArrayList<Float64>, valuePropertyName: String): Unit {
        flattenJSON(jsonKeys, times, values, valuePropertyName)
    }

    /**
     * @brief[zh-cn] 创建子剪辑 — 从原始剪辑中提取指定帧范围的新剪辑
     * @param[zh-cn] sourceClip 源剪辑
     * name 新剪辑名称
     * startFrame 起始帧
     * endFrame 结束帧
     * fps 帧率，默认 30
     * @return[zh-cn] 新的子剪辑
     *
     * @brief[en] Creates a subclip — a new clip extracted from the source clip over the given frame range
     * @param[en] sourceClip The source clip
     * name The new clip name
     * startFrame Start frame
     * endFrame End frame
     * fps Frame rate, defaults to 30
     * @return[en] The new subclip
     */
    public static func subclip(sourceClip: AnimationClip, name: String, startFrame: Int64, endFrame: Int64, fps!: Float64 = 30.0): AnimationClip {
        return subclip(sourceClip, name, startFrame, endFrame, fps: fps)
    }

    /**
     * @brief[zh-cn] 将动画剪辑转换为加法混合格式
     * @param[zh-cn] targetClip 目标剪辑（将被修改为加法格式）
     * referenceFrame 参考帧，默认 0
     * referenceClip 参考剪辑，默认为 targetClip
     * fps 帧率，默认 30
     * @return[zh-cn] 修改后的目标剪辑（现在是加法格式）
     *
     * @brief[en] Converts an animation clip to additive blending format
     * @param[en] targetClip The target clip (will be modified to additive format)
     * referenceFrame Reference frame, defaults to 0
     * referenceClip Reference clip, defaults to targetClip
     * fps Frame rate, defaults to 30
     * @return[en] The modified target clip (now in additive format)
     */
    public static func makeClipAdditive(targetClip: AnimationClip, referenceFrame!: Int64 = 0, referenceClip!: AnimationClip = targetClip, fps!: Float64 = 30.0): AnimationClip {
        return makeClipAdditive(targetClip, referenceFrame: referenceFrame, referenceClip: referenceClip, fps: fps)
    }
}

/**
 * @brief[zh-cn] 判断对象是否为 TypedArray（类型化数组）
 * @explain[zh-cn] 仓颉中没有 JS 的 TypedArray 概念，此处检查是否为数值数组类型
 * @param[zh-cn] array 待检查的对象
 * @return[zh-cn] 是否为数值数组类型
 */
internal func isTypedArray(array: Any): Bool {
    match (array) {
        case _: Array<Float64> => true
        case _: Array<Float32> => true
        case _: Array<Int64> => true
        case _: Array<Int32> => true
        case _: Array<Int16> => true
        case _: Array<Int8> => true
        case _: Array<UInt64> => true
        case _: Array<UInt32> => true
        case _: Array<UInt16> => true
        case _: Array<UInt8> => true
        case _ => false
    }
}
