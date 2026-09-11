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
 * @file[zh-cn] 3D 渲染目标
 * @brief[zh-cn] 继承 RenderTarget，用于 3D 纹理渲染目标
 * @explain[zh-cn] RenderTarget3D 是 RenderTarget 的 3D 版本，用于 3D 纹理的离屏渲染。在 bgfx 渲染后端中，3D 渲染目标对应 bgfx 的 3D texture handle。对照源码: Three.js RenderTarget3D.js
 *
 * @file[en] Render Target 3D
 * @brief[en] Extends RenderTarget, used for 3D texture render targets
 * @explain[en] RenderTarget3D is the 3D version of RenderTarget, used for off-screen rendering of 3D textures. In the bgfx rendering backend, 3D render targets correspond to bgfx's 3D texture handle. Reference: Three.js RenderTarget3D.js
 */
package three.rendering.rendertarget

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 3D 渲染目标类，继承自 RenderTarget
 * @explain[zh-cn] RenderTarget3D 是 RenderTarget 的 3D 版本，用于 3D 纹理的离屏渲染。
 *
 * @brief[en] 3D render target class, extends RenderTarget
 * @explain[en] RenderTarget3D is the 3D version of RenderTarget, used for off-screen rendering of 3D textures.
 */
public class RenderTarget3D <: RenderTarget {
    /**
     * @brief[zh-cn] 构造新的 3D 渲染目标
     * @param[zh-cn] width 渲染目标宽度，默认为 1
     * height 渲染目标高度，默认为 1
     * depth 渲染目标深度，默认为 1
     *
     * @brief[en] Construct a new 3D render target
     * @param[en] width Render target width, defaults to 1
     * height Render target height, defaults to 1
     * depth Render target depth, defaults to 1
     */
    public init(width!: Int64 = 1, height!: Int64 = 1, depth!: Int64 = 1) {
        super(width: width, height: height)
        this.kind = "RenderTarget3D"
        this.depth = depth
    }

    /**
     * @brief[zh-cn] 将给定 3D 渲染目标的设置复制到此实例
     * @param[zh-cn] source 要复制的 3D 渲染目标
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copy settings from the given 3D render target to this instance
     * @param[en] source 3D render target to copy from
     * @return[en] Reference to this instance
     */
    public func copy(source: RenderTarget3D): RenderTarget3D {
        super.copy(source)
        return this
    }

    /**
     * @brief[zh-cn] 返回从此实例复制值的新 3D 渲染目标
     * @return[zh-cn] 此实例的克隆
     *
     * @brief[en] Return a new 3D render target with values copied from this instance
     * @return[en] Clone of this instance
     */
    public func clone(): RenderTarget3D {
        let rt = RenderTarget3D()
        return rt.copy(this)
    }
}
