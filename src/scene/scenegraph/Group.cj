/**
 * @file[zh-cn] Group
 * @brief[zh-cn] 组，无变换的容器型场景对象
 * @explain[zh-cn] 用于将一组子对象整体平移/旋转/缩放。与 Object3D 唯一区别：
 * 渲染时跳过本身（无几何/材质），仅作为分组节点。
 *
 * @file[en] Group
 * @brief[en] Group, a transform-less container scene object
 * @explain[en] Used to translate/rotate/scale a group of child objects as a whole.
 * The only difference from Object3D: rendering skips the group itself (no geometry/material),
 * it serves only as a grouping node.
 */
package three.scene.scenegraph
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.scene.interfaces.IGroup
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 组，无变换的容器型场景对象
 * @explain[zh-cn] 用于将一组子对象整体平移/旋转/缩放，渲染时跳过本身
 *
 * @brief[en] Group, a transform-less container scene object
 * @explain[en] Used to translate/rotate/scale child objects as a whole, rendering skips the group itself
 */
@JsonAdapter[withSuperClass = Object3D]
public class Group <: Object3D & IGroup {

    /**
     * @brief[zh-cn] 材质库文件路径列表（OBJLoader 使用）
     *
     * @brief[en] Material library file path list (used by OBJLoader)
     */
    public var materialLibraries: Array<String>

    /**
     * @brief[zh-cn] 构造一个新的组
     *
     * @brief[en] Construct a new group
     */
    public init() {
        super()
        this.kind = "Group"
        this.materialLibraries = Array<String>()
    }
}
