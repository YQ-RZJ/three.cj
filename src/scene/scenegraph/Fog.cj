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
 * @file[zh-cn] Fog
 * @brief[zh-cn] 线性雾，随距离线性增加不透明度的雾效果
 * @explain[zh-cn] 在 near 距离处无雾，在 far 距离处完全遮挡。
 * 颜色定义雾的颜色；near/far 定义雾的起止距离。
 *
 * @file[en] Fog
 * @brief[en] Linear fog, a fog effect that linearly increases opacity with distance
 * @explain[en] No fog at near distance, fully obscured at far distance.
 * Color defines the fog color; near/far define the fog start and end distances.
 */
package three.scene.scenegraph
import three.core.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 线性雾类，随距离线性增加不透明度
 *
 * @brief[en] Linear fog class, linearly increasing opacity with distance
 */
@JsonAdapter
public class Fog {

    /**
     * @brief[zh-cn] 雾的颜色
     *
     * @brief[en] Fog color
     */
    public var color: Color

    /**
     * @brief[zh-cn] 雾起始距离（无雾），默认 1
     *
     * @brief[en] Fog start distance (no fog), default 1
     */
    public var near: Float64

    /**
     * @brief[zh-cn] 雾终止距离（完全遮挡），默认 1000
     *
     * @brief[en] Fog end distance (fully obscured), default 1000
     */
    public var far: Float64

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
        this.near = 1.0
        this.far = 1000.0
    }

    /**
     * @brief[zh-cn] 构造一个新的线性雾
     * @param[zh-cn] color 雾的颜色
     * near 雾起始距离，默认 1
     * far 雾终止距离，默认 1000
     *
     * @brief[en] Construct a new linear fog
     * @param[en] color Fog color
     * near Fog start distance, default 1
     * far Fog end distance, default 1000
     */
    public init(color: Color, near!: Float64 = 1.0, far!: Float64 = 1000.0) {
        this.name = ""
        this.color = color.clone()
        this.near = near
        this.far = far
    }

    /**
     * @brief[zh-cn] 用十六进制值构造线性雾
     * @param[zh-cn] hex 十六进制颜色值
     * near 雾起始距离，默认 1
     * far 雾终止距离，默认 1000
     *
     * @brief[en] Construct a new linear fog with a hex color value
     * @param[en] hex Hex color value
     * near Fog start distance, default 1
     * far Fog end distance, default 1000
     */
    public init(hex: UInt32, near!: Float64 = 1.0, far!: Float64 = 1000.0) {
        this.name = ""
        this.color = Color(hex)
        this.near = near
        this.far = far
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新雾实例
     * @return[zh-cn] 新雾实例
     *
     * @brief[en] Return a new fog instance with the same values as this instance
     * @return[en] New fog instance
     */
    public func clone(): Fog {
        return Fog(this.color, near: this.near, far: this.far)
    }

    // 将本雾序列化为 JSON（手写 toJSON 兼容层已移除，改用 fastjson 宏）。
}