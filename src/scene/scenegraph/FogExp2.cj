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
 * @file[zh-cn] FogExp2
 * @brief[zh-cn] 指数雾，随距离指数增长不透明度的雾效果
 * @explain[zh-cn] 与线性雾不同：无 near/far 边界，不透明度 = 1 - e^(-density * distance)。
 * density 控制雾的密度（越大雾越浓），默认 0.00025。
 *
 * @file[en] FogExp2
 * @brief[en] Exponential fog, a fog effect that exponentially increases opacity with distance
 * @explain[en] Unlike linear fog: no near/far boundary, opacity = 1 - e^(-density * distance).
 * density controls fog density (larger = denser), default 0.00025.
 */
package three.scene.scenegraph
import three.core.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 指数雾类，随距离指数增长不透明度
 *
 * @brief[en] Exponential fog class, exponentially increasing opacity with distance
 */
@JsonAdapter
public class FogExp2 {

    /**
     * @brief[zh-cn] 雾的颜色
     *
     * @brief[en] Fog color
     */
    public var color: Color

    /**
     * @brief[zh-cn] 雾密度（指数衰减系数），默认 0.00025
     *
     * @brief[en] Fog density (exponential decay coefficient), default 0.00025
     */
    public var density: Float64

    /**
     * @brief[zh-cn] 用户可命名标签
     *
     * @brief[en] User-namable tag
     */
    public var name: String

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-argument constructor (for fastjson deserialization)
     */
    public init() {
        this.name = ""
        this.color = Color(0xffffff)
        this.density = 0.00025
    }

    /**
     * @brief[zh-cn] 构造一个新的指数雾
     * @param[zh-cn] color 雾的颜色
     * density 雾密度，默认 0.00025
     *
     * @brief[en] Construct a new exponential fog
     * @param[en] color Fog color
     * density Fog density, default 0.00025
     */
    public init(color: Color, density!: Float64 = 0.00025) {
        this.name = ""
        this.color = color.clone()
        this.density = density
    }

    /**
     * @brief[zh-cn] 用十六进制值构造指数雾
     * @param[zh-cn] hex 十六进制颜色值
     * density 雾密度，默认 0.00025
     *
     * @brief[en] Construct a new exponential fog with a hex color value
     * @param[en] hex Hex color value
     * density Fog density, default 0.00025
     */
    public init(hex: UInt32, density!: Float64 = 0.00025) {
        this.name = ""
        this.color = Color(hex)
        this.density = density
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新指数雾实例
     * @return[zh-cn] 新指数雾实例
     *
     * @brief[en] Return a new exponential fog instance with the same values as this instance
     * @return[en] New exponential fog instance
     */
    public func clone(): FogExp2 {
        return FogExp2(this.color, density: this.density)
    }

    // 将本指数雾序列化为 JSON（手写 toJSON 兼容层已移除，改用 fastjson 宏）。
}