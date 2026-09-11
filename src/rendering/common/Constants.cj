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
