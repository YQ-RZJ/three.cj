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
 * @file[zh-cn] 材质工具类
 * @brief[zh-cn] 材质工具类，提供材质类型查询方法
 * @explain[zh-cn] 
 * 提供 getMaterialType 静态方法，返回材质的 kind 类型标签字符串。
 *
 * @file[en] Materials Utility
 * @brief[en] Materials utility class, providing material type query methods
 * @explain[en] 
 * Provides the getMaterialType static method, returning the material's kind type label string.
 */
package three.rendering.materials

import std.collection.*

/**
 * @brief[zh-cn] 材质工具类，提供材质类型查询方法
 *
 * @brief[en] Materials utility class, providing material type query methods
 */
public class Materials {
    /**
     * @brief[zh-cn] 获取材质的类型标签
     * @param[zh-cn] material 材质实例
     * @return[zh-cn] 材质类型标签字符串
     *
     * @brief[en] Get the type label of a material
     * @param[en] material Material instance
     * @return[en] Material type label string
     */
    public static func getMaterialType(material: Material): String { return material.kind }
}
