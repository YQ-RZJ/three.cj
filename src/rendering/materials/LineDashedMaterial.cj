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
 * @file[zh-cn] 虚线材质
 * @brief[zh-cn] 虚线材质，在LineBasicMaterial基础上支持虚线样式
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineDashedMaterial.js。在 LineBasicMaterial 基础上增加 dashSize 和 gapSize 属性，
 * 用于控制虚线的线段长度和间隔长度。
 *
 * @file[en] Line Dashed Material
 * @brief[en] Dashed line material, extending LineBasicMaterial with dashed line style
 * @explain[en] 
 * Corresponds to Three.js materials/LineDashedMaterial.js. Adds dashSize and gapSize properties on top of LineBasicMaterial,
 * used to control the dash length and gap length of dashed lines.
 */
package three.rendering.materials

import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 虚线材质，支持dashSize和gapSize
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineDashedMaterial.js。dashSize 控制虚线线段长度，gapSize 控制间隔长度。
 *
 * @brief[en] Dashed line material, supporting dashSize and gapSize
 * @explain[en] 
 * Corresponds to Three.js materials/LineDashedMaterial.js. dashSize controls the dash length, gapSize controls the gap length.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class LineDashedMaterial <: Material {
    /**
     * @brief[zh-cn] 虚线线段长度，默认3
     *
     * @brief[en] Dash size, default 3
     */
    public var dashSize: Float64

    /**
     * @brief[zh-cn] 虚线间隔长度，默认1
     *
     * @brief[en] Gap size, default 1
     */
    public var gapSize: Float64

    /**
     * @brief[zh-cn] 构造一个新的虚线材质
     *
     * @brief[en] Construct a new dashed line material
     */
    public init() { super(); this.dashSize = 3.0; this.gapSize = 1.0 }
}
