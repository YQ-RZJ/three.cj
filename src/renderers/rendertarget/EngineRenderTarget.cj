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
 * @file[zh-cn] EngineRenderTarget 引擎渲染目标
 * @brief[zh-cn] public 渲染目标资源对象（color + 可选 depth 纹理 + frame buffer 的生命周期封装）
 * @explain[zh-cn] 承接 EffectComposer/自定义 pass/外部使用者的 RT 用途：
 * 构造时经渲染器创建 GPU 资源，resize 重建，dispose 释放；
 * 句柄访问器为 internal（public 面不泄漏句柄类型），引擎内 pass 经其取
 * color/depth 纹理与 frame buffer 句柄。
 *
 * @file[en] EngineRenderTarget engine render target
 * @brief[en] Public render-target resource object (lifecycle wrapper of color + optional depth textures and a frame buffer)
 * @explain[en] Serves the RT needs of EffectComposer/custom passes/external users:
 * GPU resources are created through the renderer on construction, rebuilt on resize,
 * and released on dispose; handle accessors are internal (the public face leaks no
 * handle types), engine passes obtain color/depth texture and frame buffer handles through them.
 *
 * @package three.renderers.rendertarget
 */
package three.renderers.rendertarget

import three.renderers._gfx.*
import three.renderers._interfaces.IRenderBackend
import three.utils.safe.IReleasable
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] 引擎渲染目标
 * @explain[zh-cn] color 纹理 + 可选 depth 纹理（D24S8）+ 由二者组成的 frame buffer 的
 * 生命周期封装。创建/重建/销毁均经渲染器的资源通道下发，调用方无须接触底层 API。
 * 深度附件默认 D24S8（新版 bgfx 的 D3D11 后端中 D24 无 DSV 格式，以 D24 为深度
 * 附件创建 frame buffer 会失败返回 INVALID）。
 *
 * @brief[en] Engine render target
 * @explain[en] Lifecycle wrapper of a color texture + optional depth texture (D24S8) +
 * the frame buffer composed of them. Creation/rebuild/destruction all go through the
 * renderer's resource channel; callers never touch the underlying API.
 * The depth attachment defaults to D24S8 (in the new bgfx D3D11 backend D24 has no DSV
 * format; creating a frame buffer with D24 as the depth attachment fails returning INVALID).
 */
public class EngineRenderTarget <: IReleasable {
    /**
     * @brief[zh-cn] 渲染器（资源创建/销毁通道）
     *
     * @brief[en] The renderer (resource create/destroy channel)
     */
    private let backend: IRenderBackend

    /**
     * @brief[zh-cn] RT 宽（物理像素）
     *
     * @brief[en] RT width (physical pixels)
     */
    private var _width: Int64

    /**
     * @brief[zh-cn] RT 高（物理像素）
     *
     * @brief[en] RT height (physical pixels)
     */
    private var _height: Int64

    /**
     * @brief[zh-cn] 颜色纹理格式（bgfx 格式数值，重建时沿用）
     *
     * @brief[en] Color texture format (bgfx format value, reused on rebuild)
     */
    private let _format: UInt32

    /**
     * @brief[zh-cn] 纹理标志位组合（重建时沿用）
     *
     * @brief[en] Texture flag combination (reused on rebuild)
     */
    private let _flags: UInt64

    /**
     * @brief[zh-cn] 是否带 depth 附件
     *
     * @brief[en] Whether a depth attachment is present
     */
    private let _depth: Bool

    /**
     * 句柄包装强化点（第二阶段）：以下句柄字段升级为更强包装时，
     * 仅改动本文件内部实现与 internal 访问器，public 面签名不动。
     *
     * Handle-wrapper hardening point (phase 2): when the handle fields below are
     * upgraded to stronger wrappers, only this file's internals and the internal
     * accessors change; the public face keeps its signatures.
     */

    /**
     * @brief[zh-cn] 颜色纹理句柄
     *
     * @brief[en] Color texture handle
     */
    private var _colorTex: GfxTextureHandle = GfxTextureHandle.INVALID

    /**
     * @brief[zh-cn] 深度纹理句柄（D24S8；_depth=false 时为无效句柄）
     *
     * @brief[en] Depth texture handle (D24S8; invalid when _depth=false)
     */
    private var _depthTex: GfxTextureHandle = GfxTextureHandle.INVALID

    /**
     * @brief[zh-cn] frame buffer 句柄
     *
     * @brief[en] Frame buffer handle
     */
    private var _fb: GfxFrameBufferHandle = GfxFrameBufferHandle.INVALID

    /**
     * @brief[zh-cn] 构造渲染目标并创建 GPU 资源
     * @param[zh-cn] renderer 渲染器（资源通道）
     * width 宽（物理像素）
     * height 高（物理像素）
     * format 颜色纹理格式（bgfx 格式数值，如 TextureFormat.RGBA16F.value()）
     * flags 纹理标志位组合（如 TEXTURE_RT | U/V CLAMP）
     * depth 是否带 D24S8 深度附件（默认 true；无 depth 附件时启用深度测试的行为未定义）
     *
     * @brief[en] Constructs the render target and creates GPU resources
     * @param[en] renderer The renderer (resource channel)
     * width Width (physical pixels)
     * height Height (physical pixels)
     * format Color texture format (bgfx format value, e.g. TextureFormat.RGBA16F.value())
     * flags Texture flag combination (e.g. TEXTURE_RT | U/V CLAMP)
     * depth Whether to attach a D24S8 depth buffer (default true; with no depth attachment,
     * depth-test behavior is undefined)
     */
    public init(backend: IRenderBackend, width: Int64, height: Int64, format!: UInt32, flags!: UInt64,
        depth!: Bool = true) {
        this.backend = backend
        this._width = width
        this._height = height
        this._format = format
        this._flags = flags
        this._depth = depth
        this._create()
    }

    /**
     * @brief[zh-cn] RT 宽（物理像素）
     *
     * @brief[en] RT width (physical pixels)
     */
    public prop width: Int64 {
        get() {
            this._width
        }
    }

    /**
     * @brief[zh-cn] RT 高（物理像素）
     *
     * @brief[en] RT height (physical pixels)
     */
    public prop height: Int64 {
        get() {
            this._height
        }
    }

    /**
     * @brief[zh-cn] 颜色纹理句柄（引擎内 pass 取用；public 面不泄漏句柄类型）
     *
     * @brief[en] Color texture handle (for engine-internal passes; the public face leaks no handle types)
     */
    protected prop colorTexture: GfxTextureHandle {
        get() {
            this._colorTex
        }
    }

    /**
     * @brief[zh-cn] 深度纹理句柄（引擎内 pass 取用；无 depth 附件时为无效句柄）
     *
     * @brief[en] Depth texture handle (for engine-internal passes; invalid when no depth attachment)
     */
    protected prop depthTexture: GfxTextureHandle {
        get() {
            this._depthTex
        }
    }

    /**
     * @brief[zh-cn] frame buffer 句柄（引擎内 pass 设 view 渲染目标用）
     *
     * @brief[en] Frame buffer handle (for engine-internal passes to set view render targets)
     */
    protected prop frameBuffer: GfxFrameBufferHandle {
        get() {
            this._fb
        }
    }

    /**
     * @brief[zh-cn] GPU 资源是否有效
     *
     * @brief[en] Whether the GPU resources are valid
     */
    public prop releasable: Bool {
        get() {
            this._fb.isValid
        }
    }

    /**
     * @brief[zh-cn] 重建为指定尺寸（沿用构造时的格式/标志/深度配置）
     * @param[zh-cn] width 新宽（物理像素）
     * height 新高（物理像素）
     *
     * @brief[en] Rebuilds at the given size (reusing the format/flags/depth configuration from construction)
     * @param[en] width New width (physical pixels)
     * height New height (physical pixels)
     */
    public func resize(width: Int64, height: Int64): Unit {
        if (width <= 0 || height <= 0) {
            return
        }
        if (width == this._width && height == this._height && this._fb.isValid) {
            return
        }
        this._destroy()
        this._width = width
        this._height = height
        this._create()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源（dispose 的别名，满足链式习惯）
     *
     * @brief[en] Releases the GPU resources (alias of dispose, for chaining-style usage)
     */
    public func dispose(): Unit {
        let _ = this.release()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源（幂等）
     *
     * @brief[en] Releases the GPU resources (idempotent)
     */
    public func release(): Bool {
        this._destroy()
        return true
    }

    /**
     * 创建 GPU 资源（color + 可选 depth 纹理 + frame buffer）。
     */
    private func _create(): Unit {
        if (this._width <= 0 || this._height <= 0) {
            @LogError(["EngineRenderTarget", "invalid size ${this._width}x${this._height}; skip creation"])
            return
        }
        let w = UInt16(this._width)
        let h = UInt16(this._height)
        let format = gfxFormat(this._format)
        this._colorTex = this.backend.createTexture2D(w, h, false, 1u16, format, this._flags, None)
        if (this._depth) {
            this._depthTex = this
                .backend
                .createTexture2D(w, h, false, 1u16, GfxTextureFormat.D24S8, this._flags, None)
            let handles = Array<GfxTextureHandle>(2, {
                i => if (i == 0) {
                this._colorTex
            } else {
                this._depthTex
            }
            })
            this._fb = this.backend.createFrameBufferFromHandles(handles, true)
        } else {
            let handles = Array<GfxTextureHandle>(1, {_ => this._colorTex})
            this._fb = this.backend.createFrameBufferFromHandles(handles, true)
        }
        @LogTrace(["EngineRenderTarget", "created ${this._width}x${this._height} fb=${this._fb.idx}"])
    }

    /**
     * 销毁 GPU 资源（幂等；无效句柄跳过）。
     */
    private func _destroy(): Unit {
        if (this._fb.isValid) {
            this.backend.destroyFrameBuffer(this._fb)
        }
        if (this._colorTex.isValid) {
            this.backend.destroyTexture(this._colorTex)
        }
        if (this._depthTex.isValid) {
            this.backend.destroyTexture(this._depthTex)
        }
        this._fb = GfxFrameBufferHandle.INVALID
        this._colorTex = GfxTextureHandle.INVALID
        this._depthTex = GfxTextureHandle.INVALID
    }
}
