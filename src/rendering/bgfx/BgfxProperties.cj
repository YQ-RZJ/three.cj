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
 * @file[zh-cn] bgfx 属性存储
 * @brief[zh-cn] 替代 WebGLProperties，使用 HashMap 替代 WeakMap 存储对象关联数据
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLProperties.js。在 WebGL 中使用 WeakMap 为 three.js 对象存储渲染相关的内部数据，在仓颉中没有 WeakMap，使用 HashMap<Int64, HashMap<String, Any>> + 对象 id 替代。
 *
 * @file[en] bgfx Properties Storage
 * @brief[en] Replaces WebGLProperties, uses HashMap instead of WeakMap for object-associated data storage
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLProperties.js. In WebGL, WeakMap is used to store render-related internal data for three.js objects; in Cangjie, HashMap<Int64, HashMap<String, Any>> + object id is used instead since WeakMap is not available.
 */
package three.rendering.bgfx

import std.collection.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*

/**
 * @brief[zh-cn] bgfx 属性存储
 * @explain[zh-cn] 对照 WebGLProperties，为 three.js 对象存储渲染相关的内部数据。使用对象的 id 属性作为键，替代 JS 中的 WeakMap。
 *
 * @brief[en] bgfx properties storage
 * @explain[en] Corresponds to WebGLProperties, stores render-related internal data for three.js objects. Uses object id as key instead of JS WeakMap.
 */
public class BgfxProperties {
    /**
     * @brief[zh-cn] 属性映射（对象 ID -> 属性字典）
     *
     * @brief[en] Properties map (object ID -> property dictionary)
     */
    private var properties: HashMap<Int64, HashMap<String, Any>>

    public init() {
        this.properties = HashMap<Int64, HashMap<String, Any>>()
    }

    /**
     * @brief[zh-cn] 检查对象是否有关联数据
     * @explain[zh-cn] 对照 WebGLProperties.has()
     * @param[zh-cn] obj 对象
     * @return[zh-cn] 是否有关联数据
     *
     * @brief[en] Checks if object has associated data
     * @explain[en] Corresponds to WebGLProperties.has()
     * @param[en] obj Object
     * @return[en] Whether has associated data
     */
    public func has(obj: Object3D): Bool {
        return properties.contains(obj.id)
    }

    /**
     * @brief[zh-cn] 获取对象的关联数据映射
     * @explain[zh-cn] 对照 WebGLProperties.get()，如果不存在则创建空映射
     * @param[zh-cn] obj 对象
     * @return[zh-cn] 属性映射
     *
     * @brief[en] Gets object's associated data map
     * @explain[en] Corresponds to WebGLProperties.get(), creates empty map if not found
     * @param[en] obj Object
     * @return[en] Property map
     */
    public func get(obj: Object3D): HashMap<String, Any> {
        match (properties.get(obj.id)) {
            case Some(map) => return map
            case None =>
                let map = HashMap<String, Any>()
                properties.add(obj.id, map)
                return map
        }
    }

    /**
     * @brief[zh-cn] 删除对象的关联数据
     * @explain[zh-cn] 对照 WebGLProperties.remove()
     * @param[zh-cn] obj 对象
     *
     * @brief[en] Removes object's associated data
     * @explain[en] Corresponds to WebGLProperties.remove()
     * @param[en] obj Object
     */
    public func remove(obj: Object3D): Unit {
        properties.remove(obj.id)
    }

    /**
     * @brief[zh-cn] 更新对象的某个属性
     * @explain[zh-cn] 对照 WebGLProperties.update()
     * @param[zh-cn] obj 对象
     * key 属性键
     * value 属性值
     *
     * @brief[en] Updates a property of an object
     * @explain[en] Corresponds to WebGLProperties.update()
     * @param[en] obj Object
     * key Property key
     * value Property value
     */
    public func update(obj: Object3D, key: String, value: Any): Unit {
        get(obj).add(key, value)
    }

    /**
     * @brief[zh-cn] 释放所有数据
     * @explain[zh-cn] 对照 WebGLProperties.dispose()
     *
     * @brief[en] Disposes all data
     * @explain[en] Corresponds to WebGLProperties.dispose()
     */
    public func dispose(): Unit {
        properties = HashMap<Int64, HashMap<String, Any>>()
    }
}
