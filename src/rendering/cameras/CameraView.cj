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
 * @file[zh-cn] CameraView 相机多视口裁剪配置
 * @brief[zh-cn] 相机多视口裁剪配置
 * @explain[zh-cn] 原实现使用 Option<HashMap<String, Any>> 承载，fastjson 宏要求字段为具体类型，
 * 故提取为独立类：字段与 three.js view 对象的 key 一一对应。
 *
 * @file[en] CameraView camera multi-viewport clipping configuration
 * @brief[en] Camera multi-viewport clipping configuration
 * @explain[en] Original implementation used Option<HashMap<String, Any>>, but fastjson macro requires
 * concrete type fields, so extracted as an independent class: fields correspond one-to-one
 * with three.js view object keys.
 *
 * @package three.rendering.cameras
 */
package three.rendering.cameras

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 相机多视口裁剪配置
 *
 * @brief[en] Camera multi-viewport clipping configuration
 */
@JsonAdapter
public class CameraView {
    /**
     * @brief[zh-cn] 视口裁剪是否启用
     *
     * @brief[en] Whether viewport clipping is enabled
     */
    public var enabled: Bool

    /**
     * @brief[zh-cn] 全视口宽度（像素）
     *
     * @brief[en] Full viewport width (pixels)
     */
    public var fullWidth: Float64

    /**
     * @brief[zh-cn] 全视口高度（像素）
     *
     * @brief[en] Full viewport height (pixels)
     */
    public var fullHeight: Float64

    /**
     * @brief[zh-cn] 视口偏移 X（像素）
     *
     * @brief[en] Viewport offset X (pixels)
     */
    public var offsetX: Float64

    /**
     * @brief[zh-cn] 视口偏移 Y（像素）
     *
     * @brief[en] Viewport offset Y (pixels)
     */
    public var offsetY: Float64

    /**
     * @brief[zh-cn] 视口宽度（像素）
     *
     * @brief[en] Viewport width (pixels)
     */
    public var width: Float64

    /**
     * @brief[zh-cn] 视口高度（像素）
     *
     * @brief[en] Viewport height (pixels)
     */
    public var height: Float64

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init() {
        this.enabled = false
        this.fullWidth = 1.0
        this.fullHeight = 1.0
        this.offsetX = 0.0
        this.offsetY = 0.0
        this.width = 1.0
        this.height = 1.0
    }

    /**
     * @brief[zh-cn] 构造相机视口配置
     * @param[zh-cn] enabled 是否启用
     * fullWidth 全视口宽度
     * fullHeight 全视口高度
     * offsetX 视口偏移 X
     * offsetY 视口偏移 Y
     * width 视口宽度
     * height 视口高度
     *
     * @brief[en] Construct camera view configuration
     * @param[en] enabled Whether enabled
     * fullWidth Full viewport width
     * fullHeight Full viewport height
     * offsetX Viewport offset X
     * offsetY Viewport offset Y
     * width Viewport width
     * height Viewport height
     */
    public init(enabled: Bool, fullWidth: Float64, fullHeight: Float64, offsetX: Float64, offsetY: Float64, width: Float64, height: Float64) {
        this.enabled = enabled
        this.fullWidth = fullWidth
        this.fullHeight = fullHeight
        this.offsetX = offsetX
        this.offsetY = offsetY
        this.width = width
        this.height = height
    }

    /**
     * @brief[zh-cn] 深拷贝
     * @return[zh-cn] 新的 CameraView 实例
     *
     * @brief[en] Deep copy
     * @return[en] New CameraView instance
     */
    public func clone(): CameraView {
        return CameraView(this.enabled, this.fullWidth, this.fullHeight, this.offsetX, this.offsetY, this.width, this.height)
    }

    /**
     * @brief[zh-cn] 转换为 HashMap（供手写 toJSON 兼容层输出 three.js view 对象结构）
     * @return[zh-cn] 视口配置 HashMap
     *
     * @brief[en] Convert to HashMap (for handwritten toJSON compatibility layer to output three.js view object structure)
     * @return[en] View configuration HashMap
     */
    public func toHashMap(): HashMap<String, Any> {
        let m = HashMap<String, Any>()
        m.add("enabled", this.enabled)
        m.add("fullWidth", this.fullWidth)
        m.add("fullHeight", this.fullHeight)
        m.add("offsetX", this.offsetX)
        m.add("offsetY", this.offsetY)
        m.add("width", this.width)
        m.add("height", this.height)
        return m
    }
}
