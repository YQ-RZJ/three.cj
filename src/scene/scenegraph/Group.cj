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
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
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
        this.materialLibraries = Array<String>()
    }
}
