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
 * @file[zh-cn] 贴图数据源
 * @brief[zh-cn] 贴图数据源，持有像素数组及其版本号
 * @explain[zh-cn] Source 与 Texture 分离：多个 Texture 可共享同一 Source（如 CubeTexture 6 面共享纹理缓冲）。渲染器内部按 version 增量更新 GPU 缓冲；needsUpdate=true 时下次 render 会重传。

 * @file[en] Texture Source
 * @brief[en] Texture data source, holding pixel array and its version
 * @explain[en] Source is separated from Texture: multiple Textures can share the same Source (e.g., CubeTexture 6 faces share texture buffer). The renderer incrementally updates GPU buffers by version; when needsUpdate=true, the next render will re-upload. 
 */
package three.rendering.textures

import three.core.math.MathUtils
import three.core.interfaces.ILoadResult
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 贴图数据源类
 * @explain[zh-cn] 持有像素数组 data 及其版本号 version/needsUpdate。与 Texture 分离，多个 Texture 可共享同一 Source。渲染器内部按 version 增量更新 GPU 缓冲。

 * @brief[en] Texture data source class
 * @explain[en] Holds pixel array data and its version/needsUpdate. Separated from Texture, multiple Textures can share the same Source. The renderer incrementally updates GPU buffers by version.
 */
@JsonAdapter
public open class Source <: ILoadResult {

    /**
     * @brief[zh-cn] 像素数据数组（渲染器内部按 format/type 解释）

     * @brief[en] Pixel data array (interpreted by format/type in the renderer)
     */
    public var data: Array<UInt8>

    /**
     * @brief[zh-cn] 数据宽度（像素）

     * @brief[en] Data width in pixels
     */
    public var width: Int64

    /**
     * @brief[zh-cn] 数据高度（像素）

     * @brief[en] Data height in pixels
     */
    public var height: Int64

    /**
     * @brief[zh-cn] 渲染器内部版本号，每次 needsUpdate=true 时 render 后递增

     * @brief[en] Renderer internal version number, incremented after render when needsUpdate=true
     */
    public var version: Int64

    /**
     * @brief[zh-cn] 渲染器内部增量更新标志，true 时下次 render 会重传 GPU 缓冲

     * @brief[en] Renderer internal incremental update flag, when true the next render will re-upload GPU buffer
     */
    @JsonIgnore
    public mut prop needsUpdate: Bool {
        get() { this._needsUpdate }
        set(v) {
            if (v) { this.version += 1 }
            this._needsUpdate = v
        }
    }
    /**
     * @brief[zh-cn] 私有 backing field（不参与序列化）
     *
     * @brief[en] Private backing field (excluded from serialization)
     */
    private var _needsUpdate: Bool

    /**
     * @brief[zh-cn] 数据准备就绪标志

     * @brief[en] Data ready flag
     */
    public var dataReady: Bool

    /**
     * @brief[zh-cn] 类型标签

     * @brief[en] Type tag
     */
    public var kind: String

    /**
     * @brief[zh-cn] 构造一个新的贴图数据源
     * @param[zh-cn] data 像素数组，默认空
     * width 数据宽度（像素），默认 0
     * height 数据高度（像素），默认 0

     * @brief[en] Construct a new texture data source
     * @param[en] data Pixel array, defaults to empty
     * width Data width in pixels, defaults to 0
     * height Data height in pixels, defaults to 0
     */
    public init(data!: Array<UInt8> = Array<UInt8>(), width!: Int64 = 0, height!: Int64 = 0) {
        this.data = data
        this.width = width
        this.height = height
        this.version = 0
        this._needsUpdate = false
        this.dataReady = true
        this.kind = "Source"
    }

    /**
     * @brief[zh-cn] 取贴图宽高
     * @return[zh-cn] (width, height) 元组

     * @brief[en] Get texture width and height
     * @return[en] (width, height) tuple
     */
    public func getSize(): (Int64, Int64) {
        return (this.width, this.height)
    }
}
