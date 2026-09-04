/**
 * @file[zh-cn] 动画剪辑
 * @brief[zh-cn] 管理一组关键帧轨道
 * @explain[zh-cn] 
 * 提供动画剪辑的创建、JSON 解析与序列化、关键帧轨道管理以及从变形目标序列生成剪辑等功能
 *
 * @file[en] Animation Clip
 * @brief[en] Manages a group of keyframe tracks
 * @explain[en] 
 * Provides creation of animation clips, JSON parsing and serialization, keyframe track management, and generation of clips from morph target sequences
 */
package three.animation.clip

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.utils.constants.*
import three.animation.interfaces.IAnimationClip
import three.animation.interfaces.IKeyframeTrack
import three.animation.blend.KeyframeTrack
import three.core.interfaces.ILoadResult
import std.collection.*
import std.regex.*
import std.convert.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*
import std.io.*

/**
 * @brief[zh-cn] 根据值类型名称获取对应的轨道类型
 * @param[zh-cn] typeName 值类型名称
 * @return[zh-cn] 对应的轨道类型字符串
 *
 * @brief[en] Gets the corresponding track type based on the value type name
 * @param[en] typeName Value type name
 * @return[en] The corresponding track type string
 */
internal func getTrackTypeForValueTypeName(typeName: String): String {
    let lower = typeName.toAsciiLower()
    if (lower == "scalar" || lower == "double" || lower == "float" || lower == "number" || lower == "integer") {
        return "NumberKeyframeTrack"
    } else if (lower == "vector" || lower == "vector2" || lower == "vector3" || lower == "vector4") {
        return "VectorKeyframeTrack"
    } else if (lower == "color") {
        return "ColorKeyframeTrack"
    } else if (lower == "quaternion") {
        return "QuaternionKeyframeTrack"
    } else if (lower == "bool" || lower == "boolean") {
        return "BooleanKeyframeTrack"
    } else if (lower == "string") {
        return "StringKeyframeTrack"
    }
    throw Exception("THREE.KeyframeTrack: Unsupported typeName: " + typeName)
}

/**
 * @brief[zh-cn] 解析 JSON 关键帧轨道
 * @explain[zh-cn]
 * 仓颉侧：因 three.animation.clip 与 three.animation.clip.blend.tracks 存在跨包循环依赖（tracks 继承基类 KeyframeTrack），此处不能直接导入子类。
 * 故用基类 KeyframeTrack 装载，并按 typeStr 手动设置子类本应在 init 中设置的公共字段（ValueTypeName/ValueBufferType/DefaultInterpolation），
 * 保持与 JS 侧子类构造的语义对齐。
 * 当 json.times === undefined 时，调用 AnimationUtils.flattenJSON 从 json.keys 提取 times 与 values
 * @param[zh-cn] json 序列化的关键帧轨道 JSON
 * @return[zh-cn] 解析后的 KeyframeTrack
 *
 * @brief[en] Parses a JSON keyframe track
 * @explain[en]
 * On the Cangjie side: due to a cross-package circular dependency between three.animation.clip and three.animation.clip.blend.tracks (tracks inherits from base class KeyframeTrack),
 * subclasses cannot be directly imported here. Instead, the base class KeyframeTrack is used for loading, and the public fields
 * (ValueTypeName/ValueBufferType/DefaultInterpolation) that subclasses would normally set in init are manually set according to typeStr,
 * keeping semantics aligned with the JS subclass constructors.
 * When json.times === undefined, calls AnimationUtils.flattenJSON to extract times and values from json.keys.
 * @param[en] json Serialized keyframe track JSON
 * @return[en] The parsed KeyframeTrack
 */
internal func parseKeyframeTrack(json: HashMap<String, Any>): KeyframeTrack {
    let typeVal = json.get("type")
    if (typeVal.isNone()) {
        throw Exception("THREE.KeyframeTrack: track type undefined, can not parse")
    }
    let typeStr = (typeVal.getOrThrow() as String) ?? ""
    // 用于按需切换插值默认值
    let trackType = getTrackTypeForValueTypeName(typeStr)

    let name = _getString(json, "name")
    var times = _getArray(json, "times")
    var values = _getArray(json, "values")
    var interp = _getInt(json, "interpolation", InterpolateLinear)

    // 当 times 未定义时，使用 flattenJSON 从 json.keys 提取
    if (json.get("times").isNone()) {
        let timesList = ArrayList<Float64>()
        let valuesList = ArrayList<Float64>()
        let jsonKeysOpt = json.get("keys")
        if (jsonKeysOpt.isSome()) {
            let jsonKeys = match (jsonKeysOpt.getOrThrow()) {
                case arr: Array<HashMap<String, Any>> => arr
                case _ => Array<HashMap<String, Any>>(0, { _ => HashMap<String, Any>() })
            }
            // 提取值属性名：默认 "value"
            flattenJSON(jsonKeys, timesList, valuesList, "value")
        }
        times = timesList.toArray()
        values = valuesList.toArray()
    }

    // 按子类语义对齐插值默认值
    // BooleanKeyframeTrack/StringKeyframeTrack 始终使用离散插值
    if (trackType == "BooleanKeyframeTrack" || trackType == "StringKeyframeTrack") {
        interp = InterpolateDiscrete
    }

    // 用基类构造（避免跨包循环依赖）
    let track = KeyframeTrack(name, times, values, interpolation: interp)
    track.ValueTypeName = typeStr

    // 按子类语义对齐 ValueBufferType 与 DefaultInterpolation
    if (trackType == "BooleanKeyframeTrack" || trackType == "StringKeyframeTrack") {
        // 布尔/字符串关键帧轨道使用 Array 容器（而非 TypedArray），默认离散插值
        track.ValueBufferType = "Array"
        track.DefaultInterpolation = InterpolateDiscrete
    } else if (trackType == "QuaternionKeyframeTrack") {
        // 四元数关键帧轨道使用默认线性（SLERP）插值
        track.DefaultInterpolation = InterpolateLinear
    } else {
        // Number/Vector/Color 关键帧轨道使用默认线性插值
        track.DefaultInterpolation = InterpolateLinear
    }

    return track
}

/**
 * @brief[zh-cn] 从 morphTarget 对象中提取名称
 * @explain[zh-cn]
 * JS 中 morphTarget 是带 .name 字段的对象；仓颉侧 morphTarget 可能为：
 * - BufferAttribute（含 .name 字段）
 * - HashMap<String, Any>（从 name 字段取值）
 * - String（直接用作名称）
 * - 其他：回退到索引字符串
 * @param[zh-cn] morphTarget 变形目标对象
 * @return[zh-cn] 变形目标名称
 *
 * @brief[en] Extracts the name from a morphTarget object
 * @explain[en]
 * In JS, morphTarget is an object with a .name field; on the Cangjie side, morphTarget can be:
 * - BufferAttribute (with a .name field)
 * - HashMap<String, Any> (extracted from the "name" field)
 * - String (used directly as the name)
 * - Other: falls back to an index string
 * @param[en] morphTarget Morph target object
 * @return[en] The morph target name
 */
internal func _getMorphTargetName(morphTarget: Any): String {
    match (morphTarget) {
        case s: String => return s
        case ba: BufferAttribute => return ba.name
        case map: HashMap<String, Any> =>
            let nameOpt = map.get("name")
            if (nameOpt.isSome()) {
                return (nameOpt.getOrThrow() as String) ?? ""
            }
            return ""
        case _ => return ""
    }
}

/**
 * @brief[zh-cn] 从 JSON 映射中读取字符串值
 *
 * @brief[en] Reads a string value from a JSON map
 */
internal func _getString(map: HashMap<String, Any>, key: String): String {
    let v = map.get(key)
    if (v.isSome()) {
        return (v.getOrThrow() as String) ?? ""
    }
    return ""
}

/**
 * @brief[zh-cn] 从 JSON 映射中读取数值数组
 *
 * @brief[en] Reads a numeric array from a JSON map
 */
internal func _getArray(map: HashMap<String, Any>, key: String): Array<Float64> {
    let v = map.get(key)
    if (v.isSome()) {
        return (v.getOrThrow() as Array<Float64>) ?? []
    }
    return Array<Float64>(0, { _ => 0.0 })
}

/**
 * @brief[zh-cn] 从 JSON 映射中读取整数
 *
 * @brief[en] Reads an integer from a JSON map
 */
internal func _getInt(map: HashMap<String, Any>, key: String, defaultVal: Int64): Int64 {
    let v = map.get(key)
    if (v.isSome()) {
        return (v.getOrThrow() as Int64) ?? defaultVal
    }
    return defaultVal
}

/**
 * @brief[zh-cn] 从 JSON 映射中读取浮点数
 *
 * @brief[en] Reads a floating-point number from a JSON map
 */
internal func _getFloat(map: HashMap<String, Any>, key: String, defaultVal: Float64): Float64 {
    let v = map.get(key)
    if (v.isSome()) {
        return (v.getOrThrow() as Float64) ?? defaultVal
    }
    return defaultVal
}

/**
 * @brief[zh-cn] 动画剪辑，包含一组关键帧轨道
 * @explain[zh-cn] 
 * 对应 Three.js AnimationClip 类，实现 IAnimationClip 与 ILoadResult 接口，支持 JSON 解析与序列化
 *
 * @brief[en] An animation clip, containing a group of keyframe tracks
 * @explain[en] 
 * Corresponds to the Three.js AnimationClip class, implementing the IAnimationClip and ILoadResult interfaces, supporting JSON parsing and serialization
 */
@JsonAdapter
public class AnimationClip <: IAnimationClip & ILoadResult {
    @JsonIgnore
    internal var _name: String = ""
    /**
     * @brief[zh-cn] 剪辑名称
     *
     * @brief[en] The clip name
     */
    public mut prop name: String {
        get() { this._name }
        set(v) { this._name = v }
    }

    @JsonIgnore
    internal var _duration: Float64 = -1.0
    /**
     * @brief[zh-cn] 剪辑持续时间（秒）
     *
     * @brief[en] The clip duration in seconds
     */
    public mut prop duration: Float64 {
        get() { this._duration }
        set(v) { this._duration = v }
    }

    @JsonIgnore
    internal var _tracks: Array<IKeyframeTrack> = []
    // 接口数组无法被 fastjson 序列化（Array<IKeyframeTrack> 不满足 JsonStreamDeserializable），序列化忽略；
    // JSON 加载走 AnimationClip.parse 手动解析 tracks。
    @JsonIgnore
    /**
     * @brief[zh-cn] 关键帧轨道数组
     *
     * @brief[en] The array of keyframe tracks
     */
    public mut prop tracks: Array<IKeyframeTrack> {
        get() { this._tracks }
        set(v) { this._tracks = v }
    }

    @JsonIgnore
    internal var _blendMode: Int64 = NormalAnimationBlendMode
    /**
     * @brief[zh-cn] 混合模式，定义两个或多个动画同时播放时的混合方式
     *
     * @brief[en] The blend mode, defining how two or more animations are blended when played simultaneously
     */
    public mut prop blendMode: Int64 {
        get() { this._blendMode }
        set(v) { this._blendMode = v }
    }

    @JsonIgnore
    internal var _uuid: String = ""
    /**
     * @brief[zh-cn] 剪辑的 UUID
     *
     * @brief[en] The UUID of the clip
     */
    public mut prop uuid: String {
        get() { this._uuid }
        set(v) { this._uuid = v }
    }

    // userData（2026-08-20 回退：删除 JsonValue 后改回 HashMap<String, Any>）。序列化忽略。
    @JsonIgnore
    internal var _userData: HashMap<String, Any> = HashMap<String, Any>()
    /**
     * @brief[zh-cn] 可用于存储剪辑自定义数据的对象，不应保存函数引用（克隆时不会复制函数）
     *
     * @brief[en] An object that can be used to store custom data for the clip; function references should not be stored since they are not copied on clone
     */
    public mut prop userData: HashMap<String, Any> {
        get() { this._userData }
        set(v) { this._userData = v }
    }

    /**
     * @brief[zh-cn] 构造一个新的动画剪辑
     * @param[zh-cn] name 剪辑名称，默认 ''
     * @param[zh-cn] duration 剪辑持续时间（秒），默认 -1（从关键帧计算）
     * @param[zh-cn] tracks 关键帧轨道数组（通过 IKeyframeTrack 接口引用，避免依赖 blend 包）
     * @param[zh-cn] blendMode 混合模式，默认 NormalAnimationBlendMode
     *
     * @brief[en] Constructs a new animation clip
     * @param[en] name Clip name, defaults to ''
     * @param[en] duration Clip duration in seconds, defaults to -1 (calculated from keyframes)
     * @param[en] tracks Array of keyframe tracks (referenced via the IKeyframeTrack interface to avoid depending on the blend package)
     * @param[en] blendMode Blend mode, defaults to NormalAnimationBlendMode
     */
    public init(name!: String = "", duration!: Float64 = -1.0, tracks!: Array<IKeyframeTrack> = [], blendMode!: Int64 = NormalAnimationBlendMode) {
        this.name = name
        this.tracks = tracks
        this.duration = duration
        this.blendMode = blendMode
        this.uuid = MathUtils.generateUUID()
        this.userData = HashMap<String, Any>()

        // 如果持续时间为负，则从关键帧计算持续时间
        if (this.duration < 0.0) {
            this.resetDuration()
        }
    }

    /**
     * @brief[zh-cn] 从 JSON 创建动画剪辑的工厂方法
     * @param[zh-cn] json 序列化的动画剪辑
     * @return[zh-cn] 新的动画剪辑
     *
     * @brief[en] Factory method that creates an animation clip from JSON
     * @param[en] json Serialized animation clip
     * @return[en] The new animation clip
     */
    public static func parse(json: HashMap<String, Any>): AnimationClip {
        let tracks = ArrayList<IKeyframeTrack>()
        let jsonTracksOpt = json.get("tracks")
        let jsonTracks = if (jsonTracksOpt.isSome()) {
            match (jsonTracksOpt.getOrThrow()) {
                case arr: Array<HashMap<String, Any>> => arr
                case _ => Array<HashMap<String, Any>>(0, { _ => HashMap<String, Any>() })
            }
        } else {
            Array<HashMap<String, Any>>(0, { _ => HashMap<String, Any>() })
        }
        let fps = _getFloat(json, "fps", 1.0)
        let frameTime = 1.0 / fps

        for (i in 0..jsonTracks.size) {
            tracks.add(parseKeyframeTrack(jsonTracks[i]).scale(frameTime))
        }

        let jsonName = _getString(json, "name")
        let jsonDuration = _getFloat(json, "duration", -1.0)
        let jsonBlendMode = _getInt(json, "blendMode", NormalAnimationBlendMode)
        let jsonUuid = _getString(json, "uuid")

        let clip = AnimationClip(name: jsonName, duration: jsonDuration, tracks: tracks.toArray(), blendMode: jsonBlendMode)
        clip.uuid = jsonUuid

        // 解析 userData
        
        // 仓颉侧：使用 cjfast_json 解析 userData 字符串为 HashMap<String, Any>
        let userDataOpt = json.get("userData")
        match (userDataOpt) {
            case Some(userDataVal) =>
                match (userDataVal) {
                    case s: String =>
                        // 空字符串或 '{}' 解析为空 HashMap
                        let trimmed = s.trimAscii()
                        if (trimmed != "" && trimmed != "{}") {
                            clip.userData = parseUserData(s)
                        }
                    case m: HashMap<String, Any> =>
                        // 直接是 HashMap 的情况
                        for (k in m.keys()) {
                            match (m.get(k)) {
                                case Some(v) => clip.userData.add(k, v)
                                case None => ()
                            }
                        }
                    case _ => ()
                }
            case None => ()
        }

        return clip
    }

    /**
     * @brief[zh-cn] 使用 cjfast_json 解析 userData JSON 字符串为 HashMap<String, Any>
     * @explain[zh-cn] 对应 JS: JSON.parse(json.userData || '{}')
     * @param[zh-cn] jsonStr JSON 字符串
     * @return[zh-cn] 解析后的 HashMap<String, Any>
     *
     * @brief[en] Parses a userData JSON string into a HashMap<String, Any> using cjfast_json
     * @explain[en] Corresponds to JS: JSON.parse(json.userData || '{}')
     */
    public static func parseUserData(jsonStr: String): HashMap<String, Any> {
        try {
            let reader = JsonStreamReader(ByteBuffer(jsonStr.toArray()))
            return JsonUtil.streamFromJsonForHashMapAny(reader)
        } catch (_: Exception) {
            // 解析失败时返回空 HashMap
            return HashMap<String, Any>()
        }
    }

    /**
     * @brief[zh-cn] 使用 cjfast_json 序列化 HashMap<String, Any> 为 JSON 字符串
     * @explain[zh-cn] 对应 JS: JSON.stringify(clip.userData)
     * @param[zh-cn] userData 用户数据 HashMap
     * @return[zh-cn] JSON 字符串
     *
     * @brief[en] Serializes a HashMap<String, Any> into a JSON string using cjfast_json
     * @explain[en] Corresponds to JS: JSON.stringify(clip.userData)
     */
    public static func stringifyUserData(userData: HashMap<String, Any>): String {
        // 2026-08-20 回退：删除 JsonValue 后，用 JsonStreamWriter 手写序列化 HashMap<String, Any> 的基础值
        let stream = ByteBuffer()
        var writer = JsonStreamWriter(stream)
        writer.startObject()
        for ((k, v) in userData) {
            writer.writeName(k)
            match (v) {
                case s: String => writer.writeValue(s)
                case i: Int64 => writer.writeValue(i)
                case f: Float64 => writer.writeValue(f)
                case b: Bool => writer.writeValue(b)
                case _ => writer.writeValue("")
            }
        }
        writer.endObject()
        writer.flush()
        return String.fromUtf8(readToEnd(stream))
    }

    /**
     * @brief[zh-cn] 从几何体的变形目标数组创建新的动画剪辑
     * @explain[zh-cn] 注意：fps 参数是必需的，但动画速度可通过 AnimationAction.setDuration 覆盖
     * @param[zh-cn] name 动画剪辑名称
     * @param[zh-cn] morphTargetSequence 变形目标序列
     * @param[zh-cn] fps 每秒帧数
     * @param[zh-cn] noLoop 是否不循环
     * @return[zh-cn] 新的动画剪辑
     *
     * @brief[en] Creates a new animation clip from an array of morph targets of a geometry
     * @explain[en] Note: the fps parameter is required, but the animation speed can be overridden via AnimationAction.setDuration
     * @param[en] name Animation clip name
     * @param[en] morphTargetSequence Morph target sequence
     * @param[en] fps Frames per second
     * @param[en] noLoop Whether not to loop
     * @return[en] The new animation clip
     */
    public static func CreateFromMorphTargetSequence(name: String, morphTargetSequence: Array<Any>, fps: Float64, noLoop: Bool): AnimationClip {
        let numMorphTargets = morphTargetSequence.size
        let tracks = ArrayList<IKeyframeTrack>()

        for (i in 0..numMorphTargets) {
            var times = ArrayList<Float64>()
            var values = ArrayList<Float64>()

            times.add(Float64((i + numMorphTargets - 1) % numMorphTargets))
            times.add(Float64(i))
            times.add(Float64((i + 1) % numMorphTargets))

            values.add(0.0)
            values.add(1.0)
            values.add(0.0)

            let order = AnimationUtils.getKeyframeOrder(times.toArray())
            let sortedTimes = AnimationUtils.sortedArray(times.toArray(), 1, order)
            let sortedValues = AnimationUtils.sortedArray(values.toArray(), 1, order)

            // 如果第一帧有值，复制到最后一帧以实现完美循环
            if (!noLoop && sortedTimes[0] == 0.0) {
                let newTimes = ArrayList<Float64>()
                for (t in sortedTimes) { newTimes.add(t) }
                newTimes.add(Float64(numMorphTargets))
                let newValues = ArrayList<Float64>()
                for (v in sortedValues) { newValues.add(v) }
                newValues.add(sortedValues[0])

                let track = KeyframeTrack(".morphTargetInfluences[" + _getMorphTargetName(morphTargetSequence[i]) + "]", newTimes.toArray(), newValues.toArray())
                track.ValueTypeName = "number"
                tracks.add(track.scale(1.0 / fps))
            } else {
                let track = KeyframeTrack(".morphTargetInfluences[" + _getMorphTargetName(morphTargetSequence[i]) + "]", sortedTimes, sortedValues)
                track.ValueTypeName = "number"
                tracks.add(track.scale(1.0 / fps))
            }
        }

        return AnimationClip(name: name, duration: -1.0, tracks: tracks.toArray())
    }

    /**
     * @brief[zh-cn] 按名称查找动画剪辑
     * @explain[zh-cn]
     * 第一个参数可以是剪辑数组，或者包含 "animations" 属性的 Object3D
     * 对应 JS: 先匹配 Object3D 的 geometry.animations 或 animations 属性，再回退到数组
     * 仓颉侧 BufferGeometry 不持有 animations，故仅从 Object3D.animations 取
     * @param[zh-cn] objectOrClipArray 剪辑数组或包含动画的对象
     * @param[zh-cn] name 要查找的名称
     * @return[zh-cn] 找到的动画剪辑，未找到返回 None
     *
     * @brief[en] Finds an animation clip by name
     * @explain[en]
     * The first parameter can be an array of clips, or an Object3D containing an "animations" property
     * Corresponds to JS: first matches the Object3D geometry.animations or animations property, then falls back to the array
     * On the Cangjie side, BufferGeometry does not hold animations, so only Object3D.animations is used
     * @param[en] objectOrClipArray Array of clips or an object containing animations
     * @param[en] name The name to search for
     * @return[en] The found animation clip, or None if not found
     */
    public static func findByName(objectOrClipArray: Any, name: String): Option<AnimationClip> {
        var clipList: Array<Any> = match (objectOrClipArray) {
            case arr: Array<Any> => arr
            case _ => Array<Any>(0, { _ => 0 })
        }

        // 非数组：从 Object3D 的 animations 属性获取
        if (clipList.size == 0) {
            match (objectOrClipArray) {
                case o: Object3D =>
                    let anims = ArrayList<Any>()
                    for (i in 0..o.animations.size) { anims.add(o.animations[i]) }
                    clipList = anims.toArray()
                case _ => return None
            }
        }

        for (i in 0..clipList.size) {
            let clipObj = clipList[i]
            match (clipObj) {
                case c: AnimationClip => if (c.name == name) { return Some(c) }
                case _ => ()
            }
        }
        return None
    }

    /**
     * @brief[zh-cn] 从几何体的变形目标序列创建多个动画剪辑
     * @explain[zh-cn] 尝试将变形目标名称排序为动画组模式，如 "Walk_001, Walk_002, Run_001, Run_002..."
     * @param[zh-cn] morphTargets 变形目标序列
     * @param[zh-cn] fps 每秒帧数
     * @param[zh-cn] noLoop 是否不循环
     * @return[zh-cn] 新的动画剪辑数组
     *
     * @brief[en] Creates multiple animation clips from a geometry's morph target sequence
     * @explain[en] Tries to sort the morph target names into animation group patterns, such as "Walk_001, Walk_002, Run_001, Run_002..."
     * @param[en] morphTargets Morph target sequence
     * @param[en] fps Frames per second
     * @param[en] noLoop Whether not to loop
     * @return[en] Array of new animation clips
     */
    public static func CreateClipsFromMorphTargetSequences(morphTargets: Array<Any>, fps: Float64, noLoop: Bool): Array<AnimationClip> {
        let animationToMorphTargets = HashMap<String, ArrayList<Any>>()

        // 使用正则表达式匹配变形目标名称模式
        // 例如 flamingo_flyA_003, flamingo_run1_003, crdeath0059
        let pattern = Regex("^([\\w-]*?)([\\d]+)$")

        // 将变形目标名称排序为动画组
        // 模式如 Walk_001, Walk_002, Run_001, Run_002
        for (i in 0..morphTargets.size) {
            let morphTarget = morphTargets[i]
            let morphTargetName = _getMorphTargetName(morphTarget)
            let parts = pattern.find(morphTargetName)

            match (parts) {
                case Some(m) =>
                    // parts[1] 是第一个捕获组（动画名前缀）
                    let name = m.matchString(1)
                    let existing = animationToMorphTargets.get(name)
                    match (existing) {
                        case Some(list) => list.add(morphTarget)
                        case None =>
                            let newList = ArrayList<Any>()
                            newList.add(morphTarget)
                            animationToMorphTargets.add(name, newList)
                    }
                case None => ()
            }
        }

        let clips = ArrayList<AnimationClip>()
        for (key in animationToMorphTargets.keys()) {
            let list = animationToMorphTargets.get(key).getOrThrow()
            clips.add(AnimationClip.CreateFromMorphTargetSequence(key, list.toArray(), fps, noLoop))
        }

        return clips.toArray()
    }

    /**
     * @brief[zh-cn] 将剪辑的持续时间设置为最长的关键帧轨道的持续时间
     * @return[zh-cn] 返回当前剪辑以支持链式调用
     *
     * @brief[en] Sets the duration of the clip to the duration of its longest keyframe track
     * @return[en] Returns this clip for chaining
     */
    public func resetDuration(): AnimationClip {
        let tracks = this.tracks
        var duration: Float64 = 0.0

        for (i in 0..tracks.size) {
            let track = this.tracks[i]
            duration = max(duration, track.times[track.times.size - 1])
        }

        this.duration = duration
        return this
    }

    /**
     * @brief[zh-cn] 将所有轨道裁剪到剪辑的持续时间
     * @return[zh-cn] 返回当前剪辑以支持链式调用
     *
     * @brief[en] Trims all tracks to the clip duration
     * @return[en] Returns this clip for chaining
     */
    public func trim(): AnimationClip {
        for (i in 0..this.tracks.size) {
            this.tracks[i].trim(0.0, this.duration)
        }
        return this
    }

    /**
     * @brief[zh-cn] 对每个轨道执行最小验证
     * @explain[zh-cn] 如果所有轨道都有效则返回 true
     * @return[zh-cn] 剪辑的关键帧是否有效
     *
     * @brief[en] Performs minimal validation on each track
     * @explain[en] Returns true if all tracks are valid
     * @return[en] Whether the clip's keyframes are valid
     */
    public func validate(): Bool {
        var valid = true
        for (i in 0..this.tracks.size) {
            valid = valid && this.tracks[i].validate()
        }
        return valid
    }

    /**
     * @brief[zh-cn] 通过移除等效的连续关键帧来优化每个轨道
     * @explain[zh-cn] 在变形目标序列中很常见
     * @return[zh-cn] 返回当前剪辑以支持链式调用
     *
     * @brief[en] Optimizes each track by removing equivalent successive keyframes
     * @explain[en] This is common in morph target sequences
     * @return[en] Returns this clip for chaining
     */
    public func optimize(): AnimationClip {
        for (i in 0..this.tracks.size) {
            this.tracks[i].optimize()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回具有当前实例复制值的新动画剪辑
     * @return[zh-cn] 当前实例的克隆
     *
     * @brief[en] Returns a new animation clip with copied values of the current instance
     * @return[en] A clone of the current instance
     */
    public func clone(): AnimationClip {
        let tracks = ArrayList<IKeyframeTrack>()

        for (i in 0..this.tracks.size) {
            tracks.add(this.tracks[i].clone())
        }

        let clip = AnimationClip(name: this.name, duration: this.duration, tracks: tracks.toArray(), blendMode: this.blendMode)
        clip.uuid = this.uuid
        // 深拷贝 userData
        for (key in this.userData.keys()) {
            let val = this.userData.get(key)
            match (val) {
                case Some(v) => clip.userData.add(key, v)
                case None => ()
            }
        }

        return clip
    }
}
