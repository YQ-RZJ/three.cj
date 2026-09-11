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
 * @file[zh-cn] 图层
 * @brief[zh-cn] 将 3D 对象分配到 0~31 共 32 个图层中，对应 Three.js Layers.js
 * @explain[zh-cn] 图层使用位掩码存储，默认所有对象属于图层 0。
 * 对象必须与相机共享至少一个图层才能在该相机的视图中可见。
 *
 * @file[en] Layers
 * @brief[en] Assign 3D objects to 32 layers (0~31), corresponding to Three.js Layers.js
 * @explain[en] Layers use bitmask storage, default all objects belong to layer 0.
 * An object must share at least one layer with the camera to be visible in that camera's view.
 */
package three.scene.objects

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 图层类，使用位掩码管理 32 个图层的成员关系
 * @explain[zh-cn] 图层用于控制对象的可见性——一个对象必须与相机共享至少一个图层，
 * 才能在该相机的渲染视图中可见。所有继承自 Object3D 的类都有一个 layers 属性，它是此类的实例。
 *
 * @brief[en] Layers class, managing 32 layer memberships using a bitmask
 * @explain[en] Layers control object visibility — an object must share at least one layer with the camera
 * to be visible in that camera's rendering view. All classes inheriting from Object3D have a layers property, which is an instance of this class.
 */
@JsonAdapter
public class Layers {
    /**
     * @brief[zh-cn] 位掩码，存储当前对象所属的图层
     * @explain[zh-cn] 内部使用 UInt32 的位来表示 32 个图层的成员关系，默认 1（仅属于图层 0）
     *
     * @brief[en] Bitmask storing the current object's layer memberships
     * @explain[en] Internally uses UInt32 bits to represent 32 layer memberships, default 1 (layer 0 only)
     */
    public var mask: UInt32

    /**
     * @brief[zh-cn] 构造一个新的图层实例，默认属于图层 0
     *
     * @brief[en] Construct a new layers instance, default belonging to layer 0
     */
    public init() {
        this.mask = 1u32
    }

    /**
     * @brief[zh-cn] 设置仅属于指定图层，移除其他所有图层的成员关系
     * @param[zh-cn] layer 图层编号（0~31）
     *
     * @brief[en] Set to belong only to the specified layer, removing all other layer memberships
     * @param[en] layer Layer number (0~31)
     */
    public func set(layer: UInt32): Unit {
        this.mask = (1u32 << layer)
    }

    /**
     * @brief[zh-cn] 启用指定图层（添加成员关系）
     * @param[zh-cn] layer 图层编号（0~31）
     *
     * @brief[en] Enable the specified layer (add membership)
     * @param[en] layer Layer number (0~31)
     */
    public func enable(layer: UInt32): Unit {
        this.mask = this.mask | (1u32 << layer)
    }

    /**
     * @brief[zh-cn] 启用所有图层
     *
     * @brief[en] Enable all layers
     */
    public func enableAll(): Unit {
        this.mask = 0xFFFFFFFFu32
    }

    /**
     * @brief[zh-cn] 切换指定图层的成员关系
     * @param[zh-cn] layer 图层编号（0~31）
     *
     * @brief[en] Toggle the specified layer's membership
     * @param[en] layer Layer number (0~31)
     */
    public func toggle(layer: UInt32): Unit {
        this.mask = this.mask ^ (1u32 << layer)
    }

    /**
     * @brief[zh-cn] 禁用指定图层（移除成员关系）
     * @param[zh-cn] layer 图层编号（0~31）
     *
     * @brief[en] Disable the specified layer (remove membership)
     * @param[en] layer Layer number (0~31)
     */
    public func disable(layer: UInt32): Unit {
        this.mask = this.mask & (UInt32.Max ^ (1u32 << layer))
    }

    /**
     * @brief[zh-cn] 禁用所有图层
     *
     * @brief[en] Disable all layers
     */
    public func disableAll(): Unit {
        this.mask = 0u32
    }

    /**
     * @brief[zh-cn] 测试此图层对象与给定图层对象是否共享至少一个图层
     * @param[zh-cn] layers 要测试的图层对象
     * @return[zh-cn] 如果共享至少一个图层则返回 true
     *
     * @brief[en] Test whether this layers object shares at least one layer with the given layers object
     * @param[en] layers The layers object to test against
     * @return[en] Returns true if at least one layer is shared
     */
    public func test(layers: Layers): Bool {
        return (this.mask & layers.mask) != 0u32
    }

    /**
     * @brief[zh-cn] 测试指定图层是否已启用
     * @param[zh-cn] layer 图层编号（0~31）
     * @return[zh-cn] 如果指定图层已启用则返回 true
     *
     * @brief[en] Test whether the specified layer is enabled
     * @param[en] layer Layer number (0~31)
     * @return[en] Returns true if the specified layer is enabled
     */
    public func isEnabled(layer: UInt32): Bool {
        return (this.mask & (1u32 << layer)) != 0u32
    }
}
