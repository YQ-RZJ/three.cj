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
 * @file[zh-cn] bgfx 环境贴图管理
 * @brief[zh-cn] 替代 WebGLEnvironments，管理环境贴图
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLEnvironments.js。WebGLEnvironments 负责管理 PMREM 环境贴图，bgfx 版本使用 TextureHandle 替代 WebGL 纹理对象。
 *
 * @file[en] bgfx Environment Map Management
 * @brief[en] Replaces WebGLEnvironments, manages environment maps
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLEnvironments.js. WebGLEnvironments manages PMREM environment maps; the bgfx version uses TextureHandle instead of WebGL texture objects.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] 环境贴图信息
 * @explain[zh-cn] 存储单个环境贴图的纹理句柄和相关参数
 *
 * @brief[en] Environment map info
 * @explain[en] Stores texture handle and related parameters for a single environment map
 */
public class EnvironmentInfo {
    /**
     * @brief[zh-cn] 环境贴图纹理句柄
     *
     * @brief[en] Environment map texture handle
     */
    public var texture: TextureHandle = TextureHandle()
    /**
     * @brief[zh-cn] 是否使用 PMREM
     *
     * @brief[en] Whether PMREM is used
     */
    public var usePMREM: Bool = false
    /**
     * @brief[zh-cn] 贴图高度（用于 CubeUV）
     *
     * @brief[en] Map height (for CubeUV)
     */
    public var imageHeight: Int64 = 0

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 环境贴图管理
 * @explain[zh-cn] 对照 WebGLEnvironments，管理环境贴图的获取和缓存
 *
 * @brief[en] bgfx environment map management
 * @explain[en] Corresponds to WebGLEnvironments, manages environment map acquisition and caching
 */
public class BgfxEnvironments {
    /**
     * @brief[zh-cn] 环境贴图缓存（纹理 ID -> EnvironmentInfo）
     *
     * @brief[en] Environment map cache (texture ID -> EnvironmentInfo)
     */
    private var environments: HashMap<Int64, EnvironmentInfo>

    public init() {
        this.environments = HashMap<Int64, EnvironmentInfo>()
    }

    /**
     * @brief[zh-cn] 获取环境贴图
     * @explain[zh-cn] 对照 WebGLEnvironments.get()，按纹理 ID 查找或创建环境贴图
     * @param[zh-cn] textureId 纹理 ID
     * usePMREM 是否使用 PMREM
     * @return[zh-cn] 环境贴图信息
     *
     * @brief[en] Gets an environment map
     * @explain[en] Corresponds to WebGLEnvironments.get(), finds or creates environment map by texture ID
     * @param[en] textureId Texture ID
     * usePMREM Whether to use PMREM
     * @return[en] Environment map info
     */
    public func get(textureId: Int64, usePMREM: Bool): EnvironmentInfo {
        match (environments.get(textureId)) {
            case Some(env) => return env
            case None =>
                let env = EnvironmentInfo()
                env.usePMREM = usePMREM
                environments.add(textureId, env)
                return env
        }
    }

    /**
     * @brief[zh-cn] 释放环境贴图
     * @param[zh-cn] textureId 纹理 ID
     *
     * @brief[en] Disposes an environment map
     * @param[en] textureId Texture ID
     */
    public func dispose(textureId: Int64): Unit {
        match (environments.get(textureId)) {
            case Some(env) =>
                if (env.texture.idx != 0xFFFFu16) {
                    bgfx_destroy_texture_cj(env.texture)
                }
                environments.remove(textureId)
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 释放所有环境贴图
     *
     * @brief[en] Disposes all environment maps
     */
    public func disposeAll(): Unit {
        for ((_, env) in environments) {
            if (env.texture.idx != 0xFFFFu16) {
                bgfx_destroy_texture_cj(env.texture)
            }
        }
        environments = HashMap<Int64, EnvironmentInfo>()
    }
}
