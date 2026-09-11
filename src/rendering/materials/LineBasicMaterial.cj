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
 * @file[zh-cn] 线段基础材质
 * @brief[zh-cn] 线段基础材质，支持线宽、线帽和线连接样式
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineBasicMaterial.js。支持 linewidth/linecap/linejoin 属性。
 *
 * @file[en] Line Basic Material
 * @brief[en] Basic line material, supporting linewidth, linecap, and linejoin styles
 * @explain[en] 
 * Corresponds to Three.js materials/LineBasicMaterial.js. Supports linewidth, linecap, and linejoin properties.
 */
package three.rendering.materials

import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 线段基础材质，支持线宽、线帽和线连接样式
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineBasicMaterial.js。支持 linewidth/linecap/linejoin 属性。
 *
 * @brief[en] Basic line material, supporting linewidth, linecap, and linejoin styles
 * @explain[en] 
 * Corresponds to Three.js materials/LineBasicMaterial.js. Supports linewidth, linecap, and linejoin properties.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class LineBasicMaterial <: Material {
    /**
     * @brief[zh-cn] 线宽，默认1
     *
     * @brief[en] Line width, default 1
     */
    public var linewidth: Float64

    /**
     * @brief[zh-cn] 线帽样式，可选'round'/'butt'/'square'，默认'round'
     *
     * @brief[en] Line cap style, options 'round'/'butt'/'square', default 'round'
     */
    public var linecap: String

    /**
     * @brief[zh-cn] 线连接样式，可选'round'/'bevel'/'miter'，默认'round'
     *
     * @brief[en] Line join style, options 'round'/'bevel'/'miter', default 'round'
     */
    public var linejoin: String

    /**
     * @brief[zh-cn] 构造一个新的线段基础材质
     *
     * @brief[en] Construct a new line basic material
     */
    public init() {
        super()
        this.linewidth = 1.0
        this.linecap = "round"
        this.linejoin = "round"
    }
}
