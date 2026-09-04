/**
 * @file[zh-cn] 常量定义
 * @brief[zh-cn] 渲染通用常量定义
 * @explain[zh-cn] 
 * Constants 定义渲染通用的常量值，包括图元类型（TRIANGLES/LINES/POINTS）
 * 和后端标识（BACKEND）。
 *
 * @file[en] Constants
 * @brief[en] Rendering common constants definitions
 * @explain[en] 
 * Constants defines common rendering constant values, including primitive types (TRIANGLES/LINES/POINTS)
 * and backend identifier (BACKEND).
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染通用常量定义
 * @explain[zh-cn] 
 * 定义图元类型常量和后端标识常量。
 *
 * @brief[en] Rendering common constants definitions
 * @explain[en] 
 * Defines primitive type constants and backend identifier constants.
 */
public class Constants {
    /**
     * @brief[zh-cn] 三角形图元类型
     *
     * @brief[en] Triangle primitive type
     */
    public static let TRIANGLES: Int64 = 0

    /**
     * @brief[zh-cn] 线段图元类型
     *
     * @brief[en] Line primitive type
     */
    public static let LINES: Int64 = 1

    /**
     * @brief[zh-cn] 点图元类型
     *
     * @brief[en] Point primitive type
     */
    public static let POINTS: Int64 = 2

    /**
     * @brief[zh-cn] 后端标识，默认为 "bgfx"
     *
     * @brief[en] Backend identifier, default is "bgfx"
     */
    public static let BACKEND: String = "bgfx"
}
