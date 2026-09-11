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
 * @file[zh-cn] bgfx 扩展兼容层
 * @brief[zh-cn] 替代 WebGLExtensions，提供兼容接口
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLExtensions.js。bgfx 内部处理所有平台扩展，不需要像 WebGL 那样手动查询和加载扩展。此类提供兼容接口，使上层代码无需修改。
 *
 * @file[en] bgfx Extension Compatibility Layer
 * @brief[en] Replaces WebGLExtensions, provides compatible interface
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLExtensions.js. bgfx internally handles all platform extensions without needing manual query/load like WebGL. This class provides a compatible interface so upper-level code needs no modification.
 */
package three.rendering.bgfx

import std.collection.*

/**
 * @brief[zh-cn] bgfx 扩展兼容层
 * @explain[zh-cn] 在 WebGL 中需要查询和加载 GPU 扩展，bgfx 在初始化时自动启用所有支持的特性，无需手动查询。此类提供 has/get 接口以兼容 WebGL 代码结构。
 *
 * @brief[en] bgfx extension compatibility layer
 * @explain[en] In WebGL, GPU extensions need to be queried and loaded; bgfx automatically enables all supported features at initialization. This class provides has/get interfaces to maintain WebGL code structure compatibility.
 */
public class BgfxExtensions {
    /**
     * @brief[zh-cn] 支持的扩展映射
     *
     * @brief[en] Map of supported extensions
     */
    private var supported: HashMap<String, Bool> = HashMap<String, Bool>()

    public init() {
        // bgfx 自动支持所有常用扩展，初始化时标记为可用
        this.supported.add("EXT_texture_filter_anisotropic", true)
        this.supported.add("EXT_color_buffer_float", true)
        this.supported.add("OES_texture_float_linear", true)
        this.supported.add("EXT_color_buffer_half_float", true)
        this.supported.add("WEBGL_compressed_texture_s3tc", true)
        this.supported.add("WEBGL_compressed_texture_s3tc_srgb", true)
        this.supported.add("WEBGL_compressed_texture_etc", true)
        this.supported.add("WEBGL_compressed_texture_astc", true)
        this.supported.add("WEBGL_compressed_texture_pvrtc", false)  // bgfx 不直接支持 PVRTC
        this.supported.add("EXT_texture_compression_bptc", true)
        this.supported.add("EXT_texture_compression_rgtc", true)
        this.supported.add("WEBGL_clip_cull_distance", true)
        this.supported.add("WEBGL_multisampled_render_to_texture", true)
        this.supported.add("WEBGL_render_shared_exponent", true)
    }

    /**
     * @brief[zh-cn] 检查扩展是否可用
     * @explain[zh-cn] 对照 WebGLExtensions.has()
     * @param[zh-cn] name 扩展名称
     * @return[zh-cn] 是否可用
     *
     * @brief[en] Checks if an extension is available
     * @explain[en] Corresponds to WebGLExtensions.has()
     * @param[en] name Extension name
     * @return[en] Whether available
     */
    public func has(name: String): Bool {
        return supported.get(name).getOrThrow()
    }

    /**
     * @brief[zh-cn] 获取扩展对象
     * @explain[zh-cn] 对照 WebGLExtensions.get()。bgfx 中扩展始终可用，返回一个标记对象。
     * @param[zh-cn] name 扩展名称
     * @return[zh-cn] 扩展标记（可用时返回 Some）
     *
     * @brief[en] Gets an extension object
     * @explain[en] Corresponds to WebGLExtensions.get(). In bgfx, extensions are always available and return a marker string.
     * @param[en] name Extension name
     * @return[en] Extension marker (Some if available)
     */
    public func get(name: String): Option<String> {
        if (has(name)) {
            return Some("supported")
        }
        return None
    }

    /**
     * @brief[zh-cn] 初始化扩展
     * @explain[zh-cn] 对照 WebGLExtensions.init()。bgfx 无需手动初始化，此方法为空操作。
     *
     * @brief[en] Initializes extensions
     * @explain[en] Corresponds to WebGLExtensions.init(). bgfx requires no manual initialization; this method is a no-op.
     */
    public func `init`(): Unit {
        // bgfx 自动处理扩展，无需手动初始化
    }
}
