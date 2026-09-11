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
 * @file[zh-cn] AnimationObjectGroup 动画对象组
 * @brief[zh-cn] 管理一组动画目标对象，允许一组对象共享同一个动画
 * @explain[zh-cn] 将多个 Object3D 对象组织为一个整体，使它们能够被同一个动画剪辑驱动。
 * 内部维护对象缓存区域与活跃区域、按路径解析的绑定数组，
 * 支持 add/remove/uncache 及订阅/取消订阅属性路径。
 *
 * @file[en] AnimationObjectGroup  Animation object group
 * @brief[en] Manages a group of animation targets, allowing a set of objects to share the same animation
 * @explain[en] Groups multiple Object3D objects so they can be driven by the same animation
 * clip. Internally keeps a cached region and an active region of objects plus
 * per-path binding arrays, and supports add/remove/uncache as well as subscribing
 * to and unsubscribing from property paths.
 */
package three.animation.blend

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 动画对象组，允许一组对象共享同一个动画
 * @explain[zh-cn] 将多个 Object3D 组织为一个组，组内每个对象拥有独立的属性绑定，
 * 因此当组中对象数量变化时无需重建绑定，动画即可应用到组内所有对象。
 *
 * @brief[en] Animation object group that lets a set of objects share the same animation
 * @explain[en] Organizes several Object3D objects into a group where each object keeps its
 * own property bindings, so animations apply to all objects in the group without
 * rebuilding bindings when the member count changes.
 */
public class AnimationObjectGroup {
    /**
     * @brief[zh-cn] 组唯一标识符
     *
     * @brief[en] Unique identifier of the group
     */
    public var uuid: String
    /**
     * @brief[zh-cn] 内部对象数组（缓存对象后跟活跃对象）
     *
     * @brief[en] Internal object array (cached objects followed by active objects)
     */
    internal var _objects: ArrayList<Object3D>
    /**
     * @brief[zh-cn] 缓存对象数量阈值
     *
     * @brief[en] Cached object count threshold
     */
    internal var nCachedObjects_: Int64
    /**
     * @brief[zh-cn] 按对象 UUID 到索引的映射
     *
     * @brief[en] Map from object UUID to index
     */
    internal var _indicesByUUID: HashMap<String, Int64>
    /**
     * @brief[zh-cn] 已订阅的属性路径列表
     *
     * @brief[en] List of subscribed property paths
     */
    internal var _paths: ArrayList<String>
    /**
     * @brief[zh-cn] 已解析的属性路径列表
     *
     * @brief[en] List of parsed property paths
     */
    internal var _parsedPaths: ArrayList<HashMap<String, Any>>
    /**
     * @brief[zh-cn] 按路径分组的属性绑定列表
     *
     * @brief[en] List of property bindings grouped by path
     */
    internal var _bindings: ArrayList<ArrayList<PropertyBinding>>
    /**
     * @brief[zh-cn] 按路径到绑定列表索引的映射
     *
     * @brief[en] Map from path to index in the bindings list
     */
    internal var _bindingsIndicesByPath: HashMap<String, Int64>
    /**
     * @brief[zh-cn] 统计信息
     *
     * @brief[en] Statistics
     */
    public var stats: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造一个新的动画对象组
     * @param[zh-cn] objects 初始加入组的 Object3D 对象数组，默认为空
     *
     * @brief[en] Constructs a new animation object group
     * @param[en] objects The initial array of Object3D objects in the group, defaults to empty
     */
    public init(objects!: Array<Object3D> = Array<Object3D>()) {
        this.uuid = MathUtils.generateUUID()

        // 缓存对象后跟活跃对象
        this._objects = ArrayList<Object3D>()
        for (obj in objects) { this._objects.add(obj) }

        this.nCachedObjects_ = 0 // 阈值

        this._indicesByUUID = HashMap<String, Int64>()
        for (i in 0..objects.size) {
            this._indicesByUUID.add(objects[i].uuid, i)
        }

        this._paths = ArrayList<String>()
        this._parsedPaths = ArrayList<HashMap<String, Any>>()
        this._bindings = ArrayList<ArrayList<PropertyBinding>>()
        this._bindingsIndicesByPath = HashMap<String, Int64>()

        this.stats = HashMap<String, Any>()
        this.stats.add("total", this._objects.size)
        this.stats.add("inUse", this._objects.size - this.nCachedObjects_)
        this.stats.add("bindingsPerObject", this._bindings.size)
    }

    /**
     * @brief[zh-cn] 添加任意数量的对象到此动画组
     * @param[zh-cn] objects 要添加的 3D 对象数组
     *
     * @brief[en] Adds any number of objects to this animation group
     * @param[en] objects The 3D objects to add
     */
    public func add(objects: Array<Object3D>): Unit {
        let objectsArr = this._objects
        let indicesByUUID = this._indicesByUUID
        let paths = this._paths
        let parsedPaths = this._parsedPaths
        let bindings = this._bindings
        let nBindings = bindings.size

        var nObjects = objectsArr.size
        var nCachedObjects = this.nCachedObjects_

        for (i in 0..objects.size) {
            let object = objects[i]
            let uuid = object.uuid
            let indexOpt = indicesByUUID.get(uuid)

            if (indexOpt.isNone()) {
                // 未知对象 -> 添加到活跃区域
                let index = nObjects
                nObjects += 1
                indicesByUUID.add(uuid, index)
                objectsArr.add(object)

                // 为所有绑定创建新 PropertyBinding
                for (j in 0..nBindings) {
                    bindings[j].add(PropertyBinding(object, paths[j], parsedPaths[j]))
                }

            } else {
                let index = indexOpt.getOrThrow()
                if (index < nCachedObjects) {
                    // 将已存在的对象移动到活跃区域
                    let firstActiveIndex = nCachedObjects - 1
                    nCachedObjects -= 1
                    let lastCachedObject = objectsArr[firstActiveIndex]

                    indicesByUUID.add(lastCachedObject.uuid, index)
                    objectsArr[index] = lastCachedObject

                    indicesByUUID.add(uuid, firstActiveIndex)
                    objectsArr[firstActiveIndex] = object

                    // 为所有绑定执行相同操作
                    for (j in 0..nBindings) {
                        let bindingsForPath = bindings[j]
                        let lastCached = bindingsForPath[firstActiveIndex]
                        let bindingOpt = if (index < bindingsForPath.size) { Some(bindingsForPath[index]) } else { None<PropertyBinding> }

                        bindingsForPath[index] = lastCached

                        let binding = match (bindingOpt) {
                            case Some(b) => b
                            case None => PropertyBinding(object, paths[j], parsedPaths[j])
                        }

                        bindingsForPath[firstActiveIndex] = binding
                    }
                }
                // 否则对象已经在期望的位置
            }
        }

        this.nCachedObjects_ = nCachedObjects
        this.stats.add("total", this._objects.size)
        this.stats.add("inUse", this._objects.size - this.nCachedObjects_)
    }

    /**
     * @brief[zh-cn] 从此动画组中移除任意数量的对象
     * @param[zh-cn] objects 要移除的 3D 对象数组
     *
     * @brief[en] Removes any number of objects from this animation group
     * @param[en] objects The 3D objects to remove
     */
    public func remove(objects: Array<Object3D>): Unit {
        let objectsArr = this._objects
        let indicesByUUID = this._indicesByUUID
        let bindings = this._bindings
        let nBindings = bindings.size

        var nCachedObjects = this.nCachedObjects_

        for (i in 0..objects.size) {
            let object = objects[i]
            let uuid = object.uuid
            let indexOpt = indicesByUUID.get(uuid)

            if (indexOpt.isSome()) {
                let index = indexOpt.getOrThrow()
                if (index >= nCachedObjects) {
                    // 将对象移入缓存区域
                    let lastCachedIndex = nCachedObjects
                    nCachedObjects += 1
                    let firstActiveObject = objectsArr[lastCachedIndex]

                    indicesByUUID.add(firstActiveObject.uuid, index)
                    objectsArr[index] = firstActiveObject

                    indicesByUUID.add(uuid, lastCachedIndex)
                    objectsArr[lastCachedIndex] = object

                    // 为所有绑定执行相同操作
                    for (j in 0..nBindings) {
                        let bindingsForPath = bindings[j]
                        let firstActive = bindingsForPath[lastCachedIndex]
                        let binding = bindingsForPath[index]

                        bindingsForPath[index] = firstActive
                        bindingsForPath[lastCachedIndex] = binding
                    }
                }
            }
        }

        this.nCachedObjects_ = nCachedObjects
        this.stats.add("total", this._objects.size)
        this.stats.add("inUse", this._objects.size - this.nCachedObjects_)
    }

    /**
     * @brief[zh-cn] 释放传入的 3D 对象的所有内存资源
     * @param[zh-cn] objects 要取消缓存的 3D 对象数组
     *
     * @brief[en] Releases all memory resources of the given 3D objects
     * @param[en] objects The 3D objects to uncache
     */
    public func uncache(objects: Array<Object3D>): Unit {
        let objectsArr = this._objects
        let indicesByUUID = this._indicesByUUID
        let bindings = this._bindings
        let nBindings = bindings.size

        var nCachedObjects = this.nCachedObjects_
        var nObjects = objectsArr.size

        for (i in 0..objects.size) {
            let object = objects[i]
            let uuid = object.uuid
            let indexOpt = indicesByUUID.get(uuid)

            if (indexOpt.isSome()) {
                let index = indexOpt.getOrThrow()
                indicesByUUID.remove(uuid)

                if (index < nCachedObjects) {
                    // 对象在缓存中，缩小缓存区域
                    let firstActiveIndex = nCachedObjects - 1
                    nCachedObjects -= 1
                    let lastCachedObject = objectsArr[firstActiveIndex]
                    let lastIndex = nObjects - 1
                    nObjects -= 1
                    let lastObject = objectsArr[lastIndex]

                    if (index != firstActiveIndex) {
                        indicesByUUID.add(lastCachedObject.uuid, index)
                    }

                    objectsArr[index] = lastCachedObject

                    if (firstActiveIndex != lastIndex) {
                        indicesByUUID.add(lastObject.uuid, firstActiveIndex)
                    }

                    objectsArr[firstActiveIndex] = lastObject
                    objectsArr.remove(lastIndex..lastIndex + 1)

                    // 为所有绑定执行相同操作
                    for (j in 0..nBindings) {
                        let bindingsForPath = bindings[j]
                        let lastCached = bindingsForPath[firstActiveIndex]
                        let last = bindingsForPath[lastIndex]

                        bindingsForPath[index] = lastCached
                        bindingsForPath[firstActiveIndex] = last
                        bindingsForPath.remove(lastIndex..lastIndex + 1)
                    }

                } else {
                    // 对象在活跃区域，与最后一个交换并弹出
                    let lastIndex = nObjects - 1
                    nObjects -= 1
                    let lastObject = objectsArr[lastIndex]

                    if (index != lastIndex) {
                        indicesByUUID.add(lastObject.uuid, index)
                    }

                    objectsArr[index] = lastObject
                    objectsArr.remove(lastIndex..lastIndex + 1)

                    // 为所有绑定执行相同操作
                    for (j in 0..nBindings) {
                        let bindingsForPath = bindings[j]
                        bindingsForPath[index] = bindingsForPath[lastIndex]
                        bindingsForPath.remove(lastIndex..lastIndex + 1)
                    }
                }
            }
        }

        this.nCachedObjects_ = nCachedObjects
        this.stats.add("total", this._objects.size)
        this.stats.add("inUse", this._objects.size - this.nCachedObjects_)
    }

    /**
     * @param[zh-cn] path 属性路径
     * @param[zh-cn] parsedPath 解析后的路径
     * @return[zh-cn] 绑定数组
     *
     * 订阅属性路径 — 返回给定路径的绑定数组
     * 由 PropertyBinding.Composite 使用
     *
     * @param[en] path The property path
     * @param[en] parsedPath The parsed path
     * @return[en] The array of bindings
     *
     * Subscribes to a property path — returns the binding array for the given path.
     * Used by PropertyBinding.Composite
     */
    internal func subscribe_(path: String, parsedPath: HashMap<String, Any>): ArrayList<PropertyBinding> {
        let indicesByPath = this._bindingsIndicesByPath
        let indexOpt = indicesByPath.get(path)

        if (indexOpt.isSome()) {
            return this._bindings[indexOpt.getOrThrow()]
        }

        let paths = this._paths
        let parsedPaths = this._parsedPaths
        let objects = this._objects
        let nObjects = objects.size
        let nCachedObjects = this.nCachedObjects_
        let bindingsForPath = ArrayList<PropertyBinding>()

        let index = this._bindings.size
        indicesByPath.add(path, index)

        paths.add(path)
        parsedPaths.add(parsedPath)
        this._bindings.add(bindingsForPath)

        for (i in nCachedObjects..objects.size) {
            let object = objects[i]
            bindingsForPath.add(PropertyBinding(object, path, parsedPath))
        }

        return bindingsForPath
    }

    /**
     * @param[zh-cn] path 属性路径
     *
     * 取消订阅属性路径 — 告诉组忘记属性路径
     *
     * @param[en] path The property path
     *
     * Unsubscribes from a property path — tells the group to forget the path
     */
    internal func unsubscribe_(path: String): Unit {
        let indicesByPath = this._bindingsIndicesByPath
        let indexOpt = indicesByPath.get(path)

        if (indexOpt.isSome()) {
            let index = indexOpt.getOrThrow()

            let paths = this._paths
            let parsedPaths = this._parsedPaths
            let bindings = this._bindings
            let lastBindingsIndex = bindings.size - 1
            let lastBindings = bindings[lastBindingsIndex]
            let lastBindingsPath = paths[lastBindingsIndex]

            indicesByPath.add(lastBindingsPath, index)

            bindings[index] = lastBindings
            bindings.remove(lastBindingsIndex..lastBindingsIndex + 1)

            parsedPaths[index] = parsedPaths[lastBindingsIndex]
            parsedPaths.remove(lastBindingsIndex..lastBindingsIndex + 1)

            paths[index] = paths[lastBindingsIndex]
            paths.remove(lastBindingsIndex..lastBindingsIndex + 1)
        }
    }
}
