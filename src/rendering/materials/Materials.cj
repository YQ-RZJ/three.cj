/**
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
