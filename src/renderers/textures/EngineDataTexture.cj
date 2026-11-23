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
 * @file[zh-cn] EngineDataTexture 引擎数据纹理
 * @brief[zh-cn] public 数据纹理资源对象（2D/3D 像素数据的 GPU 上传与生命周期封装）
 * @explain[zh-cn] 承接外部使用者（自定义 pass/LUT/程序生成贴图等）的数据纹理
 * 用途：构造时把像素数组经渲染器上传为 GPU 纹理，dispose 释放；
 * 句柄访问器为 internal（public 面不泄漏句柄类型），引擎内 pass 经其取
 * 纹理句柄；handleIdx 提供只读的句柄索引值（调试/深度集成用途）。
 *
 * @file[en] EngineDataTexture engine data texture
 * @brief[en] Public data-texture resource object (GPU upload and lifecycle wrapper of 2D/3D pixel data)
 * @explain[en] Serves external users' data-texture needs (custom passes / LUTs /
 * procedurally generated images): pixel arrays are uploaded through the renderer
 * on construction, dispose releases; handle accessors are internal (the public
 * face leaks no handle types), engine-internal passes obtain the texture handle
 * through them; handleIdx exposes the read-only handle index (debugging /
 * deep-integration use).
 *
 * @package three.renderers.textures
 */
package three.renderers.textures

import three.renderers._gfx.*
import three.renderers._interfaces.IRenderBackend
import three.utils.memory.PtrArray
import three.utils.safe.IReleasable
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] 引擎数据纹理
 * @explain[zh-cn] 2D（width×height）或 3D（width×height×depth）像素数据的一次性
 * 上传封装：构造时经渲染器的资源通道创建 GPU 纹理（像素数据整块拷贝），dispose
 * 销毁。纹理创建/销毁均经抽象层接口下发，调用方无须接触底层 API。
 * 常用格式与采样组合以静态常量提供（值为后端格式数值，纯 UInt32/UInt64 值，
 * 不泄漏句柄类型）。
 *
 * @brief[en] Engine data texture
 * @explain[en] One-shot upload wrapper of 2D (width×height) or 3D
 * (width×height×depth) pixel data: a GPU texture is created through the
 * renderer's resource channel on construction (pixel data copied in bulk),
 * dispose destroys it. Texture creation/destruction all go through the
 * abstraction interface; callers never touch the underlying API.
 * Common formats and sampler combinations are provided as static constants
 * (backend format values as plain UInt32/UInt64 — no handle types leak).
 */
public class EngineDataTexture <: IReleasable {
    /**
     * @brief[zh-cn] 常用格式：RGBA8（每像素 4 字节）
     *
     * @brief[en] Common format: RGBA8 (4 bytes per pixel)
     */
    public static let FORMAT_RGBA8: UInt32 = GfxTextureFormat.RGBA8.value()

    /**
     * @brief[zh-cn] 常用格式：RGBA16F（半浮点）
     *
     * @brief[en] Common format: RGBA16F (half float)
     */
    public static let FORMAT_RGBA16F: UInt32 = GfxTextureFormat.RGBA16F.value()

    /**
     * @brief[zh-cn] 常用格式：RGBA32F（全浮点）
     *
     * @brief[en] Common format: RGBA32F (full float)
     */
    public static let FORMAT_RGBA32F: UInt32 = GfxTextureFormat.RGBA32F.value()

    /**
     * @brief[zh-cn] 采样组合：U/V 方向钳位
     *
     * @brief[en] Sampler combination: U/V clamp
     */
    public static let FLAGS_CLAMP_UV: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP

    /**
     * @brief[zh-cn] 采样组合：U/V/W 三方向钳位（3D LUT 常用）
     *
     * @brief[en] Sampler combination: U/V/W clamp (common for 3D LUTs)
     */
    public static let FLAGS_CLAMP_UVW: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP |
        GfxTextureFlag.SAMPLER_W_CLAMP

    /**
     * @brief[zh-cn] 采样组合：U/V/W 三方向钳位 + 点采样（无过滤的精确查询，
     * 3D LUT 常用）
     *
     * @brief[en] Sampler combination: U/V/W clamp + point sampling (exact
     * lookup without filtering, common for 3D LUTs)
     */
    public static let FLAGS_CLAMP_UVW_POINT: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP |
        GfxTextureFlag.SAMPLER_W_CLAMP | GfxTextureFlag.SAMPLER_MIN_POINT | GfxTextureFlag.SAMPLER_MAG_POINT

    /**
     * @brief[zh-cn] 渲染器（资源创建/销毁通道）
     *
     * @brief[en] The renderer (resource create/destroy channel)
     */
    private let backend: Option<IRenderBackend>

    /**
     * @brief[zh-cn] 纹理宽（像素）
     *
     * @brief[en] Texture width (pixels)
     */
    private let _width: Int64

    /**
     * @brief[zh-cn] 纹理高（像素）
     *
     * @brief[en] Texture height (pixels)
     */
    private let _height: Int64

    /**
     * @brief[zh-cn] 纹理深（层数；1=2D 纹理，>1=3D 纹理）
     *
     * @brief[en] Texture depth (layers; 1 = 2D texture, >1 = 3D texture)
     */
    private let _depth: Int64

    /**
     * @brief[zh-cn] 纹理格式（后端格式数值，重建时沿用）
     *
     * @brief[en] Texture format (backend format value, reused on rebuild)
     */
    private let _format: UInt32

    /**
     * @brief[zh-cn] 纹理标志位组合（重建时沿用）
     *
     * @brief[en] Texture flag combination (reused on rebuild)
     */
    private let _flags: UInt64

    /**
     * @brief[zh-cn] 纹理句柄
     *
     * @brief[en] Texture handle
     */
    private var _tex: GfxTextureHandle = GfxTextureHandle.INVALID

    /**
     * @brief[zh-cn] 构造 2D 数据纹理并上传像素数据
     * @param[zh-cn] renderer 渲染器（资源通道）
     * width 宽（像素）
     * height 高（像素）
     * pixels 像素数据（按行优先排列，字节数须 ≥ width×height×每像素字节数）
     * format 纹理格式（取 FORMAT_* 常量）
     * flags 采样标志组合（默认 0 = 后端默认）
     *
     * @brief[en] Constructs a 2D data texture and uploads the pixel data
     * @param[en] renderer The renderer (resource channel)
     * width Width (pixels)
     * height Height (pixels)
     * pixels Pixel data (row-major; byte count must be ≥ width×height×bytes-per-pixel)
     * format Texture format (use the FORMAT_* constants)
     * flags Sampler flag combination (default 0 = backend default)
     */
    public init(backend: IRenderBackend, width: Int64, height: Int64, pixels: Array<UInt8>, format!: UInt32,
        flags!: UInt64 = 0u64) {
        this.backend = Some(backend)
        this._width = width
        this._height = height
        this._depth = 1
        this._format = format
        this._flags = flags
        this._upload(pixels)
    }

    /**
     * @brief[zh-cn] 无效占位实例（不触达 GPU）
     * @explain[zh-cn] 仅供需要"无效纹理"占位语义的调用方（如脚本绑定的 nil 占位）：
     * 不创建任何 GPU 资源，isValid 恒为 false，关联 pass 据此跳过提交。
     *
     * @brief[en] Invalid placeholder instance (touches no GPU)
     * @explain[en] Only for callers needing "invalid texture" placeholder semantics
     * (e.g. nil placeholders in script bindings): creates no GPU resource,
     * isValid is always false, and the associated pass skips submission on it.
     */
    public static func invalid(): EngineDataTexture {
        return EngineDataTexture()
    }

    /**
     * 占位构造（invalid() 专用）：不上传、不触达后端。
     */
    private init() {
        this.backend = None
        this._width = 0
        this._height = 0
        this._depth = 1
        this._format = 0u32
        this._flags = 0u64
    }

    /**
     * @brief[zh-cn] 构造 3D 数据纹理并上传体素数据
     * @param[zh-cn] renderer 渲染器（资源通道）
     * width 宽（像素）
     * height 高（像素）
     * depth 深度（层数，>1）
     * pixels 体素数据（层优先排列）
     * format 纹理格式（取 FORMAT_* 常量）
     * flags 采样标志组合（默认 0 = 后端默认）
     *
     * @brief[en] Constructs a 3D data texture and uploads the voxel data
     * @param[en] renderer The renderer (resource channel)
     * width Width (pixels)
     * height Height (pixels)
     * depth Depth (layers, >1)
     * pixels Voxel data (layer-major)
     * format Texture format (use the FORMAT_* constants)
     * flags Sampler flag combination (default 0 = backend default)
     */
    public init(backend: IRenderBackend, width: Int64, height: Int64, depth: Int64, pixels: Array<UInt8>, format!: UInt32,
        flags!: UInt64 = 0u64) {
        this.backend = Some(backend)
        this._width = width
        this._height = height
        this._depth = depth
        this._format = format
        this._flags = flags
        this._upload(pixels)
    }

    /**
     * @brief[zh-cn] 纹理宽（像素）
     *
     * @brief[en] Texture width (pixels)
     */
    public prop width: Int64 {
        get() { this._width }
    }

    /**
     * @brief[zh-cn] 纹理高（像素）
     *
     * @brief[en] Texture height (pixels)
     */
    public prop height: Int64 {
        get() { this._height }
    }

    /**
     * @brief[zh-cn] 纹理深（层数；1=2D）
     *
     * @brief[en] Texture depth (layers; 1 = 2D)
     */
    public prop depth: Int64 {
        get() { this._depth }
    }

    /**
     * @brief[zh-cn] 纹理句柄（引擎内 pass 取用；public 面不泄漏句柄类型）
     *
     * @brief[en] Texture handle (for engine-internal passes; the public face leaks no handle types)
     */
    protected prop textureHandle: GfxTextureHandle {
        get() { this._tex }
    }

    /**
     * @brief[zh-cn] 纹理句柄索引（只读裸值；调试打印/深度集成用途）
     * @explain[zh-cn] 值为 UInt16 基本类型，不构成句柄类型泄漏。
     *
     * @brief[en] Texture handle index (read-only plain value; debugging / deep-integration use)
     * @explain[en] A plain UInt16 value — not a handle-type leak.
     */
    public func handleIdx(): UInt16 {
        return this._tex.idx
    }

    /**
     * @brief[zh-cn] 纹理是否有效（句柄非 INVALID 哨兵）
     * @explain[zh-cn] 构造失败或 release 后为 false；pass 可据此跳过提交。
     *
     * @brief[en] Whether the texture is valid (handle is not the INVALID sentinel)
     * @explain[en] false after a failed construction or release; passes may skip submission on it.
     */
    public prop isValid: Bool {
        get() { this._tex.isValid }
    }

    /**
     * @brief[zh-cn] GPU 资源是否有效
     *
     * @brief[en] Whether the GPU resource is valid
     */
    public prop releasable: Bool {
        get() { this._tex.isValid }
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源（dispose 的别名，满足链式习惯）
     *
     * @brief[en] Releases the GPU resource (alias of dispose, for chaining-style usage)
     */
    public func dispose(): Unit {
        let _ = this.release()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源（幂等）
     *
     * @brief[en] Releases the GPU resource (idempotent)
     */
    public func release(): Bool {
        if (this._tex.isValid) {
            if (let Some(b) <- this.backend) {
                b.destroyTexture(this._tex)
            }
        }
        this._tex = GfxTextureHandle.INVALID
        return true
    }

    /**
     * 上传像素数据（构造时一次性调用）。
     */
    private func _upload(pixels: Array<UInt8>): Unit {
        if (this._width <= 0 || this._height <= 0 || this._depth <= 0) {
            @LogError(["EngineDataTexture", "invalid size ${this._width}x${this._height}x${this._depth}; skip upload"])
            return
        }
        if (pixels.size <= 0) {
            @LogError(["EngineDataTexture", "empty pixel data; skip upload"])
            return
        }
        let b = match (this.backend) {
            case Some(bb) => bb
            case None => return
        }
        let data = PtrArray<UInt8>(pixels)
        let format = gfxFormat(this._format)
        if (this._depth > 1) {
            this._tex = b.createTexture3D(UInt16(this._width), UInt16(this._height),
                UInt16(this._depth), false, format, this._flags, Some(data))
        } else {
            this._tex = b.createTexture2D(UInt16(this._width), UInt16(this._height), false, 1u16,
                format, this._flags, Some(data))
        }
        if (!this._tex.isValid) {
            @LogError(["EngineDataTexture", "texture creation failed: ${this._width}x${this._height}x${this._depth}"])
        }
    }
}
