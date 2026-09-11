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
 * @file[zh-cn] VideoFrame 纹理
 * @brief[zh-cn] 由 VideoFrame（WebCodecs API）构造的纹理，每次 setFrame 后重传 GPU
 * @explain[zh-cn] VideoFrame 纹理：由 VideoFrame（WebCodecs API）构造的纹理，每次 setFrame 后重传 GPU。继承 VideoTexture；bgfx4cj 跨平台后端无 DOM video API，本类保留接口签名以对齐 JS side。默认 generateMipmaps=false、flipY=false、minFilter=LinearFilter。

 * @file[en] VideoFrame Texture
 * @brief[en] Texture constructed from VideoFrame (WebCodecs API), re-uploaded to GPU after each setFrame
 * @explain[en] VideoFrame texture: texture constructed from VideoFrame (WebCodecs API), re-uploaded to GPU after each setFrame. Extends VideoTexture; bgfx4cj cross-platform backend has no DOM video API, this class preserves interface signature to align with JS side. Defaults generateMipmaps=false, flipY=false, minFilter=LinearFilter. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] VideoFrame 纹理类
 * @explain[zh-cn] 继承 VideoTexture，由 VideoFrame（WebCodecs API）构造的纹理，每次 setFrame 后重传 GPU。

 * @brief[en] VideoFrame texture class
 * @explain[en] Extends VideoTexture, texture constructed from VideoFrame (WebCodecs API), re-uploaded to GPU after each setFrame.
 */
public open class VideoFrameTexture <: VideoTexture {

    /**
     * @brief[zh-cn] 构造一个新的 VideoFrame 纹理
     * @param[zh-cn] width 纹理宽度（像素）
     * height 纹理高度（像素）

     * @brief[en] Construct a new VideoFrame texture
     * @param[en] width Texture width in pixels
     * height Texture height in pixels
     */
    public init(width: Int64, height: Int64) {
        super(Array<UInt8>())
        this.kind = "VideoFrameTexture"
        this.generateMipmaps = false
        this.flipY = false
        this.minFilter = LinearFilter
    }

    /**
     * @brief[zh-cn] 设置当前帧的像素数据
     * @param[zh-cn] frame 当前帧像素数据

     * @brief[en] Set current frame pixel data
     * @param[en] frame Current frame pixel data
     */
    public func setFrame(frame: Array<UInt8>): Unit {
        this.image = frame
        this.source.data = frame
        this.source.needsUpdate = true
        this.needsUpdate = true
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新 VideoFrame 纹理实例
     * @return[zh-cn] 克隆的 VideoFrame 纹理实例

     * @brief[en] Return a new VideoFrame texture instance with the same values as this instance
     * @return[en] Cloned VideoFrame texture instance
     */
    public override func clone(): Texture {
        let t = VideoFrameTexture(this.width, this.height)
        return t.copy(this)
    }
}
