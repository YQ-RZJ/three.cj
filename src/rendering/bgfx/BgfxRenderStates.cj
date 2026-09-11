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
 * @file[zh-cn] bgfx 渲染状态栈
 * @brief[zh-cn] 替代 WebGLRenderStates，管理渲染状态栈
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLRenderStates.js。WebGLRenderStates 负责管理每帧的渲染状态（光源、阴影等）。
 *
 * @file[en] bgfx Render State Stack
 * @brief[en] Replaces WebGLRenderStates, manages render state stack
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLRenderStates.js. WebGLRenderStates manages per-frame render states (lights, shadows, etc.).
 */
package three.rendering.bgfx

import std.collection.*
import three.rendering.lights.Light
import three.rendering.lights.LightShadow

/**
 * @brief[zh-cn] 渲染状态
 * @explain[zh-cn] 对照 WebGLRenderState，管理单个场景的光照和阴影列表
 *
 * @brief[en] Render state
 * @explain[en] Corresponds to WebGLRenderState, manages light and shadow lists for a single scene
 */
public class BgfxRenderState {
    /**
     * @brief[zh-cn] 光照列表
     *
     * @brief[en] Light list
     */
    private var lights: ArrayList<Light>
    /**
     * @brief[zh-cn] 阴影列表
     *
     * @brief[en] Shadow list
     */
    private var shadows: ArrayList<LightShadow>
    /**
     * @brief[zh-cn] 当前场景 ID
     *
     * @brief[en] Current scene ID
     */
    private var sceneId: Int64 = -1

    public init() {
        this.lights = ArrayList<Light>()
        this.shadows = ArrayList<LightShadow>()
    }

    /**
     * @brief[zh-cn] 初始化渲染状态
     * @param[zh-cn] sceneId 场景 ID
     *
     * @brief[en] Initialize render state
     * @param[en] sceneId Scene ID
     */
    public func reset(sceneId: Int64): Unit {
        this.sceneId = sceneId
        lights = ArrayList<Light>()
        shadows = ArrayList<LightShadow>()
    }

    /**
     * @brief[zh-cn] 添加光源
     * @param[zh-cn] light 光源对象
     *
     * @brief[en] Add a light
     * @param[en] light Light object
     */
    public func pushLight(light: Light): Unit {
        lights.add(light)
    }

    /**
     * @brief[zh-cn] 添加阴影
     * @param[zh-cn] shadow 阴影对象
     *
     * @brief[en] Add a shadow
     * @param[en] shadow Shadow object
     */
    public func pushShadow(shadow: LightShadow): Unit {
        shadows.add(shadow)
    }

    /**
     * @brief[zh-cn] 获取光源数量
     * @return[zh-cn] 光源数量
     *
     * @brief[en] Get light count
     * @return[en] Light count
     */
    public func getLightCount(): Int64 {
        return lights.size
    }

    /**
     * @brief[zh-cn] 获取阴影数量
     * @return[zh-cn] 阴影数量
     *
     * @brief[en] Get shadow count
     * @return[en] Shadow count
     */
    public func getShadowCount(): Int64 {
        return shadows.size
    }

    /**
     * @brief[zh-cn] 获取光源列表
     * @return[zh-cn] 光源列表
     *
     * @brief[en] Get light list
     * @return[en] Light list
     */
    public func getLights(): ArrayList<Light> {
        return lights
    }

    /**
     * @brief[zh-cn] 获取阴影列表
     * @return[zh-cn] 阴影列表
     *
     * @brief[en] Get shadow list
     * @return[en] Shadow list
     */
    public func getShadows(): ArrayList<LightShadow> {
        return shadows
    }
}

/**
 * @brief[zh-cn] bgfx 渲染状态管理
 * @explain[zh-cn] 对照 WebGLRenderStates，管理渲染状态的缓存和切换
 *
 * @brief[en] bgfx render state management
 * @explain[en] Corresponds to WebGLRenderStates, manages render state caching and switching
 */
public class BgfxRenderStates {
    /**
     * @brief[zh-cn] 渲染状态缓存（场景 ID -> 渲染状态）
     *
     * @brief[en] Render state cache (scene ID -> render state)
     */
    private var renderStates: HashMap<Int64, BgfxRenderState>

    public init() {
        this.renderStates = HashMap<Int64, BgfxRenderState>()
    }

    /**
     * @brief[zh-cn] 获取渲染状态
     * @explain[zh-cn] 对照 WebGLRenderStates.get()，若不存在则自动创建
     * @param[zh-cn] sceneId 场景 ID
     * @return[zh-cn] 渲染状态
     *
     * @brief[en] Get render state
     * @explain[en] Corresponds to WebGLRenderStates.get(), auto-creates if not found
     * @param[en] sceneId Scene ID
     * @return[en] Render state
     */
    public func get(sceneId: Int64): BgfxRenderState {
        match (renderStates.get(sceneId)) {
            case Some(state) => return state
            case None =>
                let state = BgfxRenderState()
                renderStates.add(sceneId, state)
                return state
        }
    }

    /**
     * @brief[zh-cn] 释放所有渲染状态
     *
     * @brief[en] Dispose all render states
     */
    public func dispose(): Unit {
        renderStates = HashMap<Int64, BgfxRenderState>()
    }
}
