/**
 * @file[zh-cn] PropertyBinding.cj 属性绑定
 * @brief[zh-cn] 本文件定义属性绑定，负责属性路径的解析与场景图属性值的读写
 * @explain[zh-cn] PropertyBinding 持有场景图中真实属性的引用，供内部使用。
 * Composite 为复合绑定，将同一路径绑定到一组对象，用于 AnimationObjectGroup。
 *
 * @file[en] PropertyBinding.cj Property binding
 * @brief[en] This file defines property bindings, which parse property paths and
 * read/write property values of the scene graph
 * @explain[en] A PropertyBinding holds a reference to a real property in the scene
 * graph for internal use. Composite is a compound binding that binds the same
 * path to a group of objects and is used by AnimationObjectGroup.
 */
package three.animation.blend

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.core.interfaces.IPropertyBindingRoot
import std.collection.*
import std.convert.*
import std.regex.*

/**
 * @brief[zh-cn] 保留字符集：[] . : /，用于构建正则表达式
 */
internal let _RESERVED_CHARS_RE: String = "\\[\\]\\.:\\/"
/**
 * @brief[zh-cn] 匹配保留字符的正则表达式
 */
internal let _reservedRe: Regex = Regex("[" + _RESERVED_CHARS_RE + "]")

/**
 * @brief[zh-cn] 匹配非保留字符
 */
internal let _wordChar: String = "[^" + _RESERVED_CHARS_RE + "]"
/**
 * @brief[zh-cn] 匹配非保留字符或点号
 */
internal let _wordCharOrDot: String = "[^" + _RESERVED_CHARS_RE.replace("\\.", "") + "]"

/**
 * @brief[zh-cn] 匹配父目录，以 '/' 或 ':' 分隔
 */
internal let _directoryRe: String = "((?:" + _wordChar + "+" + "[\\/:])*)"
/**
 * @brief[zh-cn] 匹配目标节点，可包含 word 字符、'.' 或 '-'
 */
internal let _nodeRe: String = "(" + _wordCharOrDot + "+)?"
/**
 * @brief[zh-cn] 匹配目标节点上的对象与 accessor，不能含保留字符
 */
internal let _objectRe: String = "(?:\\.(" + _wordChar + "+)(?:\\[(.+)\\])?)?"
/**
 * @brief[zh-cn] 匹配属性与 accessor，不能含保留字符
 */
internal let _propertyRe: String = "\\.(?:" + _wordChar + "+)(?:\\[(.+)\\])?"
/**
 * @brief[zh-cn] 完整轨道名匹配正则
 */
internal let _trackRe: Regex = Regex("^" + _directoryRe + _nodeRe + _objectRe + _propertyRe + "$")

/**
 * @brief[zh-cn] 支持的节点对象名称
 */
internal let _supportedObjectNames: Array<String> = ["material", "materials", "bones", "map"]

/**
 * @brief[zh-cn] 绑定类型：直接属性绑定
 */
internal let BindingType_Direct: Int64 = 0
/**
 * @brief[zh-cn] 绑定类型：整个数组
 */
internal let BindingType_EntireArray: Int64 = 1
/**
 * @brief[zh-cn] 绑定类型：数组元素
 */
internal let BindingType_ArrayElement: Int64 = 2
/**
 * @brief[zh-cn] 绑定类型：含 fromArray/toArray 方法
 */
internal let BindingType_HasFromToArray: Int64 = 3

/**
 * @brief[zh-cn] 版本控制：无
 */
internal let Versioning_None: Int64 = 0
/**
 * @brief[zh-cn] 版本控制：标记 needsUpdate
 */
internal let Versioning_NeedsUpdate: Int64 = 1
/**
 * @brief[zh-cn] 版本控制：标记 matrixWorldNeedsUpdate
 */
internal let Versioning_MatrixWorldNeedsUpdate: Int64 = 2

/**
 * @brief[zh-cn] Composite 复合属性绑定，用于 AnimationObjectGroup
 * @explain[zh-cn] 将同一属性路径绑定到一组对象，并对所有活跃绑定统一读写。
 *
 * @brief[en] Composite compound property binding, used for AnimationObjectGroup
 * @explain[en] Binds the same property path to a group of objects and reads/writes
 * through all active bindings uniformly.
 */
public class Composite {
    /**
     * @brief[zh-cn] 目标对象组
     */
    internal var _targetGroup: AnimationObjectGroup
    /**
     * @brief[zh-cn] 各对象的绑定列表
     */
    internal var _bindings: ArrayList<PropertyBinding>
    /**
     * @brief[zh-cn] 属性路径
     */
    internal var path: String
    /**
     * @brief[zh-cn] 已解析的路径信息
     */
    internal var parsedPath: HashMap<String, Any>

    /**
     * @brief[zh-cn] 创建复合绑定，为目标对象组中的每个对象创建绑定
     * @param[zh-cn] targetGroup 目标对象组
     * path 属性路径
     * optionalParsedPath 已解析的路径信息
     *
     * @brief[en] Creates a compound binding, creating a binding for each object in the target group
     * @param[en] targetGroup The target object group
     * path The property path
     * optionalParsedPath The parsed path information
     */
    public init(targetGroup: AnimationObjectGroup, path: String, optionalParsedPath: HashMap<String, Any>) {
        this._targetGroup = targetGroup
        this.path = path
        this.parsedPath = optionalParsedPath
        this._bindings = targetGroup.subscribe_(path, optionalParsedPath)
    }

    /**
     * @brief[zh-cn] 获取值 — 绑定所有绑定后，从第一个有效绑定获取值
     * @param[zh-cn] array 目标数组
     * offset 写入偏移
     *
     * @brief[en] Gets the value after binding all bindings, reading from the first valid binding
     * @param[en] array The target array
     * offset The write offset
     */
    public func getValue(array: Array<Float64>, offset: Int64): Unit {
        this.bind() // 绑定所有绑定

        let firstValidIndex = this._targetGroup.nCachedObjects_
        if (firstValidIndex < this._bindings.size) {
            let binding = this._bindings[firstValidIndex]
            binding.getValue(array, offset)
        }
    }

    /**
     * @brief[zh-cn] 设置值 — 对所有活跃绑定设置值
     * @param[zh-cn] array 源数组
     * offset 读取偏移
     *
     * @brief[en] Sets the value on all active bindings
     * @param[en] array The source array
     * offset The read offset
     */
    public func setValue(array: Array<Float64>, offset: Int64): Unit {
        let bindings = this._bindings
        let nCachedObjects = this._targetGroup.nCachedObjects_

        for (i in nCachedObjects..bindings.size) {
            bindings[i].setValue(array, offset)
        }
    }

    /**
     * @brief[zh-cn] 绑定所有活跃绑定
     *
     * @brief[en] Binds all active bindings
     */
    public func bind(): Unit {
        let bindings = this._bindings
        let nCachedObjects = this._targetGroup.nCachedObjects_

        for (i in nCachedObjects..bindings.size) {
            bindings[i].bind()
        }
    }

    /**
     * @brief[zh-cn] 解绑所有活跃绑定
     *
     * @brief[en] Unbinds all active bindings
     */
    public func unbind(): Unit {
        let bindings = this._bindings
        let nCachedObjects = this._targetGroup.nCachedObjects_

        for (i in nCachedObjects..bindings.size) {
            bindings[i].unbind()
        }
    }
}

/**
 * @brief[zh-cn] 属性绑定，将动画轨道的属性路径与实际对象属性关联
 * @explain[zh-cn] 使用状态模式：bind() 会将 getValue/setValue 切换为绑定状态的版本；
 * 当属性未找到时，方法变为空操作。
 *
 * @brief[en] Property binding that associates an animation track's property path with an actual object property
 * @explain[en] Uses a state pattern: bind() swaps getValue/setValue to the bound
 * versions. When the property is not found, the methods become no-ops.
 */
public class PropertyBinding {
    /**
     * @brief[zh-cn] 属性路径
     *
     * @brief[en] The property path
     */
    public var path: String
    /**
     * @brief[zh-cn] 解析后的路径信息
     *
     * @brief[en] The parsed path information
     */
    public var parsedPath: HashMap<String, Any>
    /**
     * @brief[zh-cn] 拥有动画属性的对象
     *
     * @brief[en] The object that owns the animated property
     */
    public var node: IPropertyBindingRoot
    /**
     * @brief[zh-cn] 根节点
     *
     * @brief[en] The root node
     */
    public var rootNode: IPropertyBindingRoot
    /**
     * @brief[zh-cn] 目标对象（bind 后设置）
     *
     * @brief[en] The target object (set after binding)
     */
    public var targetObject: Option<IPropertyBindingRoot>
    /**
     * @brief[zh-cn] 已解析的属性（bind 后设置）
     *
     * @brief[en] The resolved property (set after binding)
     */
    public var resolvedProperty: Option<Any>
    /**
     * @brief[zh-cn] 已解析的对象（bind 后设置）
     *
     * @brief[en] The resolved object (set after binding)
     */
    public var resolvedObject: Option<Any>
    /**
     * @brief[zh-cn] 属性名（bind 后可能更新）
     *
     * @brief[en] The property name (may be updated after binding)
     */
    public var propertyName: String
    /**
     * @brief[zh-cn] 属性索引（bind 后可能更新）
     *
     * @brief[en] The property index (may be updated after binding)
     */
    public var propertyIndex: Option<Any>
    /**
     * @brief[zh-cn] 绑定类型
     */
    internal var bindingType: Int64
    /**
     * @brief[zh-cn] 版本控制类型
     */
    internal var versioning: Int64
    /**
     * @brief[zh-cn] 是否已绑定
     */
    internal var bound: Bool

    /**
     * @brief[zh-cn] 获取值函数
     */
    internal var getValueFunc: (Array<Float64>, Int64) -> Unit
    /**
     * @brief[zh-cn] 设置值函数
     */
    internal var setValueFunc: (Array<Float64>, Int64) -> Unit

    /**
     * @brief[zh-cn] 创建属性绑定实例
     * @param[zh-cn] rootNode 根节点
     * path 属性路径
     * parsedPath 已解析的路径信息
     *
     * @brief[en] Creates a property binding instance
     * @param[en] rootNode The root node
     * path The property path
     * parsedPath The parsed path information
     */
    public init(rootNode: IPropertyBindingRoot, path: String, parsedPath: HashMap<String, Any>) {
        this.path = path
        this.parsedPath = parsedPath
        this.rootNode = rootNode
        this.targetObject = None
        this.resolvedProperty = None
        this.resolvedObject = None
        this.propertyName = ""
        this.propertyIndex = None
        this.bindingType = BindingType_Direct
        this.versioning = Versioning_None
        this.bound = false

        // 查找节点
        let nodeName = _getStringFromMap(parsedPath, "nodeName")
        if (nodeName != "") {
            // findNode 返回 Option<IPropertyBindingRoot>，未找到时回退根节点（与 JS `node === undefined ? rootNode : node` 一致）
            match (PropertyBinding.findNode(rootNode, nodeName)) {
                case Some(n) => this.node = n
                case None => this.node = rootNode
            }
        } else {
            this.node = rootNode
        }

        // 初始状态：未绑定时调用 bind()
        // Ignore: 仓颉 init 中不能调用本类实例方法（open class 限制），用空操作占位并由 bind() 后续填充语义对齐。
        // bind() 会在第一次 getValue/setValue 时被调用
        this.getValueFunc = { _, _ => }
        this.setValueFunc = { _, _ => }
    }

    /**
     * @brief[zh-cn] 创建属性绑定实例；如果根是 AnimationObjectGroup，则返回 Composite 实例
     * @param[zh-cn] root 根对象
     * path 属性路径
     * parsedPath 已解析的路径信息
     * @return[zh-cn] 返回创建的绑定（PropertyBinding 或 Composite）
     *
     * @brief[en] Creates a property binding instance; returns a Composite instance if the root is an AnimationObjectGroup
     * @param[en] root The root object
     * path The property path
     * parsedPath The parsed path information
     * @return[en] Returns the created binding (PropertyBinding or Composite)
     */
    public static func create(root: IPropertyBindingRoot, path: String, parsedPath: HashMap<String, Any>): Any {
        let groupVal = _asAnimationObjectGroup(root)
        if (groupVal.isSome()) {
            return Composite(groupVal.getOrThrow(), path, parsedPath)
        }
        return PropertyBinding(root, path, parsedPath)
    }

    /**
     * @brief[zh-cn] 清理节点名称：将空白替换为下划线，移除保留字符
     * @param[zh-cn] name 节点名称
     * @return[zh-cn] 返回清理后的节点名称
     *
     * @brief[en] Sanitizes a node name by replacing whitespace with underscores and removing reserved characters
     * @param[en] name The node name
     * @return[en] Returns the sanitized node name
     */
    public static func sanitizeNodeName(name: String): String {
        var result = name.replace(" ", "_")
        result = _reservedRe.replaceAll(result, "")
        return result
    }

    /**
     * @brief[zh-cn] 解析轨道名称
     * @explain[zh-cn] 支持如下格式：
     * "nodeName.property"、"nodeName.property[accessor]"、
     * "nodeName.material.property[accessor]"、"uuid.property[accessor]"、
     * "uuid.objectName[objectIndex].propertyName[propertyIndex]"、
     * "parentName/nodeName.property"、".bone[Armature.DEF_cog].position"、
     * "scene:helium_balloon_model:helium_balloon_model.position"
     * @param[zh-cn] trackName 轨道名称
     * @return[zh-cn] 返回包含 nodeName/objectName/objectIndex/propertyName/propertyIndex 的映射
     *
     * @brief[en] Parses a track name
     * @explain[en] Supports formats such as:
     * "nodeName.property", "nodeName.property[accessor]",
     * "nodeName.material.property[accessor]", "uuid.property[accessor]",
     * "uuid.objectName[objectIndex].propertyName[propertyIndex]",
     * "parentName/nodeName.property", ".bone[Armature.DEF_cog].position",
     * "scene:helium_balloon_model:helium_balloon_model.position"
     * @param[en] trackName The track name
     * @return[en] Returns a map containing nodeName/objectName/objectIndex/propertyName/propertyIndex
     *
     * @throws[zh-cn] Exception 当轨道名称无法解析或缺少属性名时
     * @throws[en] Exception When the track name cannot be parsed or the property name is missing
     */
    public static func parseTrackName(trackName: String): HashMap<String, Any> {
        
        let matchesOpt = _trackRe.find(trackName)
        match (matchesOpt) {
            case Some(matches) =>
                // _trackRe 捕获组顺序：1=directory, 2=nodeName, 3=objectName, 4=objectIndex, 5=propertyName, 6=propertyIndex
                // matchString(n) 未匹配时返回空字符串
                let nodeName: String = matches.matchString(2)
                let objectName: String = matches.matchString(3)
                let oiStr: String = matches.matchString(4)
                let propertyName: String = matches.matchString(5)
                let piStr: String = matches.matchString(6)
                let objectIndex: Option<Any> = if (oiStr == "") { None } else { Some(oiStr) }
                let propertyIndex: Option<Any> = if (piStr == "") { None } else { Some(piStr) }
                
                var finalNodeName = nodeName
                var finalObjectName = objectName
                let lastDotOpt = finalNodeName.lastIndexOf(".")
                match (lastDotOpt) {
                    case Some(lastDot) =>
                        if (lastDot >= 0 && lastDot < finalNodeName.size - 1) {
                            let possibleObjectName = finalNodeName[lastDot + 1..]
                            var isSupported = false
                            for (sup in _supportedObjectNames) {
                                if (possibleObjectName == sup) { isSupported = true; break }
                            }
                            if (isSupported && finalObjectName == "") {
                                finalNodeName = finalNodeName[0..lastDot]
                                finalObjectName = possibleObjectName
                            }
                        }
                    case None => ()
                }
                if (propertyName == "") {
                    throw Exception("THREE.PropertyBinding: can not parse propertyName from trackName: " + trackName)
                }
                let result = HashMap<String, Any>()
                result.add("nodeName", finalNodeName)
                result.add("objectName", finalObjectName)
                result.add("objectIndex", objectIndex)
                result.add("propertyName", propertyName)
                result.add("propertyIndex", propertyIndex)
                return result
            case None =>
                throw Exception("THREE.PropertyBinding: Cannot parse trackName: " + trackName)
        }
    }

    /**
     * @brief[zh-cn] 在根对象的层级中搜索指定名称的节点
     * @param[zh-cn] root 根对象
     * nodeName 节点名称
     * @return[zh-cn] 返回找到的节点；未找到返回 None
     *
     * @brief[en] Searches the root object's hierarchy for a node with the given name
     * @param[en] root The root object
     * nodeName The node name
     * @return[en] Returns the found node, or None if not found
     */
    public static func findNode(root: IPropertyBindingRoot, nodeName: String): Option<IPropertyBindingRoot> {
        
        if (nodeName == "" || nodeName == "." || nodeName == "-1") {
            return Some(root)
        }

        // 检查根节点本身
        match (root) {
            case obj: Object3D =>
                if (obj.name == nodeName) {
                    return Some(root)
                }
                // 检查 UUID
                if (obj.uuid == nodeName) {
                    return Some(root)
                }
                
                // 搜索骨骼
                match (obj) {
                    case skinned: SkinnedMesh =>
                        let boneOpt = skinned.skeleton.getBoneByName(nodeName)
                        if (boneOpt.isSome()) {
                            // Bone <: Object3D <: IPropertyBindingRoot——中间变量向上转型（避免 as 在 Some 内解析问题）
                            return match (boneOpt) {
                                case Some(b) =>
                                    let bRoot: IPropertyBindingRoot = b
                                    Option<IPropertyBindingRoot>.Some(bRoot)
                                case None => Option<IPropertyBindingRoot>.None
                            }
                        }
                    case _ => ()
                }
                
                // 递归搜索子节点
                return _searchNodeSubtree(obj, nodeName)
            case _ => ()
        }

        
        return None
    }

    /**
     * @brief[zh-cn] 递归搜索子节点树
     */
    internal static func _searchNodeSubtree(root: Object3D, nodeName: String): Option<IPropertyBindingRoot> {
        for (i in 0..root.children.size) {
            let childNode = root.children[i]
            if (childNode.name == nodeName || childNode.uuid == nodeName) {
                return Some(childNode)
            }
            let result = _searchNodeSubtree(childNode, nodeName)
            match (result) {
                case Some(_) => return result
                case None => ()
            }
        }
        return None
    }

    /**
     * @brief[zh-cn] 将对象转换为 AnimationObjectGroup（无法转换时返回 None）
     */
    internal static func _asAnimationObjectGroup(obj: Any): Option<AnimationObjectGroup> {
        match (obj) {
            case g: AnimationObjectGroup => Some(g)
            case _ => None
        }
    }

    // === 值读写方法 ===

    /** 不可用的获取值方法 */
    internal func _getValue_unavailable(buffer: Array<Float64>, offset: Int64): Unit {
        // 属性未找到时的空操作
    }

    /** 不可用的设置值方法 */
    internal func _setValue_unavailable(buffer: Array<Float64>, offset: Int64): Unit {
        // 属性未找到时的空操作
    }

    /** 直接获取值 */
    internal func _getValue_direct(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.targetObject) {
            case obj: Object3D =>
                if (this.propertyName == "visible") {
                    buffer[offset] = if (obj.visible) { 1.0 } else { 0.0 }
                }
            case _ => ()
        }
    }

    /** 获取数组值 */
    internal func _getValue_array(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.resolvedProperty) {
            case arr: Array<Float64> =>
                for (i in 0..arr.size) {
                    buffer[offset + i] = arr[i]
                }
            case arr: ArrayList<Float64> =>
                for (i in 0..arr.size) {
                    buffer[offset + i] = arr[i]
                }
            case _ => ()
        }
    }

    /** 获取数组元素值 */
    internal func _getValue_arrayElement(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.resolvedProperty) {
            case arr: Array<Float64> =>
                match (this.propertyIndex) {
                    case Some(idx) =>
                        match (idx) {
                            case i: Int64 => if (i >= 0 && i < arr.size) { buffer[offset] = arr[i] }
                            case _ => ()
                        }
                    case None => ()
                }
            case arr: ArrayList<Float64> =>
                match (this.propertyIndex) {
                    case Some(idx) =>
                        match (idx) {
                            case i: Int64 => if (i >= 0 && i < arr.size) { buffer[offset] = arr[i] }
                            case _ => ()
                        }
                    case None => ()
                }
            case _ => ()
        }
    }

    /** 通过 toArray 获取值 */
    internal func _getValue_toArray(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.resolvedProperty) {
            case v: Vector3 =>
                buffer[offset] = v.x
                buffer[offset + 1] = v.y
                buffer[offset + 2] = v.z
            case q: Quaternion =>
                buffer[offset] = q.x
                buffer[offset + 1] = q.y
                buffer[offset + 2] = q.z
                buffer[offset + 3] = q.w
            case e: Euler =>
                buffer[offset] = e.x
                buffer[offset + 1] = e.y
                buffer[offset + 2] = e.z
            case c: Color =>
                buffer[offset] = c.r
                buffer[offset + 1] = c.g
                buffer[offset + 2] = c.b
            case _ => ()
        }
    }

    /** 直接设置值 */
    internal func _setValue_direct(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.targetObject) {
            case obj: Object3D =>
                if (this.propertyName == "visible") {
                    obj.visible = buffer[offset] != 0.0
                }
            case _ => ()
        }
    }

    /** 直接设置值并标记 needsUpdate */
    internal func _setValue_direct_setNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_direct(buffer, offset)
        match (this.targetObject) {
            case obj: Object3D =>
                obj.matrixWorldNeedsUpdate = true
            case _ => ()
        }
    }

    /** 直接设置值并标记 matrixWorldNeedsUpdate */
    internal func _setValue_direct_setMatrixWorldNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_direct(buffer, offset)
        match (this.targetObject) {
            case obj: Object3D =>
                obj.matrixWorldNeedsUpdate = true
            case _ => ()
        }
    }

    /** 设置整个数组值 */
    internal func _setValue_array(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.resolvedProperty) {
            case arr: Array<Float64> =>
                for (i in 0..arr.size) {
                    arr[i] = buffer[offset + i]
                }
            case arr: ArrayList<Float64> =>
                for (i in 0..arr.size) {
                    arr[i] = buffer[offset + i]
                }
            case _ => ()
        }
    }

    /** 设置整个数组值并标记 needsUpdate */
    internal func _setValue_array_setNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_array(buffer, offset)
    }

    /** 设置整个数组值并标记 matrixWorldNeedsUpdate */
    internal func _setValue_array_setMatrixWorldNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_array(buffer, offset)
        match (this.targetObject) {
            case obj: Object3D =>
                obj.matrixWorldNeedsUpdate = true
            case _ => ()
        }
    }

    /** 设置数组元素值 */
    internal func _setValue_arrayElement(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.resolvedProperty) {
            case arr: Array<Float64> =>
                match (this.propertyIndex) {
                    case Some(idx) =>
                        match (idx) {
                            case i: Int64 => if (i >= 0 && i < arr.size) { arr[i] = buffer[offset] }
                            case _ => ()
                        }
                    case None => ()
                }
            case arr: ArrayList<Float64> =>
                match (this.propertyIndex) {
                    case Some(idx) =>
                        match (idx) {
                            case i: Int64 => if (i >= 0 && i < arr.size) { arr[i] = buffer[offset] }
                            case _ => ()
                        }
                    case None => ()
                }
            case _ => ()
        }
    }

    /** 设置数组元素值并标记 needsUpdate */
    internal func _setValue_arrayElement_setNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_arrayElement(buffer, offset)
    }

    /** 设置数组元素值并标记 matrixWorldNeedsUpdate */
    internal func _setValue_arrayElement_setMatrixWorldNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_arrayElement(buffer, offset)
        match (this.targetObject) {
            case obj: Object3D =>
                obj.matrixWorldNeedsUpdate = true
            case _ => ()
        }
    }

    /** 通过 fromArray 设置值 */
    internal func _setValue_fromArray(buffer: Array<Float64>, offset: Int64): Unit {
        match (this.resolvedProperty) {
            case v: Vector3 =>
                v.x = buffer[offset]
                v.y = buffer[offset + 1]
                v.z = buffer[offset + 2]
            case q: Quaternion =>
                q.x = buffer[offset]
                q.y = buffer[offset + 1]
                q.z = buffer[offset + 2]
                q.w = buffer[offset + 3]
            case e: Euler =>
                e.x = buffer[offset]
                e.y = buffer[offset + 1]
                e.z = buffer[offset + 2]
            case c: Color =>
                c.r = buffer[offset]
                c.g = buffer[offset + 1]
                c.b = buffer[offset + 2]
            case _ => ()
        }
    }

    /** 通过 fromArray 设置值并标记 needsUpdate */
    internal func _setValue_fromArray_setNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_fromArray(buffer, offset)
    }

    /** 通过 fromArray 设置值并标记 matrixWorldNeedsUpdate */
    internal func _setValue_fromArray_setMatrixWorldNeedsUpdate(buffer: Array<Float64>, offset: Int64): Unit {
        this._setValue_fromArray(buffer, offset)
        match (this.targetObject) {
            case obj: Object3D =>
                obj.matrixWorldNeedsUpdate = true
            case _ => ()
        }
    }

    /** 未绑定状态的获取值方法 — 先绑定再获取 */
    internal func _getValue_unbound(targetArray: Array<Float64>, offset: Int64): Unit {
        this.bind()
        this.getValue(targetArray, offset)
    }

    /** 未绑定状态的设置值方法 — 先绑定再设置 */
    internal func _setValue_unbound(sourceArray: Array<Float64>, offset: Int64): Unit {
        this.bind()
        this.setValue(sourceArray, offset)
    }

    /**
     * @brief[zh-cn] 获取值
     * @param[zh-cn] array 目标数组
     * offset 写入偏移
     *
     * @brief[en] Gets the value
     * @param[en] array The target array
     * offset The write offset
     */
    public func getValue(array: Array<Float64>, offset: Int64): Unit {
        this.getValueFunc(array, offset)
    }

    /**
     * @brief[zh-cn] 设置值
     * @param[zh-cn] array 源数组
     * offset 读取偏移
     *
     * @brief[en] Sets the value
     * @param[en] array The source array
     * offset The read offset
     */
    public func setValue(array: Array<Float64>, offset: Int64): Unit {
        this.setValueFunc(array, offset)
    }

    /**
     * @brief[zh-cn] 创建 getter/setter 对，绑定此绑定跟踪的属性
     *
     * @brief[en] Creates getter/setter pairs and binds the property tracked by this binding
     *
     * @note[zh-cn] 绑定后 getValue/setValue 会被替换为绑定状态的版本；属性未找到时变为空操作。
     * @note[en] After binding, getValue/setValue are swapped to their bound versions; they
     * become no-ops when the property is not found.
     */
    public func bind(): Unit {
        var targetObject: IPropertyBindingRoot = this.node
        let parsedPath = this.parsedPath

        let objectName = _getStringFromMap(parsedPath, "objectName")
        let propertyName = _getStringFromMap(parsedPath, "propertyName")
        var propertyIndexVal = parsedPath.get("propertyIndex")

        // 如果节点未找到，尝试重新查找
        match (targetObject) {
            case obj: Object3D =>
                () // 已有节点
            case _ =>
                let nodeName = _getStringFromMap(parsedPath, "nodeName")
                if (nodeName != "") {
                    let found = PropertyBinding.findNode(this.rootNode, nodeName)
                    match (found) {
                        case Some(n) => targetObject = n; this.node = n
                        case None => ()
                    }
                }
        }

        // 设置失败状态，出错时直接返回
        this.getValueFunc = { buf, off => this._getValue_unavailable(buf, off) }
        this.setValueFunc = { buf, off => this._setValue_unavailable(buf, off) }

        // 确保有目标对象
        match (targetObject) {
            case obj: Object3D =>
                () // 有效目标
            case _ =>
                return // 没有目标节点，无法绑定
        }

        // 处理对象名（如 material, materials, bones, map）
        if (objectName != "") {
            let objectIndexVal = parsedPath.get("objectIndex")

            match (objectName) {
                case "materials" =>
                    match (targetObject) {
                        case obj: Mesh =>
                            match (objectIndexVal) {
                                case Some(idx: Int64) =>
                                    if (idx == 0) {
                                        this.resolvedObject = obj.material
                                    }
                                case _ =>
                                    this.resolvedObject = obj.material
                            }
                        case _ => ()
                    }
                case "bones" =>
                    match (targetObject) {
                        case obj: Object3D =>
                            // 骨骼搜索：通过 children 递归查找
                            let found = _searchNodeSubtree(obj, objectName)
                            match (found) {
                                case Some(bone) => this.resolvedObject = bone
                                case None => ()
                            }
                        case _ => ()
                    }
                case "map" =>
                    match (targetObject) {
                        case obj: Mesh =>
                            // 从材质获取 map 贴图
                            this.resolvedProperty = "map"
                        case _ => ()
                    }
                case _ => ()
            }
        }

        // 确定版本控制方式
        var versioning = Versioning_None
        match (targetObject) {
            case obj: Object3D =>
                versioning = Versioning_MatrixWorldNeedsUpdate
            case _ => ()
        }

        // 确定绑定类型并选择 getter/setter
        this.propertyName = propertyName
        this.targetObject = Some(targetObject)

        if (propertyIndexVal.isSome()) {
            // 访问属性数组的子元素
            this.bindingType = BindingType_ArrayElement
            this.propertyIndex = propertyIndexVal

            // morphTargetInfluences 特殊处理
            if (propertyName == "morphTargetInfluences") {
                match (targetObject) {
                    case mesh: Mesh =>
                        match (propertyIndexVal) {
                            case Some(idx) =>
                                match (idx) {
                                    case idxStr: String =>
                                        // 尝试从 morphTargetDictionary 解析索引
                                        let morphIdx = mesh.morphTargetDictionary.get(idxStr)
                                        match (morphIdx) {
                                            case Some(i) =>
                                                this.propertyIndex = Some(i)
                                            case None => ()
                                        }
                                    case i: Int64 =>
                                        this.propertyIndex = Some(i)
                                    case _ => ()
                                }
                            case None => ()
                        }
                    case _ => ()
                }
            }

            // 设置 resolvedProperty
            this._resolveProperty(targetObject, propertyName)

            // 选择 getter/setter
            this.getValueFunc = { buf, off => this._getValue_arrayElement(buf, off) }
            if (versioning == Versioning_NeedsUpdate) {
                this.setValueFunc = { buf, off => this._setValue_arrayElement_setNeedsUpdate(buf, off) }
            } else if (versioning == Versioning_MatrixWorldNeedsUpdate) {
                this.setValueFunc = { buf, off => this._setValue_arrayElement_setMatrixWorldNeedsUpdate(buf, off) }
            } else {
                this.setValueFunc = { buf, off => this._setValue_arrayElement(buf, off) }
            }
        } else {
            // 检查属性是否有 fromArray/toArray 方法
            let hasFromArrayToArray = this._checkFromToArray(targetObject, propertyName)

            if (hasFromArrayToArray) {
                this.bindingType = BindingType_HasFromToArray
                this._resolveProperty(targetObject, propertyName)

                this.getValueFunc = { buf, off => this._getValue_toArray(buf, off) }
                if (versioning == Versioning_NeedsUpdate) {
                    this.setValueFunc = { buf, off => this._setValue_fromArray_setNeedsUpdate(buf, off) }
                } else if (versioning == Versioning_MatrixWorldNeedsUpdate) {
                    this.setValueFunc = { buf, off => this._setValue_fromArray_setMatrixWorldNeedsUpdate(buf, off) }
                } else {
                    this.setValueFunc = { buf, off => this._setValue_fromArray(buf, off) }
                }
            } else if (this._isArrayProperty(targetObject, propertyName)) {
                this.bindingType = BindingType_EntireArray
                this._resolveProperty(targetObject, propertyName)

                this.getValueFunc = { buf, off => this._getValue_array(buf, off) }
                if (versioning == Versioning_NeedsUpdate) {
                    this.setValueFunc = { buf, off => this._setValue_array_setNeedsUpdate(buf, off) }
                } else if (versioning == Versioning_MatrixWorldNeedsUpdate) {
                    this.setValueFunc = { buf, off => this._setValue_array_setMatrixWorldNeedsUpdate(buf, off) }
                } else {
                    this.setValueFunc = { buf, off => this._setValue_array(buf, off) }
                }
            } else {
                this.bindingType = BindingType_Direct

                this.getValueFunc = { buf, off => this._getValue_direct(buf, off) }
                if (versioning == Versioning_NeedsUpdate) {
                    this.setValueFunc = { buf, off => this._setValue_direct_setNeedsUpdate(buf, off) }
                } else if (versioning == Versioning_MatrixWorldNeedsUpdate) {
                    this.setValueFunc = { buf, off => this._setValue_direct_setMatrixWorldNeedsUpdate(buf, off) }
                } else {
                    this.setValueFunc = { buf, off => this._setValue_direct(buf, off) }
                }
            }
        }

        this.bound = true
    }

    /**
     * @brief[zh-cn] 解绑属性，恢复到未绑定状态
     *
     * @brief[en] Unbinds the property and restores the unbound state
     */
    public func unbind(): Unit {
        this.node = this.rootNode

        // 恢复到未绑定状态的 getValue/setValue
        this.getValueFunc = { buf, off => this._getValue_unbound(buf, off) }
        this.setValueFunc = { buf, off => this._setValue_unbound(buf, off) }
        this.bound = false
    }

    // === 内部辅助方法 ===

    /**
     * @brief[zh-cn] 解析目标对象上的属性
     */
    internal func _resolveProperty(target: Any, propName: String): Unit {
        match (target) {
            case obj: Object3D =>
                if (propName == "position") {
                    this.resolvedProperty = Some(obj.position)
                } else if (propName == "quaternion") {
                    this.resolvedProperty = Some(obj.quaternion)
                } else if (propName == "scale") {
                    this.resolvedProperty = Some(obj.scale)
                } else if (propName == "morphTargetInfluences") {
                    match (target) {
                        case mesh: Mesh => this.resolvedProperty = Some(mesh.morphTargetInfluences)
                        case _ => ()
                    }
                }
            case _ => ()
        }
    }

    /**
     * @brief[zh-cn] 检查属性是否具有 fromArray/toArray 方法
     */
    internal func _checkFromToArray(target: Any, propName: String): Bool {
        match (target) {
            case obj: Object3D =>
                if (propName == "position" || propName == "quaternion" || propName == "scale") {
                    return true
                }
            case _ => ()
        }
        return false
    }

    /**
     * @brief[zh-cn] 检查属性是否为数组类型
     */
    internal func _isArrayProperty(target: Any, propName: String): Bool {
        match (target) {
            case obj: Object3D =>
                if (propName == "morphTargetInfluences") {
                    return true
                }
            case _ => ()
        }
        return false
    }
}

// === 辅助函数 ===

/**
 * @brief[zh-cn] 从映射中读取字符串值，键不存在或类型不符时返回空字符串
 */
internal func _getStringFromMap(map: HashMap<String, Any>, key: String): String {
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

/**
 * @brief[zh-cn] 从映射中读取整数值，键不存在或类型不符时返回默认值
 */
internal func _getIntFromMap(map: HashMap<String, Any>, key: String, defaultVal: Int64): Int64 {
    let optVal = map.get(key)
    if (optVal.isSome()) {
        let v = optVal.getOrThrow()
        match (v) {
            case i: Int64 => return i
            case _ => return defaultVal
        }
    }
    return defaultVal
}

/**
 * @brief[zh-cn] 从映射中读取浮点值，键不存在或类型不符时返回默认值
 */
internal func _getFloatFromMap(map: HashMap<String, Any>, key: String, defaultVal: Float64): Float64 {
    let optVal = map.get(key)
    if (optVal.isSome()) {
        let v = optVal.getOrThrow()
        match (v) {
            case f: Float64 => return f
            case _ => return defaultVal
        }
    }
    return defaultVal
}
